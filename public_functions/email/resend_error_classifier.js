// Classifies a Resend SDK error response into a permanent (non-retryable)
// configuration problem vs. a transient (retryable) provider failure.
//
// The installed SDK (resend@6.19.0) types this as:
//   type ErrorResponse = { message: string; statusCode: number | null; name: RESEND_ERROR_CODE_KEY }
//   type RESEND_ERROR_CODE_KEY =
//     'invalid_idempotency_key' | 'validation_error' | 'missing_api_key' |
//     'restricted_api_key' | 'invalid_api_key' | 'not_found' |
//     'method_not_allowed' | 'invalid_idempotent_request' |
//     'concurrent_idempotent_requests' | 'invalid_attachment' |
//     'invalid_from_address' | 'invalid_access' | 'invalid_parameter' |
//     'invalid_region' | 'missing_required_field' | 'monthly_quota_exceeded' |
//     'daily_quota_exceeded' | 'rate_limit_exceeded' | 'security_error' |
//     'application_error' | 'internal_server_error'
// (node_modules/resend/dist/index.d.cts). Only names that actually appear in
// that union are matched below — nothing here is guessed.

// A hosted-template send (public_functions/email/hosted_templates.js) can
// fail because the alias is wrong/unpublished ('not_found'), because the
// variables sent don't satisfy the template ('validation_error',
// 'missing_required_field', 'invalid_parameter'), or because of other
// request-shape problems that retrying verbatim can never fix. These are
// configuration bugs, not provider blips.
const CONFIGURATION_ERROR_NAMES = new Set([
  'not_found', // unknown/unpublished/deleted template alias
  'validation_error', // request body failed Resend's schema validation
  'missing_required_field', // a variable the template requires was absent
  'invalid_parameter', // a variable's value didn't satisfy the template's type
  'invalid_from_address', // sender not on a verified domain
  'invalid_attachment',
  'invalid_region',
  'invalid_access',
  'restricted_api_key',
  'invalid_api_key',
  'missing_api_key',
]);

// Provider-side or account-side conditions that a later retry can plausibly
// resolve without any code change.
const TRANSIENT_ERROR_NAMES = new Set([
  'rate_limit_exceeded',
  'internal_server_error',
  'application_error',
  'concurrent_idempotent_requests',
]);

// Quota errors are permanent for *this* send attempt (retrying in 2/20
// minutes will not free up quota) but are not a code/config bug either -
// classified as non-retryable so the bounded queue doesn't burn its two
// retries on something retrying can't fix, without being mislabeled as a
// "configuration error" in logs/audit (a human needs to upgrade a plan or
// wait for the period to roll over, not fix a template mapping).
const QUOTA_ERROR_NAMES = new Set(['monthly_quota_exceeded', 'daily_quota_exceeded']);

/**
 * @param {object} error - the `error` object from `resend.emails.send()`'s
 *   `{ data, error }` response, or a thrown Error/exception.
 * @returns {{
 *   errorClass: 'HOSTED_TEMPLATE_CONFIGURATION_ERROR'|'QUOTA_ERROR'|'TRANSIENT_PROVIDER_ERROR'|'UNKNOWN_ERROR',
 *   retryable: boolean,
 *   providerErrorName: string|null,
 *   providerErrorMessage: string,
 * }}
 */
const ALL_KNOWN_NAMES = new Set([...CONFIGURATION_ERROR_NAMES, ...QUOTA_ERROR_NAMES, ...TRANSIENT_ERROR_NAMES]);

function classifyResendError(error) {
  // Only surface `providerErrorName` when it's a name Resend itself would
  // actually return. A plain thrown JS Error also has a `.name` property
  // (the string "Error", "TypeError", etc. - a language artifact, not a
  // provider signal), so without this check a network-level throw would be
  // misreported as if Resend had named the failure "Error".
  const rawName = typeof error?.name === 'string' ? error.name : null;
  const providerErrorName = rawName && ALL_KNOWN_NAMES.has(rawName) ? rawName : null;
  const providerErrorMessage = String(error?.message || error || 'Unknown error').slice(0, 600);

  if (providerErrorName && CONFIGURATION_ERROR_NAMES.has(providerErrorName)) {
    return { errorClass: 'HOSTED_TEMPLATE_CONFIGURATION_ERROR', retryable: false, providerErrorName, providerErrorMessage };
  }
  if (providerErrorName && QUOTA_ERROR_NAMES.has(providerErrorName)) {
    return { errorClass: 'QUOTA_ERROR', retryable: false, providerErrorName, providerErrorMessage };
  }
  if (providerErrorName && TRANSIENT_ERROR_NAMES.has(providerErrorName)) {
    return { errorClass: 'TRANSIENT_PROVIDER_ERROR', retryable: true, providerErrorName, providerErrorMessage };
  }
  // Genuinely unknown provider/network failure (e.g. fetch threw, or a
  // future Resend error name not yet in the union above) - conservative
  // bounded retry, matching the system's existing default behavior.
  return { errorClass: 'UNKNOWN_ERROR', retryable: true, providerErrorName, providerErrorMessage };
}

module.exports = { classifyResendError, CONFIGURATION_ERROR_NAMES, TRANSIENT_ERROR_NAMES, QUOTA_ERROR_NAMES };
