const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { enqueueTemplatedEmail } = require('./email/transactional_queue');
const { WEBSITE_ORIGIN } = require('./email/branding');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

function text(value, max = 200) {
  return String(value ?? '').trim().slice(0, max);
}

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const RESET_ACTION_SETTINGS = {
  url: `${WEBSITE_ORIGIN}/app/`,
  handleCodeInApp: false,
};

function cors(req, res) {
  const origin = req.get('origin');
  if (origin === WEBSITE_ORIGIN || origin === 'http://localhost:4321') {
    res.set('Access-Control-Allow-Origin', origin);
  }
  res.set('Vary', 'Origin');
  res.set('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return true;
  }
  return false;
}

/**
 * IP-keyed hourly rate limit, mirroring index.js's `rateLimit(req, bucket,
 * limit)` for the same reason that endpoint needs one: this is a public,
 * unauthenticated endpoint (the caller has no account session yet, that's
 * the entire point of "forgot password"), so ownerRateLimit's UID-keyed
 * scheme doesn't apply here.
 */
async function ipRateLimit(req, bucket, limit) {
  const ip = text(req.ip || req.get('x-forwarded-for') || 'unknown', 80);
  const hour = new Date().toISOString().slice(0, 13);
  const key = `${bucket}_${Buffer.from(ip).toString('hex').slice(0, 80)}_${hour}`;
  const ref = db.collection('_public_rate_limits').doc(key);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const count = snap.exists ? Number(snap.data()?.count ?? 0) : 0;
    if (count >= limit) return false;
    tx.set(ref, { count: count + 1, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    return true;
  });
}

/**
 * Requests delivery of a Firebase password-reset link through the existing
 * Resend transactional pipeline, replacing Firebase Auth's own default
 * delivery - mirrors email_verification.js's requestEmailVerification
 * exactly, but for password reset and for a caller who is NOT signed in.
 *
 * Deliberately always returns the same 200 response whether or not the
 * email belongs to an account - this is a public, unauthenticated endpoint,
 * so responding differently for "unknown email" vs "sent" would let a
 * caller enumerate registered accounts.
 */
exports.requestPasswordReset = onRequest({ region: 'europe-west1' }, async (req, res) => {
  if (cors(req, res)) return;
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'method_not_allowed' });
    return;
  }

  const email = text(req.body?.email, 320).toLowerCase();
  if (!email || !EMAIL_RE.test(email)) {
    res.status(400).json({ error: 'invalid_email', message: 'Enter a valid email address.' });
    return;
  }

  const allowed = await ipRateLimit(req, 'request_password_reset', 5);
  if (!allowed) {
    res.status(429).json({ error: 'rate_limited', message: 'Too many reset requests. Please try again later.' });
    return;
  }

  const generic = { ok: true, message: 'If an account exists for that email, a reset link has been sent.' };

  let authUser;
  try {
    authUser = await admin.auth().getUserByEmail(email);
  } catch (_) {
    res.status(200).json(generic);
    return;
  }

  let resetUrl;
  try {
    resetUrl = await admin.auth().generatePasswordResetLink(email, RESET_ACTION_SETTINGS);
  } catch (error) {
    // Never reveal link-generation failures to the caller - same generic
    // response either way, only the server log tells the two apart.
    console.error('generatePasswordResetLink failed', authUser.uid, error?.errorInfo?.code || error?.code || 'unknown_error');
    res.status(200).json(generic);
    return;
  }

  const userName = text(authUser.displayName, 160) || (email.split('@')[0] || 'there');
  const hour = new Date().toISOString().slice(0, 13);
  const eventId = `password_reset_${authUser.uid}_${hour}`;

  await enqueueTemplatedEmail({
    eventId,
    templateId: 'password_reset',
    to: email,
    data: { userName, resetUrl, email },
  }).catch((error) => console.error('password_reset enqueue failed', authUser.uid, error));

  res.status(200).json(generic);
});
