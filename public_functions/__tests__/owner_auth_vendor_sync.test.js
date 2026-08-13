// Cloud Functions deploy packaging ignores node_modules entirely (see
// firebase.json's `ignore` list) and Cloud Build reinstalls dependencies
// server-side from package.json - so a `file:../shared/owner-auth` local
// npm dependency resolves to a path that doesn't exist remotely (only this
// codebase's own directory gets uploaded, not its sibling shared/). Both
// functions/ and public_functions/ therefore vendor a real, committed copy
// at <codebase>/vendor/owner-auth/index.js and require it by relative path
// instead. This test is the drift guard for that vendored copy: it must
// stay byte-identical to shared/owner-auth/index.js, the single source of
// truth, or the two Cloud Functions codebases silently diverge in what
// "is this caller the platform owner" means.
// Run with: node __tests__/owner_auth_vendor_sync.test.js
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

let passed = 0;
let failed = 0;

function test(name, fn) {
  try {
    fn();
    console.log(`  ok  - ${name}`);
    passed += 1;
  } catch (error) {
    console.log(`  FAIL  - ${name}`);
    console.log(`        ${error.message}`);
    failed += 1;
  }
}

const canonical = fs.readFileSync(
  path.join(__dirname, '..', '..', 'shared', 'owner-auth', 'index.js'),
  'utf8'
);

test('public_functions/vendor/owner-auth/index.js matches shared/owner-auth/index.js exactly', () => {
  const vendored = fs.readFileSync(
    path.join(__dirname, '..', 'vendor', 'owner-auth', 'index.js'),
    'utf8'
  );
  assert.equal(vendored, canonical, 'run: cp shared/owner-auth/index.js public_functions/vendor/owner-auth/index.js');
});

test('functions/vendor/owner-auth/index.js matches shared/owner-auth/index.js exactly', () => {
  const vendored = fs.readFileSync(
    path.join(__dirname, '..', '..', 'functions', 'vendor', 'owner-auth', 'index.js'),
    'utf8'
  );
  assert.equal(vendored, canonical, 'run: cp shared/owner-auth/index.js functions/vendor/owner-auth/index.js');
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
