const { escapeHtml, humanReference } = require('../email_helpers');
const { STATUS_URL } = require('../branding');

module.exports = {
  appointment_requested: (data) => {
    const reference = humanReference('appointment', data.appointmentId);
    return {
      subject: 'New appointment request',
      preheader: `An appointment has been requested at ${data.schoolName}.`,
      eyebrow: 'Appointment requested',
      title: 'New appointment request',
      status: 'pending',
      bodyText: `A new appointment has been requested at ${data.schoolName}.`,
      bodyHtml: `<p>A new appointment has been requested at <strong>${escapeHtml(data.schoolName)}</strong>.</p>`,
      infoRows: [
        { label: 'Reference', value: reference },
        { label: 'With', value: data.withLabel },
        { label: 'Requested time', value: data.requestedTimeLabel },
        { label: 'Reason', value: data.reason },
      ],
      secondaryText: "We'll confirm the appointment once it has been reviewed.",
      cta: { label: 'View Appointment', url: STATUS_URL },
    };
  },

  appointment_confirmed: (data) => {
    const reference = humanReference('appointment', data.appointmentId);
    return {
      subject: 'Your appointment has been confirmed',
      preheader: `Your appointment at ${data.schoolName} is confirmed.`,
      eyebrow: 'Appointment confirmed',
      title: 'Your appointment has been confirmed',
      status: 'success',
      bodyText: `Your appointment at ${data.schoolName} has been confirmed.`,
      bodyHtml: `<p>Your appointment at <strong>${escapeHtml(data.schoolName)}</strong> has been confirmed.</p>`,
      infoRows: [
        { label: 'Reference', value: reference },
        { label: 'With', value: data.withLabel },
        { label: 'Date & time', value: data.timeLabel },
        { label: 'Location', value: data.locationLabel },
      ],
      cta: { label: 'View Appointment', url: STATUS_URL },
    };
  },

  appointment_rescheduled: (data) => {
    const reference = humanReference('appointment', data.appointmentId);
    return {
      subject: 'Your appointment has been rescheduled',
      preheader: `Your appointment at ${data.schoolName} has a new time.`,
      eyebrow: 'Appointment rescheduled',
      title: 'Your appointment has been rescheduled',
      status: 'warning',
      bodyText: `Your appointment at ${data.schoolName} has been rescheduled.`,
      bodyHtml: `<p>Your appointment at <strong>${escapeHtml(data.schoolName)}</strong> has been rescheduled.</p>`,
      infoRows: [
        { label: 'Reference', value: reference },
        { label: 'With', value: data.withLabel },
        { label: 'New date & time', value: data.newTimeLabel },
        { label: 'Previous time', value: data.previousTimeLabel },
      ],
      cta: { label: 'View Appointment', url: STATUS_URL },
    };
  },

  appointment_cancelled: (data) => {
    const reference = humanReference('appointment', data.appointmentId);
    return {
      subject: 'Your appointment has been cancelled',
      preheader: `Your appointment at ${data.schoolName} was cancelled.`,
      eyebrow: 'Appointment cancelled',
      title: 'Your appointment has been cancelled',
      status: 'error',
      bodyText: `Your appointment at ${data.schoolName} has been cancelled.`,
      bodyHtml: `<p>Your appointment at <strong>${escapeHtml(data.schoolName)}</strong> has been cancelled.</p>`,
      infoRows: [
        { label: 'Reference', value: reference },
        { label: 'With', value: data.withLabel },
        { label: 'Was scheduled for', value: data.timeLabel },
        { label: 'Reason', value: data.reason },
      ],
      secondaryText: 'You can request a new appointment at any time.',
      cta: { label: 'Request New Appointment', url: STATUS_URL },
    };
  },

  appointment_reminder: (data) => {
    const reference = humanReference('appointment', data.appointmentId);
    return {
      subject: 'Reminder: upcoming appointment',
      preheader: `Reminder for your appointment at ${data.schoolName}.`,
      eyebrow: 'Appointment reminder',
      title: 'Upcoming appointment reminder',
      status: 'information',
      bodyText: `This is a reminder of your upcoming appointment at ${data.schoolName}.`,
      bodyHtml: `<p>This is a reminder of your upcoming appointment at <strong>${escapeHtml(data.schoolName)}</strong>.</p>`,
      infoRows: [
        { label: 'Reference', value: reference },
        { label: 'With', value: data.withLabel },
        { label: 'Date & time', value: data.timeLabel },
        { label: 'Location', value: data.locationLabel },
      ],
      cta: { label: 'View Appointment', url: STATUS_URL },
    };
  },
};
