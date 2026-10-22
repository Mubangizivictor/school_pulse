/** Server-authoritative clinic mutations. Clinical payloads are never logged. */
module.exports = ({ admin, onCall, HttpsError }) => {
  const db = admin.firestore();
  const roles = new Set(['nurse', 'schoolAdmin', 'headTeacher', 'deputyHead', 'director']);
  async function actor(request) {
    if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
    const snap = await db.collection('users').doc(request.auth.uid).get();
    const user = snap.data();
    const assigned = [user?.role, ...(Array.isArray(user?.roles) ? user.roles : [])];
    if (!snap.exists || !user?.schoolId || user.isActive === false || !assigned.some((role) => roles.has(role))) {
      throw new HttpsError('permission-denied', 'You are not authorised for clinical records.');
    }
    return { uid: request.auth.uid, schoolId: user.schoolId };
  }
  function audit(tx, schoolId, actorId, action, recordId) {
    tx.set(db.collection('health_audit').doc(), { schoolId, actorId, action, recordId, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  }
  return {
    createClinicVisit: onCall(async (request) => {
      const user = await actor(request); const visit = request.data?.visit || {};
      if (visit.schoolId !== user.schoolId || !String(visit.studentId || '').trim() || !String(visit.reason || '').trim()) throw new HttpsError('invalid-argument', 'The visit is incomplete.');
      const id = String(visit.id || db.collection('clinic_visits').doc().id);
      const ref = db.collection('clinic_visits').doc(id);
      await db.runTransaction(async (tx) => {
        if ((await tx.get(ref)).exists) return; // idempotent retry
        tx.set(ref, { ...visit, id, schoolId: user.schoolId, recordedBy: user.uid, status: 'completed', completedAt: admin.firestore.FieldValue.serverTimestamp(), createdAt: admin.firestore.FieldValue.serverTimestamp() });
        audit(tx, user.schoolId, user.uid, 'clinic_visit.created', id);
      });
      return { id, status: 'completed' };
    }),
    dispenseMedicalItem: onCall(async (request) => {
      const user = await actor(request); const data = request.data || {}; const quantity = Number(data.quantity);
      if (!Number.isInteger(quantity) || quantity <= 0 || !data.itemId || !data.visitId) throw new HttpsError('invalid-argument', 'A visit, item, and positive quantity are required.');
      const item = db.collection('medical_inventory').doc(String(data.itemId)); const visit = db.collection('clinic_visits').doc(String(data.visitId));
      const expectedStudentId = String(data.studentId || '').trim();
      await db.runTransaction(async (tx) => {
        const [itemSnap, visitSnap] = await Promise.all([tx.get(item), tx.get(visit)]);
        if (!itemSnap.exists || !visitSnap.exists || itemSnap.data().schoolId !== user.schoolId || visitSnap.data().schoolId !== user.schoolId) throw new HttpsError('permission-denied', 'The requested record is outside your school.');
        // A dispense must be attributable to a learner. The visit's own
        // studentId is the source of truth; if the caller names a student it
        // must match, so a stale/confused client can never charge stock
        // against the wrong learner's visit.
        const visitStudentId = String(visitSnap.data().studentId || '').trim();
        if (!visitStudentId) throw new HttpsError('failed-precondition', 'This visit is not linked to a learner.');
        if (expectedStudentId && expectedStudentId !== visitStudentId) throw new HttpsError('failed-precondition', 'The visit does not belong to that learner.');
        if (!['in_progress', 'completed'].includes(visitSnap.data().status || 'completed')) throw new HttpsError('failed-precondition', 'Items may only be dispensed for an active or completed visit.');
        const remaining = Number(itemSnap.data().quantity || 0) - quantity;
        if (remaining < 0) throw new HttpsError('failed-precondition', 'Insufficient stock.');
        tx.update(item, { quantity: remaining, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
        const movement = db.collection('medical_inventory_movements').doc();
        tx.set(movement, { schoolId: user.schoolId, itemId: item.id, visitId: visit.id, studentId: visitStudentId, quantity, type: 'dispensed', recordedBy: user.uid, createdAt: admin.firestore.FieldValue.serverTimestamp() });
        audit(tx, user.schoolId, user.uid, 'medical_inventory.dispensed', movement.id);
      });
      return { ok: true };
    }),
  };
};
