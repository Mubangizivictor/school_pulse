/**
 * Removes everything `seed_bursar_demo.js` writes for the
 * "school-pulse-academy" demo tenant: the finance collections, the demo
 * students, the student_accounts subtree, and the bursar auth user + its
 * `users/{uid}` profile doc.
 *
 * SAFETY: Admin SDK, bypasses security rules. Point it at the LOCAL
 * emulator only (or a throwaway demo project):
 *
 *   FIRESTORE_EMULATOR_HOST=localhost:8080 \
 *   FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 \
 *   GCLOUD_PROJECT=school-pulse-3d95b \
 *   node functions/scripts/wipe_bursar_demo.js
 *
 * It only touches the demo school namespace, so production finance data for
 * any real tenant is untouched.
 */
const admin = require("firebase-admin");

const PROJECT_ID =
  process.env.GCLOUD_PROJECT ||
  process.env.GOOGLE_CLOUD_PROJECT ||
  "school-pulse-3d95b";

if (!process.env.FIRESTORE_EMULATOR_HOST) {
  console.error(
    "Refusing to run without FIRESTORE_EMULATOR_HOST set — this script " +
      "is for the local emulator / a demo project only.",
  );
  process.exit(1);
}

admin.initializeApp({ projectId: PROJECT_ID });
const db = admin.firestore();

const SCHOOL_ID = "school-pulse-academy";
const BURSAR_EMAIL = "bursar@schoolpulse.demo";

const FINANCE_COLLECTIONS = [
  "expenditures",
  "budgets",
  "bank_accounts",
  "bank_ledger",
  "bank_reconciliations",
  "petty_cash",
  "petty_cash_ledger",
  "petty_cash_vouchers",
  "finance_suppliers",
  "supplier_invoices",
  "payment_vouchers",
  "payroll_runs",
  "payroll_compliance",
  "payroll_remittances",
  "payroll_preparations",
  "finance_audit_events",
  "student_financials",
  "payments",
  "fee_categories",
  "fee_structures",
  // Financial Entitlements & NFC service access
  "financial_entitlement_policy",
  "financial_entitlement_policy_proposals",
  "financial_entitlement_overrides",
  "financial_entitlement_audit",
  "entitlement_terminals",
  "entitlement_taps",
  "entitlement_terminal_nonces",
  "credentials",
];

async function deleteCollection(ref) {
  let removed = 0;
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const snap = await ref.limit(300).get();
    if (snap.empty) break;
    const batch = db.batch();
    for (const doc of snap.docs) {
      for (const sub of await doc.ref.listCollections()) {
        removed += await deleteCollection(sub);
      }
      batch.delete(doc.ref);
    }
    await batch.commit();
    removed += snap.size;
    if (snap.size < 300) break;
  }
  return removed;
}

(async () => {
  console.log(`Wiping Bursar demo → project ${PROJECT_ID}`);
  console.log(`  Firestore emulator: ${process.env.FIRESTORE_EMULATOR_HOST}\n`);

  let total = 0;
  for (const name of FINANCE_COLLECTIONS) {
    const n = await deleteCollection(
      db.collection(`schools/${SCHOOL_ID}/${name}`),
    );
    if (n) console.log(`  ${name}: ${n} docs`);
    total += n;
  }

  const accounts = await deleteCollection(
    db.collection(`schools/${SCHOOL_ID}/student_accounts`),
  );
  if (accounts) console.log(`  student_accounts (+subtree): ${accounts} docs`);
  total += accounts;

  const students = await db
    .collection("students")
    .where("schoolId", "==", SCHOOL_ID)
    .get();
  if (!students.empty) {
    const batch = db.batch();
    students.docs.forEach((d) => batch.delete(d.ref));
    await batch.commit();
    console.log(`  students: ${students.size} docs`);
    total += students.size;
  }

  try {
    const user = await admin.auth().getUserByEmail(BURSAR_EMAIL);
    await admin.auth().deleteUser(user.uid);
    await db.doc(`users/${user.uid}`).delete().catch(() => {});
    console.log(`  auth user ${BURSAR_EMAIL} (${user.uid}) deleted`);
  } catch (e) {
    console.log(`  auth user ${BURSAR_EMAIL}: ${e.code || e.message}`);
  }

  console.log(`\nDone. ${total} Firestore docs removed from ${SCHOOL_ID}.`);
})();
