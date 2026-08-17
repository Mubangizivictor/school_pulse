/**
 * Full production reset for school-pulse-3d95b.
 * Deletes ALL Firestore collections (recursively) and ALL Firebase Auth users.
 * Run with: node scripts/wipe_all_data.js
 */
const admin = require('firebase-admin');

admin.initializeApp({
  projectId: 'school-pulse-3d95b',
});

const db = admin.firestore();
const auth = admin.auth();

async function deleteCollectionRecursive(collectionRef, batchSize = 300) {
  const snapshot = await collectionRef.limit(batchSize).get();
  if (snapshot.empty) return;

  for (const doc of snapshot.docs) {
    const subcollections = await doc.ref.listCollections();
    for (const sub of subcollections) {
      await deleteCollectionRecursive(sub, batchSize);
    }
  }

  const batch = db.batch();
  snapshot.docs.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();

  if (snapshot.size >= batchSize) {
    await deleteCollectionRecursive(collectionRef, batchSize);
  }
}

async function wipeFirestore() {
  const collections = await db.listCollections();
  console.log(`Found ${collections.length} top-level collections.`);
  for (const col of collections) {
    console.log(`Deleting collection: ${col.id}`);
    await deleteCollectionRecursive(col);
    console.log(`Done: ${col.id}`);
  }
}

async function wipeAuthUsers() {
  let totalDeleted = 0;
  let pageToken;
  do {
    const result = await auth.listUsers(1000, pageToken);
    if (result.users.length === 0) break;
    const uids = result.users.map((u) => u.uid);
    const deleteResult = await auth.deleteUsers(uids);
    totalDeleted += deleteResult.successCount;
    if (deleteResult.failureCount > 0) {
      console.error('Some auth deletions failed:', deleteResult.errors);
    }
    pageToken = result.pageToken;
  } while (pageToken);
  console.log(`Deleted ${totalDeleted} auth users.`);
}

async function main() {
  console.log('Starting full wipe of project school-pulse-3d95b...');
  await wipeFirestore();
  await wipeAuthUsers();
  console.log('Wipe complete.');
  process.exit(0);
}

main().catch((err) => {
  console.error('Wipe failed:', err);
  process.exit(1);
});
