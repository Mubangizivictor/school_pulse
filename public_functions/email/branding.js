// Default School Pulse brand identity. A school's own branding (name/logo
// colors passed via `schoolBranding`) may override display strings, but the
// sender identity, support address, and footer legal text never change —
// every transactional email is sent and owned by School Pulse itself.

const SENDER = 'School Pulse <notifications@schoolpulseapp.com>';
const SUPPORT_EMAIL = 'support@schoolpulseapp.com';
const WEBSITE_ORIGIN = 'https://schoolpulseapp.com';
const STATUS_URL = `${WEBSITE_ORIGIN}/application-status`;

// Per-category senders under the schoolpulseapp.com email domain
// (requires Resend domain verification + SPF/DKIM for schoolpulseapp.com).
// Falls back to the general
// `notifications@` sender (SENDER) for any templateId not listed below.
const SENDER_BY_TEMPLATE = {
  application_received: 'School Pulse <applications@schoolpulseapp.com>',
  application_approved: 'School Pulse <applications@schoolpulseapp.com>',
  application_rejected: 'School Pulse <applications@schoolpulseapp.com>',

  payment_proof_received: 'School Pulse <payments@schoolpulseapp.com>',
  manual_payment_approved: 'School Pulse <payments@schoolpulseapp.com>',
  manual_payment_rejected: 'School Pulse <payments@schoolpulseapp.com>',
  mobile_money_payment_success: 'School Pulse <payments@schoolpulseapp.com>',
  mobile_money_payment_failed: 'School Pulse <payments@schoolpulseapp.com>',
  payment_receipt: 'School Pulse <payments@schoolpulseapp.com>',
  payment_reversed: 'School Pulse <payments@schoolpulseapp.com>',
  payment_overdue: 'School Pulse <payments@schoolpulseapp.com>',
  subscription_activated: 'School Pulse <payments@schoolpulseapp.com>',
  subscription_renewed: 'School Pulse <payments@schoolpulseapp.com>',
  subscription_expiring: 'School Pulse <payments@schoolpulseapp.com>',
  subscription_expired: 'School Pulse <payments@schoolpulseapp.com>',
  subscription_suspended: 'School Pulse <payments@schoolpulseapp.com>',
  subscription_reactivated: 'School Pulse <payments@schoolpulseapp.com>',

  school_admin_account_created: 'School Pulse <accounts@schoolpulseapp.com>',
  staff_account_created: 'School Pulse <accounts@schoolpulseapp.com>',
  password_reset: 'School Pulse <accounts@schoolpulseapp.com>',

  email_verification: 'School Pulse <security@schoolpulseapp.com>',
  new_login_alert: 'School Pulse <security@schoolpulseapp.com>',
  suspicious_login_alert: 'School Pulse <security@schoolpulseapp.com>',
  sessions_revoked: 'School Pulse <security@schoolpulseapp.com>',
  account_locked: 'School Pulse <security@schoolpulseapp.com>',
  account_reactivated: 'School Pulse <security@schoolpulseapp.com>',
  password_changed: 'School Pulse <security@schoolpulseapp.com>',
  two_step_verification_enabled: 'School Pulse <security@schoolpulseapp.com>',
  two_step_verification_disabled: 'School Pulse <security@schoolpulseapp.com>',
  trusted_device_added: 'School Pulse <security@schoolpulseapp.com>',
  trusted_device_removed: 'School Pulse <security@schoolpulseapp.com>',
};

/**
 * Resolve the From header for a given local templateId. Appointments,
 * reports, and anything not explicitly categorized above use the general
 * `notifications@` sender per the SaaS Owner's sender mapping.
 */
function senderForTemplate(templateId) {
  return SENDER_BY_TEMPLATE[templateId] || SENDER;
}

const PRODUCT_NAME = 'School Pulse';

// Matches the in-app brand gradient (Super Admin header, etc): #4839E0 -> #8B3FE0.
const BRAND_START = '#4839E0';
const BRAND_END = '#8B3FE0';

const FOOTER_LINES = [PRODUCT_NAME, 'Powered by VictorBee Technologies', 'Uganda'];

function defaultBranding() {
  return {
    productName: PRODUCT_NAME,
    brandStart: BRAND_START,
    brandEnd: BRAND_END,
    supportEmail: SUPPORT_EMAIL,
  };
}

/**
 * Merge a school's display branding over the School Pulse default. Only
 * cosmetic fields (name shown in the header) may be overridden — sender
 * address, support email, and footer are always School Pulse's own.
 */
function resolveBranding(schoolBranding) {
  const base = defaultBranding();
  const displayName = String(schoolBranding?.schoolName ?? '').trim().slice(0, 160);
  return {
    ...base,
    schoolName: displayName || null,
  };
}

module.exports = {
  SENDER,
  SUPPORT_EMAIL,
  WEBSITE_ORIGIN,
  STATUS_URL,
  PRODUCT_NAME,
  BRAND_START,
  BRAND_END,
  FOOTER_LINES,
  resolveBranding,
  senderForTemplate,
};
