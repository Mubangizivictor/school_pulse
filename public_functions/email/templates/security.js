const { STATUS_URL, SUPPORT_EMAIL } = require('../branding');

module.exports = {
  new_login_alert: (data) => ({
    subject: 'New sign-in to your School Pulse account',
    preheader: 'We noticed a new sign-in to your account.',
    eyebrow: 'Security alert',
    title: 'New sign-in detected',
    status: 'information',
    bodyText: 'We noticed a new sign-in to your School Pulse account.',
    bodyHtml: `<p>We noticed a new sign-in to your School Pulse account.</p>`,
    infoRows: [
      { label: 'Account', value: data.email },
      { label: 'Device', value: data.deviceLabel },
      { label: 'Location', value: data.locationLabel },
      { label: 'When', value: data.whenLabel },
    ],
    secondaryText: `If this was you, no action is needed. If not, contact us at ${SUPPORT_EMAIL} immediately.`,
    cta: { label: 'Review Account Activity', url: STATUS_URL },
  }),

  suspicious_login_alert: (data) => ({
    subject: 'Suspicious sign-in attempt on your School Pulse account',
    preheader: 'We blocked a suspicious sign-in attempt.',
    eyebrow: 'Security alert',
    title: 'Suspicious sign-in attempt',
    status: 'warning',
    bodyText: 'We detected a suspicious sign-in attempt on your School Pulse account.',
    bodyHtml: `<p>We detected a suspicious sign-in attempt on your School Pulse account.</p>`,
    infoRows: [
      { label: 'Account', value: data.email },
      { label: 'Device', value: data.deviceLabel },
      { label: 'Location', value: data.locationLabel },
      { label: 'When', value: data.whenLabel },
    ],
    secondaryText: `If this wasn't you, we recommend changing your password immediately and contacting ${SUPPORT_EMAIL}.`,
    cta: { label: 'Secure My Account', url: STATUS_URL },
  }),

  sessions_revoked: (data) => ({
    subject: 'Your School Pulse sessions were signed out',
    preheader: 'All active sessions on your account were signed out.',
    eyebrow: 'Security update',
    title: 'Your sessions were signed out',
    status: 'information',
    bodyText: 'All active sessions on your School Pulse account have been signed out.',
    bodyHtml: `<p>All active sessions on your School Pulse account have been signed out.</p>`,
    infoRows: [
      { label: 'Account', value: data.email },
      { label: 'Reason', value: data.reason },
    ],
    secondaryText: "You'll need to sign in again on each of your devices.",
    cta: { label: 'Sign In', url: STATUS_URL },
  }),

  account_locked: (data) => ({
    subject: 'Your School Pulse account has been locked',
    preheader: 'Your account has been locked for security.',
    eyebrow: 'Account locked',
    title: 'Your account has been locked',
    status: 'error',
    bodyText: 'Your School Pulse account has been locked for security reasons.',
    bodyHtml: `<p>Your School Pulse account has been locked for security reasons.</p>`,
    infoRows: [
      { label: 'Account', value: data.email },
      { label: 'Reason', value: data.reason },
    ],
    secondaryText: `Contact ${SUPPORT_EMAIL} to unlock your account.`,
    cta: { label: 'Contact Support', url: `mailto:${SUPPORT_EMAIL}` },
  }),

  account_reactivated: (data) => ({
    subject: 'Your School Pulse account has been reactivated',
    preheader: 'Your account is active again.',
    eyebrow: 'Account reactivated',
    title: 'Your account has been reactivated',
    status: 'success',
    bodyText: 'Your School Pulse account has been reactivated and you can sign in again.',
    bodyHtml: `<p>Your School Pulse account has been reactivated and you can sign in again.</p>`,
    infoRows: [
      { label: 'Account', value: data.email },
    ],
    cta: { label: 'Sign In', url: STATUS_URL },
  }),
};
