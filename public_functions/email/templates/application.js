const { escapeHtml, humanReference } = require('../email_helpers');
const { STATUS_URL, SUPPORT_EMAIL } = require('../branding');

module.exports = {
  application_received: (data) => {
    const reference = humanReference('application', data.applicationId);
    return {
      subject: 'We received your School Pulse application',
      preheader: `${data.schoolName} is now under review.`,
      eyebrow: 'Application received',
      title: 'We received your application',
      status: 'pending',
      bodyText: `Thanks for applying to School Pulse. ${data.schoolName} is now under review.`,
      bodyHtml: `<p>Thanks for applying to School Pulse. <strong>${escapeHtml(data.schoolName)}</strong> is now under review.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Application reference', value: reference },
        { label: 'Status', value: 'Under review' },
      ],
      secondaryText: 'We will email you again as soon as a decision is made.',
      cta: { label: 'View Application Status', url: STATUS_URL },
    };
  },

  application_approved: (data) => {
    const reference = humanReference('application', data.applicationId);
    return {
      subject: 'Your School Pulse application has been approved',
      preheader: `${data.schoolName} has been approved.`,
      eyebrow: 'Application approved',
      title: 'Your application has been approved',
      status: 'success',
      bodyText: `Congratulations. ${data.schoolName} has been approved to continue onboarding to School Pulse.`,
      bodyHtml: `<p>Congratulations. <strong>${escapeHtml(data.schoolName)}</strong> has been approved to continue onboarding to School Pulse.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Application reference', value: reference },
      ],
      secondaryText: 'Complete your subscription payment to activate your School Pulse environment.',
      cta: { label: 'Continue Setup', url: STATUS_URL },
    };
  },

  application_rejected: (data) => {
    const reference = humanReference('application', data.applicationId);
    return {
      subject: 'Update on your School Pulse application',
      preheader: `An update on ${data.schoolName}'s application.`,
      eyebrow: 'Application update',
      title: 'An update on your application',
      status: 'error',
      bodyText: `Thank you for your interest in School Pulse. After review, we're unable to approve ${data.schoolName}'s application at this time.`,
      bodyHtml: `<p>Thank you for your interest in School Pulse. After review, we're unable to approve <strong>${escapeHtml(data.schoolName)}</strong>'s application at this time.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Application reference', value: reference },
        { label: 'Reason', value: data.reason },
      ],
      secondaryText: 'If you believe this was a mistake or would like to provide more information, please contact support.',
      cta: { label: 'Contact Support', url: `mailto:${SUPPORT_EMAIL}` },
    };
  },

  application_more_info_required: (data) => {
    const reference = humanReference('application', data.applicationId);
    return {
      subject: 'More information needed for your School Pulse application',
      preheader: `We need more information about ${data.schoolName}'s application.`,
      eyebrow: 'Action needed',
      title: 'We need more information',
      status: 'warning',
      bodyText: `To continue reviewing ${data.schoolName}'s application, we need some additional information from you.`,
      bodyHtml: `<p>To continue reviewing <strong>${escapeHtml(data.schoolName)}</strong>'s application, we need some additional information from you.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Application reference', value: reference },
        { label: 'Requested information', value: data.requestedInfo },
      ],
      secondaryText: 'Please respond as soon as possible so we can continue processing your application.',
      cta: { label: 'View Application Status', url: STATUS_URL },
    };
  },
};
