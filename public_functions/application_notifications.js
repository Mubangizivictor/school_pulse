const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const { notifyOwners } = require('./owner_notification_engine');
const { RESEND_API_KEY } = require('./email/email_service');
const { enqueueTemplatedEmail } = require('./email/transactional_queue');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

function text(value, max = 180) {
  return String(value ?? '').trim().slice(0, max);
}

const EMAIL_SECRETS = [
  'SMTP_HOST',
  'SMTP_PORT',
  'SMTP_USER',
  'SMTP_PASS',
  'SMTP_FROM',
  'OWNER_NOTIFICATION_EMAIL',
  RESEND_API_KEY,
];

/**
 * Notify the SaaS Owner exactly once when an application enters pending_review.
 * Draft documents exist before final submission, so create-only triggers are
 * insufficient; this watches the actual state transition.
 */
exports.notifyOwnerOfSchoolApplication = onDocumentWritten(
  {
    region: 'europe-west1',
    document: 'public_school_applications/{applicationId}',
    secrets: EMAIL_SECRETS,
  },
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;

    const application = after.data() || {};
    const before = event.data?.before?.exists ? (event.data.before.data() || {}) : {};
    const afterStatus = String(application.status || '');
    const beforeStatus = String(before.status || '');

    const applicationId = event.params.applicationId;
    const schoolName = text(application.school?.name, 160) || 'A school';
    const applicantEmail = text(application.administrator?.email, 200);

    if (afterStatus === 'pending_review' && beforeStatus !== 'pending_review') {
      const plan = text(application.plan, 60) || 'School Pulse';
      const district = text(application.location?.district, 100);
      const adminName = [
        text(application.administrator?.firstName, 80),
        text(application.administrator?.lastName, 80),
      ].filter(Boolean).join(' ');
      const body = `${schoolName} submitted a ${plan} application${district ? ` from ${district}` : ''}. Review the school before requesting payment.`;

      await notifyOwners({
        eventId: `school_application_${applicationId}_pending_review`,
        eventType: 'New school application',
        title: 'New school application',
        body,
        schoolName,
        data: {
          type: 'school_application',
          notificationType: 'custom',
          priority: 'high',
          sourceModule: 'super_admin',
          sourceEntityId: applicationId,
          applicationId,
          schoolName,
          plan,
          district,
          administratorName: adminName,
        },
      });

      await enqueueTemplatedEmail({
        eventId: `application_received_${applicationId}`,
        templateId: 'application_received',
        to: applicantEmail,
        data: { schoolName, applicationId },
      });
      return;
    }

    if (afterStatus === 'approved' && beforeStatus !== 'approved') {
      await enqueueTemplatedEmail({
        eventId: `application_approved_${applicationId}`,
        templateId: 'application_approved',
        to: applicantEmail,
        data: { schoolName, applicationId },
      });

      // Push, alongside the email above, to any device the applicant has
      // already registered (users/{uid}/tokens — the same registration path
      // every other signed-in user's push notifications use). An applicant
      // has no schoolId yet, so there's no school-scoped in-app inbox this
      // can land in; email plus push (when a token exists) is what's
      // reachable pre-onboarding.
      const applicantUid = text(application.authUid || application.id, 160);
      if (applicantUid) {
        await queueApplicantPush({
          applicantUid,
          applicationId,
          type: 'application_approved',
          title: 'Application approved',
          body: `${schoolName} has been approved. Complete your subscription payment to activate your School Pulse environment.`,
        }).catch((error) => console.error('Applicant push notification failed', applicationId, error));
      }
      return;
    }

    if (afterStatus === 'rejected' && beforeStatus !== 'rejected') {
      await enqueueTemplatedEmail({
        eventId: `application_rejected_${applicationId}`,
        templateId: 'application_rejected',
        to: applicantEmail,
        data: { schoolName, applicationId, reason: text(application.rejectionReason, 500) },
      });
    }
  },
);

async function queueApplicantPush({ applicantUid, applicationId, type, title, body }) {
  const tokensSnap = await db.collection('users').doc(applicantUid).collection('tokens').get();
  if (tokensSnap.empty) return;

  const batch = db.batch();
  for (const tokenDoc of tokensSnap.docs) {
    batch.set(db.collection('notification_queue').doc(), {
      token: tokenDoc.id,
      status: 'pending',
      notification: { title, body },
      data: { type, applicationId },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
}
