function text(value, max = 500) {
  return String(value ?? '').trim().slice(0, max);
}

/** HTML-escape a value for safe interpolation into template markup. */
function escapeHtml(value, max = 1000) {
  return text(value, max)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

/** Escape a value for safe interpolation into an href/mailto attribute. */
function escapeAttr(value, max = 800) {
  return escapeHtml(value, max);
}

/**
 * Strip CR/LF from a value bound for an email header (Subject, To, From).
 * Templates may source subjects from caller-supplied data (e.g.
 * `important_announcement`'s `data.subject`); without this, a value
 * containing "\r\n" could inject additional headers (Bcc, X-*) into the
 * outbound message.
 */
function sanitizeHeaderValue(value, max = 200) {
  return text(value, max).replace(/[\r\n]+/g, ' ').trim();
}

const CURRENCY_FORMATTER = new Intl.NumberFormat('en-US');

function formatAmount(amount, currency = 'UGX') {
  const value = Math.max(0, Math.round(Number(amount || 0)));
  return `${text(currency, 10)} ${CURRENCY_FORMATTER.format(value)}`;
}

function formatDate(value) {
  const ms = value instanceof Date ? value.getTime() : Number(value || 0);
  if (!ms) return '';
  return new Date(ms).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
}

function formatDateTime(value) {
  const ms = value instanceof Date ? value.getTime() : Number(value || 0);
  if (!ms) return '';
  return new Date(ms).toLocaleString('en-GB', {
    day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit',
  });
}

const REFERENCE_PREFIXES = {
  application: 'APP',
  payment: 'PAY',
  receipt: 'RCT',
  subscription: 'SUB',
  appointment: 'APT',
  report: 'RPT',
  account: 'ACC',
};

/**
 * Derive a stable, human-readable reference (e.g. SP-APP-2026-000123) from an
 * internal id, without exposing the raw Firestore document id to the user.
 * Deterministic per internal id so re-sending the same event yields the same
 * reference, and no lookup table needs to be maintained.
 */
function humanReference(kind, internalId, when = new Date()) {
  const prefix = REFERENCE_PREFIXES[kind] || 'GEN';
  const year = (when instanceof Date ? when : new Date()).getFullYear();
  const source = text(internalId, 200) || 'unknown';
  let hash = 0;
  for (let i = 0; i < source.length; i += 1) {
    hash = (hash * 31 + source.charCodeAt(i)) >>> 0;
  }
  const digits = String(hash % 1000000).padStart(6, '0');
  return `SP-${prefix}-${year}-${digits}`;
}

module.exports = {
  text,
  escapeHtml,
  escapeAttr,
  sanitizeHeaderValue,
  formatAmount,
  formatDate,
  formatDateTime,
  humanReference,
};
