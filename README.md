# Esquilo Invest

Fonte principal de contexto: `docs/project_context.md`.

Estado atual da base:
- `BigQuery` e a fonte primaria do dashboard, com fallback seguro para a planilha operacional.
- o backend expoe CRUD controlado apenas para manipulacao de dados, sem executar ordens financeiras.
- a IA opera sobre o mesmo contexto consolidado do dashboard.
- o frontend voltou a operar em um unico `Dashboard.html`, mantendo compatibilidade total com Apps Script classico.
- o topo do dashboard agora consolida a carteira por macroclasse e os blocos de fundos e previdencia usam tabelas comparativas.
- as cotacoes de acoes atualizam sem reload global, preservando scroll, filtros e blocos expandidos.

Estrutura atual:
- `apps_script/` concentra o runtime Google Apps Script.
- `frontend/` concentra a interface HTML.
- `data/` concentra planilha local e contratos de dados.
- `docs/` concentra contexto, historico e release notes.
- `plans/` concentra backlog e trilhas de evolucao.

Antes de iniciar uma sprint nova:
1. leia `docs/project_context.md`
2. valide contratos em `data/`
3. revise backlog em `plans/sprints/backlog.md`
