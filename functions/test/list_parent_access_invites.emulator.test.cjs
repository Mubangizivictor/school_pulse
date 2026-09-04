// Firebase Emulator integration test for exports.listParentAccessInvites in
// functions/index.js - the only legal read path for parent_access_code_invites,
// which is `allow read, write: if false` in firestore.rules. Mirrors
// create_parent_access_code.emulator.test.cjs's structure and fixtures.
//
// Run via the same emulator harness as the other *.emulator.test.cjs files
// in this directory (firestore + auth emulators required).
const { after, before, beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-list-parent-access-invites-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || "localhost:9099";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const { listParentAccessInvites } = require("../index");

const admin = require("firebase-admin");
const db = admin.firestore();

const SCHOOL = "schoolA";
const SCHOOL_B = "schoolB";
const ADMIN_UID = "schoolAdminUid";
const NON_ADMIN_UID = "classTeacherUid";

function request(uid, data) {
  return { auth: uid ? { uid } : null, data };
}

async function clearFirestore() {
  const collections = await db.listCollections();
  await Promise.all(collections.map((c) => deleteCollectionRecursive(c)));
}

async function deleteCollectionRecursive(collectionRef) {
  const docRefs = await collectionRef.listDocuments();
  await Promise.all(
    docRefs.map(async (docRef) => {
      const subcollections = await docRef.listCollections();
      await Promise.all(subcollections.map((c) => deleteCollectionRecursive(c)));
      await docRef.delete();
    })
  );
}

async function seedBaseFixtures() {
  await db.doc(`users/${ADMIN_UID}`).set({
    roles: ["schoolAdmin"],
    schoolId: SCHOOL,
    schoolName: "School A",
  });
  await db.doc(`users/${NON_ADMIN_UID}`).set({
    roles: ["classTeacher"],
    schoolId: SCHOOL,
  });
}

function invite(overrides = {}) {
  return {
    schoolId: SCHOOL,
    codeHash: "irrelevant-hash-value",
    parentName: "Jane Parent",
    phoneNumber: "+256701234567",
    learnerIds: ["studentA"],
    status: "active",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt: admin.firestore.Timestamp.fromMillis(Date.now() + 7 * 24 * 60 * 60 * 1000),
    ...overrides,
  };
}

describe("listParentAccessInvites", () => {
  beforeEach(async () => {
    await clearFirestore();
    await seedBaseFixtures();
  });

  after(async () => {
    await clearFirestore();
  });

  test("a non-admin caller is rejected", async () => {
    await assert.rejects(
      () => listParentAccessInvites.run(request(NON_ADMIN_UID, {})),
      (err) => {
        assert.equal(err.code, "permission-denied");
        return true;
      }
    );
  });

  test("an unauthenticated caller is rejected", async () => {
    await assert.rejects(
      () => listParentAccessInvites.run(request(null, {})),
      (err) => {
        assert.equal(err.code, "unauthenticated");
        return true;
      }
    );
  });

  test("an admin caller receives this school's invites, masked, no raw phone or hash", async () => {
    await db.collection("parent_access_code_invites").add(invite());
    const result = await listParentAccessInvites.run(request(ADMIN_UID, {}));

    assert.equal(result.rows.length, 1);
    const row = result.rows[0];
    assert.equal(row.parentName, "Jane Parent");
    assert.equal(row.maskedPhone, "***4567");
    assert.equal(row.learnerCount, 1);
    assert.equal(row.status, "active");
    assert.equal(row.phoneNumber, undefined);
    assert.equal(row.codeHash, undefined);
    assert.equal(row.code, undefined);
  });

  test("cross-tenant data is never returned - only the caller's own school", async () => {
    await db.collection("parent_access_code_invites").add(invite({ schoolId: SCHOOL_B, parentName: "Other School Parent" }));
    await db.collection("parent_access_code_invites").add(invite({ parentName: "My School Parent" }));

    const result = await listParentAccessInvites.run(request(ADMIN_UID, {}));

    assert.equal(result.rows.length, 1);
    assert.equal(result.rows[0].parentName, "My School Parent");
  });

  test("an invite past its expiresAt is reported expired even if status is still stored as active", async () => {
    await db.collection("parent_access_code_invites").add(
      invite({
        status: "active",
        expiresAt: admin.firestore.Timestamp.fromMillis(Date.now() - 1000),
      })
    );

    const result = await listParentAccessInvites.run(request(ADMIN_UID, {}));

    assert.equal(result.rows.length, 1);
    assert.equal(result.rows[0].status, "expired");
  });

  test("a revoked invite is reported revoked even if it also happens to be past expiry", async () => {
    await db.collection("parent_access_code_invites").add(
      invite({
        status: "revoked",
        expiresAt: admin.firestore.Timestamp.fromMillis(Date.now() - 1000),
      })
    );

    const result = await listParentAccessInvites.run(request(ADMIN_UID, {}));

    assert.equal(result.rows[0].status, "revoked");
  });

  test("expiringSoon is true only within the 48h window and only for active invites", async () => {
    await db.collection("parent_access_code_invites").add(
      invite({ expiresAt: admin.firestore.Timestamp.fromMillis(Date.now() + 12 * 60 * 60 * 1000) })
    );
    await db.collection("parent_access_code_invites").add(
      invite({ expiresAt: admin.firestore.Timestamp.fromMillis(Date.now() + 5 * 24 * 60 * 60 * 1000) })
    );

    const result = await listParentAccessInvites.run(request(ADMIN_UID, {}));

    const soon = result.rows.find((r) => r.expiringSoon);
    const notSoon = result.rows.find((r) => !r.expiringSoon);
    assert.ok(soon);
    assert.ok(notSoon);
    assert.equal(result.expiringSoonCount, 1);
  });

  test("pendingCount excludes revoked and expired invites", async () => {
    await db.collection("parent_access_code_invites").add(invite({ status: "active" }));
    await db.collection("parent_access_code_invites").add(invite({ status: "revoked" }));
    await db.collection("parent_access_code_invites").add(
      invite({ status: "active", expiresAt: admin.firestore.Timestamp.fromMillis(Date.now() - 1000) })
    );

    const result = await listParentAccessInvites.run(request(ADMIN_UID, {}));

    assert.equal(result.pendingCount, 1);
  });

  test("pagination: pageSize is respected and nextCursor advances", async () => {
    for (let i = 0; i < 3; i++) {
      await db.collection("parent_access_code_invites").add(invite({ parentName: `Parent ${i}` }));
    }

    const firstPage = await listParentAccessInvites.run(request(ADMIN_UID, { pageSize: 2 }));
    assert.equal(firstPage.rows.length, 2);
    assert.ok(firstPage.nextCursor);

    const secondPage = await listParentAccessInvites.run(
      request(ADMIN_UID, { pageSize: 2, cursor: firstPage.nextCursor })
    );
    assert.equal(secondPage.rows.length, 1);
    assert.equal(secondPage.nextCursor, null);

    const seenIds = new Set([...firstPage.rows, ...secondPage.rows].map((r) => r.inviteId));
    assert.equal(seenIds.size, 3, "no duplicate or missing rows across pages");
  });
});
