#!/usr/bin/env node

/**
 * Backfills schoolId onto legacy `visitors` documents that predate the
 * field. Every schoolId-scoped query/rule against this collection
 * (VisitorRemoteDataSource.getVisitors, firestore.rules' isSameSchool
 * check) rejects outright when a document has no schoolId at all - this
 * was surfaced by a "Missing or insufficient permissions" error on the
 * admin dashboard.
 *
 * Only ever assigns the project's single existing school
 * ('school-pulse-academy', per admin_seeder.dart's demoSchoolId) - this
 * project has exactly one school today, so there is nothing ambiguous to
 * resolve. If a second school is ever added, do not reuse this script
 * without re-verifying that assumption.
 *
 * Dry run: node tool/migrate_visitors_schoolid.js
 * Apply:   node tool/migrate_visitors_schoolid.js --apply
 *
 * Authentication comes from the active gcloud account. The access token is
 * kept in memory and is never printed or written to disk.
 */

const { execFileSync } = require('node:child_process');

const projectId = process.env.FIREBASE_PROJECT_ID || 'school-pulse-3d95b';
const schoolId = process.env.SCHOOL_ID || 'school-pulse-academy';
const shouldApply = process.argv.includes('--apply');
const databaseRoot =
  `https://firestore.googleapis.com/v1/projects/${projectId}` +
  '/databases/(default)/documents';

const token = execFileSync(
  '/opt/homebrew/bin/gcloud',
  ['auth', 'print-access-token'],
  { encoding: 'utf8' },
).trim();

async function apiFetch(path, options = {}) {
  const res = await fetch(`${databaseRoot}${path}`, {
    ...options,
    headers: {
      'Authorization': `Bearer ${token}`,
      'x-goog-user-project': projectId,
      'Content-Type': 'application/json',
      ...(options.headers || {}),
    },
  });
  if (!res.ok) {
    throw new Error(`${options.method || 'GET'} ${path} failed: ${res.status} ${await res.text()}`);
  }
  return res.json();
}

async function listAllVisitors() {
  const docs = [];
  let pageToken;
  do {
    const params = new URLSearchParams({ pageSize: '300' });
    if (pageToken) params.set('pageToken', pageToken);
    const page = await apiFetch(`/visitors?${params}`);
    docs.push(...(page.documents || []));
    pageToken = page.nextPageToken;
  } while (pageToken);
  return docs;
}

async function main() {
  const docs = await listAllVisitors();
  const missing = docs.filter((doc) => !('schoolId' in (doc.fields || {})));

  console.log(`visitors: ${docs.length} total, ${missing.length} missing schoolId`);

  if (missing.length === 0) {
    console.log('Nothing to migrate.');
    return;
  }

  for (const doc of missing) {
    const name = doc.name.split('/documents/')[1];
    const visitorName = doc.fields?.name?.stringValue || '(unnamed)';
    console.log(`  ${shouldApply ? 'PATCH' : 'DRY-RUN'} ${name}  (${visitorName})`);
  }

  if (!shouldApply) {
    console.log('\nDry run only - no writes made. Re-run with --apply to patch these documents.');
    return;
  }

  for (const doc of missing) {
    const docPath = doc.name.split('/documents/')[1];
    const params = new URLSearchParams({ 'updateMask.fieldPaths': 'schoolId' });
    await apiFetch(`/${docPath}?${params}`, {
      method: 'PATCH',
      body: JSON.stringify({
        fields: { schoolId: { stringValue: schoolId } },
      }),
    });
  }

  console.log(`\nPatched ${missing.length} document(s) with schoolId="${schoolId}".`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
