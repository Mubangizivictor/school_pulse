const existing = require('./index');
const draft = require('./draft');
const owner = require('./owner');
const payments = require('./payments');
const paymentNotifications = require('./payment_notifications');
const applicationNotifications = require('./application_notifications');
const publicBilling = require('./billing_public');

// payments is intentionally spread after owner: it replaces the old
// approval/status exports with the payment-gated onboarding lifecycle while
// keeping the existing draft and rejection functions intact.
module.exports = {
  ...existing,
  ...draft,
  ...owner,
  ...payments,
  ...paymentNotifications,
  ...applicationNotifications,
  ...publicBilling,
};
