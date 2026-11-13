# Cenários de teste e integração com o Core

Escopo: App Flutter e Scrapping. O Core aparece apenas como dependência.

## Fluxo

```text
[APP no celular] <-- HTTP --> [Mockoon local]
       |
       +------ HTTP ------> [CORE] <-- RabbitMQ --> [SCRAPPING]
                               |
                               +---- SMTP/e-mail --> [USUÁRIO]
```

## Preparação

```text
[Abrir mockoon-portable/baixou-api.json]
                    |
[Iniciar porta 3000 e reiniciar após editar o JSON]
                    |
[adb devices]
                    |
[scripts/check-mockoon.ps1]
                    |
[scripts/test-auth-scenarios.ps1]
                    |
[scripts/run-android-mockoon.ps1]
```

## Autenticação

```text
+------------------------+--------+-------------------------------+
| Operação               | Código | Resultado                     |
+------------------------+--------+-------------------------------+
| Ativar primeiro acesso | 1234   | HTTP 200                      |
| Ativar primeiro acesso | outro  | HTTP 422                      |
| Validar recuperação    | 1234   | HTTP 200 + reset_token        |
| Validar recuperação    | outro  | HTTP 422                      |
+------------------------+--------+-------------------------------+
```

```text
CT-AUTH-01 PRIMEIRO ACESSO
[conta pendente] -> [digitar 1234] -> POST /auth/activate
                                      |
                                      +-> 200 -> [entrar no App]

CT-AUTH-02 CÓDIGO INVÁLIDO
[digitar 4321] -> POST /auth/activate -> 422 -> [erro + nova tentativa]

CT-AUTH-03 RECUPERAÇÃO
[e-mail] -> POST /auth/forgot-password
    -> [1234] -> POST /auth/verify-reset-code
    -> [reset_token + senha >= 8] -> POST /auth/reset-password
    -> [login com nova senha]

CT-AUTH-04 RECUPERAÇÃO INVÁLIDA
[4321] -> POST /auth/verify-reset-code -> 422 -> [manter etapa]
```

Casos adicionais: menos de quatro dígitos não chama a API; senha menor que oito
caracteres ou confirmação divergente não redefine; pedido para e-mail inexistente
usa resposta neutra; `401` limpa a sessão; timeout mostra erro recuperável.

## Scrapping

```text
[mensagem]
    -> [validar request_id/loja/URL Amazon]
    -> [extrair título e preço]
    -> [normalizar R$ 1.234,56 ou US$ 1,234.56]
    -> [publicar resultado correlacionado]

URL inválida -------> erro controlado
Preço ausente ------> parse_error (nunca zero silencioso)
Falha transitória --> retry -> DLQ
Mensagem inválida --> rejeitar sem derrubar consumidor
```

Execute `.\scripts\check.ps1` no repositório do Scrapping.

## Necessário no Core

```text
POST /auth/login                 GET  /auth/me
POST /auth/register              POST /auth/logout
POST /auth/activate              POST /auth/forgot-password
POST /auth/verify-reset-code     POST /auth/reset-password
```

- enviar os códigos por e-mail;
- expiração, uso único e limite de tentativas;
- senha mínima de oito caracteres;
- `reset_token` de uso único;
- resposta neutra e erros `401/404/409/422/429` padronizados;
- revogar sessões após reset;
- reenvio com rate limit;
- e-mail enfileirado somente após commit.

```text
[PROTÓTIPO]                 [PRODUÇÃO]
pseudoaleatório ----------> gerador criptograficamente seguro
código/token em texto ----> hash + comparação segura
3 tentativas/10 minutos --> manter + rate limit por IP/e-mail
fila de e-mail -----------> after-commit + observabilidade
```

Contrato Core/Scrapping:

```text
REQUISIÇÃO: request_id, product_id, store, url, requested_at
SUCESSO:    request_id, product_id, store, source_url,
            title, price, currency, collected_at
FALHA:      request_id, product_id, error_code, error_message,
            retryable, failed_at
```

O Core ainda deve definir exchange, filas, routing keys, DLQ, confirmação do
publisher, idempotência e retry. Para o App, deve fechar também os contratos de
produtos, histórico, alertas e notificações com schemas e paginação estáveis.

## Critério de pronto

```text
[ ] autenticação passa no Mockoon
[ ] App passa em analyze/test e no celular físico
[ ] Scrapping passa em todos os testes
[ ] contratos HTTP/RabbitMQ estão versionados
[ ] e-mail real é validado em homologação (Mailpit no ambiente local)
[ ] expiração, reenvio, tentativas e rate limit validados
[ ] reset revoga sessões
[ ] coleta duplicada é idempotente
[ ] falhas chegam à DLQ com request_id
```
