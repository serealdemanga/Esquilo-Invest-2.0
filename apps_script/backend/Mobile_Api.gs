/**
 * MOBILE API
 * Entrega um contrato JSON minimo para o app Flutter sem quebrar o web app.
 */

function doPost(e) {
  return buildMobileApiResponse_(e);
}

function isMobileApiRequest_(e) {
  return normalizeMobileApiValue_(e?.parameter?.format) === 'json';
}

function buildMobileApiResponse_(e) {
  const payload = routeMobileApiRequest_(e);
  return ContentService.createTextOutput(JSON.stringify(payload))
    .setMimeType(ContentService.MimeType.JSON);
}

function routeMobileApiRequest_(e) {
  try {
    const resource = normalizeMobileApiValue_(e?.parameter?.resource);
    if (resource === 'health') {
      return buildMobileApiSuccess_({
        resource: resource,
        data: {
          releaseName: APP_CONFIG_.releaseName,
          versionNumber: APP_CONFIG_.versionNumber,
          updatedAt: new Date().toISOString()
        }
      });
    }

    validateMobileApiToken_(e, resource);

    if (resource === 'dashboard') {
      return buildMobileApiSuccess_({
        resource: resource,
        data: getDashboardData()
      });
    }

    if (resource === 'ai-analysis') {
      const analysis = getPortfolioAIAnalysis();
      if (/^Erro:/i.test(String(analysis || ''))) {
        throw new Error(String(analysis));
      }

      return buildMobileApiSuccess_({
        resource: resource,
        data: {
          analysis: analysis,
          updatedAt: new Date().toISOString()
        }
      });
    }

    throw new Error('Recurso mobile nao suportado: ' + (resource || 'vazio') + '.');
  } catch (error) {
    return buildMobileApiError_(String(error && error.message ? error.message : error));
  }
}

function validateMobileApiToken_(e, resource) {
  if (!isProtectedMobileResource_(resource)) return;

  const configuredToken = getScriptProperty_(SCRIPT_PROPERTY_KEYS_.mobileAppApiToken);
  if (!configuredToken) return;

  const receivedToken = readMobileApiToken_(e);
  if (receivedToken && receivedToken === configuredToken) return;

  throw new Error('Token mobile invalido ou ausente.');
}

function isProtectedMobileResource_(resource) {
  return ['dashboard', 'ai-analysis'].indexOf(normalizeMobileApiValue_(resource)) >= 0;
}

function readMobileApiToken_(e) {
  const directToken = String(e?.parameter?.token || '').trim();
  if (directToken) return directToken;

  const tokenList = e?.parameters?.token || [];
  if (tokenList.length > 0) {
    return String(tokenList[0] || '').trim();
  }

  return '';
}

function buildMobileApiSuccess_(data) {
  return {
    ok: true,
    releaseName: APP_CONFIG_.releaseName,
    versionNumber: APP_CONFIG_.versionNumber,
    data: data?.data || {},
    resource: data?.resource || '',
    updatedAt: new Date().toISOString()
  };
}

function buildMobileApiError_(message) {
  return {
    ok: false,
    releaseName: APP_CONFIG_.releaseName,
    versionNumber: APP_CONFIG_.versionNumber,
    error: message || 'Erro desconhecido na API mobile.',
    updatedAt: new Date().toISOString()
  };
}

function normalizeMobileApiValue_(value) {
  return String(value || '')
    .trim()
    .toLowerCase();
}
