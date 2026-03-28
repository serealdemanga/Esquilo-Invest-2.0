/**
 * OPERATIONAL CRUD
 * Wrappers publicos para manipulacao controlada dos dados operacionais.
 * Nenhuma funcao executa ordem financeira real.
 */

function updateStatusAtivo(tipo, codigo, novoStatus) {
  const target = resolveOperationalCrudTarget_(tipo, codigo);
  const status = String(novoStatus || '').trim();
  if (!status) throw new Error('Novo status obrigatorio.');

  const result = updateRegistro(target.table, target.key, { status: status });
  return Object.assign({}, result, {
    message: 'Status atualizado com sucesso.',
    financialExecution: false
  });
}

function removerAtivo(tipo, codigo) {
  const target = resolveOperationalCrudTarget_(tipo, codigo);
  const result = deleteRegistro(target.table, target.key);
  return Object.assign({}, result, {
    message: 'Registro removido com sucesso.',
    financialExecution: false
  });
}

function adicionarAtivo(tipo, dados) {
  const target = resolveOperationalCrudType_(tipo);
  const payload = ensureOperationalCrudPayload_(dados, true);
  const result = insertRegistro(target, payload);
  return Object.assign({}, result, {
    message: 'Registro criado com sucesso.',
    financialExecution: false
  });
}

function atualizarAtivo(tipo, codigo, dados) {
  const target = resolveOperationalCrudTarget_(tipo, codigo);
  const payload = ensureOperationalCrudPayload_(dados, false);
  const result = updateRegistro(target.table, target.key, payload);
  return Object.assign({}, result, {
    message: 'Registro atualizado com sucesso.',
    financialExecution: false
  });
}

function resolveOperationalCrudTarget_(tipo, codigo) {
  return {
    table: resolveOperationalCrudType_(tipo),
    key: normalizeOperationalCrudKey_(codigo)
  };
}

function resolveOperationalCrudType_(tipo) {
  const normalizedType = normalizeOperationalCrudToken_(tipo);
  const supportedTypes = {
    acoes: BIGQUERY_SERVICE_TABLES_.ACOES,
    acao: BIGQUERY_SERVICE_TABLES_.ACOES,
    fundos: BIGQUERY_SERVICE_TABLES_.FUNDOS,
    fundo: BIGQUERY_SERVICE_TABLES_.FUNDOS,
    previdencia: BIGQUERY_SERVICE_TABLES_.PREVIDENCIA,
    previdencias: BIGQUERY_SERVICE_TABLES_.PREVIDENCIA,
    preordens: BIGQUERY_SERVICE_TABLES_.PRE_ORDENS,
    preordem: BIGQUERY_SERVICE_TABLES_.PRE_ORDENS,
    aportes: BIGQUERY_SERVICE_TABLES_.APORTES,
    aporte: BIGQUERY_SERVICE_TABLES_.APORTES
  };
  const target = supportedTypes[normalizedType];
  if (!target) throw new Error('Tipo operacional nao suportado para CRUD controlado.');
  return target;
}

function normalizeOperationalCrudKey_(codigo) {
  const normalizedKey = String(codigo || '').trim();
  if (!normalizedKey) throw new Error('Codigo ou chave do registro obrigatorio.');
  return normalizedKey;
}

function ensureOperationalCrudPayload_(dados, requireContent) {
  if (!dados || typeof dados !== 'object' || Array.isArray(dados)) {
    throw new Error('Payload invalido para operacao de CRUD.');
  }

  const payload = Object.keys(dados).reduce(function (result, key) {
    const normalizedKey = String(key || '').trim();
    if (!normalizedKey) return result;
    result[normalizedKey] = dados[key];
    return result;
  }, {});

  if (requireContent && !Object.keys(payload).length) {
    throw new Error('Dados obrigatorios para criar o registro.');
  }

  if (!requireContent && !Object.keys(payload).length) {
    throw new Error('Nenhum dado valido recebido para atualizacao.');
  }

  return payload;
}

function normalizeOperationalCrudToken_(value) {
  return String(value || '')
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '');
}
