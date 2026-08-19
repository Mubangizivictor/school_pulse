const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { randomBytes } = require("crypto");
const admin = require("firebase-admin");
const { requirePlatformOwner, OwnerAuthorizationError } = require("./vendor/owner-auth");

// Mirrors isStaff() in firestore.rules - the Admin SDK bypasses Firestore
// rules entirely, so this is the only gate on who may call these functions.
// Same pattern as functions/student_capacity.js:isStaffRole/requireStaffCaller.
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

// crypto.randomBytes, not Math.random or the client's Dart Random.secure()
// call - this is the one place a token is actually minted, so it is the one
// place that needs to be cryptographically unguessable. base64url without
// padding matches QrCredentialCodec's token pattern on the Flutter side
// (^[A-Za-z0-9_-]{40,128}$), so existing client-side parsing/rendering code
// does not need to change.
function mintQrToken() {
  const token = randomBytes(32).toString("base64url");
  return `${QR_PREFIX}.${token}`;
}

/**
 * Reserves the next school-scoped sequence number inside a transaction.
 * The old client-side path (student_identity_repository_impl.dart) formatted
 * a sequenceNumber that nothing ever atomically reserved - two admissions
 * created in close succession could receive the same schoolStudentId. A
 * single counter document per school, incremented inside the same
 * transaction that writes the identity, closes that gap.
 */
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
 * Shared transaction body for "issue an identity+credential for this
 * student if one doesn't already exist" - used by both the interactive
 * issueStudentIdentity callable and the backfillStudentIdentities
 * maintenance job, so a student can never end up with two different
 * issuance code paths producing subtly different documents. Takes an
 * already-open transaction and already-verified schoolId; does not itself
 * check staff/caller authorization - callers are responsible for that.
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
    return { identityDocumentId: doc.id, identity: doc.data(), created: false };
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

/**
 * Revokes the current QR credential and mints a replacement, atomically.
 * Replaces StudentIdentityRepositoryImpl.regenerateQrCredential, which did
 * the revoke-then-mint as two separate unguarded writes - a crash between
 * them could leave a student with no active credential at all.
 */
exports.regenerateStudentQrCredential = onCall(async (request) => {
  const { db, schoolId: callerSchoolId } = await requireStaffCaller(request.auth);
  const studentId = request.data?.studentId;
  if (typeof studentId !== "string" || !studentId) {
    throw new HttpsError("invalid-argument", "studentId is required.");
  }

  const identityQuery = db.collection("student_identities")
    .where("studentId", "==", studentId).limit(1);

  const result = await db.runTransaction(async (tx) => {
    const snap = await tx.get(identityQuery);
    if (snap.empty) {
      throw new HttpsError("not-found", "Identity not found.");
    }
    const doc = snap.docs[0];
    const identity = doc.data();
    if (identity.schoolId !== callerSchoolId) {
      throw new HttpsError("permission-denied", "Cannot modify an identity from a different school.");
    }

    const now = admin.firestore.FieldValue.serverTimestamp();
    const oldToken = typeof identity.qrCodeData === "string" ? identity.qrCodeData.split(".")[1] : null;
    if (oldToken) {
      const oldCredentialRef = db.collection("schools").doc(callerSchoolId)
        .collection("credentials").doc(oldToken);
      tx.set(oldCredentialRef, { status: "replaced", updatedAt: now }, { merge: true });
    }

    const newToken = mintQrToken();
    tx.update(doc.ref, { qrCodeData: newToken, updatedAt: now });

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

    return { qrCodeData: newToken };
  });

  return result;
});

/**
 * Atomically binds a physical NFC card UID to a student identity, closing
 * the gap NfcCredentialRepository's own doc comment calls out: its
 * assign()/replace() duplicate check only reads this device's local Isar
 * cache, and the Firestore push afterwards is deliberately best-effort/
 * non-atomic (see NfcCredentialRepositoryImpl's class doc). Two staff
 * members on two different devices assigning the same physical card to two
 * different students within the same sync window would both "succeed"
 * locally under that scheme. This function is the actual source of truth:
 * a single transaction reads schools/{id}/credentials/{cardUid}, and if it
 * is already `active` for a different identity, the whole call fails with
 * ALREADY_EXISTS instead of silently double-assigning.
 *
 * Mirrors NfcCredentialRepository.assign's semantics exactly: succeeds as
 * a no-op (returns the existing doc) if the card is already active for the
 * *same* identity; reassigning a previously-revoked card clears its
 * revoked_credentials denylist entry in the same transaction.
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
    const identitySnap = await tx.get(identityQuery);
    if (identitySnap.empty) {
      throw new HttpsError("not-found", "No identity found for this student.");
    }
    const identityDoc = identitySnap.docs[0];
    const identity = identityDoc.data();
    if (identity.schoolId !== callerSchoolId) {
      throw new HttpsError("permission-denied", "Cannot assign a card for a different school's student.");
    }

    const credentialRef = db.collection("schools").doc(callerSchoolId)
      .collection("credentials").doc(normalizedCardUid);
    const credentialSnap = await tx.get(credentialRef);
    const now = admin.firestore.FieldValue.serverTimestamp();

    if (credentialSnap.exists) {
      const existing = credentialSnap.data();
      // Migration-aware "same student" check: an existing credential may
      // still carry the legacy identityId contract (StudentIdentity.
      // uniqueSystemId) from before credential.identityId was canonicalized
      // to the real students/{studentId} document ID. Treat either form as
      // "this card already belongs to this student" so a legacy test card
      // can be reassigned/rewritten into canonical form without tripping a
      // false already-exists conflict.
      const belongsToThisStudent = existing.identityId === studentId
        || existing.identityId === identity.uniqueSystemId;
      if (existing.status === "active" && !belongsToThisStudent) {
        // Duplicate-tag conflict - one active NFC credential cannot belong
        // to two students. Surface enough for the client to render the
        // same "already registered to X" UX NfcCredentialService already
        // builds around DuplicateCredentialFailure, without a second round
        // trip: the conflicting identityId is returned in the error's
        // details so the caller can look up the name itself.
        throw new HttpsError("already-exists", "This card is already registered to another identity.", {
          conflictingIdentityId: existing.identityId,
          conflictingIdentityType: existing.identityType,
        });
      }
    }

    // Canonical contract: credential.identityId is ALWAYS the real
    // students/{studentId} document ID, never StudentIdentity.
    // uniqueSystemId. identityDocumentId separately tracks the
    // student_identities doc for audit/QR-regeneration use.
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

    // Reassigning a previously-revoked card clears its denylist entry, same
    // as NfcCredentialRepositoryImpl.assign's local-cache equivalent.
    const revocationRef = db.collection("schools").doc(callerSchoolId)
      .collection("revoked_credentials").doc(normalizedCardUid);
    tx.delete(revocationRef);

    tx.set(identityDoc.ref, { nfcStatus: "active", updatedAt: now }, { merge: true });

    return { cardUid: normalizedCardUid, identityId: studentId };
  });

  return result;
});

/**
 * Owner-gated maintenance job: finds every active student with no
 * student_identities doc yet (schools onboarded, or students bulk-imported,
 * before this feature existed) and issues one via issueIdentityInTransaction
 * - the exact same atomic sequence-reservation + token-minting logic
 * issueStudentIdentity uses interactively, so a backfilled student and a
 * freshly-admitted student end up with identical, indistinguishable
 * records. Mirrors backfillActiveStudentCounts in student_capacity.js:
 * owner-only, run once manually (not scheduled), per-school result log.
 *
 * Idempotent and resumable: issueIdentityInTransaction's own existing-
 * identity check (`existingSnap.empty`) means re-running this after a
 * partial failure, or after new students have since been admitted, only
 * ever creates identities for students that still have none - it never
 * overwrites or duplicates a student that already has a valid identity/
 * code, interactively issued or previously backfilled alike.
 */
/**
 * One-time, idempotent, resumable, tenant-scoped backfill: finds every
 * student with no student_identities doc and issues one via the exact same
 * transaction body issueStudentIdentity uses (issueIdentityInTransaction),
 * so a backfilled identity is indistinguishable from one issued the normal
 * way. Mirrors backfillActiveStudentCounts in student_capacity.js as the
 * owner-gated one-time-maintenance-job template.
 *
 * Idempotent/resumable: issueIdentityInTransaction already returns the
 * existing doc (created: false) instead of writing a second one for a
 * student that already has an identity, so re-running this after a partial
 * failure, a timeout, or on a later day is always safe - already-issued
 * students are simply skipped, never overwritten or duplicated.
 *
 * Tenant-scoped: iterates schools one at a time and only ever queries/
 * writes within that school's own students, matching the multi-tenant
 * isolation the rest of this file enforces via schoolId checks.
 */
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

  const schoolsSnap = requestedSchoolId
    ? await db.collection("schools").where(admin.firestore.FieldPath.documentId(), "==", requestedSchoolId).get()
    : await db.collection("schools").get();

  const results = [];
  for (const schoolDoc of schoolsSnap.docs) {
    const schoolId = schoolDoc.id;
    // Only ever fetch students in this school - no cross-tenant read.
    const studentsSnap = await db.collection("students")
      .where("schoolId", "==", schoolId)
      .get();

    // A per-school set of studentIds that already have an identity doc,
    // read once up front so the transaction-per-student loop below doesn't
    // need an extra read inside every transaction just to decide whether to
    // skip - issueIdentityInTransaction's own existence check inside the
    // transaction remains the source of truth (this is just an optimization
    // to avoid opening/committing a no-op transaction for most students on
    // a re-run).
    const existingIdentitiesSnap = await db.collection("student_identities")
      .where("schoolId", "==", schoolId)
      .get();
    const studentIdsWithIdentity = new Set(
      existingIdentitiesSnap.docs.map((doc) => doc.data().studentId),
    );

    let issued = 0;
    let skippedExisting = 0;
    let skippedOther = 0;
    for (const studentDoc of studentsSnap.docs) {
      const studentId = studentDoc.id;
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
        } else {
          skippedExisting++;
        }
      } catch (error) {
        console.error("BACKFILL_STUDENT_IDENTITY_FAILED", { schoolId, studentId, error: error.message });
        skippedOther++;
      }
    }

    results.push({ schoolId, studentsScanned: studentsSnap.size, issued, skippedExisting, skippedOther });
  }

  return { ok: true, schools: results };
});

/**
 * Server-side resolver/migration path for legacy credentials whose
 * identityId still carries StudentIdentity.uniqueSystemId instead of the
 * canonical students/{studentId} document ID (pre-dating the identityId
 * contract fix in assignNfcCredential/issueIdentityInTransaction). The
 * Flutter client cannot query student_identities directly for this - that
 * collection has no per-user access rule - so this callable does the
 * uniqueSystemId -> studentId lookup server-side, validates the resolved
 * student belongs to the caller's school, and migrates the credential
 * document to the canonical form so every subsequent scan resolves via the
 * fast students/{id} direct-read path without needing this function again.
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
  const credential = credentialSnap.data();
  if (credential.identityType !== "student") {
    return { found: false };
  }

  // Already canonical - identityId is a real student doc ID in this school.
  const directStudentDoc = await db.collection("students").doc(credential.identityId).get();
  if (directStudentDoc.exists && directStudentDoc.data().schoolId === callerSchoolId) {
    return { found: true, studentId: directStudentDoc.id, migrated: false };
  }

  // Legacy path: identityId is a StudentIdentity.uniqueSystemId. Map it to
  // the real studentId, validate school ownership, then rewrite the
  // credential document into canonical form.
  const identitySnap = await db.collection("student_identities")
    .where("uniqueSystemId", "==", credential.identityId).limit(1).get();
  if (identitySnap.empty) {
    return { found: false };
  }
  const identityDoc = identitySnap.docs[0];
  const identity = identityDoc.data();
  if (identity.schoolId !== callerSchoolId) {
    return { found: false };
  }

  const studentDoc = await db.collection("students").doc(identity.studentId).get();
  if (!studentDoc.exists || studentDoc.data().schoolId !== callerSchoolId) {
    return { found: false };
  }

  await credentialRef.set({
    identityId: identity.studentId,
    identityDocumentId: identityDoc.id,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  return { found: true, studentId: identity.studentId, migrated: true };
});

exports.__test__ = { issueIdentityInTransaction, mintQrToken, reserveSequence, isStaffRole };
