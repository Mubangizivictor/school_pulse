/**
 * Shared, dependency-light helpers used by every scheduled job and by the
 * payment/onboarding failure catch sites to report their own run status to
 * Platform Health. Deliberately has NO dependency on onCall/HttpsError/
 * requireOwner (unlike platform_health.js) so it can be required by every
 * job-owning file (index.js, appointments.js, exam_factory_reminders.js,
 * communication_campaigns.js, notifications.js, report_card_release.js)
 * without pulling in the callable-function machinery or risking a
 * require-ordering issue with requireOwner (defined later in index.js).
 */
module.exports = ({ admin }) => {
  const db = () => admin.firestore();

  /**
   * Wraps one scheduled job's existing async body, recording its outcome to
   * job_runs/{jobName} after it finishes (success or failure) without
   * altering the body's return value or rethrow behavior - callers must
   * keep seeing the same errors so the scheduler's own retry/error
   * reporting is unaffected.
   */
  async function recordJobRun(jobName, expectedIntervalMinutes, fn) {
    const startedAt = Date.now();
    try {
      const result = await fn();
      await db().collection("job_runs").doc(jobName).set({
        jobName,
        lastRunAt: admin.firestore.FieldValue.serverTimestamp(),
        lastStatus: "success",
        lastError: null,
        lastDurationMs: Date.now() - startedAt,
        expectedIntervalMinutes,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
      return result;
    } catch (error) {
      await db().collection("job_runs").doc(jobName).set({
        jobName,
        lastRunAt: admin.firestore.FieldValue.serverTimestamp(),
        lastStatus: "failure",
        lastError: String(error && error.message ? error.message : error).slice(0, 300),
        lastDurationMs: Date.now() - startedAt,
        expectedIntervalMinutes,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
      throw error;
    }
  }

  /**
   * Records one failure for the platform-health "failed payment/subscription
   * processing" or "failed school onboarding" checks. Deliberately stores no
   * tenant-identifying fields (no schoolId, no email, no name) - only a
   * category, the source function name, an opaque referenceId (a
   * transaction/invitation id, not PII on its own) and an already-produced,
   * truncated error message.
   */
  async function recordJobFailure(category, source, referenceId, message) {
    await db().collection("platform_job_failures").add({
      category,
      source,
      referenceId: referenceId || null,
      message: String(message || "").slice(0, 300),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  return { recordJobRun, recordJobFailure };
};
