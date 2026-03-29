/**
 * ESQUILO INVEST - DASHBOARD CONTROLLER
 * Esse script liga os dados do State Manager (AppState) com a tela HTML.
 */

// Elementos da UI que vamos atualizar
const UI = {
  lastUpdate: document.getElementById('lastUpdate'),
  valPatrimonioTotal: document.getElementById('valPatrimonioTotal'),
  valAporteTotal: document.getElementById('valAporteTotal'),
  valLucroTotal: document.getElementById('valLucroTotal'),
  badgeRentabilidade: document.getElementById('badgeRentabilidade'),
  iconLucro: document.getElementById('iconLucro'),
  tableAlocacaoBody: document.getElementById('tableAlocacaoBody'),
  btnSync: document.getElementById('btnSync')
};

/**
 * Função principal que é chamada toda vez que o AppState muda.
 * Ela pega os dados novos e joga nos elementos certos da tela.
 */
function renderDashboard(data, uiState) {
  // Trata estado de loading
  if (uiState.isLoading) {
    UI.btnSync.innerHTML = '<i data-lucide="loader-2" class="spin"></i> Carregando...';
    lucide.createIcons(); // Recria os ícones pra pegar a classe spin se precisar
    return; // Pode adicionar uns skeletons depois pra ficar mais profissa
  }

  // Volta o botão ao normal
  UI.btnSync.innerHTML = '<i data-lucide="refresh-cw"></i> Sincronizar';
  lucide.createIcons();

  // Se deu erro, a gente pode mostrar um toast ou algo assim depois
  if (uiState.error) {
    console.error("Deu ruim na renderização:", uiState.error);
    return;
  }

  // 1. Atualiza os Cards de Resumo
  const resumo = data.resumo;
  UI.valPatrimonioTotal.textContent = Utils.formatCurrency(resumo.patrimonioTotal);
  UI.valAporteTotal.textContent = Utils.formatCurrency(resumo.valorInvestido);
  UI.valLucroTotal.textContent = Utils.formatCurrency(resumo.lucroBruto);
  
  // Trata cores do lucro (verde pra alta, vermelho pra baixa)
  if (resumo.lucroBruto >= 0) {
    UI.valLucroTotal.className = 'font-mono text-success';
    UI.badgeRentabilidade.className = 'badge badge-success';
    UI.iconLucro.setAttribute('data-lucide', 'trending-up');
    UI.iconLucro.style.color = 'var(--color-success)';
  } else {
    UI.valLucroTotal.className = 'font-mono text-danger';
    UI.badgeRentabilidade.className = 'badge badge-danger';
    UI.iconLucro.setAttribute('data-lucide', 'trending-down');
    UI.iconLucro.style.color = 'var(--color-danger)';
  }
  
  UI.badgeRentabilidade.textContent = Utils.formatPercent(resumo.rentabilidade);
  
  // 2. Atualiza data da última sincronização
  if (data.ultimaAtualizacao) {
    UI.lastUpdate.textContent = `Última atualização: ${data.ultimaAtualizacao}`;
  }

  // 3. Atualiza Tabela de Alocação
  renderAlocacaoTable(data.alocacao);
}

/**
 * Monta as linhas da tabela de alocação dinamicamente
 */
function renderAlocacaoTable(alocacaoData) {
  if (!alocacaoData || alocacaoData.length === 0) {
    UI.tableAlocacaoBody.innerHTML = `<tr><td colspan="3" class="text-muted" style="text-align: center;">Nenhum dado encontrado.</td></tr>`;
    return;
  }

  const html = alocacaoData.map(item => `
    <tr>
      <td>${item.classe}</td>
      <td class="font-mono">${Utils.formatCurrency(item.valor)}</td>
      <td class="font-mono">${Utils.formatPercent(item.percentual)}</td>
    </tr>
  `).join('');

  UI.tableAlocacaoBody.innerHTML = html;
}

/**
 * Inicializa a tela quando a página carrega
 */
async function initDashboard() {
  // Conecta o nosso renderizador no State Manager
  AppState.subscribe(renderDashboard);

  // Ação do botão de sincronizar
  UI.btnSync.addEventListener('click', () => {
    carregarDados();
  });

  // Busca inicial dos dados
  await carregarDados();
}

/**
 * Puxa os dados da API e joga pro State Manager
 */
async function carregarDados() {
  try {
    const dashboardData = await API.getDashboardData();
    AppState.update(dashboardData);
  } catch (error) {
    console.error("Falha ao carregar dashboard:", error);
    // AppState.setError já é chamado dentro da API.js
  }
}

// Quando o HTML estiver 100% carregado, dá o start
document.addEventListener('DOMContentLoaded', initDashboard);