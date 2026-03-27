# Standalone Stage 2 - Config Centralization

## Objetivo

Transformar o `Config.gs` na fonte unica das configuracoes da planilha operacional para o modo Apps Script standalone.

## O que foi alterado

- adicionado `APP_CONFIG_.spreadsheetId`
- adicionado `APP_CONFIG_.spreadsheetUrl`
- mantidos os nomes das abas operacionais em `APP_CONFIG_.sheetNames`
- adicionados helpers:
  - `getOperationalSpreadsheetId_()`
  - `getOperationalSpreadsheetUrl_()`

## Spreadsheet oficial centralizado

- ID: `119enzesF7j5g7Cd1uBgjiu-YSlTKHpubfc_ZSv1M3Lk`
- URL: `https://docs.google.com/spreadsheets/d/119enzesF7j5g7Cd1uBgjiu-YSlTKHpubfc_ZSv1M3Lk/edit`

## Observacoes

Nesta etapa, o runtime ainda nao foi trocado para `openById`.
A etapa ficou restrita a centralizacao da configuracao, preparando a adaptacao do backend.
