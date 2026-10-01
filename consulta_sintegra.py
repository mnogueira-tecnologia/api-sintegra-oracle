import requests
import time
import json


# ============================================================
# CONFIGURAÇÃO
# ============================================================

TOKEN = 'Informe seu TOKEN aqui'

URL = "https://api.arquivo-nfe.com/prod/consulta_cadastro"

HEADERS = {
    "Authorization": f"Bearer {TOKEN}"
}


# ============================================================
# CONSULTAS
#
# Informe apenas UM dos identificadores:
#   cnpj, cpf ou ie
#
# O request_id será preenchido automaticamente após o envio da consulta.
# Informe os dados para consulta em lote conforme o exemplo abaixo
# O script pode ser adequado para recuperar os dados para consulta diretamente de seu banco dados
# ==================================================================================================

consultas = [
    {
        "uf": "SP",
        "cnpj": "XXXXXXXXXXXXXX",
        "cpf": None,
        "ie": None,
        "request_id": None
    },
    {
        "uf": "ES",
        "cnpj": None,
        "cpf": "XXX.XXX.XXX-XX",
        "ie": None,
        "request_id": None
    },
    {
        "uf": "GO",
        "cnpj": None,
        "cpf": None,
        "ie": "XXXXXXXXX",
        "request_id": None
    }
]


# ============================================================
# FUNÇÃO PARA MONTAR OS PARÂMETROS
# ============================================================

def criar_parametros(consulta):

    parametros = {
        "uf": consulta["uf"]
    }

    identificadores = [
        ("cnpj", consulta.get("cnpj")),
        ("cpf", consulta.get("cpf")),
        ("ie", consulta.get("ie"))
    ]

    informados = [
        nome
        for nome, valor in identificadores
        if valor is not None and valor != ""
    ]

    if len(informados) != 1:
        raise ValueError(
            "Informe exatamente um dos parâmetros: cnpj, cpf ou ie."
        )

    nome = informados[0]

    parametros[nome] = consulta[nome]

    return parametros


# ============================================================
# ETAPA 1
# ENVIA O LOTE DE CONSULTAS
# ============================================================

print()
print("=" * 70)
print("ETAPA 1 - ENVIANDO CONSULTAS")
print("=" * 70)


for numero, consulta in enumerate(consultas, start=1):

    try:

        parametros = criar_parametros(consulta)

        print()
        print(f"Consulta {numero}")
        print(f"UF: {consulta['uf']}")
        print(f"Parâmetros: {parametros}")

        resposta = requests.post(
            URL,
            headers=HEADERS,
            params=parametros,
            timeout=60
        )

        print("URL enviada:")
        print(resposta.url)

        print(f"HTTP Status: {resposta.status_code}")

        # ----------------------------------------------------
        # CONVERTE A RESPOSTA PARA JSON
        # ----------------------------------------------------

        try:

            dados = resposta.json()

        except ValueError:

            print("A API não retornou um JSON válido.")
            print("Resposta bruta recebida:")

            print(resposta.text)

            continue

        #print(
        #    f"Resposta: "
        #    f"{json.dumps(dados, ensure_ascii=False)}"
        #)

        # ----------------------------------------------------
        # ERRO
        # ----------------------------------------------------

        if "erro" in dados:

            print(f"ERRO: {dados['erro']}")

            # Caso a API retorne request_id junto com o erro,
            # também armazenamos.

            if dados.get("request_id") is not None:

                consulta["request_id"] = dados["request_id"]

                print(
                    f"Request ID recebido: "
                    f"{consulta['request_id']}"
                )

            continue

        # ----------------------------------------------------
        # REQUEST_ID
        #
        # O request_id pode vir:
        #
        # 1. Diretamente na resposta:
        #    {"request_id": 26989}
        #
        # 2. Dentro de retorno:
        #    {"retorno": [{"request_id": 26988}]}
        # ----------------------------------------------------

        request_id = dados.get("request_id")

        if request_id is None:

            retorno = dados.get("retorno")

            if isinstance(retorno, list) and len(retorno) > 0:

                request_id = retorno[0].get("request_id")

        if request_id is not None:

            consulta["request_id"] = request_id

            print(
                f"Request ID recebido: {request_id}"
            )

        else:

            print(
                "A API não retornou request_id para esta consulta."
            )

    except requests.RequestException as erro:

        print(
            f"Erro de comunicação com a API: {erro}"
        )

    except ValueError as erro:

        print(
            f"Erro nos parâmetros: {erro}"
        )


# ============================================================
# ETAPA 2
# CONSULTA OS REQUEST_ID
# ============================================================

print()
print("=" * 70)
print("ETAPA 2 - CONSULTANDO OS RESULTADOS")
print("=" * 70)


# Número máximo de tentativas para cada consulta
MAX_TENTATIVAS = 5

# Tempo de espera entre as tentativas
INTERVALO = 5


for numero, consulta in enumerate(consultas, start=1):

    request_id = consulta.get("request_id")

    if request_id is None:

        print()
        print(
            f"Consulta {numero}: sem request_id. Ignorada."
        )

        continue

    print()
    print(
        f"Consulta {numero} - Request ID: {request_id}"
    )

    resultado_obtido = False

    for tentativa in range(1, MAX_TENTATIVAS + 1):

        try:

            parametros = {
                "uf": consulta["uf"],
                "request_id": request_id
            }

            resposta = requests.post(
                URL,
                headers=HEADERS,
                params=parametros,
                timeout=60
            )

            print()
            print(
                f"Tentativa {tentativa}/{MAX_TENTATIVAS}"
            )

            # ------------------------------------------------
            # CONVERTE A RESPOSTA PARA JSON
            # ------------------------------------------------

            try:

                dados = resposta.json()

            except ValueError:

                print(
                    "A API retornou uma resposta que não é "
                    "um JSON válido."
                )

                print("Resposta bruta recebida:")
                print(resposta.text)

                break

            info = dados.get("info", "")

            # ------------------------------------------------
            # ERRO
            # ------------------------------------------------

            if "erro" in dados:

                print(
                    f"ERRO: {dados['erro']}"
                )

                resultado_obtido = True

                break

            # ------------------------------------------------
            # AGUARDANDO RETORNO
            # ------------------------------------------------

            if (
                "Aguardando retorno" in info
                or
                "status PENDENTE" in info
            ):

                if tentativa < MAX_TENTATIVAS:

                    print(
                        "Consulta ainda em processamento."
                    )

                    print(
                        f"Nova tentativa em "
                        f"{INTERVALO} segundos."
                    )

                    time.sleep(INTERVALO)

                    continue

                else:

                    print(
                        "Não foi possível obter o retorno "
                        "da SEFAZ dentro do limite de tentativas."
                    )

                    break

            # ------------------------------------------------
            # SUCESSO
            # ------------------------------------------------

            if dados.get("info") == "sucesso":

                print()
                print(
                    "CONSULTA CONCLUÍDA COM SUCESSO"
                )

                print(
                    json.dumps(
                        dados,
                        indent=4,
                        ensure_ascii=False
                    )
                )

                resultado_obtido = True

                break

            # ------------------------------------------------
            # RESPOSTA NÃO PREVISTA
            # ------------------------------------------------

            print(
                "Resposta recebida da API:"
            )

            print(
                json.dumps(
                    dados,
                    indent=4,
                    ensure_ascii=False
                )
            )

            resultado_obtido = True

            break

        except requests.RequestException as erro:

            print(
                f"Erro de comunicação com a API: {erro}"
            )

            break

        except Exception as erro:

            print(
                f"Erro inesperado: {erro}"
            )

            break
