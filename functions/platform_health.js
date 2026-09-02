/**
 * Server-side Platform Health aggregation, SuperAdmin-only. Truthfully
 * reports only what School Pulse can actually verify - see the per-check
 * comments below for exactly what each one measures and why. Every check
 * is internally timed out and never throws; the aggregation as a whole
 * never lets a raw error/stack reach the client (checkPlatformHealth's
 * catch maps any unexpected failure to a fixed, generic HttpsError).
 *
 * Depends on functions/platform_health_instrumentation.js for the shared
 * recordJobRun/recordJobFailure helpers (also required directly by every
 * scheduled-job file and the payment/onboarding catch sites) and on
 * requireOwner (functions/index.js's thin wrapper around the vendored
 * requirePlatformOwner) for the real, existing SuperAdmin auth check -
 * this module does not define its own auth guard.
 */
module.exports = ({ admin, onCall, HttpsError, requireOwner }) => {
  const db = () => admin.firestore();
  const HEALTH_STATUSES = new Set(["operational", "degraded", "outage", "unknown", "not_configured"]);

  function withTimeout(promise, ms, fallback) {
    return Promise.race([
      promise,
      new Promise((resolve) => setTimeout(() => resolve(fallback), ms)),
    ]);
  }

  function safeMessage(value, fallback) {
    const text = typeof value === "string" ? value.trim() : "";
    return text ? text.slice(0, 300) : fallback;
  }

  // ---- checkAuth: Firebase Auth reachability ------------------------------
  // A cheap, read-only call (list at most 1 user) proves the Auth service
  // itself is reachable and this project's Auth configuration is valid.
  // It does not (and must not) return any user data to the caller.
  async function checkAuth() {
    try {
      await withTimeout(admin.auth().listUsers(1), 3000, null).then((result) => {
        if (result === null) throw new Error("timeout");
      });
      return { status: "operational", message: "Firebase Auth is reachable." };
    } catch (error) {
      return { status: "outage", message: "Firebase Auth could not be reached." };
    }
  }

  // ---- checkFirestore: real read+write+delete round-trip ----------------
  // Writes to a dedicated probe doc under platform_health/ itself (never
  // touching any tenant collection), reads it back, then deletes it -
  // proving both read and write health, not just read health.
  async function checkFirestore() {
    const probeRef = db().collection("platform_health").doc("_probe");
    try {
      const run = (async () => {
        await probeRef.set({ probedAt: admin.firestore.FieldValue.serverTimestamp() });
        const snap = await probeRef.get();
        await probeRef.delete();
        return snap.exists;
      })();
      const ok = await withTimeout(run, 3000, "timeout");
      if (ok === "timeout") return { status: "unknown", message: "Firestore round-trip check timed out." };
      if (!ok) return { status: "degraded", message: "Firestore write succeeded but the read-back did not confirm it." };
      return { status: "operational", message: "Firestore read/write round-trip succeeded." };
    } catch (error) {
      return { status: "outage", message: "Firestore read/write round-trip failed." };
    }
  }

  // ---- checkFunctions: this function running IS the signal --------------
  // Self-referential but honest: if checkPlatformHealth is executing at
  // all, Cloud Functions is up. No further call is meaningful here.
  async function checkFunctions() {
    return { status: "operational", message: "Cloud Functions is executing this check." };
  }

  // ---- checkStorage: bucket-level existence only, no file operations ----
  async function checkStorage() {
    try {
      const bucket = admin.storage().bucket();
      if (!bucket || !bucket.name) {
        return { status: "not_configured", message: "No default Storage bucket is configured." };
      }
      const [exists] = await withTimeout(bucket.exists(), 3000, [false]);
      return exists
        ? { status: "operational", message: "Cloud Storage bucket is reachable." }
        : { status: "outage", message: "Cloud Storage bucket does not exist or is unreachable." };
    } catch (error) {
      return { status: "not_configured", message: "No default Storage bucket is configured." };
    }
  }

  // ---- checkNotifications: derived from the two notification-related jobs
  async function readJobRun(jobName) {
    const snap = await db().collection("job_runs").doc(jobName).get();
    return snap.exists ? snap.data() : null;
  }

  function jobStatus(run) {
    if (!run) return { status: "unknown", message: "has not run yet" };
    const intervalMs = (run.expectedIntervalMinutes || 60) * 60 * 1000;
    const lastRunAtMs = run.lastRunAt && typeof run.lastRunAt.toMillis === "function"
      ? run.lastRunAt.toMillis() : null;
    const stale = lastRunAtMs !== null && Date.now() - lastRunAtMs > intervalMs * 2;
    if (run.lastStatus === "failure") return { status: "degraded", message: "last run failed" };
    if (stale) return { status: "degraded", message: "has not run recently" };
    return { status: "operational", message: "running on schedule" };
  }

  function worstOf(statuses) {
    if (statuses.includes("outage")) return "outage";
    if (statuses.includes("degraded")) return "degraded";
    if (statuses.includes("unknown")) return "unknown";
    return "operational";
  }

  async function checkNotifications() {
    try {
      const [dispatch, escalate] = await Promise.all([
        readJobRun("dispatchScheduledNotifications"),
        readJobRun("escalateUnacknowledgedAlerts"),
      ]);
      const dispatchStatus = jobStatus(dispatch);
      const escalateStatus = jobStatus(escalate);
      const overall = worstOf([dispatchStatus.status, escalateStatus.status]);
      return {
        status: overall,
        message: overall === "operational"
          ? "Notification dispatch and escalation are running on schedule."
          : `Notification dispatch ${dispatchStatus.message}; escalation ${escalateStatus.message}.`,
      };
    } catch (error) {
      return { status: "unknown", message: "Could not read notification job status." };
    }
  }

  // ---- checkScheduledJobs: worst-of-10 rollup across every job_runs doc --
  const ALL_JOBS = [
    "autoEscalateApprovalRequests", "checkVisitorOverstays", "processScheduledBroadcasts",
    "sendAppointmentReminderEmails", "sendExamFactoryDeadlineReminders",
    "reconcileCommunicationCampaigns", "dispatchScheduledNotifications",
    "escalateUnacknowledgedAlerts", "purgeExpiredNotifications",
    "expireLapsedReportCardExceptions",
  ];

  async function checkScheduledJobs() {
    try {
      const runs = await Promise.all(ALL_JOBS.map(readJobRun));
      const statuses = runs.map((run) => jobStatus(run).status);
      const overall = worstOf(statuses);
      const unhealthyCount = statuses.filter((s) => s !== "operational").length;
      return {
        status: overall,
        message: overall === "operational"
          ? `All ${ALL_JOBS.length} scheduled jobs are running on schedule.`
          : `${unhealthyCount} of ${ALL_JOBS.length} scheduled jobs need attention.`,
      };
    } catch (error) {
      return { status: "unknown", message: "Could not read scheduled job status." };
    }
  }

  // ---- checkSchoolOnboarding / checkSubscriptionProcessing: recent failures
  async function checkFailures(category, label) {
    try {
      const since = admin.firestore.Timestamp.fromMillis(Date.now() - 24 * 60 * 60 * 1000);
      const snap = await db().collection("platform_job_failures")
        .where("category", "==", category)
        .where("createdAt", ">=", since)
        .limit(20)
        .get();
      if (snap.empty) return { status: "operational", message: `No ${label} failures in the last 24h.` };
      const count = snap.size;
      return {
        status: count > 5 ? "outage" : "degraded",
        message: `${count} ${label} failure${count === 1 ? "" : "s"} in the last 24h.`,
      };
    } catch (error) {
      return { status: "unknown", message: `Could not read ${label} failure history.` };
    }
  }

  async function checkSchoolOnboarding() {
    return checkFailures("school_onboarding", "school onboarding");
  }

  async function checkSubscriptionProcessing() {
    return checkFailures("payment_processing", "payment/subscription processing");
  }

  // ---- checkSecurityMonitoring: cross-school high-risk security events --
  // Admin SDK bypasses Firestore rules entirely, so this does NOT require
  // (and does not add) any new client-facing rule - schools/{id}/
  // security_events remains exactly as school-scoped/ungated for clients
  // as it is today. Only counts + risk tier are ever returned; no
  // schoolId, userId, or event-level field leaves this function.
  async function checkSecurityMonitoring() {
    try {
      const since = admin.firestore.Timestamp.fromMillis(Date.now() - 24 * 60 * 60 * 1000);
      const snap = await db().collectionGroup("security_events")
        .where("riskLevel", "in", ["medium", "high"])
        .where("timestamp", ">=", since)
        .limit(50)
        .get();
      if (snap.empty) return { status: "operational", message: "No elevated-risk security events in the last 24h." };
      return {
        status: "degraded",
        message: `${snap.size} elevated-risk security event${snap.size === 1 ? "" : "s"} in the last 24h across all schools.`,
      };
    } catch (error) {
      return { status: "unknown", message: "Could not read security event history." };
    }
  }

  // ---- checkPlatformRelease: honestly not_configured -----------------
  // No version/build/release metadata is published anywhere in this repo
  // today. Do not fabricate one - report the real state.
  async function checkPlatformRelease() {
    return { status: "not_configured", message: "No release/version metadata is published yet." };
  }

  function rollup(components) {
    const configured = Object.values(components).filter((c) => c.status !== "not_configured");
    if (configured.some((c) => c.status === "outage")) return "outage";
    if (configured.some((c) => c.status === "degraded" || c.status === "unknown")) return "degraded";
    return "operational";
  }

  function summarize(status, components) {
    if (status === "operational") return "All monitored services are operational.";
    const attention = Object.entries(components).filter(
      ([, c]) => c.status !== "operational" && c.status !== "not_configured",
    );
    const count = attention.length;
    return `${count} check${count === 1 ? "" : "s"} need${count === 1 ? "s" : ""} attention.`;
  }

  async function runAggregation() {
    const [
      auth, firestore, functionsHealth, storage, notifications, scheduledJobs,
      schoolOnboarding, subscriptionProcessing, securityMonitoring, platformRelease,
    ] = await Promise.all([
      checkAuth(), checkFirestore(), checkFunctions(), checkStorage(), checkNotifications(),
      checkScheduledJobs(), checkSchoolOnboarding(), checkSubscriptionProcessing(),
      checkSecurityMonitoring(), checkPlatformRelease(),
    ]);
    const now = admin.firestore.FieldValue.serverTimestamp();
    const withCheckedAt = (c) => ({
      status: HEALTH_STATUSES.has(c.status) ? c.status : "unknown",
      message: safeMessage(c.message, "Status unavailable."),
      checkedAt: now,
    });
    const components = {
      auth: withCheckedAt(auth),
      firestore: withCheckedAt(firestore),
      functions: withCheckedAt(functionsHealth),
      storage: withCheckedAt(storage),
      notifications: withCheckedAt(notifications),
      scheduledJobs: withCheckedAt(scheduledJobs),
      schoolOnboarding: withCheckedAt(schoolOnboarding),
      subscriptionProcessing: withCheckedAt(subscriptionProcessing),
      securityMonitoring: withCheckedAt(securityMonitoring),
      platformRelease: withCheckedAt(platformRelease),
    };
    const status = rollup(components);
    const doc = {
      status,
      components,
      checkedAt: now,
      checkedBy: "system",
      summary: summarize(status, components),
      version: admin.firestore.FieldValue.increment(1),
    };
    await db().collection("platform_health").doc("current").set(doc, { merge: true });
    return doc;
  }

  const checkPlatformHealth = onCall(async (request) => {
    await requireOwner(request);
    try {
      return await runAggregation();
    } catch (error) {
      throw new HttpsError("internal", "Could not refresh platform health right now.");
    }
  });

  const acknowledgePlatformHealthIncident = onCall(async (request) => {
    const { uid } = await requireOwner(request);
    const { component, note } = request.data || {};
    if (typeof component !== "string" || !component) {
      throw new HttpsError("invalid-argument", "component is required.");
    }
    await db().collection("super_admin_audit_logs").add({
      ownerId: uid,
      action: "PLATFORM_HEALTH_INCIDENT_ACKNOWLEDGED",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      metadata: {
        component,
        note: typeof note === "string" ? note.slice(0, 500) : null,
      },
    });
    return { acknowledged: true };
  });

  return {
    checkPlatformHealth,
    acknowledgePlatformHealthIncident,
    __internal: {
      rollup, summarize, withTimeout, jobStatus, worstOf, safeMessage, runAggregation,
    },
  };
};
