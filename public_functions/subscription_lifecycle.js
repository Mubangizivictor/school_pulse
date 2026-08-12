const { onSchedule } = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');
const { RESEND_API_KEY } = require('./email/email_service');
const { enqueueTemplatedEmail } = require('./email/transactional_queue');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

// Nearest-tier-first: the first entry whose day threshold is >= days
// remaining is the one tier fired per run. 1 day is the last warning before
// "expired" (day 0) takes over via the separate expiry branch below.
const EXPIRING_TIERS_DAYS = [30, 14, 7, 3, 1];

function text(value, max = 200) {
  return String(value ?? '').trim().slice(0, max);
}

function dateLabel(ms) {
  return ms > 0 ? new Date(ms).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' }) : '';
}

async function schoolAdminEmail(schoolId) {
  const snap = await db.collection('users')
    .where('schoolId', '==', schoolId)
    .where('role', '==', 'schoolAdmin')
    .limit(1)
    .get();
  if (snap.empty) return '';
  return text(snap.docs[0].data()?.email, 200);
}

/**
 * Hourly subscription-lifecycle sweep: expiring-soon reminders (30/14/7/3/1
 * days out) and the expiry transition to read-only. Manual-payment
 * approval/rejection already sends subscription_activated/renewed/
 * manual_payment_* directly (see payment_notifications.js) and already
 * writes accessMode on approval/rejection - this job only covers the
 * purely time-based transition nothing else observes: a paid term quietly
 * running out while the school is otherwise untouched.
 *
 * Idempotency: each expiring-tier notification is deduped by a deterministic
 * eventId (school + expiry value + tier), so the enqueueTemplatedEmail/
 * email_deliveries ledger itself prevents duplicates across runs - no
 * separate "already notified" bookkeeping is needed for the tiers. The
 * expired-transition notification keeps its own metadata.lastExpiredNotifiedFor
 * guard since it also gates the accessMode write, not just the email.
 */
exports.checkSubscriptionLifecycle = onSchedule(
  { region: 'europe-west1', schedule: 'every 1 hours', timeZone: 'Africa/Kampala', secrets: [RESEND_API_KEY] },
  async () => {
    const nowMs = Date.now();
    const snapshot = await db.collection('schools')
      .where('status', 'in', ['trial', 'active'])
      .get();

    for (const doc of snapshot.docs) {
      const school = doc.data() || {};
      const schoolId = doc.id;
      const expiryMs = Number(school.subscriptionExpiry || 0);
      if (!expiryMs) continue;

      const schoolName = text(school.name, 160) || 'Your school';
      const planLabel = text(school.subscriptionPlanId, 60);
      const metadata = school.metadata && typeof school.metadata === 'object' ? school.metadata : {};

      try {
        if (expiryMs > nowMs) {
          const daysUntilExpiry = Math.ceil((expiryMs - nowMs) / (24 * 60 * 60 * 1000));
          const tier = EXPIRING_TIERS_DAYS.find((tierDays) => daysUntilExpiry <= tierDays);
          if (tier) {
            const recipient = await schoolAdminEmail(schoolId);
            await enqueueTemplatedEmail({
              eventId: `subscription_expiring_${schoolId}_${expiryMs}_${tier}`,
              templateId: 'subscription_expiring',
              to: recipient,
              data: { schoolName, planLabel, expiryLabel: dateLabel(expiryMs), daysRemaining: tier },
            });
          }
          continue;
        }

        if (metadata.lastExpiredNotifiedFor !== expiryMs) {
          const recipient = await schoolAdminEmail(schoolId);
          await enqueueTemplatedEmail({
            eventId: `subscription_expired_${schoolId}_${expiryMs}`,
            templateId: 'subscription_expired',
            to: recipient,
            data: { schoolName, planLabel, expiryLabel: dateLabel(expiryMs) },
          });
          // Reuses the same "payment_due" vocabulary rejectManualPayment
          // already writes for a renewal gone unpaid - not a new status.
          // accessMode is the field Firestore rules and the Flutter gate
          // actually trust; subscriptionStatus stays for display/email copy.
          await doc.ref.set({
            accessMode: 'readOnly',
            metadata: { ...metadata, lastExpiredNotifiedFor: expiryMs, subscriptionStatus: 'payment_due' },
          }, { merge: true });
        }
      } catch (error) {
        console.error('Subscription lifecycle sweep failed for school', schoolId, error);
      }
    }
  },
);
