const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { randomBytes } = require("crypto");
const admin = require("firebase-admin");
const { requirePlatformOwner, OwnerAuthorizationError } = require("./vendor/owner-auth");

function isStaffRole(role) {
  return role && role !== "parent" && role !== "student";
}

async function requireStaffCaller(auth) {
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
  const db = admin.firestore();
  const callerDoc = await db.collection("users").doc(auth.uid).get();
  const callerData = callerDoc.exists ? callerDoc.data() : {};
  if (!isStaffRole(callerData.role)) {
    throw new HttpsError("permission-denied", "Only staff can manage student credentials.");
  }
  const schoolId = callerData.schoolId || null;
  if (!schoolId) {
    throw new HttpsError("failed-precondition", "Your account is not assigned to a school.");
  }
  return { db, schoolId, uid: auth.uid };
}

const QR_PREFIX = "SPQR1";

function mintQrToken() {
  const token = randomBytes(32).toString("base64url");
  return `${QR_PREFIX}.${token}`;
}

// Never store enough of a credential value in a history/audit row to make it
// usable - just enough to distinguish "which card/token" was involved for
// staff who already have legitimate credential-management access.
function maskCredentialValue(value) {
  if (typeof value !== "string" || value.length === 0) return null;
  const tail = value.slice(-4);
  return `••••${tail}`;
}

/**
 * Appends one append-only history row (schools/{schoolId}/credential_history)
 * and one audit_events row (institutions/{schoolId}/audit_events) inside the
 * SAME transaction as the credential mutation it describes, so the record of
 * "what happened" can never drift from - or be lost relative to - the state
 * change itself. Mirrors enrollment_audit.js's recordEnrollmentAuditEvent
 * trust model (actor/timestamp always server-derived) without a second
 * round-trip through a separate callable.
 */
function recordCredentialLifecycleEvent(tx, db, {
  schoolId, studentId, identityDocumentId, credentialType, credentialValue,
  action, auditAction, reason, actorUid,
}) {
  const now = admin.firestore.FieldValue.serverTimestamp();

  const historyRef = db.collection("schools").doc(schoolId)
    .collection("credential_history").doc();
  tx.set(historyRef, {
    schoolId,
    studentId,
    identityDocumentId,
    credentialType,
    credentialValueMasked: maskCredentialValue(credentialValue),
    action,
    reason: reason || null,
    actorId: actorUid,
    createdAt: now,
  });

  const auditRef = db.collection("institutions").doc(schoolId)
    .collection("audit_events").doc();
  tx.set(auditRef, {
    auditEventId: auditRef.id,
    institutionId: schoolId,
    moduleKey: "student_identity",
    eventType: "Identity",
    action: auditAction,
    status: "success",
    sensitivity: "normal",
    source: "cloud_function",
    actorId: actorUid,
    targetType: "student",
    targetId: studentId,
    correlationId: studentId,
    reason: reason || null,
    metadataSafe: { credentialType, credentialValueMasked: maskCredentialValue(credentialValue) },
    createdAt: now,
  });
}

async function reserveSequence(tx, db, schoolId) {
  const counterRef = db.collection("schools").doc(schoolId)
    .collection("counters").doc("studentSequence");
  const counterSnap = await tx.get(counterRef);
  const current = counterSnap.exists ? Number(counterSnap.data().value || 0) : 0;
  const next = current + 1;
  tx.set(counterRef, { value: next }, { merge: true });
  return next;
}

/**
 * Student documents are the canonical tenant source. Older
 * student_identities rows may contain an empty/stale schoolId from earlier
 * implementations; when the canonical Student has already been verified to
 * belong to this school, repair the identity row instead of rejecting it.
 */
async function issueIdentityInTransaction(tx, db, { studentId, schoolId, schoolPrefix }) {
  const studentRef = db.collection("students").doc(studentId);
  const identityQuery = db.collection("student_identities")
    .where("studentId", "==", studentId).limit(1);

  const studentSnap = await tx.get(studentRef);
  if (!studentSnap.exists) {
    return { skipped: true, reason: "student-not-found" };
  }
  const student = studentSnap.data() || {};
  if (student.schoolId !== schoolId) {
    return { skipped: true, reason: "school-mismatch" };
  }

  const existingSnap = await tx.get(identityQuery);
  if (!existingSnap.empty) {
    const doc = existingSnap.docs[0];
    const identity = doc.data() || {};
    if (identity.schoolId !== schoolId) {
      tx.set(doc.ref, {
        schoolId,
        studentId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    }
    return {
      identityDocumentId: doc.id,
      identity: { ...identity, studentId, schoolId },
      created: false,
    };
  }

  const sequence = await reserveSequence(tx, db, schoolId);
  const year = new Date().getFullYear();
  const uniqueSystemId = `SP-STUDENT-${randomBytes(8).toString("hex")}`;
  const schoolStudentId = `${schoolPrefix}${year}${String(sequence).padStart(6, "0")}`;
  const token = mintQrToken();
  const now = admin.firestore.FieldValue.serverTimestamp();

  const identityRef = db.collection("student_identities").doc();
  const identityData = {
    studentId,
    schoolId,
    uniqueSystemId,
    schoolStudentId,
    qrCodeData: token,
    nfcStatus: "unassigned",
    qrCredentialStatus: "active",
    issuedAt: now,
    createdAt: now,
    updatedAt: now,
  };
  tx.set(identityRef, identityData);

  const credentialRef = db.collection("schools").doc(schoolId)
    .collection("credentials").doc(token.split(".")[1]);
  tx.set(credentialRef, {
    credentialValue: token.split(".")[1],
    credentialType: "qr",
    identityId: studentId,
    identityType: "student",
    schoolId,
    status: "active",
    updatedAt: now,
    credentialVersion: 1,
    identityDocumentId: identityRef.id,
  });

  return { identityDocumentId: identityRef.id, identity: identityData, created: true };
}

exports.issueStudentIdentity = onCall(async (request) => {
  const { db, schoolId: callerSchoolId } = await requireStaffCaller(request.auth);
  const studentId = request.data?.studentId;
  const schoolPrefix = (request.data?.schoolPrefix || "SP").toUpperCase().slice(0, 8);

  if (typeof studentId !== "string" || !studentId) {
    throw new HttpsError("invalid-argument", "studentId is required.");
  }

  const result = await db.runTransaction(async (tx) => {
    const outcome = await issueIdentityInTransaction(tx, db, {
      studentId, schoolId: callerSchoolId, schoolPrefix,
    });
    if (outcome.skipped) {
      const message = outcome.reason === "student-not-found"
        ? "Student not found."
        : "Cannot issue an identity for a different school's student.";
      const code = outcome.reason === "student-not-found" ? "not-found" : "permission-denied";
      throw new HttpsError(code, message);
    }
    return outcome;
  });

  return result;
});

exports.regenerateStudentQrCredential = onCall(async (request) => {
  const { db, schoolId: callerSchoolId, uid } = await requireStaffCaller(request.auth);
  const studentId = request.data?.studentId;
  if (typeof studentId !== "string" || !studentId) {
    throw new HttpsError("invalid-argument", "studentId is required.");
  }

  const identityQuery = db.collection("student_identities")
    .where("studentId", "==", studentId).limit(1);

  const result = await db.runTransaction(async (tx) => {
    const studentRef = db.collection("students").doc(studentId);
    const studentSnap = await tx.get(studentRef);
    if (!studentSnap.exists) {
      throw new HttpsError("not-found", "Student not found.");
    }
    const student = studentSnap.data() || {};
    if (student.schoolId !== callerSchoolId) {
      throw new HttpsError("permission-denied", "Cannot modify a student from a different school.");
    }

    const snap = await tx.get(identityQuery);
    if (snap.empty) {
      throw new HttpsError("not-found", "Identity not found.");
    }
    const doc = snap.docs[0];
    const identity = doc.data() || {};

    const now = admin.firestore.FieldValue.serverTimestamp();
    if (identity.schoolId !== callerSchoolId) {
      tx.set(doc.ref, { schoolId: callerSchoolId, studentId, updatedAt: now }, { merge: true });
    }

    const oldToken = typeof identity.qrCodeData === "string" ? identity.qrCodeData.split(".")[1] : null;
    if (oldToken) {
      const oldCredentialRef = db.collection("schools").doc(callerSchoolId)
        .collection("credentials").doc(oldToken);
      tx.set(oldCredentialRef, { status: "replaced", updatedAt: now }, { merge: true });
    }

    const newToken = mintQrToken();
    tx.update(doc.ref, {
      qrCodeData: newToken,
      qrCredentialStatus: "active",
      schoolId: callerSchoolId,
      updatedAt: now,
    });

    const newCredentialRef = db.collection("schools").doc(callerSchoolId)
      .collection("credentials").doc(newToken.split(".")[1]);
    tx.set(newCredentialRef, {
      credentialValue: newToken.split(".")[1],
      credentialType: "qr",
      identityId: studentId,
      identityType: "student",
      schoolId: callerSchoolId,
      status: "active",
      updatedAt: now,
      credentialVersion: (identity.credentialVersion || 1) + 1,
      identityDocumentId: doc.id,
      replacesToken: oldToken || null,
    });

    recordCredentialLifecycleEvent(tx, db, {
      schoolId: callerSchoolId,
      studentId,
      identityDocumentId: doc.id,
      credentialType: "qr",
      credentialValue: newToken,
      action: "qr_replaced",
      auditAction: "identity_qr_replaced",
      actorUid: uid,
    });

    return { qrCodeData: newToken };
  });

  return result;
});

/**
 * Atomically binds a physical NFC UID to a canonical Student document.
 * Tenant authorization is based on users/{caller}.schoolId and the canonical
 * students/{studentId}.schoolId. student_identities.schoolId is legacy
 * metadata and is repaired when stale; it is never allowed to override a
 * verified Student document.
 */
exports.assignNfcCredential = onCall(async (request) => {
  const { db, schoolId: callerSchoolId, uid } = await requireStaffCaller(request.auth);
  const cardUid = request.data?.cardUid;
  const studentId = request.data?.studentId;

  if (typeof cardUid !== "string" || !cardUid.trim()) {
    throw new HttpsError("invalid-argument", "cardUid is required.");
  }
  if (typeof studentId !== "string" || !studentId) {
    throw new HttpsError("invalid-argument", "studentId is required.");
  }
  const normalizedCardUid = cardUid.trim();

  const identityQuery = db.collection("student_identities")
    .where("studentId", "==", studentId).limit(1);

  const result = await db.runTransaction(async (tx) => {
    const studentRef = db.collection("students").doc(studentId);
    const studentSnap = await tx.get(studentRef);
    if (!studentSnap.exists) {
      throw new HttpsError("not-found", "Student not found.");
    }
    const student = studentSnap.data() || {};
    if (student.schoolId !== callerSchoolId) {
      throw new HttpsError("permission-denied", "Cannot assign a card for a different school's student.");
    }

    const identitySnap = await tx.get(identityQuery);
    if (identitySnap.empty) {
      throw new HttpsError("not-found", "No identity found for this student.");
    }
    const identityDoc = identitySnap.docs[0];
    const identity = identityDoc.data() || {};

    const credentialRef = db.collection("schools").doc(callerSchoolId)
      .collection("credentials").doc(normalizedCardUid);
    const credentialSnap = await tx.get(credentialRef);
    const now = admin.firestore.FieldValue.serverTimestamp();

    if (credentialSnap.exists) {
      const existing = credentialSnap.data() || {};
      const belongsToThisStudent = existing.identityId === studentId
        || existing.identityId === identity.uniqueSystemId;
      if (existing.status === "active" && !belongsToThisStudent) {
        throw new HttpsError("already-exists", "This card is already registered to another identity.", {
          conflictingIdentityId: existing.identityId,
          conflictingIdentityType: existing.identityType,
        });
      }
    }

    tx.set(credentialRef, {
      credentialValue: normalizedCardUid,
      credentialType: "nfc",
      identityId: studentId,
      identityType: "student",
      schoolId: callerSchoolId,
      status: "active",
      updatedAt: now,
      credentialVersion: (credentialSnap.exists ? (credentialSnap.data().credentialVersion || 1) + 1 : 1),
      identityDocumentId: identityDoc.id,
      assignedBy: uid,
    }, { merge: true });

    const revocationRef = db.collection("schools").doc(callerSchoolId)
      .collection("revoked_credentials").doc(normalizedCardUid);
    tx.delete(revocationRef);

    // Repair legacy tenant metadata and mark the student card ACTIVE in the
    // same transaction that persists the credential. This is why the UI can
    // reliably stop showing "Unassigned" after a successful assignment.
    tx.set(identityDoc.ref, {
      studentId,
      schoolId: callerSchoolId,
      nfcStatus: "active",
      updatedAt: now,
    }, { merge: true });

    recordCredentialLifecycleEvent(tx, db, {
      schoolId: callerSchoolId,
      studentId,
      identityDocumentId: identityDoc.id,
      credentialType: "nfc",
      credentialValue: normalizedCardUid,
      action: "nfc_assigned",
      auditAction: "enrollment_nfc_registered",
      actorUid: uid,
    });

    return { cardUid: normalizedCardUid, identityId: studentId, status: "active" };
  });

  return result;
});

/**
 * Revokes the currently-assigned NFC card and atomically assigns a
 * replacement to the same student - the "lost/stolen/damaged card" flow.
 * A replace is NOT the same as a bare revoke: the old card is marked
 * "replaced" (not denylisted in revoked_credentials), since the intent is a
 * routine card swap, not a security incident requiring the old UID to be
 * actively rejected if it is ever scanned again by mistake.
 */
exports.replaceNfcCredential = onCall(async (request) => {
  const { db, schoolId: callerSchoolId, uid } = await requireStaffCaller(request.auth);
  const cardUid = request.data?.cardUid;
  const newCardUid = request.data?.newCardUid;
  const studentId = request.data?.studentId;
  const reason = typeof request.data?.reason === "string" ? request.data.reason.trim().slice(0, 200) : "";

  if (typeof cardUid !== "string" || !cardUid.trim()) {
    throw new HttpsError("invalid-argument", "cardUid is required.");
  }
  if (typeof newCardUid !== "string" || !newCardUid.trim()) {
    throw new HttpsError("invalid-argument", "newCardUid is required.");
  }
  if (typeof studentId !== "string" || !studentId) {
    throw new HttpsError("invalid-argument", "studentId is required.");
  }
  const oldUid = cardUid.trim();
  const newUid = newCardUid.trim();

  const identityQuery = db.collection("student_identities")
    .where("studentId", "==", studentId).limit(1);

  const result = await db.runTransaction(async (tx) => {
    const studentRef = db.collection("students").doc(studentId);
    const studentSnap = await tx.get(studentRef);
    if (!studentSnap.exists) {
      throw new HttpsError("not-found", "Student not found.");
    }
    const student = studentSnap.data() || {};
    if (student.schoolId !== callerSchoolId) {
      throw new HttpsError("permission-denied", "Cannot replace a card for a different school's student.");
    }

    const identitySnap = await tx.get(identityQuery);
    if (identitySnap.empty) {
      throw new HttpsError("not-found", "No identity found for this student.");
    }
    const identityDoc = identitySnap.docs[0];
    const identity = identityDoc.data() || {};

    const oldCredentialRef = db.collection("schools").doc(callerSchoolId)
      .collection("credentials").doc(oldUid);
    const oldCredentialSnap = await tx.get(oldCredentialRef);
    if (!oldCredentialSnap.exists) {
      throw new HttpsError("not-found", "The card being replaced is not on file.");
    }
    const oldCredential = oldCredentialSnap.data() || {};
    const belongsToThisStudent = oldCredential.identityId === studentId
      || oldCredential.identityId === identity.uniqueSystemId;
    if (!belongsToThisStudent) {
      throw new HttpsError("failed-precondition", "This card is not assigned to this student.");
    }

    const newCredentialRef = db.collection("schools").doc(callerSchoolId)
      .collection("credentials").doc(newUid);
    const newCredentialSnap = await tx.get(newCredentialRef);
    if (newCredentialSnap.exists) {
      const existingNew = newCredentialSnap.data() || {};
      const newBelongsToThisStudent = existingNew.identityId === studentId
        || existingNew.identityId === identity.uniqueSystemId;
      if (existingNew.status === "active" && !newBelongsToThisStudent) {
        throw new HttpsError("already-exists", "The replacement card is already registered to another identity.", {
          conflictingIdentityId: existingNew.identityId,
          conflictingIdentityType: existingNew.identityType,
        });
      }
    }

    const now = admin.firestore.FieldValue.serverTimestamp();

    tx.set(oldCredentialRef, { status: "replaced", updatedAt: now }, { merge: true });

    tx.set(newCredentialRef, {
      credentialValue: newUid,
      credentialType: "nfc",
      identityId: studentId,
      identityType: "student",
      schoolId: callerSchoolId,
      status: "active",
      updatedAt: now,
      credentialVersion: (newCredentialSnap.exists ? (newCredentialSnap.data().credentialVersion || 1) + 1 : 1),
      identityDocumentId: identityDoc.id,
      assignedBy: uid,
      replacesCredentialValue: oldUid,
    }, { merge: true });

    tx.set(identityDoc.ref, {
      studentId,
      schoolId: callerSchoolId,
      nfcStatus: "active",
      updatedAt: now,
    }, { merge: true });

    recordCredentialLifecycleEvent(tx, db, {
      schoolId: callerSchoolId,
      studentId,
      identityDocumentId: identityDoc.id,
      credentialType: "nfc",
      credentialValue: newUid,
      action: "nfc_replaced",
      auditAction: "identity_nfc_replaced",
      reason,
      actorUid: uid,
    });

    return { cardUid: newUid, identityId: studentId, status: "active" };
  });

  return result;
});

/**
 * Revokes an NFC card: marks the credential doc "revoked" and denylists the
 * physical UID in revoked_credentials so IdentityResolver rejects it at scan
 * time even before any replacement is assigned. Used for lost/stolen/damaged
 * cards where the card must stop working immediately, as distinct from
 * replaceNfcCredential's routine swap.
 */
exports.revokeNfcCredential = onCall(async (request) => {
  const { db, schoolId: callerSchoolId, uid } = await requireStaffCaller(request.auth);
  const cardUid = request.data?.cardUid;
  const studentId = request.data?.studentId;
  const reason = typeof request.data?.reason === "string" ? request.data.reason.trim().slice(0, 200) : "";

  if (typeof cardUid !== "string" || !cardUid.trim()) {
    throw new HttpsError("invalid-argument", "cardUid is required.");
  }
  if (typeof studentId !== "string" || !studentId) {
    throw new HttpsError("invalid-argument", "studentId is required.");
  }
  const normalizedCardUid = cardUid.trim();

  const identityQuery = db.collection("student_identities")
    .where("studentId", "==", studentId).limit(1);

  const result = await db.runTransaction(async (tx) => {
    const studentRef = db.collection("students").doc(studentId);
    const studentSnap = await tx.get(studentRef);
    if (!studentSnap.exists) {
      throw new HttpsError("not-found", "Student not found.");
    }
    const student = studentSnap.data() || {};
    if (student.schoolId !== callerSchoolId) {
      throw new HttpsError("permission-denied", "Cannot revoke a card for a different school's student.");
    }

    const identitySnap = await tx.get(identityQuery);
    if (identitySnap.empty) {
      throw new HttpsError("not-found", "No identity found for this student.");
    }
    const identityDoc = identitySnap.docs[0];
    const identity = identityDoc.data() || {};

    const credentialRef = db.collection("schools").doc(callerSchoolId)
      .collection("credentials").doc(normalizedCardUid);
    const credentialSnap = await tx.get(credentialRef);
    if (!credentialSnap.exists) {
      throw new HttpsError("not-found", "This card is not on file.");
    }
    const credential = credentialSnap.data() || {};
    const belongsToThisStudent = credential.identityId === studentId
      || credential.identityId === identity.uniqueSystemId;
    if (!belongsToThisStudent) {
      throw new HttpsError("failed-precondition", "This card is not assigned to this student.");
    }

    const now = admin.firestore.FieldValue.serverTimestamp();

    tx.set(credentialRef, { status: "revoked", updatedAt: now }, { merge: true });

    const revocationRef = db.collection("schools").doc(callerSchoolId)
      .collection("revoked_credentials").doc(normalizedCardUid);
    tx.set(revocationRef, {
      credentialValue: normalizedCardUid,
      schoolId: callerSchoolId,
      revokedAt: now,
      reason: reason || null,
      revokedBy: uid,
    });

    tx.set(identityDoc.ref, {
      studentId,
      schoolId: callerSchoolId,
      nfcStatus: "revoked",
      updatedAt: now,
    }, { merge: true });

    recordCredentialLifecycleEvent(tx, db, {
      schoolId: callerSchoolId,
      studentId,
      identityDocumentId: identityDoc.id,
      credentialType: "nfc",
      credentialValue: normalizedCardUid,
      action: "nfc_revoked",
      auditAction: "identity_nfc_revoked",
      reason,
      actorUid: uid,
    });

    return { cardUid: normalizedCardUid, identityId: studentId, status: "revoked" };
  });

  return result;
});

/**
 * Reverses a revocation and restores the card to active for its existing
 * identity mapping - for correcting an accidental/investigative
 * deactivation. Fails if the card has no prior mapping to reactivate (it
 * must have been assigned and then revoked at some point).
 */
exports.reactivateNfcCredential = onCall(async (request) => {
  const { db, schoolId: callerSchoolId, uid } = await requireStaffCaller(request.auth);
  const cardUid = request.data?.cardUid;
  const studentId = request.data?.studentId;

  if (typeof cardUid !== "string" || !cardUid.trim()) {
    throw new HttpsError("invalid-argument", "cardUid is required.");
  }
  if (typeof studentId !== "string" || !studentId) {
    throw new HttpsError("invalid-argument", "studentId is required.");
  }
  const normalizedCardUid = cardUid.trim();

  const identityQuery = db.collection("student_identities")
    .where("studentId", "==", studentId).limit(1);

  const result = await db.runTransaction(async (tx) => {
    const studentRef = db.collection("students").doc(studentId);
    const studentSnap = await tx.get(studentRef);
    if (!studentSnap.exists) {
      throw new HttpsError("not-found", "Student not found.");
    }
    const student = studentSnap.data() || {};
    if (student.schoolId !== callerSchoolId) {
      throw new HttpsError("permission-denied", "Cannot reactivate a card for a different school's student.");
    }

    const identitySnap = await tx.get(identityQuery);
    if (identitySnap.empty) {
      throw new HttpsError("not-found", "No identity found for this student.");
    }
    const identityDoc = identitySnap.docs[0];
    const identity = identityDoc.data() || {};

    const credentialRef = db.collection("schools").doc(callerSchoolId)
      .collection("credentials").doc(normalizedCardUid);
    const credentialSnap = await tx.get(credentialRef);
    if (!credentialSnap.exists) {
      throw new HttpsError("failed-precondition", "No prior mapping found for this card - assign it instead.");
    }
    const credential = credentialSnap.data() || {};
    const belongsToThisStudent = credential.identityId === studentId
      || credential.identityId === identity.uniqueSystemId;
    if (!belongsToThisStudent) {
      throw new HttpsError("failed-precondition", "This card is not assigned to this student.");
    }
    if (credential.status !== "revoked") {
      throw new HttpsError("failed-precondition", "This card is not currently revoked.");
    }

    const now = admin.firestore.FieldValue.serverTimestamp();

    tx.set(credentialRef, { status: "active", updatedAt: now }, { merge: true });

    const revocationRef = db.collection("schools").doc(callerSchoolId)
      .collection("revoked_credentials").doc(normalizedCardUid);
    tx.delete(revocationRef);

    tx.set(identityDoc.ref, {
      studentId,
      schoolId: callerSchoolId,
      nfcStatus: "active",
      updatedAt: now,
    }, { merge: true });

    recordCredentialLifecycleEvent(tx, db, {
      schoolId: callerSchoolId,
      studentId,
      identityDocumentId: identityDoc.id,
      credentialType: "nfc",
      credentialValue: normalizedCardUid,
      action: "nfc_reactivated",
      auditAction: "identity_nfc_reactivated",
      actorUid: uid,
    });

    return { cardUid: normalizedCardUid, identityId: studentId, status: "active" };
  });

  return result;
});

exports.backfillStudentIdentities = onCall(async (request) => {
  const db = admin.firestore();
  try {
    await requirePlatformOwner(request, { db });
  } catch (error) {
    if (error instanceof OwnerAuthorizationError) {
      throw new HttpsError(error.code, error.message);
    }
    throw error;
  }

  const requestedSchoolId = request.data?.schoolId;
  const schoolPrefix = (request.data?.schoolPrefix || "SP").toUpperCase().slice(0, 8);

  // Only genuinely-enrolled students are in scope - an applicant or an
  // in-progress admission has no business being issued a permanent
  // studentCode/QR identity yet.
  const enrolledStatuses = new Set(["admitted", "enrollmentInProgress", "enrolled", "active"]);

  const schoolsSnap = requestedSchoolId
    ? await db.collection("schools").where(admin.firestore.FieldPath.documentId(), "==", requestedSchoolId).get()
    : await db.collection("schools").get();

  const results = [];
  for (const schoolDoc of schoolsSnap.docs) {
    const schoolId = schoolDoc.id;
    const runId = db.collection("institutions").doc(schoolId).collection("migration_reports").doc().id;
    const studentsSnap = await db.collection("students")
      .where("schoolId", "==", schoolId)
      .get();

    // Use studentId rather than identity.schoolId when detecting existing
    // identities because legacy identity tenant metadata may be stale.
    const existingIdentitiesSnap = await db.collection("student_identities").get();
    const studentIdsWithIdentity = new Set(
      existingIdentitiesSnap.docs.map((doc) => doc.data().studentId),
    );

    let issued = 0;
    let skippedExisting = 0;
    let skippedOther = 0;
    let skippedNotEnrolled = 0;
    let missingParentLink = 0;
    const backfilledStudents = [];
    const errors = [];

    for (const studentDoc of studentsSnap.docs) {
      const studentId = studentDoc.id;
      const student = studentDoc.data() || {};

      if (!enrolledStatuses.has(student.status)) {
        skippedNotEnrolled++;
        continue;
      }

      // Parent-link gap is reported, never synthesized - there is no safe
      // way to backfill a real guardian contact from nothing.
      const relationshipSnap = await db.collection("parent_student_relationships")
        .where("schoolId", "==", schoolId)
        .where("studentId", "==", studentId)
        .limit(1)
        .get();
      if (relationshipSnap.empty) {
        missingParentLink++;
      }

      if (studentIdsWithIdentity.has(studentId)) {
        skippedExisting++;
        continue;
      }
      try {
        const outcome = await db.runTransaction((tx) => issueIdentityInTransaction(tx, db, {
          studentId, schoolId, schoolPrefix,
        }));
        if (outcome.skipped) {
          skippedOther++;
        } else if (outcome.created) {
          issued++;
          backfilledStudents.push({
            studentId,
            fieldsBackfilled: ["studentCode", "qrReference", "student_identities"],
          });
        } else {
          skippedExisting++;
        }
      } catch (error) {
        console.error("BACKFILL_STUDENT_IDENTITY_FAILED", { schoolId, studentId, error: error.message });
        skippedOther++;
        errors.push({ studentId, message: error.message });
      }
    }

    const report = {
      runId,
      schoolId,
      requestedBy: request.auth?.uid || null,
      studentsScanned: studentsSnap.size,
      studentsInScope: studentsSnap.size - skippedNotEnrolled,
      skippedNotEnrolled,
      issued,
      skippedExisting,
      skippedOther,
      missingParentLinkFollowUp: missingParentLink,
      backfilledStudents,
      errors,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    await db.collection("institutions").doc(schoolId)
      .collection("migration_reports").doc(runId).set(report);

    results.push({
      schoolId, runId, studentsScanned: studentsSnap.size, issued, skippedExisting,
      skippedOther, skippedNotEnrolled, missingParentLinkFollowUp: missingParentLink,
    });
  }

  return { ok: true, schools: results };
});

/**
 * Resolve canonical and legacy student credentials. As with assignment,
 * students/{studentId}.schoolId is authoritative. A stale identity schoolId
 * is repaired only after the resolved Student is verified against the caller.
 */
exports.resolveStudentCredential = onCall(async (request) => {
  const { db, schoolId: callerSchoolId } = await requireStaffCaller(request.auth);
  const credentialValue = request.data?.credentialValue;
  if (typeof credentialValue !== "string" || !credentialValue.trim()) {
    throw new HttpsError("invalid-argument", "credentialValue is required.");
  }

  const credentialRef = db.collection("schools").doc(callerSchoolId)
    .collection("credentials").doc(credentialValue.trim());
  const credentialSnap = await credentialRef.get();
  if (!credentialSnap.exists) {
    return { found: false };
  }
  const credential = credentialSnap.data() || {};
  if (credential.identityType !== "student") {
    return { found: false };
  }

  const directStudentDoc = await db.collection("students").doc(credential.identityId).get();
  if (directStudentDoc.exists && directStudentDoc.data().schoolId === callerSchoolId) {
    return { found: true, studentId: directStudentDoc.id, migrated: false };
  }

  const identitySnap = await db.collection("student_identities")
    .where("uniqueSystemId", "==", credential.identityId).limit(1).get();
  if (identitySnap.empty) {
    return { found: false };
  }
  const identityDoc = identitySnap.docs[0];
  const identity = identityDoc.data() || {};

  const studentDoc = await db.collection("students").doc(identity.studentId).get();
  if (!studentDoc.exists || studentDoc.data().schoolId !== callerSchoolId) {
    return { found: false };
  }

  const now = admin.firestore.FieldValue.serverTimestamp();
  await Promise.all([
    credentialRef.set({
      identityId: identity.studentId,
      identityDocumentId: identityDoc.id,
      schoolId: callerSchoolId,
      updatedAt: now,
    }, { merge: true }),
    identityDoc.ref.set({
      studentId: identity.studentId,
      schoolId: callerSchoolId,
      updatedAt: now,
    }, { merge: true }),
  ]);

  return { found: true, studentId: identity.studentId, migrated: true };
});

// Excludes visually-ambiguous characters (0/O, 1/I/L) - these codes are read
// aloud/typed on a phone keypad by students and parents.
const ACCESS_CODE_ALPHABET = "23456789ABCDEFGHJKMNPQRSTUVWXYZ";

function generateAccessCode(prefix, length = 8) {
  let suffix = "";
  const bytes = randomBytes(length);
  for (let i = 0; i < length; i++) {
    suffix += ACCESS_CODE_ALPHABET[bytes[i] % ACCESS_CODE_ALPHABET.length];
  }
  return `${prefix}${suffix}`;
}

/**
 * Issues (or re-issues) a student's portal access code server-side. Doc ID
 * is the code itself, matching parent_access_codes, so the pre-login screen
 * can do a rule-safe direct get. No PIN is set here - the student proves the
 * code via completeStudentPinSetup on first login, matching the parent flow.
 */
exports.provisionStudentAccessCode = onCall(async (request) => {
  const { db, schoolId: callerSchoolId } = await requireStaffCaller(request.auth);
  const studentId = request.data?.studentId;
  if (typeof studentId !== "string" || !studentId) {
    throw new HttpsError("invalid-argument", "studentId is required.");
  }

  const studentSnap = await db.collection("students").doc(studentId).get();
  if (!studentSnap.exists) {
    throw new HttpsError("not-found", "Student not found.");
  }
  const student = studentSnap.data() || {};
  if (student.schoolId !== callerSchoolId) {
    throw new HttpsError("permission-denied", "Cannot provision portal access for a different school's student.");
  }

  const existingSnap = await db.collection("student_access_codes")
    .where("studentId", "==", studentId).limit(1).get();

  const now = admin.firestore.FieldValue.serverTimestamp();
  const codeRef = existingSnap.empty
    ? db.collection("student_access_codes").doc(generateAccessCode("S"))
    : existingSnap.docs[0].ref;

  const data = {
    studentCode: codeRef.id,
    schoolId: callerSchoolId,
    studentId,
    studentName: student.name || "",
    isActive: true,
    mustChangePin: true,
    updatedAt: now,
  };
  if (existingSnap.empty) {
    data.createdAt = now;
  }
  await codeRef.set(data, { merge: true });

  return { code: codeRef.id };
});

/**
 * Forces a student's next login to require a fresh PIN (admin "Reset PIN").
 * Clears the stored PIN and any lockout state rather than picking a new PIN
 * server-side, so no PIN value - old or new - ever needs to travel back to
 * the admin client.
 */
exports.resetStudentPin = onCall(async (request) => {
  const { db, schoolId: callerSchoolId } = await requireStaffCaller(request.auth);
  const code = request.data?.code;
  if (typeof code !== "string" || !code.trim()) {
    throw new HttpsError("invalid-argument", "code is required.");
  }

  const codeRef = db.collection("student_access_codes").doc(code.trim());
  const snap = await codeRef.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Access code not found.");
  }
  const data = snap.data() || {};
  if (data.schoolId !== callerSchoolId) {
    throw new HttpsError("permission-denied", "Cannot reset a code for a different school's student.");
  }

  await codeRef.update({
    pin: admin.firestore.FieldValue.delete(),
    mustChangePin: true,
    failedPinAttempts: 0,
    pinLockedUntil: admin.firestore.FieldValue.delete(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { ok: true };
});

/**
 * Enables/disables a student's portal access (admin toggle). Disabled
 * accounts are rejected at loginStudent regardless of a correct PIN.
 */
exports.setStudentAccessCodeStatus = onCall(async (request) => {
  const { db, schoolId: callerSchoolId } = await requireStaffCaller(request.auth);
  const code = request.data?.code;
  const isActive = request.data?.isActive;
  const reason = request.data?.reason || null;
  if (typeof code !== "string" || !code.trim()) {
    throw new HttpsError("invalid-argument", "code is required.");
  }
  if (typeof isActive !== "boolean") {
    throw new HttpsError("invalid-argument", "isActive must be a boolean.");
  }

  const codeRef = db.collection("student_access_codes").doc(code.trim());
  const snap = await codeRef.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Access code not found.");
  }
  const data = snap.data() || {};
  if (data.schoolId !== callerSchoolId) {
    throw new HttpsError("permission-denied", "Cannot modify a code for a different school's student.");
  }

  await codeRef.update({
    isActive,
    deactivationReason: isActive ? admin.firestore.FieldValue.delete() : reason,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { ok: true };
});

exports.__test__ = {
  issueIdentityInTransaction, mintQrToken, reserveSequence, isStaffRole,
  generateAccessCode, maskCredentialValue, recordCredentialLifecycleEvent,
};
