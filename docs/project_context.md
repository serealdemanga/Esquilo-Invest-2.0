# Project Context

Este documento e a fonte principal de contexto atual do projeto.

## 1. Visao geral do sistema

O Esquilo Invest e um dashboard de carteira em Google Apps Script com interface HTML e planilha Google Sheets como fonte primaria de dados.

O sistema:
- le a planilha operacional por ID
- normaliza a base em memoria
- calcula metricas, score, perfil e decisao consolidada
- gera ranking e alertas por ativo
- oferece leitura adicional por IA
- sincroniza dados estruturados com BigQuery em fluxo separado

O sistema nao executa ordens em corretora. Toda recomendacao e apenas analitica.

## 2. Arquitetura

Camadas principais:
- `frontend/html/Dashboard.html`: interface unica com HTML, CSS e JavaScript inline
- `apps_script/backend/Backend_Core.gs`: entrada do web app e montagem do payload
- `apps_script/services/Sheet_Readers.gs`: leitura tabular e normalizacao da planilha
- `apps_script/services/Portfolio_Metrics.gs`: metricas consolidadas, score e mensagens
- `apps_script/services/Decision_Engine.gs`: score por ativo, ranking, plano e historico
- `apps_script/services/AI_Service.gs`: contexto da IA, prompt, validacao, fallback e providers
- `apps_script/integrations/BigQuery_Sync.gs`: push/pull entre planilha e BigQuery
- `apps_script/integrations/Api_Keys.gs`: leitura/escrita da chave Gemini em `Script Properties`
- `apps_script/utils/Config.gs`: configuracao global, helpers e contrato de runtime

## 3. Fluxo de dados

Fluxo principal do dashboard:
1. `doGet()` entrega `Dashboard.html`.
2. O frontend chama `google.script.run.getDashboardData()`.
3. `Backend_Core.gs` abre a planilha por `SpreadsheetApp.openById(...)`.
4. `Sheet_Readers.gs` le as abas operacionais e monta registros normalizados.
5. `Sheet_Readers.gs` tambem enriquece acoes com `GOOGLEFINANCE`, usando cache em aba interna e `CacheService`.
6. `Portfolio_Metrics.gs` consolida patrimonio, score, perfil, alertas e mensagens.
7. `Decision_Engine.gs` calcula score por ativo, ranking, plano de acao, historico e alertas inteligentes.
8. `Backend_Core.gs` devolve um payload unico para o frontend renderizar.
9. Sob demanda, o frontend chama `getPortfolioAIAnalysis()`.
10. `AI_Service.gs` reutiliza o mesmo contexto do dashboard, chama Gemini, usa OpenAI como fallback e valida o formato final.

Fluxo BigQuery:
1. `BigQuery_Sync.gs` usa a planilha ativa.
2. O sync valida cabecalhos por tabela.
3. Faz push em `WRITE_TRUNCATE` ou pull com `SELECT *`.

## 4. Estrutura de pastas atual

```text
.
|-- apps_script
|   |-- backend
|   |   |-- Backend_Core.gs
|   |   `-- Export_Import.gs
|   |-- integrations
|   |   |-- Api_Keys.gs
|   |   `-- BigQuery_Sync.gs
|   |-- services
|   |   |-- AI_Service.gs
|   |   |-- Decision_Engine.gs
|   |   |-- Portfolio_Metrics.gs
|   |   `-- Sheet_Readers.gs
|   `-- utils
|       `-- Config.gs
|-- data
|   |-- bigquery
|   |   `-- table_schemas.md
|   |-- mappings
|   |   `-- operational_sheet_headers.md
|   `-- spreadsheets
|       `-- Esquilo_Invest_Operacional.xlsx
|-- docs
|   |-- functional
|   |   `-- functional_overview_legacy.md
|   |-- release_notes
|   |   `-- release_notes.md
|   |-- sprints
|   |   `-- sprint_history.md
|   |-- technical
|   |   |-- operational_data_update_report.md
|   |   `-- technical_overview_legacy.md
|   `-- project_context.md
|-- frontend
|   `-- html
|       `-- Dashboard.html
|-- plans
|   |-- roadmap
|   |   `-- evolution_tracks.md
|   `-- sprints
|       `-- backlog.md
|-- README.md
`-- .gitattributes
```

## 5. Mapeamento dos principais arquivos

| Arquivo | Tipo | Funcao principal | Classificacao |
|---|---|---|---|
| `.gitattributes` | meta | normalizacao de atributos do repositorio | util |
| `README.md` | documentacao | ponto de entrada rapido do projeto | util |
| `apps_script/backend/Backend_Core.gs` | backend | entrega do web app e payload do dashboard | essencial |
| `apps_script/backend/Export_Import.gs` | backend | pontos de entrada futuros de import/export | util |
| `apps_script/integrations/Api_Keys.gs` | integracao | acesso a chave Gemini | essencial |
| `apps_script/integrations/BigQuery_Sync.gs` | integracao | sincronizacao planilha <-> BigQuery | util |
| `apps_script/services/AI_Service.gs` | servico | leitura por IA, providers e fallback | essencial |
| `apps_script/services/Decision_Engine.gs` | servico | score por ativo, ranking e plano | essencial |
| `apps_script/services/Portfolio_Metrics.gs` | servico | metricas, score geral, perfil e mensagens | essencial |
| `apps_script/services/Sheet_Readers.gs` | servico | leitura e normalizacao da planilha | essencial |
| `apps_script/utils/Config.gs` | utilitario | configuracao central e helpers compartilhados | essencial |
| `data/bigquery/table_schemas.md` | dados | contrato das tabelas do sync | util |
| `data/mappings/operational_sheet_headers.md` | dados | contrato dos cabecalhos da planilha | util |
| `data/spreadsheets/Esquilo_Invest_Operacional.xlsx` | dados | base operacional local e referencia estrutural | essencial |
| `docs/functional/functional_overview_legacy.md` | documentacao | contexto funcional legado preservado | util |
| `docs/release_notes/release_notes.md` | documentacao | historico incremental da base | util |
| `docs/sprints/sprint_history.md` | documentacao | historico consolidado das sprints | util |
| `docs/technical/operational_data_update_report.md` | documentacao | relatorio de migracao da planilha | util |
| `docs/technical/technical_overview_legacy.md` | documentacao | contexto tecnico legado preservado | util |
| `docs/project_context.md` | documentacao | fonte principal de contexto atual | essencial |
| `frontend/html/Dashboard.html` | frontend | layout, renderizacao e chamadas Apps Script | essencial |
| `plans/roadmap/evolution_tracks.md` | planejamento | trilhas macro de evolucao | util |
| `plans/sprints/backlog.md` | planejamento | backlog priorizado para proximas sprints | util |

## 6. Integracoes

### Planilha operacional
- fonte primaria: Google Sheets apontado por `APP_CONFIG_.spreadsheetId`
- planilha local de referencia: `data/spreadsheets/Esquilo_Invest_Operacional.xlsx`
- abas operacionais: `Acoes`, `Fundos`, `Previdencia`, `PreOrdens`, `Aportes`, `Config`
- abas auxiliares esperadas: `Dashboard_Visual`, `Export_Auxiliar`
- abas internas criadas em runtime: `_esquilo_market_cache`, `_esquilo_decision_history`

### BigQuery
- projeto: `esquilo-invest`
- dataset: `esquilo_invest`
- uso atual: push/pull tabular por cabecalho exato
- risco estrutural: o sync ainda assume planilha ativa, nao o fluxo standalone usado pelo dashboard

### IA
- provider principal: Gemini `gemini-2.5-flash`
- fallback: OpenAI `gpt-4o-mini` ou valor em `OPENAI_MODEL`
- chaves esperadas:
  - `GEMINI_API_KEY`
  - `OPENAI_API_KEY`
  - `OPENAI_MODEL`
  - `EXTERNAL_MARKET_DATA_ENABLED`
- comportamento: resposta da IA passa por sanitizacao e validacao estrutural; se falhar, o backend monta um fallback deterministico

## 7. Como evoluir o sistema

Diretrizes para proximas sprints:
- trate a planilha como fonte de verdade ate existir uma migracao formal de dominio
- altere cabecalhos so com sincronizacao entre planilha, `Sheet_Readers.gs` e `BigQuery_Sync.gs`
- preserve o contrato do payload do dashboard antes de modularizar o frontend
- use `docs/project_context.md`, `data/` e `plans/` como base de qualquer sprint nova
- mantenha funcoes pequenas e separadas por responsabilidade
- isole futuras mudancas de export/import em `Export_Import.gs`
- se houver sprint de refactor visual, quebre `Dashboard.html` apenas depois de congelar o payload

## 8. Dependencias criticas

- Google Apps Script:
  - `HtmlService`
  - `SpreadsheetApp`
  - `PropertiesService`
  - `CacheService`
  - `UrlFetchApp`
  - `BigQuery` advanced service
- Google Sheets com nomes de aba e cabecalhos esperados
- `GOOGLEFINANCE` habilitado para enriquecimento de mercado
- Script Properties corretamente configuradas

## 9. Arquivos removidos na reorganizacao

Os arquivos abaixo foram classificados como redundantes ou obsoletos porque representavam checkpoints intermediarios ja consolidados em `docs/project_context.md`, `docs/sprints/sprint_history.md` e `docs/release_notes/release_notes.md`:

- `Stage_4_Operational_Spreadsheet.md`
- `Stage_5_Data_Migration.md`
- `Stage_6_File_Reorganization.md`
- `Stage_7_Backend_Operational_Adaptation.md`
- `Stage_8_Final_Validation.md`
- `Standalone_Stage_1_Spreadsheet_Audit.md`
- `Standalone_Stage_2_Config_Centralization.md`
- `Standalone_Stage_3_Backend_OpenById.md`

## 10. Riscos tecnicos atuais

- existe uma chave Gemini hardcoded em `apps_script/integrations/Api_Keys.gs`; isso deve ser removido antes de ampliar distribuicao do projeto
- `frontend/html/Dashboard.html` concentra layout, estilo e comportamento num unico arquivo grande
- `apps_script/integrations/BigQuery_Sync.gs` segue um modelo bound a planilha, diferente do restante da base
- `apps_script/backend/Export_Import.gs` ainda contem apenas stubs
