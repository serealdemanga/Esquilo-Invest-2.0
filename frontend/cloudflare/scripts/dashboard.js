/*
  Esquilo Invest - dashboard controller and render layer

  Responsabilidades:
  - montar a casca HTML principal do dashboard
  - renderizar cada bloco a partir do payload atual
  - reagir a filtros, expansoes e eventos do usuario
  - manter a leitura desktop-first sem framework
*/

const DASHBOARD_SELECTORS = Object.freeze({
  hero: '[data-region="hero"]',
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
  requestAi: '[data-action="request-ai-analysis"]',
  openGenericModal: '[data-action="open-generic-modal"]'
});

const CATEGORY_META = Object.freeze({
  all: {
    label: 'Visao geral'
  },
  actions: {
    label: 'Acoes',
    badgeClass: 'badge--brand'
  },
  funds: {
    label: 'Fundos',
    badgeClass: 'badge--info'
  },
  pension: {
    label: 'Previdencia',
    badgeClass: 'badge--success'
  }
});

const BLOCK_LABELS = Object.freeze({
  actions: 'Acoes',
  funds: 'Fundos',
  pension: 'Previdencia',
  alerts: 'Alertas',
  actionPlan: 'Plano de acao',
  ai: 'Esquilo IA'
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
    const normalized = Number(value.replace(/\s/g, '').replace(/\./g, '').replace(',', '.').replace(/[^0-9.-]/g, ''));
    return Number.isFinite(normalized) ? normalized : 0;
  }

  return 0;
}

function pickFirstDefined(...values) {
  for (const value of values) {
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

function deriveTicker(item) {
  return normalizeString(
    pickFirstDefined(item?.ticker, item?.codigo, item?.code, item?.nome, item?.name, item?.plano)
  );
}

function deriveItemId(item, categoryKey = 'item') {
  return normalizeString(
    pickFirstDefined(item?.id, item?.assetId, item?.uid, item?.key)
  ) || `${categoryKey}-${slugify(deriveTicker(item) || JSON.stringify(item).slice(0, 24))}`;
}

function deriveItemStatus(item) {
  return normalizeString(
    pickFirstDefined(item?.status, item?.assetStatus, item?.statusLabel, item?.signal)
  );
}

function deriveRecommendation(item) {
  return normalizeString(
    pickFirstDefined(item?.recommendation, item?.recomendacao, item?.recommendationContext, item?.acaoSugerida)
  );
}

function getScoreValue(dashboard) {
  return pickFirstDefined(
    dashboard?.score,
    dashboard?.portfolioScore,
    dashboard?.summary?.score,
    dashboard?.metrics?.score,
    dashboard?.executiveSummary?.score
  );
}

function getProfileLabel(dashboard) {
  return normalizeString(
    pickFirstDefined(
      dashboard?.profile,
      dashboard?.perfil,
      dashboard?.summary?.profile,
      dashboard?.summary?.perfil,
      dashboard?.metrics?.profile
    )
  );
}

function getDecisionLabel(dashboard) {
  return normalizeString(
    pickFirstDefined(
      dashboard?.decision,
      dashboard?.decisionLabel,
      dashboard?.consolidatedDecision,
      dashboard?.summary?.decision,
      dashboard?.summary?.decisao
    )
  );
}

function getActionPlan(dashboard) {
  return isPlainObject(dashboard?.actionPlan)
    ? dashboard.actionPlan
    : isPlainObject(dashboard?.planoDeAcao)
      ? dashboard.planoDeAcao
      : null;
}

function getAlerts(dashboard) {
  return toArray(pickFirstDefined(dashboard?.alerts, dashboard?.alertas));
}

function getActions(dashboard) {
  return toArray(pickFirstDefined(dashboard?.actions, dashboard?.acoes));
}

function getFunds(dashboard) {
  return toArray(pickFirstDefined(dashboard?.funds, dashboard?.fundos));
}

function getPension(dashboard) {
  return toArray(pickFirstDefined(dashboard?.pension, dashboard?.previdencia));
}

function getOrders(dashboard) {
  return isPlainObject(dashboard?.orders)
    ? dashboard.orders
    : isPlainObject(dashboard?.preOrders)
      ? dashboard.preOrders
      : {};
}

function getSummary(dashboard) {
  return isPlainObject(dashboard?.summary) ? dashboard.summary : {};
}

function getCategorySnapshots(dashboard) {
  return isPlainObject(dashboard?.categorySnapshots)
    ? dashboard.categorySnapshots
    : isPlainObject(dashboard?.categories)
      ? dashboard.categories
      : {};
}

function getExecutiveMessage(dashboard) {
  return normalizeString(
    pickFirstDefined(
      dashboard?.executiveMessage,
      dashboard?.executiveSummary,
      dashboard?.messaging?.headline,
      dashboard?.mensagemExecutiva,
      dashboard?.summary?.message,
      dashboard?.summary?.mensagem
    )
  );
}

function getOpportunityMessage(dashboard) {
  return normalizeString(
    pickFirstDefined(
      dashboard?.opportunity,
      dashboard?.highlight,
      dashboard?.insight,
      dashboard?.messaging?.opportunity,
      dashboard?.messaging?.insight
    )
  );
}

function getMainMission(dashboard) {
  const actionPlan = getActionPlan(dashboard);
  if (actionPlan) {
    return {
      title: normalizeString(pickFirstDefined(actionPlan.title, actionPlan.acao, actionPlan.action, actionPlan.headline)) || 'Missao do momento',
      description: normalizeString(pickFirstDefined(actionPlan.reason, actionPlan.motivo, actionPlan.description, actionPlan.descricao)),
      impact: normalizeString(pickFirstDefined(actionPlan.impact, actionPlan.impacto)),
      priority: normalizeString(pickFirstDefined(actionPlan.priority, actionPlan.prioridade))
    };
  }

  return {
    title: 'Missao do momento',
    description: getDecisionLabel(dashboard) || 'Sem prioridade principal identificada.',
    impact: getOpportunityMessage(dashboard),
    priority: ''
  };
}

function calculatePortfolioTotal(summary, dashboard) {
  return parseNumeric(
    pickFirstDefined(
      summary?.totalRaw,
      summary?.total,
      dashboard?.totalEquity,
      dashboard?.patrimonioTotal,
      dashboard?.metrics?.totalEquity
    )
  );
}

function calculateInvestedTotal(summary, dashboard) {
  return parseNumeric(
    pickFirstDefined(
      summary?.investedRaw,
      summary?.valorInvestidoRaw,
      dashboard?.investedTotal,
      dashboard?.valorInvestido,
      dashboard?.metrics?.investedTotal
    )
  );
}

function calculateProfitability(summary, dashboard) {
  return parseNumeric(
    pickFirstDefined(
      summary?.performancePct,
      summary?.rentabilidadePct,
      dashboard?.performancePct,
      dashboard?.rentabilidadePct,
      dashboard?.metrics?.performancePct,
      dashboard?.metrics?.rentabilidadePct
    )
  );
}

function deriveCategorySummary(categoryKey, items, snapshot, portfolioTotal) {
  const totalValue = parseNumeric(
    pickFirstDefined(
      snapshot?.currentValue,
      snapshot?.valorAtual,
      snapshot?.totalAtual,
      snapshot?.equity,
      snapshot?.amount
    )
  ) || items.reduce((acc, item) => acc + parseNumeric(pickFirstDefined(item?.currentValue, item?.valorAtual, item?.totalAtual)), 0);

  const performance = parseNumeric(
    pickFirstDefined(
      snapshot?.performancePct,
      snapshot?.rentabilidadePct,
      snapshot?.returnPct
    )
  );

  const count = Number(
    pickFirstDefined(
      snapshot?.count,
      snapshot?.items,
      snapshot?.quantidade,
      items.length
    )
  ) || items.length;

  const sharePct = portfolioTotal > 0 ? (totalValue / portfolioTotal) * 100 : parseNumeric(snapshot?.participationPct);

  return {
    key: categoryKey,
    label: CATEGORY_META[categoryKey]?.label || categoryKey,
    totalValue,
    performance,
    sharePct,
    count
  };
}

function getTopItems(items, limit = 3) {
  return [...toArray(items)]
    .sort((left, right) => parseNumeric(pickFirstDefined(right?.currentValue, right?.valorAtual, right?.totalAtual)) - parseNumeric(pickFirstDefined(left?.currentValue, left?.valorAtual, left?.totalAtual)))
    .slice(0, limit);
}

function getScoreTone(scoreValue) {
  const score = parseNumeric(scoreValue);
  if (score >= 80) return 'success';
  if (score >= 60) return 'info';
  if (score >= 40) return 'warning';
  return 'danger';
}

function getStatusTone(text) {
  const normalized = normalizeString(text).toLowerCase();

  if (!normalized) return 'neutral';
  if (/(bom|alta|comprar|oportunidade|ok|equilibrad)/.test(normalized)) return 'success';
  if (/(atenc|moderad|revis|acompanhar)/.test(normalized)) return 'warning';
  if (/(risco|vender|reduzir|critico|fraco|ruim|perigo)/.test(normalized)) return 'danger';
  return 'info';
}

function getCategoryColor(categoryKey) {
  switch (categoryKey) {
    case 'actions':
      return 'var(--chart-actions)';
    case 'funds':
      return 'var(--chart-funds)';
    case 'pension':
      return 'var(--chart-pension)';
    default:
      return 'var(--brand-primary)';
  }
}

function renderBadge(label, tone = 'neutral', withDot = false) {
  const safeLabel = normalizeString(label);
  if (!safeLabel) return '';

  return `
    <span class="badge badge--${tone}">
      ${withDot ? '<span class="badge__dot" aria-hidden="true"></span>' : ''}
      ${safeLabel}
    </span>
  `;
}

function renderStatusLine(label, tone = 'neutral') {
  const safeLabel = normalizeString(label);
  if (!safeLabel) return '';

  return `
    <span class="status-line status-line--${tone}">
      <span class="status-line__dot" aria-hidden="true"></span>
      <span class="type-body-sm">${safeLabel}</span>
    </span>
  `;
}

function renderHero(appContext) {
  const { helpers, selectors } = appContext;
  const dashboard = selectors.getDashboard();
  const summary = getSummary(dashboard);
  const total = calculatePortfolioTotal(summary, dashboard);
  const invested = calculateInvestedTotal(summary, dashboard);
  const profitability = calculateProfitability(summary, dashboard);
  const score = getScoreValue(dashboard);
  const profile = getProfileLabel(dashboard);
  const decision = getDecisionLabel(dashboard);
  const mission = getMainMission(dashboard);
  const executiveMessage = getExecutiveMessage(dashboard);
  const opportunity = getOpportunityMessage(dashboard);
  const scoreTone = getScoreTone(score);

  return `
    <section class="page-hero page-section" aria-label="Resumo executivo da carteira">
      <div class="page-hero__primary">
        <article class="page-hero__summary card card--panel card--emphasis executive-card">
          <div class="page-hero__summary-top">
            <div class="executive-card__headline">
              <span class="type-kicker">Visao consolidada</span>
              <h1 class="type-heading-1">${helpers.escapeHtml(DEFAULT_HERO_TITLE)}</h1>
              <p class="type-body">${helpers.escapeHtml(executiveMessage || DEFAULT_HERO_SUBTITLE)}</p>
            </div>
            ${renderBadge(`Score ${score || '—'}`, scoreTone, true)}
          </div>

          <div class="page-hero__summary-body u-stack-md">
            <div>
              <span class="type-label">Patrimonio consolidado</span>
              <strong class="type-value-xl hide-value">${helpers.formatMoney(total)}</strong>
            </div>

            <div class="executive-card__metrics page-hero__stat-row">
              <article class="metric-card">
                <span class="type-label metric-card__label">Valor investido</span>
                <strong class="type-value-md metric-card__value hide-value">${helpers.formatMoney(invested)}</strong>
                <span class="type-body-sm metric-card__support">Base consolidada da carteira</span>
              </article>

              <article class="metric-card">
                <span class="type-label metric-card__label">Rentabilidade</span>
                <strong class="type-value-md metric-card__value ${profitability >= 0 ? 'u-text-success' : 'u-text-danger'}">${helpers.formatPercent(profitability)}</strong>
                <span class="type-body-sm metric-card__support">Leitura total da carteira</span>
              </article>

              <article class="metric-card">
                <span class="type-label metric-card__label">Perfil atual</span>
                <strong class="type-value-md metric-card__value">${helpers.escapeHtml(profile || 'Nao identificado')}</strong>
                <span class="type-body-sm metric-card__support">${helpers.escapeHtml(decision || 'Sem decisao consolidada')}</span>
              </article>
            </div>
          </div>

          <div class="page-hero__summary-foot">
            ${profile ? renderBadge(profile, 'neutral') : ''}
            ${decision ? renderBadge(decision, getStatusTone(decision)) : ''}
            <button class="button button--secondary button--sm" type="button" data-action="refresh-dashboard">Recarregar carteira</button>
            <button class="button button--ghost button--sm" type="button" data-action="refresh-actions">Atualizar acoes</button>
          </div>
        </article>
      </div>

      <div class="page-hero__secondary">
        <article class="page-hero__insight card card--panel insight-strip">
          <div class="insight-strip__main">
            <div class="summary-card__icon" aria-hidden="true">⚑</div>
            <div class="insight-strip__copy">
              <span class="type-label">Ponto de atencao</span>
              <strong class="type-body-strong">${helpers.escapeHtml(opportunity || 'Nenhum ponto critico destacado nesta leitura.')}</strong>
              <p class="type-body-sm">O dashboard prioriza clareza operacional, sem inventar regra paralela.</p>
            </div>
          </div>
          <div class="insight-strip__actions">
            <button class="button button--ia button--sm" type="button" data-action="request-ai-analysis">Atualizar Esquilo IA</button>
          </div>
        </article>

        <article class="page-hero__mission card card--ia">
          <span class="type-kicker">Missao do momento</span>
          <div class="u-stack-sm">
            <strong class="type-heading-3">${helpers.escapeHtml(mission.title)}</strong>
            <p class="type-body">${helpers.escapeHtml(mission.description || 'Sem missao principal consolidada para esta leitura.')}</p>
          </div>
          <div class="page-hero__mission-grid">
            <div class="inline-card__metric">
              <span class="type-label">Impacto</span>
              <strong class="type-body-strong">${helpers.escapeHtml(mission.impact || 'Ajuste tatico da carteira')}</strong>
            </div>
            <div class="inline-card__metric">
              <span class="type-label">Prioridade</span>
              <strong class="type-body-strong">${helpers.escapeHtml(mission.priority || 'Alta')}</strong>
            </div>
          </div>
        </article>
      </div>
    </section>
  `;
}

const DEFAULT_HERO_TITLE = 'Entenda o que voce tem, se faz sentido e o que vale revisar agora.';
const DEFAULT_HERO_SUBTITLE = 'O Esquilo consolida a carteira, traduz a leitura e aponta o que merece atencao sem ficar despejando ruido visual.';

function renderAllocationPanel(appContext) {
  const { helpers, selectors } = appContext;
  const dashboard = selectors.getDashboard();
  const summary = getSummary(dashboard);
  const total = calculatePortfolioTotal(summary, dashboard);
  const snapshots = getCategorySnapshots(dashboard);
  const actions = getActions(dashboard);
  const funds = getFunds(dashboard);
  const pension = getPension(dashboard);

  const categories = [
    deriveCategorySummary('actions', actions, snapshots.actions || snapshots.acoes, total),
    deriveCategorySummary('funds', funds, snapshots.funds || snapshots.fundos, total),
    deriveCategorySummary('pension', pension, snapshots.pension || snapshots.previdencia, total)
  ].filter((item) => item.totalValue > 0 || item.count > 0);

  const gradientStops = [];
  let accumulated = 0;

  categories.forEach((category) => {
    const percent = Math.max(0, category.sharePct || 0);
    const start = accumulated;
    const end = accumulated + percent;
    gradientStops.push(`${getCategoryColor(category.key)} ${start}% ${end}%`);
    accumulated = end;
  });

  const gradientCss = gradientStops.length > 0
    ? `conic-gradient(${gradientStops.join(', ')})`
    : 'conic-gradient(var(--surface-3) 0 100%)';

  const rows = categories.map((category) => `
    <article class="allocation-item">
      <span class="allocation-item__swatch" style="background:${getCategoryColor(category.key)}"></span>
      <div class="allocation-item__body">
        <strong class="type-body-strong">${helpers.escapeHtml(category.label)}</strong>
        <span class="type-body-sm">${category.count} ${category.count === 1 ? 'item' : 'itens'} mapeados</span>
      </div>
      <div class="allocation-item__stats">
        <strong class="type-body-strong hide-value">${helpers.formatMoney(category.totalValue)}</strong>
        <span class="type-body-sm">${helpers.formatPercent(category.sharePct, { rawPercent: false })}</span>
      </div>
    </article>
  `).join('');

  return `
    <article class="dashboard__allocation card card--panel">
      <div class="panel__header">
        <div class="panel__header-main">
          <span class="type-kicker">Macroclasses</span>
          <h2 class="type-heading-2">Leitura de alocacao</h2>
          <p class="type-body-sm">A carteira fecha em acoes, fundos e previdencia, evitando poluicao de leitura.</p>
        </div>
      </div>
      <div class="dashboard__allocation-body">
        <div class="dashboard__allocation-visual">
          <div class="allocation-chart" style="background:${gradientCss}">
            <div class="allocation-chart__center">
              <span class="type-label">Patrimonio</span>
              <strong class="type-value-md hide-value">${helpers.formatMoney(total)}</strong>
              <span class="type-body-sm">3 macroclasses consolidadas</span>
            </div>
          </div>
        </div>
        <div class="allocation-list dashboard__allocation-list">
          ${rows || `
            <div class="empty-state">
              <strong class="type-body-strong">Sem alocacao consolidada</strong>
              <p class="type-body-sm">A carteira ainda nao trouxe macroclasses suficientes para leitura comparativa.</p>
            </div>
          `}
        </div>
      </div>
    </article>
  `;
}

function renderInsightStrip(appContext) {
  const { helpers, selectors } = appContext;
  const dashboard = selectors.getDashboard();
  const summary = getSummary(dashboard);
  const total = calculatePortfolioTotal(summary, dashboard);
  const profitability = calculateProfitability(summary, dashboard);
  const decision = getDecisionLabel(dashboard);
  const profile = getProfileLabel(dashboard);

  return `
    <article class="dashboard__insight-strip card card--panel insight-strip">
      <div class="insight-strip__main">
        <div class="summary-card__icon" aria-hidden="true">✦</div>
        <div class="insight-strip__copy">
          <span class="type-label">Radar rapido</span>
          <strong class="type-body-strong">${helpers.escapeHtml(decision || 'Sem decisao principal travada')}</strong>
          <p class="type-body-sm">Patrimonio de ${helpers.formatMoney(total)} com perfil ${helpers.escapeHtml(profile || 'nao identificado')} e rentabilidade de ${helpers.formatPercent(profitability)}.</p>
        </div>
      </div>
      <div class="insight-strip__actions">
        ${decision ? renderBadge(decision, getStatusTone(decision)) : ''}
      </div>
    </article>
  `;
}

function renderSummaryCards(appContext) {
  const { helpers, selectors, store } = appContext;
  const dashboard = selectors.getDashboard();
  const summary = getSummary(dashboard);
  const total = calculatePortfolioTotal(summary, dashboard);
  const snapshots = getCategorySnapshots(dashboard);
  const ui = store.getState().ui;

  const categories = [
    deriveCategorySummary('actions', getActions(dashboard), snapshots.actions || snapshots.acoes, total),
    deriveCategorySummary('funds', getFunds(dashboard), snapshots.funds || snapshots.fundos, total),
    deriveCategorySummary('pension', getPension(dashboard), snapshots.pension || snapshots.previdencia, total)
  ];

  const cards = categories.map((category) => {
    const items = category.key === 'actions'
      ? getActions(dashboard)
      : category.key === 'funds'
        ? getFunds(dashboard)
        : getPension(dashboard);
    const topItems = getTopItems(items, 3);
    const isExpanded = Boolean(ui.expandedBlocks[category.key]);

    const rows = topItems.map((item) => {
      const ticker = deriveTicker(item);
      const value = parseNumeric(pickFirstDefined(item?.currentValue, item?.valorAtual, item?.totalAtual));
      const recommendation = deriveRecommendation(item);

      return `
        <div class="summary-card__panel-row">
          <div class="u-stack-xs">
            <strong class="type-body-strong">${helpers.escapeHtml(ticker || 'Item sem nome')}</strong>
            <span class="type-body-sm">${helpers.escapeHtml(recommendation || 'Sem recomendacao especifica')}</span>
          </div>
          <strong class="type-body-strong hide-value">${helpers.formatMoney(value)}</strong>
        </div>
      `;
    }).join('');

    return `
      <article class="summary-card summary-card--${category.key} ${isExpanded ? 'is-active' : ''}" data-block="${category.key}">
        <header class="summary-card__header">
          <div class="summary-card__header-main">
            <div class="summary-card__icon" aria-hidden="true">${category.key === 'actions' ? '↗' : category.key === 'funds' ? '◌' : '◎'}</div>
            <div class="summary-card__header-copy">
              <span class="type-label">${helpers.escapeHtml(category.label)}</span>
              <strong class="type-value-lg hide-value">${helpers.formatMoney(category.totalValue)}</strong>
              <div class="summary-card__meta-row">
                ${renderBadge(`${category.count} ${category.count === 1 ? 'item' : 'itens'}`, 'neutral')}
                ${renderBadge(helpers.formatPercent(category.sharePct, { rawPercent: false }), 'info')}
                ${renderBadge(helpers.formatPercent(category.performance), category.performance >= 0 ? 'success' : 'danger')}
              </div>
            </div>
          </div>
          <div class="summary-card__tools">
            <button class="button-icon ${isExpanded ? 'button-icon--active' : ''}" type="button" data-action="toggle-block" data-block-name="${category.key}" aria-label="Expandir ${helpers.escapeHtml(category.label)}">
              <span aria-hidden="true">${isExpanded ? '−' : '+'}</span>
            </button>
          </div>
        </header>

        <div class="summary-card__body ${isExpanded ? 'summary-card__body--split' : ''}">
          <div class="summary-card__panel">
            <span class="type-label">Leitura rapida</span>
            <p class="summary-card__summary">${helpers.escapeHtml(category.count > 0 ? `${category.label} representam ${helpers.formatPercent(category.sharePct, { rawPercent: false })} da carteira e carregam ${helpers.formatPercent(category.performance)} de performance no recorte atual.` : `${category.label} ainda nao possuem volume suficiente para leitura consolidada.`)}</p>
          </div>
          ${isExpanded ? `<div class="summary-card__panel">${rows || '<p class="type-body-sm">Sem itens suficientes para destacar.</p>'}</div>` : ''}
        </div>
      </article>
    `;
  }).join('');

  return cards;
}

function buildCategoryTabs(currentCategory) {
  return Object.entries(CATEGORY_META).map(([key, meta]) => `
    <button
      class="button ${currentCategory === key ? 'button--primary' : 'button--secondary'} button--sm"
      type="button"
      data-action="select-category"
      data-category="${key}"
      aria-pressed="${String(currentCategory === key)}"
    >
      ${meta.label}
    </button>
  `).join('');
}

function renderActionsPanel(appContext) {
  const { helpers, selectors, store } = appContext;
  const dashboard = selectors.getDashboard();
  const filteredActions = selectors.getFilteredActions();
  const filters = store.getState().ui.filters;
  const expanded = Boolean(store.getState().ui.expandedBlocks.actions);
  const actions = getActions(dashboard);

  const rows = filteredActions.map((item) => {
    const itemId = deriveItemId(item, 'actions');
    const ticker = deriveTicker(item);
    const institution = normalizeString(pickFirstDefined(item?.instituicao, item?.platform, item?.corretora, item?.broker));
    const currentValue = parseNumeric(pickFirstDefined(item?.currentValue, item?.valorAtual, item?.totalAtual));
    const avgPrice = parseNumeric(pickFirstDefined(item?.averagePrice, item?.precoMedio, item?.priceAvg));
    const currentPrice = parseNumeric(pickFirstDefined(item?.currentPrice, item?.cotacaoAtual, item?.price));
    const quantity = parseNumeric(pickFirstDefined(item?.quantity, item?.quantidade));
    const status = deriveItemStatus(item);
    const recommendation = deriveRecommendation(item);
    const detailOpen = store.getState().ui.selectedAssetId === itemId;

    return `
      <tbody>
        <tr class="table-row--interactive ${detailOpen ? 'is-active' : ''}">
          <td>
            <div class="table-row__entity">
              <button class="button-icon ${detailOpen ? 'button-icon--active' : ''}" type="button" data-action="toggle-asset-detail" data-asset-id="${helpers.escapeHtml(itemId)}" aria-label="Expandir ${helpers.escapeHtml(ticker)}">
                <span aria-hidden="true">${detailOpen ? '−' : '+'}</span>
              </button>
              <div class="table-row__entity-copy">
                <strong class="type-body-strong">${helpers.escapeHtml(ticker || 'Ativo sem ticker')}</strong>
                <span class="type-body-sm">${helpers.escapeHtml(institution || 'Instituicao nao informada')}</span>
              </div>
            </div>
          </td>
          <td><span class="type-body-sm">${helpers.escapeHtml(recommendation || 'Sem recomendacao')}</span></td>
          <td><span class="type-body-sm">${helpers.escapeHtml(status || 'Sem status')}</span></td>
          <td><span class="type-body-sm hide-value">${quantity || '—'}</span></td>
          <td><span class="type-body-sm hide-value">${avgPrice ? helpers.formatMoney(avgPrice) : '—'}</span></td>
          <td><span class="type-body-sm hide-value">${currentPrice ? helpers.formatMoney(currentPrice) : '—'}</span></td>
          <td><strong class="type-body-strong hide-value">${helpers.formatMoney(currentValue)}</strong></td>
          <td>
            <button class="button button--ghost button--sm" type="button" data-action="open-asset-modal" data-asset-id="${helpers.escapeHtml(itemId)}">Detalhe</button>
          </td>
        </tr>
        ${detailOpen ? `
          <tr class="table-row__detail">
            <td colspan="8">
              <div class="table-row__detail-shell">
                <div class="table-row__detail-grid">
                  <div class="table-row__detail-item">
                    <span class="type-label table-row__detail-label">Score</span>
                    <strong class="type-body-strong table-row__detail-value">${helpers.escapeHtml(String(pickFirstDefined(item?.score, item?.priorityScore, '—')))}</strong>
                  </div>
                  <div class="table-row__detail-item">
                    <span class="type-label table-row__detail-label">Rentabilidade</span>
                    <strong class="type-body-strong table-row__detail-value">${helpers.formatPercent(pickFirstDefined(item?.returnPct, item?.rentabilidadePct, item?.performancePct))}</strong>
                  </div>
                  <div class="table-row__detail-item">
                    <span class="type-label table-row__detail-label">Stop</span>
                    <strong class="type-body-strong table-row__detail-value">${helpers.escapeHtml(String(pickFirstDefined(item?.stop, item?.stopPrice, '—')))}</strong>
                  </div>
                  <div class="table-row__detail-item">
                    <span class="type-label table-row__detail-label">Resumo</span>
                    <strong class="type-body-strong table-row__detail-value">${helpers.escapeHtml(normalizeString(pickFirstDefined(item?.rationale, item?.motivo, item?.insight)) || 'Sem racional detalhado.')}</strong>
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
    <section class="panel surface-panel" data-loading-block>
      <div class="panel__header">
        <div class="panel__header-main">
          <span class="type-kicker">Acoes</span>
          <h2 class="type-heading-2">Leitura operacional detalhada</h2>
          <p class="type-body-sm">Atualizacao parcial sem reload global, preservando scroll, filtros e estado expandido.</p>
        </div>
        <div class="panel__header-actions">
          ${renderBadge(`${actions.length} ativos`, 'neutral')}
          <button class="button ${expanded ? 'button--secondary' : 'button--ghost'} button--sm" type="button" data-action="toggle-block" data-block-name="actions">${expanded ? 'Ocultar extra' : 'Expandir'}</button>
        </div>
      </div>

      <div class="panel__body">
        <div class="u-cluster">
          ${buildCategoryTabs(store.getState().ui.selectedCategory)}
          <div class="search-field" style="min-width:16rem; flex:1 1 16rem;">
            <span class="search-field__icon" aria-hidden="true">⌕</span>
            <input class="input search-field__input" type="search" placeholder="Buscar ticker ou instituicao" data-filter="table-search" value="${helpers.escapeHtml(filters.tableSearch || '')}" />
          </div>
          <select class="filter-select" data-filter="recommendation">
            ${buildSelectOptions(filters.recommendation, [
              ['all', 'Recomendacao'],
              ['comprar', 'Comprar'],
              ['manter', 'Manter'],
              ['reduzir', 'Reduzir'],
              ['vender', 'Vender']
            ])}
          </select>
          <select class="filter-select" data-filter="status">
            ${buildSelectOptions(filters.status, [
              ['all', 'Status'],
              ['bom', 'Bom'],
              ['atencao', 'Atencao'],
              ['risco', 'Risco']
            ])}
          </select>
          <select class="filter-select" data-filter="sort-by">
            ${buildSelectOptions(filters.sortBy, [
              ['priority', 'Prioridade'],
              ['performance', 'Performance'],
              ['value', 'Valor'],
              ['name', 'Nome']
            ])}
          </select>
          <select class="filter-select" data-filter="sort-direction">
            ${buildSelectOptions(filters.sortDirection, [
              ['desc', 'Maior primeiro'],
              ['asc', 'Menor primeiro']
            ])}
          </select>
          <button class="button button--ghost button--sm" type="button" data-action="reset-filters">Limpar filtros</button>
        </div>

        <div class="table-shell">
          <div class="table-shell__scroll u-scroll-x">
            <table class="data-table">
              <thead>
                <tr>
                  <th>Ativo</th>
                  <th>Recomendacao</th>
                  <th>Status</th>
                  <th>Qtd</th>
                  <th>Preco medio</th>
                  <th>Cotacao</th>
                  <th>Valor atual</th>
                  <th></th>
                </tr>
              </thead>
              ${rows || `
                <tbody>
                  <tr>
                    <td colspan="8">
                      <div class="empty-state">
                        <strong class="type-body-strong">Nenhuma acao encontrada</strong>
                        <p class="type-body-sm">Ajuste os filtros ou confira se a carteira trouxe a categoria de acoes.</p>
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

function buildSelectOptions(currentValue, options) {
  return toArray(options).map(([value, label]) => `
    <option value="${value}" ${String(currentValue) === String(value) ? 'selected' : ''}>${label}</option>
  `).join('');
}

function renderComparisonPanel(appContext, categoryKey) {
  const { helpers, selectors, store } = appContext;
  const dashboard = selectors.getDashboard();
  const items = categoryKey === 'funds' ? getFunds(dashboard) : getPension(dashboard);
  const expanded = Boolean(store.getState().ui.expandedBlocks[categoryKey]);
  const title = categoryKey === 'funds' ? 'Fundos de investimento' : 'Previdencia';
  const kicker = categoryKey === 'funds' ? 'Fundos' : 'Previdencia';

  const rows = items.map((item) => {
    const name = normalizeString(pickFirstDefined(item?.nome, item?.name, item?.fundo, item?.plano)) || 'Item sem nome';
    const platform = normalizeString(pickFirstDefined(item?.platform, item?.plataforma, item?.instituicao));
    const invested = parseNumeric(pickFirstDefined(item?.investedValue, item?.valorInvestido, item?.totalAportado));
    const currentValue = parseNumeric(pickFirstDefined(item?.currentValue, item?.valorAtual, item?.totalAtual));
    const performance = parseNumeric(pickFirstDefined(item?.returnPct, item?.rentabilidadePct, item?.performancePct));
    const recommendation = deriveRecommendation(item);

    return `
      <tr class="table-row--interactive">
        <td>
          <div class="table-row__entity-copy">
            <strong class="type-body-strong">${helpers.escapeHtml(name)}</strong>
            <span class="type-body-sm">${helpers.escapeHtml(platform || 'Plataforma nao informada')}</span>
          </div>
        </td>
        <td><span class="type-body-sm hide-value">${helpers.formatMoney(invested)}</span></td>
        <td><strong class="type-body-strong hide-value">${helpers.formatMoney(currentValue)}</strong></td>
        <td><span class="type-body-sm ${performance >= 0 ? 'u-text-success' : 'u-text-danger'}">${helpers.formatPercent(performance)}</span></td>
        <td><span class="type-body-sm">${helpers.escapeHtml(recommendation || 'Sem leitura adicional')}</span></td>
      </tr>
    `;
  }).join('');

  return `
    <section class="panel surface-panel" data-loading-block>
      <div class="panel__header">
        <div class="panel__header-main">
          <span class="type-kicker">${kicker}</span>
          <h2 class="type-heading-2">${title}</h2>
          <p class="type-body-sm">Comparativo direto, sem excesso de ornamento e com foco no que esta carregando peso real na carteira.</p>
        </div>
        <div class="panel__header-actions">
          ${renderBadge(`${items.length} registros`, 'neutral')}
          <button class="button ${expanded ? 'button--secondary' : 'button--ghost'} button--sm" type="button" data-action="toggle-block" data-block-name="${categoryKey}">${expanded ? 'Ocultar extra' : 'Expandir'}</button>
        </div>
      </div>

      <div class="panel__body">
        <div class="table-shell__scroll u-scroll-x">
          <table class="data-table">
            <thead>
              <tr>
                <th>${categoryKey === 'funds' ? 'Fundo' : 'Plano'}</th>
                <th>Investido</th>
                <th>Atual</th>
                <th>Rentabilidade</th>
                <th>Leitura</th>
              </tr>
            </thead>
            <tbody>
              ${rows || `
                <tr>
                  <td colspan="5">
                    <div class="empty-state">
                      <strong class="type-body-strong">Sem ${kicker.toLowerCase()} nesta leitura</strong>
                      <p class="type-body-sm">O payload nao trouxe itens suficientes para o comparativo.</p>
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
  const { helpers, selectors } = appContext;
  const dashboard = selectors.getDashboard();
  const summary = getSummary(dashboard);
  const score = getScoreValue(dashboard);
  const profile = getProfileLabel(dashboard);
  const decision = getDecisionLabel(dashboard);
  const actionPlan = getActionPlan(dashboard);
  const alerts = getAlerts(dashboard).slice(0, 4);
  const orders = getOrders(dashboard);
  const buyOrders = toArray(pickFirstDefined(orders.buy, orders.compra, orders.items)).slice(0, 2);
  const sellOrders = toArray(pickFirstDefined(orders.sell, orders.venda)).slice(0, 2);

  const orderCards = [...buyOrders.map((item) => ({ ...item, tone: 'buy' })), ...sellOrders.map((item) => ({ ...item, tone: 'sell' }))]
    .slice(0, 4)
    .map((item) => {
      const ticker = deriveTicker(item);
      const price = parseNumeric(pickFirstDefined(item?.targetPrice, item?.precoAlvo, item?.price));
      const quantity = parseNumeric(pickFirstDefined(item?.quantity, item?.quantidade));

      return `
        <article class="order-card order-card--${item.tone}">
          <div class="order-card__row">
            <strong class="type-body-strong">${helpers.escapeHtml(ticker || 'Pre-ordem')}</strong>
            ${renderBadge(item.tone === 'buy' ? 'Compra' : 'Venda', item.tone === 'buy' ? 'warning' : 'danger')}
          </div>
          <span class="type-body-sm">Qtd ${quantity || '—'} • Alvo ${price ? helpers.formatMoney(price) : '—'}</span>
        </article>
      `;
    }).join('');

  const alertCards = alerts.map((alertItem) => {
    const text = typeof alertItem === 'string'
      ? alertItem
      : normalizeString(pickFirstDefined(alertItem?.message, alertItem?.mensagem, alertItem?.title, alertItem?.titulo));
    const tone = getStatusTone(text);

    return `
      <div class="alert-state alert-state--${tone === 'neutral' ? 'warning' : tone}">
        <strong class="alert-state__title type-body-strong">${helpers.escapeHtml(text || 'Sem descricao do alerta')}</strong>
      </div>
    `;
  }).join('');

  return `
    <div class="dashboard__aside-sticky">
      <section class="sidebar-card card card--panel">
        <div class="card__header-main">
          <span class="type-kicker">Radar</span>
          <h2 class="type-heading-3">Score e coerencia da carteira</h2>
        </div>
        <div class="sidebar-card__metric-grid">
          <div class="inline-card__metric">
            <span class="type-label">Score</span>
            <strong class="type-value-md">${helpers.escapeHtml(String(score || '—'))}</strong>
          </div>
          <div class="inline-card__metric">
            <span class="type-label">Perfil</span>
            <strong class="type-body-strong">${helpers.escapeHtml(profile || 'Nao identificado')}</strong>
          </div>
        </div>
        ${decision ? renderStatusLine(decision, getStatusTone(decision)) : ''}
        <p class="type-body-sm">Patrimonio atual em ${helpers.formatMoney(calculatePortfolioTotal(summary, dashboard))} com leitura de risco baseada no mesmo backend do produto.</p>
      </section>

      <section class="sidebar-card card card--panel">
        <div class="card__header-main">
          <span class="type-kicker">Plano de acao</span>
          <h2 class="type-heading-3">Proxima jogada</h2>
        </div>
        <p class="type-body">${helpers.escapeHtml(normalizeString(pickFirstDefined(actionPlan?.reason, actionPlan?.motivo, actionPlan?.description, actionPlan?.descricao)) || 'Nenhuma acao principal foi consolidada nesta rodada.')}</p>
        ${actionPlan ? `
          <div class="u-stack-sm">
            ${actionPlan?.priority ? renderBadge(actionPlan.priority, 'warning') : ''}
            ${actionPlan?.impact ? renderBadge(actionPlan.impact, 'info') : ''}
          </div>
        ` : ''}
      </section>

      <section class="sidebar-card card card--panel">
        <div class="card__header-main">
          <span class="type-kicker">Alertas</span>
          <h2 class="type-heading-3">Sinais que merecem atencao</h2>
        </div>
        <div class="sidebar-card__group">
          ${alertCards || `
            <div class="helper-state">
              <p class="type-body-sm">Sem alertas relevantes nesta leitura.</p>
            </div>
          `}
        </div>
      </section>

      <section class="sidebar-card card card--panel">
        <div class="card__header-main">
          <span class="type-kicker">Pre-ordens</span>
          <h2 class="type-heading-3">Apoio tatico</h2>
        </div>
        <div class="order-stack">
          ${orderCards || `
            <div class="helper-state">
              <p class="type-body-sm">Nenhuma pre-ordem relevante mapeada para esta leitura.</p>
            </div>
          `}
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
            <span class="type-kicker">Esquilo IA</span>
            <h2 class="type-heading-3">Leitura assistida da carteira</h2>
          </div>
        </div>
        <button class="button button--ia button--sm" type="button" data-action="request-ai-analysis">${isLoading ? 'Gerando...' : 'Atualizar leitura'}</button>
      </div>
      <div class="ai-panel__response ${isLoading ? 'is-loading-skeleton' : ''}">
        ${helpers.escapeHtml(analysis || 'A leitura assistida ainda nao foi solicitada nesta sessao. O frontend esta pronto para consumi-la pelo mesmo endpoint HTTP do backend atual.')}
      </div>
      <div class="ai-panel__status type-body-sm">Sem regra paralela. A IA consome o mesmo contexto consolidado do dashboard.</div>
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

function syncDashboardUiState(appContext) {
  const { dom, store } = appContext;
  if (!dom.root) return;

  const state = store.getState();
  dom.root.classList.toggle('dashboard-loading', Boolean(state.ui.isLoading));

  dom.root.querySelectorAll(DASHBOARD_SELECTORS.categoryTabs).forEach((button) => {
    const isActive = button.dataset.category === state.ui.selectedCategory;
    button.classList.toggle('button--primary', isActive);
    button.classList.toggle('button--secondary', !isActive);
    button.setAttribute('aria-pressed', String(isActive));
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

function rerenderDashboard(appContext) {
  const { dom } = appContext;
  if (!dom.root) return;

  const heroNode = dom.root.querySelector(DASHBOARD_SELECTORS.hero);
  const allocationNode = dom.root.querySelector('[data-region="allocation-panel"]');
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
  if (fundsNode) fundsNode.innerHTML = renderComparisonPanel(appContext, 'funds');
  if (pensionNode) pensionNode.innerHTML = renderComparisonPanel(appContext, 'pension');
  if (sidebarNode) sidebarNode.innerHTML = renderSidebar(appContext);
  if (aiNode) aiNode.innerHTML = renderAiPanel(appContext);
}

function findAssetById(dashboard, assetId) {
  const allItems = [
    ...getActions(dashboard),
    ...getFunds(dashboard),
    ...getPension(dashboard)
  ];

  return allItems.find((item) => deriveItemId(item) === assetId) || null;
}

function bindDashboardEvents(appContext) {
  const { dom, store, actions } = appContext;
  if (!dom.root) return;

  dom.root.addEventListener('click', (event) => {
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

    if (button.matches(DASHBOARD_SELECTORS.toggleBlock)) {
      const blockName = button.dataset.blockName;
      store.toggleExpandedBlock(blockName, undefined, { source: 'dashboard-ui' });
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
      const asset = findAssetById(appContext.selectors.getDashboard(), assetId);
      if (asset) {
        store.openModal('asset-detail', asset, { source: 'dashboard-ui' });
      }
      return;
    }

    if (button.matches(DASHBOARD_SELECTORS.requestAi)) {
      actions.refreshAiAnalysis({ silent: false });
      return;
    }

    if (button.matches(DASHBOARD_SELECTORS.openGenericModal)) {
      store.openModal('generic-content', {
        title: normalizeString(button.dataset.modalTitle) || 'Detalhe',
        bodyHtml: normalizeString(button.dataset.modalHtml)
      }, { source: 'dashboard-ui' });
    }
  });

  dom.root.addEventListener('input', (event) => {
    const target = event.target;
    if (!(target instanceof HTMLInputElement || target instanceof HTMLSelectElement)) return;

    if (target.matches(DASHBOARD_SELECTORS.filterInput)) {
      store.setFilters({ tableSearch: target.value }, { source: 'dashboard-ui' });
      rerenderDashboard(appContext);
      syncDashboardUiState(appContext);
    }
  });

  dom.root.addEventListener('change', (event) => {
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

    unsubscribe = appContext.store.subscribe(() => {
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
    rerender: () => rerenderDashboard(appContext)
  };
}

export {
  CATEGORY_META,
  DASHBOARD_SELECTORS,
  createDashboardController,
  renderDashboardShell,
  syncDashboardUiState
};
