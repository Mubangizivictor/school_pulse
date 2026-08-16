const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');
const { sendTemplatedEmail, RESEND_API_KEY } = require('./email_service');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const COLLECTION = 'transactional_email_queue';

// Bounded retry schedule: short first retry, longer second retry, then give
// up. No infinite retries, per the "no repeated duplicate sends / bounded
// maximum" requirement — a permanently-failing send (bad address, Resend
// outage) should not retry forever.
const RETRY_DELAYS_MS = [2 * 60 * 1000, 20 * 60 * 1000]; // +2min, +20min
const MAX_ATTEMPTS = RETRY_DELAYS_MS.length + 1;

/**
 * Enqueue a templated transactional email for later delivery. This is the
 * integration seam for code that can't (or shouldn't) depend on Resend
 * directly — e.g. the separate `functions/` codebase, which has no Resend
 * secret configured. Writing a queue doc here and letting this codebase's
 * trigger drain it keeps Resend access — and template rendering — in one
 * place.
 *
 * `eventId` must be a caller-supplied idempotency key (e.g.
 * `staff_account_created_{uid}`); it is used as both the queue doc id and
 * the underlying email_deliveries doc id, so re-enqueuing the same eventId
 * after a successful send is a safe no-op.
 */
async function enqueueTemplatedEmail({ eventId, templateId, to, data = {}, schoolBranding = null, attachments = [] }) {
  if (!eventId) throw new Error('enqueueTemplatedEmail: eventId is required.');
  const ref = db.collection(COLLECTION).doc(eventId);
  await ref.set({
    eventId,
    templateId,
    to: String(to || '').trim().toLowerCase(),
    data,
    schoolBranding: schoolBranding || null,
    // Store descriptors only. PDF bytes stay in private Cloud Storage and are
    // loaded by the trusted sender immediately before the Resend call.
    attachments: Array.isArray(attachments) ? attachments.map((attachment) => ({
      filename: String(attachment?.filename || '').slice(0, 180),
      storagePath: String(attachment?.storagePath || '').slice(0, 800),
      contentType: String(attachment?.contentType || 'application/pdf').slice(0, 80),
      documentId: String(attachment?.documentId || '').slice(0, 180),
    })).filter((attachment) => attachment.filename && attachment.storagePath) : [],
    status: 'queued',
    attempts: 0,
    scheduledAt: admin.firestore.FieldValue.serverTimestamp(),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    sentAt: null,
    resendId: null,
    error: null,
  }, { merge: true });
  return ref.id;
}

async function attemptDelivery(snap) {
  const queueDoc = snap.data() || {};
  const status = String(queueDoc.status || '');
  if (!['queued', 'retrying'].includes(status)) return;

  const ref = snap.ref;
  const attempts = Number(queueDoc.attempts || 0) + 1;

  await ref.set({ status: 'processing', attempts }, { merge: true });

  try {
    const result = await sendTemplatedEmail({
      eventId: queueDoc.eventId || snap.id,
      templateId: queueDoc.templateId,
      to: queueDoc.to,
      data: queueDoc.data || {},
      schoolBranding: queueDoc.schoolBranding || null,
      attachments: queueDoc.attachments || [],
    });

    if (result.status === 'sent' || result.status === 'no_recipient') {
      await ref.set({
        status: result.status === 'sent' ? 'sent' : 'cancelled',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        resendId: result.resendId || null,
        error: result.status === 'no_recipient' ? 'no_recipient' : null,
      }, { merge: true });
      return;
    }

    // sendTemplatedEmail itself reported failure (Resend error) — fall
    // through to the shared retry/give-up logic below. `result.retryable`
    // comes from resend_error_classifier.js: false means this is a
    // configuration problem (bad template/variables/sender), which no
    // amount of retrying fixes, so it skips straight to `failed` instead of
    // waiting out the full bounded schedule. Undefined (e.g. a non-Resend
    // throw elsewhere) is treated as retryable, matching prior behavior.
    await scheduleRetryOrFail(ref, attempts, result.error || 'send_failed', result.retryable !== false);
  } catch (error) {
    await scheduleRetryOrFail(ref, attempts, error?.message || String(error), true);
  }
}

async function scheduleRetryOrFail(ref, attempts, error, retryable) {
  if (!retryable || attempts >= MAX_ATTEMPTS) {
    await ref.set({ status: 'failed', error: String(error).slice(0, 600), retryable: Boolean(retryable) }, { merge: true });
    console.error('TRANSACTIONAL_EMAIL_FAILED', ref.id, error, retryable ? '(max attempts reached)' : '(non-retryable)');
    return;
  }
  const delay = RETRY_DELAYS_MS[attempts - 1] || RETRY_DELAYS_MS[RETRY_DELAYS_MS.length - 1];
  await ref.set({
    status: 'retrying',
    error: String(error).slice(0, 600),
    scheduledAt: admin.firestore.Timestamp.fromMillis(Date.now() + delay),
  }, { merge: true });
}

const EMAIL_SECRETS = [RESEND_API_KEY];

exports.processTransactionalEmailQueue = onDocumentCreated(
  { region: 'europe-west1', document: `${COLLECTION}/{eventId}`, secrets: EMAIL_SECRETS },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    await attemptDelivery(snap);
  },
);

// Retries: a doc moved to `retrying` needs a second attempt once its
// scheduledAt has passed. onDocumentUpdated only fires on writes we already
// made ourselves (status flips), so this scans for anything due rather than
// reacting to every update — Firestore triggers can't do a "fire at future
// timestamp" wait natively.
exports.retryTransactionalEmailQueue = onSchedule(
  { region: 'europe-west1', schedule: 'every 5 minutes', secrets: EMAIL_SECRETS },
  async () => {
    const now = admin.firestore.Timestamp.now();
    const due = await db.collection(COLLECTION)
      .where('status', '==', 'retrying')
      .where('scheduledAt', '<=', now)
      .limit(100)
      .get();
    for (const doc of due.docs) {
      await attemptDelivery(doc);
    }
  },
);

module.exports.enqueueTemplatedEmail = enqueueTemplatedEmail;
module.exports.__test__ = { scheduleRetryOrFail, MAX_ATTEMPTS, RETRY_DELAYS_MS };
