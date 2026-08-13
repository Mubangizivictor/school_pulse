// Plain Node test runner (no framework dependency), matching the existing
// convention in this directory (see owner_sign_in_email.test.js). Covers the
// PURE decision logic extracted from verifyOwnerRecoveryCode's Firestore
// transaction (isChallengeValid / findUnusedCodeIndex) plus the
// normalize/hashCode helpers - i.e. the exact conditions under which a
// recovery-code + challenge pair is accepted or rejected. This repo has no
// Firestore-emulator test harness set up (grepped package.json - no
// firebase-functions-test / @firebase/rules-unit-testing dependency), so
// full end-to-end onCall behavior (actual admin.auth() calls, actual
// transactions) is NOT exercised here; run with:
//   node __tests__/owner_recovery_codes.test.js
const assert = require('node:assert/strict');
const {
  normalize,
  hashCode,
  hashNonce,
  isChallengeValid,
  findUnusedCodeIndex,
  CHALLENGE_TTL_MS,
} = require('../owner_recovery_codes').__test__;

let passed = 0;
let failed = 0;

function test(name, fn) {
  try {
    fn();
    passed += 1;
    console.log(`  ok  - ${name}`);
  } catch (error) {
    failed += 1;
    console.log(`FAIL  - ${name}`);
    console.log(`        ${error.message}`);
  }
}

const OWNER_UID = 'owner-uid-123';
const OTHER_UID = 'some-other-account-uid';
const NOW = 1_700_000_000_000;
const NONCE = 'a-sufficiently-random-client-nonce-1234';
const NONCE_HASH = hashNonce(NONCE);
const OTHER_NONCE_HASH = hashNonce('a-completely-different-nonce-value-5678');

function freshChallenge(overrides = {}) {
  return {
    ownerUid: OWNER_UID,
    used: false,
    nonceHash: NONCE_HASH,
    expiresAt: { toMillis: () => NOW + 60_000 },
    ...overrides,
  };
}

console.log('isChallengeValid()');

test('a fresh, unused, unexpired challenge for the right owner with the matching nonce is valid', () => {
  assert.equal(isChallengeValid(freshChallenge(), OWNER_UID, NOW, NONCE_HASH), true);
});

test('a null/missing challenge (challenge document does not exist) is rejected', () => {
  assert.equal(isChallengeValid(null, OWNER_UID, NOW, NONCE_HASH), false);
});

test('a challenge belonging to a DIFFERENT owner UID is rejected - a challenge can never be reused across accounts', () => {
  assert.equal(isChallengeValid(freshChallenge({ ownerUid: OTHER_UID }), OWNER_UID, NOW, NONCE_HASH), false);
});

test('an already-used challenge is rejected - same challenge cannot be redeemed twice', () => {
  assert.equal(isChallengeValid(freshChallenge({ used: true }), OWNER_UID, NOW, NONCE_HASH), false);
});

test('an expired challenge is rejected', () => {
  const expired = freshChallenge({ expiresAt: { toMillis: () => NOW - 1 } });
  assert.equal(isChallengeValid(expired, OWNER_UID, NOW, NONCE_HASH), false);
});

test('a challenge expiring exactly at the current instant is still accepted (expiresAt is the last valid millisecond)', () => {
  const atBoundary = freshChallenge({ expiresAt: { toMillis: () => NOW } });
  assert.equal(isChallengeValid(atBoundary, OWNER_UID, NOW, NONCE_HASH), true);
});

test('a challenge one millisecond before expiry is still valid', () => {
  const justBeforeBoundary = freshChallenge({ expiresAt: { toMillis: () => NOW + 1 } });
  assert.equal(isChallengeValid(justBeforeBoundary, OWNER_UID, NOW, NONCE_HASH), true);
});

test('the configured TTL is exactly 5 minutes, matching the spec', () => {
  assert.equal(CHALLENGE_TTL_MS, 5 * 60 * 1000);
});

test('a plain numeric expiresAt (not a Firestore Timestamp-like object) is also handled', () => {
  const plainNumber = freshChallenge({ expiresAt: NOW + 60_000 });
  assert.equal(isChallengeValid(plainNumber, OWNER_UID, NOW, NONCE_HASH), true);
});

console.log('\nisChallengeValid() - ephemeral session nonce binding');

test('CRITICAL: a challenge presented with the WRONG nonce hash is rejected, even though everything else about it is valid', () => {
  assert.equal(isChallengeValid(freshChallenge(), OWNER_UID, NOW, OTHER_NONCE_HASH), false);
});

test('a challenge presented with NO nonce hash at all is rejected', () => {
  assert.equal(isChallengeValid(freshChallenge(), OWNER_UID, NOW, undefined), false);
});

test('hashNonce is deterministic for the same nonce', () => {
  assert.equal(hashNonce(NONCE), hashNonce(NONCE));
});

test('hashNonce differs for different nonces', () => {
  assert.notEqual(hashNonce('nonce-a'), hashNonce('nonce-b'));
});

test('hashNonce does NOT normalize/uppercase like hashCode does - a nonce is case-sensitive, unlike a recovery code', () => {
  assert.notEqual(hashNonce('AbCdEf1234567890'), hashNonce('abcdef1234567890'));
});

console.log('\nfindUnusedCodeIndex()');

test('finds the index of a matching, unused code', () => {
  const codes = [
    { hash: 'aaa', used: false },
    { hash: 'bbb', used: false },
  ];
  assert.equal(findUnusedCodeIndex(codes, 'bbb'), 1);
});

test('returns -1 when the hash matches nothing - a wrong code is rejected', () => {
  const codes = [{ hash: 'aaa', used: false }];
  assert.equal(findUnusedCodeIndex(codes, 'zzz'), -1);
});

test('returns -1 for a matching hash that is already used - the SAME code cannot be used a second time', () => {
  const codes = [{ hash: 'aaa', used: true }];
  assert.equal(findUnusedCodeIndex(codes, 'aaa'), -1);
});

test('handles an empty/absent codes array safely', () => {
  assert.equal(findUnusedCodeIndex([], 'aaa'), -1);
  assert.equal(findUnusedCodeIndex(undefined, 'aaa'), -1);
});

console.log('\nnormalize() / hashCode()');

test('normalize uppercases and strips the cosmetic dash separator', () => {
  assert.equal(normalize('abcd-efghij'), 'ABCDEFGHIJ');
});

test('normalize strips whitespace and any other non-alphanumeric characters', () => {
  assert.equal(normalize('  ABCD - EFGHIJ  '), 'ABCDEFGHIJ');
});

test('hashCode is deterministic for the same code regardless of formatting', () => {
  assert.equal(hashCode('ABCD-EFGHIJ'), hashCode('abcd efghij'));
});

test('hashCode differs for different codes', () => {
  assert.notEqual(hashCode('ABCD-EFGHIJ'), hashCode('ABCD-EFGHIK'));
});

test('hashCode never returns the plaintext - sanity check that it is a hex digest, not passthrough', () => {
  const hash = hashCode('ABCD-EFGHIJ');
  assert.equal(hash.length, 64); // sha256 hex digest length
  assert.notEqual(hash, 'ABCDEFGHIJ');
});

console.log('\nEnd-to-end decision composition (simulating verifyOwnerRecoveryCode\'s branching)');

test('valid challenge + valid unused code => acceptable (both predicates pass)', () => {
  const challenge = freshChallenge();
  const codes = [{ hash: hashCode('ABCD-EFGHIJ'), used: false }];
  const challengeOk = isChallengeValid(challenge, OWNER_UID, NOW, NONCE_HASH);
  const codeIndex = findUnusedCodeIndex(codes, hashCode('ABCD-EFGHIJ'));
  assert.equal(challengeOk, true);
  assert.notEqual(codeIndex, -1);
});

test('valid challenge + WRONG code => rejected even though the challenge itself was fine', () => {
  const challenge = freshChallenge();
  const codes = [{ hash: hashCode('ABCD-EFGHIJ'), used: false }];
  const challengeOk = isChallengeValid(challenge, OWNER_UID, NOW, NONCE_HASH);
  const codeIndex = findUnusedCodeIndex(codes, hashCode('WRONG-CODEXX'));
  assert.equal(challengeOk, true);
  assert.equal(codeIndex, -1);
});

test('expired challenge + otherwise-valid code => rejected (challenge check short-circuits)', () => {
  const expired = freshChallenge({ expiresAt: { toMillis: () => NOW - 1 } });
  const challengeOk = isChallengeValid(expired, OWNER_UID, NOW, NONCE_HASH);
  assert.equal(challengeOk, false);
  // The real implementation returns 'invalid_challenge' before ever
  // reading the codes document in this case - verified structurally by
  // reading the source ordering below.
});

test('source-level check: verifyOwnerRecoveryCode checks challenge validity before consulting codes, and consumes both in the same transaction', () => {
  const fs = require('node:fs');
  const path = require('node:path');
  const source = fs.readFileSync(path.join(__dirname, '..', 'owner_recovery_codes.js'), 'utf8');
  const challengeCheckIndex = source.indexOf('isChallengeValid(');
  const codeCheckIndex = source.indexOf('findUnusedCodeIndex(');
  assert.ok(challengeCheckIndex > -1 && codeCheckIndex > -1, 'expected both checks to be present');
  assert.ok(challengeCheckIndex < codeCheckIndex, 'challenge validity must be checked before the code lookup');
  assert.ok(source.includes('tx.update(codesRef'), 'code consumption must happen inside the transaction');
  assert.ok(source.includes('tx.update(challengeRef'), 'challenge consumption must happen inside the transaction');
});

test('source-level check: verifyOwnerRecoveryCode never trusts a client-supplied UID - it resolves the owner solely from platform_config/owner_seed', () => {
  const fs = require('node:fs');
  const path = require('node:path');
  const source = fs.readFileSync(path.join(__dirname, '..', 'owner_recovery_codes.js'), 'utf8');
  const fnStart = source.indexOf('exports.verifyOwnerRecoveryCode');
  const fnBody = source.slice(fnStart, source.indexOf('\n});', fnStart));
  assert.ok(!fnBody.includes('request.auth'), 'verifyOwnerRecoveryCode must not read request.auth - it runs pre-Firebase-sign-in');
  assert.ok(!fnBody.includes('request.data?.uid') && !fnBody.includes('request.data.uid'), 'must never accept a client-supplied uid');
  assert.ok(fnBody.includes('seededOwnerUid()'), 'must resolve the owner from the seeded authority, not the request');
});

test('source-level check: the custom token minted on success carries no owner/MFA claims', () => {
  const fs = require('node:fs');
  const path = require('node:path');
  const source = fs.readFileSync(path.join(__dirname, '..', 'owner_recovery_codes.js'), 'utf8');
  const match = source.match(/createCustomToken\(([^)]*)\)/);
  assert.ok(match, 'expected a createCustomToken call');
  assert.equal(match[1].trim(), 'uid', 'createCustomToken must be called with only the uid - no second (claims) argument');
});

console.log('\nbeginOwnerRecoveryChallenge - independent first-factor re-verification (source-level checks)');

function beginChallengeSource() {
  const fs = require('node:fs');
  const path = require('node:path');
  const source = fs.readFileSync(path.join(__dirname, '..', 'owner_recovery_codes.js'), 'utf8');
  const fnStart = source.indexOf('exports.beginOwnerRecoveryChallenge');
  return source.slice(fnStart, source.indexOf('\nexports.', fnStart + 1));
}

test('CRITICAL: does NOT accept an enrolled MFA factor UID as proof of first-factor auth - the old hint.uid-based design is fully removed', () => {
  const fnBody = beginChallengeSource();
  assert.ok(
    !fnBody.includes('enrolledFactorUid') && !fnBody.includes('enrolledFactorUids'),
    'beginOwnerRecoveryChallenge must not reference an enrolled-factor UID anywhere - that value is static account ' +
    'metadata (set once at TOTP enrollment, unchanged across every future sign-in), not a signed/time-limited/' +
    'single-use credential, and is therefore insufficient proof that THIS caller just passed a real first-factor check.'
  );
});

test('requires an explicit `provider`, and only recognizes password/google - no default/fallback path that skips verification', () => {
  const fnBody = beginChallengeSource();
  assert.ok(fnBody.includes("provider === 'password'"), 'must have an explicit password branch');
  assert.ok(fnBody.includes("provider === 'google'"), 'must have an explicit google branch');
  assert.ok(fnBody.includes("throw new HttpsError('invalid-argument', 'Unsupported recovery method.')"), 'must reject any other/missing provider value rather than silently proceeding');
});

test('the password path calls verifyOwnerPassword - real Identity Toolkit re-verification, not a Firestore/Admin-SDK shortcut', () => {
  const fnBody = beginChallengeSource();
  assert.ok(fnBody.includes('verifyOwnerPassword(email, password)'), 'must call the independent password-verification helper');
});

test('CRITICAL: a correct password with no MFA-pending signal is treated as an anomaly and denied, never as a normal success', () => {
  const fnBody = beginChallengeSource();
  assert.ok(fnBody.includes('verification.mfaAnomaly'), 'must check the mfaAnomaly flag');
  assert.ok(fnBody.includes("'OWNER_SECURITY_CONFIG_ANOMALY'"), 'must audit-log the anomaly distinctly from an ordinary wrong-password failure');
  assert.ok(fnBody.includes("throw new HttpsError('failed-precondition', 'Verification failed.')"), 'must fail closed on the anomaly, not fall through to normal denial or (worse) success');
});

test('only accepts the verified UID when mfaEnrolled is true - a correct password alone (without the MFA signal) never yields a usable verifiedUid', () => {
  const fnBody = beginChallengeSource();
  assert.ok(fnBody.includes('verification.mfaEnrolled ? verification.localId : null'), 'verifiedUid must be gated on mfaEnrolled, not just a correct password');
});

test('the google path requires GOOGLE_OAUTH_CLIENT_IDS to be configured and refuses to proceed otherwise (fails closed, not open)', () => {
  const fnBody = beginChallengeSource();
  assert.ok(fnBody.includes('GOOGLE_OAUTH_CLIENT_IDS.length === 0'), 'must check for configured audiences');
  assert.ok(fnBody.includes("'failed-precondition'"), 'must throw failed-precondition when unconfigured, not silently skip verification');
});

test('cross-references a verified Google identity to a Firebase UID via getUserByProviderUid - never trusts a client-supplied UID or matches by email', () => {
  const fnBody = beginChallengeSource();
  assert.ok(fnBody.includes("getUserByProviderUid('google.com', googleIdentity.googleSub)"), 'must resolve the Firebase UID via the Admin SDK provider-linking record');
  assert.ok(!fnBody.includes('googleIdentity.email') || fnBody.indexOf('googleIdentity.email') === -1, 'must not authorize based on the Google email string');
});

test('a verified identity that does not equal the seeded owner UID is rejected with the same generic denial as every other case', () => {
  const fnBody = beginChallengeSource();
  assert.ok(fnBody.includes('verifiedUid !== ownerUid'), 'must compare the independently-verified UID against the seeded owner, not trust it unconditionally');
});

test('a challenge is only ever issued for the account whose credential was JUST independently re-verified in this same request', () => {
  const fnBody = beginChallengeSource();
  const setIndex = fnBody.indexOf('ref.set(');
  const verifyIndex = Math.max(fnBody.indexOf('verifyOwnerPassword'), fnBody.indexOf('verifyGoogleIdToken'));
  assert.ok(setIndex > verifyIndex && verifyIndex > -1, 'challenge creation must come after first-factor re-verification in source order');
});

test('the challenge document records which provider verified it and when, matching the requested schema', () => {
  const fnBody = beginChallengeSource();
  assert.ok(fnBody.includes('firstFactorProvider'), 'challenge must record firstFactorProvider');
  assert.ok(fnBody.includes('firstFactorVerifiedAt'), 'challenge must record firstFactorVerifiedAt');
  assert.ok(fnBody.includes('attemptCount: 0'), 'challenge must initialize attemptCount');
});

test('beginOwnerRecoveryChallenge requires a client session nonce of reasonable length and stores only its hash', () => {
  const fnBody = beginChallengeSource();
  assert.ok(fnBody.includes('request.data?.clientSessionNonce'), 'must read clientSessionNonce from the request');
  assert.ok(fnBody.includes('clientSessionNonce.length < 16'), 'must reject an implausibly short/empty nonce');
  assert.ok(fnBody.includes('hashNonce(clientSessionNonce)'), 'must hash the nonce before storing it');
  assert.ok(!/nonceHash: clientSessionNonce[,\s}]/.test(fnBody), 'must never store the raw nonce, only its hash');
});

test('verifyOwnerRecoveryCode requires the same client session nonce and rejects a request missing it', () => {
  const fs = require('node:fs');
  const path = require('node:path');
  const source = fs.readFileSync(path.join(__dirname, '..', 'owner_recovery_codes.js'), 'utf8');
  const fnStart = source.indexOf('exports.verifyOwnerRecoveryCode');
  const fnBody = source.slice(fnStart, source.indexOf('\n});', fnStart));
  assert.ok(fnBody.includes('request.data?.clientSessionNonce'), 'must read clientSessionNonce from the request');
  assert.ok(fnBody.includes('!clientSessionNonce'), 'must reject a missing nonce alongside a missing challengeId/code');
  assert.ok(fnBody.includes('hashNonce(clientSessionNonce)'), 'must hash the submitted nonce before comparing');
  assert.ok(fnBody.includes('isChallengeValid(challengeData, uid, Date.now(), submittedNonceHash)'), 'must pass the submitted nonce hash into the challenge-validity check');
});

console.log('\nverifyOwnerRecoveryCode - per-challenge attempt limiting (source-level checks)');

test('a challenge with too many wrong-code attempts is burned outright, not just counted - closes the grinding window within one challenge', () => {
  const fs = require('node:fs');
  const path = require('node:path');
  const source = fs.readFileSync(path.join(__dirname, '..', 'owner_recovery_codes.js'), 'utf8');
  assert.ok(source.includes('MAX_ATTEMPTS_PER_CHALLENGE'), 'must cap attempts per challenge');
  assert.ok(source.includes('attemptCount >= MAX_ATTEMPTS_PER_CHALLENGE'), 'must check the cap before allowing another guess');
});

console.log('\nSecurity-event challenge invalidation (source-level checks)');

test('provider link/unlink invalidates outstanding recovery challenges', () => {
  const fs = require('node:fs');
  const path = require('node:path');
  const source = fs.readFileSync(path.join(__dirname, '..', 'owner_auth.js'), 'utf8');
  assert.ok(source.includes('invalidateOutstandingChallenges'), 'logOwnerProviderEvent must invalidate outstanding challenges');
});

test('mass session revocation invalidates outstanding recovery challenges', () => {
  const fs = require('node:fs');
  const path = require('node:path');
  const source = fs.readFileSync(path.join(__dirname, '..', 'owner_sign_in_events.js'), 'utf8');
  assert.ok(source.includes('invalidateOutstandingChallenges'), 'revokeOwnerSessions must invalidate outstanding challenges');
});

test('recovery-code regeneration invalidates outstanding recovery challenges', () => {
  const fs = require('node:fs');
  const path = require('node:path');
  const source = fs.readFileSync(path.join(__dirname, '..', 'owner_recovery_codes.js'), 'utf8');
  const fnStart = source.indexOf('exports.generateOwnerRecoveryCodes');
  const fnBody = source.slice(fnStart, source.indexOf('\n});', fnStart));
  assert.ok(fnBody.includes('invalidateOutstandingChallenges'), 'generateOwnerRecoveryCodes must invalidate outstanding challenges');
});

console.log('\nenterSupportMode authorization (source-level check)');

test('enterSupportMode (functions/index.js) now uses the authoritative requireOwner() check, not a local role-only comparison', () => {
  const fs = require('node:fs');
  const path = require('node:path');
  const source = fs.readFileSync(path.join(__dirname, '..', '..', 'functions', 'index.js'), 'utf8');
  const fnStart = source.indexOf('exports.enterSupportMode');
  const fnBody = source.slice(fnStart, source.indexOf('\n});', fnStart));
  assert.ok(fnBody.includes('await requireOwner(request)'), 'enterSupportMode must call the authoritative requireOwner() helper');
  assert.ok(
    !fnBody.includes('callerData.role !== "superAdmin"'),
    'the old, weaker local role-only check must be fully removed'
  );
  // requireOwner() here is now a thin wrapper delegating to the canonical
  // owner-auth package, vendored at functions/vendor/owner-auth/index.js
  // from shared/owner-auth/index.js (Cloud Functions deploy packaging
  // ignores node_modules, so a file: dependency can't be used - see
  // shared/owner-auth/__tests__/requirePlatformOwner.test.js's vendor-sync
  // checks) - see that same test file for full coverage of the actual
  // seed-doc/role/active-status contract itself.
  assert.ok(source.includes('require("./vendor/owner-auth")'), 'functions/index.js must consume the vendored canonical owner-auth package');
  assert.ok(source.includes('await requirePlatformOwner('), 'requireOwner() must delegate to requirePlatformOwner(), not re-implement the check');
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
