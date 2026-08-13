const { escapeHtml } = require('../email_helpers');
const { STATUS_URL, SUPPORT_EMAIL } = require('../branding');

module.exports = {
  school_admin_account_created: (data) => ({
    subject: 'Your School Pulse administrator account is ready',
    preheader: `Your administrator account for ${data.schoolName} is ready.`,
    eyebrow: 'Account created',
    title: 'Your administrator account is ready',
    status: 'success',
    bodyText: `Your School Pulse administrator account for ${data.schoolName} has been created.`,
    bodyHtml: `<p>Your School Pulse administrator account for <strong>${escapeHtml(data.schoolName)}</strong> has been created.</p>`,
    infoRows: [
      { label: 'School', value: data.schoolName },
      { label: 'Email', value: data.email },
      { label: 'Role', value: 'School Administrator' },
    ],
    secondaryText: 'Sign in to complete your school setup.',
    cta: { label: 'Sign In', url: STATUS_URL },
  }),

  staff_account_created: (data) => ({
    subject: 'Your School Pulse staff account is ready',
    preheader: `Your staff account at ${data.schoolName} is ready.`,
    eyebrow: 'Account created',
    title: 'Your staff account is ready',
    status: 'success',
    bodyText: `Your School Pulse staff account at ${data.schoolName} has been created.`,
    bodyHtml: `<p>Your School Pulse staff account at <strong>${escapeHtml(data.schoolName)}</strong> has been created.</p>`,
    infoRows: [
      { label: 'School', value: data.schoolName },
      { label: 'Email', value: data.email },
      { label: 'Role', value: data.roleLabel },
    ],
    secondaryText: 'Sign in with your credentials to get started.',
    cta: { label: 'Sign In', url: STATUS_URL },
  }),

  password_reset: (data) => ({
    subject: 'Reset your School Pulse password',
    preheader: 'Use this link to reset your password.',
    eyebrow: 'Password reset',
    title: 'Reset your password',
    status: 'information',
    bodyText: 'We received a request to reset your School Pulse password. Use the link below to choose a new one.',
    bodyHtml: `<p>We received a request to reset your School Pulse password. Use the button below to choose a new one.</p>`,
    infoRows: [
      { label: 'Account', value: data.email },
    ],
    secondaryText: 'If you did not request this, you can safely ignore this email — your password will not change.',
    cta: { label: 'Reset Password', url: data.resetUrl || STATUS_URL },
  }),

  email_verification: (data) => ({
    subject: 'Verify your School Pulse email',
    preheader: 'Confirm your email address to finish setting up your School Pulse account.',
    eyebrow: 'Verify your email',
    title: 'Verify your email',
    status: 'information',
    bodyText: `Hi ${data.userName || 'there'}, confirm your email address to finish setting up your School Pulse account.`,
    bodyHtml: `<p>Hi ${escapeHtml(data.userName || 'there')}, confirm your email address to finish setting up your School Pulse account.</p>`,
    infoRows: [],
    secondaryText: "For your security, only use this link if you created or requested access to this School Pulse account. If you didn't request this, you can safely ignore this email.",
    cta: { label: 'Verify email address', url: data.verificationUrl || STATUS_URL },
  }),

  password_changed: (data) => ({
    subject: 'Your School Pulse password was changed',
    preheader: 'Your password was just changed.',
    eyebrow: 'Password changed',
    title: 'Your password was changed',
    status: 'success',
    bodyText: 'Your School Pulse account password was just changed.',
    bodyHtml: `<p>Your School Pulse account password was just changed.</p>`,
    infoRows: [
      { label: 'Account', value: data.email },
      { label: 'When', value: data.whenLabel },
    ],
    secondaryText: `If you didn't make this change, contact us immediately at ${SUPPORT_EMAIL}.`,
    cta: { label: 'Contact Support', url: `mailto:${SUPPORT_EMAIL}` },
  }),
};
