const existing = require('./index');
const draft = require('./draft');
const owner = require('./owner');
const payments = require('./payments');

// payments is intentionally spread last: it replaces the old approval/status
// exports with the payment-gated onboarding lifecycle while keeping the
// existing draft and rejection functions intact.
module.exports = { ...existing, ...draft, ...owner, ...payments };
