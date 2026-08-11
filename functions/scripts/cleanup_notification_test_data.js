#!/usr/bin/env node
/**
 * ONE-TIME PLATFORM CLEANUP TOOL. DO NOT RUN DURING NORMAL OPERATION.
 *
 * Removes leftover owner-notification test documents and stale/disabled
 * owner device tokens left behind by the retired manual test/health
 * callables. Never run automatically - always review --dry-run output first.
 *
 * Usage:
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
 *   node functions/scripts/cleanup_notification_test_data.js --dry-run
 *
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
 *   node functions/scripts/cleanup_notification_test_data.js --execute [--yes]
 */
const readline = require("node:readline/promises");
const admin = require("firebase-admin");

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
  const dryRun = process.argv.includes("--dry-run");
  const execute = process.argv.includes("--execute");
  if (!dryRun && !execute) {
    throw new Error("Pass --dry-run to preview or --execute to delete.");
  }

  const projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;
  admin.initializeApp({ projectId });
  const db = admin.firestore();

  console.log(`Target Project: ${projectId}`);

  // Test notifications: type === owner_notification_test OR eventId startswith owner_test_
  const notifSnap = await db.collection("super_admin_notifications").get();
  const testNotifDocs = notifSnap.docs.filter((doc) => {
    const data = doc.data() || {};
    return data.type === "owner_notification_test" || String(doc.id).startsWith("owner_test_");
  });

  // Stale/disabled owner device tokens
  const tokensSnap = await db.collection("platform_owner_device_tokens").get();
  const staleTokenDocs = tokensSnap.docs.filter((doc) => (doc.data() || {}).enabled === false);

  console.log(`Test notifications found: ${testNotifDocs.length}`);
  testNotifDocs.forEach((doc) => console.log(`  - super_admin_notifications/${doc.id}`));
  console.log(`Stale/disabled owner device tokens found: ${staleTokenDocs.length}`);
  staleTokenDocs.forEach((doc) => console.log(`  - platform_owner_device_tokens/${doc.id}`));

  if (dryRun) {
    console.log("\nDry run only - nothing deleted. Re-run with --execute to delete.");
    return;
  }

  if (testNotifDocs.length === 0 && staleTokenDocs.length === 0) {
    console.log("Nothing to delete.");
    return;
  }

  const proceed = await confirm(
    `This will permanently delete ${testNotifDocs.length} test notification(s) and ${staleTokenDocs.length} stale token(s).`,
  );
  if (!proceed) {
    console.log("Aborted.");
    return;
  }

  const batch = db.batch();
  [...testNotifDocs, ...staleTokenDocs].forEach((doc) => batch.delete(doc.ref));
  await batch.commit();
  console.log("Cleanup complete.");
}

main().catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
