#!/usr/bin/env node
/**
 * One-off: create a single empty school admin account for manual testing.
 *
 * Usage:
 *   node functions/scripts/seed_empty_admin.js
 */
const admin = require("firebase-admin");

const EMAIL = "admin@gmail.com";
const PASSWORD = "Test@123";
const SCHOOL_ID = "school-pulse-academy";

async function getOrCreateAuthUser(email, password, displayName) {
  const auth = admin.auth();
  try {
    return await auth.getUserByEmail(email);
  } catch (err) {
    if (err.code !== "auth/user-not-found") throw err;
  }
  return auth.createUser({
    email,
    password,
    displayName,
    emailVerified: false,
    disabled: false,
  });
}

async function main() {
  const projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;
  admin.initializeApp({ projectId });
  const auth = admin.auth();
  const db = admin.firestore();

  const userRecord = await getOrCreateAuthUser(EMAIL, PASSWORD, "School Admin");
  await auth.setCustomUserClaims(userRecord.uid, { role: "schoolAdmin", schoolId: SCHOOL_ID });

  // Root tenant doc - required by GetSchoolBranding (schools/{id}.get()) or
  // the post-login splash hangs forever on "School branding not found".
  const schoolRef = db.collection("schools").doc(SCHOOL_ID);
  const schoolSnap = await schoolRef.get();
  if (!schoolSnap.exists) {
    await schoolRef.set({
      name: "School Pulse Academy",
      schoolName: "School Pulse Academy",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // Test-only: mark subscription as fully paid/active so the dashboard
  // isn't gated behind "Subscription renewal required". Normally written
  // by Cloud Functions (payment approval / lifecycle sweep in payments.js).
  await schoolRef.set(
    {
      accessMode: "full",
      status: "active",
      subscriptionExpiry: new Date("2030-12-31").getTime(),
      "metadata.subscriptionStatus": "active",
      "metadata.hasEverActivated": true,
    },
    { merge: true }
  );

  await db.collection("users").doc(userRecord.uid).set(
    {
      id: userRecord.uid,
      name: "School Admin",
      email: EMAIL,
      role: "schoolAdmin",
      roles: ["schoolAdmin"],
      schoolId: SCHOOL_ID,
      studentIds: [],
      status: "active",
      isActive: true,
      mustChangePassword: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  console.log(`Empty school admin ready: uid=${userRecord.uid}, email=${EMAIL}, schoolId=${SCHOOL_ID}`);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(`seed_empty_admin failed: ${err.message}`);
    process.exit(1);
  });
