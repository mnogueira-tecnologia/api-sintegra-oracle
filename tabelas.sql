
CREATE SEQUENCE VALCONTRIB_SEQ
minvalue 1
start with 1
increment by 1
nocache;

-- script tabela de integração
CREATE TABLE "VALIDA_CONTRIBUINTE"
("VALCONTRIB_ID"  NUMBER DEFAULT ON NULL VALCONTRIB_SEQ.NEXTVAL not null,
 "COD_CONTRIBUINTE" VARCHAR2(20),
 "CNPJ"             VARCHAR2(20),
 "CPF"              VARCHAR2(11),
 "IE"               VARCHAR2(14),
 "UF"               VARCHAR2(2) NOT NULL,
 "DT_INCL"          DATE DEFAULT SYSDATE NOT NULL,
 "SIT"              NUMBER(1,0) DEFAULT 1 NOT NULL,
 "MSG_INTEGRACAO"   VARCHAR2(4000),
 "REQUEST_ID"       NUMBER,
 CONSTRAINT "VALCONTRIB_PK" PRIMARY KEY ("VALCONTRIB_ID") USING INDEX  ENABLE );

-- Add comments to the table
comment on table VALIDA_CONTRIBUINTE is 'Registra cnpj, cpf ou inscrição estadual para consulta';
comment on column VALIDA_CONTRIBUINTE.VALCONTRIB_ID is 'Identificador único';
comment on column VALIDA_CONTRIBUINTE.COD_CONTRIBUINTE is 'Identificador do contribuinte no sistema para consulta';
comment on column VALIDA_CONTRIBUINTE.CNPJ is 'CNPJ do contribuinte para consulta';
comment on column VALIDA_CONTRIBUINTE.CPF is 'CPF do contribuinte para consulta';
comment on column VALIDA_CONTRIBUINTE.IE is 'Inscrição estadual do contribuinte para consulta';
comment on column VALIDA_CONTRIBUINTE.UF is 'Unidade federativa para consulta';
comment on column VALIDA_CONTRIBUINTE.DT_INCL is 'Data de inclusão do registro';
comment on column VALIDA_CONTRIBUINTE.SIT is 'Situação do registro : 1 - PENDENTE; 2 - PROCESSADO COM ERRO; 3 - PROCESSADO';
comment on column VALIDA_CONTRIBUINTE.MSG_INTEGRACAO  is 'Mensagem / ocorrência de retorno da consulta';
comment on column VALIDA_CONTRIBUINTE.REQUEST_ID is 'Nro. da requisição gerada para consulta das informações de retorno';

-- check constraint
alter table VALIDA_CONTRIBUINTE add constraint valcontrib_cnpj_cpf_ie_ck check (
       (case when cnpj is not null then 1 else 0 end) +
       (case when cpf  is not null then 1 else 0 end) +
       (case when ie   is not null then 1 else 0 end) = 1
);

-- check constraint
alter table VALIDA_CONTRIBUINTE add constraint valcontrib_sit_ck check (SIT in (1,2,3));

-- inserts p/ testes
insert into valida_contribuinte (cod_contribuinte, cnpj, cpf, ie, uf) values (1, '00.000.000/0001-91', null, null, 'DF');
insert into valida_contribuinte (cod_contribuinte, cnpj, cpf, ie, uf) values (2, '33.000.167/0023-17', null, null, 'MG');
--insert into valida_contribuinte (cod_contribuinte, cnpj, cpf, ie, uf) values (3, null, null, null, null);

commit;

CREATE SEQUENCE VALCONTRIBR_SEQ
minvalue 1
start with 1
increment by 1
nocache;

-- script tabela de integração
CREATE TABLE "VALIDA_CONTRIBUINTE_RETORNO"
("VALCONTRIBR_ID"   NUMBER DEFAULT ON NULL VALCONTRIBR_SEQ.NEXTVAL not null,
 "VALCONTRIB_ID"    NUMBER NOT NULL,
 "CNPJ"             VARCHAR2(20),
 "CPF"              VARCHAR2(11),
 "IE"               VARCHAR2(14),
 "DT_HR"            DATE DEFAULT SYSDATE NOT NULL,
 "HABILITADO"       VARCHAR2(6) NOT NULL,
 "MSG_RETORNO"      VARCHAR2(4000),
 IND_CRED_NFE       VARCHAR2(200),
 IND_CRED_CTE       VARCHAR2(200),
 RAZAO_SOCIAL       VARCHAR2(100),
 FANTASIA           VARCHAR2(100),
 CNAE               VARCHAR2(7),
 REG_APUR           VARCHAR2(100),
 DT_INI_ATIV        DATE,
 DT_ULT_SIT         DATE,
 DT_BAIXA           DATE,
 IE_UNICA           VARCHAR2(14),
 IE_ATUAL           VARCHAR2(14),
 LOGRADOURO         VARCHAR2(255),
 NRO                VARCHAR2(60),
 COMPL              VARCHAR2(255),
 BAIRRO             VARCHAR2(60),
 CIDADE_IBGE        NUMBER(10),
 MUNICIPIO          VARCHAR2(60),
 CEP                NUMBER(8),
 CHABILITADO        NUMBER(1),
 CIND_CRED_NFE      NUMBER(10),
 CIND_CRED_CTE      NUMBER(10),
 CONSTRAINT "VALCONTRIBR_PK" PRIMARY KEY ("VALCONTRIBR_ID") USING INDEX  ENABLE );
 
alter table VALIDA_CONTRIBUINTE_RETORNO add constraint VALCONTRIBR_VALCONTRIB_FK foreign key (VALCONTRIB_ID)
references VALIDA_CONTRIBUINTE (VALCONTRIB_ID);

create index VALCONTRIBR_VALCONTRIB_FK_I on VALIDA_CONTRIBUINTE_RETORNO (VALCONTRIB_ID);

-- Add comments to the table
comment on table VALIDA_CONTRIBUINTE_RETORNO is 'Registra retorno da integração da consulta contribuinte';
comment on column VALIDA_CONTRIBUINTE_RETORNO.VALCONTRIBR_ID is 'Identificador único';
comment on column VALIDA_CONTRIBUINTE_RETORNO.CNPJ is 'CNPJ do contribuinte';
comment on column VALIDA_CONTRIBUINTE_RETORNO.CPF is 'CPF do contribuinte';
comment on column VALIDA_CONTRIBUINTE_RETORNO.IE is 'Inscrição estadual do contribuinte';
comment on column VALIDA_CONTRIBUINTE_RETORNO.DT_HR is 'Data / hora retorno de integração';
comment on column VALIDA_CONTRIBUINTE_RETORNO.HABILITADO is 'NÃO OU SIM';
comment on column VALIDA_CONTRIBUINTE_RETORNO.MSG_RETORNO  is 'Mensagem / ocorrência de retorno da consulta';
comment on column VALIDA_CONTRIBUINTE_RETORNO.IND_CRED_NFE is 'Indicador de contribuinte credenciado a emitir NFe';
comment on column VALIDA_CONTRIBUINTE_RETORNO.IND_CRED_CTE is 'Indicador de contribuinte credenciado a emitir CTe';
comment on column VALIDA_CONTRIBUINTE_RETORNO.CNAE is 'CNAE principal do contribuinte';
comment on column VALIDA_CONTRIBUINTE_RETORNO.REG_APUR is 'Regime de Apuração do ICMS do Contribuinte';
comment on column VALIDA_CONTRIBUINTE_RETORNO.DT_INI_ATIV is 'Data de Início da Atividade do Contribuinte';
comment on column VALIDA_CONTRIBUINTE_RETORNO.DT_ULT_SIT is 'Data da última modificação da situação cadastral do contribuinte';
comment on column VALIDA_CONTRIBUINTE_RETORNO.DT_BAIXA is 'Data de ocorrência da baixa do contribuinte';
comment on column VALIDA_CONTRIBUINTE_RETORNO.IE_UNICA is 'IE única, este campo será informado quando o contribuinte possuir IE única';
comment on column VALIDA_CONTRIBUINTE_RETORNO.IE_ATUAL is 'IE atual (em caso de IE antiga consultada)';


