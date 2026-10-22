/**
 * E2E helper: gives the first few seed_bursar_demo.js students an active
 * `credentials/{id}` doc so the Financial Entitlements terminal / card-token
 * / tap path can be exercised. Emulator-only; run AFTER seed_bursar_demo.js.
 *
 *   FIRESTORE_EMULATOR_HOST=localhost:8080 GCLOUD_PROJECT=school-pulse-3d95b \
 *   node functions/scripts/seed_entitlement_credentials.js
 */
const admin = require("firebase-admin");
if (!process.env.FIRESTORE_EMULATOR_HOST) {
  console.error("Refusing to run without FIRESTORE_EMULATOR_HOST.");
  process.exit(1);
}
admin.initializeApp({
  projectId: process.env.GCLOUD_PROJECT || "school-pulse-3d95b",
});
const db = admin.firestore();
const SCHOOL = "school-pulse-academy";

(async () => {
  const students = await db
    .collection("students")
    .where("schoolId", "==", SCHOOL)
    .limit(5)
    .get();
  let n = 0;
  const batch = db.batch();
  for (const s of students.docs) {
    const id = `cred_${s.id}`;
    batch.set(db.doc(`schools/${SCHOOL}/credentials/${id}`), {
      identityType: "student",
      identityId: s.id,
      status: "active",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    n++;
  }
  await batch.commit();
  console.log(`Seeded ${n} student credentials for ${SCHOOL}.`);
})();
