// Firebase Emulator integration tests for the owner-console callables added
// alongside the Super Admin Console completion:
//   * owner_notifications_admin.js  - mark read / mark all read / delete /
//     clear all, with per-owner (ownerId) isolation
//   * owner_trusted_devices.js      - setOwnerDeviceTrust / revokeOwnerDevice
//   * portal_domains.js             - rejectCustomPortalDomain (recheck's DNS
//     path is not exercised here - it hits real resolveCname)
//
// Same convention as portal_domains_lifecycle.emulator.test.cjs: the exported
// symbols are real onCall CloudFunction objects, invoked via `.run(request)`
// against a plain {auth, data} request. Firestore + Auth emulators required.
//
// Run:
//   firebase emulators:exec --only firestore,auth \
//     --project demo-owner-console-callables-test \
//     "node --test test/owner_console_callables.emulator.test.cjs"
const { after, beforeEach, describe, test } = require('node:test');
const assert = require('node:assert/strict');

const projectId = 'demo-owner-console-callables-test';
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const {
  markOwnerNotificationRead,
  markAllOwnerNotificationsRead,
  deleteOwnerNotification,
  clearOwnerNotifications,
} = require('../owner_notifications_admin');
const {
  setOwnerDeviceTrust,
  revokeOwnerDevice,
} = require('../owner_trusted_devices');
const { rejectCustomPortalDomain } = require('../portal_domains');

const admin = require('firebase-admin');
const db = admin.firestore();

const OWNER_UID = 'ownerUid';
const OTHER_UID = 'notTheOwnerUid';
const SCHOOL_ID = 'schoolA';

function request(uid, data) {
  return { auth: uid ? { uid } : null, data };
}

async function clearFirestore() {
  const collections = await db.listCollections();
  await Promise.all(collections.map((c) => deleteCollectionRecursive(c)));
}
async function deleteCollectionRecursive(ref) {
  const docs = await ref.listDocuments();
  await Promise.all(
    docs.map(async (d) => {
      const subs = await d.listCollections();
      await Promise.all(subs.map((s) => deleteCollectionRecursive(s)));
      await d.delete();
    }),
  );
}

async function seed() {
  await db.doc('platform_config/owner_seed').set({ seeded: true, ownerUid: OWNER_UID });
  await db.doc(`users/${OWNER_UID}`).set({
    role: 'superAdmin', roles: ['superAdmin'], isActive: true, email: 'owner@example.com',
  });
  // A second superAdmin profile that is NOT the seeded owner - requireOwner
  // must reject it outright.
  await db.doc(`users/${OTHER_UID}`).set({
    role: 'superAdmin', roles: ['superAdmin'], isActive: true,
  });

  await db.doc('super_admin_notifications/notifA').set({
    ownerId: OWNER_UID, type: 'manual_payment_submitted', status: 'unread',
    title: 'A', schoolId: SCHOOL_ID,
  });
  await db.doc('super_admin_notifications/notifB').set({
    ownerId: OWNER_UID, type: 'school_application', status: 'unread', title: 'B',
  });
  await db.doc('super_admin_notifications/notifLegacy').set({
    type: 'school_application', status: 'unread', title: 'legacy - no ownerId',
  });
  await db.doc('super_admin_notifications/notifForeign').set({
    ownerId: 'someOtherOwner', type: 'school_application', status: 'unread', title: 'foreign',
  });

  await db.doc(`super_admin_settings/${OWNER_UID}/sessions/deviceX`).set({
    platform: 'iOS', deviceName: 'iPhone', trusted: false,
    lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  await db.doc(`super_admin_settings/${OWNER_UID}/sessions/deviceCurrent`).set({
    platform: 'macOS', deviceName: 'MacBook', trusted: true,
    lastActiveAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  await db.doc('platform_owner_device_tokens/tok1').set({
    token: 'tok1', ownerId: OWNER_UID, deviceId: 'deviceX', enabled: true, platform: 'iOS',
  });

  await db.doc('portal_domain_requests/portal.example.com').set({
    hostname: 'portal.example.com', schoolId: SCHOOL_ID, status: 'pending',
    cnameTarget: 'ghs.googlehosted.com',
  });
  await db.doc('portal_domain_requests/live.example.com').set({
    hostname: 'live.example.com', schoolId: SCHOOL_ID, status: 'active',
    cnameTarget: 'ghs.googlehosted.com',
  });
  await db.doc(`schools/${SCHOOL_ID}`).set({
    id: SCHOOL_ID, name: 'School A', customDomains: ['live.example.com'],
  });
  await db.doc('portal_domains/live.example.com').set({
    schoolId: SCHOOL_ID, hostname: 'live.example.com', status: 'active',
  });
}

async function auditActions() {
  const snap = await db.collection('super_admin_audit_logs').get();
  return snap.docs.map((d) => d.data().action);
}

describe('owner console callables', () => {
  beforeEach(async () => {
    await clearFirestore();
    await seed();
  });
  after(async () => {
    await clearFirestore();
  });

  // ---- owner_notifications_admin -----------------------------------

  test('markOwnerNotificationRead: owner marks their own notification read', async () => {
    await markOwnerNotificationRead.run(request(OWNER_UID, { id: 'notifA' }));
    const snap = await db.doc('super_admin_notifications/notifA').get();
    assert.equal(snap.data().status, 'read');
  });

  test('markOwnerNotificationRead: a non-owner superAdmin is rejected', async () => {
    await assert.rejects(
      () => markOwnerNotificationRead.run(request(OTHER_UID, { id: 'notifA' })),
      (err) => err.code === 'permission-denied',
    );
  });

  test('markOwnerNotificationRead: cannot touch a foreign owner\'s notification', async () => {
    await assert.rejects(
      () => markOwnerNotificationRead.run(request(OWNER_UID, { id: 'notifForeign' })),
      (err) => err.code === 'permission-denied',
    );
    const snap = await db.doc('super_admin_notifications/notifForeign').get();
    assert.equal(snap.data().status, 'unread');
  });

  test('markAllOwnerNotificationsRead: only the owner\'s + legacy docs are marked', async () => {
    const result = await markAllOwnerNotificationsRead.run(request(OWNER_UID, {}));
    assert.equal(result.updated, 3); // notifA, notifB, notifLegacy
    const foreign = await db.doc('super_admin_notifications/notifForeign').get();
    assert.equal(foreign.data().status, 'unread');
  });

  test('deleteOwnerNotification: owner deletes their own; foreign is refused', async () => {
    await deleteOwnerNotification.run(request(OWNER_UID, { id: 'notifB' }));
    assert.equal((await db.doc('super_admin_notifications/notifB').get()).exists, false);

    await assert.rejects(
      () => deleteOwnerNotification.run(request(OWNER_UID, { id: 'notifForeign' })),
      (err) => err.code === 'permission-denied',
    );
    assert.equal((await db.doc('super_admin_notifications/notifForeign').get()).exists, true);
  });

  test('clearOwnerNotifications: clears the owner\'s + legacy docs, leaves the foreign one', async () => {
    const result = await clearOwnerNotifications.run(request(OWNER_UID, {}));
    assert.equal(result.deleted, 3);
    assert.equal((await db.doc('super_admin_notifications/notifForeign').get()).exists, true);
    assert.equal((await db.doc('super_admin_notifications/notifA').get()).exists, false);
  });

  // ---- owner_trusted_devices --------------------------------------

  test('setOwnerDeviceTrust: trusts a device, renames it, and writes an audit log', async () => {
    const result = await setOwnerDeviceTrust.run(
      request(OWNER_UID, { deviceId: 'deviceX', trusted: true, deviceName: 'My iPhone 15' }),
    );
    assert.equal(result.trusted, true);
    const snap = await db.doc(`super_admin_settings/${OWNER_UID}/sessions/deviceX`).get();
    assert.equal(snap.data().trusted, true);
    assert.equal(snap.data().deviceName, 'My iPhone 15');
    assert.ok((await auditActions()).includes('OWNER_DEVICE_TRUSTED'));
  });

  test('setOwnerDeviceTrust: a non-owner is rejected', async () => {
    await assert.rejects(
      () => setOwnerDeviceTrust.run(request(OTHER_UID, { deviceId: 'deviceX', trusted: true })),
      (err) => err.code === 'permission-denied',
    );
  });

  test('setOwnerDeviceTrust: unknown device is not-found', async () => {
    await assert.rejects(
      () => setOwnerDeviceTrust.run(request(OWNER_UID, { deviceId: 'ghost', trusted: true })),
      (err) => err.code === 'not-found',
    );
  });

  test('revokeOwnerDevice: deletes the session, disables its tokens, audits', async () => {
    await revokeOwnerDevice.run(
      request(OWNER_UID, { deviceId: 'deviceX', currentDeviceId: 'deviceCurrent' }),
    );
    assert.equal(
      (await db.doc(`super_admin_settings/${OWNER_UID}/sessions/deviceX`).get()).exists,
      false,
    );
    const tok = await db.doc('platform_owner_device_tokens/tok1').get();
    assert.equal(tok.data().enabled, false);
    assert.ok((await auditActions()).includes('OWNER_DEVICE_REVOKED'));
  });

  test('revokeOwnerDevice: refuses to revoke the current device', async () => {
    await assert.rejects(
      () =>
        revokeOwnerDevice.run(
          request(OWNER_UID, { deviceId: 'deviceCurrent', currentDeviceId: 'deviceCurrent' }),
        ),
      (err) => err.code === 'failed-precondition',
    );
    assert.equal(
      (await db.doc(`super_admin_settings/${OWNER_UID}/sessions/deviceCurrent`).get()).exists,
      true,
    );
  });

  // ---- portal_domains.rejectCustomPortalDomain -------------------

  test('rejectCustomPortalDomain: a pending request is marked rejected + audited', async () => {
    await rejectCustomPortalDomain.run(
      request(OWNER_UID, { hostname: 'portal.example.com', reason: 'Not recognised' }),
    );
    const snap = await db.doc('portal_domain_requests/portal.example.com').get();
    assert.equal(snap.data().status, 'rejected');
    assert.equal(snap.data().rejectionReason, 'Not recognised');
    assert.ok((await auditActions()).includes('REJECT_CUSTOM_PORTAL_DOMAIN'));
  });

  test('rejectCustomPortalDomain: removing an active domain tears down its projection', async () => {
    await rejectCustomPortalDomain.run(
      request(OWNER_UID, { hostname: 'live.example.com', reason: 'Owner revoked' }),
    );
    assert.equal((await db.doc('portal_domains/live.example.com').get()).exists, false);
    const school = await db.doc(`schools/${SCHOOL_ID}`).get();
    assert.deepEqual(school.data().customDomains, []);
  });

  test('rejectCustomPortalDomain: a non-owner is rejected', async () => {
    await assert.rejects(
      () =>
        rejectCustomPortalDomain.run(
          request(OTHER_UID, { hostname: 'portal.example.com', reason: 'x' }),
        ),
      (err) => err.code === 'permission-denied',
    );
  });
});
