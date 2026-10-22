/**
 * Production reset: delete all Firestore data, Auth users, and Storage objects
 * except the SaaS platform owner account.
 *
 * Usage: node scripts/wipe_to_owner_only.js
 */
const admin = require('firebase-admin');

const PROJECT_ID = 'school-pulse-3d95b';
const OWNER_UID = '9UHI2gzXNEhw3mBoFAbBqldtex82';
const OWNER_EMAIL = 'mubangizivic@gmail.com';

// Collections whose entire contents are platform-level config, not per-school
// seeded/real data — preserved as-is.
const PRESERVE_COLLECTIONS = new Set([
  'subscription_plans',
  'platform_config',
]);

admin.initializeApp({
  projectId: PROJECT_ID,
  storageBucket: 'school-pulse-3d95b.firebasestorage.app',
});

const db = admin.firestore();
const auth = admin.auth();
const bucket = admin.storage().bucket();

async function deleteCollectionDocs(collectionRef, keepDocId) {
  const BATCH_SIZE = 300;
  let deleted = 0;
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const snap = await collectionRef.limit(BATCH_SIZE).get();
    if (snap.empty) break;
    const batch = db.batch();
    let queued = 0;
    for (const doc of snap.docs) {
      if (keepDocId && doc.id === keepDocId) continue;
      // Recursively delete subcollections first.
      await deleteAllSubcollections(doc.ref);
      batch.delete(doc.ref);
      queued++;
    }
    if (queued === 0) break;
    await batch.commit();
    deleted += queued;
    if (queued < snap.size) break; // only the kept doc remained
  }
  return deleted;
}

async function deleteAllSubcollections(docRef) {
  const subcols = await docRef.listCollections();
  for (const sub of subcols) {
    await deleteCollectionDocs(sub, null);
  }
}

async function wipeFirestore() {
  const collections = await db.listCollections();
  for (const col of collections) {
    if (PRESERVE_COLLECTIONS.has(col.id)) {
      console.log(`[skip]  ${col.id} (preserved platform config)`);
      continue;
    }
    const keepDocId = col.id === 'users' ? OWNER_UID : null;
    const count = await deleteCollectionDocs(col, keepDocId);
    console.log(`[wiped] ${col.id}: ${count} doc(s) deleted${keepDocId ? ' (kept owner doc)' : ''}`);
  }
}

async function wipeAuth() {
  let deleted = 0;
  let nextPageToken;
  const uidsToDelete = [];
  do {
    const result = await auth.listUsers(1000, nextPageToken);
    for (const user of result.users) {
      if (user.uid === OWNER_UID) continue;
      uidsToDelete.push(user.uid);
    }
    nextPageToken = result.pageToken;
  } while (nextPageToken);

  for (let i = 0; i < uidsToDelete.length; i += 100) {
    const chunk = uidsToDelete.slice(i, i + 100);
    const result = await auth.deleteUsers(chunk);
    deleted += result.successCount;
    if (result.failureCount > 0) {
      console.error('Auth delete failures:', result.errors);
    }
  }
  console.log(`[wiped] Auth users: ${deleted} deleted, owner (${OWNER_EMAIL}) preserved`);
}

async function wipeStorage() {
  const [files] = await bucket.getFiles();
  let deleted = 0;
  for (const file of files) {
    await file.delete({ ignoreNotFound: true });
    deleted++;
  }
  console.log(`[wiped] Storage: ${deleted} object(s) deleted`);
}

async function main() {
  console.log(`Starting production wipe on project ${PROJECT_ID}`);
  console.log(`Preserving owner: ${OWNER_EMAIL} (${OWNER_UID})\n`);

  await wipeFirestore();
  await wipeAuth();
  await wipeStorage();

  console.log('\nDone. Only the SaaS owner account and platform config remain.');
}

main().catch((err) => {
  console.error('Wipe failed:', err);
  process.exit(1);
});
