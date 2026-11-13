# BAIXOU — aplicativo Flutter

Cliente responsivo do rastreador de preços BAIXOU. Consome a API Laravel para autenticação, catálogo, monitoramento, histórico, alertas e notificações.

## Requisitos

- Flutter compatível com Dart `^3.11.4`.
- Core em `http://localhost:8000/api` ou URL informada por `API_BASE_URL`.
- No Windows, habilite o **Modo de Desenvolvedor** para builds nativos que criam symlinks de plugins.

## Configuração

```powershell
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

Para Android Emulator, use `http://10.0.2.2:8000/api`. Para aparelho USB, `scripts/run-android-mockoon.ps1` configura `adb reverse` para o ambiente simulado.

## Verificação automatizada

```powershell
./scripts/check.ps1
```

Estado revalidado em 13/11/2026:

- análise estática sem problemas;
- 8 testes aprovados, incluindo nome e preço nos estados pendente, concluído e com falha;
- produto contém `listings`, e `bestListing` seleciona o menor preço;
- dependências diretas atualizadas: `flutter_dotenv 6`, `fl_chart 1.3` e `google_fonts 8`.
- fluxo real aprovado em Samsung SM-M625F em 05/11/2026: login, catálogo, rastreamento, detalhes, notificações e perfil;
- evidências disponíveis em `../../imagem/celular-*.png` e no relatório `../../RELATORIO_VALIDACAO_BAIXOU.html`.

## Credencial local

```text
E-mail: root@localhost
Senha:  rootroot
```
