const { defineSecret } = require('firebase-functions/params');

// Only these three values are actual credentials - everything else below is
// non-sensitive configuration (base URL, environment name, sandbox test
// MSISDN/amount are public knowledge from MTN's own sandbox docs) and is
// read directly from process.env rather than Secret Manager.
const MTN_MOMO_API_USER = defineSecret('MTN_MOMO_API_USER');
const MTN_MOMO_API_KEY = defineSecret('MTN_MOMO_API_KEY');
const MTN_MOMO_SUBSCRIPTION_KEY = defineSecret('MTN_MOMO_SUBSCRIPTION_KEY');

const MTN_MOMO_SECRETS = [MTN_MOMO_API_USER, MTN_MOMO_API_KEY, MTN_MOMO_SUBSCRIPTION_KEY];

/**
 * Single accessor for MTN MoMo environment configuration. Every call site
 * (mtn_client.js, mtn_momo.js) reads through this instead of branching on
 * MTN_MOMO_TARGET_ENVIRONMENT itself, so adding Uganda production later is a
 * change to this one function, not a hunt across the codebase.
 *
 * Production values are never guessed/defaulted - MTN_MOMO_BASE_URL must be
 * supplied via env once real Uganda production credentials are issued.
 */
function getMtnConfig() {
  const targetEnvironment = String(process.env.MTN_MOMO_TARGET_ENVIRONMENT || 'sandbox').toLowerCase();

  if (targetEnvironment === 'production_uganda' || targetEnvironment === 'production' || targetEnvironment === 'mtnuganda') {
    return {
      targetEnvironment: 'mtnuganda',
      baseUrl: process.env.MTN_MOMO_BASE_URL || '',
      currency: 'UGX',
      sandboxTestMsisdn: null,
      sandboxTestAmount: null,
    };
  }

  return {
    targetEnvironment: 'sandbox',
    baseUrl: process.env.MTN_MOMO_BASE_URL || 'https://sandbox.momodeveloper.mtn.com',
    currency: 'EUR',
    sandboxTestMsisdn: process.env.MTN_MOMO_SANDBOX_TEST_MSISDN || '256700000000',
    sandboxTestAmount: process.env.MTN_MOMO_SANDBOX_TEST_AMOUNT || '100',
  };
}

module.exports = {
  getMtnConfig,
  MTN_MOMO_API_USER,
  MTN_MOMO_API_KEY,
  MTN_MOMO_SUBSCRIPTION_KEY,
  MTN_MOMO_SECRETS,
};
