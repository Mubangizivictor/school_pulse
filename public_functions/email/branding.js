// Default School Pulse brand identity. A school's own branding (name/logo
// colors passed via `schoolBranding`) may override display strings, but the
// sender identity, support address, and footer legal text never change —
// every transactional email is sent and owned by School Pulse itself.

// mail.schoolpulseapp.com is the domain actually added and verified in
// Resend (resend.com/domains) - the bare schoolpulseapp.com apex was never
// added there, so any sender using @schoolpulseapp.com directly is
// rejected by Resend at send time ("domain is not verified"), regardless
// of whether the underlying DNS is otherwise fine. Every sender below uses
// the mail. subdomain to match what Resend has actually verified.
const EMAIL_DOMAIN = 'mail.schoolpulseapp.com';
const SENDER = `School Pulse <notifications@${EMAIL_DOMAIN}>`;
const SUPPORT_EMAIL = 'support@schoolpulseapp.com';
const WEBSITE_ORIGIN = 'https://schoolpulseapp.com';
const STATUS_URL = `${WEBSITE_ORIGIN}/application-status`;

// Per-category senders under the verified mail.schoolpulseapp.com email
// domain. Falls back to the general `notifications@` sender (SENDER) for
// any templateId not listed below.
const SENDER_BY_TEMPLATE = {
  application_received: `School Pulse <applications@${EMAIL_DOMAIN}>`,
  application_approved: `School Pulse <applications@${EMAIL_DOMAIN}>`,
  application_rejected: `School Pulse <applications@${EMAIL_DOMAIN}>`,

  payment_proof_received: `School Pulse <payments@${EMAIL_DOMAIN}>`,
  manual_payment_approved: `School Pulse <payments@${EMAIL_DOMAIN}>`,
  manual_payment_rejected: `School Pulse <payments@${EMAIL_DOMAIN}>`,
  mobile_money_payment_success: `School Pulse <payments@${EMAIL_DOMAIN}>`,
  mobile_money_payment_failed: `School Pulse <payments@${EMAIL_DOMAIN}>`,
  payment_receipt: `School Pulse <payments@${EMAIL_DOMAIN}>`,
  payment_reversed: `School Pulse <payments@${EMAIL_DOMAIN}>`,
  payment_overdue: `School Pulse <payments@${EMAIL_DOMAIN}>`,
  subscription_activated: `School Pulse <payments@${EMAIL_DOMAIN}>`,
  subscription_renewed: `School Pulse <payments@${EMAIL_DOMAIN}>`,
  subscription_expiring: `School Pulse <payments@${EMAIL_DOMAIN}>`,
  subscription_expired: `School Pulse <payments@${EMAIL_DOMAIN}>`,
  subscription_suspended: `School Pulse <payments@${EMAIL_DOMAIN}>`,
  subscription_reactivated: `School Pulse <payments@${EMAIL_DOMAIN}>`,

  school_admin_account_created: `School Pulse <accounts@${EMAIL_DOMAIN}>`,
  staff_account_created: `School Pulse <accounts@${EMAIL_DOMAIN}>`,
  password_reset: `School Pulse <accounts@${EMAIL_DOMAIN}>`,

  email_verification: `School Pulse <security@${EMAIL_DOMAIN}>`,
  new_login_alert: `School Pulse <security@${EMAIL_DOMAIN}>`,
  suspicious_login_alert: `School Pulse <security@${EMAIL_DOMAIN}>`,
  sessions_revoked: `School Pulse <security@${EMAIL_DOMAIN}>`,
  account_locked: `School Pulse <security@${EMAIL_DOMAIN}>`,
  account_reactivated: `School Pulse <security@${EMAIL_DOMAIN}>`,
  password_changed: `School Pulse <security@${EMAIL_DOMAIN}>`,
  two_step_verification_enabled: `School Pulse <security@${EMAIL_DOMAIN}>`,
  two_step_verification_disabled: `School Pulse <security@${EMAIL_DOMAIN}>`,
  trusted_device_added: `School Pulse <security@${EMAIL_DOMAIN}>`,
  trusted_device_removed: `School Pulse <security@${EMAIL_DOMAIN}>`,
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
