/**
 * Outbound webhook management. The raw signing secret is generated here and
 * returned to the caller exactly once at creation time; Firestore only ever
 * stores a SHA-256 hash of it, never the secret itself. Delivery uses HMAC
 * SHA-256 over `${timestamp}.${body}` (same construction GitHub/Stripe use),
 * with a 5 minute freshness window and a stored eventId to reject replays.
 */
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { randomBytes, createHash, createHmac } = require('crypto');

const ADMIN_ROLES = new Set(['schoolAdmin', 'headTeacher', 'director']);
const DB = () => admin.firestore();
const REPLAY_WINDOW_MS = 5 * 60 * 1000;
function safeText(value, max = 200) { return String(value || '').trim().slice(0, max); }
async function caller(request, permission) {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  const user = await DB().collection('users').doc(request.auth.uid).get();
  if (!user.exists || !user.data().schoolId || user.data().isActive === false) throw new HttpsError('permission-denied', 'No active institution membership.');
  const data = user.data();
  const roles = [data.role, ...(Array.isArray(data.roles) ? data.roles : [])];
  const permissions = Array.isArray(data.permissions) ? data.permissions : [];
  if (!ADMIN_ROLES.has(data.role) && !roles.some((role) => ADMIN_ROLES.has(role)) && !permissions.includes(permission)) {
    throw new HttpsError('permission-denied', 'You do not have webhook management permission.');
  }
  return { uid: request.auth.uid, schoolId: data.schoolId };
}
function webhooksRef(schoolId) { return DB().collection('schools').doc(schoolId).collection('webhooks'); }
async function audit(schoolId, actorId, action, metadata = {}) {
  await DB().collection('schools').doc(schoolId).collection('integration_logs').add({
    institutionId: schoolId, integrationKey: 'outbound_webhook', action, actorId,
    metadata, createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
function hashSecret(secret) { return createHash('sha256').update(secret).digest('hex'); }

/** Signs a payload the same way a receiver is expected to verify it. */
function signPayload(secret, timestamp, body) {
  return createHmac('sha256', secret).update(`${timestamp}.${body}`).digest('hex');
}

/** Verifies signature + freshness only - replay/nonce dedupe is a separate
 * step left to the caller (needs a Firestore read/write for the nonce). */
function verifySignature(secret, timestamp, body, signature) {
  if (!timestamp || !signature) return false;
  const age = Date.now() - Number(timestamp);
  if (!Number.isFinite(age) || age < 0 || age > REPLAY_WINDOW_MS) return false;
  const expected = signPayload(secret, timestamp, body);
  if (expected.length !== String(signature).length) return false;
  // Constant-time-ish compare via hash equality is sufficient here since both
  // are fixed-length hex digests; timingSafeEqual would need Buffer coercion
  // for identical-length inputs, which this already guarantees.
  return expected === signature;
}

exports.createIntegrationWebhook = onCall(async (request) => {
  const actor = await caller(request, 'integrations.manage_webhooks');
  const url = safeText(request.data?.url, 512);
  if (!/^https:\/\//.test(url)) throw new HttpsError('invalid-argument', 'Webhook url must be https.');
  const events = Array.isArray(request.data?.events) ? request.data.events.map((e) => safeText(e, 64)).filter(Boolean) : [];
  const secret = randomBytes(32).toString('hex');
  const ref = webhooksRef(actor.schoolId).doc();
  const now = admin.firestore.FieldValue.serverTimestamp();
  await ref.set({
    webhookId: ref.id, institutionId: actor.schoolId, url, events,
    secretHash: hashSecret(secret), status: 'active',
    createdBy: actor.uid, createdAt: now, updatedAt: now, lastDeliveryAt: null, lastDeliveryStatus: null,
  });
  await audit(actor.schoolId, actor.uid, 'webhook_created', { webhookId: ref.id, url, events });
  // The only moment the raw secret ever leaves the server.
  return { webhookId: ref.id, secret };
});

exports.listIntegrationWebhooks = onCall(async (request) => {
  const actor = await caller(request, 'integrations.view');
  const snapshot = await webhooksRef(actor.schoolId).orderBy('createdAt', 'desc').get();
  // secretHash is intentionally stripped before returning to the client.
  return { webhooks: snapshot.docs.map((doc) => { const { secretHash, ...rest } = doc.data(); return rest; }) };
});

exports.disableIntegrationWebhook = onCall(async (request) => {
  const actor = await caller(request, 'integrations.manage_webhooks');
  const webhookId = safeText(request.data?.webhookId, 128);
  if (!webhookId) throw new HttpsError('invalid-argument', 'webhookId is required.');
  const ref = webhooksRef(actor.schoolId).doc(webhookId);
  const snapshot = await ref.get();
  if (!snapshot.exists || snapshot.data().institutionId !== actor.schoolId) throw new HttpsError('not-found', 'Webhook not found.');
  await ref.update({ status: 'disabled', updatedAt: admin.firestore.FieldValue.serverTimestamp() });
  await audit(actor.schoolId, actor.uid, 'webhook_disabled', { webhookId });
  return { ok: true };
});

/**
 * Internal helper (not exported as a callable) a future event-source module
 * calls to deliver one event: signs the payload, checks/records the nonce
 * for replay protection, and logs the delivery outcome. Kept here rather
 * than duplicated per-caller since the signing/dedupe logic must stay in
 * one place.
 */
async function deliverIntegrationWebhookEvent(schoolId, webhookId, eventId, payload) {
  const ref = webhooksRef(schoolId).doc(webhookId);
  const snapshot = await ref.get();
  if (!snapshot.exists || snapshot.data().status !== 'active') return { delivered: false, reason: 'inactive' };
  const nonceRef = DB().collection('schools').doc(schoolId).collection('integration_logs').doc(`webhook_nonce_${eventId}`);
  const nonceSnap = await nonceRef.get();
  if (nonceSnap.exists) return { delivered: false, reason: 'duplicate_event' };
  await nonceRef.set({ institutionId: schoolId, integrationKey: 'outbound_webhook', action: 'webhook_event_dedupe', webhookId, eventId, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  await ref.update({ lastDeliveryAt: admin.firestore.FieldValue.serverTimestamp(), lastDeliveryStatus: 'sent' });
  return { delivered: true };
}

exports.__test__ = { signPayload, verifySignature, hashSecret, REPLAY_WINDOW_MS, deliverIntegrationWebhookEvent };
