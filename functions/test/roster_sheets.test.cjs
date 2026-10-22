const test = require('node:test');
const assert = require('node:assert/strict');
const { rowFor, formatDate, HEADER_ROW } = require('../roster_sheets').__test__;

function fakeTimestamp(date) {
  return { toDate: () => date };
}

test('rowFor maps a student + identity + class name into the header order', () => {
  const row = rowFor(
    {
      studentCode: 'VHS-2026-00128',
      admissionNumber: 'VHS-ADM-2026-00128',
      name: 'Amina Nakato',
      status: 'active',
      classId: 'class-p3',
    },
    {
      nfcStatus: 'active',
      qrCredentialStatus: 'active',
      issuedAt: fakeTimestamp(new Date('2026-01-12T00:00:00.000Z')),
    },
    'P3',
  );
  assert.deepEqual(row, [
    'VHS-2026-00128',
    'VHS-ADM-2026-00128',
    'Amina Nakato',
    'P3',
    'active',
    'active',
    'active',
    '2026-01-12',
  ]);
});

test('rowFor falls back to studentCode when admissionNumber is absent', () => {
  const row = rowFor(
    { studentCode: 'SP0007', name: 'Jane Student', status: 'active' },
    null,
    '',
  );
  assert.equal(row[1], 'SP0007');
});

test('rowFor marks every identity column "not issued" when the student has no '
  + 'StudentIdentity yet - never fabricates a status', () => {
  const row = rowFor(
    { studentCode: 'SP0008', name: 'No Identity Yet', status: 'enrolled' },
    null,
    'P4',
  );
  assert.equal(row[5], 'not issued');
  assert.equal(row[6], 'not issued');
  assert.equal(row[7], '');
});

test('rowFor never includes a raw qrCodeData/uniqueSystemId/cardUid value - '
  + 'only the derived status fields are exported', () => {
  const identity = {
    nfcStatus: 'active',
    qrCredentialStatus: 'active',
    issuedAt: fakeTimestamp(new Date('2026-01-12T00:00:00.000Z')),
    qrCodeData: 'SPQR1.superSecretTokenThatMustNeverBeExported',
    uniqueSystemId: 'SP-STUDENT-abc123',
  };
  const row = rowFor(
    { studentCode: 'SP0009', name: 'Secure Student', status: 'active' },
    identity,
    'P5',
  );
  const serialized = row.join('|');
  assert.ok(!serialized.includes('SPQR1.'));
  assert.ok(!serialized.includes('SP-STUDENT-abc123'));
});

test('formatDate returns an empty string for null/undefined and an ISO date '
  + 'for a Firestore Timestamp-like value', () => {
  assert.equal(formatDate(null), '');
  assert.equal(formatDate(undefined), '');
  assert.equal(
    formatDate(fakeTimestamp(new Date('2026-01-12T00:00:00.000Z'))),
    '2026-01-12',
  );
});

test('HEADER_ROW never includes a raw-credential-shaped column name', () => {
  const serialized = HEADER_ROW.join('|').toLowerCase();
  assert.ok(!serialized.includes('uuid'));
  assert.ok(!serialized.includes('token'));
  assert.ok(!serialized.includes('card uid'));
  assert.ok(!serialized.includes('qr code'));
});
