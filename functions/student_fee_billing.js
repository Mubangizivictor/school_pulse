/**
 * Institution fee-plan and student-billing backend.
 *
 * All money is stored as integer UGX. Published plan versions and issued
 * bills are immutable snapshots; corrections use adjustments, never rewrites.
 */
module.exports = ({ admin, onCall, HttpsError }) => {
  // Bug fixed here: this factory used to assign onto the bare `exports`
  // identifier, which inside this arrow function resolves to THIS FILE's
  // own module-level exports object (a closure reference), not something
  // handed back to the caller - and the factory had no explicit `return`,
  // so `require("./student_fee_billing")({...})` always evaluated to
  // undefined. index.js's `Object.assign(exports, require(...)(...))`
  // therefore silently no-op'd (Object.assign ignores undefined/null
  // sources without throwing), meaning publishFeePlan/findMatchingFeePlan/
  // issueStudentBill were never actually exported as callable Cloud
  // Functions despite compiling and passing static review. Caught by the
  // new emulator integration test in
  // test/student_fee_billing.emulator.test.cjs, which calls these exports
  // directly and failed with "is not a function" until this was fixed.
  const api = {};
  const db = admin.firestore();
  const serverTime = () => admin.firestore.FieldValue.serverTimestamp();

  const asText = (value, max = 160) => String(value ?? "").trim().slice(0, max);
  const asMoney = (value, field) => {
    if (!Number.isSafeInteger(value) || value < 0) {
      throw new HttpsError("invalid-argument", `${field} must be a non-negative whole number of UGX.`);
    }
    return value;
  };

  async function loadCaller(request, schoolId) {
    if (!request.auth) throw new HttpsError("unauthenticated", "Sign-in required.");
    if (!schoolId) throw new HttpsError("invalid-argument", "schoolId is required.");
    const snap = await db.collection("users").doc(request.auth.uid).get();
    const user = snap.exists ? snap.data() || {} : {};
    const roles = Array.isArray(user.roles) ? user.roles : [user.role].filter(Boolean);
    if (user.schoolId !== schoolId) {
      throw new HttpsError("permission-denied", "You are not allowed to manage this school's student billing.");
    }
    return { uid: request.auth.uid, roles };
  }

  // Plan authoring/matching/issuance: schoolAdmin/director/headTeacher/
  // bursar (finance leadership) plus registrar/admissions, since admissions
  // staff need to issue a bill as part of finishing an enrolment.
  async function callerForSchool(request, schoolId) {
    const caller = await loadCaller(request, schoolId);
    if (!caller.roles.some((role) =>
      ["schoolAdmin", "director", "headTeacher", "bursar", "registrar", "admissions"].includes(role)
    )) {
      throw new HttpsError("permission-denied", "You are not allowed to manage this school's student billing.");
    }
    return caller;
  }

  // Money-adjusting actions (discounts/waivers, payments, reversals):
  // deliberately narrower than callerForSchool. registrar/admissions can
  // issue a bill against an already-published, already-priced plan, but
  // approving a discount or recording/reversing money received is a
  // finance-leadership decision - the same set firestore.rules'
  // isFinanceStaff() already uses for the legacy finance collections, kept
  // in sync here on purpose.
  async function callerForFinance(request, schoolId) {
    const caller = await loadCaller(request, schoolId);
    if (!caller.roles.some((role) =>
      ["schoolAdmin", "director", "headTeacher", "bursar"].includes(role)
    )) {
      throw new HttpsError("permission-denied", "Only finance leadership can perform this action.");
    }
    return caller;
  }

  function normalizedName(value) {
    return asText(value, 120).toLowerCase().replace(/\s+/g, " ");
  }

  function validateLines(lines) {
    if (!Array.isArray(lines) || lines.length === 0) {
      throw new HttpsError("invalid-argument", "At least one fee line is required.");
    }
    const seen = new Set();
    return lines.map((line, index) => {
      const chargeId = asText(line?.chargeId, 160);
      const name = asText(line?.name, 120);
      if (!chargeId || !name) throw new HttpsError("invalid-argument", `Fee line ${index + 1} needs a chargeId and name.`);
      if (seen.has(chargeId)) throw new HttpsError("invalid-argument", "A charge can appear only once in a plan.");
      seen.add(chargeId);
      return {
        chargeId, name,
        amountUgx: asMoney(line.amountUgx, `Fee line ${index + 1} amount`),
        required: line.required !== false,
        serviceKey: asText(line.serviceKey, 80) || null,
      };
    });
  }

  api.publishFeePlan = onCall(async (request) => {
    const data = request.data || {};
    const schoolId = asText(data.schoolId);
    const caller = await callerForSchool(request, schoolId);
    const planId = asText(data.planId) || db.collection("schools").doc(schoolId).collection("fee_plans").doc().id;
    const academicYearId = asText(data.academicYearId);
    const termId = asText(data.termId);
    const classId = asText(data.classId);
    const studentCategory = asText(data.studentCategory, 60) || "day";
    if (!academicYearId || !termId || !classId) {
      throw new HttpsError("invalid-argument", "academicYearId, termId, and classId are required.");
    }
    const lines = validateLines(data.lines);
    const totalUgx = lines.reduce((sum, line) => sum + line.amountUgx, 0);
    const planRef = db.doc(`schools/${schoolId}/fee_plans/${planId}`);
    const versionRef = planRef.collection("versions").doc();
    await db.runTransaction(async (tx) => {
      const existing = await tx.get(planRef);
      const old = existing.exists ? existing.data() || {} : {};
      if (old.status === "published" && !data.createNewVersion) {
        throw new HttpsError("failed-precondition", "Published plans are immutable. Create a new version instead.");
      }
      const versionNumber = Number(old.latestVersion || 0) + 1;
      const selector = { academicYearId, termId, classId, studentCategory: normalizedName(studentCategory) };
      tx.set(planRef, {
        schoolId, name: asText(data.name, 160) || `Fee plan ${academicYearId} ${termId}`,
        normalizedName: normalizedName(data.name || `Fee plan ${academicYearId} ${termId}`),
        selector, status: "published", currency: "UGX", latestVersion: versionNumber,
        currentVersionId: versionRef.id, updatedAt: serverTime(), updatedBy: caller.uid,
        createdAt: old.createdAt || serverTime(), createdBy: old.createdBy || caller.uid,
      }, { merge: true });
      tx.set(versionRef, {
        schoolId, planId, version: versionNumber, status: "published", selector,
        currency: "UGX", lines, totalUgx, publishedAt: serverTime(), publishedBy: caller.uid,
        createdAt: serverTime(), createdBy: caller.uid,
      });
      tx.set(db.collection("schools").doc(schoolId).collection("audit_events").doc(), {
        action: "fee_plan_published", actorId: caller.uid, planId, versionId: versionRef.id,
        occurredAt: serverTime(),
      });
    });
    return { planId, versionId: versionRef.id, totalUgx };
  });

  // Read-only matching endpoint for the enrolment review. It returns only a
  // published plan/version and never accepts a client-provided price.
  api.findMatchingFeePlan = onCall(async (request) => {
    const data = request.data || {};
    const schoolId = asText(data.schoolId);
    await callerForSchool(request, schoolId);
    const selector = {
      academicYearId: asText(data.academicYearId),
      termId: asText(data.termId),
      classId: asText(data.classId),
      studentCategory: normalizedName(data.studentCategory || "day"),
    };
    if (!selector.academicYearId || !selector.termId || !selector.classId) {
      throw new HttpsError("invalid-argument", "academicYearId, termId, and classId are required.");
    }
    const plans = await db.collection(`schools/${schoolId}/fee_plans`)
      .where("status", "==", "published")
      .where("selector.academicYearId", "==", selector.academicYearId)
      .where("selector.termId", "==", selector.termId)
      .where("selector.classId", "==", selector.classId)
      .where("selector.studentCategory", "==", selector.studentCategory)
      .limit(2)
      .get();
    if (plans.empty) return { match: null };
    if (plans.size > 1) {
      throw new HttpsError("failed-precondition", "More than one published fee plan matches this learner.");
    }
    const plan = plans.docs[0].data();
    const version = await plans.docs[0].ref.collection("versions").doc(plan.currentVersionId).get();
    if (!version.exists) throw new HttpsError("failed-precondition", "The published fee-plan version is missing.");
    const snapshot = version.data();
    return {
      match: {
        planId: plans.docs[0].id, versionId: version.id, name: plan.name,
        currency: "UGX", totalUgx: snapshot.totalUgx, lines: snapshot.lines,
      },
    };
  });

  api.issueStudentBill = onCall(async (request) => {
    const data = request.data || {};
    const schoolId = asText(data.schoolId);
    const caller = await callerForSchool(request, schoolId);
    const studentId = asText(data.studentId);
    const planId = asText(data.planId);
    if (!studentId || !planId) throw new HttpsError("invalid-argument", "studentId and planId are required.");
    const billId = asText(data.idempotencyKey, 180) || `${studentId}_${planId}`;
    const studentRef = db.doc(`students/${studentId}`);
    const planRef = db.doc(`schools/${schoolId}/fee_plans/${planId}`);
    const billRef = db.doc(`schools/${schoolId}/student_accounts/${studentId}/bills/${billId}`);
    await db.runTransaction(async (tx) => {
      const [studentSnap, planSnap, billSnap] = await Promise.all([tx.get(studentRef), tx.get(planRef), tx.get(billRef)]);
      if (!studentSnap.exists || studentSnap.data().schoolId !== schoolId) throw new HttpsError("not-found", "Student was not found in this school.");
      if (!planSnap.exists || planSnap.data().status !== "published") throw new HttpsError("failed-precondition", "A published fee plan is required.");
      if (billSnap.exists) return;
      const plan = planSnap.data();
      const versionRef = planRef.collection("versions").doc(plan.currentVersionId);
      const versionSnap = await tx.get(versionRef);
      if (!versionSnap.exists) throw new HttpsError("failed-precondition", "The published fee-plan version is missing.");
      const version = versionSnap.data();
      const student = studentSnap.data();
      const selector = version.selector || {};
      if (student.classId !== selector.classId) throw new HttpsError("failed-precondition", "The fee plan does not match the student's class.");
      tx.set(billRef, {
        schoolId, studentId, billId, status: "open", currency: "UGX",
        planId, planVersionId: versionRef.id, academicYearId: selector.academicYearId,
        termId: selector.termId, classId: selector.classId,
        issuedTotalUgx: version.totalUgx, paidTotalUgx: 0, adjustmentTotalUgx: 0,
        balanceUgx: version.totalUgx, lines: version.lines, issuedAt: serverTime(),
        issuedBy: caller.uid, createdAt: serverTime(), updatedAt: serverTime(),
      });
      tx.set(db.doc(`schools/${schoolId}/student_accounts/${studentId}`), {
        schoolId, studentId, currency: "UGX", lastBillId: billId,
        updatedAt: serverTime(), updatedBy: caller.uid,
      }, { merge: true });
      tx.set(db.collection("schools").doc(schoolId).collection("audit_events").doc(), {
        action: "student_bill_issued", actorId: caller.uid, studentId, billId, planId,
        occurredAt: serverTime(),
      });
    });
    return { billId };
  });

  // ---------------------------------------------------------------------
  // Adjustments, payments, reversals.
  //
  // The bill doc's issuedTotalUgx/lines snapshot is never touched again once
  // issueStudentBill writes it - every correction (discount, payment,
  // reversal) is its own immutable record under the bill, and only
  // adjustmentTotalUgx/paidTotalUgx/balanceUgx on the parent bill doc are
  // updated, atomically, in the same transaction as the record write.
  // balanceUgx = issuedTotalUgx - adjustmentTotalUgx - paidTotalUgx and must
  // never go negative - every write here recomputes it from the bill's
  // current fields inside the transaction and rejects (rather than silently
  // clamping) a change that would drive it below zero, since a silent clamp
  // would hide a real operator error (e.g. double-applying a discount).
  // ---------------------------------------------------------------------

  const ADJUSTMENT_TYPES = ["discount", "scholarship", "waiver"];
  const PAYMENT_METHODS = ["cash", "mobile_money", "bank_transfer"];

  async function loadBillForWrite(tx, schoolId, studentId, billId) {
    const billRef = db.doc(`schools/${schoolId}/student_accounts/${studentId}/bills/${billId}`);
    const billSnap = await tx.get(billRef);
    if (!billSnap.exists || billSnap.data().schoolId !== schoolId) {
      throw new HttpsError("not-found", "Bill was not found for this student.");
    }
    return { billRef, bill: billSnap.data() };
  }

  // Sequential-looking, collision-proof receipt numbers: a per-school
  // counter doc incremented inside the same transaction as the payment
  // write, never client-supplied. Formatted as RCT-{schoolId prefix-free
  // sequence, zero-padded} so it reads like a real receipt number rather
  // than a raw Firestore id.
  async function nextReceiptNumber(tx, schoolId) {
    const counterRef = db.doc(`schools/${schoolId}/counters/receiptNumber`);
    const counterSnap = await tx.get(counterRef);
    const next = (counterSnap.exists ? Number(counterSnap.data().value || 0) : 0) + 1;
    tx.set(counterRef, { value: next, updatedAt: serverTime() }, { merge: true });
    return `RCT-${String(next).padStart(6, "0")}`;
  }

  api.applyBillAdjustment = onCall(async (request) => {
    const data = request.data || {};
    const schoolId = asText(data.schoolId);
    const caller = await callerForFinance(request, schoolId);
    const studentId = asText(data.studentId);
    const billId = asText(data.billId);
    if (!studentId || !billId) throw new HttpsError("invalid-argument", "studentId and billId are required.");
    const type = asText(data.type, 40);
    if (!ADJUSTMENT_TYPES.includes(type)) {
      throw new HttpsError("invalid-argument", `type must be one of: ${ADJUSTMENT_TYPES.join(", ")}.`);
    }
    const reason = asText(data.reason, 500);
    if (!reason) throw new HttpsError("invalid-argument", "reason is required.");
    const evidenceReference = asText(data.evidenceReference, 500) || null;
    const hasAmount = data.amountUgx !== undefined && data.amountUgx !== null;
    const hasPercentage = data.percentage !== undefined && data.percentage !== null;
    if (hasAmount === hasPercentage) {
      throw new HttpsError("invalid-argument", "Provide exactly one of amountUgx or percentage.");
    }
    if (hasPercentage) {
      const percentage = Number(data.percentage);
      if (!Number.isFinite(percentage) || percentage <= 0 || percentage > 100) {
        throw new HttpsError("invalid-argument", "percentage must be a number between 0 (exclusive) and 100.");
      }
    }

    const adjustmentRef = db
      .collection(`schools/${schoolId}/student_accounts/${studentId}/bills/${billId}/adjustments`)
      .doc();

    const result = await db.runTransaction(async (tx) => {
      const { billRef, bill } = await loadBillForWrite(tx, schoolId, studentId, billId);
      const amountUgx = hasAmount
        ? asMoney(data.amountUgx, "amountUgx")
        : Math.round((Number(data.percentage) / 100) * Number(bill.issuedTotalUgx || 0));

      const newAdjustmentTotal = Number(bill.adjustmentTotalUgx || 0) + amountUgx;
      const newBalance = Number(bill.issuedTotalUgx || 0) - newAdjustmentTotal - Number(bill.paidTotalUgx || 0);
      if (newBalance < 0) {
        throw new HttpsError(
          "failed-precondition",
          "This adjustment would take the bill balance below zero. Reduce the amount/percentage."
        );
      }

      const ref = adjustmentRef;
      tx.set(ref, {
        schoolId, studentId, billId, adjustmentId: ref.id, type, amountUgx,
        percentage: hasPercentage ? Number(data.percentage) : null,
        reason, evidenceReference,
        // approverId is captured server-side from the authenticated caller -
        // never trust a client-supplied approver for who authorized money
        // leaving the books.
        approverId: caller.uid, createdAt: serverTime(),
      });
      tx.update(billRef, {
        adjustmentTotalUgx: newAdjustmentTotal, balanceUgx: newBalance, updatedAt: serverTime(),
      });
      tx.set(db.collection("schools").doc(schoolId).collection("audit_events").doc(), {
        action: "bill_adjustment_applied", actorId: caller.uid, studentId, billId,
        adjustmentId: ref.id, type, amountUgx, occurredAt: serverTime(),
      });
      return { adjustmentId: ref.id, amountUgx, balanceUgx: newBalance };
    });
    return result;
  });

  api.recordStudentPayment = onCall(async (request) => {
    const data = request.data || {};
    const schoolId = asText(data.schoolId);
    const caller = await callerForFinance(request, schoolId);
    const studentId = asText(data.studentId);
    const billId = asText(data.billId);
    if (!studentId || !billId) throw new HttpsError("invalid-argument", "studentId and billId are required.");
    const method = asText(data.method, 40);
    if (!PAYMENT_METHODS.includes(method)) {
      throw new HttpsError("invalid-argument", `method must be one of: ${PAYMENT_METHODS.join(", ")}.`);
    }
    const amountUgx = asMoney(data.amountUgx, "amountUgx");
    if (amountUgx <= 0) throw new HttpsError("invalid-argument", "amountUgx must be greater than zero.");
    const referenceNumber = asText(data.referenceNumber, 160) || null;
    const payerName = asText(data.payerName, 160) || null;
    const payerGuardianId = asText(data.payerGuardianId, 160) || null;
    const allocations = Array.isArray(data.allocations)
      ? data.allocations.map((a, index) => {
          const chargeId = asText(a?.chargeId, 160) || null;
          const allocatedAmountUgx = asMoney(a?.amountUgx, `Allocation ${index + 1} amount`);
          return { chargeId, amountUgx: allocatedAmountUgx };
        })
      : [];
    if (allocations.length > 0) {
      const allocatedTotal = allocations.reduce((sum, a) => sum + a.amountUgx, 0);
      if (allocatedTotal !== amountUgx) {
        throw new HttpsError("invalid-argument", "Allocation amounts must sum to amountUgx.");
      }
    }

    const paymentRef = db.collection(`schools/${schoolId}/student_accounts/${studentId}/bills/${billId}/payments`).doc();

    const result = await db.runTransaction(async (tx) => {
      const { billRef, bill } = await loadBillForWrite(tx, schoolId, studentId, billId);
      const newPaidTotal = Number(bill.paidTotalUgx || 0) + amountUgx;
      const newBalance = Number(bill.issuedTotalUgx || 0) - Number(bill.adjustmentTotalUgx || 0) - newPaidTotal;
      if (newBalance < 0) {
        throw new HttpsError(
          "failed-precondition",
          "This payment exceeds the remaining balance on the bill."
        );
      }
      // receiptNumber is generated here, inside the transaction, from a
      // server-side counter - never accepted from the client, so it can
      // never be spoofed or collide.
      const receiptNumber = await nextReceiptNumber(tx, schoolId);

      tx.set(paymentRef, {
        schoolId, studentId, billId, paymentId: paymentRef.id, status: "recorded",
        method, amountUgx, currency: "UGX", referenceNumber, payerName, payerGuardianId,
        allocations, receiptNumber, recordedBy: caller.uid, recordedAt: serverTime(),
        createdAt: serverTime(), reversalOfPaymentId: null,
      });
      tx.update(billRef, {
        paidTotalUgx: newPaidTotal, balanceUgx: newBalance,
        status: newBalance === 0 ? "paid" : bill.status, updatedAt: serverTime(),
      });
      tx.set(db.collection("schools").doc(schoolId).collection("audit_events").doc(), {
        action: "student_payment_recorded", actorId: caller.uid, studentId, billId,
        paymentId: paymentRef.id, amountUgx, receiptNumber, occurredAt: serverTime(),
      });
      return { paymentId: paymentRef.id, receiptNumber, balanceUgx: newBalance };
    });
    return result;
  });

  // Compensating-record reversal: never mutates the original payment doc.
  // Writes a new payment record with a negative amountUgx referencing the
  // original via reversalOfPaymentId, and restores paidTotalUgx/balanceUgx
  // on the bill accordingly. Reversals are gated by the same finance-only
  // role set as callerForFinance - deliberately not widened, since undoing
  // recorded money is at least as sensitive as recording it.
  api.reverseStudentPayment = onCall(async (request) => {
    const data = request.data || {};
    const schoolId = asText(data.schoolId);
    const caller = await callerForFinance(request, schoolId);
    const studentId = asText(data.studentId);
    const billId = asText(data.billId);
    const paymentId = asText(data.paymentId);
    if (!studentId || !billId || !paymentId) {
      throw new HttpsError("invalid-argument", "studentId, billId, and paymentId are required.");
    }
    const reason = asText(data.reason, 500);
    if (!reason) throw new HttpsError("invalid-argument", "reason is required.");

    const originalRef = db.doc(`schools/${schoolId}/student_accounts/${studentId}/bills/${billId}/payments/${paymentId}`);
    const reversalRef = db.collection(`schools/${schoolId}/student_accounts/${studentId}/bills/${billId}/payments`).doc();

    const result = await db.runTransaction(async (tx) => {
      const { billRef, bill } = await loadBillForWrite(tx, schoolId, studentId, billId);
      const originalSnap = await tx.get(originalRef);
      if (!originalSnap.exists) throw new HttpsError("not-found", "Original payment was not found.");
      const original = originalSnap.data();
      if (original.amountUgx <= 0) {
        throw new HttpsError("failed-precondition", "Only a positive payment can be reversed.");
      }
      if (original.reversedBy) {
        throw new HttpsError("failed-precondition", "This payment has already been reversed.");
      }

      const reversalAmount = -original.amountUgx;
      const newPaidTotal = Number(bill.paidTotalUgx || 0) + reversalAmount;
      const newBalance = Number(bill.issuedTotalUgx || 0) - Number(bill.adjustmentTotalUgx || 0) - newPaidTotal;
      const receiptNumber = await nextReceiptNumber(tx, schoolId);

      tx.set(reversalRef, {
        schoolId, studentId, billId, paymentId: reversalRef.id, status: "reversal",
        method: original.method, amountUgx: reversalAmount, currency: "UGX",
        referenceNumber: original.referenceNumber, payerName: original.payerName,
        payerGuardianId: original.payerGuardianId, allocations: [], receiptNumber,
        recordedBy: caller.uid, recordedAt: serverTime(), createdAt: serverTime(),
        reversalOfPaymentId: paymentId, reason,
      });
      // The original record's fields are never mutated - only a
      // reversedBy/reversedAt marker is added so it's easy to tell at a
      // glance a compensating record exists, without changing anything the
      // original payment asserted about what happened.
      tx.update(originalRef, { reversedBy: caller.uid, reversedAt: serverTime(), reversalPaymentId: reversalRef.id });
      tx.update(billRef, {
        paidTotalUgx: newPaidTotal, balanceUgx: newBalance,
        status: newBalance > 0 && bill.status === "paid" ? "open" : bill.status,
        updatedAt: serverTime(),
      });
      tx.set(db.collection("schools").doc(schoolId).collection("audit_events").doc(), {
        action: "student_payment_reversed", actorId: caller.uid, studentId, billId,
        paymentId, reversalPaymentId: reversalRef.id, reason, occurredAt: serverTime(),
      });
      return { reversalPaymentId: reversalRef.id, receiptNumber, balanceUgx: newBalance };
    });
    return result;
  });

  return api;
};