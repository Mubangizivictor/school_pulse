const { escapeHtml } = require('../email_helpers');
const { STATUS_URL, SUPPORT_EMAIL } = require('../branding');

module.exports = {
  important_announcement: (data) => ({
    subject: data.subject || 'Important announcement from School Pulse',
    preheader: data.summary || 'An important announcement.',
    eyebrow: 'Announcement',
    title: data.title || 'Important announcement',
    status: 'information',
    bodyText: data.message,
    bodyHtml: `<p>${escapeHtml(data.message, 3000)}</p>`,
    secondaryText: data.secondaryText,
    cta: data.ctaLabel && data.ctaUrl ? { label: data.ctaLabel, url: data.ctaUrl } : { label: 'Open School Pulse', url: STATUS_URL },
  }),

  support_update: (data) => ({
    subject: data.subject || 'Update on your support request',
    preheader: 'An update on your support request.',
    eyebrow: 'Support update',
    title: 'Update on your support request',
    status: 'information',
    bodyText: data.message,
    bodyHtml: `<p>${escapeHtml(data.message, 3000)}</p>`,
    infoRows: [
      { label: 'Ticket reference', value: data.ticketReference },
      { label: 'Status', value: data.statusLabel },
    ],
    cta: { label: 'View Support Ticket', url: data.ctaUrl || `mailto:${SUPPORT_EMAIL}` },
  }),

  billing_action_required: (data) => ({
    subject: 'Action required on your School Pulse billing',
    preheader: `Billing action needed for ${data.schoolName}.`,
    eyebrow: 'Billing',
    title: 'Action required on your billing',
    status: 'warning',
    bodyText: `Your School Pulse billing for ${data.schoolName} needs attention.`,
    bodyHtml: `<p>Your School Pulse billing for <strong>${escapeHtml(data.schoolName)}</strong> needs attention.</p>`,
    infoRows: [
      { label: 'School', value: data.schoolName },
      { label: 'Reason', value: data.reason },
    ],
    secondaryText: 'Please resolve this as soon as possible to avoid service interruption.',
    cta: { label: 'Review Billing', url: STATUS_URL },
  }),
};
