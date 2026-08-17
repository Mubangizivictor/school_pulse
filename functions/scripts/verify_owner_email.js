#!/usr/bin/env node
/**
 * One-off fix: marks the seeded SaaS owner's email as verified.
 *
 * bootstrap_owner.js creates the owner with emailVerified: false and never
 * sends a verification email (it's a local admin script, not a signup flow),
 * so the account is otherwise permanently unable to pass Firebase Auth's
 * "verify email before MFA enrollment" gate.
 *
 * Usage:
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
 *   OWNER_EMAIL=owner@victorbee.tech \
 *   node functions/scripts/verify_owner_email.js
 */
const admin = require("firebase-admin");

async function main() {
  const email = process.env.OWNER_EMAIL;
  if (!email) {
    throw new Error("Missing required environment variable: OWNER_EMAIL");
  }

  const projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;
  admin.initializeApp({ projectId });
  const auth = admin.auth();

  const user = await auth.getUserByEmail(email);
  if (user.emailVerified) {
    console.log(`Already verified: uid=${user.uid}, email=${email}`);
    return;
  }

  await auth.updateUser(user.uid, { emailVerified: true });
  console.log(`Marked emailVerified=true for uid=${user.uid}, email=${email}`);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(`verify_owner_email failed: ${err.message}`);
    process.exit(1);
  });
