const test = require('node:test');
const assert = require('node:assert/strict');

test('integration registry has unique supported keys', () => {
  // Keep this test dependency-free: the callable module itself requires the
  // Firebase runtime, while this verifies the source registry contract.
  const source = require('node:fs').readFileSync(require('node:path').join(__dirname, '..', 'integration_center.js'), 'utf8');
  const keys = [...source.matchAll(/^\s{2}([a-z_]+): \{ name:/gm)].map((match) => match[1]);
  assert.equal(new Set(keys).size, keys.length);
  assert.ok(keys.includes('google_sheets'));
  assert.ok(keys.includes('institution_mtn_momo'));
  assert.ok(keys.includes('outbound_webhook'));
});

test('integration center does not persist client supplied credentials', () => {
  const source = require('node:fs').readFileSync(require('node:path').join(__dirname, '..', 'integration_center.js'), 'utf8');
  assert.match(source, /credentialReference/);
  assert.match(source, /Only safe display\/mapping metadata/);
  assert.doesNotMatch(source, /apiKey:\s*request\.data/);
  assert.doesNotMatch(source, /secret:\s*request\.data/);
});
