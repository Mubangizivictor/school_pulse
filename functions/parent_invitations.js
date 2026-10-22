/**
 * Verified, time-limited parent sign-in invitations + parent-link management.
 *
 * Ports the staff verified-invitation model (index.js issueStaffInvitation /
 * createStaffInvitation / cancelStaffInvitation) to the parent side. The
 * legacy `createParentAccessCode` path in index.js still mints a raw one-time
 * code (kept as a manual-share fallback); these callables layer a verified,
 * mailbox-proving invitation on top of an existing
 * `parent_access_code_invites` doc and mirror a client-readable
 * `invitationStatus` / `invitationSentAt` / `invitationCanResendAt` back onto
 * that doc so `listParentAccessInvites` can render status chips and gate the
 * resend button.
 *
 * All callables here:
 *  - require request.auth and a role in PARENT_INVITE_ADMIN_ROLES
 *    (director, headTeacher, deputyHead, schoolAdmin, admissions, registrar),
 *    except updateParentInvitationDetails / unlink which require schoolAdmin;
 *  - resolve the caller's schoolId from their own users/{uid} doc and reject
 *    any target whose schoolId differs (generic "not found" so ids in other
 *    tenants cannot be probed);
 *  - write an audit_logs entry (module: "parent_access").
 *
 * The invitation status collection `parent_invitations/{id}` is
 * `allow read, write: if false` in firestore.rules - only this Admin-SDK
 * path writes it, and the client reads status via the mirror fields on
 * `parent_access_code_invites` (surfaced through listParentAccessInvites).
 *
 * Factory style matches the other index.js sub-modules:
 *   Object.assign(exports, require("./parent_invitations")({ admin, onCall, HttpsError, enqueueTransactionalEmail }));
 */

const PARENT_INVITE_ADMIN_ROLES = new Set([
  "director", "headTeacher", "deputyHead", "schoolAdmin", "admissions", "registrar",
]);

// Mirrors STAFF_INVITATION_RESEND_COOLDOWN_MS / STAFF_INVITATION_TTL_MS in
// index.js. Kept in sync deliberately - parent and staff invitations share
// the same "60s between sends, valid 7 days" contract.
const PARENT_INVITATION_RESEND_COOLDOWN_MS = 60 * 1000;
const PARENT_INVITATION_TTL_MS = 7 * 24 * 60 * 60 * 1000;

module.exports = ({ admin, onCall, HttpsError, enqueueTransactionalEmail }) => {
  const db = () => admin.firestore();
  const FieldValue = admin.firestore.FieldValue;
  const Timestamp = admin.firestore.Timestamp;

  function rolesOf(data) {
    return Array.isArray(data.roles) ? data.roles : (data.role ? [data.role] : []);
  }

  async function requireParentInviteAdmin(request, { schoolAdminOnly = false } = {}) {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in to manage parent access.");
    }
    const snap = await db().collection("users").doc(request.auth.uid).get();
    const data = snap.exists ? snap.data() : {};
    const roles = rolesOf(data);
    const ok = schoolAdminOnly
      ? roles.includes("schoolAdmin")
      : roles.some((r) => PARENT_INVITE_ADMIN_ROLES.has(r));
    if (!ok) {
      throw new HttpsError(
        "permission-denied",
        schoolAdminOnly
          ? "Only a school admin may perform this action."
          : "You do not have permission to manage parent access.",
      );
    }
    const schoolId = String(data.schoolId || "");
    if (!schoolId) {
      throw new HttpsError("failed-precondition", "Your account is not assigned to a school.");
    }
    return { data, roles, schoolId };
  }

  // Loads the parent_access_code_invites doc and enforces tenant isolation.
  async function loadInvite(inviteId, schoolId) {
    const id = String(inviteId || "").trim();
    if (!id) throw new HttpsError("invalid-argument", "An invitation id is required.");
    const ref = db().collection("parent_access_code_invites").doc(id);
    const snap = await ref.get();
    if (!snap.exists || String(snap.data().schoolId || "") !== schoolId) {
      // Same generic denial for missing vs cross-tenant so ids elsewhere
      // cannot be enumerated.
      throw new HttpsError("not-found", "Parent record not found.");
    }
    return { ref, data: snap.data() };
  }

  function maskEmail(value) {
    const s = String(value || "").trim();
    const at = s.indexOf("@");
    if (at < 1) return "";
    const name = s.slice(0, at);
    const domain = s.slice(at);
    const head = name.length <= 2 ? name[0] : name.slice(0, 2);
    return `${head}${"*".repeat(Math.max(1, name.length - head.length))}${domain}`;
  }

  function maskPhone(value) {
    const digits = String(value || "").replace(/\D/g, "");
    if (digits.length < 4) return "***";
    return `***${digits.slice(-4)}`;
  }

  function normalizeEmail(value) {
    const s = String(value || "").trim().toLowerCase();
    if (!s) return null;
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(s)) {
      throw new HttpsError("invalid-argument", "Enter a valid email address.");
    }
    return s;
  }

  function normalizePhone(value) {
    const s = String(value || "").replace(/\s/g, "");
    if (!/^\+\d{8,15}$/.test(s)) {
      throw new HttpsError("invalid-argument", "Enter a valid phone number in international format.");
    }
    return s;
  }

  async function auditParentAccess({ schoolId, actorId, action, targetId, extra = {} }) {
    await db().collection("audit_logs").add({
      schoolId,
      actorId,
      module: "parent_access",
      action,
      targetType: "parent_access_invite",
      targetId,
      ...extra,
      createdAt: FieldValue.serverTimestamp(),
    });
  }

  /**
   * Issues (or reissues) a verified invitation for an existing parent record.
   * Prefers email (Firebase Auth-independent transactional email carrying the
   * one-time code + a link); when no email is on file the caller must fall
   * back to sharing the raw code from createParentAccessCode manually, and
   * this returns { delivered: false }.
   *
   * Idempotent by inviteId: repeated calls within the cooldown are rejected
   * with resource-exhausted; outside it, a fresh parent_invitations doc is
   * written and the mirror fields updated.
   */
  async function issueParentInvitation({ inviteRef, inviteData, actorUid, schoolId, rawCode }) {
    const invitationsRef = db().collection("parent_invitations");
    const latest = await invitationsRef
      .where("schoolId", "==", schoolId)
      .where("parentInviteId", "==", inviteRef.id)
      .orderBy("createdAt", "desc")
      .limit(1)
      .get();

    const now = Date.now();
    if (!latest.empty) {
      const last = latest.docs[0].data();
      const lastMs = last.createdAt && last.createdAt.toMillis ? last.createdAt.toMillis() : 0;
      if (last.status !== "cancelled" && now - lastMs < PARENT_INVITATION_RESEND_COOLDOWN_MS) {
        throw new HttpsError("resource-exhausted", "Please wait before resending this invitation.");
      }
    }

    const email = inviteData.email ? String(inviteData.email).trim().toLowerCase() : null;
    const expiresAt = Timestamp.fromMillis(now + PARENT_INVITATION_TTL_MS);
    const canResendAt = Timestamp.fromMillis(now + PARENT_INVITATION_RESEND_COOLDOWN_MS);
    const recordRef = invitationsRef.doc();

    const schoolSnap = await db().collection("schools").doc(schoolId).get();
    const schoolName = schoolSnap.exists ? (schoolSnap.data().name || "") : "";

    let deliveryStatus = "sent";
    let delivered = true;
    if (email && enqueueTransactionalEmail) {
      try {
        await enqueueTransactionalEmail({
          eventId: `parent_invite_${recordRef.id}`,
          templateId: "parent_account_created",
          to: email,
          data: {
            schoolName,
            parentName: inviteData.parentName || "",
            code: rawCode || "",
            learnerCount: Array.isArray(inviteData.learnerIds) ? inviteData.learnerIds.length : 0,
          },
        });
      } catch (err) {
        console.error("parent invitation email enqueue failed", inviteRef.id, err);
        deliveryStatus = "failed";
      }
    } else {
      // No email on file - the admin shares the raw code out of band.
      deliveryStatus = "pending_manual";
      delivered = false;
    }

    await recordRef.set({
      schoolId,
      parentInviteId: inviteRef.id,
      channel: email ? "email" : "manual",
      maskedTarget: email ? maskEmail(email) : maskPhone(inviteData.phoneNumber),
      status: deliveryStatus,
      createdBy: actorUid,
      createdAt: FieldValue.serverTimestamp(),
      expiresAt,
    });

    await inviteRef.set({
      invitationId: recordRef.id,
      invitationStatus: deliveryStatus,
      invitationChannel: email ? "email" : "manual",
      invitationSentAt: FieldValue.serverTimestamp(),
      invitationCanResendAt: canResendAt,
      invitationExpiresAt: expiresAt,
    }, { merge: true });

    return {
      invitationId: recordRef.id,
      status: deliveryStatus,
      delivered,
      canResendAt: canResendAt.toMillis(),
      expiresAt: expiresAt.toMillis(),
    };
  }

  return {
    /**
     * (Re)send a verified invitation for an existing parent_access_code_invites
     * doc. `rawCode` (the one-time code from createParentAccessCode) may be
     * passed by the client immediately after creation so the email carries it;
     * on a later standalone resend the client will not have it and the email
     * omits it (the parent must use the code they already received, or the
     * admin reallocates).
     */
    createParentInvitation: onCall(async (request) => {
      const { schoolId, data: actor } = await requireParentInviteAdmin(request);
      const { inviteId, rawCode } = request.data || {};
      const { ref, data } = await loadInvite(inviteId, schoolId);
      if (data.status === "revoked") {
        throw new HttpsError("failed-precondition", "This parent access has been revoked.");
      }

      const result = await issueParentInvitation({
        inviteRef: ref,
        inviteData: data,
        actorUid: request.auth.uid,
        schoolId,
        rawCode: typeof rawCode === "string" ? rawCode : null,
      });

      await auditParentAccess({
        schoolId,
        actorId: request.auth.uid,
        action: result.delivered ? "invitation_sent" : "invitation_prepared_manual",
        targetId: ref.id,
        extra: { invitationId: result.invitationId, actorRole: rolesOf(actor)[0] || null },
      });

      return result;
    }),

    /** Cancel the live invitation for a parent record without revoking the
     * underlying link/code (use revokeParentAccessCode for that). */
    cancelParentInvitation: onCall(async (request) => {
      const { schoolId } = await requireParentInviteAdmin(request);
      const { inviteId } = request.data || {};
      const { ref, data } = await loadInvite(inviteId, schoolId);

      const invitationId = data.invitationId || null;
      if (invitationId) {
        await db().collection("parent_invitations").doc(invitationId).set(
          { status: "cancelled", cancelledAt: FieldValue.serverTimestamp(), cancelledBy: request.auth.uid },
          { merge: true },
        );
      }
      await ref.set({ invitationStatus: "cancelled" }, { merge: true });

      await auditParentAccess({
        schoolId,
        actorId: request.auth.uid,
        action: "invitation_cancelled",
        targetId: ref.id,
        extra: { invitationId },
      });

      return { status: "cancelled" };
    }),

    /** schoolAdmin-only: edit the guardian's own details (name / phone /
     * email / relationship) on an existing parent record. Phone/email are
     * re-normalised; a duplicate phone against another active record in the
     * same tenant is rejected. Audited. */
    updateParentInvitationDetails: onCall(async (request) => {
      const { schoolId } = await requireParentInviteAdmin(request, { schoolAdminOnly: true });
      const { inviteId, parentName, phoneNumber, email } = request.data || {};
      const { ref, data } = await loadInvite(inviteId, schoolId);
      if (data.status === "revoked") {
        throw new HttpsError("failed-precondition", "This parent access has been revoked.");
      }

      const update = {};
      if (parentName !== undefined) {
        const name = String(parentName || "").trim();
        if (!name) throw new HttpsError("invalid-argument", "A guardian name is required.");
        update.parentName = name;
      }
      if (phoneNumber !== undefined) {
        const phone = normalizePhone(phoneNumber);
        if (phone !== data.phoneNumber) {
          const dupe = await db().collection("parent_learner_links")
            .where("schoolId", "==", schoolId)
            .where("phoneNumber", "==", phone)
            .limit(1).get();
          const activeDupe = dupe.docs.some((d) => d.data().status !== "revoked" && d.data().parentInviteId !== ref.id);
          if (activeDupe) {
            throw new HttpsError("already-exists", "Another parent with this phone number is already linked.");
          }
        }
        update.phoneNumber = phone;
      }
      if (email !== undefined) {
        update.email = email === null || email === "" ? FieldValue.delete() : normalizeEmail(email);
      }
      if (Object.keys(update).length === 0) {
        throw new HttpsError("invalid-argument", "No changes were provided.");
      }

      await ref.set(update, { merge: true });
      // Keep the phone on any active parent_learner_links in sync.
      if (update.phoneNumber) {
        const links = await db().collection("parent_learner_links")
          .where("schoolId", "==", schoolId)
          .where("parentInviteId", "==", ref.id).get();
        const batch = db().batch();
        links.docs.forEach((d) => {
          if (d.data().status !== "revoked") batch.set(d.ref, { phoneNumber: update.phoneNumber }, { merge: true });
        });
        await batch.commit();
      }

      await auditParentAccess({
        schoolId,
        actorId: request.auth.uid,
        action: "details_updated",
        targetId: ref.id,
        extra: { fields: Object.keys(update) },
      });

      return { success: true };
    }),

    /** Add one or more learner links to an EXISTING parent record instead of
     * creating a duplicate parent. Used by the Link Parent flow's duplicate
     * detection ("link to existing parent"). Enforces the tenant's
     * configurable guardian cap per learner and rejects a learner already
     * linked to this parent. Six-role gated (initial-link semantics, same as
     * createParentAccessCode). */
    linkLearnersToExistingParent: onCall(async (request) => {
      const { schoolId } = await requireParentInviteAdmin(request);
      const { inviteId, learners } = request.data || {};
      const { ref, data } = await loadInvite(inviteId, schoolId);
      if (data.status === "revoked") {
        throw new HttpsError("failed-precondition", "This parent access has been revoked.");
      }
      if (!Array.isArray(learners) || !learners.length) {
        throw new HttpsError("invalid-argument", "At least one learner is required.");
      }
      const learnerIds = [...new Set(learners.map((l) => String(l.studentId || "")).filter(Boolean))];
      if (learnerIds.length !== learners.length) {
        throw new HttpsError("invalid-argument", "Each learner may be linked once.");
      }

      // Resolve the tenant's configurable guardian cap (mirrors index.js
      // resolveMaxGuardians; duplicated here to keep this module standalone).
      let maxGuardians = 2;
      try {
        const policy = await db().collection("people_policies").doc(schoolId).get();
        const v = Number(policy.exists ? policy.data().maxStandardGuardians : null);
        if (Number.isInteger(v) && v >= 1 && v <= 10) maxGuardians = v;
      } catch (err) {
        console.error("linkLearnersToExistingParent: policy read failed", schoolId, err);
      }

      const students = await Promise.all(learnerIds.map((id) => db().collection("students").doc(id).get()));
      if (students.some((s) => !s.exists || s.data().schoolId !== schoolId)) {
        throw new HttpsError("permission-denied", "One or more learners are unavailable.");
      }

      const phone = String(data.phoneNumber || "");
      const created = await db().runTransaction(async (tx) => {
        const out = [];
        for (const learner of learners) {
          const studentId = String(learner.studentId);
          const links = await tx.get(
            db().collection("parent_learner_links").where("schoolId", "==", schoolId).where("studentId", "==", studentId),
          );
          const active = links.docs.filter((d) => d.data().status !== "revoked");
          if (active.some((d) => d.data().phoneNumber === phone)) {
            throw new HttpsError("already-exists", "This parent is already linked to one of the selected learners.");
          }
          if (active.length >= maxGuardians) {
            throw new HttpsError("failed-precondition", `A learner can have a maximum of ${maxGuardians} parents.`);
          }
          const linkRef = db().collection("parent_learner_links").doc();
          tx.set(linkRef, {
            schoolId,
            studentId,
            parentInviteId: ref.id,
            phoneNumber: phone,
            relationship: String(learner.relationship || "Guardian"),
            isPrimaryContact: learner.isPrimaryContact === true,
            status: "pending",
            linkType: "initial",
            createdBy: request.auth.uid,
            createdAt: FieldValue.serverTimestamp(),
          });
          out.push({ studentId, linkId: linkRef.id });
        }
        // Extend the invite's denormalised learner arrays.
        const nextIds = [...new Set([...(data.learnerIds || []), ...learnerIds])];
        const nextRels = [
          ...(data.learnerRelationships || []),
          ...learners.map((l) => ({ studentId: String(l.studentId), relationship: String(l.relationship || "Guardian") })),
        ];
        tx.set(ref, { learnerIds: nextIds, learnerRelationships: nextRels }, { merge: true });
        return out;
      });

      await auditParentAccess({
        schoolId,
        actorId: request.auth.uid,
        action: "learners_linked",
        targetId: ref.id,
        extra: { learnerIds },
      });

      return { success: true, links: created };
    }),

    /** Admin-gated, tenant-scoped read of the immutable parent_link_audit_log
     * (collection is `allow read, write: if false`, so a callable is the only
     * read path). Filter by inviteId (resolves the record's learners) or a
     * single studentId. */
    listParentLinkAudit: onCall(async (request) => {
      const { schoolId } = await requireParentInviteAdmin(request);
      const { inviteId, studentId } = request.data || {};

      let studentIds = [];
      if (studentId) {
        studentIds = [String(studentId)];
      } else if (inviteId) {
        const { data } = await loadInvite(inviteId, schoolId);
        studentIds = Array.isArray(data.learnerIds) ? data.learnerIds.map(String) : [];
      } else {
        throw new HttpsError("invalid-argument", "inviteId or studentId is required.");
      }
      if (!studentIds.length) return { entries: [] };

      // Firestore `in` supports up to 30 values; parent records never link
      // that many learners, but chunk defensively.
      const chunks = [];
      for (let i = 0; i < studentIds.length; i += 10) chunks.push(studentIds.slice(i, i + 10));
      const results = await Promise.all(chunks.map((chunk) =>
        db().collection("parent_link_audit_log")
          .where("schoolId", "==", schoolId)
          .where("studentId", "in", chunk)
          .get(),
      ));
      const entries = results.flatMap((snap) => snap.docs.map((d) => {
        const e = d.data();
        return {
          id: d.id,
          action: e.action || null,
          actorRole: e.actorRole || null,
          studentId: e.studentId || null,
          reason: e.reason || "",
          oldLink: e.oldLink || null,
          newLink: e.newLink || null,
          createdAt: e.createdAt?.toMillis?.() ?? null,
        };
      }));
      entries.sort((a, b) => (b.createdAt || 0) - (a.createdAt || 0));
      return { entries };
    }),
  };
};

module.exports.PARENT_INVITATION_RESEND_COOLDOWN_MS = PARENT_INVITATION_RESEND_COOLDOWN_MS;
module.exports.PARENT_INVITATION_TTL_MS = PARENT_INVITATION_TTL_MS;
module.exports.PARENT_INVITE_ADMIN_ROLES = PARENT_INVITE_ADMIN_ROLES;
