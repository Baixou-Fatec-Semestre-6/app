# BAIXOU — Flutter App

Aplicativo Flutter do rastreador de preços BAIXOU. A autenticação, produtos, histórico, alertas e notificações são acessados por HTTP através de repositórios. Durante o desenvolvimento, a API pode ser executada localmente com o ambiente Mockoon versionado em `baixou/mockoon/baixou-api.json`.

## Execução com a API mock

1. Abra `baixou/mockoon/baixou-api.json` no Mockoon e inicie a porta `3001`.
2. Configure `baixou/.env`:

```ini
API_BASE_URL=http://10.0.2.2:3001/api
ENABLE_MOCK_DATA=false
```

Use `localhost` em Flutter Desktop/Web e `10.0.2.2` no Android Emulator.

3. Execute:

```bash
cd baixou
flutter pub get
flutter run
```

Consulte [DOCUMENTACAO_TECNICA.md](baixou/docs/DOCUMENTACAO_TECNICA.md) para arquitetura, contratos e cenários.
