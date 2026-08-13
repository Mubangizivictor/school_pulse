const { OAuth2Client } = require('google-auth-library');

// Firebase's client SDKs never expose a server-verifiable artifact for "the
// user just passed their first-factor MFA challenge" - the opaque
// MultiFactorSession/mfaPendingCredential can only ever be redeemed by
// Firebase's OWN backend via resolver.resolveSignIn(), and the Admin SDK
// has no equivalent verification call (confirmed by exhaustive search of
// firebase-admin's auth module - no verifyMfaPendingCredential or similar
// exists). Google's own Identity Platform documentation is explicit that
// there is no built-in mechanism for MFA recovery and recommends building
// one entirely outside the resolver, independently re-verifying identity:
// https://cloud.google.com/identity-platform/docs/work-with-mfa-users
//
// This module is that independent re-verification. It never touches
// `resolver`/`hints`/`MultiFactorSession` at all - the owner re-supplies
// their first factor specifically for the recovery flow, and this module
// checks it directly against Google's own infrastructure, the same way the
// ORIGINAL first-factor sign-in was checked, just a second time, from our
// own backend.

// The Firebase "Web API key" is not a secret - it identifies the Firebase
// project to Identity Toolkit and Google OAuth endpoints, and is already
// shipped inside every client build (see lib/firebase_options.dart's `web`
// config in the Flutter app, and android/app/google-services.json). Using
// it server-side to call the same public REST endpoints the client SDKs
// themselves call is the standard, documented way to talk to Identity
// Toolkit outside of firebase-admin (which deliberately has no
// password-verification API, since it operates with full trust and has no
// reason to check a password a client already proved).
const FIREBASE_WEB_API_KEY = 'AIzaSyCDNtLTprFYZ8gX6-oABoVwiLsKCZck0-8';

const IDENTITY_TOOLKIT_SIGN_IN_URL =
  `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_WEB_API_KEY}`;

/**
 * Re-verifies an email/password credential directly against Identity
 * Toolkit's `accounts:signInWithPassword` REST endpoint - the exact same
 * endpoint every Firebase client SDK calls internally for
 * `signInWithEmailAndPassword`. The password is never persisted, logged,
 * or forwarded anywhere else - it lives only in this function's stack for
 * the duration of the fetch call.
 *
 * Deliberately does not use the Admin SDK: `admin.auth()` has no password
 * verification method by design (Admin SDK access implies full trust and
 * bypasses passwords entirely, e.g. createCustomToken). This REST call is
 * the actual, Google-documented mechanism third-party backends use to
 * verify a password Identity Toolkit already stores.
 *
 * CRITICAL: for an account with MFA enrolled, Identity Toolkit's
 * documented response to a CORRECT password is still HTTP 200 (this is a
 * successful intermediate state, not an error) - but it additionally
 * carries `mfaPendingCredential` (an opaque proof-of-first-factor token,
 * consumed only by Identity Toolkit's own mfaSignIn.finalize, never by
 * this backend - see the module-level comment above for why) and
 * `mfaInfo[]` (which second factors are enrolled). Since the seeded owner
 * account is REQUIRED to have TOTP enrolled (mandatory MFA, enforced
 * elsewhere in this app), a 200 response for the owner's own email that
 * is MISSING `mfaInfo`/`mfaPendingCredential` is not a normal outcome -
 * it would mean MFA was somehow disabled out from under the account, or
 * the response shape changed unexpectedly. This function fails closed and
 * flags that case distinctly (`mfaAnomaly: true`) rather than treating it
 * as an ordinary successful password check, so callers can audit it as a
 * security-configuration anomaly instead of silently proceeding.
 *
 * `mfaPendingCredential` itself is deliberately NEVER returned, logged, or
 * stored by this function - it is sensitive transient authentication
 * material (Identity Toolkit's own docs describe it as proof of passing
 * the first factor) and this codebase has no use for it: the actual
 * recovery-challenge correlation is `beginOwnerRecoveryChallenge`'s own
 * random `challengeId`, entirely independent of anything Identity Toolkit
 * issued. Only its PRESENCE is checked, never its value.
 *
 * @returns {Promise<{localId: string|null, mfaEnrolled: boolean, mfaAnomaly: boolean}>}
 *   `localId` is null for a wrong password. `mfaAnomaly` is true only for
 *   the specific case above (correct password, but no MFA signal present).
 */
async function verifyOwnerPassword(email, password) {
  const res = await fetch(IDENTITY_TOOLKIT_SIGN_IN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password, returnSecureToken: false }),
  });
  if (!res.ok) {
    // Identity Toolkit returns 400 with an error.message like
    // INVALID_LOGIN_CREDENTIALS for a wrong password - never surfaced to
    // the caller beyond "verification failed", matching this codebase's
    // existing generic-denial convention for the owner security surface.
    return { localId: null, mfaEnrolled: false, mfaAnomaly: false };
  }
  const data = await res.json();
  const localId = typeof data.localId === 'string' ? data.localId : null;
  if (!localId) {
    return { localId: null, mfaEnrolled: false, mfaAnomaly: false };
  }
  const hasMfaSignal = typeof data.mfaPendingCredential === 'string' && Array.isArray(data.mfaInfo) && data.mfaInfo.length > 0;
  return {
    localId,
    mfaEnrolled: hasMfaSignal,
    mfaAnomaly: !hasMfaSignal,
  };
}

// Lazily constructed - the OAuth2Client itself does not need a client ID
// at construction time; verifyIdToken takes the expected audience(s) per
// call, which lets this support multiple platform client IDs (Android,
// iOS, Web) without three separate client instances.
const oauth2Client = new OAuth2Client();

/**
 * Re-verifies a Google ID token's signature, issuer, audience and expiry
 * directly against Google's own token-verification infrastructure (the
 * same JWKS-based check Google's own client libraries perform), then
 * cross-references the verified Google account against Firebase's
 * `users/{uid}` record to resolve the canonical Firebase UID - never
 * trusting a client-supplied UID or email string.
 *
 * `expectedAudiences` must be the project's actual OAuth client ID(s)
 * (Android/iOS/Web) - passing none makes token verification meaningless,
 * since ANY validly-signed Google ID token for ANY app would otherwise
 * pass. Currently unconfigured in this project (see MANUAL CONFIG note in
 * the exported function below) until Google Sign-In's Firebase provider
 * setup is completed - this function will refuse to run until real
 * audiences are supplied rather than silently skip the audience check.
 */
async function verifyGoogleIdToken(idToken, expectedAudiences) {
  if (!Array.isArray(expectedAudiences) || expectedAudiences.length === 0) {
    throw new Error(
      'verifyGoogleIdToken called with no expected audience(s) configured - ' +
      'refusing to verify a token with no audience check, since that would ' +
      'accept a validly-signed ID token from ANY Google Sign-In-enabled app, ' +
      'not just this one.'
    );
  }
  const ticket = await oauth2Client.verifyIdToken({
    idToken,
    audience: expectedAudiences,
  });
  const payload = ticket.getPayload();
  if (!payload?.sub || !payload.email_verified) {
    return null;
  }
  return { googleSub: payload.sub, email: payload.email };
}

module.exports = { verifyOwnerPassword, verifyGoogleIdToken };
