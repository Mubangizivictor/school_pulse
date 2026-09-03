const existing = require('./index');
const draft = require('./draft');
const owner = require('./owner');
const ownerAuth = require('./owner_auth');
const ownerRecoveryCodes = require('./owner_recovery_codes');
const ownerSecuritySession = require('./owner_security_session');
const payments = require('./payments');
const paymentNotifications = require('./payment_notifications');
const applicationNotifications = require('./application_notifications');
const ownerDeviceRegistry = require('./owner_device_registry');
const ownerNotificationsAdmin = require('./owner_notifications_admin');
const ownerTrustedDevices = require('./owner_trusted_devices');
const ownerNotificationPreferences = require('./owner_notification_preferences');
const publicBilling = require('./billing_public');
const availability = require('./availability');
const ownerSignInEvents = require('./owner_sign_in_events');
const transactionalEmailQueue = require('./email/transactional_queue');
const subscriptionLifecycle = require('./subscription_lifecycle');
const subscriptionCycleBilling = require('./subscription_cycle_billing');
const location = require('./location');
const mtnMomo = require('./mtn_momo');
const emailVerification = require('./email_verification');
const documentVerification = require('./documents/verification_endpoint');
const studentCredentialVerification = require('./documents/student_verification_endpoint');
const portalDomains = require('./portal_domains');
const schoolCounts = require('./school_counts');

// payments is intentionally spread after owner: it replaces the old
// approval/status exports with the payment-gated onboarding lifecycle while
// keeping the existing draft and rejection functions intact.
module.exports = {
  ...existing,
  ...draft,
  ...owner,
  ...ownerAuth,
  ...ownerRecoveryCodes,
  ...ownerSecuritySession,
  ...payments,
  ...paymentNotifications,
  ...applicationNotifications,
  ...ownerDeviceRegistry,
  ...ownerNotificationsAdmin,
  ...ownerTrustedDevices,
  ...ownerNotificationPreferences,
  ...publicBilling,
  ...availability,
  ...ownerSignInEvents,
  ...transactionalEmailQueue,
  ...subscriptionLifecycle,
  ...subscriptionCycleBilling,
  ...location,
  ...mtnMomo,
  ...emailVerification,
  ...documentVerification,
  ...studentCredentialVerification,
  ...portalDomains,
  ...schoolCounts,
};
