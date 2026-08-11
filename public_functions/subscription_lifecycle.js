const { onSchedule } = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');
const { RESEND_API_KEY } = require('./email/email_service');
const { enqueueTemplatedEmail } = require('./email/transactional_queue');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const EXPIRING_SOON_MS = 7 * 24 * 60 * 60 * 1000; // notify 7 days out
const OVERDUE_GRACE_MS = 3 * 24 * 60 * 60 * 1000; // first overdue reminder 3 days after expiry
const OVERDUE_REPEAT_MS = 5 * 24 * 60 * 60 * 1000; // repeat overdue reminder every 5 days after that

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
 * Daily subscription-lifecycle sweep: expiring-soon reminders, expiry
 * transition, and repeating overdue nudges. Manual-payment approval/
 * rejection already sends subscription_activated/renewed/manual_payment_*
 * directly (see payment_notifications.js) — this only covers the
 * time-based transitions nothing else observes.
 *
 * Idempotency: each notification type is only sent once per expiry value
 * (metadata.lastExpiringNotifiedFor / lastExpiredNotifiedFor track the
 * subscriptionExpiry timestamp they were sent for), except the overdue
 * reminder, which is intentionally recurring on a fixed cadence
 * (metadata.lastOverdueNotifiedAt).
 */
exports.checkSubscriptionLifecycle = onSchedule(
  { region: 'europe-west1', schedule: 'every day 06:00', timeZone: 'Africa/Kampala', secrets: [RESEND_API_KEY] },
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
        if (expiryMs > nowMs && expiryMs - nowMs <= EXPIRING_SOON_MS) {
          if (metadata.lastExpiringNotifiedFor === expiryMs) continue;
          const recipient = await schoolAdminEmail(schoolId);
          await enqueueTemplatedEmail({
            eventId: `subscription_expiring_${schoolId}_${expiryMs}`,
            templateId: 'subscription_expiring',
            to: recipient,
            data: { schoolName, planLabel, expiryLabel: dateLabel(expiryMs) },
          });
          await doc.ref.set({ metadata: { ...metadata, lastExpiringNotifiedFor: expiryMs } }, { merge: true });
          continue;
        }

        if (expiryMs <= nowMs) {
          if (metadata.lastExpiredNotifiedFor !== expiryMs) {
            const recipient = await schoolAdminEmail(schoolId);
            await enqueueTemplatedEmail({
              eventId: `subscription_expired_${schoolId}_${expiryMs}`,
              templateId: 'subscription_expired',
              to: recipient,
              data: { schoolName, planLabel, expiryLabel: dateLabel(expiryMs) },
            });
            // Reuses the same "payment_due" vocabulary rejectManualPayment
            // already writes for a renewal gone unpaid — not a new status.
            await doc.ref.set({
              metadata: { ...metadata, lastExpiredNotifiedFor: expiryMs, subscriptionStatus: 'payment_due' },
            }, { merge: true });
          }

          const overdueMs = nowMs - expiryMs;
          const lastOverdueAt = Number(metadata.lastOverdueNotifiedAt || 0);
          const dueForOverdueReminder = overdueMs >= OVERDUE_GRACE_MS &&
            (lastOverdueAt === 0 || nowMs - lastOverdueAt >= OVERDUE_REPEAT_MS);
          if (dueForOverdueReminder) {
            const recipient = await schoolAdminEmail(schoolId);
            // Keyed off the overdue cycle's start (last reminder timestamp,
            // or the expiry itself for the first reminder) rather than
            // nowMs, so a retried/double-fired scheduler invocation within
            // the same cycle computes the same eventId and is deduped by
            // email_deliveries instead of sending a second reminder.
            await enqueueTemplatedEmail({
              eventId: `payment_overdue_${schoolId}_${lastOverdueAt || expiryMs}`,
              templateId: 'payment_overdue',
              to: recipient,
              data: { schoolName, schoolId, dueDateLabel: dateLabel(expiryMs) },
            });
            await doc.ref.set({ metadata: { ...metadata, lastOverdueNotifiedAt: nowMs } }, { merge: true });
          }
        }
      } catch (error) {
        console.error('Subscription lifecycle sweep failed for school', schoolId, error);
      }
    }
  },
);
