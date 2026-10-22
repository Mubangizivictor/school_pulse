// Firebase Emulator integration tests for the Super Admin "Notification
// preferences" surface - the owner-only callables OwnerNotificationService /
// OwnerNotificationPreferencesScreen drive (public_functions/
// owner_notification_preferences.js, region europe-west1):
//   getOwnerNotificationPreferences, updateOwnerNotificationPreferences
//
// The 4 feed-admin callables (mark read / mark all / delete / clear, with
// per-owner isolation) are covered by owner_console_callables.emulator.test.cjs.
//
// Firestore + Auth emulators required.
//
// Run:
//   firebase emulators:exec --only firestore,auth \
//     --project demo-owner-notification-preferences-test \
//     "node --test test/owner_notification_preferences.emulator.test.cjs"
const { beforeEach, describe, test } = require('node:test');
const assert = require('node:assert/strict');

const projectId = 'demo-owner-notification-preferences-test';
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || 'localhost:9099';
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const {
  getOwnerNotificationPreferences,
  updateOwnerNotificationPreferences,
} = require('../owner_notification_preferences');

const admin = require('firebase-admin');
const db = admin.firestore();

const OWNER_UID = 'ownerUid';
const OTHER_UID = 'notTheOwnerUid';

function request(uid, data) {
  return { auth: uid ? { uid } : null, data };
}
async function clearFirestore() {
  const cols = await db.listCollections();
  await Promise.all(cols.map((c) => del(c)));
}
async function del(ref) {
  const docs = await ref.listDocuments();
  await Promise.all(docs.map(async (d) => {
    const subs = await d.listCollections();
    await Promise.all(subs.map(del));
    await d.delete();
  }));
}
async function seedOwner() {
  await db.doc('platform_config/owner_seed').set({ seeded: true, ownerUid: OWNER_UID });
  await db.doc(`users/${OWNER_UID}`).set({
    role: 'superAdmin', roles: ['superAdmin'], isActive: true, email: 'Owner@Example.com',
  });
  await db.doc(`users/${OTHER_UID}`).set({ role: 'superAdmin', roles: ['superAdmin'], isActive: true });
}
async function storedPrefs(uid = OWNER_UID) {
  const snap = await db.doc(`platform_owner_settings/${uid}`).get();
  return snap.exists ? snap.data() : null;
}
async function auditActions() {
  const snap = await db.collection('super_admin_audit_logs').get();
  return snap.docs.map((d) => d.data().action).sort();
}

describe('Super Admin - Notification preferences', () => {
  beforeEach(async () => {
    await clearFirestore();
    await seedOwner();
  });

  // --- AUTH GATE ------------------------------------------------------

  test('unauthenticated is rejected', async () => {
    await assert.rejects(getOwnerNotificationPreferences.run(request(null, {})), /sign in|unauthenticated/i);
    await assert.rejects(updateOwnerNotificationPreferences.run(request(null, {})), /sign in|unauthenticated/i);
  });

  test('a non-owner superAdmin is denied', async () => {
    await assert.rejects(getOwnerNotificationPreferences.run(request(OTHER_UID, {})), /access denied|permission-denied/i);
    await assert.rejects(updateOwnerNotificationPreferences.run(request(OTHER_UID, {})), /access denied|permission-denied/i);
  });

  // --- GET (defaults) ----------------------------------------------

  test('get returns the sane defaults when nothing is stored, plus honest capabilities', async () => {
    const res = await getOwnerNotificationPreferences.run(request(OWNER_UID, {}));
    assert.equal(res.ok, true);
    assert.equal(res.ownerId, OWNER_UID);
    const p = res.notificationPreferences;
    assert.equal(p.pushEnabled, true);
    assert.equal(p.emailEnabled, true);
    assert.deepEqual(p.categories, { billing: true, schoolApplications: true, payments: true, platformActivity: true });
    assert.equal(p.quietHours.enabled, false);
    assert.equal(p.quietHours.timezone, 'Africa/Kampala');
    assert.equal(p.frequency, 'realtime');
    assert.deepEqual(res.capabilities, { realtime: true, dailyDigestDeliveryImplemented: false });
    assert.equal(await storedPrefs(), null, 'get is read-only - nothing persisted');
  });

  // --- UPDATE ----------------------------------------------------

  test('update persists sanitized preferences under the owner uid + audits', async () => {
    const res = await updateOwnerNotificationPreferences.run(request(OWNER_UID, {
      notificationPreferences: {
        pushEnabled: false,
        emailEnabled: true,
        categories: { billing: false, payments: true },
        quietHours: { enabled: true, start: '21:30', end: '06:15' },
        frequency: 'daily_digest',
      },
    }));
    assert.equal(res.ok, true);
    const p = res.notificationPreferences;
    assert.equal(p.pushEnabled, false);
    assert.equal(p.categories.billing, false);
    assert.equal(p.categories.payments, true);
    assert.equal(p.categories.schoolApplications, true, 'unspecified category keeps its default');
    assert.equal(p.quietHours.enabled, true);
    assert.equal(p.quietHours.start, '21:30');
    assert.equal(p.frequency, 'daily_digest');

    const stored = await storedPrefs();
    assert.equal(stored.ownerId, OWNER_UID);
    assert.equal(stored.updatedBy, OWNER_UID);
    assert.equal(stored.notificationPreferences.pushEnabled, false);
    assert.equal(stored.notificationPreferences.quietHours.start, '21:30');

    assert.deepEqual(await auditActions(), ['owner_notification_preferences_updated']);
  });

  test('update round-trips through get', async () => {
    await updateOwnerNotificationPreferences.run(request(OWNER_UID, {
      notificationPreferences: { emailEnabled: false, frequency: 'realtime' },
    }));
    const res = await getOwnerNotificationPreferences.run(request(OWNER_UID, {}));
    assert.equal(res.notificationPreferences.emailEnabled, false);
  });

  test('update clamps an invalid quiet-hours clock and an unknown frequency', async () => {
    const res = await updateOwnerNotificationPreferences.run(request(OWNER_UID, {
      notificationPreferences: {
        quietHours: { enabled: true, start: '99:99', end: 'nope' },
        frequency: 'hourly',
      },
    }));
    // invalid clock -> falls back to the default 22:00 / 07:00
    assert.equal(res.notificationPreferences.quietHours.start, '22:00');
    assert.equal(res.notificationPreferences.quietHours.end, '07:00');
    // unknown frequency -> falls back to existing (realtime)
    assert.equal(res.notificationPreferences.frequency, 'realtime');
  });

  test('update forces quietHours.timezone to Africa/Kampala regardless of input', async () => {
    const res = await updateOwnerNotificationPreferences.run(request(OWNER_UID, {
      notificationPreferences: { quietHours: { enabled: true, timezone: 'America/New_York' } },
    }));
    assert.equal(res.notificationPreferences.quietHours.timezone, 'Africa/Kampala');
  });

  test('a partial update merges onto the stored value, not onto defaults', async () => {
    // First: turn everything off.
    await updateOwnerNotificationPreferences.run(request(OWNER_UID, {
      notificationPreferences: {
        pushEnabled: false, emailEnabled: false,
        categories: { billing: false, schoolApplications: false, payments: false, platformActivity: false },
      },
    }));
    // Then: a tiny update that only re-enables billing.
    const res = await updateOwnerNotificationPreferences.run(request(OWNER_UID, {
      notificationPreferences: { categories: { billing: true } },
    }));
    assert.equal(res.notificationPreferences.categories.billing, true);
    assert.equal(res.notificationPreferences.categories.payments, false, 'other categories stay off, not reset to default-on');
    assert.equal(res.notificationPreferences.pushEnabled, false, 'push stays off');
  });

  test('update accepts a bare payload (no notificationPreferences wrapper)', async () => {
    const res = await updateOwnerNotificationPreferences.run(request(OWNER_UID, { pushEnabled: false }));
    assert.equal(res.notificationPreferences.pushEnabled, false);
  });

  test('per-owner isolation: one owner\'s prefs never leak to another settings doc', async () => {
    await updateOwnerNotificationPreferences.run(request(OWNER_UID, {
      notificationPreferences: { pushEnabled: false },
    }));
    // OTHER_UID is a superAdmin but not the seeded owner - it can't even call
    // this, so there is only ever one settings doc, keyed by the real owner.
    const all = await db.collection('platform_owner_settings').listDocuments();
    assert.deepEqual(all.map((d) => d.id), [OWNER_UID]);
  });
});
