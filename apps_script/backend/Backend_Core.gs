/**
 * BACKEND CORE
 * Orquestracao principal do backend para Google Apps Script.
 * Esta base abre explicitamente a planilha operacional por ID.
 */

function doGet() {
  return HtmlService.createTemplateFromFile(APP_CONFIG_.templateName)
    .evaluate()
    .setTitle('Esquilo Invest - Base Operacional')
    .addMetaTag('viewport', 'width=device-width, initial-scale=1')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
}

/**
 * Orquestra a carga completa do dashboard.
 * Entrada: nenhuma.
 * Saida: payload compatível com o frontend atual, sem alterar os contratos existentes.
 */
function getDashboardData() {
  const dashboardContext = buildDashboardContext_();
  return buildDashboardPayload_(dashboardContext.domainData, dashboardContext.insights);
}

/**
 * Contexto unico para calculos e payloads do dashboard.
 * Reaproveitado por dashboard, leitura auxiliar e builders de IA.
 */
function buildDashboardContext_() {
  const spreadsheetContext = getSpreadsheetContext_();
  const domainData = collectDashboardDomainData_(spreadsheetContext);
  const insights = buildDashboardInsights_(domainData);

  return {
    spreadsheet: spreadsheetContext.spreadsheet,
    sheets: spreadsheetContext.sheets,
    domainData,
    insights
  };
}

function getSpreadsheetContext_() {
  const spreadsheet = openOperationalSpreadsheet_();

  return {
    spreadsheet,
    sheets: {
      actions: spreadsheet.getSheetByName(APP_CONFIG_.sheetNames.actions),
      preOrders: spreadsheet.getSheetByName(APP_CONFIG_.sheetNames.preOrders),
      funds: spreadsheet.getSheetByName(APP_CONFIG_.sheetNames.funds),
      previdencia: spreadsheet.getSheetByName(APP_CONFIG_.sheetNames.previdencia),
      aportes: spreadsheet.getSheetByName(APP_CONFIG_.sheetNames.aportes),
      config: spreadsheet.getSheetByName(APP_CONFIG_.sheetNames.config),
      dashboardVisual: spreadsheet.getSheetByName(APP_CONFIG_.sheetNames.dashboardVisual),
      exportAuxiliar: spreadsheet.getSheetByName(APP_CONFIG_.sheetNames.exportAuxiliar)
    }
  };
}

/**
 * Coleta os blocos de dados brutos consumidos pelo dashboard.
 * Mantem leitura de planilha separada das transformacoes e recomendacoes.
 */
function collectDashboardDomainData_(spreadsheetContext) {
  const rawData = readSpreadsheetData_(spreadsheetContext);
  const mappedActions = mapStocks_(rawData.actions);
  const actions = enrichActionsWithMarketData_(
    mappedActions,
    safeGetActionMarketData_(mappedActions, spreadsheetContext.spreadsheet)
  );
  const investments = mapFunds_(rawData.funds, spreadsheetContext.spreadsheet, spreadsheetContext.sheets.funds);
  const previdencias = mapPension_(rawData.previdencia, spreadsheetContext.spreadsheet, spreadsheetContext.sheets.previdencia);
  const preOrders = mapPreOrders_(rawData.preOrders);

  return {
    summary: buildPortfolioSummaryFromDomains_(actions, investments, previdencias, preOrders),
    actions: actions,
    preOrders: preOrders,
    fundosTop: buildFundsTopFromMappedItems_(investments),
    investments: investments,
    previdencias: previdencias,
    previdenciaInfo: buildPrevidenciaInfoFromMappedItems_(previdencias),
    tip: ''
  };
}

/**
 * Calcula blocos analiticos do dashboard sem misturar leitura de planilha com payload final.
 */
function buildDashboardInsights_(domainData) {
  const engine = buildPortfolioDecisionEngine_(domainData);
  const alert = getPrimaryAlert_(engine.alerts);
  const orders = buildOrdersPayload_(domainData.actions, domainData.preOrders);
  const messaging = buildPortfolioMessagingFromEngine_(engine);
  const actionPlan = getActionPlan_(engine);
  const spreadsheet = openOperationalSpreadsheet_();
  const decisionHistory = buildDecisionHistory_(spreadsheet, domainData.actions, engine, actionPlan);
  const intelligentAlerts = buildIntelligentAlerts_(engine, actionPlan, decisionHistory);

  return {
    alerts: engine.alerts,
    alert,
    orders,
    metrics: engine.metrics,
    score: engine.score,
    profile: engine.profile,
    generalAdvice: engine.generalAdvice,
    messaging: messaging,
    actionPlan: actionPlan,
    decisionHistory: decisionHistory,
    intelligentAlerts: intelligentAlerts,
    assetRanking: engine.assetRanking,
    decisionEngine: engine
  };
}

function buildDashboardPayload_(domainData, insights) {
  return {
    summary: domainData.summary,
    actions: domainData.actions,
    alert: insights.alert,
    alerts: insights.alerts,
    orders: insights.orders,
    fundosTop: domainData.fundosTop,
    investments: domainData.investments,
    previdencias: domainData.previdencias,
    previdenciaInfo: domainData.previdenciaInfo,
    tip: domainData.tip,
    profile: insights.profile,
    score: insights.score,
    generalAdvice: insights.generalAdvice,
    messaging: insights.messaging,
    actionPlan: insights.actionPlan,
    decisionHistory: insights.decisionHistory,
    intelligentAlerts: insights.intelligentAlerts,
    assetRanking: insights.assetRanking,
    categories: insights.decisionEngine ? insights.decisionEngine.categories : {},
    portfolioDecision: insights.decisionEngine ? insights.decisionEngine.portfolioDecision : {}
  };
}

