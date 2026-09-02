// Report Card Financial Clearance & Bursar Release — the structured,
// audited exception layer that sits on top of the flat
// `reportCards.financialAccessStatus` gate.
//
// The flat field ('held' | 'released' | 'revoked') stays the single
// Firestore-rule-enforceable gate: a Parent/Student may read a report only
// when it is `released`. This module never weakens that. Instead it:
//
//   * makes "financially cleared" a per-school configurable policy
//     (full balance zero / selected fee categories paid / minimum % paid),
//   * records every Bursar release exception as its own immutable document
//     under `schools/{schoolId}/reportCardReleaseExceptions/{id}` with a
//     balance snapshot, structured reason, optional expiry, optional
//     second-approver step, and an append-only audit trail,
//   * supports grant / approve / revoke / renew, and a scheduled sweep that
//     expires lapsed exceptions,
//   * keeps `reportCards.financialAccessStatus` in sync through
//     transactions so the rule gate and the PDF callable stay correct.
//
// Factory shape matches finance_governance.js / student_fee_billing.js:
// `require("./report_card_release")({ admin, onCall, HttpsError })` returns
// an object of callables (+ one scheduled function) that index.js
// Object.assign()s onto exports. The factory MUST return `api`.
module.exports = ({ admin, onCall, HttpsError, onSchedule }) => {
  const db = admin.firestore();
  const FieldValue = admin.firestore.FieldValue;
  const Timestamp = admin.firestore.Timestamp;
  const { enqueueNotification: sharedEnqueueNotification } = require("./notification_helpers")({ admin });

  const BURSAR_ROLES = ["bursar", "director", "schoolAdmin"];
  const DEFAULT_APPROVER_ROLES = ["headTeacher", "director"];

  const REASON_CODES = new Set([
    "paymentPlan",
    "scholarship",
    "managementInstruction",
    "hardship",
    "staffBenefit",
    "custom",
  ]);

  const txt = (v, n = 1000) => String(v == null ? "" : v).trim().slice(0, n);
  const nowTs = () => Timestamp.now();

  // ---------------------------------------------------------------------------
  // Caller / auth
  // ---------------------------------------------------------------------------

  async function loadCaller(auth) {
    if (!auth) throw new HttpsError("unauthenticated", "You must be signed in.");
    const snap = await db.doc(`users/${auth.uid}`).get();
    const user = snap.exists ? snap.data() : {};
    const roles = Array.isArray(user.roles)
      ? user.roles
      : [user.role].filter(Boolean);
    if (!user.schoolId) {
      throw new HttpsError(
        "failed-precondition",
        "Your account is not assigned to a school.",
      );
    }
    return {
      uid: auth.uid,
      schoolId: user.schoolId,
      roles,
      name: txt(user.name || user.displayName || "Staff member", 120),
    };
  }

  const requireAnyRole = (caller, allowed, message) => {
    if (!allowed.some((r) => caller.roles.includes(r))) {
      throw new HttpsError("permission-denied", message);
    }
  };

  // ---------------------------------------------------------------------------
  // Configurable clearance policy
  // ---------------------------------------------------------------------------

  const DEFAULT_RESTRICTION_MESSAGE =
    "This report card is currently awaiting financial clearance. " +
    "Please contact the school bursar for assistance.";

  /**
   * Reads `schools/{schoolId}/configs/reportReleasePolicy` and returns a
   * fully-defaulted `financialClearance` policy. A school that has never
   * configured anything gets the historical behaviour: every compulsory
   * term bill must have a zero (or credit) balance.
   */
  async function loadClearancePolicy(schoolId) {
    const snap = await db
      .doc(`schools/${schoolId}/configs/reportReleasePolicy`)
      .get();
    const fc = (snap.exists && snap.data().financialClearance) || {};
    const mode = ["fullBalance", "selectedCategories", "minimumPercentage"].includes(
      fc.mode,
    )
      ? fc.mode
      : "fullBalance";
    return {
      mode,
      feeCategoryIds: Array.isArray(fc.feeCategoryIds)
        ? fc.feeCategoryIds.map((v) => txt(v, 160)).filter(Boolean)
        : [],
      minimumPercentagePaid: Number.isFinite(fc.minimumPercentagePaid)
        ? Math.max(0, Math.min(100, Number(fc.minimumPercentagePaid)))
        : 100,
      compulsoryOnly: fc.compulsoryOnly !== false,
      restrictionMessage:
        txt(fc.restrictionMessage, 600) || DEFAULT_RESTRICTION_MESSAGE,
      secondApproverRequired: fc.secondApproverRequired === true,
      secondApproverArrearsThresholdUgx: Number.isFinite(
        fc.secondApproverArrearsThresholdUgx,
      )
        ? Math.max(0, Math.round(Number(fc.secondApproverArrearsThresholdUgx)))
        : 0,
      secondApproverRoles:
        Array.isArray(fc.secondApproverRoles) && fc.secondApproverRoles.length > 0
          ? fc.secondApproverRoles.map((v) => txt(v, 40)).filter(Boolean)
          : DEFAULT_APPROVER_ROLES,
      defaultExpiryDays: Number.isFinite(fc.defaultExpiryDays)
        ? Math.max(0, Math.min(3650, Math.round(Number(fc.defaultExpiryDays))))
        : 0,
    };
  }

  const billIsCompulsory = (data) => {
    const lines = Array.isArray(data.lines) ? data.lines : [];
    if (lines.length === 0) return true; // no line detail → treat as compulsory
    return lines.some((l) => l && l.required !== false);
  };

  const billTouchesCategories = (data, categoryIds) => {
    const set = new Set(categoryIds);
    const lines = Array.isArray(data.lines) ? data.lines : [];
    return lines.some(
      (l) => l && (set.has(l.chargeId) || set.has(l.serviceKey)),
    );
  };

  /**
   * Authoritative server-side "is this learner financially cleared for this
   * report period" check. Reads the learner's issued bills for the exact
   * academicYearId+termId. A period with no bill at all is NOT cleared — a
   * report must never auto-release just because billing was never set up.
   *
   * Returns { cleared, mode, balanceUgx, requiredUgx?, percentPaid?, billCount }.
   */
  async function computeFinancialClearance({
    schoolId,
    studentId,
    academicYearId,
    termId,
    policy,
  }) {
    const pol = policy || (await loadClearancePolicy(schoolId));
    const billsSnap = await db
      .collection(`schools/${schoolId}/student_accounts/${studentId}/bills`)
      .where("academicYearId", "==", academicYearId)
      .where("termId", "==", termId)
      .get();
    const bills = billsSnap.docs.map((d) => d.data());
    const base = { mode: pol.mode, billCount: bills.length };
    if (bills.length === 0) {
      return { ...base, cleared: false, balanceUgx: 0 };
    }

    if (pol.mode === "minimumPercentage") {
      let paid = 0;
      let outstanding = 0;
      for (const b of bills) {
        paid += Number(b.paidTotalUgx || 0);
        outstanding += Math.max(0, Number(b.balanceUgx || 0));
      }
      const denom = paid + outstanding;
      const percentPaid = denom <= 0 ? 100 : (paid / denom) * 100;
      return {
        ...base,
        cleared: percentPaid + 1e-9 >= pol.minimumPercentagePaid,
        balanceUgx: outstanding,
        percentPaid: Math.round(percentPaid * 100) / 100,
      };
    }

    if (pol.mode === "selectedCategories") {
      const relevant = pol.feeCategoryIds.length
        ? bills.filter((b) => billTouchesCategories(b, pol.feeCategoryIds))
        : bills;
      const balanceUgx = relevant.reduce(
        (s, b) => s + Math.max(0, Number(b.balanceUgx || 0)),
        0,
      );
      // No bill carries a selected category → nothing to clear for the
      // configured categories; treat as cleared (the school opted into a
      // narrower gate than "everything").
      return { ...base, cleared: balanceUgx <= 0, balanceUgx };
    }

    // fullBalance (default)
    const relevant = pol.compulsoryOnly
      ? bills.filter((b) => billIsCompulsory(b))
      : bills;
    const balanceUgx = relevant.reduce(
      (s, b) => s + Math.max(0, Number(b.balanceUgx || 0)),
      0,
    );
    return { ...base, cleared: balanceUgx <= 0, balanceUgx };
  }

  // ---------------------------------------------------------------------------
  // Exceptions
  // ---------------------------------------------------------------------------

  const exceptionsCol = (schoolId) =>
    db.collection(`schools/${schoolId}/reportCardReleaseExceptions`);

  const isLive = (exc, now) =>
    exc.status === "active" &&
    (!exc.expiresAt || exc.expiresAt.toMillis() > now.toMillis());

  /**
   * The one live (active, non-expired) exception for a report period, or
   * null. Also returns a pending-approval record if one exists (no access,
   * but the UI shows "Pending approval").
   */
  async function findExceptionForPeriod({
    schoolId,
    studentId,
    academicYearId,
    termId,
    now,
  }) {
    const snap = await exceptionsCol(schoolId)
      .where("studentId", "==", studentId)
      .where("academicYearId", "==", academicYearId)
      .where("termId", "==", termId)
      .where("status", "in", ["active", "pendingApproval"])
      .get();
    let active = null;
    let pending = null;
    for (const d of snap.docs) {
      const data = { id: d.id, ...d.data() };
      if (data.status === "pendingApproval") pending = data;
      else if (isLive(data, now)) active = data;
    }
    return { active, pending };
  }

  /**
   * The single source of truth for a report period's access. Never trusts a
   * client "cleared" flag — always recomputed from bills + exception docs.
   *
   * Returns { uiStatus, accessStatus, clearance, exception }
   *   uiStatus:  automaticallyAvailable | withheldForFees | exceptionActive
   *              | exceptionExpired | pendingApproval
   *   accessStatus: 'released' | 'held'   (what financialAccessStatus becomes)
   */
  async function resolveReportAccess({
    schoolId,
    studentId,
    academicYearId,
    termId,
    policy,
  }) {
    const now = nowTs();
    const clearance = await computeFinancialClearance({
      schoolId,
      studentId,
      academicYearId,
      termId,
      policy,
    });
    if (clearance.cleared) {
      return {
        uiStatus: "automaticallyAvailable",
        accessStatus: "released",
        clearance,
        exception: null,
      };
    }
    const { active, pending } = await findExceptionForPeriod({
      schoolId,
      studentId,
      academicYearId,
      termId,
      now,
    });
    if (active) {
      return {
        uiStatus: "exceptionActive",
        accessStatus: "released",
        clearance,
        exception: active,
      };
    }
    if (pending) {
      return {
        uiStatus: "pendingApproval",
        accessStatus: "held",
        clearance,
        exception: pending,
      };
    }
    // Was there an exception that has since expired/been revoked?
    const priorSnap = await exceptionsCol(schoolId)
      .where("studentId", "==", studentId)
      .where("academicYearId", "==", academicYearId)
      .where("termId", "==", termId)
      .where("status", "in", ["expired", "revoked"])
      .limit(1)
      .get();
    return {
      uiStatus: priorSnap.empty ? "withheldForFees" : "exceptionExpired",
      accessStatus: "held",
      clearance,
      exception: null,
    };
  }

  // ---------------------------------------------------------------------------
  // Audit + notifications (self-contained, mirrors index.js helpers)
  // ---------------------------------------------------------------------------

  async function writeSchoolAudit(schoolId, entry) {
    await db.collection(`schools/${schoolId}/subject_audit_logs`).add({
      schoolId,
      timestamp: FieldValue.serverTimestamp(),
      platform: "cloud_function",
      ...entry,
    });
  }

  const auditLine = (action, caller, extra = {}) => ({
    action,
    actorUid: caller.uid,
    actorName: caller.name,
    at: Timestamp.now(),
    ...extra,
  });

  /**
   * Fan-out notification via the notification_requests → notifications
   * pipeline (functions/notifications.js). Never writes `notifications`
   * directly. idempotencyKey dedupes retries downstream. Delegates to the
   * shared helper (functions/notification_helpers.js) with this module's
   * sender/category defaults.
   */
  async function enqueueNotification({
    schoolId,
    recipientUid,
    recipientRoles,
    type,
    title,
    shortBody,
    idempotencyKey,
    sourceEntityId = null,
    metadata = {},
  }) {
    await sharedEnqueueNotification({
      schoolId,
      recipientUid,
      recipientRoles,
      type,
      title,
      shortBody,
      idempotencyKey,
      sourceEntityId,
      metadata,
      senderRoleSnapshot: "Report Card Engine",
      sourceModule: "reportCards",
    });
  }

  /** Parent/student uid linked to a student, if any (for direct notify). */
  async function linkedUserUidsForStudent(schoolId, studentId) {
    const snap = await db
      .collection("users")
      .where("schoolId", "==", schoolId)
      .where("studentIds", "array-contains", studentId)
      .get();
    const uids = snap.docs.map((d) => d.id);
    // Student's own account
    const selfSnap = await db
      .collection("users")
      .where("schoolId", "==", schoolId)
      .where("studentId", "==", studentId)
      .get();
    for (const d of selfSnap.docs) if (!uids.includes(d.id)) uids.push(d.id);
    return uids;
  }

  async function notifyParentsReportAvailable(schoolId, studentId, reportCardId) {
    const uids = await linkedUserUidsForStudent(schoolId, studentId);
    await Promise.all(
      uids.map((uid) =>
        enqueueNotification({
          schoolId,
          recipientUid: uid,
          // The app's notification deep-link router maps `reportCardPublished`
          // to the parent report-card screen. Using the same type here means a
          // "now available" notification lands the parent straight on the
          // report they can finally see (the router re-checks access itself).
          type: "reportCardPublished",
          title: "Report card now available",
          shortBody:
            "A report card that was awaiting financial clearance is now available to view.",
          idempotencyKey: `rc_released_${reportCardId}_${uid}`,
          sourceEntityId: reportCardId,
          metadata: { reportCardId, action: "released" },
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Report-period → finalized reports, and the sync writer
  // ---------------------------------------------------------------------------

  async function finalizedReportsForPeriod({
    schoolId,
    studentId,
    academicYearId,
    termId,
  }) {
    const snap = await db
      .collection(`schools/${schoolId}/reportCards`)
      .where("studentId", "==", studentId)
      .where("academicYearId", "==", academicYearId)
      .where("termId", "==", termId)
      .where("isFinalized", "==", true)
      .get();
    return snap.docs;
  }

  /**
   * Recomputes and applies financialAccessStatus for every finalized report
   * in a period, from resolveReportAccess. Only touches reports whose
   * financialAccessSource is NOT 'bursar' (a manual flat override always
   * wins until a Bursar changes it via setReportCardFinancialAccess).
   *
   * Notifies linked parents when a report flips held/revoked → released.
   * Returns the list of reportCardIds that became newly released.
   */
  async function syncPeriodReportAccess({
    schoolId,
    studentId,
    academicYearId,
    termId,
    source, // 'exception' | 'auto'
    reason,
    exceptionId = null,
    caller = null,
  }) {
    const resolution = await resolveReportAccess({
      schoolId,
      studentId,
      academicYearId,
      termId,
    });
    const docs = await finalizedReportsForPeriod({
      schoolId,
      studentId,
      academicYearId,
      termId,
    });
    const newlyReleased = [];
    for (const doc of docs) {
      const data = doc.data();
      if (data.financialAccessSource === "bursar") continue;
      const target = resolution.accessStatus; // 'released' | 'held'
      if (data.financialAccessStatus === target && data.activeExceptionId === exceptionId) {
        continue;
      }
      const wasReleased = data.financialAccessStatus === "released";
      // eslint-disable-next-line no-await-in-loop
      await db.runTransaction(async (tx) => {
        const fresh = await tx.get(doc.ref);
        if (!fresh.exists) return;
        const fd = fresh.data();
        if (fd.financialAccessSource === "bursar") return;
        tx.update(doc.ref, {
          financialAccessStatus: target,
          financialAccessSource:
            resolution.uiStatus === "exceptionActive" ? "exception" : "auto",
          activeExceptionId:
            resolution.uiStatus === "exceptionActive"
              ? resolution.exception.id
              : null,
          financialAccessUpdatedAt: FieldValue.serverTimestamp(),
          financialAccessUpdatedBy: caller ? caller.uid : null,
          financialAccessReason:
            reason ||
            (target === "released"
              ? "Report released."
              : "Report held pending financial clearance."),
          financialClearanceComputed: {
            cleared: resolution.clearance.cleared,
            mode: resolution.clearance.mode,
            balanceUgx: resolution.clearance.balanceUgx,
            percentPaid: resolution.clearance.percentPaid ?? null,
            uiStatus: resolution.uiStatus,
            at: FieldValue.serverTimestamp(),
          },
        });
        tx.set(doc.ref.collection("auditLog").doc(), {
          action: `financial_access.${
            target === "released" ? "released" : "held"
          }`,
          actorUid: caller ? caller.uid : null,
          actorDisplayName: caller ? caller.name : "System",
          reason: reason || null,
          source,
          exceptionId,
          reportVersion: fd.version,
          timestamp: FieldValue.serverTimestamp(),
        });
      });
      if (!wasReleased && resolution.accessStatus === "released") {
        newlyReleased.push(doc.id);
        // eslint-disable-next-line no-await-in-loop
        await notifyParentsReportAvailable(schoolId, studentId, doc.id).catch(
          (e) => console.error("notifyParentsReportAvailable failed", e),
        );
      }
    }
    return newlyReleased;
  }

  // ---------------------------------------------------------------------------
  // Callables
  // ---------------------------------------------------------------------------

  const api = {};

  // report_card_financial_gate.js requires this module with only { admin }
  // to reuse the policy/sync engine (see the require-cycle note at the top).
  // In that path there is no onCall/onSchedule, so the HTTPS callables and
  // the scheduled sweep below are simply not registered.
  if (onCall) {

  /**
   * Bursar grants a learner-specific report-card release exception for one
   * report period. Snapshots the outstanding balance at grant time
   * (immutable). If the school requires a second approver and the arrears
   * meet the configured threshold, the exception is created
   * `pendingApproval` and grants NO access until approved. Idempotent on
   * clientRequestId. Rejects a duplicate active/pending exception for the
   * same (student, year, term).
   */
  api.grantReportCardReleaseException = onCall(async (request) => {
    const caller = await loadCaller(request.auth);
    requireAnyRole(
      caller,
      BURSAR_ROLES,
      "Only the Bursar may grant a report-card release exception.",
    );
    const d = request.data || {};
    const studentId = txt(d.studentId, 160);
    const academicYearId = txt(d.academicYearId, 80);
    const termId = txt(d.termId, 80);
    const reasonCode = txt(d.reasonCode, 40);
    const reasonNote = txt(d.reasonNote, 1000);
    const clientRequestId = txt(d.clientRequestId, 180);
    if (!studentId || !academicYearId || !termId) {
      throw new HttpsError(
        "invalid-argument",
        "studentId, academicYearId and termId are required.",
      );
    }
    if (!REASON_CODES.has(reasonCode)) {
      throw new HttpsError(
        "invalid-argument",
        "reasonCode must be one of paymentPlan, scholarship, managementInstruction, hardship, staffBenefit, custom.",
      );
    }
    if (reasonCode === "custom" && !reasonNote) {
      throw new HttpsError(
        "invalid-argument",
        "A custom reason requires a note describing it.",
      );
    }
    let expiresAt = null;
    if (d.expiresAt != null && d.expiresAt !== "") {
      const ms = typeof d.expiresAt === "number" ? d.expiresAt : Date.parse(d.expiresAt);
      if (!Number.isFinite(ms)) {
        throw new HttpsError("invalid-argument", "expiresAt is not a valid date.");
      }
      if (ms <= Date.now()) {
        throw new HttpsError(
          "invalid-argument",
          "expiresAt must be in the future.",
        );
      }
      expiresAt = Timestamp.fromMillis(ms);
    }

    // Verify the student belongs to this school (tenant isolation).
    const studentSnap = await db
      .doc(`schools/${caller.schoolId}/students/${studentId}`)
      .get();
    if (!studentSnap.exists) {
      throw new HttpsError(
        "not-found",
        "That learner was not found in your school.",
      );
    }
    const studentName = txt(
      studentSnap.data().fullName ||
        studentSnap.data().name ||
        [studentSnap.data().firstName, studentSnap.data().lastName]
          .filter(Boolean)
          .join(" ") ||
        "Learner",
      160,
    );

    const policy = await loadClearancePolicy(caller.schoolId);
    const clearance = await computeFinancialClearance({
      schoolId: caller.schoolId,
      studentId,
      academicYearId,
      termId,
      policy,
    });

    const needsApproval =
      policy.secondApproverRequired &&
      clearance.balanceUgx >= policy.secondApproverArrearsThresholdUgx &&
      !caller.roles.some((r) => policy.secondApproverRoles.includes(r));

    const col = exceptionsCol(caller.schoolId);
    const docId = clientRequestId
      ? `exc_${clientRequestId.replace(/[^A-Za-z0-9_-]/g, "").slice(0, 120)}`
      : col.doc().id;
    const ref = col.doc(docId);

    const result = await db.runTransaction(async (tx) => {
      const existing = await tx.get(ref);
      if (existing.exists) {
        // Idempotent replay of the same submit.
        const e = existing.data();
        return { exceptionId: docId, status: e.status, idempotent: true };
      }
      // Reject a duplicate live/pending exception for the same period.
      const dupSnap = await tx.get(
        col
          .where("studentId", "==", studentId)
          .where("academicYearId", "==", academicYearId)
          .where("termId", "==", termId)
          .where("status", "in", ["active", "pendingApproval"]),
      );
      if (!dupSnap.empty) {
        throw new HttpsError(
          "already-exists",
          "An active or pending release exception already exists for this learner and report period.",
        );
      }
      const status = needsApproval ? "pendingApproval" : "active";
      tx.set(ref, {
        schoolId: caller.schoolId,
        studentId,
        studentName,
        academicYearId,
        termId,
        reasonCode,
        reasonNote: reasonNote || null,
        outstandingBalanceUgxAtRelease: clearance.balanceUgx,
        clearancePolicyModeAtRelease: clearance.mode,
        status,
        createdByUid: caller.uid,
        createdByName: caller.name,
        createdAt: FieldValue.serverTimestamp(),
        authorisedByUid: null,
        authorisedByName: null,
        authorisedAt: null,
        expiresAt,
        consumedAt: null,
        renewedFromExceptionId: txt(d.renewedFromExceptionId, 180) || null,
        supersededByExceptionId: null,
        clientRequestId: clientRequestId || null,
        auditTrail: [
          auditLine("grant", caller, {
            note: reasonNote || null,
            toStatus: status,
            balanceUgxSnapshot: clearance.balanceUgx,
          }),
        ],
      });
      return { exceptionId: docId, status, idempotent: false };
    });

    if (!result.idempotent) {
      await writeSchoolAudit(caller.schoolId, {
        userId: caller.uid,
        action: "report_card_exception.grant",
        entityType: "reportCardReleaseExceptions",
        entityId: result.exceptionId,
        newValue: {
          studentId,
          academicYearId,
          termId,
          reasonCode,
          status: result.status,
          balanceUgx: clearance.balanceUgx,
        },
      });
      if (result.status === "active") {
        await syncPeriodReportAccess({
          schoolId: caller.schoolId,
          studentId,
          academicYearId,
          termId,
          source: "exception",
          reason: `Release exception (${reasonCode}).`,
          exceptionId: result.exceptionId,
          caller,
        });
      } else {
        await enqueueNotification({
          schoolId: caller.schoolId,
          recipientRoles: policy.secondApproverRoles,
          type: "report_card.exception_pending_approval",
          title: "Report-card release exception needs approval",
          shortBody: `${studentName}: a release exception for an outstanding balance is awaiting your approval.`,
          idempotencyKey: `rc_exc_pending_${result.exceptionId}`,
          metadata: { exceptionId: result.exceptionId },
        });
      }
    }

    return {
      exceptionId: result.exceptionId,
      status: result.status,
      requiresApproval: needsApproval,
      outstandingBalanceUgxAtRelease: clearance.balanceUgx,
    };
  });

  /**
   * Second approver (Headteacher/Director by default) approves a pending
   * exception. The creator may not approve their own. On approval the
   * covered reports are released.
   */
  api.approveReportCardReleaseException = onCall(async (request) => {
    const caller = await loadCaller(request.auth);
    const d = request.data || {};
    const exceptionId = txt(d.exceptionId, 180);
    const note = txt(d.note, 1000);
    if (!exceptionId) {
      throw new HttpsError("invalid-argument", "exceptionId is required.");
    }
    const policy = await loadClearancePolicy(caller.schoolId);
    requireAnyRole(
      caller,
      policy.secondApproverRoles,
      "You are not authorised to approve report-card release exceptions.",
    );
    const ref = exceptionsCol(caller.schoolId).doc(exceptionId);

    const outcome = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists) throw new HttpsError("not-found", "Exception not found.");
      const e = snap.data();
      if (e.schoolId !== caller.schoolId) {
        throw new HttpsError("permission-denied", "Wrong school.");
      }
      if (e.status !== "pendingApproval") {
        if (e.status === "active" && e.authorisedByUid === caller.uid) {
          return { idempotent: true, exception: e };
        }
        throw new HttpsError(
          "failed-precondition",
          `Exception is ${e.status}, not pending approval.`,
        );
      }
      if (e.createdByUid === caller.uid) {
        throw new HttpsError(
          "failed-precondition",
          "You cannot approve an exception you created.",
        );
      }
      tx.update(ref, {
        status: "active",
        authorisedByUid: caller.uid,
        authorisedByName: caller.name,
        authorisedAt: FieldValue.serverTimestamp(),
        auditTrail: FieldValue.arrayUnion(
          auditLine("approve", caller, {
            note: note || null,
            fromStatus: "pendingApproval",
            toStatus: "active",
          }),
        ),
      });
      return { idempotent: false, exception: e };
    });

    if (!outcome.idempotent) {
      const e = outcome.exception;
      await writeSchoolAudit(caller.schoolId, {
        userId: caller.uid,
        action: "report_card_exception.approve",
        entityType: "reportCardReleaseExceptions",
        entityId: exceptionId,
        newValue: { fromStatus: "pendingApproval", toStatus: "active" },
      });
      await syncPeriodReportAccess({
        schoolId: caller.schoolId,
        studentId: e.studentId,
        academicYearId: e.academicYearId,
        termId: e.termId,
        source: "exception",
        reason: `Release exception approved (${e.reasonCode}).`,
        exceptionId,
        caller,
      });
    }
    return { exceptionId, status: "active" };
  });

  /**
   * Revoke a non-terminal exception. Always permitted (revoke is not an
   * "edit"), including after it has been consumed. Re-gates covered reports
   * from the policy.
   */
  api.revokeReportCardReleaseException = onCall(async (request) => {
    const caller = await loadCaller(request.auth);
    const d = request.data || {};
    const exceptionId = txt(d.exceptionId, 180);
    const reason = txt(d.reason, 1000);
    if (!exceptionId || !reason) {
      throw new HttpsError(
        "invalid-argument",
        "exceptionId and a reason are required.",
      );
    }
    const policy = await loadClearancePolicy(caller.schoolId);
    requireAnyRole(
      caller,
      [...BURSAR_ROLES, ...policy.secondApproverRoles],
      "You are not authorised to revoke report-card release exceptions.",
    );
    const ref = exceptionsCol(caller.schoolId).doc(exceptionId);

    const outcome = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists) throw new HttpsError("not-found", "Exception not found.");
      const e = snap.data();
      if (e.schoolId !== caller.schoolId) {
        throw new HttpsError("permission-denied", "Wrong school.");
      }
      if (e.status === "revoked") return { idempotent: true, exception: e };
      if (e.status === "expired") {
        throw new HttpsError(
          "failed-precondition",
          "An expired exception cannot be revoked.",
        );
      }
      tx.update(ref, {
        status: "revoked",
        revokedByUid: caller.uid,
        revokedByName: caller.name,
        revokedAt: FieldValue.serverTimestamp(),
        auditTrail: FieldValue.arrayUnion(
          auditLine("revoke", caller, {
            note: reason,
            fromStatus: e.status,
            toStatus: "revoked",
          }),
        ),
      });
      return { idempotent: false, exception: e };
    });

    if (!outcome.idempotent) {
      const e = outcome.exception;
      await writeSchoolAudit(caller.schoolId, {
        userId: caller.uid,
        action: "report_card_exception.revoke",
        entityType: "reportCardReleaseExceptions",
        entityId: exceptionId,
        newValue: { fromStatus: e.status, toStatus: "revoked", reason },
      });
      await syncPeriodReportAccess({
        schoolId: caller.schoolId,
        studentId: e.studentId,
        academicYearId: e.academicYearId,
        termId: e.termId,
        source: "auto",
        reason: "Release exception revoked.",
        exceptionId: null,
        caller,
      });
    }
    return { exceptionId, status: "revoked" };
  });

  /**
   * Renew an expired (or still-active) exception: creates a NEW exception
   * record linked via renewedFromExceptionId, points the old record's
   * supersededByExceptionId at it, and re-runs the second-approver check on
   * a fresh balance snapshot. The old record is never otherwise mutated.
   */
  api.renewReportCardReleaseException = onCall(async (request) => {
    const caller = await loadCaller(request.auth);
    requireAnyRole(
      caller,
      BURSAR_ROLES,
      "Only the Bursar may renew a report-card release exception.",
    );
    const d = request.data || {};
    const sourceId = txt(d.exceptionId, 180);
    const reasonNote = txt(d.reasonNote, 1000);
    const clientRequestId = txt(d.clientRequestId, 180);
    if (!sourceId) {
      throw new HttpsError("invalid-argument", "exceptionId is required.");
    }
    let newExpiresAt = null;
    if (d.newExpiresAt != null && d.newExpiresAt !== "") {
      const ms =
        typeof d.newExpiresAt === "number"
          ? d.newExpiresAt
          : Date.parse(d.newExpiresAt);
      if (!Number.isFinite(ms) || ms <= Date.now()) {
        throw new HttpsError(
          "invalid-argument",
          "newExpiresAt must be a valid future date.",
        );
      }
      newExpiresAt = Timestamp.fromMillis(ms);
    }

    const srcRef = exceptionsCol(caller.schoolId).doc(sourceId);
    const srcSnap = await srcRef.get();
    if (!srcSnap.exists) {
      throw new HttpsError("not-found", "Source exception not found.");
    }
    const src = srcSnap.data();
    if (src.schoolId !== caller.schoolId) {
      throw new HttpsError("permission-denied", "Wrong school.");
    }
    if (!["expired", "active"].includes(src.status)) {
      throw new HttpsError(
        "failed-precondition",
        `Only an expired or active exception can be renewed (this one is ${src.status}).`,
      );
    }
    if (src.supersededByExceptionId) {
      return {
        exceptionId: src.supersededByExceptionId,
        status: "active",
        idempotent: true,
      };
    }

    const policy = await loadClearancePolicy(caller.schoolId);
    const clearance = await computeFinancialClearance({
      schoolId: caller.schoolId,
      studentId: src.studentId,
      academicYearId: src.academicYearId,
      termId: src.termId,
      policy,
    });
    const needsApproval =
      policy.secondApproverRequired &&
      clearance.balanceUgx >= policy.secondApproverArrearsThresholdUgx &&
      !caller.roles.some((r) => policy.secondApproverRoles.includes(r));

    const col = exceptionsCol(caller.schoolId);
    const newId = clientRequestId
      ? `exc_${clientRequestId.replace(/[^A-Za-z0-9_-]/g, "").slice(0, 120)}`
      : col.doc().id;
    const newRef = col.doc(newId);

    const result = await db.runTransaction(async (tx) => {
      const [freshSrc, freshNew] = await Promise.all([
        tx.get(srcRef),
        tx.get(newRef),
      ]);
      if (freshNew.exists) {
        return { exceptionId: newId, status: freshNew.data().status, idempotent: true };
      }
      if (freshSrc.data().supersededByExceptionId) {
        return {
          exceptionId: freshSrc.data().supersededByExceptionId,
          status: "active",
          idempotent: true,
        };
      }
      const status = needsApproval ? "pendingApproval" : "active";
      tx.set(newRef, {
        schoolId: caller.schoolId,
        studentId: src.studentId,
        studentName: src.studentName,
        academicYearId: src.academicYearId,
        termId: src.termId,
        reasonCode: src.reasonCode,
        reasonNote: reasonNote || src.reasonNote || null,
        outstandingBalanceUgxAtRelease: clearance.balanceUgx,
        clearancePolicyModeAtRelease: clearance.mode,
        status,
        createdByUid: caller.uid,
        createdByName: caller.name,
        createdAt: FieldValue.serverTimestamp(),
        authorisedByUid: null,
        authorisedByName: null,
        authorisedAt: null,
        expiresAt: newExpiresAt,
        consumedAt: null,
        renewedFromExceptionId: sourceId,
        supersededByExceptionId: null,
        clientRequestId: clientRequestId || null,
        auditTrail: [
          auditLine("renew", caller, {
            note: reasonNote || null,
            toStatus: status,
            renewedFromExceptionId: sourceId,
            balanceUgxSnapshot: clearance.balanceUgx,
          }),
        ],
      });
      tx.update(srcRef, {
        supersededByExceptionId: newId,
        auditTrail: FieldValue.arrayUnion(
          auditLine("superseded", caller, {
            note: "Renewed",
            supersededByExceptionId: newId,
          }),
        ),
      });
      return { exceptionId: newId, status, idempotent: false };
    });

    if (!result.idempotent) {
      await writeSchoolAudit(caller.schoolId, {
        userId: caller.uid,
        action: "report_card_exception.renew",
        entityType: "reportCardReleaseExceptions",
        entityId: result.exceptionId,
        newValue: {
          renewedFrom: sourceId,
          status: result.status,
          balanceUgx: clearance.balanceUgx,
        },
      });
      if (result.status === "active") {
        await syncPeriodReportAccess({
          schoolId: caller.schoolId,
          studentId: src.studentId,
          academicYearId: src.academicYearId,
          termId: src.termId,
          source: "exception",
          reason: `Release exception renewed (${src.reasonCode}).`,
          exceptionId: result.exceptionId,
          caller,
        });
      } else {
        await enqueueNotification({
          schoolId: caller.schoolId,
          recipientRoles: policy.secondApproverRoles,
          type: "report_card.exception_pending_approval",
          title: "Renewed report-card release exception needs approval",
          shortBody: `${src.studentName}: a renewed release exception is awaiting your approval.`,
          idempotencyKey: `rc_exc_pending_${result.exceptionId}`,
          metadata: { exceptionId: result.exceptionId },
        });
      }
    }
    return {
      exceptionId: result.exceptionId,
      status: result.status,
      requiresApproval: needsApproval,
    };
  });

  /**
   * Read-only helper for the Bursar console. Given a report period (and an
   * optional class filter) returns one row per finalized report with its
   * balance, policy result, UI status and any exception. No writes.
   */
  api.getReportCardReleaseEligibility = onCall(async (request) => {
    const caller = await loadCaller(request.auth);
    requireAnyRole(
      caller,
      [...BURSAR_ROLES, "headTeacher"],
      "Only finance staff may view report-card release eligibility.",
    );
    const d = request.data || {};
    const academicYearId = txt(d.academicYearId, 80);
    const termId = txt(d.termId, 80);
    const classId = txt(d.classId, 120);
    if (!academicYearId || !termId) {
      throw new HttpsError(
        "invalid-argument",
        "academicYearId and termId are required.",
      );
    }
    let q = db
      .collection(`schools/${caller.schoolId}/reportCards`)
      .where("academicYearId", "==", academicYearId)
      .where("termId", "==", termId)
      .where("isFinalized", "==", true);
    if (classId) q = q.where("classId", "==", classId);
    const snap = await q.get();
    const policy = await loadClearancePolicy(caller.schoolId);

    const rows = [];
    for (const doc of snap.docs) {
      const data = doc.data();
      // eslint-disable-next-line no-await-in-loop
      const resolution = await resolveReportAccess({
        schoolId: caller.schoolId,
        studentId: data.studentId,
        academicYearId,
        termId,
        policy,
      });
      // A manual flat Bursar override wins over the computed status.
      let uiStatus = resolution.uiStatus;
      if (data.financialAccessSource === "bursar") {
        uiStatus =
          data.financialAccessStatus === "released"
            ? "exceptionActive"
            : data.financialAccessStatus === "revoked"
              ? "exceptionExpired"
              : "withheldForFees";
      }
      rows.push({
        reportCardId: doc.id,
        studentId: data.studentId,
        studentName: data.studentName,
        classId: data.classId,
        streamId: data.streamId || null,
        academicYearId,
        termId,
        version: data.version || 1,
        financialAccessStatus: data.financialAccessStatus,
        financialAccessSource: data.financialAccessSource || "auto",
        uiStatus,
        balanceUgx: resolution.clearance.balanceUgx,
        clearance: resolution.clearance,
        restrictionMessage: policy.restrictionMessage,
        exception: resolution.exception
          ? serialiseException(resolution.exception)
          : null,
      });
    }
    return { policy: serialisePolicy(policy), rows };
  });

  /** Redacts an exception record for staff UI (no raw uids, ms timestamps). */
  function serialiseException(e) {
    return {
      id: e.id,
      status: e.status,
      reasonCode: e.reasonCode,
      reasonNote: e.reasonNote || null,
      outstandingBalanceUgxAtRelease: e.outstandingBalanceUgxAtRelease,
      clearancePolicyModeAtRelease: e.clearancePolicyModeAtRelease || null,
      expiresAt: e.expiresAt ? e.expiresAt.toMillis() : null,
      createdByName: e.createdByName || null,
      createdAt: e.createdAt ? e.createdAt.toMillis() : null,
      authorisedByName: e.authorisedByName || null,
      authorisedAt: e.authorisedAt ? e.authorisedAt.toMillis() : null,
      consumedAt: e.consumedAt ? e.consumedAt.toMillis() : null,
      renewedFromExceptionId: e.renewedFromExceptionId || null,
      supersededByExceptionId: e.supersededByExceptionId || null,
      auditTrail: Array.isArray(e.auditTrail)
        ? e.auditTrail.map((a) => ({
            action: a.action,
            actorName: a.actorName || "Staff",
            note: a.note || null,
            fromStatus: a.fromStatus || null,
            toStatus: a.toStatus || null,
            at: a.at && a.at.toMillis ? a.at.toMillis() : null,
          }))
        : [],
    };
  }

  function serialisePolicy(pol) {
    return { ...pol };
  }

  /**
   * Staff read of the configured financial-clearance policy, for the
   * settings editor. Returns the fully-defaulted policy plus the raw stored
   * doc's `effectiveFrom` / `updatedByName` / `updatedAt` so the editor can
   * show "in effect since ...".
   */
  api.getReportCardClearancePolicy = onCall(async (request) => {
    const caller = await loadCaller(request.auth);
    requireAnyRole(
      caller,
      [...BURSAR_ROLES, "headTeacher"],
      "You are not authorised to view the report-release policy.",
    );
    const snap = await db
      .doc(`schools/${caller.schoolId}/configs/reportReleasePolicy`)
      .get();
    const raw = snap.exists ? snap.data() : {};
    const policy = await loadClearancePolicy(caller.schoolId);
    return {
      policy: serialisePolicy(policy),
      meta: {
        effectiveFrom:
          raw.financialClearanceEffectiveFrom &&
          raw.financialClearanceEffectiveFrom.toMillis
            ? raw.financialClearanceEffectiveFrom.toMillis()
            : null,
        updatedByName: raw.financialClearanceUpdatedByName || null,
        updatedAt:
          raw.financialClearanceUpdatedAt &&
          raw.financialClearanceUpdatedAt.toMillis
            ? raw.financialClearanceUpdatedAt.toMillis()
            : null,
        configured: !!raw.financialClearance,
      },
    };
  });

  /**
   * Saves the school's financial-clearance policy (the `financialClearance`
   * map on `configs/reportReleasePolicy`). Role-gated to bursar / schoolAdmin
   * / headTeacher / director - the same set the Firestore rule allows, but
   * this callable is the ONLY supported write path so the change is audited
   * and every already-finalized report is re-materialised against the new
   * policy in the same operation (a Firestore-rule write would leave stale
   * `financialAccessStatus` values behind).
   *
   * Historical exception snapshots (`outstandingBalanceUgxAtRelease`,
   * `clearancePolicyModeAtRelease`) are NEVER touched - they record the
   * balance/policy at grant time and must stay immutable.
   */
  api.saveReportCardClearancePolicy = onCall(async (request) => {
    const caller = await loadCaller(request.auth);
    requireAnyRole(
      caller,
      [...BURSAR_ROLES, "headTeacher"],
      "You are not authorised to change the report-release policy.",
    );
    const d = (request.data && request.data.financialClearance) || request.data || {};

    const mode = ["fullBalance", "selectedCategories", "minimumPercentage"].includes(
      d.mode,
    )
      ? d.mode
      : "fullBalance";
    const next = {
      mode,
      feeCategoryIds: Array.isArray(d.feeCategoryIds)
        ? d.feeCategoryIds.map((v) => txt(v, 160)).filter(Boolean).slice(0, 100)
        : [],
      minimumPercentagePaid: Number.isFinite(d.minimumPercentagePaid)
        ? Math.max(0, Math.min(100, Math.round(Number(d.minimumPercentagePaid))))
        : 100,
      compulsoryOnly: d.compulsoryOnly !== false,
      restrictionMessage:
        txt(d.restrictionMessage, 600) || DEFAULT_RESTRICTION_MESSAGE,
      secondApproverRequired: d.secondApproverRequired === true,
      secondApproverArrearsThresholdUgx: Number.isFinite(
        d.secondApproverArrearsThresholdUgx,
      )
        ? Math.max(0, Math.round(Number(d.secondApproverArrearsThresholdUgx)))
        : 0,
      secondApproverRoles:
        Array.isArray(d.secondApproverRoles) && d.secondApproverRoles.length > 0
          ? d.secondApproverRoles
              .map((v) => txt(v, 40))
              .filter(Boolean)
              .slice(0, 8)
          : DEFAULT_APPROVER_ROLES,
      defaultExpiryDays: Number.isFinite(d.defaultExpiryDays)
        ? Math.max(0, Math.min(3650, Math.round(Number(d.defaultExpiryDays))))
        : 0,
    };
    if (mode === "minimumPercentage" && next.minimumPercentagePaid <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "minimumPercentagePaid must be greater than 0 for the minimum-percentage policy.",
      );
    }
    if (mode === "selectedCategories" && next.feeCategoryIds.length === 0) {
      throw new HttpsError(
        "invalid-argument",
        "Select at least one fee category for the selected-categories policy.",
      );
    }

    const ref = db.doc(`schools/${caller.schoolId}/configs/reportReleasePolicy`);
    const prevSnap = await ref.get();
    const prev = (prevSnap.exists && prevSnap.data().financialClearance) || null;

    await ref.set(
      {
        financialClearance: next,
        financialClearanceEffectiveFrom: FieldValue.serverTimestamp(),
        financialClearanceUpdatedBy: caller.uid,
        financialClearanceUpdatedByName: caller.name,
        financialClearanceUpdatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    await writeSchoolAudit(caller.schoolId, {
      userId: caller.uid,
      action: "report_card_policy.updated",
      entityType: "configs/reportReleasePolicy",
      entityId: "financialClearance",
      oldValue: prev,
      newValue: next,
    });

    // Re-materialise every finalized report against the new policy so the
    // parent read rule (financialAccessStatus == 'released') stays correct.
    // A manual flat Bursar override is still respected inside
    // syncPeriodReportAccess.
    let reMaterialised = 0;
    const seen = new Set();
    const finalizedSnap = await db
      .collection(`schools/${caller.schoolId}/reportCards`)
      .where("isFinalized", "==", true)
      .get();
    for (const doc of finalizedSnap.docs) {
      const data = doc.data();
      const key = `${data.studentId}__${data.academicYearId}__${data.termId}`;
      if (seen.has(key)) continue;
      seen.add(key);
      // eslint-disable-next-line no-await-in-loop
      await syncPeriodReportAccess({
        schoolId: caller.schoolId,
        studentId: data.studentId,
        academicYearId: data.academicYearId,
        termId: data.termId,
        source: "auto",
        reason: "Financial-clearance policy updated.",
        exceptionId: null,
        caller,
      }).catch((err) =>
        console.error("policy re-materialise failed", key, err),
      );
      reMaterialised += 1;
    }

    return {
      policy: serialisePolicy(next),
      reMaterialisedPeriods: reMaterialised,
    };
  });

  /**
   * Full history for the "View audit history" action: the report card's own
   * immutable `auditLog` sub-collection entries plus every release exception
   * (any status) that has ever covered this report's period, each with its
   * redacted `auditTrail`. Staff-only, same-school.
   */
  api.getReportCardExceptionHistory = onCall(async (request) => {
    const caller = await loadCaller(request.auth);
    requireAnyRole(
      caller,
      [...BURSAR_ROLES, "headTeacher"],
      "You are not authorised to view report-card release history.",
    );
    const d = request.data || {};
    const reportCardId = txt(d.reportCardId, 180);
    if (!reportCardId) {
      throw new HttpsError("invalid-argument", "reportCardId is required.");
    }
    const rcRef = db.doc(`schools/${caller.schoolId}/reportCards/${reportCardId}`);
    const rcSnap = await rcRef.get();
    if (!rcSnap.exists) throw new HttpsError("not-found", "Report card not found.");
    const rc = rcSnap.data();
    if (rc.schoolId !== caller.schoolId) {
      throw new HttpsError("permission-denied", "Wrong school.");
    }
    const auditSnap = await rcRef
      .collection("auditLog")
      .orderBy("timestamp", "desc")
      .limit(50)
      .get();
    const reportAudit = auditSnap.docs.map((x) => {
      const a = x.data();
      return {
        action: a.action,
        actorName: a.actorDisplayName || "System",
        reason: a.reason || null,
        source: a.source || null,
        reportVersion: a.reportVersion || null,
        at: a.timestamp && a.timestamp.toMillis ? a.timestamp.toMillis() : null,
      };
    });
    const excSnap = await exceptionsCol(caller.schoolId)
      .where("studentId", "==", rc.studentId)
      .where("academicYearId", "==", rc.academicYearId)
      .where("termId", "==", rc.termId)
      .get();
    const exceptions = excSnap.docs
      .map((x) => serialiseException({ id: x.id, ...x.data() }))
      .sort((a, b) => (b.createdAt || 0) - (a.createdAt || 0));
    return { reportAudit, exceptions };
  });

  /**
   * Called best-effort by the Parent Portal when a parent/student opens a
   * report they can see. Writes an immutable parent-access audit event and
   * stamps consumedAt on the covering active exception (first read only),
   * which locks that exception from any future edit.
   */
  api.recordReportCardParentView = onCall(async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign-in required.");
    }
    const d = request.data || {};
    const reportCardId = txt(d.reportCardId, 180);
    const kind = d.kind === "download" ? "download" : "view";
    if (!reportCardId) {
      throw new HttpsError("invalid-argument", "reportCardId is required.");
    }
    const userSnap = await db.doc(`users/${request.auth.uid}`).get();
    const user = userSnap.exists ? userSnap.data() : {};
    const schoolId = user.schoolId;
    if (!schoolId) return { recorded: false };
    const rcRef = db.doc(`schools/${schoolId}/reportCards/${reportCardId}`);
    const rcSnap = await rcRef.get();
    if (!rcSnap.exists) return { recorded: false };
    const rc = rcSnap.data();
    // Server-side linkage re-check — never trust the caller.
    const linked =
      (Array.isArray(user.studentIds) && user.studentIds.includes(rc.studentId)) ||
      user.studentId === rc.studentId;
    if (!linked || rc.financialAccessStatus !== "released") {
      // Don't record an access that the rules would not have permitted.
      return { recorded: false };
    }
    await writeSchoolAudit(schoolId, {
      userId: request.auth.uid,
      action: kind === "download" ? "report_card.parent_download" : "report_card.parent_access",
      entityType: "reportCards",
      entityId: reportCardId,
      newValue: { studentId: rc.studentId, via: rc.financialAccessSource || "auto" },
    });
    if (rc.activeExceptionId) {
      const excRef = exceptionsCol(schoolId).doc(rc.activeExceptionId);
      await db
        .runTransaction(async (tx) => {
          const s = await tx.get(excRef);
          if (!s.exists) return;
          if (s.data().consumedAt) return;
          tx.update(excRef, {
            consumedAt: FieldValue.serverTimestamp(),
            auditTrail: FieldValue.arrayUnion({
              action: "consumed",
              actorUid: request.auth.uid,
              actorName: "Parent/Student",
              at: Timestamp.now(),
              note: `First ${kind} of report ${reportCardId}`,
            }),
          });
        })
        .catch((e) => console.error("stamp consumedAt failed", e));
    }
    return { recorded: true };
  });

  // ---------------------------------------------------------------------------
  // Scheduled expiry sweep
  // ---------------------------------------------------------------------------

  if (onSchedule) {
    api.expireLapsedReportCardExceptions = onSchedule(
      "every 6 hours",
      async () => {
        const now = nowTs();
        // listDocuments() (not get()) so a school whose top-level doc has no
        // fields - only subcollections - is still swept.
        const schoolRefs = await db.collection("schools").listDocuments();
        for (const schoolRef of schoolRefs) {
          const schoolId = schoolRef.id;
          // eslint-disable-next-line no-await-in-loop
          const due = await exceptionsCol(schoolId)
            .where("status", "==", "active")
            .where("expiresAt", "<=", now)
            .get();
          for (const doc of due.docs) {
            const e = doc.data();
            // eslint-disable-next-line no-await-in-loop
            await doc.ref.update({
              status: "expired",
              expiredAt: FieldValue.serverTimestamp(),
              auditTrail: FieldValue.arrayUnion({
                action: "expire",
                actorUid: "system",
                actorName: "System",
                at: Timestamp.now(),
                fromStatus: "active",
                toStatus: "expired",
              }),
            });
            // eslint-disable-next-line no-await-in-loop
            await writeSchoolAudit(schoolId, {
              userId: "system",
              action: "report_card_exception.expire",
              entityType: "reportCardReleaseExceptions",
              entityId: doc.id,
              newValue: { fromStatus: "active", toStatus: "expired" },
            });
            // eslint-disable-next-line no-await-in-loop
            await syncPeriodReportAccess({
              schoolId,
              studentId: e.studentId,
              academicYearId: e.academicYearId,
              termId: e.termId,
              source: "auto",
              reason: "Release exception expired.",
              exceptionId: null,
            }).catch((err) =>
              console.error("syncPeriodReportAccess (expiry) failed", err),
            );
            // Notify the Bursar if a report dropped back to held.
            // eslint-disable-next-line no-await-in-loop
            await enqueueNotification({
              schoolId,
              recipientRoles: BURSAR_ROLES,
              type: "report_card.exception_expired",
              title: "Report-card release exception expired",
              shortBody: `${e.studentName}: a release exception has expired and the report is withheld again.`,
              idempotencyKey: `rc_exc_expired_${doc.id}`,
              metadata: { exceptionId: doc.id },
            });
          }
        }
      },
    );
  }

  } // end if (onCall)

  // Exported for report_card_financial_gate.js and index.js.
  api.__internals = {
    loadClearancePolicy,
    computeFinancialClearance,
    resolveReportAccess,
    syncPeriodReportAccess,
    notifyParentsReportAvailable,
    DEFAULT_RESTRICTION_MESSAGE,
  };

  return api;
};
