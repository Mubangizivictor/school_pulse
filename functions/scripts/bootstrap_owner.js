#!/usr/bin/env node
/**
 * One-time SaaS owner account seeder.
 *
 * This is deliberately a standalone script, NOT a deployed Cloud Function -
 * the owner account must never be reachable over the network (no HTTP
 * endpoint, no callable, no sign-up form). It is run locally or from a
 * trusted CI job by whoever already holds the Firebase service account key,
 * which is the actual authorization boundary here.
 *
 * Usage:
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
 *   OWNER_EMAIL=owner@victorbee.tech \
 *   OWNER_PASSWORD='a long, random, unique passphrase' \
 *   OWNER_PHONE='+15551234567' \
 *   OWNER_SETUP_SECRET='a separate long random string, just a fat-finger guard' \
 *   node functions/scripts/bootstrap_owner.js [--yes]
 *
 * Safe to re-run: after the first successful seed, a platform_config/owner_seed
 * flag is written and every subsequent invocation refuses to run, regardless
 * of the credentials supplied.
 */
const readline = require("node:readline/promises");
const admin = require("firebase-admin");

const REQUIRED_ENV = ["OWNER_EMAIL", "OWNER_PASSWORD", "OWNER_PHONE", "OWNER_SETUP_SECRET"];

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

async function main() {
  const missing = REQUIRED_ENV.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    throw new Error(`Missing required environment variable(s): ${missing.join(", ")}`);
  }

  const email = process.env.OWNER_EMAIL.trim();
  const password = process.env.OWNER_PASSWORD;
  const phoneNumber = process.env.OWNER_PHONE.trim();
  const setupSecret = process.env.OWNER_SETUP_SECRET;

  if (password.length < 12) {
    throw new Error("OWNER_PASSWORD must be at least 12 characters.");
  }
  if (setupSecret.length < 20) {
    throw new Error(
      "OWNER_SETUP_SECRET must be at least 20 characters - it exists to catch " +
      "accidental/copy-paste runs, not as the real auth boundary (that's the " +
      "service account credential you're already authenticating with)."
    );
  }

  // projectId must be explicit (not left to env-var inference) - the Admin
  // SDK only attaches the x-goog-user-project quota header, required by
  // identitytoolkit when authenticating with personal/ADC credentials
  // (as opposed to a service account key), when app.options.projectId is set.
  const projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;
  admin.initializeApp({ projectId });
  const auth = admin.auth();
  const db = admin.firestore();

  const seedFlagRef = db.collection("platform_config").doc("owner_seed");
  const existing = await seedFlagRef.get();
  if (existing.exists && existing.data().seeded) {
    throw new Error(
      `Refusing to run: the SaaS owner account was already seeded ` +
      `(uid=${existing.data().ownerUid}, at=${existing.data().seededAt?.toDate?.() ?? "unknown"}). ` +
      `Use the platform dashboard to manage the owner account from here on.`
    );
  }

  const proceed = await confirm(
    `About to create the SaaS owner account "${email}" on Firebase project "${projectId}".`
  );
  if (!proceed) {
    console.log("Aborted.");
    return;
  }

  let userRecord;
  try {
    userRecord = await auth.createUser({
      email,
      password,
      phoneNumber,
      emailVerified: false,
      disabled: false,
    });
  } catch (err) {
    if (err.code === "auth/email-already-exists") {
      throw new Error(`An account with email "${email}" already exists in Firebase Auth.`);
    }
    throw err;
  }

  try {
    await auth.setCustomUserClaims(userRecord.uid, { role: "superAdmin" });

    const batch = db.batch();
    batch.set(db.collection("users").doc(userRecord.uid), {
      name: "Platform Owner",
      email,
      phone: phoneNumber,
      role: "superAdmin",
      roles: ["superAdmin"],
      schoolId: null,
      studentIds: [],
      // Forces the existing force-set-password screen on first login; MFA
      // enrollment is a separate, not-yet-built gate this flag does not
      // cover.
      mustChangePassword: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    batch.set(seedFlagRef, {
      seeded: true,
      seededAt: admin.firestore.FieldValue.serverTimestamp(),
      ownerUid: userRecord.uid,
    });
    await batch.commit();
  } catch (err) {
    // Don't leave an orphaned, unlisted Auth superuser around on failure.
    await auth.deleteUser(userRecord.uid).catch(() => {});
    throw err;
  }

  console.log(`SaaS owner account created: uid=${userRecord.uid}, email=${email}`);
  console.log("Next steps: sign in, set a new password when prompted, then enroll MFA once that flow ships.");
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(`bootstrap_owner failed: ${err.message}`);
    process.exit(1);
  });
