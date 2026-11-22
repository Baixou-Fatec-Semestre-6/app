# Mock da API BAIXOU

1. Instale o Mockoon Desktop em <https://mockoon.com/download/>.
2. Abra `baixou-api.json` pelo menu **File > Open environment**.
3. Inicie o ambiente na porta `3001`.
4. No Android Emulator, configure `API_BASE_URL=http://10.0.2.2:3001/api`.
5. Em Flutter Desktop/Web, use `API_BASE_URL=http://localhost:3001/api`.

O ambiente contém respostas alternativas em algumas rotas. No Mockoon, marque outra resposta como padrão para revisar estados de erro, lista vazia ou latência.

Também pode ser executado pela CLI:

```powershell
npx @mockoon/cli start --data .\mockoon\baixou-api.json
```
