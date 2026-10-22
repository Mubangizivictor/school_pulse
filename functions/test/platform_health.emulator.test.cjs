// Firebase Emulator integration test for functions/platform_health.js —
// the SuperAdmin-only health aggregation callable. Run:
// `npm run test:platform-health:emulator`. Requires the Firestore emulator
// (JDK 21). Seeds job_runs/platform_job_failures/security_events docs
// directly (bypassing rules via the Admin SDK, same as production writes),
// then calls runAggregation() directly (exported via __internal) to assert
// the written platform_health/current doc's rollup for real scenarios:
// all-healthy, one stale job, one failed job, payment failures present,
// onboarding failures present, storage not configured.
const { beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-platform-health-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

const admin = require("firebase-admin");
admin.initializeApp();
class HttpsError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
  }
}
const requireOwner = async (request) => {
  const uid = request?.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in first.");
  const snap = await admin.firestore().collection("users").doc(uid).get();
  const user = snap.exists ? snap.data() : null;
  if (!user || !["superAdmin", "super_admin"].includes(user.role)) {
    throw new HttpsError("permission-denied", "Access denied.");
  }
  return { uid, user };
};
const platformHealth = require("../platform_health")({ admin, onCall: (h) => h, HttpsError, requireOwner });

const db = admin.firestore();
const OWNER = "ownerUid";
const ADMIN_USER = "schoolAdminUid";

const req = (uid) => ({ auth: uid ? { uid } : null });

async function clearFirestore() {
  const cols = await db.listCollections();
  await Promise.all(cols.map(del));
}
async function del(colRef) {
  const docs = await colRef.listDocuments();
  await Promise.all(
    docs.map(async (d) => {
      const subs = await d.listCollections();
      await Promise.all(subs.map(del));
      await d.delete();
    }),
  );
}

async function seedOwner() {
  await db.doc(`users/${OWNER}`).set({ role: "superAdmin", roles: ["superAdmin"], isActive: true });
  await db.doc(`users/${ADMIN_USER}`).set({ role: "schoolAdmin", roles: ["schoolAdmin"], schoolId: "schoolA", isActive: true });
}

const ALL_JOBS = [
  "autoEscalateApprovalRequests", "checkVisitorOverstays", "processScheduledBroadcasts",
  "sendAppointmentReminderEmails", "sendExamFactoryDeadlineReminders",
  "reconcileCommunicationCampaigns", "dispatchScheduledNotifications",
  "escalateUnacknowledgedAlerts", "purgeExpiredNotifications",
  "expireLapsedReportCardExceptions",
];

async function seedAllJobsHealthy() {
  await Promise.all(ALL_JOBS.map((jobName) =>
    db.collection("job_runs").doc(jobName).set({
      jobName,
      lastRunAt: admin.firestore.Timestamp.now(),
      lastStatus: "success",
      lastError: null,
      expectedIntervalMinutes: 15,
      updatedAt: admin.firestore.Timestamp.now(),
    })));
}

beforeEach(async () => {
  await clearFirestore();
  await seedOwner();
});

describe("checkPlatformHealth: SuperAdmin auth", () => {
  test("a SuperAdmin caller succeeds", async () => {
    await seedAllJobsHealthy();
    const result = await platformHealth.checkPlatformHealth(req(OWNER));
    assert.ok(result.status);
  });

  test("a School Admin caller is denied with permission-denied", async () => {
    await assert.rejects(
      () => platformHealth.checkPlatformHealth(req(ADMIN_USER)),
      (err) => {
        assert.equal(err.code, "permission-denied");
        return true;
      },
    );
  });

  test("an unauthenticated caller is denied", async () => {
    await assert.rejects(
      () => platformHealth.checkPlatformHealth(req(null)),
      (err) => {
        assert.equal(err.code, "unauthenticated");
        return true;
      },
    );
  });
});

describe("checkPlatformHealth: rollup scenarios against real seeded data", () => {
  test("all-healthy: every job recent+successful, no failures -> operational overall", async () => {
    await seedAllJobsHealthy();
    const result = await platformHealth.checkPlatformHealth(req(OWNER));
    assert.equal(result.status, "operational");
    assert.equal(result.components.scheduledJobs.status, "operational");
    assert.equal(result.components.schoolOnboarding.status, "operational");
    assert.equal(result.components.subscriptionProcessing.status, "operational");
  });

  test("one stale job -> scheduledJobs degraded, overall degraded", async () => {
    await seedAllJobsHealthy();
    await db.collection("job_runs").doc("purgeExpiredNotifications").set({
      jobName: "purgeExpiredNotifications",
      lastRunAt: admin.firestore.Timestamp.fromMillis(Date.now() - 3 * 24 * 60 * 60 * 1000),
      lastStatus: "success",
      lastError: null,
      expectedIntervalMinutes: 1440,
      updatedAt: admin.firestore.Timestamp.now(),
    });
    const result = await platformHealth.checkPlatformHealth(req(OWNER));
    assert.equal(result.components.scheduledJobs.status, "degraded");
    assert.equal(result.status, "degraded");
  });

  test("one failed job -> scheduledJobs degraded", async () => {
    await seedAllJobsHealthy();
    await db.collection("job_runs").doc("checkVisitorOverstays").set({
      jobName: "checkVisitorOverstays",
      lastRunAt: admin.firestore.Timestamp.now(),
      lastStatus: "failure",
      lastError: "boom",
      expectedIntervalMinutes: 15,
      updatedAt: admin.firestore.Timestamp.now(),
    });
    const result = await platformHealth.checkPlatformHealth(req(OWNER));
    assert.equal(result.components.scheduledJobs.status, "degraded");
  });

  test("payment/subscription failures present -> subscriptionProcessing degraded, message never contains raw internals", async () => {
    await seedAllJobsHealthy();
    await db.collection("platform_job_failures").add({
      category: "payment_processing", source: "initiateMobileMoneyCharge",
      referenceId: "txn-1", message: "Provider timeout",
      createdAt: admin.firestore.Timestamp.now(),
    });
    const result = await platformHealth.checkPlatformHealth(req(OWNER));
    assert.equal(result.components.subscriptionProcessing.status, "degraded");
    assert.doesNotMatch(result.components.subscriptionProcessing.message, /txn-1|Provider timeout/);
  });

  test("onboarding failures present -> schoolOnboarding degraded", async () => {
    await seedAllJobsHealthy();
    await db.collection("platform_job_failures").add({
      category: "school_onboarding", source: "provisionSchoolAdmin",
      referenceId: "invite-1", message: "School does not exist.",
      createdAt: admin.firestore.Timestamp.now(),
    });
    const result = await platformHealth.checkPlatformHealth(req(OWNER));
    assert.equal(result.components.schoolOnboarding.status, "degraded");
  });

  test("storage not configured (no default bucket in this emulator project) is honestly reported, never fabricated operational", async () => {
    await seedAllJobsHealthy();
    const result = await platformHealth.checkPlatformHealth(req(OWNER));
    assert.ok(["not_configured", "outage"].includes(result.components.storage.status));
  });

  test("platformRelease is always not_configured (no version metadata source exists)", async () => {
    await seedAllJobsHealthy();
    const result = await platformHealth.checkPlatformHealth(req(OWNER));
    assert.equal(result.components.platformRelease.status, "not_configured");
  });

  test("elevated-risk security_events across schools are counted without leaking per-school identity in the message", async () => {
    await seedAllJobsHealthy();
    await db.doc("schools/schoolA/security_events/eventA").set({
      institutionId: "schoolA", schoolId: "schoolA", riskLevel: "high",
      type: "Login failure", timestamp: admin.firestore.Timestamp.now(),
    });
    const result = await platformHealth.checkPlatformHealth(req(OWNER));
    assert.equal(result.components.securityMonitoring.status, "degraded");
    assert.doesNotMatch(result.components.securityMonitoring.message, /schoolA/);
  });

  test("the aggregate result is cached to platform_health/current for the Home card's fast stream", async () => {
    await seedAllJobsHealthy();
    await platformHealth.checkPlatformHealth(req(OWNER));
    const cached = await db.collection("platform_health").doc("current").get();
    assert.ok(cached.exists);
    assert.ok(cached.data().status);
  });
});

describe("acknowledgePlatformHealthIncident: audits only manual actions, never automatic polls", () => {
  test("acknowledging an incident writes exactly one super_admin_audit_logs entry", async () => {
    await seedAllJobsHealthy();
    await platformHealth.checkPlatformHealth(req(OWNER)); // a poll - must NOT be audited
    const beforeCount = (await db.collection("super_admin_audit_logs").get()).size;
    assert.equal(beforeCount, 0, "an automatic poll must never write an audit log entry");

    await platformHealth.acknowledgePlatformHealthIncident(
      { auth: { uid: OWNER }, data: { component: "scheduledJobs", note: "Investigating." } },
    );
    const logs = await db.collection("super_admin_audit_logs")
      .where("action", "==", "PLATFORM_HEALTH_INCIDENT_ACKNOWLEDGED").get();
    assert.equal(logs.size, 1);
    assert.equal(logs.docs[0].data().metadata.component, "scheduledJobs");
  });

  test("acknowledging requires a component argument", async () => {
    await assert.rejects(
      () => platformHealth.acknowledgePlatformHealthIncident({ auth: { uid: OWNER }, data: {} }),
      (err) => {
        assert.equal(err.code, "invalid-argument");
        return true;
      },
    );
  });

  test("a School Admin cannot acknowledge an incident", async () => {
    await assert.rejects(
      () => platformHealth.acknowledgePlatformHealthIncident(
        { auth: { uid: ADMIN_USER }, data: { component: "scheduledJobs" } },
      ),
      (err) => {
        assert.equal(err.code, "permission-denied");
        return true;
      },
    );
  });
});
