import { esquiloApi } from './api.js';
import { dashboardSelectors, dashboardStore } from './state.js';
import {
  createDashboardController,
  renderDashboardShell,
  syncDashboardUiState
} from './dashboard.js';

/*
  Esquilo Invest - app bootstrap

  Responsabilidades:
  - bootstrap da aplicacao
  - conexao entre API, store e controller de dashboard
  - helpers globais reutilizaveis
  - binding de eventos compartilhados
  - sincronizacao de estado base com o DOM
*/

const APP_SELECTORS = Object.freeze({
  root: '[data-app-root]',
  body: 'body',
  pageTitle: '[data-role="page-title"]',
  pageSubtitle: '[data-role="page-subtitle"]',
  dataSource: '[data-role="data-source"]',
  updatedAt: '[data-role="updated-at"]',
  version: '[data-role="app-version"]',
  warning: '[data-role="global-warning"]',
  error: '[data-role="global-error"]',
  toast: '[data-role="toast"]',
  toastTitle: '[data-role="toast-title"]',
  toastMessage: '[data-role="toast-message"]',
  toastClose: '[data-action="toast-close"]',
  modalOverlay: '[data-role="modal-overlay"]',
  modalTitle: '[data-role="modal-title"]',
  modalBody: '[data-role="modal-body"]',
  modalClose: '[data-action="modal-close"]',
  ghostToggle: '[data-action="toggle-ghost-mode"]',
  refreshDashboard: '[data-action="refresh-dashboard"]',
  refreshActions: '[data-action="refresh-actions"]',
  refreshAi: '[data-action="refresh-ai"]'
});

const DEFAULT_TEXT = Object.freeze({
  pageTitle: 'Esquilo Invest',
  pageSubtitle: 'Clareza sobre o que voce tem, se faz sentido e o que vale revisar agora.',
  updatedAtFallback: 'Aguardando leitura operacional',
  dataSourceFallback: 'Fonte nao identificada',
  genericError: 'Nao foi possivel carregar a carteira agora.',
  genericWarning: 'Alguns dados podem estar desatualizados.',
  loadingAi: 'Gerando leitura da Esquilo IA...'
});

const APP_FORMATTER_LOCALE = 'pt-BR';
const APP_TIMEZONE = 'America/Sao_Paulo';
const TOAST_DEFAULT_TIMEOUT_MS = 4000;

function normalizeString(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function isPlainObject(value) {
  return Object.prototype.toString.call(value) === '[object Object]';
}

function isFiniteNumber(value) {
  return typeof value === 'number' && Number.isFinite(value);
}

function toArray(value) {
  return Array.isArray(value) ? value : [];
}

function parseNumeric(value) {
  if (isFiniteNumber(value)) return value;

  if (typeof value === 'string') {
    const normalized = Number(value.replace(/\s/g, '').replace(/\./g, '').replace(',', '.').replace(/[^0-9.-]/g, ''));
    return Number.isFinite(normalized) ? normalized : 0;
  }

  return 0;
}

function escapeHtml(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function formatMoney(value, options = {}) {
  const amount = parseNumeric(value);
  return new Intl.NumberFormat(APP_FORMATTER_LOCALE, {
    style: 'currency',
    currency: options.currency || 'BRL',
    maximumFractionDigits: options.maximumFractionDigits ?? 2,
    minimumFractionDigits: options.minimumFractionDigits ?? 2
  }).format(amount);
}

function formatPercent(value, options = {}) {
  const amount = parseNumeric(value);
  const normalized = Math.abs(amount) > 1 && options.rawPercent !== false ? amount / 100 : amount;

  return new Intl.NumberFormat(APP_FORMATTER_LOCALE, {
    style: 'percent',
    maximumFractionDigits: options.maximumFractionDigits ?? 2,
    minimumFractionDigits: options.minimumFractionDigits ?? 0
  }).format(normalized);
}

function formatCompactNumber(value) {
  const amount = parseNumeric(value);
  return new Intl.NumberFormat(APP_FORMATTER_LOCALE, {
    notation: 'compact',
    maximumFractionDigits: 1
  }).format(amount);
}

function formatDateTime(value) {
  const raw = normalizeString(value);
  if (!raw) return DEFAULT_TEXT.updatedAtFallback;

  const date = new Date(raw);
  if (Number.isNaN(date.getTime())) return raw;

  return new Intl.DateTimeFormat(APP_FORMATTER_LOCALE, {
    dateStyle: 'short',
    timeStyle: 'short',
    timeZone: APP_TIMEZONE
  }).format(date);
}

function formatDataSourceLabel(value) {
  const source = normalizeString(value).toLowerCase();

  if (!source) return DEFAULT_TEXT.dataSourceFallback;
  if (source === 'bigquery') return 'BigQuery';
  if (source === 'spreadsheet-fallback') return 'Planilha de contingencia';
  if (source === 'spreadsheet') return 'Planilha operacional';
  return source.replace(/[-_]/g, ' ');
}

function createDomCache(root = document) {
  return {
    root: root.querySelector(APP_SELECTORS.root),
    body: document.querySelector(APP_SELECTORS.body),
    pageTitle: root.querySelector(APP_SELECTORS.pageTitle),
    pageSubtitle: root.querySelector(APP_SELECTORS.pageSubtitle),
    dataSource: root.querySelector(APP_SELECTORS.dataSource),
    updatedAt: root.querySelector(APP_SELECTORS.updatedAt),
    version: root.querySelector(APP_SELECTORS.version),
    warning: root.querySelector(APP_SELECTORS.warning),
    error: root.querySelector(APP_SELECTORS.error),
    toast: root.querySelector(APP_SELECTORS.toast),
    toastTitle: root.querySelector(APP_SELECTORS.toastTitle),
    toastMessage: root.querySelector(APP_SELECTORS.toastMessage),
    toastClose: root.querySelector(APP_SELECTORS.toastClose),
    modalOverlay: root.querySelector(APP_SELECTORS.modalOverlay),
    modalTitle: root.querySelector(APP_SELECTORS.modalTitle),
    modalBody: root.querySelector(APP_SELECTORS.modalBody),
    modalCloseButtons: Array.from(root.querySelectorAll(APP_SELECTORS.modalClose)),
    ghostToggles: Array.from(root.querySelectorAll(APP_SELECTORS.ghostToggle)),
    refreshDashboardButtons: Array.from(root.querySelectorAll(APP_SELECTORS.refreshDashboard)),
    refreshActionsButtons: Array.from(root.querySelectorAll(APP_SELECTORS.refreshActions)),
    refreshAiButtons: Array.from(root.querySelectorAll(APP_SELECTORS.refreshAi))
  };
}

function setText(node, value) {
  if (!node) return;
  node.textContent = value;
}

function setHtml(node, value) {
  if (!node) return;
  node.innerHTML = value;
}

function setHidden(node, isHidden) {
  if (!node) return;
  node.hidden = Boolean(isHidden);
}

function setPressedState(nodes, value) {
  toArray(nodes).forEach((node) => {
    node.setAttribute('aria-pressed', String(Boolean(value)));
    node.classList.toggle('button-icon--active', Boolean(value));
  });
}

function setDisabledState(nodes, value) {
  toArray(nodes).forEach((node) => {
    node.disabled = Boolean(value);
    node.setAttribute('aria-disabled', String(Boolean(value)));
  });
}

function createAppHelpers() {
  return {
    escapeHtml,
    formatMoney,
    formatPercent,
    formatCompactNumber,
    formatDateTime,
    formatDataSourceLabel,
    normalizeString,
    parseNumeric,
    toArray
  };
}

function createToastManager(store, dom) {
  let timerId = null;

  function clearTimer() {
    if (!timerId) return;
    window.clearTimeout(timerId);
    timerId = null;
  }

  function dismiss(meta = {}) {
    clearTimer();
    store.setToast(null, {
      source: 'toast-manager',
      ...meta
    });
  }

  function schedule(toast) {
    clearTimer();
    const timeoutMs = Number(toast?.timeoutMs) > 0 ? Number(toast.timeoutMs) : TOAST_DEFAULT_TIMEOUT_MS;
    timerId = window.setTimeout(() => dismiss({ reason: 'timeout' }), timeoutMs);
  }

  function sync() {
    const toast = store.getState().ui.toast;

    if (!toast) {
      setHidden(dom.toast, true);
      return;
    }

    setHidden(dom.toast, false);
    dom.toast.dataset.tone = normalizeString(toast.tone) || 'info';
    setText(dom.toastTitle, normalizeString(toast.title) || 'Esquilo');
    setText(dom.toastMessage, normalizeString(toast.message));
    schedule(toast);
  }

  return {
    sync,
    dismiss
  };
}

function renderModalContent(modalState, helpers) {
  const modalName = normalizeString(modalState?.name);
  const payload = modalState?.payload;

  if (!modalName) {
    return {
      title: '',
      bodyHtml: ''
    };
  }

  if (modalName === 'asset-detail' && isPlainObject(payload)) {
    const title = normalizeString(payload.ticker || payload.nome || payload.name) || 'Detalhe do ativo';
    const detailEntries = Object.entries(payload)
      .filter(([key, value]) => typeof value !== 'object' && value !== null && value !== '')
      .slice(0, 12)
      .map(([key, value]) => {
        const label = key.replace(/[_-]/g, ' ');
        return `
          <div class="table-row__detail-item">
            <span class="type-label table-row__detail-label">${helpers.escapeHtml(label)}</span>
            <span class="type-body-strong table-row__detail-value">${helpers.escapeHtml(String(value))}</span>
          </div>
        `;
      })
      .join('');

    return {
      title,
      bodyHtml: `<div class="table-row__detail-grid">${detailEntries}</div>`
    };
  }

  if (modalName === 'generic-content' && isPlainObject(payload)) {
    return {
      title: normalizeString(payload.title) || 'Detalhe',
      bodyHtml: normalizeString(payload.bodyHtml)
    };
  }

  return {
    title: 'Detalhe',
    bodyHtml: '<div class="helper-state"><p class="type-body">Conteudo indisponivel para este bloco.</p></div>'
  };
}

function syncGlobalUi(appContext) {
  const { dom, helpers, store, selectors, toastManager } = appContext;
  const state = store.getState();
  const meta = selectors.getMeta();
  const ui = state.ui;

  if (dom.root) {
    dom.root.classList.toggle('dashboard-loading', Boolean(ui.isLoading));
    dom.root.dataset.transport = esquiloApi.getRuntime().transport;
  }

  if (dom.body) {
    dom.body.classList.toggle('is-ghost-mode', Boolean(ui.isGhostMode));
    dom.body.classList.toggle('ghost-active', Boolean(ui.isGhostMode));
  }

  setPressedState(dom.ghostToggles, ui.isGhostMode);
  setDisabledState(dom.refreshDashboardButtons, ui.isLoading || ui.isRefreshing);
  setDisabledState(dom.refreshActionsButtons, ui.isLoading || ui.isActionsRefreshing);
  setDisabledState(dom.refreshAiButtons, ui.isLoading || ui.isAiLoading);

  setText(dom.pageTitle, DEFAULT_TEXT.pageTitle);
  setText(dom.pageSubtitle, DEFAULT_TEXT.pageSubtitle);
  setText(dom.dataSource, helpers.formatDataSourceLabel(meta.dataSource));
  setText(dom.updatedAt, helpers.formatDateTime(meta.updatedAt));

  const versionText = [normalizeString(meta.releaseName), normalizeString(meta.versionNumber)]
    .filter(Boolean)
    .join(' • ');
  setText(dom.version, versionText || 'Cloudflare front');

  if (dom.warning) {
    const warningText = normalizeString(ui.lastWarning || meta.sourceWarning);
    setHidden(dom.warning, !warningText);
    setText(dom.warning, warningText);
  }

  if (dom.error) {
    const errorText = normalizeString(ui.lastError);
    setHidden(dom.error, !errorText);
    setText(dom.error, errorText);
  }

  if (dom.modalOverlay) {
    const isOpen = Boolean(ui.modal?.isOpen);
    dom.modalOverlay.classList.toggle('is-open', isOpen);
    dom.modalOverlay.setAttribute('aria-hidden', String(!isOpen));

    if (isOpen) {
      const modalContent = renderModalContent(ui.modal, helpers);
      setText(dom.modalTitle, modalContent.title);
      setHtml(dom.modalBody, modalContent.bodyHtml);
    } else {
      setText(dom.modalTitle, '');
      setHtml(dom.modalBody, '');
    }
  }

  toastManager.sync();
  syncDashboardUiState(appContext);
}

function bindGlobalEvents(appContext) {
  const { dom, store, actions, toastManager } = appContext;

  dom.ghostToggles.forEach((button) => {
    button.addEventListener('click', () => {
      store.toggleGhostMode(undefined, { source: 'ui' });
    });
  });

  dom.refreshDashboardButtons.forEach((button) => {
    button.addEventListener('click', () => {
      actions.refreshDashboard({ silent: false });
    });
  });

  dom.refreshActionsButtons.forEach((button) => {
    button.addEventListener('click', () => {
      actions.refreshActionsOnly({ silent: false });
    });
  });

  dom.refreshAiButtons.forEach((button) => {
    button.addEventListener('click', () => {
      actions.refreshAiAnalysis({ silent: false });
    });
  });

  dom.modalCloseButtons.forEach((button) => {
    button.addEventListener('click', () => {
      store.closeModal({ source: 'ui' });
    });
  });

  if (dom.modalOverlay) {
    dom.modalOverlay.addEventListener('click', (event) => {
      if (event.target === dom.modalOverlay) {
        store.closeModal({ source: 'overlay' });
      }
    });
  }

  if (dom.toastClose) {
    dom.toastClose.addEventListener('click', () => {
      toastManager.dismiss({ reason: 'manual' });
    });
  }

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && store.getState().ui.modal?.isOpen) {
      store.closeModal({ source: 'keyboard' });
    }
  });
}

function createAppActions(appContext) {
  const { api, store } = appContext;

  async function refreshHealth(options = {}) {
    const { silent = true } = options;

    try {
      const health = await api.getHealth();
      store.setHealth(health, { source: 'health' });
      return health;
    } catch (error) {
      if (!silent) {
        store.setWarning(normalizeString(error?.message) || DEFAULT_TEXT.genericWarning, {
          source: 'health'
        });
      }
      return null;
    }
  }

  async function refreshDashboard(options = {}) {
    const { silent = false } = options;

    store.clearError({ source: 'dashboard-refresh' });
    store.setLoadingStatus(store.getState().ui.isBootstrapped ? 'isRefreshing' : 'isLoading', true, {
      source: 'dashboard-refresh'
    });

    try {
      const payload = await api.getDashboardData();
      store.setDashboardData(payload, { source: 'dashboard' });

      if (!silent) {
        store.setToast(
          {
            tone: 'success',
            title: 'Carteira atualizada',
            message: 'A leitura principal da carteira foi recarregada.'
          },
          { source: 'dashboard-refresh' }
        );
      }

      return payload;
    } catch (error) {
      const message = normalizeString(error?.message) || DEFAULT_TEXT.genericError;
      store.setError(message, { source: 'dashboard-refresh' });

      if (!silent) {
        store.setToast(
          {
            tone: 'danger',
            title: 'Falha ao atualizar',
            message
          },
          { source: 'dashboard-refresh' }
        );
      }

      throw error;
    } finally {
      store.setLoadingStatus('isLoading', false, { source: 'dashboard-refresh' });
      store.setLoadingStatus('isRefreshing', false, { source: 'dashboard-refresh' });
    }
  }

  async function refreshActionsOnly(options = {}) {
    const { silent = false } = options;

    store.clearError({ source: 'actions-refresh' });
    store.setLoadingStatus('isActionsRefreshing', true, { source: 'actions-refresh' });

    try {
      const snapshot = await api.getDashboardActionsSnapshot();
      store.setActionsSnapshot(snapshot, { source: 'actions-snapshot' });

      if (!silent) {
        store.setToast(
          {
            tone: 'info',
            title: 'Leitura de acoes atualizada',
            message: 'As acoes foram recarregadas sem resetar o dashboard.'
          },
          { source: 'actions-refresh' }
        );
      }

      return snapshot;
    } catch (error) {
      const message = normalizeString(error?.message) || DEFAULT_TEXT.genericError;
      store.setError(message, { source: 'actions-refresh' });

      if (!silent) {
        store.setToast(
          {
            tone: 'danger',
            title: 'Falha ao atualizar acoes',
            message
          },
          { source: 'actions-refresh' }
        );
      }

      throw error;
    } finally {
      store.setLoadingStatus('isActionsRefreshing', false, { source: 'actions-refresh' });
    }
  }

  async function refreshAiAnalysis(options = {}) {
    const { silent = false } = options;

    store.setLoadingStatus('isAiLoading', true, { source: 'ai-refresh' });

    if (!silent) {
      store.setToast(
        {
          tone: 'info',
          title: 'Esquilo IA',
          message: DEFAULT_TEXT.loadingAi,
          timeoutMs: 1800
        },
        { source: 'ai-refresh' }
      );
    }

    try {
      const analysis = await api.getPortfolioAIAnalysis();
      store.setAiAnalysis(analysis, { source: 'ai-analysis' });
      return analysis;
    } catch (error) {
      const message = normalizeString(error?.message) || 'Nao foi possivel gerar a leitura da Esquilo IA.';
      store.setWarning(message, { source: 'ai-refresh' });

      if (!silent) {
        store.setToast(
          {
            tone: 'warning',
            title: 'Esquilo IA indisponivel',
            message
          },
          { source: 'ai-refresh' }
        );
      }

      return '';
    } finally {
      store.setLoadingStatus('isAiLoading', false, { source: 'ai-refresh' });
    }
  }

  return {
    refreshHealth,
    refreshDashboard,
    refreshActionsOnly,
    refreshAiAnalysis
  };
}

function createAppContext(options = {}) {
  const rootNode = options.root || document;
  const dom = createDomCache(rootNode);
  const helpers = createAppHelpers();
  const store = options.store || dashboardStore;
  const selectors = options.selectors || dashboardSelectors;
  const api = options.api || esquiloApi;

  const appContext = {
    api,
    dom,
    helpers,
    selectors,
    store,
    dashboardController: null,
    actions: null,
    toastManager: null,
    unsubscribe: null
  };

  appContext.toastManager = createToastManager(store, dom);
  appContext.actions = createAppActions(appContext);
  appContext.dashboardController = createDashboardController(appContext);

  return appContext;
}

async function bootstrapApp(options = {}) {
  const appContext = createAppContext(options);
  const { store, dashboardController } = appContext;

  renderDashboardShell(appContext);
  bindGlobalEvents(appContext);

  appContext.unsubscribe = store.subscribe(() => {
    syncGlobalUi(appContext);
  });

  syncGlobalUi(appContext);
  dashboardController.bind();

  try {
    await Promise.allSettled([
      appContext.actions.refreshHealth({ silent: true }),
      appContext.actions.refreshDashboard({ silent: true })
    ]);

    store.bootstrap({ source: 'app-bootstrap' });
    syncGlobalUi(appContext);

    dashboardController.afterInitialLoad();
  } catch (error) {
    store.setError(normalizeString(error?.message) || DEFAULT_TEXT.genericError, {
      source: 'app-bootstrap'
    });
    syncGlobalUi(appContext);
  }

  return appContext;
}

function autoStart() {
  const appRoot = document.querySelector(APP_SELECTORS.root);
  if (!appRoot) return;

  bootstrapApp({ root: document }).catch((error) => {
    console.error('[Esquilo] falha no bootstrap', error);
  });
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', autoStart, { once: true });
} else {
  autoStart();
}

export {
  APP_SELECTORS,
  DEFAULT_TEXT,
  autoStart,
  bootstrapApp,
  createAppActions,
  createAppContext,
  createAppHelpers,
  escapeHtml,
  formatCompactNumber,
  formatDataSourceLabel,
  formatDateTime,
  formatMoney,
  formatPercent,
  parseNumeric
};
