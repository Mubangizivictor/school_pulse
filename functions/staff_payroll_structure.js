/**
 * Institution salary-structure backend.
 *
 * Mirrors student_fee_billing.js's design exactly, but keyed on staff
 * designation instead of class/term: all money is stored as integer UGX,
 * and published structure versions are immutable snapshots.
 */
module.exports = ({ admin, onCall, HttpsError }) => {
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
      throw new HttpsError("permission-denied", "You are not allowed to manage this school's payroll.");
    }
    return { uid: request.auth.uid, roles };
  }

  // Structure authoring/matching: HR/finance leadership only - unlike fee
  // plans, admissions/registrar staff have no reason to touch payroll.
  async function callerForPayroll(request, schoolId) {
    const caller = await loadCaller(request, schoolId);
    if (!caller.roles.some((role) =>
      ["schoolAdmin", "director", "headTeacher", "bursar"].includes(role)
    )) {
      throw new HttpsError("permission-denied", "Only HR/finance leadership can manage payroll.");
    }
    return caller;
  }

  function validateLines(lines) {
    if (!Array.isArray(lines) || lines.length === 0) {
      throw new HttpsError("invalid-argument", "At least one pay component is required.");
    }
    const seen = new Set();
    return lines.map((line, index) => {
      const componentId = asText(line?.componentId, 160);
      const name = asText(line?.name, 120);
      if (!componentId || !name) throw new HttpsError("invalid-argument", `Pay component ${index + 1} needs a componentId and name.`);
      if (seen.has(componentId)) throw new HttpsError("invalid-argument", "A component can appear only once in a structure.");
      seen.add(componentId);
      return {
        componentId, name,
        amountUgx: asMoney(line.amountUgx, `Pay component ${index + 1} amount`),
        required: line.required !== false,
        componentKey: asText(line.componentKey, 80) || null,
      };
    });
  }

  api.publishSalaryStructure = onCall(async (request) => {
    const data = request.data || {};
    const schoolId = asText(data.schoolId);
    const caller = await callerForPayroll(request, schoolId);
    const structureId = asText(data.structureId) || db.collection("schools").doc(schoolId).collection("salary_structures").doc().id;
    const designationId = asText(data.designationId);
    if (!designationId) {
      throw new HttpsError("invalid-argument", "designationId is required.");
    }
    const lines = validateLines(data.lines);
    const totalUgx = lines.reduce((sum, line) => sum + line.amountUgx, 0);
    const structureRef = db.doc(`schools/${schoolId}/salary_structures/${structureId}`);
    const versionRef = structureRef.collection("versions").doc();
    await db.runTransaction(async (tx) => {
      const existing = await tx.get(structureRef);
      const old = existing.exists ? existing.data() || {} : {};
      if (old.status === "published" && !data.createNewVersion) {
        throw new HttpsError("failed-precondition", "Published structures are immutable. Create a new version instead.");
      }
      const versionNumber = Number(old.latestVersion || 0) + 1;
      const selector = { designationId };
      tx.set(structureRef, {
        schoolId, name: asText(data.name, 160) || `Salary structure ${designationId}`,
        selector, status: "published", currency: "UGX", latestVersion: versionNumber,
        currentVersionId: versionRef.id, updatedAt: serverTime(), updatedBy: caller.uid,
        createdAt: old.createdAt || serverTime(), createdBy: old.createdBy || caller.uid,
      }, { merge: true });
      tx.set(versionRef, {
        schoolId, structureId, version: versionNumber, status: "published", selector,
        currency: "UGX", lines, totalUgx, publishedAt: serverTime(), publishedBy: caller.uid,
        createdAt: serverTime(), createdBy: caller.uid,
      });
      tx.set(db.collection("schools").doc(schoolId).collection("audit_events").doc(), {
        action: "salary_structure_published", actorId: caller.uid, structureId, versionId: versionRef.id,
        occurredAt: serverTime(),
      });
    });
    return { structureId, versionId: versionRef.id, totalUgx };
  });

  // Read-only matching endpoint for the Add Staff wizard's Pay Structure
  // step. Returns only a published structure/version and never accepts a
  // client-provided amount.
  api.findMatchingSalaryStructure = onCall(async (request) => {
    const data = request.data || {};
    const schoolId = asText(data.schoolId);
    await callerForPayroll(request, schoolId);
    const designationId = asText(data.designationId);
    if (!designationId) {
      throw new HttpsError("invalid-argument", "designationId is required.");
    }
    const structures = await db.collection(`schools/${schoolId}/salary_structures`)
      .where("status", "==", "published")
      .where("selector.designationId", "==", designationId)
      .limit(2)
      .get();
    if (structures.empty) return { match: null };
    if (structures.size > 1) {
      throw new HttpsError("failed-precondition", "More than one published salary structure matches this designation.");
    }
    const structure = structures.docs[0].data();
    const version = await structures.docs[0].ref.collection("versions").doc(structure.currentVersionId).get();
    if (!version.exists) throw new HttpsError("failed-precondition", "The published salary-structure version is missing.");
    const snapshot = version.data();
    return {
      match: {
        structureId: structures.docs[0].id, versionId: version.id, name: structure.name,
        currency: "UGX", totalUgx: snapshot.totalUgx, lines: snapshot.lines,
      },
    };
  });

  return api;
};
