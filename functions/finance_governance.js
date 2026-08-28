// Authoritative finance-governance writes: expenditure requisitions,
// expenditure approval decisions, and school budget lines.
//
// Before this module these three mutations went straight from the client
// SDK to `schools/{id}/expenditures` and `schools/{id}/budgets`, protected
// only by Firestore rules. They are now callable-only (rules deny client
// writes) so every change is validated, tenant/role checked, idempotent,
// and recorded in `finance_audit_events` in the same transaction.
//
// Factory shape matches student_fee_billing.js / payment_vouchers.js:
// `require("./finance_governance")({ admin, onCall, HttpsError })` returns
// an object of callables that index.js Object.assign()s onto exports. The
// factory MUST return `api` (assigning onto a bare `exports` here is a
// no-op — see the note atop student_fee_billing.js).
module.exports = ({ admin, onCall, HttpsError }) => {
  const db = admin.firestore();
  const FieldValue = admin.firestore.FieldValue;

  const txt = (v, n = 240) => String(v == null ? "" : v).trim().slice(0, n);
  const slug = (v) =>
    txt(v, 60)
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/(^-|-$)/g, "");

  // Positive whole-UGX guard. Money in this project is integer UGX; a
  // fractional or non-positive amount is always a client bug.
  const wholeUgx = (v, label) => {
    const n = typeof v === "number" ? v : Number(v);
    if (!Number.isFinite(n) || !Number.isInteger(n) || n <= 0) {
      throw new HttpsError(
        "invalid-argument",
        `${label} must be a positive whole number of UGX.`,
      );
    }
    return n;
  };
  const nonNegUgx = (v, label) => {
    const n = typeof v === "number" ? v : Number(v);
    if (!Number.isFinite(n) || !Number.isInteger(n) || n < 0) {
      throw new HttpsError(
        "invalid-argument",
        `${label} must be a whole number of UGX (0 or more).`,
      );
    }
    return n;
  };

  const FINANCE_ROLES = new Set([
    "bursar",
    "schoolAdmin",
    "headTeacher",
    "director",
  ]);
  // Who may raise a requisition or edit a budget line. Deliberately the
  // same finance set — mirrors canWriteFinance() in firestore.rules.
  const AUTHOR_ROLES = new Set(["bursar", "schoolAdmin"]);

  async function loadCaller(request, schoolId) {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign-in required.");
    }
    if (!schoolId) {
      throw new HttpsError("invalid-argument", "schoolId is required.");
    }
    const snap = await db.doc(`users/${request.auth.uid}`).get();
    const user = snap.exists ? snap.data() : {};
    const roles = Array.isArray(user.roles)
      ? user.roles
      : [user.role].filter(Boolean);
    if (user.schoolId !== schoolId) {
      // Tenant isolation: a signed-in user of school A can never touch
      // school B's finance records, whatever their role.
      throw new HttpsError(
        "permission-denied",
        "You cannot modify another school's finance records.",
      );
    }
    return {
      uid: request.auth.uid,
      roles,
      name: txt(user.displayName || user.name || "", 120),
      primaryRole: roles.find((r) => FINANCE_ROLES.has(r)) || roles[0] || "",
    };
  }

  const requireRole = (caller, allowed, action) => {
    if (!caller.roles.some((r) => allowed.has(r))) {
      throw new HttpsError("permission-denied", `Not authorised to ${action}.`);
    }
  };

  const auditRef = (schoolId) =>
    db.collection(`schools/${schoolId}/finance_audit_events`).doc();

  const auditEntry = (module, action, caller, extra) => ({
    module,
    action,
    actorId: caller.uid,
    actorRole: caller.primaryRole,
    ...extra,
    at: FieldValue.serverTimestamp(),
  });

  const api = {};

  // ---- Expenditure requisitions ------------------------------------------

  // Create or amend a `pending` requisition. Idempotent on
  // `clientRequestId` (a UUID the client mints once per submit attempt) so
  // a retried call after a dropped response reuses the same doc instead of
  // raising a duplicate. Amending is only allowed while still `pending`.
  api.submitExpenditure = onCall(async (request) => {
    const d = request.data || {};
    const schoolId = txt(d.schoolId);
    const caller = await loadCaller(request, schoolId);
    requireRole(caller, AUTHOR_ROLES, "raise an expenditure requisition");

    const description = txt(d.description, 500);
    const budgetCategoryId = txt(d.budgetCategoryId, 120);
    const amount = wholeUgx(d.amount, "Requisition amount");
    const supplierId = d.supplierId ? txt(d.supplierId, 120) : null;
    const supplierName = d.supplierName ? txt(d.supplierName, 200) : null;
    const attachmentUrls = Array.isArray(d.attachmentUrls)
      ? d.attachmentUrls.map((u) => txt(u, 500)).filter(Boolean).slice(0, 20)
      : [];
    if (!description || !budgetCategoryId) {
      throw new HttpsError(
        "invalid-argument",
        "A description and budget category are required.",
      );
    }

    const col = db.collection(`schools/${schoolId}/expenditures`);
    const clientRequestId = txt(d.clientRequestId, 180);
    const explicitId = txt(d.expenditureId, 180);
    const docId =
      explicitId ||
      (clientRequestId ? `req_${slug(clientRequestId) || clientRequestId}` : col.doc().id);
    const ref = col.doc(docId);

    const result = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (snap.exists) {
        const cur = snap.data();
        if (cur.status && cur.status !== "pending") {
          // A decision has already been taken — the requisition is frozen.
          throw new HttpsError(
            "failed-precondition",
            "This requisition is no longer editable.",
          );
        }
        if (cur.requesterId && cur.requesterId !== caller.uid) {
          throw new HttpsError(
            "permission-denied",
            "Only the requester can amend this requisition.",
          );
        }
      }
      const base = snap.exists ? snap.data() : {};
      tx.set(
        ref,
        {
          schoolId,
          requesterId: base.requesterId || caller.uid,
          requesterName: base.requesterName || caller.name,
          description,
          amount,
          budgetCategoryId,
          supplierId,
          supplierName,
          status: "pending",
          attachmentUrls,
          approvalHistory: base.approvalHistory || [],
          clientRequestId: clientRequestId || base.clientRequestId || null,
          createdAt: base.createdAt || FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      tx.set(
        auditRef(schoolId),
        auditEntry("expenditure", snap.exists ? "expenditure_amended" : "expenditure_submitted", caller, {
          expenditureId: docId,
          amountUgx: amount,
        }),
      );
      return { expenditureId: docId, created: !snap.exists };
    });
    return result;
  });

  // approve | reject | return. The requester may never decide their own
  // requisition. Idempotent: repeating the *same* decision by the *same*
  // actor on an already-decided doc succeeds as a no-op; a conflicting
  // decision on a terminal doc is `failed-precondition`.
  api.decideExpenditure = onCall(async (request) => {
    const d = request.data || {};
    const schoolId = txt(d.schoolId);
    const expenditureId = txt(d.expenditureId, 180);
    const decision = txt(d.decision, 16).toLowerCase();
    const comment = txt(d.comment, 1000);
    const caller = await loadCaller(request, schoolId);
    requireRole(caller, FINANCE_ROLES, "decide an expenditure requisition");
    if (!expenditureId) {
      throw new HttpsError("invalid-argument", "expenditureId is required.");
    }
    const NEXT = { approve: "approved", reject: "rejected", return: "pending" };
    if (!NEXT[decision]) {
      throw new HttpsError(
        "invalid-argument",
        "decision must be one of: approve, reject, return.",
      );
    }
    if ((decision === "reject" || decision === "return") && !comment) {
      throw new HttpsError(
        "invalid-argument",
        "A comment is required when rejecting or returning a requisition.",
      );
    }

    const ref = db.doc(`schools/${schoolId}/expenditures/${expenditureId}`);
    return db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists) {
        throw new HttpsError("not-found", "Requisition not found.");
      }
      const cur = snap.data();
      if (cur.requesterId === caller.uid) {
        throw new HttpsError(
          "permission-denied",
          "You cannot decide a requisition you raised.",
        );
      }
      const target = NEXT[decision];
      const history = Array.isArray(cur.approvalHistory)
        ? cur.approvalHistory.slice()
        : [];
      const last = history[history.length - 1];

      if (cur.status === target) {
        if (last && last.approverId === caller.uid && last.status === decision) {
          // Exact retry — no-op success.
          return { expenditureId, status: cur.status, idempotent: true };
        }
        if (target !== "pending") {
          // Someone else already reached this terminal state.
          return { expenditureId, status: cur.status, idempotent: true };
        }
      }
      if (
        (cur.status === "approved" || cur.status === "rejected") &&
        target !== cur.status
      ) {
        throw new HttpsError(
          "failed-precondition",
          `Requisition is already ${cur.status} and cannot be ${decision}ed.`,
        );
      }

      history.push({
        id: auditRef(schoolId).id,
        approverId: caller.uid,
        approverName: caller.name,
        approverRole: caller.primaryRole,
        status: decision,
        comment: comment || null,
        updatedAt: admin.firestore.Timestamp.now(),
      });
      tx.update(ref, {
        status: target,
        approvalHistory: history,
        decidedAt: FieldValue.serverTimestamp(),
        decidedBy: caller.uid,
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.set(
        auditRef(schoolId),
        auditEntry("expenditure", `expenditure_${decision}`, caller, {
          expenditureId,
          fromStatus: cur.status || "pending",
          toStatus: target,
        }),
      );
      return { expenditureId, status: target, idempotent: false };
    });
  });

  // ---- School budget lines ---------------------------------------------

  // Upsert a budget line. The client can never set `spentAmount` — the
  // server preserves the stored value (or 0 for a new line); actuals are
  // driven by paid expenditures/vouchers elsewhere. Idempotent on
  // `clientRequestId`, else keyed by year+term+name so re-saving the same
  // line updates rather than duplicates.
  api.saveSchoolBudget = onCall(async (request) => {
    const d = request.data || {};
    const schoolId = txt(d.schoolId);
    const caller = await loadCaller(request, schoolId);
    requireRole(caller, AUTHOR_ROLES, "manage budget lines");

    const name = txt(d.name, 160);
    const academicYear = txt(d.academicYear, 32);
    const term = txt(d.term, 32);
    const description = d.description ? txt(d.description, 1000) : null;
    const allocatedAmount = nonNegUgx(d.allocatedAmount, "Allocated amount");
    if (!name || !academicYear || !term) {
      throw new HttpsError(
        "invalid-argument",
        "Budget name, academic year and term are required.",
      );
    }

    const col = db.collection(`schools/${schoolId}/budgets`);
    const clientRequestId = txt(d.clientRequestId, 180);
    const explicitId = txt(d.budgetId, 180);
    const docId =
      explicitId ||
      (clientRequestId
        ? `bdg_${slug(clientRequestId) || clientRequestId}`
        : `${slug(academicYear)}__${slug(term)}__${slug(name)}`);
    const ref = col.doc(docId);

    return db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      const base = snap.exists ? snap.data() : {};
      const spentAmount = Number.isFinite(base.spentAmount)
        ? base.spentAmount
        : 0;
      tx.set(
        ref,
        {
          schoolId,
          name,
          academicYear,
          term,
          description,
          allocatedAmount,
          spentAmount,
          createdAt: base.createdAt || FieldValue.serverTimestamp(),
          createdBy: base.createdBy || caller.uid,
          updatedAt: FieldValue.serverTimestamp(),
          updatedBy: caller.uid,
        },
        { merge: true },
      );
      tx.set(
        auditRef(schoolId),
        auditEntry("budget", snap.exists ? "budget_updated" : "budget_created", caller, {
          budgetId: docId,
          allocatedUgx: allocatedAmount,
        }),
      );
      return { budgetId: docId, created: !snap.exists };
    });
  });

  return api;
};
