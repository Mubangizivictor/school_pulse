const { escapeHtml, formatAmount, humanReference } = require('../email_helpers');
const { STATUS_URL } = require('../branding');

module.exports = {
  subscription_activated: (data) => ({
    subject: 'Your School Pulse subscription is active',
    preheader: `${data.schoolName}'s subscription is now active.`,
    eyebrow: 'Subscription activated',
    title: 'Your subscription is active',
    status: 'success',
    bodyText: `${data.schoolName}'s School Pulse subscription is now active.`,
    bodyHtml: `<p><strong>${escapeHtml(data.schoolName)}</strong>'s School Pulse subscription is now active.</p>`,
    infoRows: [
      { label: 'School', value: data.schoolName },
      { label: 'Plan', value: data.planLabel },
      { label: 'Renews', value: data.expiryLabel },
    ],
    cta: { label: 'Go to Dashboard', url: STATUS_URL },
  }),

  subscription_renewed: (data) => ({
    subject: 'Your School Pulse subscription has been renewed',
    preheader: `${data.schoolName}'s subscription has been renewed.`,
    eyebrow: 'Subscription renewed',
    title: 'Your subscription has been renewed',
    status: 'success',
    bodyText: `${data.schoolName}'s School Pulse subscription has been renewed.`,
    bodyHtml: `<p><strong>${escapeHtml(data.schoolName)}</strong>'s School Pulse subscription has been renewed.</p>`,
    infoRows: [
      { label: 'School', value: data.schoolName },
      { label: 'Plan', value: data.planLabel },
      { label: 'Amount', value: data.amountLabel || formatAmount(data.amount) },
      { label: 'Next renewal', value: data.expiryLabel },
    ],
    cta: { label: 'View Subscription', url: STATUS_URL },
  }),

  subscription_expiring: (data) => {
    const days = Number(data.daysRemaining || 0);
    const dayLabel = days === 1 ? '1 day' : `${days} days`;
    return {
      subject: `Your School Pulse subscription expires in ${dayLabel}`,
      preheader: `${data.schoolName}'s subscription expires in ${dayLabel}.`,
      eyebrow: 'Renewal reminder',
      title: `Your subscription expires in ${dayLabel}`,
      status: 'warning',
      bodyText: `${data.schoolName}'s School Pulse subscription will expire in ${dayLabel}. Renew now to avoid interruption.`,
      bodyHtml: `<p><strong>${escapeHtml(data.schoolName)}</strong>'s School Pulse subscription will expire in ${dayLabel}. Renew now to avoid interruption.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Plan', value: data.planLabel },
        { label: 'Expires', value: data.expiryLabel },
      ],
      cta: { label: 'Renew Subscription', url: STATUS_URL },
    };
  },

  subscription_expired: (data) => ({
    subject: 'Your School Pulse subscription has expired',
    preheader: `${data.schoolName}'s subscription has expired.`,
    eyebrow: 'Subscription expired',
    title: 'Your subscription has expired',
    status: 'error',
    bodyText: `${data.schoolName}'s School Pulse subscription has expired. Renew now to restore access.`,
    bodyHtml: `<p><strong>${escapeHtml(data.schoolName)}</strong>'s School Pulse subscription has expired. Renew now to restore access.</p>`,
    infoRows: [
      { label: 'School', value: data.schoolName },
      { label: 'Plan', value: data.planLabel },
      { label: 'Expired on', value: data.expiryLabel },
    ],
    cta: { label: 'Renew Now', url: STATUS_URL },
  }),

  subscription_suspended: (data) => ({
    subject: 'Your School Pulse subscription has been suspended',
    preheader: `${data.schoolName}'s subscription has been suspended.`,
    eyebrow: 'Subscription suspended',
    title: 'Your subscription has been suspended',
    status: 'error',
    bodyText: `${data.schoolName}'s School Pulse subscription has been suspended.`,
    bodyHtml: `<p><strong>${escapeHtml(data.schoolName)}</strong>'s School Pulse subscription has been suspended.</p>`,
    infoRows: [
      { label: 'School', value: data.schoolName },
      { label: 'Reason', value: data.reason },
    ],
    secondaryText: 'Please contact support to resolve this and restore access.',
    cta: { label: 'Contact Support', url: STATUS_URL },
  }),

  subscription_reactivated: (data) => ({
    subject: 'Your School Pulse subscription has been reactivated',
    preheader: `${data.schoolName}'s subscription has been reactivated.`,
    eyebrow: 'Subscription reactivated',
    title: 'Your subscription has been reactivated',
    status: 'success',
    bodyText: `${data.schoolName}'s School Pulse subscription has been reactivated.`,
    bodyHtml: `<p><strong>${escapeHtml(data.schoolName)}</strong>'s School Pulse subscription has been reactivated.</p>`,
    infoRows: [
      { label: 'School', value: data.schoolName },
      { label: 'Plan', value: data.planLabel },
      { label: 'Renews', value: data.expiryLabel },
    ],
    cta: { label: 'Go to Dashboard', url: STATUS_URL },
  }),

  // Phase 2A term-based billing (public_functions/subscription_cycle_billing.js).
  // Distinct from the legacy flat-expiry subscription_expiring/subscription_expired
  // templates above - these describe a specific subscription_cycles invoice/
  // reminder/grace event, not the whole-subscription expiry. Kept at the
  // same plain-text/simple-HTML polish level as the rest of this file.
  cycle_invoice_issued: (data) => ({
    subject: `Invoice issued for ${data.termName || 'your next term'}`,
    preheader: `An invoice for ${data.schoolName} has been issued.`,
    eyebrow: 'Invoice issued',
    title: 'A new invoice has been issued',
    status: 'info',
    bodyText: `An invoice for ${data.schoolName}'s ${data.termName || 'upcoming term'} has been issued.`,
    bodyHtml: `<p>An invoice for <strong>${escapeHtml(data.schoolName)}</strong>'s ${escapeHtml(data.termName || 'upcoming term')} has been issued.</p>`,
    infoRows: [
      { label: 'School', value: data.schoolName },
      { label: 'Term', value: data.termName },
      { label: 'Amount due', value: data.amountLabel },
      { label: 'Due date', value: data.dueLabel },
    ],
    cta: { label: 'Make Payment', url: STATUS_URL },
  }),

  cycle_reminder: (data) => ({
    subject: `Payment reminder: ${data.termName || 'your subscription'}`,
    preheader: `A payment reminder for ${data.schoolName}.`,
    eyebrow: 'Payment reminder',
    title: 'Your payment is due',
    status: 'warning',
    bodyText: `A reminder that payment for ${data.schoolName}'s ${data.termName || 'current term'} is due.`,
    bodyHtml: `<p>A reminder that payment for <strong>${escapeHtml(data.schoolName)}</strong>'s ${escapeHtml(data.termName || 'current term')} is due.</p>`,
    infoRows: [
      { label: 'School', value: data.schoolName },
      { label: 'Term', value: data.termName },
      { label: 'Amount due', value: data.amountLabel },
      { label: 'Due date', value: data.dueLabel },
    ],
    cta: { label: 'Make Payment', url: STATUS_URL },
  }),

  cycle_grace_expiring: (data) => ({
    subject: `Grace period ending soon for ${data.schoolName}`,
    preheader: `The grace period for ${data.schoolName} is about to end.`,
    eyebrow: 'Grace period ending',
    title: 'Your grace period is ending soon',
    status: 'error',
    bodyText: `The grace period for ${data.schoolName}'s ${data.termName || 'current term'} ends soon. Pay now to avoid suspension.`,
    bodyHtml: `<p>The grace period for <strong>${escapeHtml(data.schoolName)}</strong>'s ${escapeHtml(data.termName || 'current term')} ends soon. Pay now to avoid suspension.</p>`,
    infoRows: [
      { label: 'School', value: data.schoolName },
      { label: 'Term', value: data.termName },
      { label: 'Amount due', value: data.amountLabel },
      { label: 'Grace ends', value: data.graceLabel },
    ],
    secondaryText: 'Access will be suspended automatically if payment is not received before the grace period ends.',
    cta: { label: 'Make Payment', url: STATUS_URL },
  }),

  payment_overdue: (data) => {
    const reference = humanReference('subscription', data.schoolId || data.schoolName);
    return {
      subject: 'Payment overdue for your School Pulse subscription',
      preheader: `A payment for ${data.schoolName} is overdue.`,
      eyebrow: 'Payment overdue',
      title: 'Your payment is overdue',
      status: 'error',
      bodyText: `The subscription payment for ${data.schoolName} is overdue.`,
      bodyHtml: `<p>The subscription payment for <strong>${escapeHtml(data.schoolName)}</strong> is overdue.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Reference', value: reference },
        { label: 'Amount due', value: data.amountLabel || formatAmount(data.amount) },
        { label: 'Due date', value: data.dueDateLabel },
      ],
      secondaryText: 'Please make payment as soon as possible to avoid service interruption.',
      cta: { label: 'Make Payment', url: STATUS_URL },
    };
  },
};
