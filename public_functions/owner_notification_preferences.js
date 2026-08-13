const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { requirePlatformOwner, OwnerAuthorizationError } = require('./vendor/owner-auth');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const DEFAULT_PREFERENCES = Object.freeze({
  pushEnabled: true,
  emailEnabled: true,
  categories: {
    billing: true,
    schoolApplications: true,
    payments: true,
    platformActivity: true,
  },
  quietHours: {
    enabled: false,
    start: '22:00',
    end: '07:00',
    timezone: 'Africa/Kampala',
  },
  frequency: 'realtime',
});

function text(value, max = 200) {
  return String(value ?? '').trim().slice(0, max);
}

function bool(value, fallback) {
  return typeof value === 'boolean' ? value : fallback;
}

function validClock(value, fallback) {
  const cleaned = text(value, 5);
  return /^([01]\d|2[0-3]):[0-5]\d$/.test(cleaned) ? cleaned : fallback;
}

function sanitizePreferences(raw = {}, existing = DEFAULT_PREFERENCES) {
  const currentCategories = existing.categories || DEFAULT_PREFERENCES.categories;
  const currentQuiet = existing.quietHours || DEFAULT_PREFERENCES.quietHours;
  const categories = raw.categories && typeof raw.categories === 'object' ? raw.categories : {};
  const quietHours = raw.quietHours && typeof raw.quietHours === 'object' ? raw.quietHours : {};
  const requestedFrequency = text(raw.frequency, 30).toLowerCase();

  return {
    pushEnabled: bool(raw.pushEnabled, existing.pushEnabled ?? true),
    emailEnabled: bool(raw.emailEnabled, existing.emailEnabled ?? true),
    categories: {
      billing: bool(categories.billing, currentCategories.billing ?? true),
      schoolApplications: bool(categories.schoolApplications, currentCategories.schoolApplications ?? true),
      payments: bool(categories.payments, currentCategories.payments ?? true),
      platformActivity: bool(categories.platformActivity, currentCategories.platformActivity ?? true),
    },
    quietHours: {
      enabled: bool(quietHours.enabled, currentQuiet.enabled ?? false),
      start: validClock(quietHours.start, currentQuiet.start || '22:00'),
      end: validClock(quietHours.end, currentQuiet.end || '07:00'),
      timezone: 'Africa/Kampala',
    },
    // daily_digest is accepted as a stored preference for forward compatibility,
    // but delivery remains realtime until a scheduler/digest worker is explicitly implemented.
    frequency: ['realtime', 'daily_digest'].includes(requestedFrequency)
      ? requestedFrequency
      : (existing.frequency || 'realtime'),
  };
}

// Thin wrapper over the canonical @school-pulse/owner-auth package - see
// shared/owner-auth/index.js.
async function requireOwner(request) {
  try {
    return await requirePlatformOwner(request, { db });
  } catch (error) {
    if (error instanceof OwnerAuthorizationError) {
      throw new HttpsError(error.code, error.message);
    }
    throw error;
  }
}

function settingsRef(uid) {
  return db.collection('platform_owner_settings').doc(uid);
}

async function readPreferences(uid) {
  const snap = await settingsRef(uid).get();
  const stored = snap.exists ? (snap.data()?.notificationPreferences || {}) : {};
  return sanitizePreferences(stored, DEFAULT_PREFERENCES);
}

exports.getOwnerNotificationPreferences = onCall(
  { region: 'europe-west1' },
  async (request) => {
    const owner = await requireOwner(request);
    const notificationPreferences = await readPreferences(owner.uid);
    return {
      ok: true,
      ownerId: owner.uid,
      notificationPreferences,
      capabilities: {
        realtime: true,
        dailyDigestDeliveryImplemented: false,
      },
    };
  },
);

exports.updateOwnerNotificationPreferences = onCall(
  { region: 'europe-west1' },
  async (request) => {
    const owner = await requireOwner(request);
    const current = await readPreferences(owner.uid);
    const incoming = request.data?.notificationPreferences && typeof request.data.notificationPreferences === 'object'
      ? request.data.notificationPreferences
      : (request.data || {});
    const notificationPreferences = sanitizePreferences(incoming, current);

    await settingsRef(owner.uid).set({
      ownerId: owner.uid,
      notificationPreferences,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: owner.uid,
    }, { merge: true });

    await db.collection('super_admin_audit_logs').add({
      action: 'owner_notification_preferences_updated',
      actorUid: owner.uid,
      actorEmail: text(owner.user?.email, 200).toLowerCase(),
      entityType: 'platform_owner_settings',
      entityId: owner.uid,
      summary: {
        pushEnabled: notificationPreferences.pushEnabled,
        emailEnabled: notificationPreferences.emailEnabled,
        frequency: notificationPreferences.frequency,
        categories: notificationPreferences.categories,
        quietHoursEnabled: notificationPreferences.quietHours.enabled,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { ok: true, notificationPreferences };
  },
);

module.exports.DEFAULT_PREFERENCES = DEFAULT_PREFERENCES;
module.exports.sanitizePreferences = sanitizePreferences;
module.exports.readOwnerNotificationPreferences = readPreferences;
