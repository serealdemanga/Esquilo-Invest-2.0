# Standalone Stage 1 - Spreadsheet Dependency Audit

## Objetivo

Mapear todos os pontos da nova base operacional que ainda assumem que o Apps Script esta vinculado diretamente a uma planilha ativa.

## Ocorrencias encontradas

Dependencias diretas de `SpreadsheetApp.getActiveSpreadsheet()`:

1. `Backend_Core.gs`
   - `getSpreadsheetContext_()`
   - impacto: alto
   - motivo: e o ponto central de abertura da planilha do dashboard

2. `AI_Service.gs`
   - `getInventoryLoot()`
   - impacto: medio
   - motivo: varre todas as abas da planilha para montar contexto textual auxiliar

3. `Decision_Engine.gs`
   - `buildDecisionHistory_()`
   - impacto: alto
   - motivo: grava e le historico de decisoes em aba interna

4. `Sheet_Readers.gs`
   - `readGoogleFinanceMarketBatch_(tickers, spreadsheet)`
   - impacto: medio
   - motivo: ainda aceita fallback implicito para planilha ativa ao criar/usar a aba tecnica de cache

## O que nao foi encontrado

- nenhum uso de `SpreadsheetApp.getActiveSheet()`
- nenhuma dependencia explicita de aba ativa
- nenhum uso atual de `SpreadsheetApp.openById()`

## Arquivos que precisam de ajuste

- `Config.gs`
- `Backend_Core.gs`
- `AI_Service.gs`
- `Decision_Engine.gs`
- `Sheet_Readers.gs`

## Funcoes previstas para alteracao

- `getSpreadsheetContext_()`
- `getInventoryLoot()`
- `buildDecisionHistory_()`
- `readGoogleFinanceMarketBatch_(tickers, spreadsheet)`

## Observacoes

O restante do backend novo ja trabalha majoritariamente com planilha e abas recebidas por contexto.
Isso reduz o escopo da adaptacao standalone para poucos pontos centrais.
