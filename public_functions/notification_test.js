const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { notifyOwners } = require('./owner_notification_engine');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

async function requireOwner(request) {
  if (!request.auth?.uid) throw new HttpsError('unauthenticated', 'Sign in as the School Pulse owner first.');
  const snap = await db.collection('users').doc(request.auth.uid).get();
  const user = snap.data() || {};
  const roles = Array.isArray(user.roles) ? user.roles : [];
  if (user.isActive === false || (user.role !== 'superAdmin' && !roles.includes('superAdmin') && user.isSuperAdmin !== true)) {
    throw new HttpsError('permission-denied', 'Only the School Pulse SaaS Owner can run notification diagnostics.');
  }
  return { uid: request.auth.uid, user };
}

/**
 * Owner-only end-to-end diagnostic. It writes the same in-app alert and runs
 * the same FCM + SMTP paths as real application/payment notifications, then
 * returns channel-by-channel delivery results for troubleshooting.
 */
exports.testOwnerNotificationDelivery = onCall(
  {
    region: 'europe-west1',
    secrets: ['SMTP_HOST', 'SMTP_PORT', 'SMTP_USER', 'SMTP_PASS', 'SMTP_FROM', 'OWNER_NOTIFICATION_EMAIL'],
  },
  async (request) => {
    const owner = await requireOwner(request);
    const eventId = `owner_test_${owner.uid}_${Date.now()}`;
    const result = await notifyOwners({
      eventId,
      eventType: 'Notification system test',
      title: 'School Pulse notification test',
      body: 'If you received this alert, the owner notification pipeline is connected correctly.',
      schoolName: '',
      data: { type: 'owner_notification_test', ownerId: owner.uid },
    });

    return {
      ok: true,
      eventId,
      ownerIds: result.ownerIds || [],
      inApp: result.inApp || null,
      push: result.push || null,
      email: result.email || null,
    };
  },
);
