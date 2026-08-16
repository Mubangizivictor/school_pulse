const test = require('node:test');
const assert = require('node:assert/strict');

test('sync job status transitions are one of the known set', () => {
  const source = require('node:fs').readFileSync(require('node:path').join(__dirname, '..', 'integration_sync_jobs.js'), 'utf8');
  const statuses = [...source.matchAll(/status:\s*'([a-zA-Z]+)'/g)].map((m) => m[1]);
  const known = new Set(['running', 'queued', 'succeeded', 'failed']);
  for (const status of statuses) assert.ok(known.has(status), `unexpected status literal: ${status}`);
});

test('google_sheets sync delegates to attendance_sheets rather than re-implementing export', () => {
  const source = require('node:fs').readFileSync(require('node:path').join(__dirname, '..', 'integration_sync_jobs.js'), 'utf8');
  assert.match(source, /require\('\.\/attendance_sheets'\)/);
  assert.doesNotMatch(source, /google\.sheets\(/);
});

test('non google_sheets integrations only get a scaffold job, no fake external call', () => {
  const source = require('node:fs').readFileSync(require('node:path').join(__dirname, '..', 'integration_sync_jobs.js'), 'utf8');
  assert.match(source, /No worker wired yet/);
});
