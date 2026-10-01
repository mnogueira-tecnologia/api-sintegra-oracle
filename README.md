# Integração da API SINTEGRA com Oracle PL/SQL – Consulta de Inscrição Estadual em tempo real

Exemplo de integração da **API SINTEGRA da ArquivoNfe** utilizando Oracle PL/SQL e os recursos `APEX_WEB_SERVICE` e `APEX_JSON`.

O projeto demonstra como realizar consultas de dados cadastrais de contribuintes por UF, utilizando **CNPJ, CPF ou Inscrição Estadual (IE)**, conforme a disponibilidade da consulta para cada UF.

A integração utiliza processamento assíncrono por meio do `request_id`, permitindo enviar solicitações e consultar seus respectivos resultados posteriormente.

## 🔎 Palavras-chave

* API SINTEGRA Oracle
* Oracle PL/SQL
* Oracle APEX
* Consulta SINTEGRA
* SINTEGRA CCC
* Consulta Inscrição Estadual
* API Fiscal Brasil
* Integração Oracle com API REST
* Consulta CNPJ
* Consulta CPF

## Benefícios

✔ Consulta por CNPJ, CPF ou IE<br>
✔ Integração com Oracle PL/SQL<br>
✔ Comunicação com API REST via HTTPS<br>
✔ Processamento assíncrono utilizando `request_id`<br>
✔ Armazenamento dos resultados em tabelas Oracle<br>
✔ Exemplo prático de integração com Oracle APEX

## Casos de uso

✔ Validação cadastral antes da emissão de NF<br>
✔ Conferência cadastral automática<br>
✔ Verificação de informações de empresas e contribuintes<br>
✔ Integração com sistemas ERP e aplicações próprias<br>
✔ Automatização de processos fiscais

## Diferenciais

✔ Consulta dos dados cadastrais disponibilizados pela SEFAZ da UF consultada.<br>
✔ Comunicação segura por HTTPS.<br>
✔ Infraestrutura hospedada na Oracle Cloud no Brasil.<br>
✔ API REST com suporte a consultas por CNPJ, CPF ou Inscrição Estadual.<br>
✔ Exemplo de integração utilizando recursos nativos do Oracle APEX.

---

## 🚀 Requisitos

* Oracle Database com suporte a PL/SQL
* Oracle APEX, para utilização de `APEX_WEB_SERVICE` e `APEX_JSON`
* Acesso HTTPS ao endpoint da API
* Token de autenticação da ArquivoNfe

---

## 📁 Arquivos do projeto

| Arquivo                      | Descrição                                                        |
| ---------------------------- | ---------------------------------------------------------------- |
| `tabelas.sql`                | Criação das tabelas, sequences, constraints e registros de teste |
| `PK_VALIDA_CONTRIBUINTE.pck` | Package PL/SQL responsável pela integração com a API             |
| `sintegra.png`               | Imagem ilustrativa                                               |
| `teste_etapa1.png`           | Exemplo da primeira etapa da integração                          |
| `teste_etapa2.png`           | Exemplo da segunda etapa                                         |
| `teste_etapa3.png`           | Exemplo da terceira etapa                                        |

---

## ⚙️ Como utilizar

### 1️⃣ Cadastre-se gratuitamente

Acesse o portal:

https://portal.arquivo-nfe.com

Crie sua conta para obter acesso à API.

---

### 2️⃣ Copie seu Token

Após o login no portal:

1. Acesse o menu **Meu Token**.
2. Copie seu token de acesso.

> ⚠️ Nunca publique seu token de acesso no GitHub.

No package `PK_VALIDA_CONTRIBUINTE.pck`, localize a variável:

```sql
gv_token := 'SEU_TOKEN_AQUI';
```

Informe seu token apenas no ambiente local.

---

### 3️⃣ Crie as tabelas

Execute o script `tabelas.sql` no schema Oracle que será utilizado para a integração.

O script cria:

* Tabela `VALIDA_CONTRIBUINTE`: armazena as solicitações de consulta.
* Tabela `VALIDA_CONTRIBUINTE_RETORNO`: armazena os dados retornados pela API.
* Sequences para geração dos identificadores.
* Constraints e índice para relacionamento entre as tabelas.
* Registros de exemplo para teste.

---

### 4️⃣ Configure o package

Abra o arquivo `PK_VALIDA_CONTRIBUINTE.pck` e configure o token de acesso.

O package utiliza os recursos:

* `APEX_WEB_SERVICE`: envio das requisições HTTP.
* `APEX_JSON`: leitura e interpretação das respostas JSON.
* `DBMS_LOCK.SLEEP`: intervalo entre tentativas de consulta.

O schema precisa possuir os privilégios necessários para utilização desses recursos e acesso HTTPS ao endpoint da API.

---

### 5️⃣ Execute a integração

O package disponibiliza duas procedures:

**PB_ENVIA_SINTEGRA**

Responsável por enviar as consultas pendentes à API, utilizando CNPJ, CPF ou IE e armazenando o `request_id` retornado.

**PB_RETORNO_SINTEGRA**

Responsável por consultar os resultados das solicitações enviadas anteriormente e armazenar os dados cadastrais retornados.

A separação em duas etapas permite organizar o envio das solicitações e o processamento dos respectivos retornos.

---

### 6️⃣ Consulte os resultados

Os registros de integração são armazenados nas tabelas:

```sql
SELECT *
FROM VALIDA_CONTRIBUINTE;
```

```sql
SELECT *
FROM VALIDA_CONTRIBUINTE_RETORNO;
```

A situação da solicitação é controlada pelo campo `SIT`:

| SIT | Descrição           |
| --- | ------------------- |
| 1   | Pendente            |
| 2   | Processado com erro |
| 3   | Processado          |

---

## 🔄 Fluxo da integração

1. Inclusão dos contribuintes na tabela `VALIDA_CONTRIBUINTE`.
2. Envio das solicitações à API.
3. Recebimento e armazenamento do `request_id`.
4. Consulta dos resultados utilizando o protocolo.
5. Armazenamento dos dados cadastrais na tabela de retorno.

---

## 📄 Exemplos de execução

### Etapa 1 — Envio das consultas

![Envio das consultas](teste_etapa1.png)

### Etapa 2 — Consulta dos retornos

![Consulta dos retornos](teste_etapa2.png)

### Etapa 3 — Dados armazenados

![Dados armazenados](teste_etapa3.png)

---

## 🔗 Documentação da API

Consulte a documentação completa da API SINTEGRA:

https://www.arquivo-nfe.com/api-sintegra-ccc

---

## ⭐ Apoie o projeto

Se este projeto foi útil para você:

⭐ **Deixe uma estrela no repositório.**

Isso ajuda outras pessoas a encontrarem este exemplo de integração.

---

Made with ❤️ by **ArquivoNfe**

https://www.arquivo-nfe.com
