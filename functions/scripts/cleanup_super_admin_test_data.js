#!/usr/bin/env node
/**
 * Super Admin / SaaS Owner dummy-data audit and cleanup.
 *
 * Scans the platform-level collections the Super Admin console reads from
 * (schools, applications, payments, transactions, memberships, contacts,
 * notifications, audit logs) and classifies each document as REAL or
 * DUMMY/TEST using name/email/id heuristics — there is no `isTest`/`demo`
 * flag written anywhere in the real create-school/payment paths (checked
 * against public_functions/owner.js and payments.js), so this is
 * necessarily a heuristic pass, not an automatic one. Nothing is ever
 * deleted without a human reading the printed classification first.
 *
 * Deliberately out of scope (per the cleanup request): student/teacher/
 * parent/attendance/finance/library/transport/boarding data living inside
 * a school's own subcollections. This script only touches platform-level
 * collections, never `schools/{id}/...` subcollections.
 *
 * Usage:
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
 *   node functions/scripts/cleanup_super_admin_test_data.js
 *     -> DRY RUN. Prints the full classification audit and a manifest.
 *        Deletes nothing.
 *
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
 *   node functions/scripts/cleanup_super_admin_test_data.js --execute [--yes]
 *     -> Deletes only the documents classified DUMMY, after re-printing
 *        the plan and requiring interactive confirmation (unless --yes).
 */
const readline = require("node:readline/promises");
const path = require("node:path");
const fs = require("node:fs");
const admin = require("firebase-admin");

const EXPECTED_PROJECT_ID = "school-pulse-3d95b";
const ADMIN_EMAILS = ["mubangizivic@gmail.com", "admin@gmail.com"];

// Legacy/demo school id used by lib/core/utils/admin_seeder.dart and
// functions/scripts/purge_firestore.js — always dummy if it ever appears
// in a platform-level collection.
const KNOWN_DUMMY_SCHOOL_IDS = new Set(["school-pulse-academy"]);

const DUMMY_NAME_PATTERNS = [
  /\bdummy\b/i,
  /\bdemo\b/i,
  /\bmock\b/i,
  /\bsample\b/i,
  /\bfake\b/i,
  /\btest\s*school\b/i,
  /\bexample\s*school\b/i,
  /^school\s*a$/i,
  /^school\s*b$/i,
  /\bsunrise\s*(high|academy)?\b/i,
  /\bgreen\s*valley\b/i,
  /\bgreenfield\b/i,
  /\bjohn\s*doe\b/i,
  /\bjane\s*doe\b/i,
  /^test/i,
  /\bqa\b/i,
];

const DUMMY_EMAIL_PATTERNS = [
  /@example\.(com|org|net)$/i,
  /@test\.(com|org|net)$/i,
  /^test.*@/i,
  /\+test.*@/i,
  /@schoolpulse\.com$/i, // fictional domain used only in dead mock UI, never real prod
  /@schoolpulse-qa\.test$/i, // synthetic QA pipeline domain seen in public_school_applications
];

// Doc-ID substrings that mark a record as a QA/E2E fixture regardless of
// its field contents — observed in practice across notifications,
// payments, and applications (e.g. "school_application_ZZZ_TEST_..._pending_review",
// "payment_e2e_verify_test_payment"). No \b word-boundary anchors here:
// Firestore ids are underscore-delimited, and \b does not match between
// "_" and a letter (both are \w), so anchored patterns silently failed to
// match ids like "..._e2e_verify_test_...".
const DUMMY_ID_PATTERNS = [
  /ZZZ[_-]?TEST/i,
  /e2e[_-]?verify[_-]?test/i,
  /test[_-]?applicant/i,
  /qa[_-]?real/i,
];

function isAdminEmail(email) {
  return !!email && ADMIN_EMAILS.includes(String(email).trim().toLowerCase());
}

function matchesAny(value, patterns) {
  if (!value) return false;
  const str = String(value);
  return patterns.some((re) => re.test(str));
}

// Resolves a dotted path like "administrator.email" or "school.name"
// against a nested Firestore document map.
function getPath(data, dottedPath) {
  return dottedPath.split(".").reduce((acc, key) => (acc && typeof acc === "object" ? acc[key] : undefined), data);
}

/**
 * Returns { dummy: boolean, reasons: string[] } — reasons is always
 * populated (even when dummy=false, e.g. "no dummy signal found") so the
 * audit printout is legible without cross-referencing this function.
 */
function classifySchool(id, data) {
  const reasons = [];
  if (KNOWN_DUMMY_SCHOOL_IDS.has(id)) reasons.push(`known demo school id "${id}"`);
  if (matchesAny(data.name, DUMMY_NAME_PATTERNS)) reasons.push(`school name "${data.name}" matches dummy pattern`);
  if (matchesAny(data.displayLabel, DUMMY_NAME_PATTERNS)) reasons.push(`displayLabel "${data.displayLabel}" matches dummy pattern`);
  if (matchesAny(data.adminEmail, DUMMY_EMAIL_PATTERNS)) reasons.push(`adminEmail "${data.adminEmail}" matches dummy pattern`);
  if (matchesAny(data.contactEmail, DUMMY_EMAIL_PATTERNS)) reasons.push(`contactEmail "${data.contactEmail}" matches dummy pattern`);
  return { dummy: reasons.length > 0, reasons: reasons.length ? reasons : ["no dummy signal found — treat as real"] };
}

function classifyByEmailAndName(id, data, nameFields, emailFields, dummySchoolIds) {
  const reasons = [];
  for (const f of nameFields) {
    const value = getPath(data, f);
    if (matchesAny(value, DUMMY_NAME_PATTERNS)) reasons.push(`${f} "${value}" matches dummy pattern`);
  }
  for (const f of emailFields) {
    const value = getPath(data, f);
    if (matchesAny(value, DUMMY_EMAIL_PATTERNS)) reasons.push(`${f} "${value}" matches dummy pattern`);
    if (isAdminEmail(value)) reasons.push(`${f} is a protected admin email — NOT dummy`);
  }
  if (data.schoolId && KNOWN_DUMMY_SCHOOL_IDS.has(data.schoolId)) {
    reasons.push(`schoolId "${data.schoolId}" is the known demo school`);
  }
  if (data.schoolId && dummySchoolIds && dummySchoolIds.has(data.schoolId)) {
    reasons.push(`schoolId "${data.schoolId}" references a school already classified dummy`);
  }
  if (matchesAny(id, DUMMY_ID_PATTERNS)) {
    reasons.push(`document id "${id}" matches a known QA/E2E fixture pattern`);
  }
  const protectedHit = reasons.some((r) => r.includes("protected admin email"));
  const dummyHit = reasons.some(
    (r) =>
      r.includes("matches dummy pattern") ||
      r.includes("known demo school") ||
      r.includes("QA/E2E fixture pattern") ||
      r.includes("already classified dummy"),
  );
  return {
    dummy: dummyHit && !protectedHit,
    reasons: reasons.length ? reasons : ["no dummy signal found — treat as real"],
  };
}

// Platform-level collections in scope. `classify` takes (id, data,
// dummySchoolIds) — the third arg is the set of school IDs already
// classified dummy by the `schools` pass, computed first each run, so any
// record referencing one of those schools inherits dummy status even when
// its own name/email fields don't independently match a pattern.
const COLLECTIONS = [
  {
    name: "schools",
    classify: (id, data) => classifySchool(id, data),
    summary: (data) => `name="${data.name || data.displayLabel || ""}" status=${data.status || "?"}`,
  },
  {
    name: "users",
    // Never sweep users automatically — role==superAdmin or an admin email
    // must survive no matter what. Only flag school-scoped admin/staff
    // accounts tied to a known-dummy school.
    classify: (id, data, dummySchoolIds) => {
      if (isAdminEmail(data.email) || data.role === "superAdmin" || (Array.isArray(data.roles) && data.roles.includes("superAdmin"))) {
        return { dummy: false, reasons: ["protected: super admin / admin email — never delete"] };
      }
      return classifyByEmailAndName(id, data, ["name"], ["email"], dummySchoolIds);
    },
    summary: (data) => `name="${data.name || ""}" email="${data.email || ""}" role=${data.role || "?"}`,
  },
  {
    name: "institution_memberships",
    classify: (id, data, dummySchoolIds) => classifyByEmailAndName(id, data, [], ["email"], dummySchoolIds),
    summary: (data) => `schoolId=${data.schoolId || "?"} email="${data.email || ""}"`,
  },
  {
    name: "school_contacts",
    classify: (id, data, dummySchoolIds) => classifyByEmailAndName(id, data, ["name"], ["email"], dummySchoolIds),
    summary: (data) => `schoolId=${data.schoolId || "?"} name="${data.name || ""}" email="${data.email || ""}"`,
  },
  {
    name: "school_admin_invitations",
    classify: (id, data, dummySchoolIds) => classifyByEmailAndName(id, data, [], ["email"], dummySchoolIds),
    summary: (data) => `schoolId=${data.schoolId || "?"} email="${data.email || ""}" status=${data.status || "?"}`,
  },
  {
    name: "public_school_applications",
    // `school` and `administrator` are nested maps on this collection, not
    // flat fields — confirmed against live docs.
    classify: (id, data, dummySchoolIds) =>
      classifyByEmailAndName(id, data, ["school.name"], ["administrator.email", "school.email"], dummySchoolIds),
    summary: (data) => `schoolName="${getPath(data, "school.name") || ""}" status=${data.status || "?"}`,
  },
  {
    name: "payment_transactions",
    // No name/email fields on this collection — classification here is
    // purely inherited via schoolId from a dummy school, or a matching doc id.
    classify: (id, data, dummySchoolIds) => classifyByEmailAndName(id, data, [], [], dummySchoolIds),
    summary: (data) => `schoolId=${data.schoolId || "?"} amountUgx=${data.amountUgx ?? "?"} status=${data.status || "?"}`,
  },
  {
    name: "mtn_payments",
    classify: (id, data, dummySchoolIds) => classifyByEmailAndName(id, data, [], [], dummySchoolIds),
    summary: (data) => `schoolId=${data.schoolId || "?"} amount=${data.amount ?? "?"} status=${data.status || "?"}`,
  },
  {
    name: "manual_subscription_payments",
    // schoolName/payerName/payerEmail are flat fields here (confirmed against live docs).
    classify: (id, data, dummySchoolIds) =>
      classifyByEmailAndName(id, data, ["schoolName", "payerName"], ["payerEmail"], dummySchoolIds),
    summary: (data) => `schoolId=${data.schoolId || "?"} schoolName="${data.schoolName || ""}" status=${data.status || "?"}`,
  },
  {
    name: "subscription_receipts",
    classify: (id, data, dummySchoolIds) => classifyByEmailAndName(id, data, [], [], dummySchoolIds),
    summary: (data) => `schoolId=${data.schoolId || "?"} amount=${data.amount ?? "?"}`,
  },
  {
    name: "super_admin_notifications",
    classify: (id, data, dummySchoolIds) => {
      if (data.type === "owner_notification_test" || String(id).startsWith("owner_test_")) {
        return { dummy: true, reasons: [`type/id marks this a test notification (type="${data.type}", id="${id}")`] };
      }
      // Notification doc IDs embed the school/application/payment id they
      // reference (e.g. "payment_<schoolAuthUid>_..."), so an id-substring
      // match against a dummy school id or the QA/E2E id patterns is the
      // only signal available — there's no schoolId field on this doc.
      if ([...dummySchoolIds].some((sid) => id.includes(sid)) || matchesAny(id, DUMMY_ID_PATTERNS)) {
        return { dummy: true, reasons: [`document id "${id}" references a dummy school or matches a QA/E2E fixture pattern`] };
      }
      return { dummy: false, reasons: ["real platform notification — no dummy signal found"] };
    },
    summary: (data) => `type=${data.type || "?"} title="${data.title || ""}"`,
  },
  {
    name: "super_admin_audit_logs",
    // Deliberately conservative: this is a security/compliance trail, not
    // transactional data. Only an explicit actor-email match against a
    // dummy pattern flags a row — schoolId inheritance is intentionally
    // NOT applied here, so a real audit event about a dummy school (e.g.
    // "you approved this test application") still survives for review.
    classify: (id, data) => classifyByEmailAndName(id, data, [], ["actorEmail", "email"]),
    summary: (data) => `action=${data.action || "?"} actorEmail="${data.actorEmail || ""}"`,
  },
];

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
  // Never hardcode a UID. The real owner is whoever the platform's own
  // seed flag or users collection says has role==superAdmin.
  const uids = new Set();
  try {
    const seedFlag = await db.collection("platform_config").doc("owner_seed").get();
    if (seedFlag.exists && seedFlag.data().ownerUid) uids.add(seedFlag.data().ownerUid);
  } catch (_) {
    // ignore — fall through to the users query below
  }
  const bySnap = await db.collection("users").where("role", "==", "superAdmin").get();
  bySnap.docs.forEach((d) => uids.add(d.id));
  return uids;
}

async function main() {
  const execute = process.argv.includes("--execute");
  const projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;

  console.log(`TARGET PROJECT: ${projectId}`);
  if (projectId !== EXPECTED_PROJECT_ID) {
    console.error(
      `Refusing to run: expected Firebase project "${EXPECTED_PROJECT_ID}" but ` +
      `GOOGLE_CLOUD_PROJECT/GCLOUD_PROJECT is "${projectId}". Set the correct ` +
      `service account / env var before re-running.`,
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
    collections: {},
    authUsersFlagged: [],
  };

  let totalDummy = 0;
  let totalReal = 0;

  // `schools` is classified first (it's first in COLLECTIONS) so every
  // other collection can inherit dummy status via schoolId.
  const dummySchoolIds = new Set();

  for (const col of COLLECTIONS) {
    const snap = await db.collection(col.name).get();
    const dummyDocs = [];
    const realDocs = [];

    for (const doc of snap.docs) {
      const data = doc.data() || {};
      const { dummy, reasons } = col.classify(doc.id, data, dummySchoolIds);
      if (col.name === "schools" && dummy) dummySchoolIds.add(doc.id);
      const row = { id: doc.id, summary: col.summary(data), reasons };
      if (dummy) {
        dummyDocs.push(row);
        totalDummy++;
      } else {
        realDocs.push(row);
        totalReal++;
      }
    }

    manifest.collections[col.name] = {
      totalDocs: snap.size,
      dummyCount: dummyDocs.length,
      realCount: realDocs.length,
      dummy: dummyDocs,
    };

    console.log(`\n=== ${col.name} (${snap.size} docs) ===`);
    if (dummyDocs.length === 0) {
      console.log("  No documents classified as dummy/test.");
    } else {
      console.log(`  DUMMY/TEST (${dummyDocs.length}) — planned for deletion:`);
      dummyDocs.forEach((r) => {
        console.log(`    - ${col.name}/${r.id} :: ${r.summary}`);
        r.reasons.forEach((reason) => console.log(`        reason: ${reason}`));
      });
    }
    if (realDocs.length > 0) {
      console.log(`  REAL/UNCLASSIFIED (${realDocs.length}) — will NOT be touched:`);
      realDocs.forEach((r) => console.log(`    - ${col.name}/${r.id} :: ${r.summary}`));
    }
  }

  // --- Firebase Auth: only flag users NOT in ADMIN_EMAILS and NOT an
  // owner UID, whose displayName/email matches a dummy pattern. We do not
  // delete every non-admin auth user (unlike cleanup_auth_users.js) — only
  // ones with a dummy signal, per this script's audit-first mandate.
  const authUsers = [];
  let pageToken;
  do {
    const page = await auth.listUsers(1000, pageToken);
    authUsers.push(...page.users);
    pageToken = page.pageToken;
  } while (pageToken);

  console.log(`\n=== Firebase Auth (${authUsers.length} users) ===`);
  const dummyAuthUsers = [];
  for (const user of authUsers) {
    if (ownerUids.has(user.uid) || isAdminEmail(user.email)) continue;
    const nameHit = matchesAny(user.displayName, DUMMY_NAME_PATTERNS);
    const emailHit = matchesAny(user.email, DUMMY_EMAIL_PATTERNS);
    if (nameHit || emailHit) {
      const reason = [
        nameHit ? `displayName "${user.displayName}" matches dummy pattern` : null,
        emailHit ? `email "${user.email}" matches dummy pattern` : null,
      ].filter(Boolean).join("; ");
      dummyAuthUsers.push({ uid: user.uid, email: user.email, displayName: user.displayName, reason });
      console.log(`  DUMMY: uid=${user.uid} email=${user.email} displayName="${user.displayName || ""}" — ${reason}`);
    }
  }
  if (dummyAuthUsers.length === 0) console.log("  No Auth users classified as dummy/test.");
  manifest.authUsersFlagged = dummyAuthUsers;

  console.log(`\n--- SUMMARY ---`);
  console.log(`Total documents classified DUMMY: ${totalDummy}`);
  console.log(`Total documents classified REAL/kept: ${totalReal}`);
  console.log(`Auth users classified DUMMY: ${dummyAuthUsers.length}`);
  console.log(
    `\nNOTE: this heuristic pass can both over- and under-flag records — read every ` +
    `row above before trusting it. Nothing matched "REAL/UNCLASSIFIED" should be ` +
    `assumed safe without a human glance, and anything flagged DUMMY should be ` +
    `sanity-checked against the live app before --execute.`,
  );

  // --- Write manifest (always, dry-run or execute) for traceability.
  const backupDir = path.join(__dirname, "..", "..", "cleanup_backups");
  fs.mkdirSync(backupDir, { recursive: true });
  const manifestPath = path.join(backupDir, `super_admin_cleanup_${Date.now()}.json`);
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
  console.log(`\nManifest written: ${manifestPath}`);

  if (!execute) {
    console.log("\nDRY RUN — nothing deleted. Re-run with --execute to delete the DUMMY rows above.");
    return;
  }

  if (totalDummy === 0 && dummyAuthUsers.length === 0) {
    console.log("\nNothing classified as dummy — nothing to delete.");
    return;
  }

  const proceed = await confirm(
    `\nThis will permanently delete ${totalDummy} Firestore document(s) and ${dummyAuthUsers.length} Auth user(s) listed above.`,
  );
  if (!proceed) {
    console.log("Aborted. No changes made.");
    return;
  }

  for (const col of COLLECTIONS) {
    const dummyDocs = manifest.collections[col.name].dummy;
    if (dummyDocs.length === 0) continue;
    const batch = db.batch();
    dummyDocs.forEach((r) => batch.delete(db.collection(col.name).doc(r.id)));
    await batch.commit();
    console.log(`Deleted ${dummyDocs.length} document(s) from ${col.name}.`);
  }

  for (const user of dummyAuthUsers) {
    try {
      await auth.deleteUser(user.uid);
      console.log(`Deleted Auth user: ${user.email} (${user.uid})`);
    } catch (err) {
      console.error(`Failed to delete Auth user ${user.email} (${user.uid}):`, err.message || err);
    }
  }

  console.log("\nCleanup complete.");
}

main().catch((error) => {
  console.error(error.stack || error.message || error);
  process.exit(1);
});
