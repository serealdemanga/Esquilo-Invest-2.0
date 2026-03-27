# Etapa 5 - Migracao dos dados validos

## Objetivo

Popular a nova planilha operacional com os dados confiaveis da planilha antiga, ignorando linhas decorativas, totais e instrucoes textuais.

## O que foi migrado

Planilha de origem:
- `Esquilo_Invest_v3.xlsx`

Planilha de destino:
- `Esquilo_Invest_Operacional.xlsx`

Migrado com sucesso:
- `Acoes`: 5 linhas operacionais
- `PreOrdens`: 3 linhas operacionais
- `Fundos`: 6 linhas operacionais
- `Previdencia`: 4 linhas operacionais
- `Aportes`: 12 linhas operacionais

## O que foi adaptado

Para preservar os dados validos com mais fidelidade, alguns cabecalhos da planilha nova foram refinados durante a migracao.

Ajustes principais:
- `Acoes` passou a refletir a estrutura operacional real da aba legada
- `PreOrdens` voltou a incluir `Lote` e `Cotacao Atual`
- `Aportes` foi alinhada ao formato real usado na planilha antiga

## O que nao foi migrado

Linhas descartadas por seguranca:

- `Acoes`
  - total da aba
  - alerta textual sobre `CMIN3`
  - instrucao operacional sobre pre-ordens executadas

- `PreOrdens`
  - linha de total potencial
  - alerta textual de concentracao setorial

- `Fundos`
  - linha de total
  - linhas `Adicionar novo fundo`

- `Previdencia`
  - linha de total
  - linhas `Adicionar novo plano`

- `Aportes`
  - linha `TOTAL 12 MESES`

Abas sem fonte de migracao real nesta etapa:
- `Config`
- `Dashboard_Visual`
- `Export_Auxiliar`

## Validacao

Foi validado que a nova planilha:
- manteve as abas finais definidas
- recebeu os dados operacionais relevantes
- continua em formato `.xlsx` valido
- nao depende da planilha antiga para existir
