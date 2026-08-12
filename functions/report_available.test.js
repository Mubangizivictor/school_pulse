// Plain Node test runner (no framework dependency), matching the convention
// already used in public_functions/ and appointments.test.js. Run with:
// node report_available.test.js
const assert = require('node:assert/strict');
const { reportAvailableEventId, chunkIds } = require('./index').__test__;

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

console.log('reportAvailableEventId()');

test('is deterministic for the same (student, term, parent) triple - proves duplicate publish events cannot double-email', () => {
  const a = reportAvailableEventId('student_1', 'term_1', 'parent_1');
  const b = reportAvailableEventId('student_1', 'term_1', 'parent_1');
  assert.equal(a, b);
});

test('differs per recipient - two parents of the same student each get their own idempotency key, so both actually receive an email', () => {
  const parentA = reportAvailableEventId('student_1', 'term_1', 'parent_A');
  const parentB = reportAvailableEventId('student_1', 'term_1', 'parent_B');
  assert.notEqual(parentA, parentB);
});

test('differs per student - one parent with two children in the same class does not collapse into one email', () => {
  const child1 = reportAvailableEventId('student_1', 'term_1', 'parent_1');
  const child2 = reportAvailableEventId('student_2', 'term_1', 'parent_1');
  assert.notEqual(child1, child2);
});

test('differs per term - a new term\'s report is a genuinely new event, not deduped against last term\'s', () => {
  const term1 = reportAvailableEventId('student_1', 'term_1', 'parent_1');
  const term2 = reportAvailableEventId('student_1', 'term_2', 'parent_1');
  assert.notEqual(term1, term2);
});

console.log('\nchunkIds()');

test('splits into groups of at most 10 - the Firestore `in` operator limit', () => {
  const ids = Array.from({ length: 25 }, (_, i) => `id_${i}`);
  const chunks = chunkIds(ids);
  assert.equal(chunks.length, 3);
  for (const chunk of chunks) assert.ok(chunk.length <= 10, `chunk of ${chunk.length} exceeds Firestore's in-query limit`);
});

test('preserves every id across chunks, in order, with none dropped or duplicated', () => {
  const ids = Array.from({ length: 23 }, (_, i) => `id_${i}`);
  const chunks = chunkIds(ids);
  assert.deepEqual(chunks.flat(), ids);
});

test('empty input produces no chunks', () => {
  assert.deepEqual(chunkIds([]), []);
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
