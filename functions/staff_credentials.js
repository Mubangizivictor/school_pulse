const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { randomBytes } = require("crypto");
const admin = require("firebase-admin");

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
    throw new HttpsError("permission-denied", "Only staff can manage staff credentials.");
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

/**
 * users/{staffId} is the canonical tenant source, mirroring
 * student_credentials.js's Student-is-canonical pattern. Older
 * staff_identities rows may carry a stale/empty schoolId; once the caller's
 * school has been verified against the canonical User document, repair the
 * identity row instead of rejecting a valid staff member.
 */
async function issueIdentityInTransaction(tx, db, { staffId, schoolId }) {
  const staffRef = db.collection("users").doc(staffId);
  const identityQuery = db.collection("staff_identities")
    .where("staffId", "==", staffId).limit(1);

  const staffSnap = await tx.get(staffRef);
  if (!staffSnap.exists) {
    return { skipped: true, reason: "staff-not-found" };
  }
  const staff = staffSnap.data() || {};
  if (staff.schoolId !== schoolId) {
    return { skipped: true, reason: "school-mismatch" };
  }

  const existingSnap = await tx.get(identityQuery);
  if (!existingSnap.empty) {
    const doc = existingSnap.docs[0];
    const identity = doc.data() || {};
    if (identity.schoolId !== schoolId) {
      tx.set(doc.ref, {
        schoolId,
        staffId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    }
    return {
      identityDocumentId: doc.id,
      identity: { ...identity, staffId, schoolId },
      created: false,
    };
  }

  const uniqueSystemId = `SP-STAFF-${randomBytes(8).toString("hex")}`;
  const token = mintQrToken();
  const now = admin.firestore.FieldValue.serverTimestamp();

  const identityRef = db.collection("staff_identities").doc();
  const identityData = {
    staffId,
    schoolId,
    uniqueSystemId,
    qrCodeData: token,
    nfcStatus: "unassigned",
    createdAt: now,
    updatedAt: now,
  };
  tx.set(identityRef, identityData);

  const credentialRef = db.collection("schools").doc(schoolId)
    .collection("credentials").doc(token.split(".")[1]);
  tx.set(credentialRef, {
    credentialValue: token.split(".")[1],
    credentialType: "qr",
    identityId: staffId,
    identityType: "staff",
    schoolId,
    status: "active",
    updatedAt: now,
    credentialVersion: 1,
    identityDocumentId: identityRef.id,
  });

  return { identityDocumentId: identityRef.id, identity: identityData, created: true };
}

exports.issueStaffIdentity = onCall(async (request) => {
  const { db, schoolId: callerSchoolId } = await requireStaffCaller(request.auth);
  const staffId = request.data?.staffId;

  if (typeof staffId !== "string" || !staffId) {
    throw new HttpsError("invalid-argument", "staffId is required.");
  }

  const result = await db.runTransaction(async (tx) => {
    const outcome = await issueIdentityInTransaction(tx, db, {
      staffId, schoolId: callerSchoolId,
    });
    if (outcome.skipped) {
      const message = outcome.reason === "staff-not-found"
        ? "Staff member not found."
        : "Cannot issue an identity for a different school's staff member.";
      const code = outcome.reason === "staff-not-found" ? "not-found" : "permission-denied";
      throw new HttpsError(code, message);
    }
    return outcome;
  });

  return result;
});

exports.regenerateStaffQrCredential = onCall(async (request) => {
  const { db, schoolId: callerSchoolId } = await requireStaffCaller(request.auth);
  const staffId = request.data?.staffId;
  if (typeof staffId !== "string" || !staffId) {
    throw new HttpsError("invalid-argument", "staffId is required.");
  }

  const identityQuery = db.collection("staff_identities")
    .where("staffId", "==", staffId).limit(1);

  const result = await db.runTransaction(async (tx) => {
    const staffRef = db.collection("users").doc(staffId);
    const staffSnap = await tx.get(staffRef);
    if (!staffSnap.exists) {
      throw new HttpsError("not-found", "Staff member not found.");
    }
    const staff = staffSnap.data() || {};
    if (staff.schoolId !== callerSchoolId) {
      throw new HttpsError("permission-denied", "Cannot modify a staff member from a different school.");
    }

    const snap = await tx.get(identityQuery);
    if (snap.empty) {
      throw new HttpsError("not-found", "Identity not found.");
    }
    const doc = snap.docs[0];
    const identity = doc.data() || {};

    const now = admin.firestore.FieldValue.serverTimestamp();
    if (identity.schoolId !== callerSchoolId) {
      tx.set(doc.ref, { schoolId: callerSchoolId, staffId, updatedAt: now }, { merge: true });
    }

    const oldToken = typeof identity.qrCodeData === "string" ? identity.qrCodeData.split(".")[1] : null;
    if (oldToken) {
      const oldCredentialRef = db.collection("schools").doc(callerSchoolId)
        .collection("credentials").doc(oldToken);
      tx.set(oldCredentialRef, { status: "replaced", updatedAt: now }, { merge: true });
    }

    const newToken = mintQrToken();
    tx.update(doc.ref, { qrCodeData: newToken, schoolId: callerSchoolId, updatedAt: now });

    const newCredentialRef = db.collection("schools").doc(callerSchoolId)
      .collection("credentials").doc(newToken.split(".")[1]);
    tx.set(newCredentialRef, {
      credentialValue: newToken.split(".")[1],
      credentialType: "qr",
      identityId: staffId,
      identityType: "staff",
      schoolId: callerSchoolId,
      status: "active",
      updatedAt: now,
      credentialVersion: (identity.credentialVersion || 1) + 1,
      identityDocumentId: doc.id,
      replacesToken: oldToken || null,
    });

    return { qrCodeData: newToken };
  });

  return result;
});

/**
 * Atomically binds a physical NFC UID to a canonical staff User document.
 * Mirrors assignNfcCredential in student_credentials.js. Tenant
 * authorization is based on users/{caller}.schoolId and the canonical
 * users/{staffId}.schoolId.
 */
exports.assignStaffNfcCredential = onCall(async (request) => {
  const { db, schoolId: callerSchoolId, uid } = await requireStaffCaller(request.auth);
  const cardUid = request.data?.cardUid;
  const staffId = request.data?.staffId;

  if (typeof cardUid !== "string" || !cardUid.trim()) {
    throw new HttpsError("invalid-argument", "cardUid is required.");
  }
  if (typeof staffId !== "string" || !staffId) {
    throw new HttpsError("invalid-argument", "staffId is required.");
  }
  const normalizedCardUid = cardUid.trim();

  const identityQuery = db.collection("staff_identities")
    .where("staffId", "==", staffId).limit(1);

  const result = await db.runTransaction(async (tx) => {
    const staffRef = db.collection("users").doc(staffId);
    const staffSnap = await tx.get(staffRef);
    if (!staffSnap.exists) {
      throw new HttpsError("not-found", "Staff member not found.");
    }
    const staff = staffSnap.data() || {};
    if (staff.schoolId !== callerSchoolId) {
      throw new HttpsError("permission-denied", "Cannot assign a card for a different school's staff member.");
    }

    const identitySnap = await tx.get(identityQuery);
    if (identitySnap.empty) {
      throw new HttpsError("not-found", "No identity found for this staff member.");
    }
    const identityDoc = identitySnap.docs[0];
    const identity = identityDoc.data() || {};

    const credentialRef = db.collection("schools").doc(callerSchoolId)
      .collection("credentials").doc(normalizedCardUid);
    const credentialSnap = await tx.get(credentialRef);
    const now = admin.firestore.FieldValue.serverTimestamp();

    if (credentialSnap.exists) {
      const existing = credentialSnap.data() || {};
      const belongsToThisStaffMember = existing.identityId === staffId
        || existing.identityId === identity.uniqueSystemId;
      if (existing.status === "active" && !belongsToThisStaffMember) {
        throw new HttpsError("already-exists", "This card is already registered to another identity.", {
          conflictingIdentityId: existing.identityId,
          conflictingIdentityType: existing.identityType,
        });
      }
    }

    tx.set(credentialRef, {
      credentialValue: normalizedCardUid,
      credentialType: "nfc",
      identityId: staffId,
      identityType: "staff",
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

    tx.set(identityDoc.ref, {
      staffId,
      schoolId: callerSchoolId,
      nfcStatus: "active",
      updatedAt: now,
    }, { merge: true });

    return { cardUid: normalizedCardUid, identityId: staffId, status: "active" };
  });

  return result;
});

exports.__test__ = { issueIdentityInTransaction, mintQrToken, isStaffRole };
