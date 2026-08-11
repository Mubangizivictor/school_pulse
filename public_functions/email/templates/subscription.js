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

  subscription_expiring: (data) => ({
    subject: 'Your School Pulse subscription is expiring soon',
    preheader: `${data.schoolName}'s subscription expires soon.`,
    eyebrow: 'Renewal reminder',
    title: 'Your subscription is expiring soon',
    status: 'warning',
    bodyText: `${data.schoolName}'s School Pulse subscription will expire soon. Renew now to avoid interruption.`,
    bodyHtml: `<p><strong>${escapeHtml(data.schoolName)}</strong>'s School Pulse subscription will expire soon. Renew now to avoid interruption.</p>`,
    infoRows: [
      { label: 'School', value: data.schoolName },
      { label: 'Plan', value: data.planLabel },
      { label: 'Expires', value: data.expiryLabel },
    ],
    cta: { label: 'Renew Subscription', url: STATUS_URL },
  }),

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
