// Single source of truth for the school-portal subdomain namespace: the
// root domain, the reserved-word list, and the slug validity rule. Used by
// every file that reserves or validates a <slug>.ROOT subdomain
// (portal_domains.js's checkPortalSlug/createSchoolPortal, payments.js's
// approveSchoolApplication, index.js's submitSchoolApplication) so the
// three onboarding paths can never independently drift on what counts as
// a valid/available slug.
//
// Pure constants/functions only (no Cloud Functions registered here, no
// Firebase Admin SDK usage) so it can be required from any of those files
// without circular-require risk.
const ROOT = 'schoolpulseapp.com';
const RESERVED = new Set(['admin', 'api', 'www', 'support', 'schoolpulse', 'app', 'mail', 'status', 'portal']);
const validSlug = (v) => /^[a-z0-9](?:[a-z0-9-]{1,61}[a-z0-9])?$/.test(v) && !RESERVED.has(v);

module.exports = { ROOT, RESERVED, validSlug };
