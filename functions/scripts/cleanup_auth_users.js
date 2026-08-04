#!/usr/bin/env node
/**
 * Cleanup script to remove all demo users from Firebase Auth except the admins.
 *
 * Usage:
 *   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
 *   node functions/scripts/cleanup_auth_users.js [--yes]
 */
const admin = require("firebase-admin");
const readline = require("node:readline/promises");

const ADMIN_EMAILS = ["mubangizivic@gmail.com", "admin@gmail.com"];

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
  const projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;
  const storageBucket = `${projectId}.firebasestorage.app`;
  admin.initializeApp({
    projectId,
    storageBucket
  });
  const auth = admin.auth();

  console.log(`Target Project: ${projectId}`);

  const proceed = await confirm(
    `This will delete ALL Firebase Auth users except: ${ADMIN_EMAILS.join(", ")}.`
  );
  if (!proceed) {
    console.log("Aborted.");
    return;
  }

  let deleteCount = 0;
  let skipCount = 0;

  async function processUsers(nextPageToken) {
    const listUsersResult = await auth.listUsers(1000, nextPageToken);
    const users = listUsersResult.users;

    for (const user of users) {
      if (ADMIN_EMAILS.includes(user.email)) {
        console.log(`Skipping admin: ${user.email}`);
        skipCount++;
        continue;
      }

      try {
        await auth.deleteUser(user.uid);
        console.log(`Deleted user: ${user.email} (${user.uid})`);
        deleteCount++;
      } catch (error) {
        console.error(`Failed to delete user ${user.email}:`, error);
      }
    }

    if (listUsersResult.pageToken) {
      await processUsers(listUsersResult.pageToken);
    }
  }

  try {
    await processUsers();
    console.log(`\nAuth Cleanup complete.`);
    console.log(`Deleted: ${deleteCount} users`);
    console.log(`Skipped: ${skipCount} admins`);

    // --- Cleanup Storage ---
    const storageProceed = await confirm(
      "Do you also want to delete all files in the Firebase Storage bucket?"
    );
    if (storageProceed) {
      console.log("Cleaning up Storage...");
      const bucket = admin.storage().bucket();
      const [files] = await bucket.getFiles();
      if (files.length === 0) {
        console.log("Storage bucket is already empty.");
      } else {
        await Promise.all(files.map(file => file.delete()));
        console.log(`Deleted ${files.length} files from Storage.`);
      }
    }

  } catch (error) {
    console.error("Error during cleanup:", error);
  }
}

main().catch(console.error);
