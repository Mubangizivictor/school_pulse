/** Guardian consent for direct learner enrolment (Step 6 of the enrolment
 * wizard).
 *
 * Deliberately does NOT let a client mark consent "captured" directly: every
 * capture path here is a callable that validates the method is one the
 * tenant's `enrolmentPolicy.consentMethods` permits, then writes an
 * append-only record to `guardian_consent_records` and mirrors the latest
 * state onto `direct_enrolment_drafts/{draftId}.guardianConsent`. The
 * append-only collection is the audit source of truth; the draft mirror is
 * only a convenience read for the wizard and for `directEnrolLearner`'s
 * final-submission revalidation.
 *
 * Three methods, gated per school:
 *   - guardian_signs_now: guardian is physically present; staff captures a
 *     digital signature/confirmation immediately. Captured synchronously by
 *     `recordGuardianConsentByStaff`.
 *   - secure_link: `requestGuardianConsentLink` mints a single-use,
 *     time-limited token (mirrors owner_recovery_codes.js's challenge
 *     pattern) and emails the guardian via the same cross-codebase
 *     transactional_email_queue appointments.js writes to. The guardian
 *     (unauthenticated) redeems it via `resolveGuardianConsentLink`.
 *   - verbal: only usable when policy explicitly enables it; requires date/
 *     time (server-stamped), the authorising staff member, and — because a
 *     verbal/phone consent has no independent guardian action — a mandatory
 *     witness name + relationship, captured by
 *     `recordGuardianConsentByStaff`.
 *
 * Callables here use the default (no explicit region) onCall like
 * directEnrolLearner in index.js, since the Flutter client calls both
 * without FirebaseFunctions.instanceFor(region: ...) — must stay in sync.
 */
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const crypto = require("crypto");

const ENROLMENT_STAFF_ROLES = new Set([
  "schoolAdmin",
  "director",
  "headTeacher",
  "deputyHead",
  "admissions",
  "registrar",
  "receptionist",
]);
const LINK_TTL_MS = 72 * 60 * 60 * 1000; // 72 hours

const DEFAULT_CONSENT_METHODS = ["guardian_signs_now", "secure_link"];

function text(value, max = 400) {
  return String(value ?? "").trim().slice(0, max);
}

async function requireEnrolmentStaff(request, schoolId) {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in to continue.");
  const db = admin.firestore();
  const callerSnap = await db.collection("users").doc(request.auth.uid).get();
  const caller = callerSnap.exists ? callerSnap.data() : null;
  if (!caller || !caller.schoolId || caller.isActive === false) {
    throw new HttpsError("permission-denied", "No active institution membership.");
  }
  const roles = [caller.role, ...(Array.isArray(caller.roles) ? caller.roles : [])];
  if (!roles.some((r) => ENROLMENT_STAFF_ROLES.has(r))) {
    throw new HttpsError("permission-denied", "You do not have permission to manage enrolment consent.");
  }
  if (schoolId && caller.schoolId !== schoolId) {
    throw new HttpsError("permission-denied", "You may only act on your own school's enrolment records.");
  }
  return { db, uid: request.auth.uid, schoolId: caller.schoolId, callerName: caller.name || "" };
}

async function loadDraftForSchool(db, draftId, schoolId) {
  const draftRef = db.collection("direct_enrolment_drafts").doc(draftId);
  const draftSnap = await draftRef.get();
  if (!draftSnap.exists) throw new HttpsError("not-found", "This enrolment draft no longer exists.");
  const draft = draftSnap.data();
  if (draft.schoolId !== schoolId) throw new HttpsError("permission-denied", "This draft belongs to another school.");
  return { draftRef, draft };
}

async function loadEnrolmentPolicy(db, schoolId) {
  const schoolSnap = await db.collection("schools").doc(schoolId).get();
  const school = schoolSnap.exists ? schoolSnap.data() : {};
  const policy = school.enrolmentPolicy || {};
  const consentMethods = Array.isArray(policy.consentMethods) && policy.consentMethods.length
    ? policy.consentMethods
    : DEFAULT_CONSENT_METHODS;
  return {
    consentMethods,
    policyVersion: text(policy.consentPolicyVersion || "v1", 40),
    privacyNoticeUrl: policy.privacyNoticeUrl || null,
    consentText: text(
      policy.consentText ||
        "I consent to the enrolment of this learner and confirm that the information provided is true and correct. " +
          "We collect and use personal information in accordance with the Privacy Notice for Learner Enrolment.",
      4000,
    ),
    schoolName: school.name || "your school",
  };
}

function findGuardian(draft, guardianId) {
  const guardians = Array.isArray(draft.guardians) ? draft.guardians : [];
  return guardians.find((g) => g && g.id === guardianId) || null;
}

function hashConsentText(text_) {
  return crypto.createHash("sha256").update(text_, "utf8").digest("hex");
}

async function writeConsentRecord(db, { schoolId, draftId, guardian, method, status, policy, extra = {} }) {
  const ref = db.collection("guardian_consent_records").doc();
  const payload = {
    schoolId,
    draftId,
    guardianId: guardian.id,
    guardianName: guardian.name || "",
    method,
    status,
    policyVersion: policy.policyVersion,
    consentTextHash: hashConsentText(policy.consentText),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    ...extra,
  };
  await ref.set(payload);
  return { id: ref.id, ...payload };
}

async function mirrorOntoDraft(draftRef, record) {
  await draftRef.set(
    {
      guardianConsent: {
        recordId: record.id,
        guardianId: record.guardianId,
        guardianName: record.guardianName,
        method: record.method,
        status: record.status,
        policyVersion: record.policyVersion,
        capturedAt: record.capturedAt || null,
        expiresAt: record.expiresAt || null,
        capturedByStaffId: record.capturedByStaffId || null,
        capturedByStaffName: record.capturedByStaffName || null,
      },
    },
    { merge: true },
  );
}

/** Staff-present capture: "guardian signs now" (digital signature/
 * confirmation while present) or "verbal"/in-person (requires witness). */
exports.recordGuardianConsentByStaff = onCall(async (request) => {
  const draftId = text(request.data?.draftId, 200);
  const guardianId = text(request.data?.guardianId, 200);
  const method = text(request.data?.method, 40);
  if (!draftId || !guardianId) throw new HttpsError("invalid-argument", "Draft and guardian are required.");
  if (!["guardian_signs_now", "verbal"].includes(method)) {
    throw new HttpsError("invalid-argument", "Unsupported consent method for staff capture.");
  }

  const staff = await requireEnrolmentStaff(request, text(request.data?.schoolId, 200) || undefined);
  const { draftRef, draft } = await loadDraftForSchool(staff.db, draftId, staff.schoolId);
  const policy = await loadEnrolmentPolicy(staff.db, staff.schoolId);
  if (!policy.consentMethods.includes(method)) {
    throw new HttpsError("permission-denied", "This consent method is not enabled by your school's policy.");
  }
  const guardian = findGuardian(draft, guardianId);
  if (!guardian) throw new HttpsError("failed-precondition", "This guardian is not linked to the draft.");

  const extra = {
    capturedAt: admin.firestore.FieldValue.serverTimestamp(),
    capturedByStaffId: staff.uid,
    capturedByStaffName: staff.callerName,
  };
  if (method === "guardian_signs_now") {
    const signatureDataUrl = text(request.data?.signatureDataUrl, 200000);
    if (!signatureDataUrl) throw new HttpsError("invalid-argument", "A guardian signature is required.");
    extra.signatureRef = signatureDataUrl.slice(0, 200000);
  } else {
    const witnessName = text(request.data?.witnessName, 200);
    const witnessRelationship = text(request.data?.witnessRelationship, 120);
    const verbalConsentReference = text(request.data?.verbalConsentReference, 200);
    if (!witnessName || !witnessRelationship) {
      throw new HttpsError(
        "invalid-argument",
        "Verbal/in-person consent requires a witness name and relationship, per school policy.",
      );
    }
    extra.witnessName = witnessName;
    extra.witnessRelationship = witnessRelationship;
    extra.verbalConsentReference = verbalConsentReference || null;
  }

  const record = await writeConsentRecord(staff.db, {
    schoolId: staff.schoolId,
    draftId,
    guardian,
    method,
    status: "captured",
    policy,
    extra,
  });
  await mirrorOntoDraft(draftRef, { ...record, capturedAt: new Date().toISOString() });
  await staff.db.collection("audit_logs").add({
    schoolId: staff.schoolId,
    actorId: staff.uid,
    module: "enrollment",
    action: "guardian_consent_captured",
    targetType: "direct_enrolment_draft",
    targetId: draftId,
    details: { method, guardianId, recordId: record.id },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { recordId: record.id, status: "captured" };
});

/** Mints a single-use, time-limited consent link and emails the guardian. */
exports.requestGuardianConsentLink = onCall(async (request) => {
  const draftId = text(request.data?.draftId, 200);
  const guardianId = text(request.data?.guardianId, 200);
  if (!draftId || !guardianId) throw new HttpsError("invalid-argument", "Draft and guardian are required.");

  const staff = await requireEnrolmentStaff(request, text(request.data?.schoolId, 200) || undefined);
  const { draftRef, draft } = await loadDraftForSchool(staff.db, draftId, staff.schoolId);
  const policy = await loadEnrolmentPolicy(staff.db, staff.schoolId);
  if (!policy.consentMethods.includes("secure_link")) {
    throw new HttpsError("permission-denied", "Secure consent links are not enabled by your school's policy.");
  }
  const guardian = findGuardian(draft, guardianId);
  if (!guardian) throw new HttpsError("failed-precondition", "This guardian is not linked to the draft.");
  const email = text(guardian.email, 200).toLowerCase();
  if (!email) throw new HttpsError("failed-precondition", "This guardian has no email address on file.");

  const tokenId = crypto.randomBytes(32).toString("base64url");
  const linkRef = staff.db.collection("guardian_consent_links").doc(tokenId);
  const expiresAt = admin.firestore.Timestamp.fromMillis(Date.now() + LINK_TTL_MS);
  await linkRef.set({
    id: tokenId,
    schoolId: staff.schoolId,
    draftId,
    guardianId,
    guardianName: guardian.name || "",
    email,
    used: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdByStaffId: staff.uid,
    expiresAt,
  });

  const record = await writeConsentRecord(staff.db, {
    schoolId: staff.schoolId,
    draftId,
    guardian,
    method: "secure_link",
    status: "pending",
    policy,
    extra: { linkId: tokenId, expiresAt },
  });
  await mirrorOntoDraft(draftRef, { ...record, expiresAt: expiresAt.toDate().toISOString() });

  await admin.firestore().collection("transactional_email_queue").doc(`guardian_consent_${tokenId}`).set({
    eventId: `guardian_consent_${tokenId}`,
    templateId: "guardian_consent_link",
    to: email,
    data: {
      guardianName: guardian.name || "Guardian",
      schoolName: policy.schoolName,
      consentUrl: `https://school-pulse-3d95b.web.app/consent/${tokenId}`,
      expiresInHours: Math.round(LINK_TTL_MS / (60 * 60 * 1000)),
    },
    schoolBranding: null,
    status: "queued",
    attempts: 0,
    scheduledAt: admin.firestore.FieldValue.serverTimestamp(),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    sentAt: null,
    resendId: null,
    error: null,
  }, { merge: true });

  await staff.db.collection("audit_logs").add({
    schoolId: staff.schoolId,
    actorId: staff.uid,
    module: "enrollment",
    action: "guardian_consent_link_sent",
    targetType: "direct_enrolment_draft",
    targetId: draftId,
    details: { guardianId, recordId: record.id },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { recordId: record.id, status: "pending", expiresAt: expiresAt.toDate().toISOString() };
});

/** Public: the guardian (unauthenticated) redeems the token from the emailed
 * link. Single-use and time-limited, mirroring owner_recovery_codes.js's
 * challenge-consumption transaction. */
exports.resolveGuardianConsentLink = onCall(async (request) => {
  const token = text(request.data?.token, 400);
  const action = text(request.data?.action, 20) || "view";
  if (!token) throw new HttpsError("invalid-argument", "A consent token is required.");

  const db = admin.firestore();
  const linkRef = db.collection("guardian_consent_links").doc(token);

  if (action === "view") {
    const snap = await linkRef.get();
    if (!snap.exists) throw new HttpsError("not-found", "This consent link is invalid.");
    const link = snap.data();
    if (link.used) throw new HttpsError("failed-precondition", "This consent link has already been used.");
    if (link.expiresAt && link.expiresAt.toMillis() < Date.now()) {
      throw new HttpsError("failed-precondition", "This consent link has expired.");
    }
    const policy = await loadEnrolmentPolicy(db, link.schoolId);
    return {
      guardianName: link.guardianName,
      schoolName: policy.schoolName,
      consentText: policy.consentText,
      privacyNoticeUrl: policy.privacyNoticeUrl,
    };
  }

  if (action !== "confirm") throw new HttpsError("invalid-argument", "Unsupported action.");

  const result = await db.runTransaction(async (tx) => {
    const snap = await tx.get(linkRef);
    if (!snap.exists) throw new HttpsError("not-found", "This consent link is invalid.");
    const link = snap.data();
    if (link.used) throw new HttpsError("failed-precondition", "This consent link has already been used.");
    if (link.expiresAt && link.expiresAt.toMillis() < Date.now()) {
      throw new HttpsError("failed-precondition", "This consent link has expired.");
    }
    const draftRef = db.collection("direct_enrolment_drafts").doc(link.draftId);
    const draftSnap = await tx.get(draftRef);
    if (!draftSnap.exists) throw new HttpsError("not-found", "The related enrolment draft no longer exists.");
    const draft = draftSnap.data();
    const guardian = findGuardian(draft, link.guardianId) || {
      id: link.guardianId,
      name: link.guardianName,
    };
    const policy = await loadEnrolmentPolicy(db, link.schoolId);

    const recordRef = db.collection("guardian_consent_records").doc();
    const capturedAt = admin.firestore.FieldValue.serverTimestamp();
    tx.set(recordRef, {
      schoolId: link.schoolId,
      draftId: link.draftId,
      guardianId: guardian.id,
      guardianName: guardian.name || "",
      method: "secure_link",
      status: "captured",
      policyVersion: policy.policyVersion,
      consentTextHash: hashConsentText(policy.consentText),
      linkId: token,
      capturedAt,
      createdAt: capturedAt,
    });
    tx.set(
      draftRef,
      {
        guardianConsent: {
          recordId: recordRef.id,
          guardianId: guardian.id,
          guardianName: guardian.name || "",
          method: "secure_link",
          status: "captured",
          policyVersion: policy.policyVersion,
          capturedAt: new Date().toISOString(),
        },
      },
      { merge: true },
    );
    tx.set(linkRef, { used: true, usedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    return { recordId: recordRef.id };
  });

  return { status: "captured", recordId: result.recordId };
});

/** Withdraws a previously captured consent (e.g. a guardian later objects,
 * or staff recorded the wrong guardian). Withdrawal is itself a new
 * append-only record, never a mutation of the original — see the
 * `withdrawalHistory` shape implied by querying `guardian_consent_records`
 * for a guardian/draft pair ordered by createdAt. */
exports.withdrawGuardianConsent = onCall(async (request) => {
  const draftId = text(request.data?.draftId, 200);
  const guardianId = text(request.data?.guardianId, 200);
  const reason = text(request.data?.reason, 500);
  if (!draftId || !guardianId || !reason) {
    throw new HttpsError("invalid-argument", "Draft, guardian and a withdrawal reason are required.");
  }
  const staff = await requireEnrolmentStaff(request, text(request.data?.schoolId, 200) || undefined);
  const { draftRef, draft } = await loadDraftForSchool(staff.db, draftId, staff.schoolId);
  const guardian = findGuardian(draft, guardianId) || { id: guardianId, name: "" };
  const policy = await loadEnrolmentPolicy(staff.db, staff.schoolId);

  const record = await writeConsentRecord(staff.db, {
    schoolId: staff.schoolId,
    draftId,
    guardian,
    method: draft.guardianConsent?.method || "guardian_signs_now",
    status: "withdrawn",
    policy,
    extra: {
      withdrawnAt: admin.firestore.FieldValue.serverTimestamp(),
      withdrawnReason: reason,
      withdrawnByStaffId: staff.uid,
    },
  });
  await mirrorOntoDraft(draftRef, { ...record });
  await staff.db.collection("audit_logs").add({
    schoolId: staff.schoolId,
    actorId: staff.uid,
    module: "enrollment",
    action: "guardian_consent_withdrawn",
    targetType: "direct_enrolment_draft",
    targetId: draftId,
    details: { guardianId, reason, recordId: record.id },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { recordId: record.id, status: "withdrawn" };
});
