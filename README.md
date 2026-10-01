# Integração da API SINTEGRA em Python – Consulta de Inscrição Estadual em tempo real

Exemplo de integração em **Python** com a API SINTEGRA da **ArquivoNFe**, para consulta de dados cadastrais por UF.

A API permite realizar consultas utilizando **CNPJ, CPF ou Inscrição Estadual (IE)**, conforme a disponibilidade da consulta para cada UF.

## 🔎 Palavras-chave

* API SINTEGRA
* Consulta SINTEGRA
* SINTEGRA CCC
* Consulta Inscrição Estadual
* API Fiscal Brasil
* Consulta CNPJ
* Consulta CPF
* Consulta Inscrição Estadual por API

## Benefícios

✔ Consulta por CNPJ, CPF ou IE<br>
✔ Dados cadastrais retornados pela API<br>
✔ Integração simples via API REST<br>
✔ Processamento assíncrono utilizando `request_id`<br>
✔ Exemplo prático de integração em Python

## Casos de uso

✔ Validação cadastral antes da emissão de NF<br>
✔ Conferência cadastral automática<br>
✔ Verificação de informações de empresas e contribuintes<br>
✔ Integração com sistemas ERP e aplicações próprias<br>
✔ Processos de KYC (Know Your Customer)

## Diferenciais

✔ Consulta dos dados cadastrais disponibilizados pela SEFAZ da UF consultada.<br>
✔ Comunicação segura por HTTPS.<br>
✔ Infraestrutura hospedada na Oracle Cloud no Brasil.<br>
✔ Painel web para configurações, consultas manuais e acompanhamento das integrações via API.<br>
✔ API REST com suporte a consultas por CNPJ, CPF ou Inscrição Estadual.

---

## 🚀 Requisitos

* Windows ou Linux
* Python 3.x
* Git (opcional, caso escolha clonar o projeto)
* Biblioteca `requests`

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

> ⚠️ **Nunca publique seu token de acesso no GitHub.**

No arquivo `consulta_sintegra.py`, informe seu token apenas localmente:

```python
TOKEN = 'SEU_TOKEN_AQUI'
```

Antes de publicar o código no GitHub, certifique-se de que o token não esteja preenchido.

---

### 3️⃣ Instalação do Python

O exemplo utiliza **Python 3**.

#### Windows

Baixe o Python pelo site oficial:

https://www.python.org/downloads/windows/

Durante a instalação, marque a opção:

**Add python.exe to PATH**

Depois de concluir a instalação, abra o **Prompt de Comando (CMD)** e execute:

```bash
python --version
```

O comando deverá apresentar a versão instalada, por exemplo:

```text
Python 3.13.x
```

#### Linux

Verifique se o Python 3 está instalado:

```bash
python3 --version
```

Caso não esteja instalado, utilize o gerenciador de pacotes da sua distribuição.

Por exemplo, no Ubuntu/Debian:

```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv
```

Depois confirme:

```bash
python3 --version
```

---

### 4️⃣ Baixe o projeto

Você pode baixar o projeto diretamente pelo GitHub ou cloná-lo utilizando o Git.

#### Opção 1 — Baixar ZIP

No GitHub, clique em:

**Code → Download ZIP**

Depois, extraia o arquivo em uma pasta do seu computador.

#### Opção 2 — Clonar com Git

Se o Git estiver instalado, execute:

```bash
git clone https://github.com/mnogueira-tecnologia/api-sintegra-python.git
```

Depois acesse a pasta do projeto:

```bash
cd api-sintegra-python
```

---

### 5️⃣ Crie um ambiente virtual Python

É recomendado utilizar um ambiente virtual para manter as dependências do projeto isoladas.

#### Windows

Dentro da pasta do projeto, execute:

```bash
python -m venv .venv
```

Ative o ambiente virtual:

```bash
.venv\Scripts\activate
```

Após a ativação, o terminal deverá apresentar algo semelhante a:

```text
(.venv) C:\Users\seu_usuario\api-sintegra-python>
```

#### Linux

Crie o ambiente virtual:

```bash
python3 -m venv .venv
```

Ative o ambiente:

```bash
source .venv/bin/activate
```

---

### 6️⃣ Instale as dependências

Com o ambiente virtual ativado, instale a biblioteca `requests` e as demais dependências do projeto:

#### Windows

```bash
pip install -r requirements.txt
```

#### Linux

```bash
pip3 install -r requirements.txt
```

Você também pode verificar se a biblioteca `requests` foi instalada corretamente:

```bash
pip show requests
```

---

### 7️⃣ Configure seu Token

Abra o arquivo [`consulta_sintegra.py`](consulta_sintegra.py) e informe seu token de acesso:

```python
TOKEN = 'SEU_TOKEN_AQUI'
```

Por exemplo:

```python
TOKEN = '123456789abcdef'
```

> ⚠️ **O token acima é apenas um exemplo. Nunca utilize ou publique tokens reais no GitHub.**

Antes de executar o projeto, certifique-se de que o token esteja configurado corretamente.

---

### 8️⃣ Execute o exemplo

Com o ambiente virtual ativado e o token configurado, execute o script.

#### Windows

```bash
python consulta_sintegra.py
```

#### Linux

```bash
python3 consulta_sintegra.py
```

O script realizará as consultas configuradas no exemplo e exibirá os resultados retornados pela API no terminal.

O exemplo demonstra:

* envio de consultas por CNPJ, CPF ou Inscrição Estadual;
* armazenamento do `request_id` (protocolo da consulta);
* consulta dos resultados de forma assíncrona;
* novas tentativas quando a consulta ainda está em processamento;
* tratamento das respostas da API;
* exibição dos resultados em formato JSON.

O código-fonte completo está disponível em:

[`consulta_sintegra.py`](consulta_sintegra.py)

---

## 📄 Exemplo de retorno da API

O exemplo abaixo apresenta um retorno da API após a conclusão da consulta:

![Retorno JSON](teste_etapa1.png)
![Retorno JSON](teste_etapa2.png)
![Retorno JSON](teste_etapa3.png)

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
