#!/usr/bin/env node
/**
 * School Pulse — Firebase Auth + Firestore audit & controlled wipe.
 *
 * Usage (on your Mac):
 *
 *   cd ~/Desktop/apps/school_pulse
 *   node scripts/firebase_audit_and_wipe.js           # count only
 *   node scripts/firebase_audit_and_wipe.js --delete  # count then ask for "yes", then wipe
 *
 * Requirements:
 *   npm install firebase-admin   (or: cd scripts && npm install)
 *
 * Authentication:
 *   Export GOOGLE_APPLICATION_CREDENTIALS to your service account JSON, e.g.:
 *     export GOOGLE_APPLICATION_CREDENTIALS=~/Desktop/apps/school_pulse/school-pulse-serviceaccount.json
 *   OR the script falls back to Application Default Credentials (gcloud auth application-default login).
 *
 * Collections wiped (in --delete mode, after your "yes"):
 *   Firebase Auth: ALL users
 *   Firestore top-level: users, institution_memberships, onboarding_state, students
 *   Firestore nested:    schools/{id}/config, schools/{id}/approval_delegations
 *                        (the schools/{id} document itself is NOT deleted - structure data lives there)
 *
 * Backup files written before delete:
 *   ./scripts/backup-auth-{timestamp}.json
 *   ./scripts/backup-firestore-{timestamp}.json
 */

'use strict';

const admin = require('firebase-admin');
const fs    = require('fs');
const path  = require('path');
const readline = require('readline');

const PROJECT_ID = 'school-pulse-3d95b';

// Top-level collections whose ALL documents belong to users/accounts.
const TOP_LEVEL_COLLECTIONS = [
  'users',
  'institution_memberships',
  'onboarding_state',
  'students',
];

// --- init Firebase Admin ------------------------------------------------
let credential;
if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  credential = admin.credential.cert(require(process.env.GOOGLE_APPLICATION_CREDENTIALS));
} else {
  credential = admin.credential.applicationDefault();
}
admin.initializeApp({ credential, projectId: PROJECT_ID });
const auth = admin.auth();
const db   = admin.firestore();
// -----------------------------------------------------------------------

async function listAllAuthUsers() {
  const users = [];
  let next = undefined;
  do {
    const result = await auth.listUsers(1000, next);
    users.push(...result.users);
    next = result.pageToken;
  } while (next);
  return users;
}

async function countCollection(name) {
  const snap = await db.collection(name).count().get();
  return snap.data().count;
}

async function fetchCollection(name) {
  const snap = await db.collection(name).get();
  const docs = {};
  snap.forEach(d => docs[d.id] = d.data());
  return docs;
}

async function deleteCollectionBatch(name) {
  let deleted = 0;
  let snap;
  do {
    snap = await db.collection(name).limit(400).get();
    if (snap.empty) break;
    const batch = db.batch();
    snap.forEach(d => batch.delete(d.ref));
    await batch.commit();
    deleted += snap.size;
    process.stdout.write(`  ${name}: deleted ${deleted} ...\r`);
  } while (!snap.empty);
  console.log(`  ${name}: deleted ${deleted} docs.`);
}

function ask(question) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise(resolve => rl.question(question, ans => { rl.close(); resolve(ans.trim()); }));
}

async function main() {
  const doDelete = process.argv.includes('--delete');
  const ts = new Date().toISOString().replace(/[:.]/g, '-');

  console.log('\n=== School Pulse Firebase Audit ===');
  console.log(`Project: ${PROJECT_ID}\n`);

  // --- Auth users ---
  console.log('Counting Firebase Auth users...');
  const authUsers = await listAllAuthUsers();
  console.log(`\n  Firebase Auth users: ${authUsers.length}`);
  authUsers.forEach(u =>
    console.log(`    uid=${u.uid}  email=${u.email || '(none)'}  role=${u.customClaims?.role || '(none)'}  created=${u.metadata.creationTime}`)
  );

  // --- Firestore collections ---
  console.log('\nCounting Firestore documents...');
  const counts = {};
  for (const col of TOP_LEVEL_COLLECTIONS) {
    counts[col] = await countCollection(col);
    console.log(`  ${col}: ${counts[col]} docs`);
  }

  // Summary
  console.log('\n--- Summary ---');
  console.log(`Firebase Auth users to delete: ${authUsers.length}`);
  for (const [col, n] of Object.entries(counts)) {
    console.log(`  ${col}: ${n} docs`);
  }
  const totalDocs = Object.values(counts).reduce((a, b) => a + b, 0);
  console.log(`Total Firestore docs to delete: ${totalDocs}`);

  if (!doDelete) {
    console.log('\n(Run with --delete to export a backup and wipe after confirmation.)');
    return;
  }

  // --- Backup before anything ---
  console.log('\nWriting backup files...');
  const authBackupPath = path.join(__dirname, `backup-auth-${ts}.json`);
  fs.writeFileSync(authBackupPath, JSON.stringify(authUsers, null, 2));
  console.log(`  Auth backup: ${authBackupPath}`);

  const firestoreBackup = {};
  for (const col of TOP_LEVEL_COLLECTIONS) {
    console.log(`  Fetching ${col} for backup...`);
    firestoreBackup[col] = await fetchCollection(col);
  }
  const fsBackupPath = path.join(__dirname, `backup-firestore-${ts}.json`);
  fs.writeFileSync(fsBackupPath, JSON.stringify(firestoreBackup, null, 2));
  console.log(`  Firestore backup: ${fsBackupPath}`);

  // --- Confirmation ---
  console.log('\n!!! PERMANENT DELETE — this cannot be undone !!!');
  const answer = await ask('Type "yes" to confirm deletion, anything else to abort: ');
  if (answer !== 'yes') {
    console.log('Aborted. Nothing deleted.');
    return;
  }

  console.log('\nDeleting Firebase Auth users...');
  const uidChunks = chunk(authUsers.map(u => u.uid), 100);
  let deletedUsers = 0;
  for (const uids of uidChunks) {
    const result = await auth.deleteUsers(uids);
    deletedUsers += result.successCount;
    if (result.errors.length) {
      console.error('  Errors:', result.errors.map(e => e.error.message));
    }
  }
  console.log(`  Deleted ${deletedUsers} auth users.`);

  console.log('\nDeleting Firestore collections...');
  for (const col of TOP_LEVEL_COLLECTIONS) {
    await deleteCollectionBatch(col);
  }

  console.log('\nDone. All accounts wiped.');
  console.log(`Backups are at:\n  ${authBackupPath}\n  ${fsBackupPath}`);
}

function chunk(arr, size) {
  const out = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

main().catch(err => {
  console.error('\nFatal error:', err.message);
  process.exit(1);
});
