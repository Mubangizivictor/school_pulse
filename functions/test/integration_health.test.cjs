const test = require('node:test');
const assert = require('node:assert/strict');

test('getIntegrationHealthSummary reads integrations and devices with single collection reads only', () => {
  const source = require('node:fs').readFileSync(require('node:path').join(__dirname, '..', 'integration_health.js'), 'utf8');
  assert.match(source, /collection\('integrations'\)\.get\(\)/);
  assert.match(source, /collection\('integration_devices'\)\.get\(\)/);
  // No per-provider network calls - this must stay cheap/cached.
  assert.doesNotMatch(source, /fetch\(|axios|https\.request/);
});
