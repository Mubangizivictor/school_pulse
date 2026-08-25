/**
 * Institution fee-plan and student-billing backend.
 *
 * All money is stored as integer UGX. Published plan versions and issued
 * bills are immutable snapshots; corrections use adjustments, never rewrites.
 */
module.exports = ({ admin, onCall, HttpsError }) => {
  const db = admin.firestore();
  const serverTime = () => admin.firestore.FieldValue.serverTimestamp();

  const asText = (value, max = 160) => String(value ?? "").trim().slice(0, max);
  const asMoney = (value, field) => {
    if (!Number.isSafeInteger(value) || value < 0) {
      throw new HttpsError("invalid-argument", `${field} must be a non-negative whole number of UGX.`);
    }
    return value;
  };

  async function callerForSchool(request, schoolId) {
    if (!request.auth) throw new HttpsError("unauthenticated", "Sign-in required.");
    if (!schoolId) throw new HttpsError("invalid-argument", "schoolId is required.");
    const snap = await db.collection("users").doc(request.auth.uid).get();
    const user = snap.exists ? snap.data() || {} : {};
    const roles = Array.isArray(user.roles) ? user.roles : [user.role].filter(Boolean);
    if (user.schoolId !== schoolId || !roles.some((role) =>
      ["schoolAdmin", "director", "headTeacher", "bursar", "registrar", "admissions"].includes(role)
    )) {
      throw new HttpsError("permission-denied", "You are not allowed to manage this school's student billing.");
    }
    return { uid: request.auth.uid, roles };
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

  exports.publishFeePlan = onCall(async (request) => {
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

  exports.issueStudentBill = onCall(async (request) => {
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
};