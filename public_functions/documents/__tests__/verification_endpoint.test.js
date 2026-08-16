const assert = require('node:assert/strict');
const admin = require('firebase-admin');
if (!admin.apps.length) admin.initializeApp({ projectId: 'school-pulse-test' });
const { __test__ } = require('../verification_endpoint');

assert.equal(__test__.token('  abc  '), 'abc');
assert.match(__test__.page({ valid: true, title: 'Verified', reference: 'SP-APP-2026-000001', type: 'APPLICATION APPROVAL', school: 'A School', date: '16 AUG 2026' }), /Valid official document/);
assert.doesNotMatch(__test__.page({ valid: false, title: 'Invalid' }), /Firestore|paymentId|schoolId/i);
console.log('Official document verification endpoint: 3 passed');
