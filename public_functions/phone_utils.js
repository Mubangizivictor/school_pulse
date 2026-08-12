const UGANDA_MSISDN_PATTERN = /^256\d{9}$/;

/**
 * Normalize a Uganda phone number to MTN's expected MSISDN shape
 * (256XXXXXXXXX) and validate the result. Unlike the older, unvalidated
 * normalizer in functions/index.js, this throws on anything that doesn't
 * resolve to a plausible Uganda MSISDN rather than silently passing a
 * malformed string on to MTN.
 *
 * Accepts: 0793128137, +256793128137, 256793128137, with any surrounding
 * whitespace/punctuation stripped before matching.
 */
function normalizeUgandaMsisdn(rawPhone) {
  const digits = String(rawPhone ?? '').replace(/\D/g, '');

  let normalized;
  if (digits.startsWith('256')) {
    normalized = digits;
  } else if (digits.startsWith('0')) {
    normalized = `256${digits.slice(1)}`;
  } else {
    normalized = `256${digits}`;
  }

  if (!UGANDA_MSISDN_PATTERN.test(normalized)) {
    throw new Error('invalid_msisdn');
  }
  return normalized;
}

/** e.g. '256793128137' -> '2567******37' - safe to store/display client-side. */
function maskMsisdn(msisdn) {
  const value = String(msisdn ?? '');
  if (value.length < 6) return '******';
  return `${value.slice(0, 4)}${'*'.repeat(value.length - 6)}${value.slice(-2)}`;
}

module.exports = { normalizeUgandaMsisdn, maskMsisdn };
module.exports.__test__ = { normalizeUgandaMsisdn, maskMsisdn };
