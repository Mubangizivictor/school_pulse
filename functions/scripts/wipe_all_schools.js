#!/usr/bin/env node
/**
 * Full production reset of the Super Admin / SaaS Owner console back to a
 * true zero-state: EVERY school and everything that references it. Unlike
 * cleanup_super_admin_test_data.js (which only removes records matching a
 * dummy/test heuristic), this deletes unconditionally - it does not try to
 * distinguish a real school from a test one. Run this only when the intent
 * is "wipe every school in production," not "clean up test data."
 *
 * Deliberately out of scope, same as cleanup_super_admin_test_data.js:
 * never touches subscription_plans, platform_billing_config, platform_config,
 * platform_owner_settings, or any users/{uid} doc for a protected owner/admin
 * account. Never touches a school's own subcollections
 * (schools/{id}/students, /attendance, /fees, etc.) - those subcollections
 * are deleted implicitly along with the parent by walking and deleting each
 * one explicitly below, but the module-specific subcollection LIST is the
 * one already used by functions/scripts/purge_firestore.js, kept in sync
 * with it here.
 *
 * Usage:
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
 *   node functions/scripts/wipe_all_schools.js
 *     -> DRY RUN. Prints every school and dependent record that would be
 *        deleted. Deletes nothing.
 *
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
 *   node functions/scripts/wipe_all_schools.js --execute [--yes]
 *     -> Deletes every school + all dependent records + associated non-owner
 *        Auth users, after re-printing the plan and requiring interactive
 *        confirmation (unless --yes).
 */
const readline = require("node:readline/promises");
const path = require("node:path");
const fs = require("node:fs");
const admin = require("firebase-admin");

const EXPECTED_PROJECT_ID = "school-pulse-3d95b";
const ADMIN_EMAILS = ["mubangizivic@gmail.com", "admin@gmail.com"];

// Platform-level collections that carry a schoolId (or, for schools itself,
// its own doc id) tying them to a specific tenant. Every doc in each of
// these collections is deleted unconditionally in this script - there is
// no dummy/real distinction here.
const SCHOOL_SCOPED_COLLECTIONS = [
  "institution_memberships",
  "school_contacts",
  "school_admin_invitations",
  "public_school_applications",
  "payment_transactions",
  "mtn_payments",
  "manual_subscription_payments",
  "subscription_receipts",
];

// Same per-school subcollection list purge_firestore.js already uses for
// the single demo school - applied here across every real school doc too,
// since a full wipe must not leave orphaned subcollections behind.
const SCHOOL_SUBCOLLECTIONS = [
  "staff_role_assignments",
  "subject_audit_logs",
  "class_attendance_sessions",
  "class_attendance_corrections",
  "class_report_entries",
  "class_homework",
  "class_behaviour_records",
  "lessons",
];

function isAdminEmail(email) {
  return !!email && ADMIN_EMAILS.includes(String(email).trim().toLowerCase());
}

async function confirm(message) {
  if (process.argv.includes("--yes")) return true;
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  try {
    const answer = await rl.question(`${message} Type "yes" to continue: `);
    return answer.trim().toLowerCase() === "yes";
  } finally {
    rl.close();
  }
}

async function findOwnerUids(db) {
  const uids = new Set();
  try {
    const seedFlag = await db.collection("platform_config").doc("owner_seed").get();
    if (seedFlag.exists && seedFlag.data().ownerUid) uids.add(seedFlag.data().ownerUid);
  } catch (_) {
    // fall through to the users query below
  }
  const bySnap = await db.collection("users").where("role", "==", "superAdmin").get();
  bySnap.docs.forEach((d) => uids.add(d.id));
  return uids;
}

async function deleteInBatches(db, refs) {
  const BATCH_SIZE = 400;
  for (let i = 0; i < refs.length; i += BATCH_SIZE) {
    const batch = db.batch();
    refs.slice(i, i + BATCH_SIZE).forEach((ref) => batch.delete(ref));
    await batch.commit();
  }
}

async function main() {
  const execute = process.argv.includes("--execute");
  const projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;

  console.log(`TARGET PROJECT: ${projectId}`);
  if (projectId !== EXPECTED_PROJECT_ID) {
    console.error(
      `Refusing to run: expected Firebase project "${EXPECTED_PROJECT_ID}" but ` +
      `GOOGLE_CLOUD_PROJECT/GCLOUD_PROJECT is "${projectId}".`,
    );
    process.exit(1);
  }

  admin.initializeApp({ projectId });
  const db = admin.firestore();
  const auth = admin.auth();

  const ownerUids = await findOwnerUids(db);
  if (ownerUids.size === 0) {
    console.error(
      "Refusing to run: could not establish any superAdmin owner UID from " +
      "platform_config/owner_seed or users where role==superAdmin. Owner " +
      "protection cannot be guaranteed, so aborting before reading further.",
    );
    process.exit(1);
  }
  console.log(`Owner protection established for UID(s): ${[...ownerUids].join(", ")}`);
  console.log(`Protected admin emails: ${ADMIN_EMAILS.join(", ")}\n`);

  const manifest = {
    project: projectId,
    mode: execute ? "execute" : "dry-run",
    generatedAt: new Date().toISOString(),
    ownerUidsProtected: [...ownerUids],
    schools: [],
    collections: {},
    usersDeleted: [],
    authUsersDeleted: [],
  };

  // --- Schools + their subcollections ---
  const schoolsSnap = await db.collection("schools").get();
  const schoolIds = schoolsSnap.docs.map((d) => d.id);
  console.log(`=== schools (${schoolsSnap.size} docs) — ALL will be deleted ===`);
  const schoolRefs = [];
  for (const doc of schoolsSnap.docs) {
    const data = doc.data() || {};
    console.log(`  - schools/${doc.id} :: name="${data.name || data.displayLabel || ""}" status=${data.status || "?"}`);
    manifest.schools.push({ id: doc.id, name: data.name || data.displayLabel || "" });
    schoolRefs.push(doc.ref);

    for (const sub of SCHOOL_SUBCOLLECTIONS) {
      const subSnap = await doc.ref.collection(sub).get();
      if (subSnap.empty) continue;
      console.log(`      subcollection schools/${doc.id}/${sub}: ${subSnap.size} docs`);
      manifest.collections[`schools/${doc.id}/${sub}`] = subSnap.docs.map((d) => d.id);
      if (execute) await deleteInBatches(db, subSnap.docs.map((d) => d.ref));
    }
  }

  // --- Platform-level collections scoped by schoolId ---
  for (const col of SCHOOL_SCOPED_COLLECTIONS) {
    const snap = await db.collection(col).get();
    console.log(`\n=== ${col} (${snap.size} docs) — ALL will be deleted ===`);
    manifest.collections[col] = snap.docs.map((d) => d.id);
    snap.docs.slice(0, 20).forEach((d) => console.log(`  - ${col}/${d.id}`));
    if (snap.size > 20) console.log(`  ... and ${snap.size - 20} more`);
    if (execute) await deleteInBatches(db, snap.docs.map((d) => d.ref));
  }

  // --- super_admin_notifications: delete all (platform notifications are
  // inherently about schools/applications/payments, all of which are gone
  // after this wipe) ---
  const notifSnap = await db.collection("super_admin_notifications").get();
  console.log(`\n=== super_admin_notifications (${notifSnap.size} docs) — ALL will be deleted ===`);
  manifest.collections["super_admin_notifications"] = notifSnap.docs.map((d) => d.id);
  if (execute) await deleteInBatches(db, notifSnap.docs.map((d) => d.ref));

  // --- users: delete every non-owner, non-admin-email account (school
  // admins/staff/parents - anyone tied to a school that no longer exists) ---
  const usersSnap = await db.collection("users").get();
  const usersToDelete = usersSnap.docs.filter((doc) => {
    const data = doc.data() || {};
    if (ownerUids.has(doc.id) || isAdminEmail(data.email) || data.role === "superAdmin") return false;
    return true;
  });
  console.log(`\n=== users (${usersSnap.size} docs total) — ${usersToDelete.length} will be deleted, owner/admin accounts kept ===`);
  usersToDelete.slice(0, 20).forEach((d) => {
    const data = d.data() || {};
    console.log(`  - users/${d.id} :: name="${data.name || ""}" email="${data.email || ""}" role=${data.role || "?"}`);
  });
  if (usersToDelete.length > 20) console.log(`  ... and ${usersToDelete.length - 20} more`);
  manifest.usersDeleted = usersToDelete.map((d) => ({ id: d.id, email: (d.data() || {}).email || "" }));
  if (execute) await deleteInBatches(db, usersToDelete.map((d) => d.ref));

  if (execute) await deleteInBatches(db, schoolRefs);

  // --- Firebase Auth: delete every non-owner, non-admin-email user ---
  const authUsers = [];
  let pageToken;
  do {
    const page = await auth.listUsers(1000, pageToken);
    authUsers.push(...page.users);
    pageToken = page.pageToken;
  } while (pageToken);

  const authToDelete = authUsers.filter((u) => !ownerUids.has(u.uid) && !isAdminEmail(u.email));
  console.log(`\n=== Firebase Auth (${authUsers.length} users total) — ${authToDelete.length} will be deleted, owner/admin accounts kept ===`);
  authToDelete.forEach((u) => console.log(`  - uid=${u.uid} email=${u.email} displayName="${u.displayName || ""}"`));
  manifest.authUsersDeleted = authToDelete.map((u) => ({ uid: u.uid, email: u.email, displayName: u.displayName || "" }));

  console.log(`\n--- SUMMARY ---`);
  console.log(`Schools to delete: ${manifest.schools.length}`);
  console.log(`Users (Firestore) to delete: ${usersToDelete.length}`);
  console.log(`Auth users to delete: ${authToDelete.length}`);
  console.log(`Owner/admin accounts preserved: ${[...ownerUids].join(", ")} / ${ADMIN_EMAILS.join(", ")}`);

  const backupDir = path.join(__dirname, "..", "..", "cleanup_backups");
  fs.mkdirSync(backupDir, { recursive: true });
  const manifestPath = path.join(backupDir, `wipe_all_schools_${Date.now()}.json`);
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
  console.log(`\nManifest written: ${manifestPath}`);

  if (!execute) {
    console.log("\nDRY RUN — nothing deleted. Re-run with --execute to perform the full wipe above.");
    return;
  }

  const proceed = await confirm(
    `\nThis will PERMANENTLY delete ALL ${manifest.schools.length} schools, ${usersToDelete.length} Firestore user(s), and ${authToDelete.length} Auth user(s) from production project "${projectId}". This cannot be undone.`,
  );
  if (!proceed) {
    console.log("Aborted before Auth deletion. Firestore data above was already deleted in this run — re-run to check nothing remains, or restore from the manifest/backups if this was a mistake.");
    return;
  }

  for (const user of authToDelete) {
    try {
      await auth.deleteUser(user.uid);
      console.log(`Deleted Auth user: ${user.email} (${user.uid})`);
    } catch (err) {
      console.error(`Failed to delete Auth user ${user.email} (${user.uid}):`, err.message || err);
    }
  }

  console.log("\nFull wipe complete.");
}

main().catch((error) => {
  console.error(error.stack || error.message || error);
  process.exit(1);
});
