const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { isOwnerData } = require('./owner_notification_engine');
const { RESEND_API_KEY } = require('./email/email_service');
const { enqueueTemplatedEmail } = require('./email/transactional_queue');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const EMAIL_SECRETS = [RESEND_API_KEY];

function text(value, max = 200) {
  return String(value ?? '').trim().slice(0, max);
}

async function requireOwner(request) {
  if (!request.auth?.uid) {
    throw new HttpsError('unauthenticated', 'Sign in as the School Pulse SaaS Owner first.');
  }
  const snap = await db.collection('users').doc(request.auth.uid).get();
  const user = snap.data() || {};
  if (user.isActive === false || !isOwnerData(user)) {
    throw new HttpsError('permission-denied', 'Only the School Pulse SaaS Owner can perform this action.');
  }
  return { uid: request.auth.uid, user };
}

/**
 * Best-effort caller IP extraction for a v2 onCall function. Firebase
 * populates `x-forwarded-for` on the underlying Express request for
 * callable functions running behind Cloud Functions/Cloud Run. Only the
 * first (client-nearest) hop is kept, and the value never leaves the
 * server except as a coarse "differs from last time" signal used by the
 * suspicious-sign-in heuristic below - the raw IP itself is not returned
 * to the client from suspicious-activity reads (see the Flutter query,
 * which only ever selects timestamp/platform/reason fields for display).
 */
function callerIp(request) {
  const raw = request.rawRequest;
  if (!raw) return 'unknown';
  const forwarded = raw.get ? raw.get('x-forwarded-for') : raw.headers?.['x-forwarded-for'];
  if (forwarded) return text(String(forwarded).split(',')[0], 64);
  return text(raw.ip || raw.socket?.remoteAddress, 64) || 'unknown';
}

/**
 * Pure decision: given the suspicion heuristic's result and the sign-in
 * event's own doc id (already the idempotency anchor for the audit record
 * itself), which hosted template fires and under what eventId. Extracted so
 * it's testable without a Firestore emulator.
 */
function classifySignInEmail(suspicious, signInEventId) {
  return suspicious
    ? { templateId: 'suspicious_login_alert', eventId: `suspicious_login_${signInEventId}` }
    : { templateId: 'new_login_alert', eventId: `new_login_${signInEventId}` };
}

/**
 * Records an owner sign-in event, called by the Flutter client right after
 * a successful SaaS-owner login (see AuthBloc._syncNotifications). This
 * project has no Identity Platform blocking functions configured today
 * (no `beforeSignIn`/`beforeCreate` triggers anywhere in public_functions/
 * as of this change), so a callable invoked post-login is the smallest
 * addition that fits the existing patterns here rather than introducing a
 * new trigger type project-wide.
 *
 * Suspicion heuristic (intentionally simple, NOT real fraud detection):
 * flag the new event if the owner's IP or platform differs from their
 * immediately-preceding sign-in event. A first-ever sign-in is never
 * flagged (nothing to compare against).
 */
exports.logOwnerSignIn = onCall({ region: 'europe-west1', secrets: EMAIL_SECRETS }, async (request) => {
  const owner = await requireOwner(request);
  const platform = text(request.data?.platform, 40) || 'unknown';
  const ip = callerIp(request);
  const serverTime = admin.firestore.FieldValue.serverTimestamp();

  const priorSnap = await db
    .collection('super_admin_sign_in_events')
    .where('ownerId', '==', owner.uid)
    .orderBy('timestamp', 'desc')
    .limit(1)
    .get();

  let suspicious = false;
  let reason = null;
  if (!priorSnap.empty) {
    const prior = priorSnap.docs[0].data() || {};
    const ipChanged = prior.ip && prior.ip !== 'unknown' && prior.ip !== ip;
    const platformChanged = prior.platform && prior.platform !== 'unknown' && prior.platform !== platform;
    if (ipChanged || platformChanged) {
      suspicious = true;
      const parts = [];
      if (ipChanged) parts.push('IP address changed since the previous sign-in');
      if (platformChanged) parts.push('platform changed since the previous sign-in');
      reason = parts.join('; ');
    }
  }

  const ref = db.collection('super_admin_sign_in_events').doc();
  await ref.set({
    id: ref.id,
    ownerId: owner.uid,
    timestamp: serverTime,
    platform,
    ip,
    suspicious,
    reason,
  });

  // Email goes through the existing central queue -> hosted-template
  // pipeline (email/transactional_queue.js -> email/email_service.js),
  // exactly like every other business event in this codebase
  // (application_notifications.js, payment_notifications.js). Never calls
  // Resend directly from here. `whenLabel` and `locationLabel` deliberately
  // omit the raw IP: this codebase has no IP-geolocation capability, and a
  // raw IP is more identifying than a coarse label, not less - the hosted
  // template's own "Unknown location" fallback is used instead of inventing
  // a geolocation dependency or a fabricated risk signal.
  const whenLabel = new Date().toISOString();
  const emailData = { email: owner.user.email, deviceLabel: platform, platform, whenLabel };
  const decision = classifySignInEmail(suspicious, ref.id);

  await enqueueTemplatedEmail({
    eventId: decision.eventId,
    templateId: decision.templateId,
    to: owner.user.email,
    data: suspicious ? { ...emailData, activityType: 'Suspicious sign-in', reason } : emailData,
  }).catch((error) => console.error(`${decision.templateId} email enqueue failed`, ref.id, error));

  return { ok: true, suspicious };
});

/**
 * Revokes every existing session/ID token for the calling SaaS owner
 * across all devices, using the Admin SDK's revokeRefreshTokens. Unlike
 * the client-side `FirebaseAuth.instance.signOut()` this previously used
 * (which only ends the current device's local session), this actually
 * invalidates refresh tokens issued before this call project-wide, so any
 * other signed-in device is forced to re-authenticate the next time its
 * ID token is refreshed or verified server-side.
 */
exports.revokeOwnerSessions = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);

  await admin.auth().revokeRefreshTokens(owner.uid);

  const auditRef = db.collection('super_admin_audit_logs').doc();
  const serverTime = admin.firestore.FieldValue.serverTimestamp();
  await auditRef.set({
    id: auditRef.id,
    ownerId: owner.uid,
    action: 'REVOKE_ALL_SESSIONS',
    affectedUserId: owner.uid,
    timestamp: serverTime,
    device: 'Owner Console',
    metadata: { via: 'security_settings_deep_dive_screen' },
  });

  // Mark the owner's device/session registry docs revoked too, so Trusted
  // Devices / Active Sessions UI reflects the revocation. Lives at
  // super_admin_settings/{ownerId}/sessions/{deviceId} (see
  // owner_session_remote_data_source.dart) - token revocation above is
  // the real, independent source of truth regardless of this registry.
  try {
    const sessionsSnap = await db
      .collection('super_admin_settings')
      .doc(owner.uid)
      .collection('sessions')
      .get();
    if (!sessionsSnap.empty) {
      const batch = db.batch();
      sessionsSnap.docs.forEach((doc) => {
        batch.set(doc.ref, { revoked: true, revokedAt: serverTime }, { merge: true });
      });
      await batch.commit();
    }
  } catch (_) {
    // Collection absent or rules not yet defined for it - non-fatal.
  }

  return { ok: true };
});

exports.__test__ = { classifySignInEmail };
