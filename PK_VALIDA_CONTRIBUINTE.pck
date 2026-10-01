create or replace package PK_VALIDA_CONTRIBUINTE is
  
  procedure pb_envia_sintegra;  
  procedure pb_retorno_sintegra;

end PK_VALIDA_CONTRIBUINTE;
/
create or replace package body PK_VALIDA_CONTRIBUINTE is

  gv_url    varchar2(4000) := 'https://api.arquivo-nfe.com/prod/consulta_cadastro';
  gv_token  varchar2(200)  := 'SEU_TOKEN_AQUI';


  procedure pb_envia_sintegra is

    cursor c_envia is
    select valcontrib_id, CNPJ, IE, CPF, UF
      from valida_contribuinte
     where sit = 1 -- pendente
       and request_id is null;

    l_values      apex_json.t_values;
    v_info        varchar2(1000);
    v_erro        varchar2(1000);
    v_request_id   varchar2(1000); --number;
    vn_sucesso     varchar2(1000); --number;
    s_json         clob;
    v_qt_tenta_env number := 0;
    v_qt_integrado number := 0;
    v_linhas       number := 0;
    v_c_env        c_envia%rowtype;
    v_reg_ret      valida_contribuinte_retorno%rowtype;
  begin

    -- insere solicitação de consulta (integração)
    open c_envia;
    loop
        v_c_env := null;
        fetch c_envia into v_c_env;
        
        <<repete>>
        
        -- finaliza qdo processar todos os envios ou se exceder o limite definido de tentativas
        exit when c_envia%NOTFOUND or v_qt_tenta_env > 2000;
        
        apex_web_service.g_request_headers(1).name  := 'Authorization';
        apex_web_service.g_request_headers(1).value := 'Bearer ' || gv_token;
        apex_web_service.g_request_headers(2).name  := 'uf';
        apex_web_service.g_request_headers(2).value := v_c_env.UF;

        if v_c_env.CNPJ is not null then
            apex_web_service.g_request_headers(3).name := 'cnpj';
            apex_web_service.g_request_headers(3).value := v_c_env.CNPJ;
        elsif v_c_env.CPF is not null then
            apex_web_service.g_request_headers(3).name := 'cpf';
            apex_web_service.g_request_headers(3).value := v_c_env.CPF;
        elsif v_c_env.IE is not null then
            apex_web_service.g_request_headers(3).name := 'ie';
            apex_web_service.g_request_headers(3).value := v_c_env.IE;
        end if;
        
        dbms_output.put_line('Processando valcontrib_id = '||v_c_env.valcontrib_id);

        s_json := null;
        s_json := apex_web_service.make_rest_request(p_url         => gv_url,
                                                     p_http_method => 'POST');

        dbms_output.put_line('s_json request : '||s_json);

        if s_json like '%ERROR 429%' then -- Error 429 Too Many Requests
           dbms_output.put_line('Sleep 15 seg Error 429 Too Many Requests. Linhas processadas = '||v_qt_integrado);
           v_qt_tenta_env := v_qt_tenta_env+1;
           pb_sleep(15);
           goto repete;
        end if;

        l_values.delete;
        apex_json.parse ( p_values => l_values
                        , p_source => s_json);

        v_request_id := null;
        v_info       := null;
        v_erro       := null;

        v_request_id := apex_json.get_varchar2 (p_path => 'request_id' , p0 => 2, p_values => l_values);
        v_info       := apex_json.get_varchar2 (p_path => 'info' , p0 => 1, p_values => l_values);
        v_erro       := apex_json.get_varchar2 (p_path => 'erro' , p0 => 1, p_values => l_values);
        
        -- se o envio já encontrar um registro já integrado a instantes, processar leitura
        if v_info = 'sucesso' then

           v_linhas := apex_json.get_varchar2 (p_path => 'nro_linhas' , p0 => 2, p_values => l_values);  
           --dbms_output.put_line('v_linhas : '||v_linhas);
           
           delete from valida_contribuinte_retorno
            where valcontrib_id = v_c_env.valcontrib_id;

           -- loop retornos
           FOR i IN 1 .. v_linhas LOOP
                v_reg_ret := null;
                v_reg_ret.cnpj          := apex_json.get_varchar2 ('retorno[%d].cnpj', p0 => i, p_values => l_values);
                v_reg_ret.cpf           := apex_json.get_varchar2 ('retorno[%d].cpf', p0 => i, p_values => l_values);
                v_reg_ret.ie            := apex_json.get_varchar2 ('retorno[%d].ie', p0 => i, p_values => l_values);
                v_reg_ret.habilitado    := apex_json.get_varchar2 ('retorno[%d].xhabilitado', p0 => i, p_values => l_values);
                v_request_id            := apex_json.get_varchar2 (p_path => 'retorno[%d].request_id' , p0 => i, p_values => l_values);
                v_reg_ret.msg_retorno   := apex_json.get_varchar2 (p_path => 'retorno[%d].ocorrencia' , p0 => i, p_values => l_values);
                v_reg_ret.ind_cred_nfe  := apex_json.get_varchar2 (p_path => 'retorno[%d].xind_cred_nfe' , p0 => i, p_values => l_values);
                v_reg_ret.ind_cred_cte  := apex_json.get_varchar2 (p_path => 'retorno[%d].xind_cred_cte' , p0 => i, p_values => l_values);
                v_reg_ret.razao_social  := apex_json.get_varchar2 (p_path => 'retorno[%d].razao_social' , p0 => i, p_values => l_values);
                v_reg_ret.fantasia      := apex_json.get_varchar2 (p_path => 'retorno[%d].fantasia' , p0 => i, p_values => l_values);
                v_reg_ret.cnae          := apex_json.get_varchar2 (p_path => 'retorno[%d].cnae' , p0 => i, p_values => l_values);
                v_reg_ret.dt_ini_ativ   := to_date(apex_json.get_varchar2 (p_path => 'retorno[%d].dt_ini_ativ' , p0 => i, p_values => l_values),'dd/mm/yyyy');
                v_reg_ret.dt_ult_sit    := to_date(apex_json.get_varchar2 (p_path => 'retorno[%d].dt_ult_sit' , p0 => i, p_values => l_values),'dd/mm/yyyy');
                v_reg_ret.dt_baixa      := to_date(apex_json.get_varchar2 (p_path => 'retorno[%d].dt_baixa' , p0 => i, p_values => l_values),'dd/mm/yyyy');
                v_reg_ret.ie_unica      := apex_json.get_varchar2 (p_path => 'retorno[%d].ie_unica' , p0 => i, p_values => l_values);
                v_reg_ret.ie_atual      := apex_json.get_varchar2 (p_path => 'retorno[%d].ie_atual' , p0 => i, p_values => l_values);
                v_reg_ret.logradouro    := apex_json.get_varchar2 (p_path => 'retorno[%d].logradouro' , p0 => i, p_values => l_values);
                v_reg_ret.nro           := apex_json.get_varchar2 (p_path => 'retorno[%d].nro' , p0 => i, p_values => l_values);
                v_reg_ret.compl         := apex_json.get_varchar2 (p_path => 'retorno[%d].compl' , p0 => i, p_values => l_values);
                v_reg_ret.bairro        := apex_json.get_varchar2 (p_path => 'retorno[%d].bairro' , p0 => i, p_values => l_values);
                v_reg_ret.cidade_ibge   := apex_json.get_varchar2 (p_path => 'retorno[%d].cidade_ibge' , p0 => i, p_values => l_values);
                v_reg_ret.municipio     := apex_json.get_varchar2 (p_path => 'retorno[%d].municipio' , p0 => i, p_values => l_values);
                v_reg_ret.cep           := apex_json.get_varchar2 (p_path => 'retorno[%d].cep' , p0 => i, p_values => l_values);
                v_reg_ret.chabilitado   := apex_json.get_varchar2 (p_path => 'retorno[%d].chabilitado' , p0 => i, p_values => l_values);
                v_reg_ret.cind_cred_nfe := apex_json.get_varchar2 (p_path => 'retorno[%d].cind_cred_nfe' , p0 => i, p_values => l_values);
                v_reg_ret.cind_cred_cte := apex_json.get_varchar2 (p_path => 'retorno[%d].cind_cred_cte' , p0 => i, p_values => l_values);
                v_reg_ret.dt_hr         := sysdate;
                v_reg_ret.valcontrib_id := v_c_env.valcontrib_id;

                --dbms_output.put_line('retorno v_request_id : '||v_request_id);

                -- insere retorno
                insert into valida_contribuinte_retorno values v_reg_ret;
                
                dbms_output.put_line('update valida_contribuinte_retorno request_id = '||v_request_id||' valcontrib_id = '||v_c_env.valcontrib_id);
                  
                -- registra requisicao e situacao como processado
                update valida_contribuinte
                   set request_id     = v_request_id
                     , sit            = 3 -- processado
                     , msg_integracao = v_reg_ret.msg_retorno
                 where valcontrib_id  = v_c_env.valcontrib_id;

             END LOOP;

             v_qt_integrado := v_qt_integrado+1;
       else
           if v_request_id is not null then
             
              dbms_output.put_line('update valida_contribuinte aguardando request_id = '||v_request_id||' valcontrib_id = '||v_c_env.valcontrib_id);

              -- registra requisicao de integração
              update valida_contribuinte
                 set request_id     = v_request_id
                   , msg_integracao = 'Integrado, aguardando retorno da integração...'
               where valcontrib_id  = v_c_env.valcontrib_id;

               v_qt_integrado := v_qt_integrado+1;

           else
             
               dbms_output.put_line('valida_contribuinte retorno de erro request_id = '||v_request_id||', valcontrib_id = '||v_c_env.valcontrib_id||', Info : '||v_info||' Erro : '||v_erro||' Msg '||v_reg_ret.msg_retorno);

               -- registra requisicao e situacao como processado
               update valida_contribuinte
                  set sit            = 2 -- processado com erro
                    , msg_integracao = 'Info : '||v_info||' Erro : '||v_erro||' Msg '||v_reg_ret.msg_retorno
                where valcontrib_id  = v_c_env.valcontrib_id;

           end if;

       end if;

       v_qt_tenta_env := v_qt_tenta_env+1;

    end loop;
    
    DBMS_OUTPUT.PUT_LINE('Fim pb_envia_sintegra');

  exception
       when others then
         raise_application_error(-20000, 'Erro pb_envia_sintegra erro = '||sqlerrm||', s_json = '||s_json);
         --Dbms_Output.put_line ( DBMS_UTILITY.FORMAT_ERROR_STACK() );
  end;
  

  procedure pb_retorno_sintegra is

    cursor c_ret is
    select *
      from valida_contribuinte
     where sit = 1 -- pendente
       and request_id is not null;

    l_values      apex_json.t_values;
    v_info        varchar2(1000);
    v_erro        varchar2(1000);
    v_request_id  varchar2(1000); 
    s_json         clob;
    v_c_ret        c_ret%rowtype;
    v_reg_ret      valida_contribuinte_retorno%rowtype;
    v_qt_tenta_env number := 0;
    v_qt_integrado number := 0;
    v_linhas       number := 0;
  begin

    -- consulta / insere retorno
    open c_ret;
    loop
        v_c_ret := null;
        fetch c_ret into v_c_ret;
        
        <<repete>>

        if v_qt_tenta_env > 2000 then
            dbms_output.put_line('Finaliza processo por exceder o limite definido de execuções');
        end if;
        
        -- Finaliza processo por exceder o limite definido de execuções
        exit when c_ret%NOTFOUND or v_qt_tenta_env > 2000;
      
        apex_web_service.g_request_headers(1).name  := 'Authorization';
        apex_web_service.g_request_headers(1).value := 'Bearer ' || gv_token;
        apex_web_service.g_request_headers(2).name  := 'uf';
        apex_web_service.g_request_headers(2).value := v_c_ret.UF;
        apex_web_service.g_request_headers(3).name := 'request_id';
        apex_web_service.g_request_headers(3).value := v_c_ret.request_id;

        s_json := apex_web_service.make_rest_request(p_url         => gv_url,
                                                     p_http_method => 'POST');


        --dbms_output.put_line('s_json ret : '||s_json);

        if s_json like '%ERROR 429%' then -- Error 429 Too Many Requests
           dbms_output.put_line('Sleep 15 seg Error 429 Too Many Requests. Linhas processadas = '||v_qt_integrado);
           v_qt_tenta_env := v_qt_tenta_env+1;
           pb_sleep(15);
           goto repete;
        end if;

        apex_json.parse ( p_values => l_values
                        , p_source => s_json);

        v_request_id := null;
        v_info       := null;
        v_erro       := null;

        v_request_id := apex_json.get_varchar2 (p_path => 'request_id' , p0 => 2, p_values => l_values);
        v_info       := apex_json.get_varchar2 (p_path => 'info' , p0 => 1, p_values => l_values);
        v_erro       := apex_json.get_varchar2 (p_path => 'erro' , p0 => 1, p_values => l_values);
        
        if v_info = 'sucesso' then
   
           v_linhas := apex_json.get_varchar2 (p_path => 'nro_linhas' , p0 => 2, p_values => l_values);  
           --dbms_output.put_line('v_linhas : '||v_linhas);
           
           delete from valida_contribuinte_retorno
            where valcontrib_id = v_c_ret.valcontrib_id;
           
           -- varre retornos
           FOR i IN 1 .. v_linhas
             LOOP         
                v_reg_ret := null;
                v_reg_ret.cnpj          := apex_json.get_varchar2 ('retorno[%d].cnpj', p0 => i, p_values => l_values);
                v_reg_ret.cpf           := apex_json.get_varchar2 ('retorno[%d].cpf', p0 => i, p_values => l_values);
                v_reg_ret.ie            := apex_json.get_varchar2 ('retorno[%d].ie', p0 => i, p_values => l_values);
                v_reg_ret.habilitado    := apex_json.get_varchar2 ('retorno[%d].xhabilitado', p0 => i, p_values => l_values);
                v_request_id            := apex_json.get_varchar2 (p_path => 'retorno[%d].request_id' , p0 => i, p_values => l_values);
                v_reg_ret.msg_retorno   := apex_json.get_varchar2 (p_path => 'retorno[%d].ocorrencia' , p0 => i, p_values => l_values);
                v_reg_ret.ind_cred_nfe  := apex_json.get_varchar2 (p_path => 'retorno[%d].xind_cred_nfe' , p0 => i, p_values => l_values);
                v_reg_ret.ind_cred_cte  := apex_json.get_varchar2 (p_path => 'retorno[%d].xind_cred_cte' , p0 => i, p_values => l_values);
                v_reg_ret.razao_social  := apex_json.get_varchar2 (p_path => 'retorno[%d].razao_social' , p0 => i, p_values => l_values);
                v_reg_ret.fantasia      := apex_json.get_varchar2 (p_path => 'retorno[%d].fantasia' , p0 => i, p_values => l_values);
                v_reg_ret.cnae          := apex_json.get_varchar2 (p_path => 'retorno[%d].cnae' , p0 => i, p_values => l_values);
                v_reg_ret.dt_ini_ativ   := to_date(apex_json.get_varchar2 (p_path => 'retorno[%d].dt_ini_ativ' , p0 => i, p_values => l_values),'dd/mm/yyyy');
                v_reg_ret.dt_ult_sit    := to_date(apex_json.get_varchar2 (p_path => 'retorno[%d].dt_ult_sit' , p0 => i, p_values => l_values),'dd/mm/yyyy');
                v_reg_ret.dt_baixa      := to_date(apex_json.get_varchar2 (p_path => 'retorno[%d].dt_baixa' , p0 => i, p_values => l_values),'dd/mm/yyyy');
                v_reg_ret.ie_unica      := apex_json.get_varchar2 (p_path => 'retorno[%d].ie_unica' , p0 => i, p_values => l_values);
                v_reg_ret.ie_atual      := apex_json.get_varchar2 (p_path => 'retorno[%d].ie_atual' , p0 => i, p_values => l_values);
                v_reg_ret.logradouro    := apex_json.get_varchar2 (p_path => 'retorno[%d].logradouro' , p0 => i, p_values => l_values);
                v_reg_ret.nro           := apex_json.get_varchar2 (p_path => 'retorno[%d].nro' , p0 => i, p_values => l_values);
                v_reg_ret.compl         := apex_json.get_varchar2 (p_path => 'retorno[%d].compl' , p0 => i, p_values => l_values);
                v_reg_ret.bairro        := apex_json.get_varchar2 (p_path => 'retorno[%d].bairro' , p0 => i, p_values => l_values);
                v_reg_ret.cidade_ibge   := apex_json.get_varchar2 (p_path => 'retorno[%d].cidade_ibge' , p0 => i, p_values => l_values);
                v_reg_ret.municipio     := apex_json.get_varchar2 (p_path => 'retorno[%d].municipio' , p0 => i, p_values => l_values);
                v_reg_ret.cep           := apex_json.get_varchar2 (p_path => 'retorno[%d].cep' , p0 => i, p_values => l_values);
                v_reg_ret.chabilitado   := apex_json.get_varchar2 (p_path => 'retorno[%d].chabilitado' , p0 => i, p_values => l_values);
                v_reg_ret.cind_cred_nfe := apex_json.get_varchar2 (p_path => 'retorno[%d].cind_cred_nfe' , p0 => i, p_values => l_values);
                v_reg_ret.cind_cred_cte := apex_json.get_varchar2 (p_path => 'retorno[%d].cind_cred_cte' , p0 => i, p_values => l_values);
                v_reg_ret.dt_hr         := sysdate;
                v_reg_ret.valcontrib_id := v_c_ret.valcontrib_id;

                insert into valida_contribuinte_retorno values v_reg_ret;

                -- registra requisicao e situacao processado
                update valida_contribuinte
                   set request_id     = v_request_id
                     , sit            = 3 -- processado
                     , msg_integracao = v_reg_ret.msg_retorno
                 where valcontrib_id  = v_c_ret.valcontrib_id;

             END LOOP;

             v_qt_integrado := v_qt_integrado+1;
       else

             dbms_output.put_line('valida_contribuinte retorno de erro request_id = '||v_request_id||', valcontrib_id = '||v_c_ret.valcontrib_id||', Info : '||v_info||' Erro : '||v_erro||' Msg '||v_reg_ret.msg_retorno);
             
             -- registra requisicao e situacao processado
             update valida_contribuinte
                set sit            = 2 -- processado com erro
                  , msg_integracao = 'Info : '||v_info||' Erro : '||v_erro||' Msg '||v_reg_ret.msg_retorno
              where valcontrib_id  = v_c_ret.valcontrib_id;

       end if;
        
       v_qt_tenta_env := v_qt_tenta_env+1;
       
    end loop;
    
    DBMS_OUTPUT.PUT_LINE('Fim pb_retorno_sintegra');
    
  exception
       when others then
         raise_application_error(-20000, 'Erro pb_retorno_sintegra erro = '||sqlerrm||', s_json = '||s_json);
         --Dbms_Output.put_line ( DBMS_UTILITY.FORMAT_ERROR_STACK() );
         --Dbms_Output.put_line ( DBMS_UTILITY.FORMAT_ERROR_BACKTRACE() );
  end;



begin
  -- Initialization
  null;
  
end PK_VALIDA_CONTRIBUINTE;
/
