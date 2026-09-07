/**
 * Maintains schools/{schoolId}/meta/admin_count, a small counter of how many
 * ACTIVE staff hold at least one admin-console role (director, headTeacher,
 * schoolAdmin - kept in sync with ADMIN_ROLES in index.js and
 * UserRoleDisplay.adminRoles on the client). Firestore rules can't cheaply
 * aggregate "how many other admins exist" per write, so this trigger keeps a
 * running count that firestore.rules reads instead - see the users/{uid}
 * update rule's admin-lockout check. The client-side guard
 * (StaffAdminLockoutGuard) gives immediate UI feedback; this is the
 * server-side backstop that a direct write or compromised client can't
 * bypass.
 *
 * Deliberately counts by uid, not by role - a user with two admin roles
 * still only occupies one "admin seat".
 */
module.exports = ({ admin, onDocumentWritten }) => {
  const ADMIN_ROLES = ["director", "headTeacher", "schoolAdmin"];

  function isCountedAdmin(data) {
    if (!data) return false;
    if (data.isActive === false) return false;
    const roles = Array.isArray(data.roles) ? data.roles : [];
    const legacyRole = typeof data.role === "string" ? [data.role] : [];
    return [...roles, ...legacyRole].some((r) => ADMIN_ROLES.includes(r));
  }

  const onStaffAdminStatusChanged = onDocumentWritten(
    "users/{uid}",
    async (event) => {
      const before = event.data?.before?.data();
      const after = event.data?.after?.data();
      const wasAdmin = isCountedAdmin(before);
      const isAdmin = isCountedAdmin(after);
      if (wasAdmin === isAdmin) return;

      const schoolId = (after || before)?.schoolId;
      if (!schoolId) return;

      const delta = isAdmin ? 1 : -1;
      const counterRef = admin
        .firestore()
        .collection("schools")
        .doc(schoolId)
        .collection("meta")
        .doc("admin_count");

      await admin.firestore().runTransaction(async (tx) => {
        const snap = await tx.get(counterRef);
        const current = snap.exists && typeof snap.data().count === "number"
          ? snap.data().count
          : 0;
        const next = Math.max(0, current + delta);
        tx.set(
          counterRef,
          { count: next, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
          { merge: true },
        );
      });
    },
  );

  return { onStaffAdminStatusChanged };
};
