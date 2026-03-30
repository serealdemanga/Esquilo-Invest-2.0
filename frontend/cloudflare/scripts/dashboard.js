/*
  Esquilo Invest - dashboard render layer (reworked)
  Alinhado ao payload real da Mobile API.
*/

const DASHBOARD_SELECTORS = Object.freeze({
  hero: '[data-region="hero"]',
  allocation: '[data-region="allocation-panel"]',
  insightStrip: '[data-region="insight-strip"]',
  summaryGrid: '[data-region="summary-grid"]',
  actionsPanel: '[data-region="actions-panel"]',
  fundsPanel: '[data-region="funds-panel"]',
  pensionPanel: '[data-region="pension-panel"]',
  sidebar: '[data-region="sidebar"]',
  aiPanel: '[data-region="ai-panel"]',
  categoryTabs: '[data-action="select-category"]',
  filterInput: '[data-filter="table-search"]',
  filterRecommendation: '[data-filter="recommendation"]',
  filterStatus: '[data-filter="status"]',
  filterSortBy: '[data-filter="sort-by"]',
  filterSortDirection: '[data-filter="sort-direction"]',
  resetFilters: '[data-action="reset-filters"]',
  toggleBlock: '[data-action="toggle-block"]',
  toggleAssetDetail: '[data-action="toggle-asset-detail"]',
  openAssetModal: '[data-action="open-asset-modal"]',
  requestAi: '[data-action="request-ai-analysis"]'
});

const CATEGORY_META = Object.freeze({
  all: { label: 'Visão geral' },
  actions: { label: 'Ações' },
  funds: { label: 'Fundos' },
  pension: { label: 'Previdência' }
});

function normalizeString(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function isPlainObject(value) {
  return Object.prototype.toString.call(value) === '[object Object]';
}

function toArray(value) {
  return Array.isArray(value) ? value : [];
}

function parseNumeric(value) {
  if (typeof value === 'number' && Number.isFinite(value)) return value;
  if (typeof value === 'string') {
    const cleaned = value
      .replace(/\s/g, '')
      .replace(/\./g, '')
      .replace(',', '.')
      .replace(/[^0-9.-]/g, '');
    const parsed = Number(cleaned);
    return Number.isFinite(parsed) ? parsed : 0;
  }
  return 0;
}

function pickFirstDefined() {
  for (let index = 0; index < arguments.length; index += 1) {
    const value = arguments[index];
    if (value !== undefined && value !== null && value !== '') {
      return value;
    }
  }
  return '';
}

function slugify(value) {
  return normalizeString(String(value || ''))
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');
}

function getDashboard(appContext) {
  return appContext.selectors.getDashboard() || {};
}

function getSummary(dashboard) {
  return isPlainObject(dashboard.summary) ? dashboard.summary : {};
}

function getActions(dashboard) {
  return toArray(dashboard.actions);
}

function getFunds(dashboard) {
  return toArray(pickFirstDefined(dashboard.investments, dashboard.funds, dashboard.fundos));
}

function getPension(dashboard) {
  return toArray(pickFirstDefined(dashboard.previdencias, dashboard.previdencia, dashboard.pension));
}

function getCategorySnapshots(dashboard) {
  if (Array.isArray(dashboard.categorySnapshots)) return dashboard.categorySnapshots;
  if (isPlainObject(dashboard.categorySnapshots)) return Object.values(dashboard.categorySnapshots);
  return [];
}

function getCategorySnapshotByKey(dashboard, key) {
  const snapshots = getCategorySnapshots(dashboard);
  return snapshots.find(function (item) {
    return item && item.key === key;
  }) || null;
}

function getScoreObject(dashboard) {
  return isPlainObject(dashboard.score) ? dashboard.score : {};
}

function getScoreValue(dashboard) {
  return parseNumeric(
    pickFirstDefined(
      dashboard && dashboard.score && dashboard.score.score,
      dashboard && dashboard.portfolioScore,
      dashboard && dashboard.summary && dashboard.summary.score,
      dashboard && dashboard.metrics && dashboard.metrics.score,
      dashboard && dashboard.score
    )
  );
}

function getProfileLabel(dashboard) {
  const profile = isPlainObject(dashboard.profile) ? dashboard.profile : {};
  return normalizeString(pickFirstDefined(profile.squad, dashboard.profileLabel, dashboard.profile));
}

function getPrimaryRecommendation(dashboard) {
  return dashboard && dashboard.messaging && dashboard.messaging.primaryRecommendation
    ? dashboard.messaging.primaryRecommendation
    : {};
}

function getExecutiveSummary(dashboard) {
  return dashboard && dashboard.messaging && dashboard.messaging.executiveSummary
    ? dashboard.messaging.executiveSummary
    : {};
}

function getPrimaryAlert(dashboard) {
  const alert = isPlainObject(dashboard.alert) ? dashboard.alert : null;
  if (alert && normalizeString(alert.text)) return alert.text;

  const alerts = toArray(dashboard.alerts);
  const firstAlert = alerts[0] || null;
  if (isPlainObject(firstAlert) && normalizeString(firstAlert.message)) return firstAlert.message;
  if (typeof firstAlert === 'string') return firstAlert;
  return '';
}

function getActionPlan(dashboard) {
  return isPlainObject(dashboard.actionPlan) ? dashboard.actionPlan : {};
}

function getAssetRanking(dashboard) {
  return isPlainObject(dashboard.assetRanking) ? dashboard.assetRanking : {};
}

function getOrders(dashboard) {
  return isPlainObject(dashboard.orders) ? dashboard.orders : {};
}

function getStatusTone(label) {
  const text = normalizeString(label).toLowerCase();
  if (!text) return 'neutral';
  if (/(forte|ok|manter|positivo|saudavel)/.test(text)) return 'success';
  if (/(aten|instavel|monitorar|revisar)/.test(text)) return 'warning';
  if (/(crit|reduzir|vender|risco)/.test(text)) return 'danger';
  return 'info';
}

function getScoreTone(score) {
  if (score >= 85) return 'success';
  if (score >= 70) return 'info';
  if (score >= 50) return 'warning';
  return 'danger';
}

function buildCategoryTabs(currentCategory) {
  return Object.keys(CATEGORY_META).map(function (key) {
    const meta = CATEGORY_META[key];
    const active = currentCategory === key;

    return `
      <button
        class="button ${active ? 'button--primary' : 'button--secondary'} button--sm"
        type="button"
        data-action="select-category"
        data-category="${key}"
        aria-pressed="${String(active)}"
      >
        ${meta.label}
      </button>
    `;
  }).join('');
}

function buildSelectOptions(currentValue, options) {
  return toArray(options).map(function (item) {
    const value = item[0];
    const label = item[1];
    const selected = String(currentValue) === String(value) ? 'selected' : '';
    return `<option value="${value}" ${selected}>${label}</option>`;
  }).join('');
}

function renderBadge(label, tone) {
  const safeLabel = normalizeString(label);
  if (!safeLabel) return '';
  return `<span class="badge badge--${tone || 'neutral'}">${safeLabel}</span>`;
}

function renderHero(appContext) {
  const { helpers } = appContext;
  const dashboard = getDashboard(appContext);
  const summary = getSummary(dashboard);
  const scoreObject = getScoreObject(dashboard);
  const scoreValue = getScoreValue(dashboard);
  const scoreTone = getScoreTone(scoreValue);
  const profileLabel = getProfileLabel(dashboard);
  const executiveSummary = getExecutiveSummary(dashboard);
  const recommendation = getPrimaryRecommendation(dashboard);
  const actionPlan = getActionPlan(dashboard);
  const leadText = normalizeString(
    pickFirstDefined(
      executiveSummary.statusText,
      recommendation.reason,
      actionPlan.justificativa,
      dashboard.generalAdvice,
      'Aqui você vê quanto tem, como está a carteira e o que merece atenção agora.'
    )
  );

  return `
    <section class="page-hero page-section" aria-label="Resumo da carteira">
      <div class="page-hero__primary">
        <article class="page-hero__summary card card--panel card--emphasis executive-card">
          <div class="page-hero__summary-top">
            <div class="executive-card__headline">
              <span class="type-kicker">Visão geral</span>
              <h1 class="type-heading-1">Sua carteira em uma leitura só.</h1>
              <p class="type-body">${helpers.escapeHtml(leadText)}</p>
            </div>
            ${renderBadge(`Score ${scoreValue || '—'}`, scoreTone)}
          </div>

          <div class="page-hero__summary-body u-stack-md">
            <div>
              <span class="type-label">Patrimônio atual</span>
              <strong class="type-value-xl hide-value">${helpers.formatMoney(summary.totalRaw)}</strong>
            </div>

            <div class="executive-card__metrics page-hero__stat-row">
              <article class="metric-card">
                <span class="type-label metric-card__label">Total investido</span>
                <strong class="type-value-md metric-card__value hide-value">${helpers.formatMoney(summary.totalInvestidoRaw)}</strong>
                <span class="type-body-sm metric-card__support">Quanto já entrou na carteira</span>
              </article>

              <article class="metric-card">
                <span class="type-label metric-card__label">Resultado acumulado</span>
                <strong class="type-value-md metric-card__value ${summary.totalPerformanceRaw >= 0 ? 'u-text-success' : 'u-text-danger'}">${helpers.formatPercent(summary.totalPerformanceRaw)}</strong>
                <span class="type-body-sm metric-card__support">Da carteira toda, até agora</span>
              </article>

              <article class="metric-card">
                <span class="type-label metric-card__label">Perfil</span>
                <strong class="type-value-md metric-card__value">${helpers.escapeHtml(profileLabel || 'Sem leitura')}</strong>
                <span class="type-body-sm metric-card__support">${helpers.escapeHtml(scoreObject.status || 'Sem status')}</span>
              </article>
            </div>
          </div>

          <div class="page-hero__summary-foot">
            ${profileLabel ? renderBadge(profileLabel, 'neutral') : ''}
            ${scoreObject.status ? renderBadge(scoreObject.status, getStatusTone(scoreObject.status)) : ''}
            <button class="button button--secondary button--sm" type="button" data-action="refresh-dashboard">Atualizar</button>
            <button class="button button--ghost button--sm" type="button" data-action="refresh-actions">Rever ações</button>
          </div>
        </article>
      </div>

      <div class="page-hero__secondary">
        <article class="page-hero__insight card card--panel insight-strip">
          <div class="insight-strip__main">
            <div class="summary-card__icon" aria-hidden="true">⚑</div>
            <div class="insight-strip__copy">
              <span class="type-label">Ponto principal</span>
              <strong class="type-body-strong">${helpers.escapeHtml(recommendation.title || actionPlan.acao_principal || 'Sem movimento urgente agora')}</strong>
              <p class="type-body-sm">${helpers.escapeHtml(recommendation.reason || actionPlan.justificativa || 'Nada crítico além do que já está sob observação.')}</p>
            </div>
          </div>
          <div class="insight-strip__actions">
            <button class="button button--ia button--sm" type="button" data-action="request-ai-analysis">Ver leitura da IA</button>
          </div>
        </article>

        <article class="page-hero__mission card card--ia">
          <span class="type-kicker">Próximo passo</span>
          <div class="u-stack-sm">
            <strong class="type-heading-3">${helpers.escapeHtml(actionPlan.acao_principal || 'Seguir acompanhando')}</strong>
            <p class="type-body">${helpers.escapeHtml(actionPlan.impacto || recommendation.impact || 'Sem urgência fora do normal. Apenas acompanhe o que mais pesa na carteira.')}</p>
          </div>
          <div class="page-hero__mission-grid">
            <div class="inline-card__metric">
              <span class="type-label">Prioridade</span>
              <strong class="type-body-strong">${helpers.escapeHtml(actionPlan.prioridade || 'Média')}</strong>
            </div>
            <div class="inline-card__metric">
              <span class="type-label">Atualização</span>
              <strong class="type-body-strong">${helpers.escapeHtml(helpers.formatDateTime(dashboard.updatedAt))}</strong>
            </div>
          </div>
        </article>
      </div>
    </section>
  `;
}

function renderAllocationPanel(appContext) {
  const { helpers } = appContext;
  const dashboard = getDashboard(appContext);
  const snapshots = getCategorySnapshots(dashboard);
  const total = parseNumeric(getSummary(dashboard).totalRaw);

  let accumulated = 0;
  const stops = snapshots.map(function (item) {
    const sharePct = parseNumeric(item.shareRaw) * 100;
    const start = accumulated;
    accumulated += sharePct;
    return `${item.color || 'var(--brand-primary)'} ${start}% ${accumulated}%`;
  });

  const gradient = stops.length
    ? `conic-gradient(${stops.join(', ')})`
    : 'conic-gradient(var(--surface-3) 0 100%)';

  const list = snapshots.map(function (item) {
    return `
      <article class="allocation-item">
        <span class="allocation-item__swatch" style="background:${item.color || 'var(--brand-primary)'}"></span>
        <div class="allocation-item__body">
          <strong class="type-body-strong">${helpers.escapeHtml(item.label || 'Categoria')}</strong>
          <span class="type-body-sm">${helpers.escapeHtml(item.status || 'Sem leitura')}</span>
        </div>
        <div class="allocation-item__stats">
          <strong class="type-body-strong hide-value">${helpers.escapeHtml(item.totalLabel || helpers.formatMoney(item.totalRaw))}</strong>
          <span class="type-body-sm">${helpers.escapeHtml(item.shareLabel || '0,0%')}</span>
        </div>
      </article>
    `;
  }).join('');

  return `
    <article class="dashboard__allocation card card--panel">
      <div class="panel__header">
        <div class="panel__header-main">
          <span class="type-kicker">Composição</span>
          <h2 class="type-heading-2">Onde seu dinheiro está hoje</h2>
          <p class="type-body-sm">Uma leitura simples da divisão da carteira.</p>
        </div>
      </div>
      <div class="dashboard__allocation-body">
        <div class="dashboard__allocation-visual">
          <div class="allocation-chart" style="background:${gradient}">
            <div class="allocation-chart__center">
              <span class="type-label">Total</span>
              <strong class="type-value-md hide-value">${helpers.formatMoney(total)}</strong>
              <span class="type-body-sm">${snapshots.length} blocos principais</span>
            </div>
          </div>
        </div>
        <div class="allocation-list dashboard__allocation-list">
          ${list}
        </div>
      </div>
    </article>
  `;
}

function renderInsightStrip(appContext) {
  const { helpers } = appContext;
  const dashboard = getDashboard(appContext);
  const executiveSummary = getExecutiveSummary(dashboard);
  const alertText = getPrimaryAlert(dashboard);

  return `
    <article class="dashboard__insight-strip card card--panel insight-strip">
      <div class="insight-strip__main">
        <div class="summary-card__icon" aria-hidden="true">✦</div>
        <div class="insight-strip__copy">
          <span class="type-label">Resumo rápido</span>
          <strong class="type-body-strong">${helpers.escapeHtml(executiveSummary.performanceText || 'Tudo em um lugar')}</strong>
          <p class="type-body-sm">${helpers.escapeHtml(alertText || executiveSummary.statusText || 'Acompanhe o que mais pesa na carteira para decidir com calma.')}</p>
        </div>
      </div>
      <div class="insight-strip__actions">
        ${executiveSummary.scoreStatusText ? renderBadge(executiveSummary.scoreStatusText, getStatusTone(executiveSummary.scoreStatusText)) : ''}
      </div>
    </article>
  `;
}

function renderSummaryCards(appContext) {
  const { helpers } = appContext;
  const dashboard = getDashboard(appContext);
  const actions = getActions(dashboard);
  const funds = getFunds(dashboard);
  const pension = getPension(dashboard);
  const categories = [
    { key: 'actions', title: 'Ações', items: actions, snapshot: getCategorySnapshotByKey(dashboard, 'acoes') },
    { key: 'funds', title: 'Fundos', items: funds, snapshot: getCategorySnapshotByKey(dashboard, 'fundos') },
    { key: 'pension', title: 'Previdência', items: pension, snapshot: getCategorySnapshotByKey(dashboard, 'previdencia') }
  ];

  return categories.map(function (category) {
    const snapshot = category.snapshot || {};
    const leading = category.items[0] || null;

    return `
      <article class="summary-card summary-card--${category.key}">
        <header class="summary-card__header">
          <div class="summary-card__header-main">
            <div class="summary-card__icon" aria-hidden="true">${category.key === 'actions' ? '↗' : category.key === 'funds' ? '◌' : '◎'}</div>
            <div class="summary-card__header-copy">
              <span class="type-label">${category.title}</span>
              <strong class="type-value-lg hide-value">${helpers.escapeHtml(snapshot.totalLabel || 'Sem dados')}</strong>
              <div class="summary-card__meta-row">
                ${renderBadge(`${category.items.length} itens`, 'neutral')}
                ${renderBadge(snapshot.shareLabel || '0,0%', 'info')}
                ${renderBadge(snapshot.performanceLabel || '0,0%', snapshot.performanceRaw >= 0 ? 'success' : 'danger')}
              </div>
            </div>
          </div>
        </header>
        <div class="summary-card__body">
          <div class="summary-card__panel">
            <span class="type-label">Leitura</span>
            <p class="summary-card__summary">${helpers.escapeHtml(snapshot.recommendation ? `${snapshot.label || category.title}: ${snapshot.recommendation}.` : 'Sem leitura complementar nesta categoria.')}</p>
          </div>
          <div class="summary-card__panel">
            <span class="type-label">Maior posição</span>
            <p class="summary-card__summary">${helpers.escapeHtml(leading ? (leading.name || leading.ticker || 'Sem item principal') : 'Nenhum item nessa categoria.')}</p>
          </div>
        </div>
      </article>
    `;
  }).join('');
}

function renderActionsPanel(appContext) {
  const { helpers, selectors, store } = appContext;
  const dashboard = getDashboard(appContext);
  const filters = store.getState().ui.filters;
  const items = selectors.getFilteredActions();

  const rows = items.map(function (item) {
    const itemId = slugify(item.ticker || item.name);
    const resultText = normalizeString(item.rendimentoPct || item.performanceLabel || '—');
    const detailOpen = store.getState().ui.selectedAssetId === itemId;

    return `
      <tbody>
        <tr class="table-row--interactive ${detailOpen ? 'is-active' : ''}">
          <td>
            <div class="table-row__entity">
              <button class="button-icon ${detailOpen ? 'button-icon--active' : ''}" type="button" data-action="toggle-asset-detail" data-asset-id="${helpers.escapeHtml(itemId)}" aria-label="Expandir ${helpers.escapeHtml(item.ticker || item.name)}">
                <span aria-hidden="true">${detailOpen ? '−' : '+'}</span>
              </button>
              <div class="table-row__entity-copy">
                <strong class="type-body-strong">${helpers.escapeHtml(item.ticker || item.name || 'Ativo')}</strong>
                <span class="type-body-sm">${helpers.escapeHtml(item.name || item.observation || '')}</span>
              </div>
            </div>
          </td>
          <td><span class="type-body-sm">${helpers.escapeHtml(item.institution || '—')}</span></td>
          <td><span class="type-body-sm">${helpers.escapeHtml(item.statusLabel || '—')}</span></td>
          <td><span class="type-body-sm">${helpers.escapeHtml(item.recommendation || 'Acompanhar')}</span></td>
          <td><strong class="type-body-strong hide-value">${helpers.escapeHtml(item.positionValue || item.valorAtual || helpers.formatMoney(item.valorAtualRaw))}</strong></td>
          <td><span class="type-body-sm ${normalizeString(resultText).startsWith('-') ? 'u-text-danger' : 'u-text-success'}">${helpers.escapeHtml(resultText)}</span></td>
          <td><button class="button button--ghost button--sm" type="button" data-action="open-asset-modal" data-asset-id="${helpers.escapeHtml(itemId)}">Detalhe</button></td>
        </tr>
        ${detailOpen ? `
          <tr class="table-row__detail">
            <td colspan="7">
              <div class="table-row__detail-shell">
                <div class="table-row__detail-grid">
                  <div class="table-row__detail-item">
                    <span class="type-label table-row__detail-label">Preço médio</span>
                    <strong class="type-body-strong table-row__detail-value">${helpers.escapeHtml(item.avgPrice || helpers.formatMoney(item.avgPriceRaw))}</strong>
                  </div>
                  <div class="table-row__detail-item">
                    <span class="type-label table-row__detail-label">Preço atual</span>
                    <strong class="type-body-strong table-row__detail-value">${helpers.escapeHtml(item.currentPrice || helpers.formatMoney(item.currentPriceRaw))}</strong>
                  </div>
                  <div class="table-row__detail-item">
                    <span class="type-label table-row__detail-label">Quantidade</span>
                    <strong class="type-body-strong table-row__detail-value">${helpers.escapeHtml(String(item.qty || item.qtyRaw || '—'))}</strong>
                  </div>
                  <div class="table-row__detail-item">
                    <span class="type-label table-row__detail-label">Comentário</span>
                    <strong class="type-body-strong table-row__detail-value">${helpers.escapeHtml(item.smartRecommendation && item.smartRecommendation.reason || item.observation || 'Sem observação extra.')}</strong>
                  </div>
                </div>
              </div>
            </td>
          </tr>
        ` : ''}
      </tbody>
    `;
  }).join('');

  return `
    <section class="panel surface-panel">
      <div class="panel__header">
        <div class="panel__header-main">
          <span class="type-kicker">Ações</span>
          <h2 class="type-heading-2">O que está acontecendo nas suas ações</h2>
          <p class="type-body-sm">Uma visão simples do que está bem, do que pede atenção e do que vale acompanhar.</p>
        </div>
      </div>

      <div class="panel__body">
        <div class="u-cluster">
          ${buildCategoryTabs(store.getState().ui.selectedCategory)}
          <div class="search-field" style="min-width:16rem; flex:1 1 16rem;">
            <span class="search-field__icon" aria-hidden="true">⌕</span>
            <input class="input search-field__input" type="search" placeholder="Buscar ativo ou instituição" data-filter="table-search" value="${helpers.escapeHtml(filters.tableSearch || '')}" />
          </div>
          <select class="filter-select" data-filter="recommendation">
            ${buildSelectOptions(filters.recommendation, [['all', 'Leitura'], ['manter', 'Manter'], ['monitorar', 'Monitorar'], ['revisar', 'Revisar'], ['reduzir', 'Reduzir']])}
          </select>
          <select class="filter-select" data-filter="status">
            ${buildSelectOptions(filters.status, [['all', 'Situação'], ['comprado', 'Comprado'], ['aplicado', 'Aplicado'], ['ativo', 'Ativo']])}
          </select>
          <select class="filter-select" data-filter="sort-by">
            ${buildSelectOptions(filters.sortBy, [['priority', 'Prioridade'], ['performance', 'Resultado'], ['value', 'Valor'], ['name', 'Nome']])}
          </select>
          <select class="filter-select" data-filter="sort-direction">
            ${buildSelectOptions(filters.sortDirection, [['desc', 'Maior primeiro'], ['asc', 'Menor primeiro']])}
          </select>
          <button class="button button--ghost button--sm" type="button" data-action="reset-filters">Limpar</button>
        </div>

        <div class="table-shell">
          <div class="table-shell__scroll u-scroll-x">
            <table class="data-table">
              <thead>
                <tr>
                  <th>Ativo</th>
                  <th>Instituição</th>
                  <th>Situação</th>
                  <th>Leitura</th>
                  <th>Valor atual</th>
                  <th>Resultado</th>
                  <th></th>
                </tr>
              </thead>
              ${rows || `
                <tbody>
                  <tr>
                    <td colspan="7">
                      <div class="empty-state">
                        <strong class="type-body-strong">Nada encontrado</strong>
                        <p class="type-body-sm">Tente mudar os filtros para ver mais itens.</p>
                      </div>
                    </td>
                  </tr>
                </tbody>
              `}
            </table>
          </div>
        </div>
      </div>
    </section>
  `;
}

function renderCollectionTable(appContext, items, title, kicker) {
  const { helpers } = appContext;

  const rows = items.map(function (item) {
    const performance = normalizeString(item.performanceLabel || item.rentPct || '0,0%');
    return `
      <tr class="table-row--interactive">
        <td>
          <div class="table-row__entity-copy">
            <strong class="type-body-strong">${helpers.escapeHtml(item.name || 'Item')}</strong>
            <span class="type-body-sm">${helpers.escapeHtml(item.observation || item.classification || '')}</span>
          </div>
        </td>
        <td><span class="type-body-sm">${helpers.escapeHtml(item.institution || '—')}</span></td>
        <td><strong class="type-body-strong hide-value">${helpers.escapeHtml(item.valorAtual || helpers.formatMoney(item.valorAtualRaw))}</strong></td>
        <td><span class="type-body-sm ${performance.startsWith('-') ? 'u-text-danger' : 'u-text-success'}">${helpers.escapeHtml(performance)}</span></td>
        <td><span class="type-body-sm">${helpers.escapeHtml(item.recommendation || 'Manter')}</span></td>
      </tr>
    `;
  }).join('');

  return `
    <section class="panel surface-panel">
      <div class="panel__header">
        <div class="panel__header-main">
          <span class="type-kicker">${kicker}</span>
          <h2 class="type-heading-2">${title}</h2>
          <p class="type-body-sm">Sem complicação: valor atual, resultado e leitura do que está aqui.</p>
        </div>
        <div class="panel__header-actions">
          ${renderBadge(`${items.length} itens`, 'neutral')}
        </div>
      </div>
      <div class="panel__body">
        <div class="table-shell__scroll u-scroll-x">
          <table class="data-table">
            <thead>
              <tr>
                <th>Nome</th>
                <th>Instituição</th>
                <th>Valor atual</th>
                <th>Resultado</th>
                <th>Leitura</th>
              </tr>
            </thead>
            <tbody>
              ${rows || `
                <tr>
                  <td colspan="5">
                    <div class="empty-state">
                      <strong class="type-body-strong">Sem itens aqui</strong>
                      <p class="type-body-sm">Essa parte da carteira não trouxe dados agora.</p>
                    </div>
                  </td>
                </tr>
              `}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  `;
}

function renderSidebar(appContext) {
  const { helpers } = appContext;
  const dashboard = getDashboard(appContext);
  const scoreObject = getScoreObject(dashboard);
  const recommendation = getPrimaryRecommendation(dashboard);
  const ranking = getAssetRanking(dashboard);
  const orders = getOrders(dashboard);
  const history = toArray(dashboard.decisionHistory).slice(0, 3);
  const alerts = toArray(dashboard.intelligentAlerts).slice(0, 3);

  const alertHtml = alerts.map(function (item) {
    return `
      <div class="alert-state alert-state--${getStatusTone(item.type || item.title)}">
        <strong class="alert-state__title type-body-strong">${helpers.escapeHtml(item.title || 'Alerta')}</strong>
        <span class="type-body-sm">${helpers.escapeHtml(item.message || '')}</span>
      </div>
    `;
  }).join('');

  const orderText = orders.buy && orders.buy.symbol
    ? `Compra sugerida: ${orders.buy.symbol} em ${orders.buy.value || 'valor não informado'}`
    : orders.sell && orders.sell.symbol
      ? `Venda sugerida: ${orders.sell.symbol} em ${orders.sell.value || 'valor não informado'}`
      : 'Sem ordem sugerida agora.';

  const historyHtml = history.map(function (item) {
    return `
      <div class="helper-state">
        <strong class="type-body-strong">${helpers.escapeHtml(item.acao || 'Sem registro')}</strong>
        <p class="type-body-sm">${helpers.escapeHtml(item.contexto || item.outcome && item.outcome.summary || '')}</p>
      </div>
    `;
  }).join('');

  return `
    <div class="dashboard__aside-sticky">
      <section class="sidebar-card card card--panel">
        <div class="card__header-main">
          <span class="type-kicker">Saúde da carteira</span>
          <h2 class="type-heading-3">Como ela está hoje</h2>
        </div>
        <div class="sidebar-card__metric-grid">
          <div class="inline-card__metric">
            <span class="type-label">Score</span>
            <strong class="type-value-md">${helpers.escapeHtml(String(scoreObject.score || '—'))}</strong>
          </div>
          <div class="inline-card__metric">
            <span class="type-label">Leitura</span>
            <strong class="type-body-strong">${helpers.escapeHtml(scoreObject.status || 'Sem status')}</strong>
          </div>
        </div>
        <p class="type-body-sm">${helpers.escapeHtml(scoreObject.explanation || 'Sem explicação detalhada nesta rodada.')}</p>
      </section>

      <section class="sidebar-card card card--panel">
        <div class="card__header-main">
          <span class="type-kicker">Ação sugerida</span>
          <h2 class="type-heading-3">O que mais importa agora</h2>
        </div>
        <p class="type-body">${helpers.escapeHtml(recommendation.title || 'Nenhuma mudança urgente')}</p>
        <p class="type-body-sm">${helpers.escapeHtml(recommendation.reason || 'Sem detalhe extra no momento.')}</p>
        <div class="u-stack-sm">
          ${ranking.topOpportunity ? renderBadge(`Oportunidade: ${ranking.topOpportunity.ticker}`, 'success') : ''}
          ${ranking.topRisk ? renderBadge(`Ficar de olho: ${ranking.topRisk.ticker}`, 'warning') : ''}
        </div>
      </section>

      <section class="sidebar-card card card--panel">
        <div class="card__header-main">
          <span class="type-kicker">Alertas</span>
          <h2 class="type-heading-3">O que merece atenção</h2>
        </div>
        <div class="sidebar-card__group">
          ${alertHtml || '<div class="helper-state"><p class="type-body-sm">Sem alerta importante agora.</p></div>'}
        </div>
      </section>

      <section class="sidebar-card card card--panel">
        <div class="card__header-main">
          <span class="type-kicker">Movimento sugerido</span>
          <h2 class="type-heading-3">Leitura rápida</h2>
        </div>
        <p class="type-body-sm">${helpers.escapeHtml(orderText)}</p>
      </section>

      <section class="sidebar-card card card--panel">
        <div class="card__header-main">
          <span class="type-kicker">Histórico</span>
          <h2 class="type-heading-3">Últimas leituras</h2>
        </div>
        <div class="sidebar-card__group">
          ${historyHtml || '<div class="helper-state"><p class="type-body-sm">Sem histórico recente.</p></div>'}
        </div>
      </section>
    </div>
  `;
}

function renderAiPanel(appContext) {
  const { helpers, selectors, store } = appContext;
  const analysis = selectors.getAiAnalysis();
  const isLoading = Boolean(store.getState().ui.isAiLoading);

  return `
    <section class="ai-panel card card--ia">
      <div class="ai-panel__header">
        <div class="ai-panel__brand">
          <div class="ai-panel__icon" aria-hidden="true">✧</div>
          <div>
            <span class="type-kicker">Leitura da IA</span>
            <h2 class="type-heading-3">Uma segunda opinião sobre a carteira</h2>
          </div>
        </div>
        <button class="button button--ia button--sm" type="button" data-action="request-ai-analysis">${isLoading ? 'Lendo...' : 'Atualizar'}</button>
      </div>
      <div class="ai-panel__response ${isLoading ? 'is-loading-skeleton' : ''}">
        ${helpers.escapeHtml(analysis || 'Quando você pedir, a IA resume a carteira em linguagem mais direta e humana.')}
      </div>
      <div class="ai-panel__status type-body-sm">Use isso como apoio, não como piloto automático.</div>
    </section>
  `;
}

function renderDashboardContent(appContext) {
  const { dom } = appContext;
  if (!dom.root) return;

  dom.root.innerHTML = `
    <div class="app__shell">
      <div class="app__stack">
        <section data-region="hero"></section>
        <section data-region="overview" class="dashboard page-section">
          <div class="dashboard__overview">
            <div class="dashboard__overview-top">
              <div data-region="allocation-panel"></div>
              <div data-region="insight-strip"></div>
            </div>
            <div class="dashboard__overview-bottom">
              <div class="dashboard__summary-grid" data-region="summary-grid"></div>
            </div>
          </div>

          <div class="dashboard__content page-section">
            <main class="dashboard__main">
              <section data-region="actions-panel"></section>
              <section data-region="funds-panel"></section>
              <section data-region="pension-panel"></section>
            </main>
            <aside class="dashboard__aside" data-region="sidebar"></aside>
          </div>

          <div class="page-section" data-region="ai-panel"></div>
        </section>
      </div>
    </div>
  `;
}

function rerenderDashboard(appContext) {
  const { dom } = appContext;
  if (!dom.root) return;

  const heroNode = dom.root.querySelector(DASHBOARD_SELECTORS.hero);
  const allocationNode = dom.root.querySelector(DASHBOARD_SELECTORS.allocation);
  const insightNode = dom.root.querySelector(DASHBOARD_SELECTORS.insightStrip);
  const summaryNode = dom.root.querySelector(DASHBOARD_SELECTORS.summaryGrid);
  const actionsNode = dom.root.querySelector(DASHBOARD_SELECTORS.actionsPanel);
  const fundsNode = dom.root.querySelector(DASHBOARD_SELECTORS.fundsPanel);
  const pensionNode = dom.root.querySelector(DASHBOARD_SELECTORS.pensionPanel);
  const sidebarNode = dom.root.querySelector(DASHBOARD_SELECTORS.sidebar);
  const aiNode = dom.root.querySelector(DASHBOARD_SELECTORS.aiPanel);

  if (heroNode) heroNode.innerHTML = renderHero(appContext);
  if (allocationNode) allocationNode.innerHTML = renderAllocationPanel(appContext);
  if (insightNode) insightNode.innerHTML = renderInsightStrip(appContext);
  if (summaryNode) summaryNode.innerHTML = renderSummaryCards(appContext);
  if (actionsNode) actionsNode.innerHTML = renderActionsPanel(appContext);
  if (fundsNode) fundsNode.innerHTML = renderCollectionTable(appContext, getFunds(getDashboard(appContext)), 'Fundos', 'Fundos');
  if (pensionNode) pensionNode.innerHTML = renderCollectionTable(appContext, getPension(getDashboard(appContext)), 'Previdência', 'Previdência');
  if (sidebarNode) sidebarNode.innerHTML = renderSidebar(appContext);
  if (aiNode) aiNode.innerHTML = renderAiPanel(appContext);
}

function syncDashboardUiState(appContext) {
  const { dom, store } = appContext;
  if (!dom.root) return;

  const state = store.getState();
  dom.root.classList.toggle('dashboard-loading', Boolean(state.ui.isLoading));

  dom.root.querySelectorAll(DASHBOARD_SELECTORS.categoryTabs).forEach(function (button) {
    const active = button.dataset.category === state.ui.selectedCategory;
    button.classList.toggle('button--primary', active);
    button.classList.toggle('button--secondary', !active);
    button.setAttribute('aria-pressed', String(active));
  });

  const filterInput = dom.root.querySelector(DASHBOARD_SELECTORS.filterInput);
  if (filterInput && filterInput.value !== state.ui.filters.tableSearch) {
    filterInput.value = state.ui.filters.tableSearch || '';
  }
}

function renderDashboardShell(appContext) {
  renderDashboardContent(appContext);
  rerenderDashboard(appContext);
}

function findAssetById(dashboard, assetId) {
  return []
    .concat(getActions(dashboard), getFunds(dashboard), getPension(dashboard))
    .find(function (item) {
      return slugify(item.ticker || item.name) === assetId;
    }) || null;
}

function bindDashboardEvents(appContext) {
  const { dom, store, actions } = appContext;
  if (!dom.root) return;

  dom.root.addEventListener('click', function (event) {
    const button = event.target.closest('button');
    if (!button) return;

    if (button.matches(DASHBOARD_SELECTORS.categoryTabs)) {
      store.setSelectedCategory(button.dataset.category || 'all', { source: 'dashboard-ui' });
      rerenderDashboard(appContext);
      syncDashboardUiState(appContext);
      return;
    }

    if (button.matches(DASHBOARD_SELECTORS.resetFilters)) {
      store.resetFilters({ source: 'dashboard-ui' });
      rerenderDashboard(appContext);
      syncDashboardUiState(appContext);
      return;
    }

    if (button.matches(DASHBOARD_SELECTORS.toggleAssetDetail)) {
      const assetId = normalizeString(button.dataset.assetId);
      const current = store.getState().ui.selectedAssetId;
      store.setSelectedAsset(current === assetId ? '' : assetId, { source: 'dashboard-ui' });
      rerenderDashboard(appContext);
      syncDashboardUiState(appContext);
      return;
    }

    if (button.matches(DASHBOARD_SELECTORS.openAssetModal)) {
      const assetId = normalizeString(button.dataset.assetId);
      const asset = findAssetById(getDashboard(appContext), assetId);
      if (asset) {
        store.openModal('asset-detail', asset, { source: 'dashboard-ui' });
      }
      return;
    }

    if (button.matches(DASHBOARD_SELECTORS.requestAi)) {
      actions.refreshAiAnalysis({ silent: false });
    }
  });

  dom.root.addEventListener('input', function (event) {
    const target = event.target;
    if (!(target instanceof HTMLInputElement || target instanceof HTMLSelectElement)) return;

    if (target.matches(DASHBOARD_SELECTORS.filterInput)) {
      store.setFilters({ tableSearch: target.value }, { source: 'dashboard-ui' });
      rerenderDashboard(appContext);
      syncDashboardUiState(appContext);
    }
  });

  dom.root.addEventListener('change', function (event) {
    const target = event.target;
    if (!(target instanceof HTMLSelectElement)) return;

    if (target.matches(DASHBOARD_SELECTORS.filterRecommendation)) {
      store.setFilters({ recommendation: target.value }, { source: 'dashboard-ui' });
      rerenderDashboard(appContext);
      syncDashboardUiState(appContext);
      return;
    }

    if (target.matches(DASHBOARD_SELECTORS.filterStatus)) {
      store.setFilters({ status: target.value }, { source: 'dashboard-ui' });
      rerenderDashboard(appContext);
      syncDashboardUiState(appContext);
      return;
    }

    if (target.matches(DASHBOARD_SELECTORS.filterSortBy)) {
      store.setFilters({ sortBy: target.value }, { source: 'dashboard-ui' });
      rerenderDashboard(appContext);
      syncDashboardUiState(appContext);
      return;
    }

    if (target.matches(DASHBOARD_SELECTORS.filterSortDirection)) {
      store.setFilters({ sortDirection: target.value }, { source: 'dashboard-ui' });
      rerenderDashboard(appContext);
      syncDashboardUiState(appContext);
    }
  });
}

function createDashboardController(appContext) {
  let unsubscribe = null;

  function bind() {
    bindDashboardEvents(appContext);

    unsubscribe = appContext.store.subscribe(function () {
      rerenderDashboard(appContext);
      syncDashboardUiState(appContext);
    });
  }

  function afterInitialLoad() {
    rerenderDashboard(appContext);
    syncDashboardUiState(appContext);
  }

  function destroy() {
    if (typeof unsubscribe === 'function') {
      unsubscribe();
      unsubscribe = null;
    }
  }

  return {
    bind,
    afterInitialLoad,
    destroy,
    rerender: function () {
      rerenderDashboard(appContext);
    }
  };
}

export {
  CATEGORY_META,
  DASHBOARD_SELECTORS,
  createDashboardController,
  renderDashboardShell,
  syncDashboardUiState
};
