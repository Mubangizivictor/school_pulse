// Plain Node test runner (no framework dependency), matching the
// convention already used across public_functions/__tests__. Covers the
// canonical requirePlatformOwner() contract in isolation (in-memory fake
// Firestore, no emulator needed for this pure-logic module) plus proof
// that BOTH Cloud Functions codebases vendor this exact same file (see
// <codebase>/vendor/owner-auth/index.js in functions/ and
// public_functions/) - not two copies that happen to look similar.
// Run with: node __tests__/requirePlatformOwner.test.js
const assert = require('node:assert/strict');
const path = require('node:path');
const {
  requirePlatformOwner,
  rejectIfPlatformOwner,
  isOwnerProfile,
  OwnerAuthorizationError,
} = require('../index.js');

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

async function asyncTest(name, fn) {
  try {
    await fn();
    passed += 1;
    console.log(`  ok  - ${name}`);
  } catch (error) {
    failed += 1;
    console.log(`FAIL  - ${name}`);
    console.log(`        ${error.message}`);
  }
}

// Minimal fake Firestore: just enough surface (`.collection().doc().get()`)
// for requirePlatformOwner's two reads, backed by a plain in-memory map so
// each test can seed exactly the documents it needs.
function fakeDb(docs) {
  return {
    collection(name) {
      return {
        doc(id) {
          const key = `${name}/${id}`;
          return {
            async get() {
              const data = docs[key];
              return { exists: data !== undefined, data: () => data };
            },
          };
        },
      };
    },
  };
}

const OWNER_UID = 'owner-uid-abc';
const OTHER_UID = 'school-admin-uid-xyz';

async function run() {
  console.log('requirePlatformOwner() - contract');

  await asyncTest('rejects an unauthenticated request', async () => {
    const db = fakeDb({});
    await assert.rejects(
      () => requirePlatformOwner({ auth: null }, { db }),
      (err) => err instanceof OwnerAuthorizationError && err.code === 'unauthenticated'
    );
  });

  await asyncTest('rejects when platform_config/owner_seed does not exist at all', async () => {
    const db = fakeDb({});
    await assert.rejects(
      () => requirePlatformOwner({ auth: { uid: OWNER_UID } }, { db }),
      (err) => err instanceof OwnerAuthorizationError && err.code === 'permission-denied'
    );
  });

  await asyncTest('rejects when seed.seeded is false', async () => {
    const db = fakeDb({
      'platform_config/owner_seed': { seeded: false, ownerUid: OWNER_UID },
    });
    await assert.rejects(() => requirePlatformOwner({ auth: { uid: OWNER_UID } }, { db }));
  });

  await asyncTest('CRITICAL: rejects a caller whose UID does not match platform_config/owner_seed.ownerUid, even with a valid owner-shaped profile doc', async () => {
    const db = fakeDb({
      'platform_config/owner_seed': { seeded: true, ownerUid: OWNER_UID },
      [`users/${OTHER_UID}`]: { role: 'superAdmin', isActive: true },
    });
    await assert.rejects(
      () => requirePlatformOwner({ auth: { uid: OTHER_UID } }, { db }),
      (err) => err instanceof OwnerAuthorizationError && err.code === 'permission-denied'
    );
  });

  await asyncTest('rejects the seeded UID if users/{uid} does not exist', async () => {
    const db = fakeDb({
      'platform_config/owner_seed': { seeded: true, ownerUid: OWNER_UID },
    });
    await assert.rejects(() => requirePlatformOwner({ auth: { uid: OWNER_UID } }, { db }));
  });

  await asyncTest('rejects the seeded UID if the profile is deactivated (isActive: false), even though it is still named in the seed doc', async () => {
    const db = fakeDb({
      'platform_config/owner_seed': { seeded: true, ownerUid: OWNER_UID },
      [`users/${OWNER_UID}`]: { role: 'superAdmin', isActive: false },
    });
    await assert.rejects(
      () => requirePlatformOwner({ auth: { uid: OWNER_UID } }, { db }),
      (err) => err instanceof OwnerAuthorizationError && err.code === 'permission-denied'
    );
  });

  await asyncTest('rejects the seeded UID if the profile has no owner-shaped role at all', async () => {
    const db = fakeDb({
      'platform_config/owner_seed': { seeded: true, ownerUid: OWNER_UID },
      [`users/${OWNER_UID}`]: { role: 'schoolAdmin', isActive: true },
    });
    await assert.rejects(() => requirePlatformOwner({ auth: { uid: OWNER_UID } }, { db }));
  });

  await asyncTest('accepts the seeded UID with an active superAdmin profile', async () => {
    const db = fakeDb({
      'platform_config/owner_seed': { seeded: true, ownerUid: OWNER_UID },
      [`users/${OWNER_UID}`]: { role: 'superAdmin', isActive: true },
    });
    const result = await requirePlatformOwner({ auth: { uid: OWNER_UID } }, { db });
    assert.equal(result.uid, OWNER_UID);
  });

  console.log('\nrejectIfPlatformOwner() - the inverse gate used by every NON-owner auth surface (Staff Gateway, session restore)');

  await asyncTest('no-ops for an unauthenticated request', async () => {
    const db = fakeDb({});
    await assert.doesNotReject(() => rejectIfPlatformOwner({ auth: null }, { db }));
  });

  await asyncTest('no-ops for an ordinary staff UID that is not the seeded owner', async () => {
    const db = fakeDb({
      'platform_config/owner_seed': { seeded: true, ownerUid: OWNER_UID },
      [`users/${OTHER_UID}`]: { role: 'schoolAdmin', isActive: true },
    });
    await assert.doesNotReject(() => rejectIfPlatformOwner({ auth: { uid: OTHER_UID } }, { db }));
  });

  await asyncTest('no-ops when platform_config/owner_seed does not exist at all', async () => {
    const db = fakeDb({});
    await assert.doesNotReject(() => rejectIfPlatformOwner({ auth: { uid: OTHER_UID } }, { db }));
  });

  await asyncTest('no-ops when seed.seeded is false, even if ownerUid happens to match', async () => {
    const db = fakeDb({
      'platform_config/owner_seed': { seeded: false, ownerUid: OWNER_UID },
    });
    await assert.doesNotReject(() => rejectIfPlatformOwner({ auth: { uid: OWNER_UID } }, { db }));
  });

  await asyncTest('CRITICAL: rejects the canonical seeded owner UID, with correct credentials, on a non-owner auth surface', async () => {
    const db = fakeDb({
      'platform_config/owner_seed': { seeded: true, ownerUid: OWNER_UID },
      [`users/${OWNER_UID}`]: { role: 'superAdmin', isActive: true },
    });
    await assert.rejects(
      () => rejectIfPlatformOwner({ auth: { uid: OWNER_UID } }, { db }),
      (err) => err instanceof OwnerAuthorizationError && err.code === 'permission-denied'
    );
  });

  await asyncTest('rejects the seeded owner UID even if their profile happens to be missing/deactivated - identity is by UID, not profile state', async () => {
    const db = fakeDb({
      'platform_config/owner_seed': { seeded: true, ownerUid: OWNER_UID },
    });
    await assert.rejects(
      () => rejectIfPlatformOwner({ auth: { uid: OWNER_UID } }, { db }),
      (err) => err instanceof OwnerAuthorizationError && err.code === 'permission-denied'
    );
  });

  await asyncTest('does NOT reject by email match - a non-owner UID that happens to share the owner email string still passes', async () => {
    const db = fakeDb({
      'platform_config/owner_seed': { seeded: true, ownerUid: OWNER_UID },
      [`users/${OTHER_UID}`]: { role: 'schoolAdmin', isActive: true, email: 'owner@school-pulse.app' },
    });
    await assert.doesNotReject(() => rejectIfPlatformOwner({ auth: { uid: OTHER_UID } }, { db }));
  });

  console.log('\nisOwnerProfile() - role recognition, never by email');

  test('recognizes isSuperAdmin: true', () => {
    assert.equal(isOwnerProfile({ isSuperAdmin: true }), true);
  });
  test('recognizes role: "superAdmin"', () => {
    assert.equal(isOwnerProfile({ role: 'superAdmin' }), true);
  });
  test('recognizes roles array containing "saasOwner"', () => {
    assert.equal(isOwnerProfile({ roles: ['schoolAdmin', 'saasOwner'] }), true);
  });
  test('does NOT recognize an owner by matching email alone', () => {
    assert.equal(isOwnerProfile({ email: 'owner@school-pulse.app', role: 'schoolAdmin' }), false);
  });
  test('rejects null/undefined profile data', () => {
    assert.equal(isOwnerProfile(null), false);
    assert.equal(isOwnerProfile(undefined), false);
  });

  console.log('\nBoth Cloud Functions codebases vendor this SAME source (not independent copies)');

  // Cloud Functions deploy packaging ignores node_modules entirely (see
  // firebase.json) and Cloud Build reinstalls dependencies server-side from
  // package.json - so a `file:../shared/owner-auth` local npm dependency
  // resolves to a path that doesn't exist remotely (only a codebase's own
  // directory gets uploaded, not its sibling shared/). Both functions/ and
  // public_functions/ therefore vendor a real, committed copy at
  // <codebase>/vendor/owner-auth/index.js and require it by relative path
  // instead of an npm package name. This test is the drift guard for that
  // vendored copy - see also public_functions/__tests__/owner_auth_vendor_sync.test.js,
  // which runs from `npm test` in that codebase and checks the same thing.
  const fs = require('node:fs');

  test('functions/vendor/owner-auth/index.js is byte-identical to this file', () => {
    const vendored = path.join(__dirname, '..', '..', '..', 'functions', 'vendor', 'owner-auth', 'index.js');
    const thisFile = path.join(__dirname, '..', 'index.js');
    assert.equal(
      fs.readFileSync(vendored, 'utf8'),
      fs.readFileSync(thisFile, 'utf8'),
      'functions/vendor/owner-auth/index.js has drifted - run: cp shared/owner-auth/index.js functions/vendor/owner-auth/index.js'
    );
  });

  test('public_functions/vendor/owner-auth/index.js is byte-identical to this file', () => {
    const vendored = path.join(__dirname, '..', '..', '..', 'public_functions', 'vendor', 'owner-auth', 'index.js');
    const thisFile = path.join(__dirname, '..', 'index.js');
    assert.equal(
      fs.readFileSync(vendored, 'utf8'),
      fs.readFileSync(thisFile, 'utf8'),
      'public_functions/vendor/owner-auth/index.js has drifted - run: cp shared/owner-auth/index.js public_functions/vendor/owner-auth/index.js'
    );
  });

  test('functions/index.js and public_functions/owner_auth.js each wrap requirePlatformOwner - neither re-implements the check inline', () => {
    const fs = require('node:fs');
    const functionsSource = fs.readFileSync(
      path.join(__dirname, '..', '..', '..', 'functions', 'index.js'),
      'utf8'
    );
    const publicFunctionsSource = fs.readFileSync(
      path.join(__dirname, '..', '..', '..', 'public_functions', 'owner_auth.js'),
      'utf8'
    );
    assert.ok(functionsSource.includes('require("./vendor/owner-auth")'), 'functions/index.js must import the vendored shared package');
    assert.ok(functionsSource.includes('await requirePlatformOwner('), 'functions/index.js must call requirePlatformOwner');
    assert.ok(publicFunctionsSource.includes("require('./vendor/owner-auth')"), 'owner_auth.js must import the vendored shared package');
    assert.ok(publicFunctionsSource.includes('await requirePlatformOwner('), 'owner_auth.js must call requirePlatformOwner');
    // Neither file should contain a second, ad-hoc seed-doc/role check
    // outside of what the shared package itself does.
    assert.ok(!functionsSource.includes('seed.ownerUid !== uid'), 'functions/index.js must not re-implement the seed-UID comparison inline anymore');
    assert.ok(!publicFunctionsSource.includes('seed.ownerUid !== uid'), 'owner_auth.js must not re-implement the seed-UID comparison inline anymore');
  });

  console.log('\nEvery owner-gated Cloud Function consumes the canonical resolver (repo-wide audit)');

  test('all seven previously-divergent files now import and delegate to requirePlatformOwner, with no leftover local role-only/isOwnerData checks', () => {
    const fs = require('node:fs');
    const pfDir = path.join(__dirname, '..', '..', '..', 'public_functions');
    const fnDir = path.join(__dirname, '..', '..', '..', 'functions');

    const files = [
      path.join(pfDir, 'owner.js'),
      path.join(pfDir, 'payments.js'),
      path.join(pfDir, 'owner_sign_in_events.js'),
      path.join(pfDir, 'owner_device_registry.js'),
      path.join(pfDir, 'owner_notification_preferences.js'),
      path.join(pfDir, 'owner_notifications_admin.js'),
      path.join(fnDir, 'student_capacity.js'),
    ];

    for (const file of files) {
      const source = fs.readFileSync(file, 'utf8');
      const relative = path.relative(path.join(__dirname, '..', '..', '..'), file);
      assert.ok(
        source.includes('./vendor/owner-auth'),
        `${relative} must import the canonical vendored owner-auth package`
      );
      assert.ok(
        source.includes('requirePlatformOwner('),
        `${relative} must call requirePlatformOwner`
      );
      assert.ok(
        !source.includes("owner.role !== 'superAdmin'") && !source.includes('callerData.role !== "superAdmin"'),
        `${relative} must not retain its old local role-only check`
      );
      assert.ok(
        !/const \{ isOwnerData \} = require/.test(source),
        `${relative} must not retain its old local isOwnerData-based requireOwner()`
      );
    }
  });

  console.log(`\n${passed} passed, ${failed} failed`);
  if (failed > 0) process.exit(1);
}

run();
