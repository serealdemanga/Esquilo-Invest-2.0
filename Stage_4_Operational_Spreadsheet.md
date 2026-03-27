# Etapa 4 - Nova planilha operacional

## Objetivo

Criar uma nova planilha base separada da antiga, ja pensada para a operacao do Esquilo Invest e para a futura subida manual ao Google Apps Script.

## O que foi criado

Arquivo:
- `Esquilo_Invest_Operacional.xlsx`

Abas criadas:
- `Acoes`
- `Fundos`
- `Previdencia`
- `PreOrdens`
- `Aportes`
- `Config`
- `Dashboard_Visual`
- `Export_Auxiliar`

## Estrutura inicial

Cada aba operacional ja nasceu com cabecalhos simples e diretos, para reduzir ambiguidade na migracao da etapa seguinte.

Exemplos:
- `Acoes`: ativo, nome, plataforma, status, quantidade, preco medio, cotacao, valor investido, valor atual, stop, rentabilidade e observacao
- `Fundos`: fundo, plataforma, categoria, status, inicio, valores, rentabilidade, risco e observacao
- `Config`: chave, valor e observacao

## Validacao

O arquivo foi gerado em formato `.xlsx` com estrutura Open XML valida.

Pacote validado:
- `[Content_Types].xml`
- `_rels/.rels`
- `xl/workbook.xml`
- `xl/_rels/workbook.xml.rels`
- `xl/worksheets/sheet1.xml` a `sheet8.xml`

## Observacao

Nenhum dado da planilha antiga foi migrado nesta etapa.
A etapa atual criou apenas a base estrutural da nova planilha operacional.
