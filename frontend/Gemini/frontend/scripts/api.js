/**
 * ESQUILO INVEST - API SERVICE
 * Substitui o google.script.run. Faz chamadas REST pro backend.
 */

const API = {
  // TODO: Substituir pela URL real do Web App do Apps Script
  // O backend do Apps Script PRECISA estar configurado para aceitar requisições GET/POST 
  // e retornar JSON (Content-Type: application/json) com CORS liberado.
  BASE_URL: 'URL_DO_SEU_WEB_APP_APPS_SCRIPT_AQUI',
  
  /**
   * Faz a requisição padrão com tratamento de erro
   */
  async fetch(endpoint, options = {}) {
    try {
      AppState.setLoading(true);
      
      const response = await window.fetch(`${this.BASE_URL}?action=${endpoint}`, {
        method: options.method || 'GET',
        headers: {
          'Content-Type': 'application/json',
          ...options.headers
        },
        // Se for POST, converte o body
        ...(options.body && { body: JSON.stringify(options.body) })
      });

      if (!response.ok) {
        throw new Error(`Erro na API: ${response.status} ${response.statusText}`);
      }

      const data = await response.json();
      AppState.setLoading(false);
      return data;

    } catch (error) {
      console.error('[API Error]', error);
      AppState.setError(error.message);
      AppState.setLoading(false);
      throw error;
    }
  },

  /**
   * Busca os dados consolidados do Dashboard
   */
  async getDashboardData() {
    // Mock temporário para podermos ver a UI funcionando antes do backend estar 100% pronto
    // Descomente a linha abaixo quando o endpoint real existir
    // return await this.fetch('getDashboardData'); 

    return new Promise(resolve => {
      setTimeout(() => {
        resolve({
          resumo: {
            patrimonioTotal: 154320.50,
            valorInvestido: 120000.00,
            lucroBruto: 34320.50,
            rentabilidade: 28.6
          },
          alocacao: [
            { classe: 'Ações BR', valor: 61728.20, percentual: 40 },
            { classe: 'FIIs', valor: 46296.15, percentual: 30 },
            { classe: 'Renda Fixa', valor: 30864.10, percentual: 20 },
            { classe: 'Caixa', valor: 15432.05, percentual: 10 }
          ],
          ultimaAtualizacao: new Date().toLocaleDateString('pt-BR')
        });
      }, 800); // Simula um delay de rede
    });
  }
};