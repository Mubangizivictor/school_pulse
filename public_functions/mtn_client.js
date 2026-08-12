const crypto = require('crypto');
const { getMtnConfig, MTN_MOMO_API_USER, MTN_MOMO_API_KEY, MTN_MOMO_SUBSCRIPTION_KEY } = require('./mtn_config');

// Cloud Functions v2 instances are reused across invocations, so an
// in-memory cache here is a real cache, not a per-request no-op. Refreshed
// whenever less than 60s of validity remains.
let _tokenCache = { token: null, expiresAt: 0 };
const TOKEN_SAFETY_MARGIN_MS = 60 * 1000;

function invalidateTokenCache() {
  _tokenCache = { token: null, expiresAt: 0 };
}

async function getMtnAccessToken({ forceRefresh = false } = {}) {
  if (!forceRefresh && _tokenCache.token && _tokenCache.expiresAt > Date.now() + TOKEN_SAFETY_MARGIN_MS) {
    return _tokenCache.token;
  }

  const config = getMtnConfig();
  const apiUser = MTN_MOMO_API_USER.value();
  const apiKey = MTN_MOMO_API_KEY.value();
  const subscriptionKey = MTN_MOMO_SUBSCRIPTION_KEY.value();
  if (!apiUser || !apiKey || !subscriptionKey) {
    throw new Error('mtn_not_configured');
  }

  const basicAuth = Buffer.from(`${apiUser}:${apiKey}`).toString('base64');
  const startedAt = Date.now();
  const res = await fetch(`${config.baseUrl}/collection/token/`, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${basicAuth}`,
      'Ocp-Apim-Subscription-Key': subscriptionKey,
    },
  });
  const durationMs = Date.now() - startedAt;

  if (!res.ok) {
    console.error('MTN_TOKEN_REQUEST_FAILED', JSON.stringify({ httpStatus: res.status, durationMs }));
    throw new Error(`mtn_token_request_failed_${res.status}`);
  }

  const data = await res.json();
  const expiresInSeconds = Number(data.expires_in || 3600);
  _tokenCache = {
    token: data.access_token,
    expiresAt: Date.now() + expiresInSeconds * 1000,
  };
  console.log('MTN_TOKEN_REFRESHED', JSON.stringify({ durationMs, expiresInSeconds }));
  return _tokenCache.token;
}

/**
 * Runs `fn(accessToken)` against MTN. On a 401 response, invalidates the
 * cached token and retries exactly once with a freshly-fetched token - never
 * retries a second time, so a persistently misconfigured credential fails
 * fast instead of looping.
 */
async function withMtnAuthRetry(fn) {
  let accessToken = await getMtnAccessToken();
  let res = await fn(accessToken);
  if (res.status === 401) {
    invalidateTokenCache();
    accessToken = await getMtnAccessToken({ forceRefresh: true });
    res = await fn(accessToken);
  }
  return res;
}

/**
 * POST /collection/v1_0/requesttopay. Returns { ok, status, financialTransactionId? }.
 * Throws only on transport-level failure (network error) - a non-202 HTTP
 * response is returned as { ok: false, httpStatus, safeError } rather than
 * thrown, since callers need to persist a FAILED payment record either way.
 */
async function mtnRequestToPay({ referenceId, amount, currency, payerMsisdn, payerMessage, payeeNote }) {
  const config = getMtnConfig();
  const subscriptionKey = MTN_MOMO_SUBSCRIPTION_KEY.value();
  const startedAt = Date.now();

  const res = await withMtnAuthRetry((accessToken) => fetch(`${config.baseUrl}/collection/v1_0/requesttopay`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'X-Reference-Id': referenceId,
      'X-Target-Environment': config.targetEnvironment,
      'Ocp-Apim-Subscription-Key': subscriptionKey,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      amount: String(amount),
      currency,
      externalId: referenceId,
      payer: { partyIdType: 'MSISDN', partyId: payerMsisdn },
      payerMessage,
      payeeNote,
    }),
  }));
  const durationMs = Date.now() - startedAt;

  if (res.status === 202) {
    console.log('MTN_REQUEST_TO_PAY', JSON.stringify({ referenceId, httpStatus: res.status, durationMs }));
    return { ok: true };
  }

  const bodyText = await res.text().catch(() => '');
  console.error('MTN_REQUEST_TO_PAY_FAILED', JSON.stringify({ referenceId, httpStatus: res.status, durationMs }));
  return { ok: false, httpStatus: res.status, safeError: `mtn_requesttopay_failed_${res.status}`, rawBody: bodyText };
}

/** GET /collection/v1_0/requesttopay/{referenceId}. Returns raw MTN JSON, or null on transport/HTTP failure. */
async function mtnGetStatus({ referenceId }) {
  const config = getMtnConfig();
  const subscriptionKey = MTN_MOMO_SUBSCRIPTION_KEY.value();
  const startedAt = Date.now();

  const res = await withMtnAuthRetry((accessToken) => fetch(`${config.baseUrl}/collection/v1_0/requesttopay/${referenceId}`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'X-Target-Environment': config.targetEnvironment,
      'Ocp-Apim-Subscription-Key': subscriptionKey,
    },
  }));
  const durationMs = Date.now() - startedAt;

  if (!res.ok) {
    console.error('MTN_GET_STATUS_FAILED', JSON.stringify({ referenceId, httpStatus: res.status, durationMs }));
    return null;
  }

  console.log('MTN_GET_STATUS', JSON.stringify({ referenceId, httpStatus: res.status, durationMs }));
  return res.json();
}

const MTN_STATUS_MAP = {
  SUCCESSFUL: 'SUCCESSFUL',
  FAILED: 'FAILED',
  PENDING: 'PENDING',
  REJECTED: 'FAILED',
  TIMEOUT: 'EXPIRED',
  EXPIRED: 'EXPIRED',
  CANCELLED: 'CANCELLED',
};

/** Pure mapper - never throws. Unrecognized MTN status strings map to UNKNOWN. */
function mapMtnStatus(mtnStatus) {
  const key = String(mtnStatus ?? '').trim().toUpperCase();
  return MTN_STATUS_MAP[key] || 'UNKNOWN';
}

function newReferenceId() {
  return crypto.randomUUID();
}

module.exports = {
  getMtnAccessToken,
  invalidateTokenCache,
  mtnRequestToPay,
  mtnGetStatus,
  mapMtnStatus,
  newReferenceId,
};
module.exports.__test__ = { mapMtnStatus };
