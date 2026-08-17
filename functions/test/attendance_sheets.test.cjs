const test = require('node:test');
const assert = require('node:assert/strict');
const { rowFor, retryWithBackoff, friendlyError } = require('../attendance_sheets').__test__;

function fakeTimestamp(date) {
  return { toDate: () => date };
}

test('rowFor formats date/createdAt from Firestore Timestamps and falls back to ids when names are absent', () => {
  const row = rowFor({
    date: fakeTimestamp(new Date('2026-08-17T00:00:00.000Z')),
    category: 'students',
    scopeName: 'P7',
    personName: 'Sarah Namusoke',
    status: 'present',
    method: 'qr',
    markedBy: 'Teacher A',
    createdAt: fakeTimestamp(new Date('2026-08-17T08:03:00.000Z')),
  });
  assert.deepEqual(row, [
    '2026-08-17',
    'students',
    'P7',
    'Sarah Namusoke',
    'present',
    'qr',
    'Teacher A',
    '2026-08-17T08:03:00.000Z',
  ]);
});

test('rowFor falls back to scopeId/personId when display names are missing', () => {
  const row = rowFor({
    date: null,
    category: 'students',
    scopeId: 'p7',
    personId: 'studentA',
    status: 'present',
    method: 'nfc',
    markedBy: 'Teacher A',
    createdAt: null,
  });
  assert.equal(row[2], 'p7');
  assert.equal(row[3], 'studentA');
});

test('retryWithBackoff retries on a transient 429 and eventually succeeds', async () => {
  let attempts = 0;
  const result = await retryWithBackoff(async () => {
    attempts += 1;
    if (attempts < 2) {
      const err = new Error('rate limited');
      err.code = 429;
      throw err;
    }
    return 'ok';
  });
  assert.equal(result, 'ok');
  assert.equal(attempts, 2);
});

test('retryWithBackoff does not retry a non-transient error', async () => {
  let attempts = 0;
  await assert.rejects(
    retryWithBackoff(async () => {
      attempts += 1;
      const err = new Error('bad request');
      err.code = 400;
      throw err;
    }),
    /bad request/,
  );
  assert.equal(attempts, 1);
});

test('friendlyError maps not_connected/needs_reauth to plain-language messages with a machine-readable reason', () => {
  const notConnected = friendlyError({ code: 'not_connected' });
  assert.equal(notConnected.message, 'Connect Google Sheets first.');
  assert.equal(notConnected.details.reason, 'not_connected');

  const needsReauth = friendlyError({ code: 'needs_reauth' });
  assert.equal(needsReauth.message, 'Google Sheets connection needs to be renewed.');
  assert.equal(needsReauth.details.reason, 'needs_reauth');

  const other = friendlyError({ code: 'anything_else' });
  assert.match(other.message, /Attendance is saved/);
  assert.equal(other.details.reason, 'temporary');
});
