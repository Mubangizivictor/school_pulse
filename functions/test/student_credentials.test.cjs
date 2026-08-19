const assert = require('node:assert/strict');
const test = require('node:test');
const admin = require('firebase-admin');
if (!admin.apps.length) admin.initializeApp({ projectId: 'school-pulse-test' });

const { __test__ } = require('../student_credentials');

test('mintQrToken produces a token matching QrCredentialCodec\'s pattern '
  + 'on the Flutter side (SPQR1.<40-128 base64url chars>)', () => {
  const token = __test__.mintQrToken();
  assert.match(token, /^SPQR1\.[A-Za-z0-9_-]{40,128}$/);
});

test('mintQrToken is not deterministic - two calls never collide', () => {
  const a = __test__.mintQrToken();
  const b = __test__.mintQrToken();
  assert.notEqual(a, b);
});

test('isStaffRole rejects parent/student and accepts every staff role', () => {
  // isStaffRole returns whatever falsy value the `&&` chain short-circuits
  // to (null/undefined/'') rather than a strict boolean false - assert
  // truthiness, matching how every call site (`if (!isStaffRole(...))`)
  // actually uses the return value.
  assert.equal(!!__test__.isStaffRole('parent'), false);
  assert.equal(!!__test__.isStaffRole('student'), false);
  assert.equal(!!__test__.isStaffRole(null), false);
  assert.equal(!!__test__.isStaffRole(undefined), false);
  assert.equal(__test__.isStaffRole('schoolAdmin'), true);
  assert.equal(__test__.isStaffRole('classTeacher'), true);
});

test('issueIdentityInTransaction skips (does not throw or write) when the '
  + "student doesn't exist - a fake in-memory transaction stub proves it "
  + 'never calls tx.set in that branch', async () => {
  const calls = { get: 0, set: 0 };
  const fakeTx = {
    get: async () => { calls.get += 1; return { exists: false }; },
    set: () => { calls.set += 1; },
  };
  const fakeDb = {
    collection: () => ({
      doc: () => ({}),
      where: () => ({ limit: () => ({}) }),
    }),
  };
  const outcome = await __test__.issueIdentityInTransaction(fakeTx, fakeDb, {
    studentId: 'missing', schoolId: 'schoolA', schoolPrefix: 'SP',
  });
  assert.equal(outcome.skipped, true);
  assert.equal(outcome.reason, 'student-not-found');
  assert.equal(calls.set, 0);
});

test('issueIdentityInTransaction skips on a schoolId mismatch without '
  + 'writing anything - the cross-school guard backfillStudentIdentities '
  + 'and issueStudentIdentity both rely on', async () => {
  const calls = { set: 0 };
  const fakeTx = {
    get: async (ref) => (ref.__kind === 'student'
      ? { exists: true, data: () => ({ schoolId: 'schoolB' }) }
      : { empty: true, docs: [] }),
    set: () => { calls.set += 1; },
  };
  const fakeDb = {
    collection: (name) => ({
      doc: () => ({ __kind: name === 'students' ? 'student' : 'other' }),
      where: () => ({ limit: () => ({ __kind: 'identityQuery' }) }),
    }),
  };
  const outcome = await __test__.issueIdentityInTransaction(fakeTx, fakeDb, {
    studentId: 's1', schoolId: 'schoolA', schoolPrefix: 'SP',
  });
  assert.equal(outcome.skipped, true);
  assert.equal(outcome.reason, 'school-mismatch');
  assert.equal(calls.set, 0);
});

test('issueIdentityInTransaction writes the QR credential with '
  + 'identityId=studentId (the canonical students/{id} document ID), not '
  + 'StudentIdentity.uniqueSystemId - the contract Attendance/IdentityResolver '
  + 'depends on for the fast direct-read path', async () => {
  const writes = [];
  const makeRef = (kind, id) => ({
    __kind: kind,
    id: id || 'generated-id',
    collection: (subName) => makeCollection(subName),
  });
  function makeCollection(name) {
    return {
      doc: (id) => makeRef(
        name === 'students' ? 'student'
          : name === 'counters' ? 'counter'
          : name === 'credentials' ? 'credential'
          : 'other',
        id,
      ),
      where: () => ({ limit: () => ({ __kind: 'identityQuery' }) }),
    };
  }
  const fakeTx = {
    get: async (ref) => {
      if (ref.__kind === 'student') return { exists: true, data: () => ({ schoolId: 'schoolA' }) };
      if (ref.__kind === 'counter') return { exists: false };
      return { empty: true, docs: [] };
    },
    set: (ref, data) => { writes.push({ ref, data }); },
  };
  const fakeDb = { collection: makeCollection };
  const outcome = await __test__.issueIdentityInTransaction(fakeTx, fakeDb, {
    studentId: 's1', schoolId: 'schoolA', schoolPrefix: 'SP',
  });
  assert.equal(outcome.created, true);
  const credentialWrite = writes.find((w) => w.data.credentialType === 'qr');
  assert.ok(credentialWrite, 'expected a QR credential write');
  assert.equal(credentialWrite.data.identityId, 's1');
  assert.notEqual(credentialWrite.data.identityId, outcome.identity.uniqueSystemId);
});
