/** Subscription change requests and usage-metric refreshes.
 *
 * Confirmed missing during the schoolAdmin audit: the Flutter client's
 * SubscriptionRepository (lib/features/admin/data/repositories/
 * subscription_repository.dart) calls `requestSubscriptionChange` and
 * `requestSubscriptionUsageRefresh` via httpsCallable, but neither callable
 * existed anywhere in functions/ - every call failed at runtime with
 * functions/not-found.
 *
 * Scope is deliberately proportionate: this does NOT integrate real
 * billing/payment activation (no MTN MoMo or other payment-provider
 * plumbing exists anywhere else in this codebase for subscription plan
 * changes either - the fee-collection MoMo flow is a separate, unrelated
 * feature for parent fee payments). A plan/add-on change is recorded as a
 * pending_review request plus an audit_events entry for a human/billing
 * process to action, mirroring institutions/{id}/subscription_history and
 * audit_events being read-only from the client (firestore.rules: `allow
 * write: if false` on both) - this callable is therefore the only path that
 * can populate them.
 */
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// Mirrors institution_health.js's ADMIN_ROLES - schoolAdmin/headTeacher/
// director are the roles trusted to change what a school pays for.
const ADMIN_ROLES = new Set(["schoolAdmin", "headTeacher", "director"]);

async function requireSchoolAdmin(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
  const db = admin.firestore();
  const callerSnap = await db.collection("users").doc(request.auth.uid).get();
  const caller = callerSnap.exists ? callerSnap.data() : null;
  if (!caller || !caller.schoolId || caller.isActive === false) {
    throw new HttpsError("permission-denied", "No active institution membership.");
  }
  const roles = [caller.role, ...(Array.isArray(caller.roles) ? caller.roles : [])];
  if (!roles.some((role) => ADMIN_ROLES.has(role))) {
    throw new HttpsError(
      "permission-denied",
      "Only a school admin, head teacher, or director may change the subscription."
    );
  }
  return { db, uid: request.auth.uid, schoolId: caller.schoolId, callerName: caller.name || "" };
}

async function recordAuditEvent(db, schoolId, actorId, action, metadata) {
  await db
    .collection("institutions")
    .doc(schoolId)
    .collection("audit_events")
    .add({
      actorId,
      action,
      metadata,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}

// The Flutter client (SubscriptionRepository) calls both callables via
// FirebaseFunctions.instanceFor(region: 'europe-west1') - the region must be
// declared explicitly here to match, since these callables would otherwise
// deploy to the project default region and the client calls would 404.
const CALLABLE_OPTS = { region: "europe-west1" };

exports.requestSubscriptionChange = onCall(CALLABLE_OPTS, async (request) => {
  const { db, uid, schoolId, callerName } = await requireSchoolAdmin(request);

  const type = String(request.data?.type || "").trim();
  const planId = request.data?.planId ? String(request.data.planId).trim() : null;
  const addOnId = request.data?.addOnId ? String(request.data.addOnId).trim() : null;
  const note = String(request.data?.note || "").slice(0, 2000);

  if (!type) {
    throw new HttpsError("invalid-argument", "A change type is required.");
  }
  if (!planId && !addOnId) {
    throw new HttpsError("invalid-argument", "Either a planId or addOnId is required.");
  }

  // Validate the requested plan/add-on actually exists in the shared catalog
  // (subscription_plans / subscription_addons) before recording the request -
  // otherwise an admin could queue a request for a nonexistent plan id.
  let planName = null;
  if (planId) {
    const planSnap = await db.collection("subscription_plans").doc(planId).get();
    if (!planSnap.exists) {
      throw new HttpsError("not-found", "The requested subscription plan was not found.");
    }
    planName = planSnap.data()?.name || planId;
  }
  let addOnName = null;
  if (addOnId) {
    const addOnSnap = await db.collection("subscription_addons").doc(addOnId).get();
    if (!addOnSnap.exists) {
      throw new HttpsError("not-found", "The requested add-on was not found.");
    }
    addOnName = addOnSnap.data()?.name || addOnId;
  }

  const historyRef = db
    .collection("institutions")
    .doc(schoolId)
    .collection("subscription_history")
    .doc();

  const record = {
    type,
    planId: planId || null,
    planName,
    addOnId: addOnId || null,
    addOnName,
    note,
    status: "pending_review",
    requestedBy: uid,
    requestedByName: callerName,
    schoolId,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await historyRef.set(record);
  await recordAuditEvent(db, schoolId, uid, "subscription_change_requested", {
    historyId: historyRef.id,
    type,
    planId,
    addOnId,
  });

  return { ok: true, requestId: historyRef.id, status: "pending_review" };
});

// Cheaply-computable usage metrics this callable can honestly refresh today.
// Storage/other richer metrics would require wiring into modules outside
// this task's scope (Storage buckets, per-feature counters) and are left as
// a follow-up rather than faked here.
const REFRESHABLE_METRICS = [
  {
    key: "students",
    unit: "students",
    count: async (db, schoolId) => {
      const snap = await db
        .collection("students")
        .where("schoolId", "==", schoolId)
        .where("status", "==", "active")
        .count()
        .get();
      return snap.data().count;
    },
  },
  {
    key: "staff",
    unit: "staff",
    count: async (db, schoolId) => {
      const snap = await db
        .collection("users")
        .where("schoolId", "==", schoolId)
        .where("isActive", "!=", false)
        .count()
        .get();
      return snap.data().count;
    },
  },
];

exports.requestSubscriptionUsageRefresh = onCall(CALLABLE_OPTS, async (request) => {
  const { db, uid, schoolId } = await requireSchoolAdmin(request);

  const schoolSnap = await db.collection("schools").doc(schoolId).get();
  const school = schoolSnap.exists ? schoolSnap.data() : {};
  const subscription = school?.subscription && typeof school.subscription === "object"
    ? school.subscription
    : {};

  const usageRoot = db
    .collection("institutions")
    .doc(schoolId)
    .collection("usage_metrics");

  const results = {};
  const batch = db.batch();

  for (const metric of REFRESHABLE_METRICS) {
    let currentValue = 0;
    try {
      currentValue = await metric.count(db, schoolId);
    } catch (err) {
      // A single metric's count failing (e.g. a missing composite index)
      // should not block refreshing the others.
      continue;
    }
    const limitKey = metric.key === "students" ? "maxStudents" : `max${metric.key[0].toUpperCase()}${metric.key.slice(1)}`;
    const limitValue = Number(subscription[limitKey] || 0) || null;
    const status = !limitValue
      ? "unlimited"
      : currentValue >= limitValue
      ? "atLimit"
      : currentValue >= limitValue * 0.9
      ? "nearLimit"
      : "normal";

    results[metric.key] = currentValue;
    batch.set(
      usageRoot.doc(metric.key),
      {
        usageMetricKey: metric.key,
        currentValue,
        limitValue,
        unit: metric.unit,
        status,
        refreshedAt: admin.firestore.FieldValue.serverTimestamp(),
        refreshedBy: uid,
      },
      { merge: true }
    );
  }

  await batch.commit();
  await recordAuditEvent(db, schoolId, uid, "subscription_usage_refreshed", results);

  return { ok: true, usage: results };
});
