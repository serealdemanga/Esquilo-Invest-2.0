/**
 * ESQUILO INVEST - STATE MANAGER
 * Gerenciador de estado simples para o frontend.
 * Evita que a gente fique lendo dados direto do HTML (DOM).
 */

const AppState = {
  // Dados brutos que vêm da API
  data: {
    resumo: {
      patrimonioTotal: 0,
      valorInvestido: 0,
      lucroBruto: 0,
      rentabilidade: 0
    },
    alocacao: [], // [{classe: "Ações", valor: 1000, percentual: 50}]
    ativos: [],
    ultimaAtualizacao: null
  },
  
  // Status da aplicação
  ui: {
    isLoading: false,
    error: null
  },

  // Observadores (funções que rodam quando o estado muda)
  listeners: [],

  // Adiciona um ouvinte
  subscribe(listener) {
    this.listeners.push(listener);
  },

  // Atualiza o estado e avisa a galera
  update(newData) {
    this.data = { ...this.data, ...newData };
    this.notify();
  },

  setLoading(status) {
    this.ui.isLoading = status;
    this.notify();
  },

  setError(errorMsg) {
    this.ui.error = errorMsg;
    this.notify();
  },

  // Roda todas as funções que estão ouvindo as mudanças
  notify() {
    this.listeners.forEach(listener => listener(this.data, this.ui));
  }
};

// Formatações úteis globais
const Utils = {
  formatCurrency(value) {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(value || 0);
  },
  
  formatPercent(value) {
    return new Intl.NumberFormat('pt-BR', {
      style: 'percent',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format((value || 0) / 100);
  }
};