# Stage 6 - File Reorganization

## Objetivo

Copiar o runtime atual para a nova base operacional sem tocar no projeto antigo, reorganizando o backend em poucos arquivos `.gs` pensados para Google Apps Script classico.

## O que foi copiado

- `Dashboard.html` recebeu a interface principal atual como base.
- Funcoes do backend atual foram redistribuidas para:
  - `Backend_Core.gs`
  - `Sheet_Readers.gs`
  - `Portfolio_Metrics.gs`
  - `Decision_Engine.gs`
  - `AI_Service.gs`

## O que foi adaptado

- `Config.gs` concentrou configuracoes, chaves de Script Properties e helpers compartilhados.
- `Dashboard.html` foi limpo de referencia local a manifesto e atualizado para a release `Mapa de Cobre 1.0.3`.
- `Export_Import.gs` recebeu stubs simples e claros para o Apps Script.

## O que ficou para a Etapa 7

- adaptar leitores ao layout da nova planilha operacional
- alinhar offsets e mapeamentos herdados da base antiga
- validar o backend novo contra `Esquilo_Invest_Operacional.xlsx`

## Observacoes

A base antiga permaneceu intacta.
A nova base ja ficou com estrutura simples, poucos arquivos e sem dependencias de build.
