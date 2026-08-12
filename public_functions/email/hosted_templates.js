const { text, formatAmount, humanReference } = require('./email_helpers');

/**
 * Published Resend hosted templates (resend.com/templates), keyed by the
 * SAME local `templateId` values already used throughout the codebase
 * (application_notifications.js, payment_notifications.js, mtn_momo.js,
 * subscription_lifecycle.js, owner_sign_in_events.js, functions/index.js,
 * functions/appointments.js). No call site needs to change to pick a
 * template — sendTemplatedEmail looks up this map by the templateId it
 * already receives.
 *
 * Aliases below were copied verbatim from the Resend dashboard
 * (Templates -> alias column) on 2026-08-12 — not guessed. Where more than
 * one local templateId reasonably maps to the same published template (the
 * hosted library has 16 templates; the local library has 39, since it also
 * covers events School Pulse never published a hosted template for, e.g.
 * 2FA/trusted-device/subscription_suspended), multiple local ids point at
 * one alias below with a shared variable transformer.
 *
 * `variables` transformers read from the SAME `data` object callers already
 * pass to enqueueTemplatedEmail/enqueueTransactionalEmail today — no call
 * site had to widen its payload for this to work, except application_
 * approved/rejected, which already computed `adminName` locally but never
 * threaded it through (see application_notifications.js).
 */
const HOSTED_TEMPLATES = {
  application_received: {
    alias: 'school-application-received',
    variables: (data) => ({
      school_name: text(data.schoolName, 160) || 'A school',
      application_reference: humanReference('application', data.applicationId),
    }),
  },

  application_approved: {
    alias: 'application-approved',
    variables: (data) => ({
      admin_name: text(data.adminName, 160) || 'Administrator',
      school_name: text(data.schoolName, 160) || 'A school',
      application_reference: humanReference('application', data.applicationId),
    }),
  },

  application_rejected: {
    alias: 'application-rejected',
    variables: (data) => ({
      admin_name: text(data.adminName, 160) || 'Administrator',
      school_name: text(data.schoolName, 160) || 'A school',
      application_reference: humanReference('application', data.applicationId),
      rejection_reason: text(data.reason, 500) || 'No reason provided.',
    }),
  },

  payment_proof_received: {
    alias: 'payment-proof-received',
    variables: (data) => ({
      school_name: text(data.schoolName, 160) || 'A school',
      amount: text(data.amountLabel, 60) || formatAmount(data.amount),
      payment_method: text(data.methodLabel, 60) || 'Unknown',
      payment_reference: humanReference('payment', data.paymentId),
      submitted_at: text(data.submittedAtLabel, 60) || new Date().toISOString(),
    }),
  },

  // Three local ids (manual approval, MTN auto-settlement, receipt) all
  // represent the same business fact — "payment verified, subscription
  // active" — which is the one hosted template School Pulse published.
  manual_payment_approved: {
    alias: 'payment-verified-1',
    variables: (data) => ({
      school_name: text(data.schoolName, 160) || 'A school',
      amount: text(data.amountLabel, 60) || formatAmount(data.amount),
      payment_method: text(data.methodLabel, 60) || 'Unknown',
      payment_reference: humanReference('receipt', data.paymentId),
      plan_name: text(data.planLabel, 80) || 'School Pulse',
      subscription_start: text(data.startLabel, 60) || 'Today',
      subscription_end: text(data.expiryLabel, 60) || 'N/A',
    }),
  },
  mobile_money_payment_success: {
    alias: 'payment-verified-1',
    variables: (data) => ({
      school_name: text(data.schoolName, 160) || 'A school',
      amount: text(data.amountLabel, 60) || formatAmount(data.amount),
      payment_method: 'MTN Mobile Money',
      payment_reference: humanReference('receipt', data.paymentId),
      plan_name: text(data.planLabel, 80) || 'School Pulse',
      subscription_start: text(data.startLabel, 60) || 'Today',
      subscription_end: text(data.expiryLabel, 60) || 'N/A',
    }),
  },

  // Both rejection paths (manual review, MTN failure) represent the same
  // "payment needs attention" business fact.
  manual_payment_rejected: {
    alias: 'payment-needs-attention',
    variables: (data) => ({
      school_name: text(data.schoolName, 160) || 'A school',
      amount: text(data.amountLabel, 60) || formatAmount(data.amount),
      payment_method: text(data.methodLabel, 60) || 'Unknown',
      payment_reference: humanReference('payment', data.paymentId),
      rejection_reason: text(data.reason, 500) || 'No reason provided.',
    }),
  },
  mobile_money_payment_failed: {
    alias: 'payment-needs-attention',
    variables: (data) => ({
      school_name: text(data.schoolName, 160) || 'A school',
      amount: text(data.amountLabel, 60) || formatAmount(data.amount),
      payment_method: 'MTN Mobile Money',
      payment_reference: humanReference('payment', data.paymentId),
      rejection_reason: text(data.reason, 500) || 'No reason provided.',
    }),
  },

  subscription_renewed: {
    alias: 'subscription-renewed',
    variables: (data) => ({
      school_name: text(data.schoolName, 160) || 'A school',
      plan_name: text(data.planLabel, 80) || 'School Pulse',
      amount: text(data.amountLabel, 60) || formatAmount(data.amount),
      payment_method: text(data.methodLabel, 60) || 'Unknown',
      payment_reference: humanReference('receipt', data.paymentId),
      subscription_start: text(data.startLabel, 60) || 'Today',
      subscription_end: text(data.expiryLabel, 60) || 'N/A',
    }),
  },

  subscription_expiring: {
    alias: 'subscription-expiring-soon',
    variables: (data) => ({
      school_name: text(data.schoolName, 160) || 'A school',
      plan_name: text(data.planLabel, 80) || 'School Pulse',
      subscription_end: text(data.expiryLabel, 60) || 'N/A',
      days_remaining: String(Number(data.daysRemaining || 0)),
      renewal_amount: text(data.renewalAmountLabel, 60) || 'N/A',
    }),
  },

  subscription_expired: {
    alias: 'subscription-expired',
    variables: (data) => ({
      school_name: text(data.schoolName, 160) || 'A school',
      plan_name: text(data.planLabel, 80) || 'School Pulse',
      subscription_end: text(data.expiryLabel, 60) || 'N/A',
      renewal_amount: text(data.renewalAmountLabel, 60) || 'N/A',
    }),
  },

  school_admin_account_created: {
    alias: 'school-admin-welcome',
    // No adminName field exists anywhere in the school_admin_invitations
    // provisioning doc (see functions/index.js provisionSchoolAdmin) -
    // display name there defaults to "{schoolName} Admin" too. admin_email
    // falls back to `data.email` (already required for delivery to reach
    // this recipient at all), never a placeholder string.
    variables: (data) => ({
      admin_name: text(data.adminName, 160) || 'Administrator',
      school_name: text(data.schoolName, 160) || 'A school',
      admin_email: text(data.email, 200) || text(data.adminEmail, 200),
    }),
  },

  new_login_alert: {
    alias: 'new-login-alert',
    variables: (data) => ({
      account_email: text(data.email, 200),
      device_name: text(data.deviceLabel, 160) || 'Unknown device',
      platform: text(data.platform, 60) || text(data.deviceLabel, 60) || 'Unknown',
      signed_in_at: text(data.whenLabel, 60) || new Date().toISOString(),
      // Deliberately never a raw IP (see owner_sign_in_events.js) - only a
      // coarse label or the safe "Unknown location" fallback.
      location: text(data.locationLabel, 120) || 'Unknown location',
    }),
  },

  suspicious_login_alert: {
    alias: 'suspicious-activity-alert',
    variables: (data) => ({
      account_email: text(data.email, 200),
      activity_type: text(data.activityType, 80) || 'Suspicious sign-in',
      device_name: text(data.deviceLabel, 160) || 'Unknown device',
      activity_time: text(data.whenLabel, 60) || new Date().toISOString(),
      location: text(data.locationLabel, 120) || 'Unknown location',
      alert_reason: text(data.reason, 300) || 'Sign-in pattern differed from the previous session.',
    }),
  },

  appointment_confirmed: {
    alias: 'appointment-confirmed',
    variables: (data) => ({
      school_name: text(data.schoolName, 160) || 'Your school',
      staff_name: text(data.withLabel, 160) || 'your host',
      appointment_date: text(data.dateLabel, 60) || text(data.timeLabel, 60) || 'To be confirmed',
      appointment_time: text(data.timeLabel, 60) || 'To be confirmed',
      appointment_reference: humanReference('appointment', data.appointmentId),
      appointment_purpose: text(data.purpose, 300) || 'Not specified',
    }),
  },

  appointment_cancelled: {
    alias: 'appointment-cancelled',
    variables: (data) => ({
      school_name: text(data.schoolName, 160) || 'Your school',
      staff_name: text(data.withLabel, 160) || 'your host',
      appointment_date: text(data.dateLabel, 60) || text(data.timeLabel, 60) || 'Not specified',
      appointment_time: text(data.timeLabel, 60) || 'Not specified',
      appointment_reference: humanReference('appointment', data.appointmentId),
      cancellation_reason: text(data.reason, 500) || 'No reason given.',
    }),
  },

  appointment_reminder: {
    alias: 'appointment-reminder',
    variables: (data) => ({
      school_name: text(data.schoolName, 160) || 'Your school',
      staff_name: text(data.withLabel, 160) || 'your host',
      appointment_date: text(data.dateLabel, 60) || text(data.timeLabel, 60) || 'To be confirmed',
      appointment_time: text(data.timeLabel, 60) || 'To be confirmed',
      appointment_reference: humanReference('appointment', data.appointmentId),
      appointment_purpose: text(data.purpose, 300) || 'Not specified',
    }),
  },

  report_available: {
    alias: 'report-available',
    variables: (data) => ({
      student_name: text(data.studentName, 160) || 'Student',
      school_name: text(data.schoolName, 160) || 'Your school',
      report_name: text(data.reportName, 160) || 'Report',
      academic_period: text(data.periodLabel, 60) || 'This term',
      published_at: text(data.publishedByLabel, 60) || new Date().toISOString(),
    }),
  },
};

function getHostedTemplate(templateId) {
  return HOSTED_TEMPLATES[templateId] || null;
}

module.exports = { HOSTED_TEMPLATES, getHostedTemplate };
