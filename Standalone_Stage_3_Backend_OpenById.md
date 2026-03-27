# Standalone Stage 3 - Backend OpenById

## Objetivo

Adaptar o nucleo do dashboard para abrir a planilha operacional explicitamente por ID, no modo Apps Script standalone.

## O que foi alterado

- `Config.gs`
  - helper `openOperationalSpreadsheet_()` adicionado
- `Backend_Core.gs`
  - `getSpreadsheetContext_()` agora usa `openOperationalSpreadsheet_()`
  - `buildDashboardInsights_()` passou a carregar o historico com a planilha aberta por ID
- `Decision_Engine.gs`
  - `buildDecisionHistory_()` agora recebe a planilha explicitamente

## Resultado da etapa

O fluxo principal do dashboard agora abre a planilha via:
- `SpreadsheetApp.openById(APP_CONFIG_.spreadsheetId)`

## Dependencias que ainda restam fora do nucleo

- `AI_Service.gs`
  - `getInventoryLoot()`
- `Sheet_Readers.gs`
  - `readGoogleFinanceMarketBatch_(tickers, spreadsheet)` ainda aceita fallback implicito

## Observacoes

Esses pontos restantes nao bloqueiam o fluxo principal do dashboard, mas ainda serao revisados nas proximas etapas.
