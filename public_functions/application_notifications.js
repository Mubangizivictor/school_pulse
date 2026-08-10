const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { notifyOwners } = require('./owner_notification_engine');

function text(value, max = 180) {
  return String(value ?? '').trim().slice(0, max);
}

/**
 * Notify the SaaS Owner when an application ENTERS pending_review.
 *
 * This intentionally uses onDocumentWritten instead of onDocumentCreated:
 * registration drafts create the document before final submission, so a
 * create-only trigger can fire too early and permanently miss the real
 * pending_review transition.
 */
exports.notifyOwnerOfSchoolApplication = onDocumentWritten(
  {
    region: 'europe-west1',
    document: 'public_school_applications/{applicationId}',
    secrets: ['SMTP_HOST', 'SMTP_PORT', 'SMTP_USER', 'SMTP_PASS', 'SMTP_FROM', 'OWNER_NOTIFICATION_EMAIL'],
  },
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;

    const application = after.data() || {};
    const before = event.data?.before?.exists ? (event.data.before.data() || {}) : {};
    const afterStatus = String(application.status || '');
    const beforeStatus = String(before.status || '');

    if (afterStatus !== 'pending_review' || beforeStatus === 'pending_review') return;

    const applicationId = event.params.applicationId;
    const schoolName = text(application.school?.name, 160) || 'A school';
    const plan = text(application.plan, 60) || 'School Pulse';
    const district = text(application.location?.district, 100);
    const adminName = [
      text(application.administrator?.firstName, 80),
      text(application.administrator?.lastName, 80),
    ].filter(Boolean).join(' ');

    const body = `${schoolName} submitted a ${plan} application${district ? ` from ${district}` : ''}. Review the school before requesting payment.`;

    await notifyOwners({
      eventId: `school_application_${applicationId}_${text(event.id, 120)}`,
      eventType: 'New school application',
      title: 'New school application',
      body,
      schoolName,
      data: {
        type: 'school_application',
        applicationId,
        schoolName,
        plan,
        district,
        administratorName: adminName,
      },
    });
  },
);
