#!/usr/bin/env node
/**
 * Read-only inspection of a single staff member's account wiring.
 *
 * Looks up an Auth user by email, then reads users/{uid}, school_contacts/{uid},
 * and queries staff_role_assignments for that uid. Prints everything except
 * the account's password (Admin SDK never has access to it anyway).
 *
 * Usage:
 *   node functions/scripts/inspect_staff_record.js <email>
 */
const admin = require("firebase-admin");

const projectId = "school-pulse-3d95b";
admin.initializeApp({ projectId });

async function main() {
  const email = process.argv[2];
  if (!email) {
    console.error("Usage: node inspect_staff_record.js <email>");
    process.exit(1);
  }

  console.log(`\n=== Auth user for ${email} ===`);
  let userRecord;
  try {
    userRecord = await admin.auth().getUserByEmail(email);
  } catch (err) {
    console.error(`Auth lookup failed: ${err.message}`);
    process.exit(1);
  }
  const uid = userRecord.uid;
  console.log({
    uid,
    email: userRecord.email,
    disabled: userRecord.disabled,
    emailVerified: userRecord.emailVerified,
    customClaims: userRecord.customClaims || null,
    metadata: userRecord.metadata,
  });

  const db = admin.firestore();

  console.log(`\n=== users/${uid} ===`);
  const userDoc = await db.collection("users").doc(uid).get();
  if (!userDoc.exists) {
    console.log("(missing)");
  } else {
    console.log(JSON.stringify(userDoc.data(), null, 2));
  }

  console.log(`\n=== school_contacts/${uid} ===`);
  const contactDoc = await db.collection("school_contacts").doc(uid).get();
  if (!contactDoc.exists) {
    console.log("(missing)");
  } else {
    console.log(JSON.stringify(contactDoc.data(), null, 2));
  }

  const schoolId = userDoc.exists ? userDoc.data().schoolId : null;
  console.log(
    `\n=== schools/${schoolId}/staff_role_assignments where userId == ${uid} ===`
  );
  let byUserId = { size: 0, forEach: () => {} };
  if (schoolId) {
    byUserId = await db
      .collection("schools")
      .doc(schoolId)
      .collection("staff_role_assignments")
      .where("userId", "==", uid)
      .get();
  }
  console.log(`byUserId: ${byUserId.size} doc(s)`);
  byUserId.forEach((d) => console.log(d.id, JSON.stringify(d.data(), null, 2)));

  console.log("\n=== Summary ===");
  const flatAssignedClass = userDoc.exists ? userDoc.data().assignedClass : undefined;
  const flatSubjects = userDoc.exists ? userDoc.data().subjects : undefined;
  console.log({
    hasLegacyAssignedClass: flatAssignedClass !== undefined,
    legacyAssignedClass: flatAssignedClass ?? null,
    hasLegacySubjects: flatSubjects !== undefined,
    legacySubjects: flatSubjects ?? null,
    staffRoleAssignmentsCount: byUserId.size,
  });
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("Fatal error:", err);
    process.exit(1);
  });
