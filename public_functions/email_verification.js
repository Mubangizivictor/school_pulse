const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { enqueueTemplatedEmail } = require('./email/transactional_queue');
const { ownerRateLimit } = require('./owner_rate_limit');
const { WEBSITE_ORIGIN } = require('./email/branding');
const { isAllowedOrigin } = require('./allowed_origins');

if (!admin.apps.length) admin.initializeApp();

function text(value, max = 200) {
  return String(value ?? '').trim().slice(0, max);
}

const VERIFICATION_ACTION_SETTINGS = {
  url: `${WEBSITE_ORIGIN}/register-school?verified=1`,
  handleCodeInApp: false,
};

function cors(req, res) {
  const origin = req.get('origin');
  if (isAllowedOrigin(origin)) {
    res.set('Access-Control-Allow-Origin', origin);
  }
  res.set('Vary', 'Origin');
  res.set('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type,Authorization');
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return true;
  }
  return false;
}

/**
 * Same shape as draft.js's `identity()` / index.js's `verifiedIdentity()`,
 * except this one deliberately does NOT require `email_verified` on the
 * token — the entire point of this endpoint is to serve callers whose email
 * is not yet verified.
 */
async function identity(req) {
  const header = text(req.get('authorization'), 5000);
  if (!header.startsWith('Bearer ')) return null;
  try {
    return await admin.auth().verifyIdToken(header.slice(7));
  } catch (_) {
    return null;
  }
}

/**
 * Pure derivation of the display name and idempotency key used for the
 * queued email, extracted so it's testable without the Admin SDK/Firestore.
 * `eventId` is bucketed per-hour (not per-request) so a rapid double-tap
 * within the same rate-limit window is a safe idempotent no-op at the
 * queue/delivery layer too, on top of the rate limit itself.
 */
function buildVerificationEmailRequest({ uid, email, displayName, now = new Date() }) {
  const userName = text(displayName, 160) || (text(email).split('@')[0] || 'there');
  const hour = now.toISOString().slice(0, 13);
  const eventId = `email_verification_${uid}_${hour}`;
  return { userName, eventId };
}

/**
 * Classifies a thrown error from `admin.auth().generateEmailVerificationLink`
 * into the HTTP response this endpoint should send. Firebase Auth enforces
 * its own project-level abuse quota on link generation
 * (`auth/too-many-requests`, underlying reason TOO_MANY_ATTEMPTS_TRY_LATER)
 * independent of the ownerRateLimit check earlier in the request - a second,
 * Firebase-owned layer of protection for the same concern. Extracted as a
 * pure function so this mapping is testable without the Admin SDK.
 */
function classifyLinkGenerationError(error) {
  const code = error?.errorInfo?.code || error?.code || '';
  if (code === 'auth/too-many-requests') {
    return { status: 429, body: { error: 'rate_limited', message: 'Too many verification requests. Please try again later.' } };
  }
  return { status: 500, body: { error: 'link_generation_failed', message: 'Could not send the verification email. Please try again.' } };
}

/**
 * Requests delivery of a Firebase email-verification link through the
 * existing Resend transactional pipeline, replacing Firebase Auth's own
 * default delivery (the generic firebaseapp.com email). Firebase Auth
 * remains the sole generator/validator of the underlying action code -
 * this endpoint only asks the Admin SDK for a link and hands it to
 * `enqueueTemplatedEmail`; it never mints its own token and never sets
 * `emailVerified` itself.
 *
 * Recipient is always the CALLER's own verified-caller email, taken
 * server-side from `admin.auth().getUser(uid)` - never from client input -
 * so this cannot be used to spam an arbitrary address. Mirrors the plain
 * fetch()+Bearer-token calling convention every other website endpoint in
 * this codebase uses (see draft.js, index.js) rather than the Callable SDK
 * protocol, since the website never loads firebase/functions.
 */
exports.requestEmailVerification = onRequest({ region: 'europe-west1' }, async (req, res) => {
  if (cors(req, res)) return;
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'method_not_allowed' });
    return;
  }

  const caller = await identity(req);
  if (!caller?.uid) {
    res.status(401).json({ error: 'auth_required', message: 'Sign in to request email verification.' });
    return;
  }

  const allowed = await ownerRateLimit(caller.uid, 'request_email_verification', 3);
  if (!allowed) {
    res.status(429).json({ error: 'rate_limited', message: 'Too many verification requests. Please try again later.' });
    return;
  }

  let authUser;
  try {
    authUser = await admin.auth().getUser(caller.uid);
  } catch (_) {
    res.status(404).json({ error: 'account_not_found', message: 'Your account could not be found.' });
    return;
  }

  const email = text(authUser.email, 320);
  if (!email) {
    res.status(400).json({ error: 'no_email', message: 'Your account has no email address on file.' });
    return;
  }

  // Already verified: report success without generating or sending
  // anything new, and without revealing any other account detail.
  if (authUser.emailVerified) {
    res.status(200).json({ ok: true, alreadyVerified: true });
    return;
  }

  let verificationUrl;
  try {
    verificationUrl = await admin.auth().generateEmailVerificationLink(email, VERIFICATION_ACTION_SETTINGS);
  } catch (error) {
    // Never log the raw error, which can otherwise include the account email.
    const { status, body } = classifyLinkGenerationError(error);
    console.error('generateEmailVerificationLink failed', caller.uid, error?.errorInfo?.code || error?.code || 'unknown_error');
    res.status(status).json(body);
    return;
  }

  // Optional, non-authoritative display context only - never the recipient
  // or any security-relevant field. schoolName may legitimately be supplied
  // by the in-progress registration flow (the applicant hasn't submitted
  // their application yet, so there is no server record to read it from).
  const schoolName = text(req.body?.schoolName, 160);
  const { userName, eventId } = buildVerificationEmailRequest({ uid: caller.uid, email, displayName: authUser.displayName });

  await enqueueTemplatedEmail({
    eventId,
    templateId: 'email_verification',
    to: email,
    data: { userName, verificationUrl, ...(schoolName ? { schoolName } : {}) },
  }).catch((error) => console.error('email_verification enqueue failed', caller.uid, error));

  res.status(200).json({ ok: true, alreadyVerified: false });
});

exports.__test__ = { buildVerificationEmailRequest, VERIFICATION_ACTION_SETTINGS, classifyLinkGenerationError };
