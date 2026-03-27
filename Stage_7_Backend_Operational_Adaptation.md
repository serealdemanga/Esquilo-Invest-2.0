# Stage 7 - Backend Operational Adaptation

## Objetivo

Adaptar a nova base de codigo para consumir a nova planilha operacional sem depender do layout antigo da planilha de referencia.

## O que foi adaptado

- `Config.gs`
  - offsets de leitura ajustados para cabecalho em linha 1 e dados a partir da linha 2
- `Backend_Core.gs`
  - contexto de planilha ampliado para incluir abas operacionais e auxiliares da nova base
- `Sheet_Readers.gs`
  - leitura reescrita para formato tabular simples
  - mapeamento por cabecalho, sem dependencia de posicao antiga da planilha
  - filtros de linhas invalidadas mantidos de forma localizada

## Contrato operacional assumido

O backend novo passa a assumir:
- `Acoes`: cabecalho na linha 1
- `Fundos`: cabecalho na linha 1
- `Previdencia`: cabecalho na linha 1
- `PreOrdens`: cabecalho na linha 1
- `Aportes`: leitura preparada para uso futuro
- `Config`: leitura preparada para uso futuro

## O que foi preservado

- payload principal do dashboard
- contratos de `actions`, `investments`, `previdencias` e `preOrders`
- integracao da Esquilo.ai
- camada de Decision Engine

## Observacoes

A adaptacao ficou concentrada na camada de leitura para reduzir risco.
O projeto antigo permaneceu intacto.
