# Mockoon portátil — BAIXOU

## Importação

1. Abra o Mockoon Portable.
2. Selecione **File > Open local environment** (ou arraste o arquivo).
3. Escolha `baixou-api.json` desta pasta.
4. Inicie o ambiente **BAIXOU - API portátil**.
5. Confirme `GET http://localhost:3001/api/health`.

O ambiente escuta em `0.0.0.0:3001`, possui CORS ativo e pode ser acessado pelo
computador, emulador ou celular conectado por ADB.

## Credenciais e cenários

- Login normal: qualquer e-mail válido, exceto os cenários abaixo; senha com 8+ caracteres.
- `erro@baixou.app`: login retorna `422`.
- `inativo@baixou.app`: login retorna `403`.
- `existente@baixou.app`: cadastro retorna `422`.
- Código `0000`: ativação/recuperação retorna `422`.
- Código `1234`: único código válido para ativação e recuperação.
- Qualquer outro código de quatro dígitos retorna `422`.
- Token retornado: `mock-token-baixou`.

Nas rotas que oferecem cenários adicionais, envie o header:

```text
X-Mock-Scenario: empty
X-Mock-Scenario: pending
X-Mock-Scenario: server-error
```

Rotas protegidas retornam `401` quando o header `Authorization` não é enviado.
O App adiciona automaticamente `Authorization: Bearer mock-token-baixou` após o login.

## Celular Android via USB

O script `../scripts/run-android-mockoon.ps1` configura o redirecionamento USB e
executa o App apontando para o Mockoon. Isso evita depender do IP ou do Wi-Fi.

```powershell
cd C:\workspace\semestre6\app\baixou
.\scripts\run-android-mockoon.ps1
```

Mantenha o Mockoon iniciado antes de executar o script.

## Validar primeiro acesso e recuperação

Depois de reiniciar o ambiente no Mockoon, execute:

```powershell
cd C:\workspace\semestre6\app\baixou
.\scripts\test-auth-scenarios.ps1
```

O script confirma que `1234` funciona e que outro código, como `4321`, retorna
`422` tanto na ativação quanto na recuperação de senha.
