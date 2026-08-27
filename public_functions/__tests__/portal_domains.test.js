const test = require('node:test');
const assert = require('node:assert/strict');
const { __test__ } = require('../portal_domains');
test('portal slugs reject reserved and unsafe values', () => {
  assert.equal(__test__.validSlug('greenhill'), true);
  assert.equal(__test__.validSlug('schoolpulse'), false);
  assert.equal(__test__.validSlug('Green Hill'), false);
});
test('custom host excludes platform wildcard', () => {
  assert.equal(__test__.validHost('portal.greenhill.ac.ug'), true);
  assert.equal(__test__.validHost('greenhill.schoolpulse.ug'), false);
});
