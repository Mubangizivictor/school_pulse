const existing = require('./index');
const draft = require('./draft');
const owner = require('./owner');
const payments = require('./payments');
const paymentNotifications = require('./payment_notifications');
const applicationNotifications = require('./application_notifications');
const ownerDeviceRegistry = require('./owner_device_registry');
const ownerNotificationsAdmin = require('./owner_notifications_admin');
const ownerNotificationPreferences = require('./owner_notification_preferences');
const publicBilling = require('./billing_public');
const availability = require('./availability');
const ownerSignInEvents = require('./owner_sign_in_events');
const transactionalEmailQueue = require('./email/transactional_queue');
const subscriptionLifecycle = require('./subscription_lifecycle');
const location = require('./location');
const mtnMomo = require('./mtn_momo');

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
  ...ownerDeviceRegistry,
  ...ownerNotificationsAdmin,
  ...ownerNotificationPreferences,
  ...publicBilling,
  ...availability,
  ...ownerSignInEvents,
  ...transactionalEmailQueue,
  ...subscriptionLifecycle,
  ...location,
  ...mtnMomo,
};
