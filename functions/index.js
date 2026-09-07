const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated, onDocumentWritten } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { randomBytes, randomUUID, createHash, createHmac } = require("crypto");
const admin = require("firebase-admin");
const { requirePlatformOwner, OwnerAuthorizationError } = require("./vendor/owner-auth");
const { hashPin, verifyPin, assertNotLockedOut, failedAttemptUpdate, clearLockoutUpdate } = require("./vendor/pin-auth");
const reportCardEngine = require("./report_card_engine");
const { renderReportCardPdf } = require("./report_card_pdf");

admin.initializeApp();
const supportAuditFunctions = require("./support_audit")({ admin, onCall, HttpsError });
const enrollmentAuditFunctions = require("./enrollment_audit")({ admin, onCall, HttpsError });
const { maybeAutoUpdateReportCardFinancialAccess } = require("./report_card_financial_gate")({ admin });
Object.assign(exports, require("./student_fee_billing")({ admin, onCall, HttpsError, maybeAutoUpdateReportCardFinancialAccess }));
Object.assign(exports, require("./staff_payroll_structure")({ admin, onCall, HttpsError }));
const staffAttendanceCorrectionFunctions = require("./staff_attendance_corrections")({ admin, onCall, HttpsError });
exports.correctStaffAttendance = staffAttendanceCorrectionFunctions.correctStaffAttendance;
Object.assign(exports, require("./payroll_compliance")({ admin, onCall, HttpsError }));
Object.assign(exports, require("./payment_codes")({ admin, onCall, HttpsError }));
Object.assign(exports, require("./payment_vouchers")({ admin, onCall, HttpsError }));
Object.assign(exports, require("./finance_governance")({ admin, onCall, HttpsError }));
Object.assign(exports, require("./report_card_release")({ admin, onCall, HttpsError, onSchedule }));
Object.assign(exports, require("./finance_operations")({ admin, onCall, HttpsError }));
Object.assign(exports, require("./finance_reconciliation")({ admin, onCall, HttpsError }));
Object.assign(exports, require("./health_clinic")({ admin, onCall, HttpsError }));
Object.assign(exports, require("./financial_entitlements")({ admin, onCall, HttpsError }));
Object.assign(exports, require("./exam_factory")({ admin, onCall, HttpsError }));
Object.assign(exports, require("./exam_factory_operations")({ admin, onCall, HttpsError }));
Object.assign(exports, require("./exam_factory_reminders")({ admin, onSchedule }));
const { recordJobRun, recordJobFailure } = require("./platform_health_instrumentation")({ admin });
Object.assign(exports, require("./staff_admin_count")({ admin, onDocumentWritten }));
Object.assign(exports, require("./parent_invitations")({ admin, onCall, HttpsError, enqueueTransactionalEmail }));

/**
 * Enqueue a templated transactional email for the `public_functions`
 * codebase to send (it holds the Resend secret and the template registry;
 * this codebase deliberately does not duplicate either). Writing straight to
 * Firestore works because both Cloud Functions codebases share one project
 * — public_functions/email/transactional_queue.js drains this collection.
 * `eventId` is the idempotency key: writing the same eventId twice is a
 * no-op once it has been sent.
 */
async function enqueueTransactionalEmail({ eventId, templateId, to, data = {} }) {
  if (!eventId || !to) return;
  await admin.firestore().collection("transactional_email_queue").doc(eventId).set({
    eventId,
    templateId,
    to: String(to).trim().toLowerCase(),
    data,
    schoolBranding: null,
    status: "queued",
    attempts: 0,
    scheduledAt: admin.firestore.FieldValue.serverTimestamp(),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    sentAt: null,
    resendId: null,
    error: null,
  }, { merge: true });
}

/**
 * Thin wrapper around the canonical owner-auth package (shared/owner-auth/index.js) -
 * the ONE authoritative implementation of "is this authenticated UID the
 * School Pulse SaaS Owner", consumed identically here and in
 * public_functions/owner_auth.js via a committed copy at
 * vendor/owner-auth/index.js in each codebase (kept byte-identical to
 * shared/owner-auth/index.js - see that package's tests for the drift
 * guard). A plain npm `file:../shared/owner-auth` dependency doesn't work
 * here: Cloud Functions deploy packaging ignores node_modules entirely, so
 * a local file: dependency resolves to a path that doesn't exist in the
 * remote build (only this codebase's own directory gets uploaded, not its
 * sibling shared/ directory) and crashes every function in the codebase at
 * container startup. This file and public_functions/ are SEPARATE Cloud
 * Functions codebases (see firebase.json's two `codebase` entries) with no
 * shared require() graph between them at the source level, which is why
 * this goes through a vendored copy instead of two hand-maintained,
 * independently-drifting copies of the same check (which is what existed
 * here previously - see git history).
 *
 * Also fixes a known inconsistency from an earlier security pass:
 * enterSupportMode previously checked only `callerData.role !== "superAdmin"`
 * on the caller's own profile doc - weaker than every other owner-gated
 * path, which also requires the caller's UID to match
 * `platform_config/owner_seed.ownerUid` and the profile to still be active.
 */
async function requireOwner(request) {
  try {
    return await requirePlatformOwner(request, { db: admin.firestore() });
  } catch (error) {
    if (error instanceof OwnerAuthorizationError) {
      throw new HttpsError(error.code, error.message);
    }
    throw error;
  }
}

// Placed after requireOwner's own definition above (not up with the other
// Object.assign(exports, require(...)) calls near the top of this file) -
// platform_health.js needs requireOwner passed in, which would otherwise
// be undefined at that point in the file due to how the interpreter
// executes top-to-bottom.
const platformHealthFunctions = require("./platform_health")({ admin, onCall, HttpsError, requireOwner });
exports.checkPlatformHealth = platformHealthFunctions.checkPlatformHealth;
exports.acknowledgePlatformHealthIncident = platformHealthFunctions.acknowledgePlatformHealthIncident;

// ... existing roles and helper functions ...
const ADMIN_ROLES = ["director", "headTeacher", "schoolAdmin"];

const STAFF_ROLES = [
  "director", "headTeacher", "deputyHead", "deanOfStudies", "schoolAdmin", "bursar",
  "classTeacher", "subjectTeacher", "librarian", "nurse", "boardingMatron", "boardingPatron",
  "transportCoordinator", "guidanceDiscipline", "storeInventory",
  "receptionist", "gatekeeper", "securityHead",
  "gamesMaster", "cateringManager", "religiousLeader", "hrOfficer",
  "admissions", "registrar",
];

// Maps a UserRole to the StaffResponsibilityType (see
// lib/features/teacher/domain/entities/staff_role_assignment.dart) that
// best describes it, so createStaffAccount can write a real
// staff_role_assignments row alongside the legacy flat assignedClass/
// subjects fields it has always written. Roles with no natural
// responsibility type (e.g. director, schoolAdmin) fall back to "other".
const ROLE_TO_RESPONSIBILITY_TYPE = {
  classTeacher: "classTeacher",
  subjectTeacher: "subjectTeacher",
  nurse: "nurse",
  bursar: "bursar",
  librarian: "librarian",
  securityHead: "securityOfficer",
  gatekeeper: "securityOfficer",
  transportCoordinator: "transportCoordinator",
  storeInventory: "storeInventoryManager",
  receptionist: "receptionist",
  cateringManager: "cateringManager",
};

// A small, curated mirror of RolePermissionDefaults
// (lib/core/permissions/role_permission_defaults.dart) - only the subset
// needed to stamp a sensible default permissionScope.permissions onto a
// staff_role_assignments row at creation time. Not a full port: the Dart
// map is the source of truth for the app's own permission evaluator.
//
// classTeacher/subjectTeacher list every permission their own panel's
// repositories actually check (see grep of `Permission: Permission.class*`/
// `Permission.subject*` call sites under lib/features/teacher/) - every one
// of these is scoped to the assignment's own classId/subjectId by
// PermissionScope, never global, so granting the full ordinary-teacher set
// by default is not a privilege escalation. Deliberately excluded:
// class.report.approve.dean/headteacher (Dean/Headteacher-only per their
// own doc comments in permission.dart) and class.teacher.multi_assign.
// override (admin-only, reason-audited). A school can still narrow or
// widen either role's grant via role_permission_overrides.
const RESPONSIBILITY_DEFAULT_PERMISSIONS = {
  classTeacher: [
    "class.students.view", "class.student.profile.view",
    "class.attendance.take", "class.attendance.edit", "class.attendance.view",
    "class.homework.create", "class.homework.publish", "class.homework.edit",
    "class.behaviour.record", "class.behaviour.view", "class.achievement.record",
    "class.leave.view",
    "class.parent.message", "class.announcement.create", "class.announcement.publish",
    "class.performance.view",
    "class.report.entry", "class.report.competency.entry", "class.report.conduct.entry",
    "class.report.comment.write", "class.report.recommendation.write",
    "class.report.submit", "class.report.generate", "class.report.share", "class.report.export",
    "class.task.manage", "class.task.collaborate",
    "class.resource.upload", "class.resource.share",
    "class.timetable.view",
  ],
  subjectTeacher: [
    "subject.students.view", "subject.student.enroll", "subject.student.remove",
    "subject.lesson.view", "subject.lesson.start", "subject.lesson.complete",
    "subject.attendance.take", "subject.attendance.edit",
    "subject.resource.upload", "subject.resource.share",
    "subject.assessment.create",
    "subject.marks.view", "subject.marks.enter", "subject.marks.edit", "subject.marks.submit",
    "subject.report.view", "subject.report.generate",
    "subject.parent.message", "subject.student.message", "subject.announcement.send",
    "subject.timetable.view",
  ],
  nurse: ["health.student.verify", "health.student.basic.read"],
  bursar: ["finance.student.verify", "finance.student.balance.read"],
  librarian: ["library.member.verify", "library.borrow", "library.return"],
  securityOfficer: ["security.identity.verify", "security.entry.record", "security.exit.record"],
  transportCoordinator: ["transport.boarding.verify", "transport.boarding.record"],
  storeInventoryManager: [],
  receptionist: [],
  cateringManager: ["meals.verify", "meals.serve"],
};

// Excludes visually ambiguous characters (0/O, 1/l/I) since admins read
// this aloud or copy it onto a note for the teacher.
const PASSWORD_CHARS = "ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789";

// Central approval workflow -------------------------------------------------
// Source modules submit immutable snapshots here; only these functions mutate
// workflow state. Source execution remains in the originating module.
const APPROVAL_ADMIN_ROLES = ["director", "headTeacher", "deputyHead", "schoolAdmin", "bursar", "deanOfStudies"];
function approvalRef(schoolId, requestId) { return admin.firestore().doc(`schools/${schoolId}/approval_requests/${requestId}`); }
async function approvalCaller(request, schoolId) {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in is required.");
  const user = (await admin.firestore().doc(`users/${request.auth.uid}`).get()).data();
  if (!user || user.schoolId !== schoolId || user.isActive === false) throw new HttpsError("permission-denied", "No active membership for this institution.");
  return user;
}
function isApprovalAdmin(user) { return APPROVAL_ADMIN_ROLES.includes(user.role) || (user.roles || []).some((r) => APPROVAL_ADMIN_ROLES.includes(r)) || (user.permissions || []).includes("approvals.approve"); }
async function approvalStageApprovers(schoolId, stage) {
  const users = await admin.firestore().collection("users").where("schoolId", "==", schoolId).get();
  return users.docs.filter((doc) => {
    const user = doc.data() || {};
    if (user.isActive === false) return false;
    const roles = Array.isArray(user.roles) ? user.roles : [user.role].filter(Boolean);
    const permissions = user.permissions || [];
    return (!stage.requiredRoleTemplate || roles.includes(stage.requiredRoleTemplate)) &&
      (permissions.includes(stage.requiredPermission || "approvals.approve") || isApprovalAdmin(user));
  }).map((doc) => doc.id);
}
// Pure so it can be unit-tested without the emulator; `nowMs` defaults to
// Date.now() but is injectable for expiry tests.
function isDelegationValid(delegation, moduleKey, requestType, nowMs = Date.now()) {
  const startMs = delegation.start?.toMillis ? delegation.start.toMillis() : delegation.start;
  const endMs = delegation.end?.toMillis ? delegation.end.toMillis() : delegation.end;
  if (!(startMs <= nowMs && nowMs <= endMs)) return false;
  if ((delegation.modules || []).length && !delegation.modules.includes(moduleKey)) return false;
  if ((delegation.requestTypes || []).length && !delegation.requestTypes.includes(requestType)) return false;
  return true;
}
async function hasValidApprovalDelegation(schoolId, uid, moduleKey, requestType) {
  const snap = await admin.firestore().collection(`schools/${schoolId}/approval_delegations`)
    .where("delegateId", "==", uid).where("status", "==", "active").get();
  return snap.docs.some((doc) => isDelegationValid(doc.data(), moduleKey, requestType));
}

exports.submitApprovalRequest = onCall(async (request) => {
  const d = request.data || {}; const schoolId = String(d.institutionId || ""); const user = await approvalCaller(request, schoolId);
  if (!(user.permissions || []).includes("approvals.submit") && !isApprovalAdmin(user)) throw new HttpsError("permission-denied", "You cannot submit approval requests.");
  for (const key of ["moduleKey", "requestType", "sourceRecordType", "sourceRecordId", "title", "approvalPolicyId", "sourceRecordVersion"]) if (!d[key]) throw new HttpsError("invalid-argument", `${key} is required.`);
  const db = admin.firestore(); const requestId = d.idempotencyKey || `${d.sourceRecordId}_${d.requestType}`;
  const ref = approvalRef(schoolId, requestId); const policy = await db.doc(`schools/${schoolId}/approval_policies/${d.approvalPolicyId}`).get();
  if (!policy.exists || policy.data().status !== "active") throw new HttpsError("failed-precondition", "The approval policy is not active.");
  const firstStage = (policy.data().stages || [])[0] || {};
  const requiredApprovers = await approvalStageApprovers(schoolId, firstStage);
  if (!requiredApprovers.length) throw new HttpsError("failed-precondition", "No active approver is configured for the first workflow stage.");
  await db.runTransaction(async (tx) => { const existing = await tx.get(ref); if (existing.exists && ["submitted", "pending", "inReview", "awaitingInformation", "escalated", "delegated"].includes(existing.data().currentStatus)) throw new HttpsError("already-exists", "An active request already exists for this source record."); const now = admin.firestore.FieldValue.serverTimestamp(); tx.set(ref, { approvalRequestId: requestId, institutionId: schoolId, moduleKey: d.moduleKey, requestType: d.requestType, sourceRecordType: d.sourceRecordType, sourceRecordId: d.sourceRecordId, sourceRoute: d.sourceRoute || "", title: d.title, summary: d.summary || "", requestedBy: request.auth.uid, requesterRole: user.role || "", requesterDepartment: user.departmentId || null, requesterCampus: user.campusId || null, requesterDivision: user.divisionId || null, currentStage: firstStage.stageId || "", currentStatus: "pending", priority: d.priority || "normal", sensitivity: d.sensitivity || "normal", amount: d.amount || null, oldValue: d.oldValue || null, proposedValue: d.proposedValue || null, reason: d.reason || null, attachments: d.attachments || [], requiredApprovers, approvalPolicyId: d.approvalPolicyId, escalationPolicyId: d.escalationPolicyId || null, sourceRecordVersion: String(d.sourceRecordVersion), createdAt: now, submittedAt: now, dueAt: d.dueAt ? admin.firestore.Timestamp.fromDate(new Date(d.dueAt)) : null, resolvedAt: null, version: 1, correlationId: d.correlationId || requestId }); });
  await ref.collection("actions").add({ actorId: request.auth.uid, action: "submitted", stage: "", comment: "", timestamp: admin.firestore.FieldValue.serverTimestamp(), correlationId: d.correlationId || requestId });
  return { requestId };
});

exports.decideApprovalRequest = onCall(async (request) => {
  const d = request.data || {}; const schoolId = String(d.institutionId || ""); const user = await approvalCaller(request, schoolId); const uid = request.auth.uid;
  if (!["approved", "rejected", "returned", "informationRequested", "cancelled"].includes(d.decision)) throw new HttpsError("invalid-argument", "Unsupported approval decision.");
  if (["rejected", "returned"].includes(d.decision) && !String(d.comment || "").trim()) throw new HttpsError("invalid-argument", "A reason is required.");
  const ref = approvalRef(schoolId, String(d.requestId)); const db = admin.firestore();
  const preSnap = await ref.get();
  if (!preSnap.exists) throw new HttpsError("not-found", "Approval request not found.");
  const preRow = preSnap.data();
  const hasDelegation = isApprovalAdmin(user) ? false : await hasValidApprovalDelegation(schoolId, uid, preRow.moduleKey, preRow.requestType);
  if (!(preRow.requiredApprovers || []).includes(uid) && !hasDelegation) throw new HttpsError("permission-denied", "You are not assigned to the current approval step.");
  const prePolicy = await db.doc(`schools/${schoolId}/approval_policies/${preRow.approvalPolicyId}`).get();
  const preStages = prePolicy.exists ? prePolicy.data().stages || [] : [];
  const preIndex = preStages.findIndex((s) => s.stageId === preRow.currentStage);
  const preNext = preIndex >= 0 && preIndex < preStages.length - 1 ? preStages[preIndex + 1] : null;
  const nextApprovers = preNext ? await approvalStageApprovers(schoolId, preNext) : [];
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref); if (!snap.exists) throw new HttpsError("not-found", "Approval request not found."); const row = snap.data();
    if (row.currentStatus !== "pending" && row.currentStatus !== "partiallyApproved") throw new HttpsError("failed-precondition", "This request is no longer awaiting a decision.");
    if (d.expectedVersion != null && row.version !== d.expectedVersion) throw new HttpsError("aborted", "The request changed; reload it before deciding.");
    const policySnap = await tx.get(db.doc(`schools/${schoolId}/approval_policies/${row.approvalPolicyId}`));
    if (!policySnap.exists || policySnap.data().status !== "active") throw new HttpsError("failed-precondition", "The workflow policy is no longer active.");
    const policy = policySnap.data(); const stages = policy.stages || []; const index = stages.findIndex((s) => s.stageId === row.currentStage); const stage = stages[index] || {};
    if (row.requestedBy === uid && !policy.selfApprovalAllowed) throw new HttpsError("permission-denied", "Self approval is not allowed.");
    let status, nextStage = row.currentStage, stageApprovals = (row.stageApprovals || 0);
    if (d.decision === "approved") {
      stageApprovals += 1;
      const minimum = stage.minimumApprovals || 1;
      if (stageApprovals < minimum) {
        status = "partiallyApproved";
      } else {
        const next = index >= 0 && index < stages.length - 1 ? stages[index + 1] : null;
        status = next ? "pending" : "approved";
        nextStage = next ? next.stageId : row.currentStage;
        stageApprovals = 0;
      }
    } else if (d.decision === "informationRequested") {
      status = "awaitingInformation";
    } else {
      status = d.decision;
    }
    const resolved = ["approved", "rejected", "returned", "cancelled"].includes(status) && !(d.decision === "approved" && status === "pending");
    if (d.decision === "approved" && status === "pending" && !nextApprovers.length) throw new HttpsError("failed-precondition", "No active approver is configured for the next workflow stage.");
    tx.update(ref, { currentStatus: status, currentStage: nextStage, requiredApprovers: status === "pending" && d.decision === "approved" ? nextApprovers : row.requiredApprovers || [], stageApprovals: status === "pending" || status === "partiallyApproved" ? stageApprovals : 0, version: admin.firestore.FieldValue.increment(1), resolvedAt: resolved ? admin.firestore.FieldValue.serverTimestamp() : null });
    tx.set(ref.collection("actions").doc(), { actorId: uid, action: d.decision, stage: row.currentStage, comment: String(d.comment || ""), viaDelegation: hasDelegation, timestamp: admin.firestore.FieldValue.serverTimestamp(), correlationId: row.correlationId || "" });
  });
  return { ok: true };
});

// Called by the source module once it has performed (or failed to perform)
// the operation an approved request authorized. Approval Center never
// mutates source records itself - it only records the outcome.
exports.reportApprovalExecutionResult = onCall(async (request) => {
  const d = request.data || {}; const schoolId = String(d.institutionId || ""); const user = await approvalCaller(request, schoolId); const uid = request.auth.uid;
  if (!["executed", "executionFailed"].includes(d.result)) throw new HttpsError("invalid-argument", "Unsupported execution result.");
  const ref = approvalRef(schoolId, String(d.requestId)); const db = admin.firestore();
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref); if (!snap.exists) throw new HttpsError("not-found", "Approval request not found."); const row = snap.data();
    if (row.currentStatus !== "approved") throw new HttpsError("failed-precondition", "Only an approved request can report an execution result.");
    tx.update(ref, { currentStatus: d.result, version: admin.firestore.FieldValue.increment(1) });
    tx.set(ref.collection("actions").doc(), { actorId: uid, action: d.result, stage: row.currentStage, comment: String(d.errorReference || ""), timestamp: admin.firestore.FieldValue.serverTimestamp(), correlationId: row.correlationId || "" });
  });
  return { ok: true };
});

// Pure so the stage-cleaning/validation rules can be unit-tested without the
// emulator. Throws a plain Error with a human message on invalid input;
// callers translate that into an HttpsError.
function validatePolicyStages(stages) {
  if (!Array.isArray(stages) || !stages.length) throw new Error("At least one stage is required.");
  const seenIds = new Set();
  return stages.map((s, i) => {
    const stageId = String(s.stageId || "").trim();
    if (!stageId) throw new Error(`Stage ${i + 1} needs a stageId.`);
    if (seenIds.has(stageId)) throw new Error(`Duplicate stageId "${stageId}".`);
    seenIds.add(stageId);
    const minimumApprovals = s.minimumApprovals == null ? 1 : Number(s.minimumApprovals);
    if (!(minimumApprovals >= 1)) throw new Error(`Stage "${stageId}" needs minimumApprovals >= 1.`);
    return {
      stageId, order: Number(s.order) || i, name: String(s.name || stageId),
      requiredPermission: String(s.requiredPermission || "approvals.approve"),
      requiredRoleTemplate: s.requiredRoleTemplate || null,
      minimumApprovals, parallel: s.parallel === true,
      allowReturn: s.allowReturn !== false, allowReject: s.allowReject !== false, allowComment: s.allowComment !== false,
      requiresMfa: s.requiresMfa === true, requiresReauth: s.requiresReauth === true,
      escalationTimeoutMinutes: s.escalationTimeoutMinutes ? Number(s.escalationTimeoutMinutes) : null,
    };
  }).sort((a, b) => a.order - b.order);
}

// Policy authoring is deliberately admin-only and server-validated: a
// malformed stage list (missing stageId/order, non-positive minimumApprovals)
// would otherwise silently break decideApprovalRequest's transaction above.
exports.saveApprovalPolicy = onCall(async (request) => {
  const d = request.data || {}; const schoolId = String(d.institutionId || ""); const user = await approvalCaller(request, schoolId);
  if (!(user.permissions || []).includes("approvals.manage_policies") && !isApprovalAdmin(user)) throw new HttpsError("permission-denied", "You cannot manage approval policies.");
  for (const key of ["name", "moduleKey", "requestType"]) if (!String(d[key] || "").trim()) throw new HttpsError("invalid-argument", `${key} is required.`);
  let cleanStages;
  try {
    cleanStages = validatePolicyStages(d.stages);
  } catch (e) {
    throw new HttpsError("invalid-argument", e.message);
  }
  const db = admin.firestore();
  const policyId = String(d.approvalPolicyId || "").trim() || db.collection(`schools/${schoolId}/approval_policies`).doc().id;
  const ref = db.doc(`schools/${schoolId}/approval_policies/${policyId}`);
  await db.runTransaction(async (tx) => {
    const existing = await tx.get(ref);
    const version = existing.exists ? (existing.data().version || 1) + 1 : 1;
    tx.set(ref, {
      approvalPolicyId: policyId, institutionId: schoolId, name: String(d.name).trim(),
      moduleKey: String(d.moduleKey).trim(), requestType: String(d.requestType).trim(),
      stages: cleanStages, status: d.status === "archived" ? "archived" : "active",
      minimumApprovals: cleanStages[0]?.minimumApprovals || 1, version,
      sequential: d.sequential !== false, delegationAllowed: d.delegationAllowed === true,
      selfApprovalAllowed: d.selfApprovalAllowed === true, escalationAllowed: d.escalationAllowed !== false,
      requiresMfa: d.requiresMfa === true, requiresReauth: d.requiresReauth === true,
      dueTimeMinutes: d.dueTimeMinutes ? Number(d.dueTimeMinutes) : null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: request.auth.uid,
      createdAt: existing.exists ? existing.data().createdAt : admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: false });
  });
  return { policyId };
});

exports.createApprovalDelegation = onCall(async (request) => {
  const d = request.data || {}; const schoolId = String(d.institutionId || ""); const user = await approvalCaller(request, schoolId); if (!isApprovalAdmin(user)) throw new HttpsError("permission-denied", "Only an active approver may delegate."); const start = new Date(d.startsAt), end = new Date(d.endsAt); if (!(start < end) || end <= new Date()) throw new HttpsError("invalid-argument", "Delegation dates are invalid."); const delegate = await admin.firestore().doc(`users/${d.delegateId}`).get(); if (!delegate.exists || delegate.data().schoolId !== schoolId || delegate.data().isActive === false) throw new HttpsError("failed-precondition", "Delegate must be an active member of this institution."); await admin.firestore().collection(`schools/${schoolId}/approval_delegations`).add({ institutionId: schoolId, delegatorId: request.auth.uid, delegateId: d.delegateId, modules: d.modules || [], requestTypes: d.requestTypes || [], permissions: ["approvals.approve"], start: admin.firestore.Timestamp.fromDate(start), end: admin.firestore.Timestamp.fromDate(end), reason: String(d.reason || ""), status: "active", createdAt: admin.firestore.FieldValue.serverTimestamp() }); return { ok: true };
});

exports.escalateApprovalRequest = onCall(async (request) => {
  const d = request.data || {}; const schoolId = String(d.institutionId || ""); const user = await approvalCaller(request, schoolId); if (!isApprovalAdmin(user)) throw new HttpsError("permission-denied", "You cannot escalate this request."); const ref = approvalRef(schoolId, String(d.requestId)); await ref.update({ currentStatus: "escalated", version: admin.firestore.FieldValue.increment(1) }); await ref.collection("actions").add({ actorId: request.auth.uid, action: "escalated", stage: "", comment: String(d.reason || ""), timestamp: admin.firestore.FieldValue.serverTimestamp() }); return { ok: true };
});

// Policy-driven auto-escalation: a stage's own escalationTimeoutMinutes (or,
// failing that, the policy dueTimeMinutes) determines how long a request may
// sit unresolved before this scheduled sweep escalates it and logs why.
exports.autoEscalateApprovalRequests = onSchedule("every 15 minutes", async () => {
  await recordJobRun("autoEscalateApprovalRequests", 15, async () => {
  const db = admin.firestore();
  const schools = await db.collection("schools").get();
  for (const school of schools.docs) {
    const schoolId = school.id;
    const pending = await db.collection(`schools/${schoolId}/approval_requests`)
      .where("currentStatus", "in", ["pending", "partiallyApproved"]).get();
    if (pending.empty) continue;
    const policyCache = new Map();
    for (const doc of pending.docs) {
      const row = doc.data();
      if (!policyCache.has(row.approvalPolicyId)) {
        const p = await db.doc(`schools/${schoolId}/approval_policies/${row.approvalPolicyId}`).get();
        policyCache.set(row.approvalPolicyId, p.exists ? p.data() : null);
      }
      const policy = policyCache.get(row.approvalPolicyId);
      if (!policy || !policy.escalationAllowed) continue;
      const stage = (policy.stages || []).find((s) => s.stageId === row.currentStage);
      const timeoutMinutes = stage?.escalationTimeoutMinutes || policy.dueTimeMinutes;
      if (!timeoutMinutes) continue;
      const baseline = (row.submittedAt || row.createdAt);
      if (!baseline) continue;
      const dueAtMs = baseline.toMillis() + timeoutMinutes * 60000;
      if (Date.now() < dueAtMs) continue;
      await doc.ref.update({ currentStatus: "escalated", version: admin.firestore.FieldValue.increment(1) });
      await doc.ref.collection("actions").add({ actorId: "system", action: "escalated", stage: row.currentStage, comment: `Auto-escalated after ${timeoutMinutes} minutes without a decision.`, timestamp: admin.firestore.FieldValue.serverTimestamp() });
    }
  }
  });
});

function generateTemporaryPassword() {
  const bytes = randomBytes(12);
  let password = "";
  for (let i = 0; i < bytes.length; i++) {
    password += PASSWORD_CHARS[bytes[i] % PASSWORD_CHARS.length];
  }
  return password;
}

// Same first-letters-of-school-name prefix AdmissionReviewScreen derives
// client-side for student codes (_prefixFrom in
// admission_review_screen.dart) - duplicated here since Cloud Functions
// can't call Dart code, kept in sync by convention rather than a shared lib.
function schoolPrefixFrom(schoolName) {
  if (!schoolName || !schoolName.trim()) return "SCH";
  return schoolName
    .trim()
    .split(/\s+/)
    .map((w) => w[0])
    .slice(0, 3)
    .join("")
    .toUpperCase();
}

/**
 * Direct-enrolment finaliser.  The client can only save an untrusted draft;
 * this callable owns validation, capacity, idempotency and numbering in one
 * Firestore transaction.  It intentionally does not touch
 * admission_applications, which remain a separate review pipeline.
 */
exports.directEnrolLearner = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in to enrol a learner.");
  const draftId = String(request.data?.draftId || "");
  if (!draftId) throw new HttpsError("invalid-argument", "A draft is required.");
  const db = admin.firestore();
  const actorRef = db.collection("users").doc(request.auth.uid);
  const draftRef = db.collection("direct_enrolment_drafts").doc(draftId);
  const response = await db.runTransaction(async (tx) => {
    const [actorSnap, draftSnap] = await Promise.all([tx.get(actorRef), tx.get(draftRef)]);
    if (!actorSnap.exists) throw new HttpsError("permission-denied", "Your staff profile is unavailable.");
    if (!draftSnap.exists) throw new HttpsError("not-found", "This enrolment draft no longer exists.");
    const actor = actorSnap.data();
    const roles = Array.isArray(actor.roles) ? actor.roles : [actor.role];
    if (!roles.some((r) => ["schoolAdmin", "director", "headTeacher", "deputyHead", "admissions", "registrar", "receptionist"].includes(r))) {
      throw new HttpsError("permission-denied", "You do not have permission to enrol learners.");
    }
    const draft = draftSnap.data();
    if (!draft.schoolId || draft.schoolId !== actor.schoolId) throw new HttpsError("permission-denied", "This draft belongs to another school.");
    if (draft.createdBy !== request.auth.uid) throw new HttpsError("permission-denied", "This draft belongs to another user.");
    // An already-finalised draft may be retried after a dropped client
    // response. It must already point at a real learner; otherwise only a
    // draft status is allowed through to the finaliser.
    if (draft.status === "enrolled") {
      const enrolledId = String(draft.enrolledStudentId || draft.studentId || "");
      const enrolledStudent = enrolledId ? await tx.get(db.collection("students").doc(enrolledId)) : null;
      if (!enrolledStudent?.exists || enrolledStudent.data().schoolId !== draft.schoolId) {
        throw new HttpsError("failed-precondition", "This completed draft is invalid.");
      }
      return { studentId: enrolledId, studentNumber: enrolledStudent.data().admissionNumber, status: enrolledStudent.data().status, alreadyEnrolled: true, schoolId: draft.schoolId };
    }
    if (draft.status !== "draft") throw new HttpsError("failed-precondition", "This draft is no longer available for enrolment.");
    const learner = draft.learner || {}, placement = draft.placement || {};
    if (!String(learner.firstNames || "").trim() || !String(learner.surname || "").trim() || !String(learner.dateOfBirth || "").trim()) {
      throw new HttpsError("failed-precondition", "Learner legal names and date of birth are required.");
    }
    if (!placement.academicYearId || !placement.classId || !String(placement.term || "").trim()) {
      throw new HttpsError("failed-precondition", "Academic placement is incomplete.");
    }
    const guardians = Array.isArray(draft.guardians) ? draft.guardians : [];
    const overrideReason = String(draft.guardianOverride?.reason || "").trim();
    const canOverrideGuardian = roles.some((r) => ["schoolAdmin", "director", "headTeacher", "deputyHead", "admissions", "registrar"].includes(r));
    if (overrideReason && !canOverrideGuardian) {
      throw new HttpsError("permission-denied", "You do not have permission to use a guardian override.");
    }
    if (!guardians.length && !overrideReason) throw new HttpsError("failed-precondition", "Add a guardian or provide an authorised override reason.");
    // `consentAcknowledged` is the legacy single-checkbox flag; structured
    // consent (guardian_signs_now / secure_link / verbal) supersedes it via
    // `draft.guardianConsent`, written only by guardian_consent.js's
    // callables — never settable by the client directly.
    const consentValid = draft.consentAcknowledged === true ||
      (draft.guardianConsent && draft.guardianConsent.status === "captured");
    if (!consentValid) throw new HttpsError("failed-precondition", "Guardian consent must be captured before enrolment.");
    const studentId = String(draft.studentId || "");
    if (!studentId) throw new HttpsError("failed-precondition", "Draft has no learner identifier.");
    const studentRef = db.collection("students").doc(studentId);
    const existing = await tx.get(studentRef);
    if (existing.exists) {
      const data = existing.data();
      if (data.schoolId !== draft.schoolId) throw new HttpsError("permission-denied", "Learner identifier is invalid.");
      return { studentId, studentNumber: data.admissionNumber, status: data.status, alreadyEnrolled: true };
    }
    const classRef = db.collection("classes").doc(placement.classId);
    const classSnap = await tx.get(classRef);
    if (!classSnap.exists || classSnap.data().schoolId !== draft.schoolId) throw new HttpsError("failed-precondition", "Selected class is unavailable.");
    const classData = classSnap.data();
    // Querying the active roster inside the transaction makes the capacity
    // decision retry-safe under concurrent enrolments.
    const activeInClass = await tx.get(db.collection("students").where("schoolId", "==", draft.schoolId).where("classId", "==", placement.classId).where("status", "==", "active"));
    if (Number(classData.capacity || 0) > 0 && activeInClass.size >= Number(classData.capacity)) {
      throw new HttpsError("failed-precondition", "This class is at its configured capacity.");
    }
    const schoolRef = db.collection("schools").doc(draft.schoolId);
    const schoolSnap = await tx.get(schoolRef);
    const school = schoolSnap.exists ? schoolSnap.data() : {};
    const prefix = schoolPrefixFrom(school.name || actor.schoolName);
    const yearLabel = String(placement.academicYear || new Date().getFullYear());
    const counterRef = schoolRef.collection("counters").doc(`direct_student_${yearLabel.replace(/[^0-9A-Za-z]/g, "")}`);
    const counterSnap = await tx.get(counterRef);
    const sequence = Number(counterSnap.exists ? counterSnap.data().count || 0 : 0) + 1;
    const studentNumber = `${prefix}-${yearLabel}-${String(sequence).padStart(5, "0")}`;
    const requirements = Array.isArray(school.enrolmentPolicy?.documentRequirements) ? school.enrolmentPolicy.documentRequirements : [];
    const docs = Array.isArray(draft.documents) ? draft.documents.filter((d) => d && d.status === "uploaded") : [];
    const missingRequired = requirements.filter((r) => r.required && !docs.some((d) => d.requirementId === r.id));
    const permitsDeadline = missingRequired.every((r) => r.postEnrolmentDeadlineAllowed === true);
    if (missingRequired.length && !permitsDeadline) throw new HttpsError("failed-precondition", "Required documents are missing under school policy.");
    const status = missingRequired.length ? "provisional" : "active";
    tx.set(counterRef, { count: sequence, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    tx.set(studentRef, { schoolId: draft.schoolId, name: `${learner.firstNames.trim()} ${learner.surname.trim()}`, firstNames: learner.firstNames.trim(), surname: learner.surname.trim(), dateOfBirth: learner.dateOfBirth, gender: learner.sex || "other", nationality: learner.nationality || null, entryType: learner.entryType || "New admission", previousSchool: learner.entryType === "Transfer" ? (learner.previousSchool || null) : null, previousClass: learner.entryType === "Transfer" ? (learner.previousClass || null) : null, classId: placement.classId, className: placement.className || classData.name, academicYearId: placement.academicYearId, academicYear: placement.academicYear, term: placement.term, stream: placement.stream || null, admissionNumber: studentNumber, studentCode: studentNumber, status, directEnrolmentDraftId: draftId, createdAt: admin.firestore.FieldValue.serverTimestamp(), updatedAt: admin.firestore.FieldValue.serverTimestamp(), enrolledBy: request.auth.uid }, { merge: false });
    tx.set(db.collection("student_guardians").doc(studentId), { schoolId: draft.schoolId, studentId, guardians, updatedAt: admin.firestore.FieldValue.serverTimestamp(), updatedBy: request.auth.uid });
    tx.set(db.collection("student_services").doc(studentId), { schoolId: draft.schoolId, studentId, ...(draft.services || {}), updatedAt: admin.firestore.FieldValue.serverTimestamp() });
    if (String(draft.support || "").trim()) tx.set(db.collection("student_medical_support").doc(studentId), { schoolId: draft.schoolId, studentId, note: String(draft.support).trim(), updatedAt: admin.firestore.FieldValue.serverTimestamp(), updatedBy: request.auth.uid });
    for (const doc of docs) tx.set(studentRef.collection("documents").doc(String(doc.id)), { ...doc, schoolId: draft.schoolId, studentId, uploadedBy: request.auth.uid, uploadedAt: admin.firestore.FieldValue.serverTimestamp() });
    tx.set(draftRef, { status: "enrolled", enrolledStudentId: studentId, enrolledAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    const audit = (action, details) => tx.set(db.collection("audit_logs").doc(), { schoolId: draft.schoolId, actorId: request.auth.uid, module: "enrollment", action, targetType: "student", targetId: studentId, details, createdAt: admin.firestore.FieldValue.serverTimestamp() });
    audit("enrolment_activated", { draftId, studentNumber, status });
    audit("guardian_changed", { count: guardians.length });
    if (overrideReason) audit("guardian_override", { reason: overrideReason });
    for (const doc of docs) audit("document_uploaded", { documentId: doc.id, name: doc.name });
    return { studentId, studentNumber, status, alreadyEnrolled: false, schoolId: draft.schoolId };
  });

  // Best-effort, outside the enrolment transaction: a billing hiccup must
  // never roll back an already-created student. Mirrors the same pattern in
  // the 12-step enrolment wizard's activation flow (EnrollmentSetupWizardBloc).
  let billingWarning = null;
  const feePlanId = String(request.data?.feePlanId || "");
  if (!response.alreadyEnrolled && feePlanId) {
    try {
      const selectedOptionalLineIds = Array.isArray(request.data?.selectedOptionalLineIds)
        ? request.data.selectedOptionalLineIds : [];
      const billResult = await exports.issueStudentBillCore({
        schoolId: response.schoolId, studentId: response.studentId, planId: feePlanId,
        idempotencyKey: `${response.studentId}_${feePlanId}`,
        selectedOptionalLineIds, actorUid: request.auth.uid,
      });
      const bursary = request.data?.bursary;
      if (bursary && Number(bursary.amount) > 0) {
        await exports.applyBillAdjustmentCore({
          schoolId: response.schoolId, studentId: response.studentId, billId: billResult.billId,
          type: "scholarship", reason: String(bursary.reason || "Bursary awarded at enrolment"),
          amountUgx: bursary.isPercentage ? undefined : Math.round(Number(bursary.amount)),
          percentage: bursary.isPercentage ? Number(bursary.amount) : undefined,
          actorUid: request.auth.uid,
        });
      }
    } catch (e) {
      billingWarning = e.message || "Billing could not be issued yet. Retry from the student account.";
    }
  }
  return { ...response, billingWarning };
});

// Staff code shape mirrors the student code convention (prefix + year +
// sequence), e.g. SMAC260007. Uses the same transactional counter pattern
// as getNextSequenceNumber (student_remote_data_source.dart) so concurrent
// staff creation can never collide on the same number.
async function generateStaffCode(schoolId, schoolPrefix) {
  const year = new Date().getFullYear().toString().slice(-2);
  const counterRef = admin.firestore()
    .collection("schools").doc(schoolId)
    .collection("counters").doc(`staff_${year}`);

  const sequence = await admin.firestore().runTransaction(async (transaction) => {
    const snapshot = await transaction.get(counterRef);
    const next = (snapshot.exists ? (snapshot.data().count || 0) : 0) + 1;
    transaction.set(counterRef, { count: next }, { merge: true });
    return next;
  });

  return `${schoolPrefix}-T-${year}${String(sequence).padStart(4, "0")}`;
}

// Minimum time between invitations for the same staff member, mirroring the
// client-side 60s resend cooldown convention used elsewhere (see
// registration_bloc.dart) but enforced server-side since the client cannot
// be trusted to self-limit.
const STAFF_INVITATION_RESEND_COOLDOWN_MS = 60 * 1000;
// How long an unaccepted invitation stays valid before it must be resent.
const STAFF_INVITATION_TTL_MS = 7 * 24 * 60 * 60 * 1000;

/**
 * Issues (or reissues) a verified, time-limited sign-in invitation for an
 * existing staff Auth user. Never generates or stores a password - only a
 * Firebase Auth password-reset action link, which itself expires and proves
 * the recipient controls the mailbox before any password is set. Writes
 * invitation status/metadata to the server-only `staff_invitations`
 * collection; the raw link is emailed directly, never persisted or returned
 * to the caller.
 */
async function issueStaffInvitation({ db, schoolId, uid, email, name, roleLabel, actorUid }) {
  const invitationsRef = db.collection("staff_invitations");
  const latest = await invitationsRef
    .where("schoolId", "==", schoolId)
    .where("uid", "==", uid)
    .orderBy("createdAt", "desc")
    .limit(1)
    .get();

  const now = Date.now();
  if (!latest.empty) {
    const last = latest.docs[0].data();
    const lastCreatedMs = last.createdAt && last.createdAt.toMillis ? last.createdAt.toMillis() : 0;
    if (last.status !== "cancelled" && now - lastCreatedMs < STAFF_INVITATION_RESEND_COOLDOWN_MS) {
      throw new HttpsError(
        "resource-exhausted",
        "Please wait before resending another invitation."
      );
    }
  }

  const schoolDoc = await db.collection("schools").doc(schoolId).get();
  const setupLink = await admin.auth().generatePasswordResetLink(email.trim());
  const inviteRef = invitationsRef.doc();
  const expiresAt = admin.firestore.Timestamp.fromMillis(now + STAFF_INVITATION_TTL_MS);
  await inviteRef.set({
    schoolId,
    uid,
    email: email.trim(),
    status: "sent",
    createdBy: actorUid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt,
  });

  try {
    await enqueueTransactionalEmail({
      eventId: `staff_invite_${inviteRef.id}`,
      templateId: "staff_account_created",
      to: email.trim(),
      data: {
        schoolName: schoolDoc.exists ? (schoolDoc.data().name || "") : "",
        roleLabel: roleLabel || "",
        setupLink,
        email: email.trim(),
      },
    });
  } catch (err) {
    console.error("staff invitation email enqueue failed", uid, err);
    await inviteRef.set({ status: "failed" }, { merge: true });
    throw new HttpsError("internal", "Could not send the invitation email. Please try again.");
  }

  await db.collection("users").doc(uid).set({
    invitationStatus: "sent",
    invitationId: inviteRef.id,
  }, { merge: true });

  return { inviteId: inviteRef.id, expiresAt: expiresAt.toMillis() };
}

exports.createStaffInvitation = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
  const { uid } = request.data || {};
  if (typeof uid !== "string" || !uid.trim()) {
    throw new HttpsError("invalid-argument", "A staff member id is required.");
  }

  const db = admin.firestore();
  const callerDoc = await db.collection("users").doc(auth.uid).get();
  const callerData = callerDoc.exists ? callerDoc.data() : {};
  const callerRoles = Array.isArray(callerData.roles)
    ? callerData.roles
    : (callerData.role ? [callerData.role] : []);
  if (!callerRoles.some((r) => ADMIN_ROLES.includes(r))) {
    throw new HttpsError("permission-denied", "Only school administrators can send invitations.");
  }
  const schoolId = callerData.schoolId || null;
  if (!schoolId) {
    throw new HttpsError("failed-precondition", "Your administrator account is not assigned to a school.");
  }

  const staffDoc = await db.collection("users").doc(uid).get();
  if (!staffDoc.exists || staffDoc.data().schoolId !== schoolId) {
    // Cross-tenant/unknown target: same generic denial either way so this
    // cannot be used to probe which uids exist in other schools.
    throw new HttpsError("permission-denied", "Staff member not found.");
  }
  const staffData = staffDoc.data();

  const result = await issueStaffInvitation({
    db,
    schoolId,
    uid,
    email: staffData.email,
    name: staffData.name,
    roleLabel: staffData.role,
    actorUid: auth.uid,
  });

  await db.collection("audit_logs").add({
    schoolId,
    type: "staff_invitation_sent",
    targetUid: uid,
    actorUid: auth.uid,
    inviteId: result.inviteId,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { inviteId: result.inviteId, expiresAt: result.expiresAt, status: "sent" };
});

exports.cancelStaffInvitation = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
  const { uid } = request.data || {};
  if (typeof uid !== "string" || !uid.trim()) {
    throw new HttpsError("invalid-argument", "A staff member id is required.");
  }

  const db = admin.firestore();
  const callerDoc = await db.collection("users").doc(auth.uid).get();
  const callerData = callerDoc.exists ? callerDoc.data() : {};
  const callerRoles = Array.isArray(callerData.roles)
    ? callerData.roles
    : (callerData.role ? [callerData.role] : []);
  if (!callerRoles.some((r) => ADMIN_ROLES.includes(r))) {
    throw new HttpsError("permission-denied", "Only school administrators can cancel invitations.");
  }
  const schoolId = callerData.schoolId || null;
  if (!schoolId) {
    throw new HttpsError("failed-precondition", "Your administrator account is not assigned to a school.");
  }

  const staffDoc = await db.collection("users").doc(uid).get();
  if (!staffDoc.exists || staffDoc.data().schoolId !== schoolId) {
    throw new HttpsError("permission-denied", "Staff member not found.");
  }
  const invitationId = staffDoc.data().invitationId;
  if (invitationId) {
    await db.collection("staff_invitations").doc(invitationId).set(
      { status: "cancelled" },
      { merge: true }
    );
  }
  await db.collection("users").doc(uid).set({ invitationStatus: "cancelled" }, { merge: true });

  await db.collection("audit_logs").add({
    schoolId,
    type: "staff_invitation_cancelled",
    targetUid: uid,
    actorUid: auth.uid,
    inviteId: invitationId || null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { status: "cancelled" };
});

exports.createStaffAccount = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const {
    name, email, assignedClass, subjects, academicYearId,
    departmentId, designationId, campusId, employmentType, dateJoined,
    gender, phoneNumber, alternatePhone, address, nationality,
    emergencyContact, roleConfigs, idempotencyKey,
    sendLoginDetailsViaEmail = false,
    selectedPayComponentIds,
  } = request.data || {};
  // Accept the current multi-role `roles` array, falling back to a legacy
  // singular `role` from any older client build still calling this.
  const roles = Array.isArray(request.data?.roles)
    ? request.data.roles
    : (request.data?.role ? [request.data.role] : []);
  // "invite" (default): the staff member sets their own password through a
  // verified, time-limited invitation (see createStaffInvitation). "noLogin":
  // a staff profile with no ability to sign in until an administrator later
  // issues an invitation. Administrators never choose, see, or transmit a
  // password for either path - the Auth user below is always created with a
  // securely random, unguessable, never-returned password.
  const signInMethod = request.data?.signInMethod === "noLogin" ? "noLogin" : "invite";

  if (typeof name !== "string" || !name.trim()) {
    throw new HttpsError("invalid-argument", "Name is required.");
  }
  if (typeof email !== "string" || !email.trim()) {
    throw new HttpsError("invalid-argument", "Email is required.");
  }
  if (roles.length === 0 || !roles.every((r) => STAFF_ROLES.includes(r))) {
    throw new HttpsError("invalid-argument", "Invalid staff role.");
  }
  // The Admin SDK bypasses Firestore rules entirely, so this check is the
  // only gate on who may create staff accounts - it must happen here.
  const callerDoc = await admin.firestore().collection("users").doc(auth.uid).get();
  const callerData = callerDoc.exists ? callerDoc.data() : {};
  // Check the full roles array, not just the legacy singular `role` field -
  // a multi-role admin whose primary/first role isn't admin-flavored (e.g.
  // legacy data where `role` predates a later admin role grant) must still
  // pass this check if ANY of their roles qualifies.
  const callerRoles = Array.isArray(callerData.roles)
    ? callerData.roles
    : (callerData.role ? [callerData.role] : []);
  const schoolId = callerData.schoolId || null;
  if (!callerRoles.some((r) => ADMIN_ROLES.includes(r))) {
    throw new HttpsError("permission-denied", "Only school administrators can create staff accounts.");
  }
  if (!schoolId) {
    throw new HttpsError(
      "failed-precondition",
      "Your administrator account is not assigned to a school."
    );
  }

  // A Class Teacher role is meaningless without exactly one class, and a
  // Subject Teacher role is meaningless without at least one subject+class
  // pair - enforce both before touching Auth so a malformed request never
  // creates a half-usable account.
  if (roles.includes("classTeacher") && !assignedClass) {
    throw new HttpsError(
      "invalid-argument",
      "Select a class for the Class Teacher role."
    );
  }
  if (
    roles.includes("subjectTeacher") &&
    (!Array.isArray(subjects) || subjects.length === 0)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Add at least one subject and class for the Subject Teacher role."
    );
  }

  const db = admin.firestore();
  if (typeof idempotencyKey !== "string" || !/^[A-Za-z0-9_-]{16,128}$/.test(idempotencyKey)) {
    throw new HttpsError("invalid-argument", "A valid enrolment request key is required.");
  }
  // Stored before duplicate-email detection. A completed retry returns this
  // result and cannot create another Auth user, profile, assignment or email.
  const requestRef = db.collection("schools").doc(schoolId)
    .collection("staff_enrolment_requests").doc(idempotencyKey);
  const priorRequest = await requestRef.get();
  if (priorRequest.exists && priorRequest.data().status === "completed") {
    return { uid: priorRequest.data().uid, staffCode: priorRequest.data().staffCode,
      setupEmailQueued: priorRequest.data().setupEmailQueued === true, replayed: true };
  }
  if (priorRequest.exists && priorRequest.data().uid) {
    const existingProfile = await db.collection("users").doc(priorRequest.data().uid).get();
    if (existingProfile.exists) {
      return { uid: priorRequest.data().uid, staffCode: existingProfile.data().staffCode,
        setupEmailQueued: priorRequest.data().setupEmailQueued === true, replayed: true };
    }
  }

  // Duplicate-email guard ahead of Auth user creation: auth/email-already-
  // exists is still handled below as a fallback (e.g. a race, or an Auth
  // user with no Firestore profile from a prior partial failure), but
  // checking first gives a clean error for the common case without
  // spending an Auth write.
  const existingByEmail = await db
    .collection("users")
    .where("schoolId", "==", schoolId)
    .where("email", "==", email.trim())
    .limit(1)
    .get();
  if (!existingByEmail.empty) {
    throw new HttpsError("already-exists", "An account with this email already exists.");
  }

  const campusDocs = await db.collection("campuses").where("schoolId", "==", schoolId).where("isActive", "==", true).get();
  let resolvedCampusId = campusId || null;
  if (campusDocs.size === 1) resolvedCampusId = campusDocs.docs[0].id;
  if (campusDocs.size > 1 && !resolvedCampusId) {
    throw new HttpsError("invalid-argument", "Select a campus for this school.");
  }
  if (resolvedCampusId && !campusDocs.docs.some((doc) => doc.id === resolvedCampusId)) {
    throw new HttpsError("invalid-argument", "Selected campus does not belong to this school.");
  }
  // Department and designation (job title) are optional but, when supplied,
  // must belong to the calling school - same tenant-isolation check as
  // campus above, since a client-supplied id is otherwise trusted as-is.
  if (departmentId) {
    const department = await db.collection("departments").doc(departmentId).get();
    if (!department.exists || department.data().schoolId !== schoolId) {
      throw new HttpsError("invalid-argument", "Selected department does not belong to this school.");
    }
  }
  if (designationId) {
    const designation = await db.collection("staff_designations").doc(designationId).get();
    if (!designation.exists || designation.data().schoolId !== schoolId) {
      throw new HttpsError("invalid-argument", "Selected designation does not belong to this school.");
    }
  }

  // The canonical staff_role_assignments row is the only thing the teacher
  // panel and firestore.rules trust for "what can this account see" - it
  // must always be written for classTeacher/subjectTeacher, so resolve the
  // current academic year server-side rather than depending on a client
  // that may submit before its own async lookup finishes (or omits the
  // field entirely). A client-supplied academicYearId, if present, is
  // still honored so admin-selected historical/future years keep working.
  let resolvedAcademicYearId = academicYearId || null;
  if (!resolvedAcademicYearId && roles.some((r) => r === "classTeacher" || r === "subjectTeacher")) {
    const currentYear = await db
      .collection("academic_years")
      .where("schoolId", "==", schoolId)
      .where("isCurrent", "==", true)
      .limit(1)
      .get();
    if (currentYear.empty) {
      throw new HttpsError(
        "failed-precondition",
        "No current academic year is set up for this school. Set one before assigning teaching roles."
      );
    }
    resolvedAcademicYearId = currentYear.docs[0].id;
  }

  // Class/subject assignments arrive from the wizard as names (the UI only
  // has names today) - resolve them to the real ids the roster queries and
  // firestore.rules filter on, rather than perpetuating a name-keyed
  // shadow model. An unresolvable name fails the whole request: a
  // dangling className with no matching class would silently produce an
  // assignment nothing can ever query correctly.
  let classId = null;
  if (assignedClass) {
    const classQuery = await db
      .collection("classes")
      .where("schoolId", "==", schoolId)
      .where("name", "==", assignedClass)
      .limit(1)
      .get();
    if (classQuery.empty) {
      throw new HttpsError(
        "invalid-argument",
        `No class named "${assignedClass}" exists for this school.`
      );
    }
    classId = classQuery.docs[0].id;
  }

  const teachingSubjects = Array.isArray(subjects) ? subjects : [];
  const resolvedSubjectAssignments = [];
  for (const s of teachingSubjects) {
    const subjName = s && s.subjectName;
    const clsName = s && s.className;
    if (!subjName || !clsName) continue;
    const [subjectQuery, subjectClassQuery] = await Promise.all([
      db.collection("subjects").where("schoolId", "==", schoolId).where("name", "==", subjName).limit(1).get(),
      db.collection("classes").where("schoolId", "==", schoolId).where("name", "==", clsName).limit(1).get(),
    ]);
    if (subjectQuery.empty) {
      throw new HttpsError("invalid-argument", `No subject named "${subjName}" exists for this school.`);
    }
    if (subjectClassQuery.empty) {
      throw new HttpsError("invalid-argument", `No class named "${clsName}" exists for this school.`);
    }
    resolvedSubjectAssignments.push({
      subjectId: subjectQuery.docs[0].id,
      subjectName: subjName,
      classId: subjectClassQuery.docs[0].id,
      className: clsName,
    });
  }

  // Never an admin-chosen or admin-visible value - only ever used once,
  // internally, to satisfy Auth's createUser requirement, then discarded.
  // The staff member's only path to a usable password is either the
  // invitation flow (createStaffInvitation) or, for signInMethod "noLogin",
  // a later invitation an administrator deliberately issues.
  const temporaryPassword = generateTemporaryPassword();

  const schoolDoc = await db.collection("schools").doc(schoolId).get();
  const schoolPrefix = schoolPrefixFrom(schoolDoc.exists ? schoolDoc.data().name : null);
  const staffCode = await generateStaffCode(schoolId, schoolPrefix);

  let userRecord;
  try {
    userRecord = await admin.auth().createUser({
      email: email.trim(),
      password: temporaryPassword,
      displayName: name.trim(),
    });
    // Persist the created uid before any Firestore batch/email work. This
    // turns a network retry after Auth success into a recoverable replay.
    await requestRef.set({ status: "auth_created", uid: userRecord.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  } catch (err) {
    if (err.code === "auth/email-already-exists") {
      throw new HttpsError("already-exists", "An account with this email already exists.");
    }
    throw new HttpsError("internal", err.message || "Failed to create the account.");
  }

  try {
    const userData = {
      name: name.trim(),
      email: email.trim(),
      role: roles[0],
      roles,
      schoolId,
      staffCode,
      studentIds: [],
      // The staff member always sets their own password (invite or a later
      // deliberate invite for noLogin) - there is no admin-set password to
      // force a change away from, so this simply tracks "has never signed
      // in yet" for UI purposes.
      mustChangePassword: true,
      setupRequired: true,
      signInMethod,
      sendLoginDetailsViaEmail: sendLoginDetailsViaEmail === true,
      createdBy: auth.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      ...(assignedClass ? { assignedClass } : {}),
      ...(Array.isArray(subjects) ? { subjects } : {}),
      ...(departmentId ? { departmentId } : {}),
      ...(designationId ? { designationId } : {}),
      ...(resolvedCampusId ? { campusId: resolvedCampusId } : {}),
      ...(employmentType ? { employmentType } : {}),
      ...(dateJoined ? { dateJoined: new Date(dateJoined) } : {}),
      ...(gender ? { gender } : {}),
      ...(phoneNumber ? { phoneNumber } : {}),
      ...(alternatePhone ? { alternatePhone } : {}),
      ...(address ? { address } : {}),
      ...(nationality ? { nationality } : {}),
      ...(emergencyContact && typeof emergencyContact === "object" ? { emergencyContact } : {}),
    };
    const batch = db.batch();
    batch.set(db.collection("users").doc(userRecord.uid), userData);
    batch.set(db.collection("school_contacts").doc(userRecord.uid), {
      name: name.trim(),
      role: roles[0],
      roles,
      schoolId,
      staffCode,
      isActive: true,
    });

    // The canonical staff_role_assignments row is what the teacher panel
    // and firestore.rules actually trust - always written (never gated on
    // an optional field) whenever the role requires it, with real
    // classId/subjectId so downstream roster/rules queries resolve.
    const assignmentsRef = db.collection("schools").doc(schoolId).collection("staff_role_assignments");
    const now = admin.firestore.FieldValue.serverTimestamp();

    if (roles.includes("subjectTeacher")) {
      for (const s of resolvedSubjectAssignments) {
        batch.set(assignmentsRef.doc(), {
          schoolId,
          staffId: userRecord.uid,
          userId: userRecord.uid,
          roleType: "subjectTeacher",
          academicYearId: resolvedAcademicYearId,
          subjectId: s.subjectId,
          subjectName: s.subjectName,
          classId: s.classId,
          className: s.className,
          startDate: now,
          status: "active",
          permissionScope: {
            permissions: RESPONSIBILITY_DEFAULT_PERMISSIONS.subjectTeacher,
            subjectId: s.subjectId,
            classId: s.classId,
            academicYearId: resolvedAcademicYearId,
            termIds: [],
          },
          assignedBy: auth.uid,
          assignedAt: now,
        });
      }
    }
    if (roles.includes("classTeacher")) {
      batch.set(assignmentsRef.doc(), {
        schoolId,
        staffId: userRecord.uid,
        userId: userRecord.uid,
        roleType: "classTeacher",
        academicYearId: resolvedAcademicYearId,
        classId,
        className: assignedClass,
        startDate: now,
        status: "active",
        permissionScope: {
          permissions: RESPONSIBILITY_DEFAULT_PERMISSIONS.classTeacher,
          classId,
          academicYearId: resolvedAcademicYearId,
          termIds: [],
        },
        assignedBy: auth.uid,
        assignedAt: now,
      });
    }
    // Non-teaching responsibilities: one row per role that maps to a
    // responsibility type, unconstrained by subject/class (nulls in
    // PermissionScope mean "unconstrained" per its own doc comment).
    for (const role of roles) {
      const responsibilityType = ROLE_TO_RESPONSIBILITY_TYPE[role];
      if (!responsibilityType || responsibilityType === "classTeacher" || responsibilityType === "subjectTeacher") {
        continue;
      }
      const config = roleConfigs && roleConfigs[role] || {};
      batch.set(assignmentsRef.doc(), {
        schoolId,
        staffId: userRecord.uid,
        userId: userRecord.uid,
        roleType: responsibilityType,
        academicYearId: resolvedAcademicYearId,
        startDate: now,
        status: "active",
        permissionScope: {
          permissions: RESPONSIBILITY_DEFAULT_PERMISSIONS[responsibilityType] || [],
          termIds: [],
          // Omitted means unrestricted; an explicitly supplied empty/null
          // scope is retained as configured rather than widened silently.
          ...(Object.prototype.hasOwnProperty.call(config, "departmentId") ? { departmentId: config.departmentId } : {}),
          ...(Object.prototype.hasOwnProperty.call(config, "facilityId") ? { facilityId: config.facilityId } : {}),
          ...(Object.prototype.hasOwnProperty.call(config, "routeId") ? { routeId: config.routeId } : {}),
          ...(Object.prototype.hasOwnProperty.call(config, "dormitoryWing") ? { dormitoryWing: config.dormitoryWing } : {}),
          ...(Object.prototype.hasOwnProperty.call(config, "approvalScope") ? { approvalScope: config.approvalScope } : {}),
        },
        assignedBy: auth.uid,
        assignedAt: now,
      });
    }

    await batch.commit();
  } catch (err) {
    // Don't leave an orphaned Auth user with no matching profile doc - a
    // retry with the same email would otherwise permanently fail with
    // already-exists with no way for the admin to recover.
    await admin.auth().deleteUser(userRecord.uid).catch(() => {});
    throw new HttpsError("internal", err.message || "Failed to save the staff profile.");
  }

  // "noLogin" leaves the staff member unable to sign in until an
  // administrator deliberately calls createStaffInvitation later - no Auth
  // action link is generated or emailed here for that path.
  let setupEmailQueued = false;
  if (signInMethod === "invite") {
    try {
      await issueStaffInvitation({
        db,
        schoolId,
        uid: userRecord.uid,
        email: email.trim(),
        name: name.trim(),
        roleLabel: roles[0],
        actorUid: auth.uid,
      });
      setupEmailQueued = true;
    } catch (err) {
      console.error("staff invitation issue failed", userRecord.uid, err);
    }
  }
  await requestRef.set({ status: "completed", uid: userRecord.uid, staffCode,
    setupEmailQueued, emailQueuedAt: setupEmailQueued ? admin.firestore.FieldValue.serverTimestamp() : null,
    createdAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });

  // Best-effort, outside the staff-creation transaction: a pay-structure
  // lookup hiccup must never roll back an already-created staff account.
  // Mirrors the same pattern in directEnrolLearner's fee-billing hook.
  // Persists which optional pay components this staff member opted into
  // (e.g. responsibility allowance) so the existing payroll module
  // (functions has no separate "issue pay" callable yet - see
  // lib/features/hr/) can read them back when generating a pay run.
  if (designationId) {
    try {
      const structures = await db.collection(`schools/${schoolId}/salary_structures`)
        .where("status", "==", "published")
        .where("selector.designationId", "==", designationId)
        .limit(1)
        .get();
      if (!structures.empty) {
        const structure = structures.docs[0].data();
        await db.doc(`users/${userRecord.uid}`).set({
          payStructure: {
            structureId: structures.docs[0].id,
            versionId: structure.currentVersionId,
            selectedOptionalComponentIds: Array.isArray(selectedPayComponentIds) ? selectedPayComponentIds : [],
          },
        }, { merge: true });
      }
    } catch (err) {
      console.error("staff pay-structure lookup failed", userRecord.uid, err);
    }
  }

  return { uid: userRecord.uid, staffCode, setupEmailQueued };
});

// Resets a staff member's Firebase Auth password to a new random temporary
// one and flips mustChangePassword, so they're prompted to set their own on
// next login - mirrors createStaffAccount's admin-gate + temp-password
// pattern above, since only the Admin SDK (never the client) can set
// another user's Auth password.
exports.adminResetStaffPassword = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const { userId } = request.data || {};
  if (typeof userId !== "string" || !userId.trim()) {
    throw new HttpsError("invalid-argument", "userId is required.");
  }

  const db = admin.firestore();

  const callerDoc = await db.collection("users").doc(auth.uid).get();
  const callerData = callerDoc.exists ? callerDoc.data() : {};
  const callerRoles = Array.isArray(callerData.roles)
    ? callerData.roles
    : (callerData.role ? [callerData.role] : []);
  if (!callerRoles.some((r) => ADMIN_ROLES.includes(r))) {
    throw new HttpsError("permission-denied", "Only school administrators can reset staff passwords.");
  }
  const callerSchoolId = callerData.schoolId || null;
  if (!callerSchoolId) {
    throw new HttpsError(
      "failed-precondition",
      "Your administrator account is not assigned to a school."
    );
  }

  const targetDoc = await db.collection("users").doc(userId).get();
  if (!targetDoc.exists) {
    throw new HttpsError("not-found", "Staff member not found.");
  }
  const targetData = targetDoc.data();
  // Tenant boundary: an admin may only reset passwords for staff in their
  // own school, same guard shape as toggleStaffActiveStatus's Firestore rule.
  if (targetData.schoolId !== callerSchoolId) {
    throw new HttpsError("permission-denied", "That staff member belongs to a different school.");
  }

  const temporaryPassword = generateTemporaryPassword();

  try {
    await admin.auth().updateUser(userId, { password: temporaryPassword });
  } catch (err) {
    if (err.code === "auth/user-not-found") {
      throw new HttpsError("not-found", "No Auth account found for this staff member.");
    }
    throw new HttpsError("internal", err.message || "Failed to reset the password.");
  }

  await db.collection("users").doc(userId).update({
    mustChangePassword: true,
  });

  if (targetData.email) {
    await enqueueTransactionalEmail({
      eventId: `password_changed_${userId}_${Date.now()}`,
      templateId: "password_changed",
      to: targetData.email,
      data: {
        email: targetData.email,
        whenLabel: new Date().toLocaleString("en-GB", {
          day: "numeric", month: "long", year: "numeric", hour: "2-digit", minute: "2-digit",
        }),
      },
    }).catch((err) => console.error("password_changed email enqueue failed", userId, err));
  }

  return { temporaryPassword };
});

// Deactivating a staff member only ever flipped the Firestore `isActive`
// flag; the Firebase Auth account itself stayed enabled indefinitely, so a
// deactivated staff member's existing credentials remained valid for
// anything that doesn't go through this app's own profile-fetch gate (e.g.
// direct Firestore/Auth SDK usage). This mirrors the disabled state onto the
// actual Auth account server-side, same admin/tenant guard shape as
// adminResetStaffPassword.
exports.setStaffAuthDisabled = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const { userId, disabled } = request.data || {};
  if (typeof userId !== "string" || !userId.trim()) {
    throw new HttpsError("invalid-argument", "userId is required.");
  }
  if (typeof disabled !== "boolean") {
    throw new HttpsError("invalid-argument", "disabled must be a boolean.");
  }

  const db = admin.firestore();

  const callerDoc = await db.collection("users").doc(auth.uid).get();
  const callerData = callerDoc.exists ? callerDoc.data() : {};
  const callerRoles = Array.isArray(callerData.roles)
    ? callerData.roles
    : (callerData.role ? [callerData.role] : []);
  if (!callerRoles.some((r) => ADMIN_ROLES.includes(r))) {
    throw new HttpsError("permission-denied", "Only school administrators can change staff account status.");
  }
  const callerSchoolId = callerData.schoolId || null;
  if (!callerSchoolId) {
    throw new HttpsError(
      "failed-precondition",
      "Your administrator account is not assigned to a school."
    );
  }

  const targetDoc = await db.collection("users").doc(userId).get();
  if (!targetDoc.exists) {
    throw new HttpsError("not-found", "Staff member not found.");
  }
  const targetData = targetDoc.data();
  if (targetData.schoolId !== callerSchoolId) {
    throw new HttpsError("permission-denied", "That staff member belongs to a different school.");
  }

  try {
    await admin.auth().updateUser(userId, { disabled });
  } catch (err) {
    if (err.code === "auth/user-not-found") {
      // Firestore-only profile with no Auth account yet - nothing to sync.
      return { ok: true };
    }
    throw new HttpsError("internal", err.message || "Failed to update the account status.");
  }

  return { ok: true };
});

// Revokes every refresh token for the caller. Firebase Auth does not expose
// individual-device sessions to clients, so a server-side revoke is the only
// reliable way to remove access from a lost or untrusted device. The caller is
// signed out locally immediately afterwards by ActiveSessionsScreen.
exports.revokeAllSessions = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  try {
    await admin.auth().revokeRefreshTokens(request.auth.uid);

    const userDoc = await admin.firestore().collection("users").doc(request.auth.uid).get();
    const email = userDoc.exists ? userDoc.data().email : null;
    if (email) {
      await enqueueTransactionalEmail({
        eventId: `sessions_revoked_${request.auth.uid}_${Date.now()}`,
        templateId: "sessions_revoked",
        to: email,
        data: { email, reason: "You signed out of all devices." },
      }).catch((err) => console.error("sessions_revoked email enqueue failed", request.auth.uid, err));
    }

    return { revoked: true };
  } catch (err) {
    throw new HttpsError(
      "internal",
      err.message || "Unable to revoke active sessions.",
    );
  }
});

// ---------------------------------------------------------------------------
// Institution Security Center
// ---------------------------------------------------------------------------
// Firebase Auth deliberately does not expose per-device refresh-token
// revocation.  The records below are therefore an institution-scoped security
// registry and every destructive action revokes the target user's refresh
// tokens server-side as well as recording why it happened. No token, OTP or
// device fingerprint is ever stored here.
const SECURITY_ADMIN_ROLES = ["director", "headTeacher", "schoolAdmin"];

function securityError(code, message) {
  throw new HttpsError(code, message);
}

async function securityActor(request) {
  if (!request.auth) securityError("unauthenticated", "You must be signed in.");
  const ref = admin.firestore().collection("users").doc(request.auth.uid);
  const snap = await ref.get();
  if (!snap.exists) securityError("permission-denied", "Your account profile is unavailable.");
  const data = snap.data();
  const roles = Array.isArray(data.roles) ? data.roles : [data.role].filter(Boolean);
  const permissions = Array.isArray(data.permissions) ? data.permissions : [];
  if (!data.schoolId || !data.isActive) securityError("permission-denied", "Your institution access is not active.");
  return { uid: request.auth.uid, data, roles, permissions, schoolId: data.schoolId };
}

function canSecurity(actor, permission) {
  return SECURITY_ADMIN_ROLES.some((role) => actor.roles.includes(role)) || actor.permissions.includes(permission);
}

async function requireSecurity(actor, permission) {
  if (!canSecurity(actor, permission)) securityError("permission-denied", "You do not have this security permission.");
}

function requireReason(value) {
  if (typeof value !== "string" || value.trim().length < 3) {
    securityError("invalid-argument", "A reason of at least 3 characters is required.");
  }
  return value.trim().slice(0, 500);
}

async function auditSecurity({ schoolId, actorId, type, targetUserId = null, targetId = null, reason = null, riskLevel = "informational", metadata = {} }) {
  const db = admin.firestore();
  const event = {
    institutionId: schoolId, schoolId, actorId, targetUserId, targetId, type,
    reason, riskLevel, metadata, timestamp: admin.firestore.FieldValue.serverTimestamp(),
  };
  await Promise.all([
    db.collection("schools").doc(schoolId).collection("security_events").add(event),
    db.collection("audit_logs").add({
      schoolId, title: type, description: reason || type,
      iconName: "gpp_maybe", colorHex: "FFB3261E", timestamp: admin.firestore.FieldValue.serverTimestamp(),
      userId: actorId, relatedEntityId: targetId || targetUserId,
    }),
  ]);
}

exports.registerSecuritySession = onCall(async (request) => {
  const actor = await securityActor(request);
  const data = request.data || {};
  const deviceId = typeof data.deviceId === "string" ? data.deviceId.trim() : "";
  if (!deviceId || deviceId.length > 160) securityError("invalid-argument", "A valid device ID is required.");
  const db = admin.firestore();
  const sessionRef = db.collection("schools").doc(actor.schoolId).collection("security_sessions").doc(deviceId);
  const deviceRef = db.collection("schools").doc(actor.schoolId).collection("trusted_devices").doc(deviceId);
  const now = admin.firestore.FieldValue.serverTimestamp();
  await db.runTransaction(async (tx) => {
    const previous = await tx.get(deviceRef);
    const previousStatus = previous.exists ? previous.data().trustStatus : null;
    if (previousStatus === "blocked") {
      securityError("permission-denied", "This device has been blocked. Contact your institution administrator.");
    }
    const trusted = previousStatus === "trusted";
    tx.set(deviceRef, {
      deviceId, institutionId: actor.schoolId, userId: actor.uid,
      deviceName: String(data.deviceName || "Unknown device").slice(0, 120),
      platform: String(data.platform || "Unknown").slice(0, 60),
      appVersion: String(data.appVersion || "Unknown").slice(0, 60),
      firstSeenAt: previous.exists ? previous.data().firstSeenAt : now,
      // A revoked device stays revoked until an administrator explicitly
      // changes its state; a routine sign-in heartbeat must never silently
      // restore trust or erase lost-device history.
      lastSeenAt: now, trustStatus: previousStatus || "unknown",
      riskLevel: trusted ? "low" : "medium", revokedAt: null,
    }, { merge: true });
    tx.set(sessionRef, {
      sessionId: deviceId, institutionId: actor.schoolId, userId: actor.uid,
      accountType: actor.roles[0] || "unknown", activeWorkspace: "school",
      deviceId, deviceName: String(data.deviceName || "Unknown device").slice(0, 120),
      platform: String(data.platform || "Unknown").slice(0, 60),
      appVersion: String(data.appVersion || "Unknown").slice(0, 60),
      createdAt: now, lastActivityAt: now, expiresAt: null,
      trustedDevice: trusted, sessionStatus: "active", revokedAt: null, revokedBy: null,
      revokeReason: null, riskLevel: trusted ? "low" : "medium",
      authenticationMethod: "firebase_auth", mfaVerified: !!actor.data.mfaEnabled,
    }, { merge: true });
  });
  return { registered: true };
});

// Intentionally callable before authentication: it records only a one-way
// identifier hash and coarse failure category. It never reveals whether an
// account exists. The deterministic five failures/15 minutes rule is simple,
// explainable and creates a high-risk alert rather than claiming AI detection.
exports.recordSecurityLoginFailure = onCall(async (request) => {
  const identifier = typeof request.data?.identifier === "string" ? request.data.identifier.trim().toLowerCase() : "";
  if (!identifier || identifier.length > 320) return { recorded: false };
  const db = admin.firestore();
  const hash = createHash("sha256").update(identifier).digest("hex");
  const matches = await db.collection("users").where("email", "==", identifier).limit(1).get();
  if (matches.empty) return { recorded: true };
  const user = matches.docs[0];
  const schoolId = user.data().schoolId;
  if (!schoolId) return { recorded: true };
  const events = db.collection("schools").doc(schoolId).collection("security_events");
  // Imported from the dedicated firestore submodule rather than read as
  // `admin.firestore.FieldValue`: under `firebase emulators:start`,
  // `admin.firestore` (the static attached to the `firestore()` accessor
  // function) has been observed to have no own properties at all, even
  // though `admin.firestore()` itself works - so the inline property read
  // throws "Cannot read properties of undefined" (repros deterministically
  // in this multi-codebase project's emulator, never seen in production).
  const { FieldValue } = require("firebase-admin/firestore");
  await events.add({ institutionId: schoolId, schoolId, userId: user.id, loginIdentifierHash: hash, success: false, failureReasonCategory: "authentication_failed", type: "Login failure", riskLevel: "low", timestamp: FieldValue.serverTimestamp() });
  const since = admin.firestore.Timestamp.fromMillis(Date.now() - 15 * 60 * 1000);
  const recent = await events.where("userId", "==", user.id).where("type", "==", "Login failure").where("timestamp", ">=", since).get();
  if (recent.size >= 5) {
    await admin.auth().updateUser(user.id, { disabled: true });
    await user.ref.set({ isActive: false, securityStatus: "locked", lockedAt: FieldValue.serverTimestamp(), lockReason: "Repeated failed login attempts" }, { merge: true });
    await events.add({ institutionId: schoolId, schoolId, userId: user.id, type: "Account locked", riskLevel: "high", reason: "Five failed logins within 15 minutes", timestamp: FieldValue.serverTimestamp() });
  }
  return { recorded: true };
});

async function targetInSchool(db, schoolId, userId) {
  if (typeof userId !== "string" || !userId) securityError("invalid-argument", "A target user is required.");
  const target = await db.collection("users").doc(userId).get();
  if (!target.exists || target.data().schoolId !== schoolId) securityError("permission-denied", "The target does not belong to your institution.");
  const roles = Array.isArray(target.data().roles) ? target.data().roles : [target.data().role].filter(Boolean);
  if (roles.includes("superAdmin")) securityError("permission-denied", "School administrators cannot manage platform-owner sessions.");
  return target;
}

async function revokeTargetSessions({ actor, targetUserId, reason, sessionId = null, type = "Session revoked" }) {
  const db = admin.firestore();
  await targetInSchool(db, actor.schoolId, targetUserId);
  // Token invalidation is intentionally server-side. It invalidates all of
  // the target's Firebase refresh tokens, which is the strongest behavior
  // Firebase Auth supports for a lost/untrusted device.
  await admin.auth().revokeRefreshTokens(targetUserId);
  const sessions = await db.collection("schools").doc(actor.schoolId)
    .collection("security_sessions").where("userId", "==", targetUserId).get();
  const batch = db.batch();
  for (const doc of sessions.docs) {
    // Firebase Auth can only revoke the user's refresh-token set, so every
    // registry entry must be marked revoked even when the action began from
    // one device row. Leaving sibling rows active would be misleading.
    batch.set(doc.ref, { sessionStatus: "revoked", revokedAt: admin.firestore.FieldValue.serverTimestamp(), revokedBy: actor.uid, revokeReason: reason }, { merge: true });
  }
  batch.set(db.collection("users").doc(targetUserId), { sessionVersion: admin.firestore.FieldValue.increment(1) }, { merge: true });
  await batch.commit();
  await auditSecurity({ schoolId: actor.schoolId, actorId: actor.uid, type, targetUserId, targetId: sessionId, reason, riskLevel: "high" });
}

exports.revokeInstitutionSession = onCall(async (request) => {
  const actor = await securityActor(request);
  await requireSecurity(actor, "security.revoke_session");
  const data = request.data || {};
  const reason = requireReason(data.reason);
  if (data.targetUserId === actor.uid && data.confirmSelf !== true) {
    securityError("failed-precondition", "Confirm self-revocation before signing yourself out.");
  }
  await revokeTargetSessions({ actor, targetUserId: data.targetUserId, sessionId: data.sessionId, reason });
  return { revoked: true, scope: "all_target_sessions" };
});

exports.revokeAllInstitutionUserSessions = onCall(async (request) => {
  const actor = await securityActor(request);
  await requireSecurity(actor, "security.revoke_all_sessions");
  const data = request.data || {};
  const reason = requireReason(data.reason);
  if (data.targetUserId === actor.uid && data.confirmSelf !== true) securityError("failed-precondition", "Confirm self-revocation before signing yourself out.");
  await revokeTargetSessions({ actor, targetUserId: data.targetUserId, reason, type: "All sessions revoked" });
  return { revoked: true };
});

exports.setTrustedDeviceStatus = onCall(async (request) => {
  const actor = await securityActor(request);
  await requireSecurity(actor, "security.manage_device_trust");
  const data = request.data || {};
  const reason = requireReason(data.reason);
  const status = data.status;
  if (!["trusted", "untrusted", "revoked", "blocked"].includes(status)) securityError("invalid-argument", "Invalid device trust status.");
  const db = admin.firestore();
  const ref = db.collection("schools").doc(actor.schoolId).collection("trusted_devices").doc(data.deviceId || "");
  const snap = await ref.get();
  if (!snap.exists) securityError("not-found", "Device not found.");
  await ref.set({ trustStatus: status, trustedAt: status === "trusted" ? admin.firestore.FieldValue.serverTimestamp() : null, trustedBy: actor.uid, revokedAt: ["revoked", "blocked"].includes(status) ? admin.firestore.FieldValue.serverTimestamp() : null, revokeReason: reason }, { merge: true });
  if (["untrusted", "revoked", "blocked"].includes(status)) await revokeTargetSessions({ actor, targetUserId: snap.data().userId, reason, sessionId: data.deviceId, type: "Device " + status });
  else await auditSecurity({ schoolId: actor.schoolId, actorId: actor.uid, type: "Device trusted", targetUserId: snap.data().userId, targetId: data.deviceId, reason });
  return { updated: true };
});

exports.setInstitutionAccountLock = onCall(async (request) => {
  const actor = await securityActor(request);
  const data = request.data || {};
  await requireSecurity(actor, data.locked ? "security.lock_account" : "security.unlock_account");
  const reason = requireReason(data.reason);
  const db = admin.firestore();
  await targetInSchool(db, actor.schoolId, data.targetUserId);
  await admin.auth().updateUser(data.targetUserId, { disabled: !!data.locked });
  await db.collection("users").doc(data.targetUserId).set({ isActive: !data.locked, securityStatus: data.locked ? "locked" : "active", lockedAt: data.locked ? admin.firestore.FieldValue.serverTimestamp() : null, lockReason: reason }, { merge: true });
  if (data.locked) await revokeTargetSessions({ actor, targetUserId: data.targetUserId, reason, type: "Account locked" });
  else await auditSecurity({ schoolId: actor.schoolId, actorId: actor.uid, type: "Account unlocked", targetUserId: data.targetUserId, reason, riskLevel: "medium" });
  return { updated: true };
});

exports.requireInstitutionPasswordReset = onCall(async (request) => {
  const actor = await securityActor(request);
  await requireSecurity(actor, "security.force_password_reset");
  const data = request.data || {};
  const reason = requireReason(data.reason);
  const db = admin.firestore();
  await targetInSchool(db, actor.schoolId, data.targetUserId);
  await db.collection("users").doc(data.targetUserId).set({ mustChangePassword: true, passwordResetRequiredAt: admin.firestore.FieldValue.serverTimestamp(), passwordResetInitiatedBy: actor.uid }, { merge: true });
  if (data.revokeSessions !== false) await revokeTargetSessions({ actor, targetUserId: data.targetUserId, reason, type: "Password reset required" });
  else await auditSecurity({ schoolId: actor.schoolId, actorId: actor.uid, type: "Password reset required", targetUserId: data.targetUserId, reason, riskLevel: "high" });
  return { updated: true };
});

// ============================================================================
// Owner Support Mode
//
// Lets the SaaS owner briefly act as a school's admin to help with support
// requests, without ever handling that admin's password. The owner's own
// session is intentionally left alone in Firebase Auth (revoked sessions on
// exit would lock them out): the client is expected to sign out of the
// owner session and into the minted admin session, then reverse that on
// exit. Every entry/exit is audited, and a server-side support_mode_sessions
// doc is the source of truth for "is this session still valid" so a leaked
// custom token can't outlive its window even if the client never calls
// exitSupportMode.
// ============================================================================
const SUPPORT_MODE_TTL_MS = 30 * 60 * 1000; // 30 minutes

exports.enterSupportMode = onCall(async (request) => {
  // Legacy custom-token impersonation is intentionally retired. Institution
  // support now requires the explicit, scoped and revocable support-access
  // contract in support_audit.js; minting an admin identity bypasses that
  // contract and makes it impossible to distinguish support actions.
  throw new HttpsError("failed-precondition", "Legacy support impersonation is disabled. Request institution-approved scoped support access instead.");
  const owner = await requireOwner(request);
  const auth = request.auth;

  const { schoolId, reason } = request.data || {};
  if (typeof schoolId !== "string" || !schoolId.trim()) {
    throw new HttpsError("invalid-argument", "schoolId is required.");
  }
  if (typeof reason !== "string" || reason.trim().length < 3) {
    throw new HttpsError("invalid-argument", "A reason of at least 3 characters is required.");
  }

  const db = admin.firestore();

  const schoolDoc = await db.collection("schools").doc(schoolId).get();
  if (!schoolDoc.exists) {
    throw new HttpsError("not-found", "School not found.");
  }

  const adminQuery = await db
    .collection("users")
    .where("schoolId", "==", schoolId)
    .where("role", "==", "schoolAdmin")
    .limit(1)
    .get();
  if (adminQuery.empty) {
    throw new HttpsError(
      "failed-precondition",
      "This school has no school admin account to support.",
    );
  }
  const adminDoc = adminQuery.docs[0];
  const adminData = adminDoc.data();

  const now = Date.now();
  const expiresAt = now + SUPPORT_MODE_TTL_MS;

  // Source of truth for session validity - Firestore rules for
  // school-scoped collections can check this to deny writes past expiry
  // even if the minted token is still technically unexpired.
  await db.collection("support_mode_sessions").doc(auth.uid).set({
    ownerId: auth.uid,
    schoolId,
    adminUid: adminDoc.id,
    reason: reason.trim(),
    startedAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt: admin.firestore.Timestamp.fromMillis(expiresAt),
  });

  await db.collection("super_admin_audit_logs").add({
    ownerId: auth.uid,
    action: "ENTER_SUPPORT_MODE",
    schoolId,
    affectedUserId: adminDoc.id,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    device: "Platform Dashboard",
    reason: reason.trim(),
    metadata: {},
  });

  const token = await admin.auth().createCustomToken(adminDoc.id, {
    supportMode: true,
    actingOwnerId: auth.uid,
  });

  return {
    token,
    adminUid: adminDoc.id,
    adminName: adminData.name || adminData.email || "School Admin",
    schoolName: schoolDoc.data().name || "",
    expiresAt,
  };
});

exports.exitSupportMode = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const { ownerId, schoolId } = request.data || {};
  if (typeof ownerId !== "string" || !ownerId.trim()) {
    throw new HttpsError("invalid-argument", "ownerId is required.");
  }

  const db = admin.firestore();

  // Called while signed in as the impersonated admin (auth.uid is the
  // admin, not the owner), so the caller can't be checked against the
  // session doc's ownerId directly - instead confirm this uid is indeed the
  // adminUid on that session before tearing it down.
  const sessionRef = db.collection("support_mode_sessions").doc(ownerId);
  const sessionDoc = await sessionRef.get();
  if (sessionDoc.exists && sessionDoc.data().adminUid !== auth.uid) {
    throw new HttpsError("permission-denied", "Session mismatch.");
  }

  await sessionRef.delete();

  await db.collection("super_admin_audit_logs").add({
    ownerId,
    action: "EXIT_SUPPORT_MODE",
    schoolId: schoolId || (sessionDoc.exists ? sessionDoc.data().schoolId : null),
    affectedUserId: auth.uid,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    device: "Platform Dashboard",
  });

  return { exited: true };
});

// ============================================================================
// School Admin provisioning
//
// createSchool() (super_admin_remote_datasource.dart) writes a school and a
// tenant doc directly from the client, then drops a
// school_admin_invitations doc and stops - Firestore rules make that
// collection create-only for the client (isSuperAdmin() to create; nobody,
// including the owner, can read/update/delete it back through the client
// SDK). This trigger is the "somebody" the invitation doc's own comment
// says is expected to pick it up: it creates the real Firebase Auth
// account via the Admin SDK, writes the schoolAdmin profile, and scrubs the
// plaintext temporary password out of the invitation once consumed.
// ============================================================================
exports.provisionSchoolAdmin = onDocumentCreated(
  "school_admin_invitations/{invitationId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const invitation = snap.data();
    const ref = snap.ref;

    // Only ever act on a fresh, unconsumed invitation. A duplicate trigger
    // delivery (Cloud Functions' at-least-once guarantee) or a retry must
    // not create a second Auth account or re-provision an already-handled
    // request.
    if (invitation.status !== "pending") return;

    const email = typeof invitation.email === "string" ? invitation.email.trim() : "";
    const schoolId = invitation.schoolId;
    const tenantId = invitation.tenantId;
    const tempPassword = invitation.tempPassword;

    if (!email || !schoolId || !tempPassword) {
      await ref.update({
        status: "failed",
        tempPassword: admin.firestore.FieldValue.delete(),
        error: "Invitation is missing email, schoolId, or tempPassword.",
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      await recordJobFailure("school_onboarding", "provisionSchoolAdmin", event.data.id, "Invitation is missing email, schoolId, or tempPassword.");
      return;
    }

    // Claim the invitation before doing anything else, so a second
    // concurrent delivery of the same event sees status != "pending" and
    // exits at the guard above rather than racing this one.
    await ref.update({ status: "processing" });

    const schoolDoc = await admin.firestore().collection("schools").doc(schoolId).get();
    if (!schoolDoc.exists) {
      await ref.update({
        status: "failed",
        tempPassword: admin.firestore.FieldValue.delete(),
        error: `School ${schoolId} does not exist.`,
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      await recordJobFailure("school_onboarding", "provisionSchoolAdmin", event.data.id, `School ${schoolId} does not exist.`);
      return;
    }
    const schoolName = schoolDoc.data().name || "";

    let userRecord;
    let createdNewAuthUser = false;
    try {
      userRecord = await admin.auth().getUserByEmail(email);
      // Existing identity case: don't create a duplicate Auth account for
      // an email that already has one - add this school's admin membership
      // to the existing user instead of overwriting who they are elsewhere.
    } catch (err) {
      if (err.code !== "auth/user-not-found") {
        await ref.update({
          status: "failed",
          tempPassword: admin.firestore.FieldValue.delete(),
          error: err.message || "Failed to look up existing account.",
          failedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        await recordJobFailure("school_onboarding", "provisionSchoolAdmin", event.data.id, err.message || "Failed to look up existing account.");
        return;
      }
      try {
        userRecord = await admin.auth().createUser({
          email,
          password: tempPassword,
          displayName: `${schoolName} Admin`.trim(),
        });
        createdNewAuthUser = true;
      } catch (createErr) {
        await ref.update({
          status: "failed",
          tempPassword: admin.firestore.FieldValue.delete(),
          error: createErr.message || "Failed to create the admin account.",
          failedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        await recordJobFailure("school_onboarding", "provisionSchoolAdmin", event.data.id, createErr.message || "Failed to create the admin account.");
        return;
      }
    }

    try {
      const db = admin.firestore();
      const userRef = db.collection("users").doc(userRecord.uid);
      const existingProfile = await userRef.get();

      // Phase 1 Institution Context: additive membership record so this
      // user can switch into this institution regardless of which school
      // remains their "home" schoolId. Deterministic id (uid_schoolId)
      // makes this an idempotent upsert - safe to run even if a retry
      // reaches this point twice.
      const membershipRef = db
        .collection("institution_memberships")
        .doc(`${userRecord.uid}_${schoolId}`);

      if (existingProfile.exists) {
        // Existing user (staff/admin elsewhere) gaining School Admin
        // authority for this new school - add the role/school membership
        // without clobbering whatever roles they already hold at another
        // tenant. schoolId here is intentionally left as their existing
        // primary school; multi-school membership beyond a single
        // schoolId field is not modeled on the user profile, but the
        // institution_memberships doc below makes this second institution
        // switchable via the Institution Context Engine.
        const existingRoles = Array.isArray(existingProfile.data().roles)
          ? existingProfile.data().roles
          : [];
        const roles = existingRoles.includes("schoolAdmin")
          ? existingRoles
          : [...existingRoles, "schoolAdmin"];
        await userRef.update({
          roles,
          // Keep the first role as the primary/legacy role only if this
          // account had none before; otherwise leave their existing
          // primary role untouched.
          ...(existingRoles.length === 0 ? { role: "schoolAdmin" } : {}),
        });
        await membershipRef.set({
          userId: userRecord.uid,
          institutionId: schoolId,
          roles: ["schoolAdmin"],
          isPrimaryAdmin: existingProfile.data().schoolId === schoolId,
          status: "active",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      } else {
        const batch = db.batch();
        batch.set(userRef, {
          name: `${schoolName} Admin`.trim(),
          email,
          role: "schoolAdmin",
          roles: ["schoolAdmin"],
          schoolId,
          studentIds: [],
          mustChangePassword: true,
          isActive: true,
          isPrimaryAdmin: true,
          createdBy: "provisionSchoolAdmin",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        batch.set(db.collection("school_contacts").doc(userRecord.uid), {
          name: `${schoolName} Admin`.trim(),
          role: "schoolAdmin",
          roles: ["schoolAdmin"],
          schoolId,
          isActive: true,
        });
        batch.set(membershipRef, {
          userId: userRecord.uid,
          institutionId: schoolId,
          roles: ["schoolAdmin"],
          isPrimaryAdmin: true,
          status: "active",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        // First-login onboarding state, one doc per membership - the
        // client's InstitutionOnboardingCubit reads/advances this so a
        // killed app resumes mid-flow instead of restarting.
        batch.set(
          db.collection("onboarding_state").doc(`${userRecord.uid}_${schoolId}`),
          {
            userId: userRecord.uid,
            institutionId: schoolId,
            currentStep: "identityConfirm",
            completedSteps: [],
            mfaRequired: false,
            startedAt: admin.firestore.FieldValue.serverTimestamp(),
            completedAt: null,
          }
        );
        await batch.commit();
      }

      await db.collection("super_admin_audit_logs").add({
        action: "school_admin_provisioned",
        schoolId,
        affectedUserId: userRecord.uid,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        metadata: {
          email,
          tenantId: tenantId || null,
          reusedExistingAccount: !createdNewAuthUser,
        },
      });

      // Consumed: scrub the plaintext temporary password immediately so it
      // never lingers in Firestore past the moment it was needed.
      await ref.update({
        status: "consumed",
        tempPassword: admin.firestore.FieldValue.delete(),
        provisionedUid: userRecord.uid,
        consumedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Only for a genuinely new account — an existing user gaining admin
      // rights at a second school already has an account and knows it.
      if (createdNewAuthUser) {
        await enqueueTransactionalEmail({
          eventId: `school_admin_account_created_${userRecord.uid}`,
          templateId: "school_admin_account_created",
          to: email,
          data: { schoolName, email },
        }).catch((err) => console.error("school_admin_account_created email enqueue failed", userRecord.uid, err));
      }
    } catch (err) {
      // Only roll back the Auth account if this invocation created it -
      // never delete a pre-existing identity that predates this trigger.
      if (createdNewAuthUser) {
        await admin.auth().deleteUser(userRecord.uid).catch(() => {});
      }
      await ref.update({
        status: "failed",
        tempPassword: admin.firestore.FieldValue.delete(),
        error: err.message || "Failed to provision the school admin profile.",
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
);

// ============================================================================
// Subscription billing - MTN Mobile Money & Airtel Money
//
// NOT YET LIVE: this is a structurally-correct implementation against each
// provider's public API docs (MTN MoMo Collections API, Airtel Money
// Collection API), but it has never been run against a real sandbox or
// production account - neither was available while writing it. Before
// relying on it:
//   1. Fill in the environment variables listed in functions/.env.example
//      (via `firebase functions:secrets:set NAME` or a functions/.env file).
//   2. Deploy, then trigger one real renewal from a test phone and confirm
//      money actually moves and the webhook fires.
//   3. On the MTN MoMo developer portal / Airtel developer portal, register
//      the deployed webhook URLs as the callback for each product.
//
// Roles allowed to trigger a subscription charge - same admin tier as
// everything else, plus the bursar, since billing is their job day to day.
const BILLING_ROLES = ["director", "headTeacher", "schoolAdmin", "bursar"];

function normalizeUgandaMsisdn(phone) {
  const digits = String(phone).replace(/\D/g, "");
  if (digits.startsWith("256")) return digits;
  if (digits.startsWith("0")) return `256${digits.substring(1)}`;
  return `256${digits}`;
}

async function getMtnAccessToken() {
  const base = process.env.MTN_MOMO_BASE_URL;
  const user = process.env.MTN_MOMO_API_USER;
  const key = process.env.MTN_MOMO_API_KEY;
  const subKey = process.env.MTN_MOMO_SUBSCRIPTION_KEY;
  if (!base || !user || !key || !subKey) {
    throw new Error("MTN MoMo is not configured yet - see functions/.env.example.");
  }
  const basicAuth = Buffer.from(`${user}:${key}`).toString("base64");
  const res = await fetch(`${base}/collection/token/`, {
    method: "POST",
    headers: {
      "Authorization": `Basic ${basicAuth}`,
      "Ocp-Apim-Subscription-Key": subKey,
    },
  });
  if (!res.ok) throw new Error(`MTN token request failed: ${res.status} ${await res.text()}`);
  const data = await res.json();
  return data.access_token;
}

async function initiateMtnCharge({ transactionId, phoneNumber, amountUgx }) {
  const base = process.env.MTN_MOMO_BASE_URL;
  const subKey = process.env.MTN_MOMO_SUBSCRIPTION_KEY;
  const targetEnv = process.env.MTN_MOMO_TARGET_ENVIRONMENT || "sandbox";
  const callbackUrl = process.env.MTN_MOMO_CALLBACK_URL;
  const accessToken = await getMtnAccessToken();

  const res = await fetch(`${base}/collection/v1_0/requesttopay`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${accessToken}`,
      "X-Reference-Id": transactionId,
      "X-Target-Environment": targetEnv,
      "Ocp-Apim-Subscription-Key": subKey,
      "Content-Type": "application/json",
      ...(callbackUrl ? { "X-Callback-Url": callbackUrl } : {}),
    },
    body: JSON.stringify({
      amount: String(amountUgx),
      currency: targetEnv === "sandbox" ? "EUR" : "UGX",
      externalId: transactionId,
      payer: { partyIdType: "MSISDN", partyId: normalizeUgandaMsisdn(phoneNumber) },
      payerMessage: "School Pulse subscription renewal",
      payeeNote: "Monthly subscription",
    }),
  });
  if (res.status !== 202) {
    throw new Error(`MTN requesttopay failed: ${res.status} ${await res.text()}`);
  }
}

async function getAirtelAccessToken() {
  const base = process.env.AIRTEL_BASE_URL;
  const clientId = process.env.AIRTEL_CLIENT_ID;
  const clientSecret = process.env.AIRTEL_CLIENT_SECRET;
  if (!base || !clientId || !clientSecret) {
    throw new Error("Airtel Money is not configured yet - see functions/.env.example.");
  }
  const res = await fetch(`${base}/auth/oauth2/token`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ client_id: clientId, client_secret: clientSecret, grant_type: "client_credentials" }),
  });
  if (!res.ok) throw new Error(`Airtel token request failed: ${res.status} ${await res.text()}`);
  const data = await res.json();
  return data.access_token;
}

async function initiateAirtelCharge({ transactionId, phoneNumber, amountUgx }) {
  const base = process.env.AIRTEL_BASE_URL;
  const accessToken = await getAirtelAccessToken();
  // Airtel wants the subscriber MSISDN without the country code.
  const msisdn = normalizeUgandaMsisdn(phoneNumber).replace(/^256/, "");

  const res = await fetch(`${base}/merchant/v1/payments/`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${accessToken}`,
      "X-Country": "UG",
      "X-Currency": "UGX",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      reference: "School Pulse subscription renewal",
      subscriber: { country: "UG", currency: "UGX", msisdn },
      transaction: { amount: amountUgx, country: "UG", currency: "UGX", id: transactionId },
    }),
  });
  if (!res.ok) {
    throw new Error(`Airtel payment request failed: ${res.status} ${await res.text()}`);
  }
}

/**
 * Client-callable: kicks off a Mobile Money "request to pay" prompt on the
 * subscriber's phone. Writes a pending payment_transactions doc immediately
 * so the UI has something to watch, then calls out to the provider.
 */
exports.initiateMobileMoneyCharge = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "You must be signed in.");

  const userDoc = await admin.firestore().collection("users").doc(auth.uid).get();
  const userData = userDoc.data() || {};
  const role = userData.role;
  if (!BILLING_ROLES.includes(role)) {
    throw new HttpsError("permission-denied", "Only admins or the bursar can manage billing.");
  }
  const schoolId = userData.schoolId || null;

  const { provider, phoneNumber, amountUgx } = request.data || {};
  if (!["mtn", "airtel"].includes(provider)) {
    throw new HttpsError("invalid-argument", "provider must be 'mtn' or 'airtel'.");
  }
  if (!phoneNumber || !amountUgx || amountUgx <= 0) {
    throw new HttpsError("invalid-argument", "phoneNumber and a positive amountUgx are required.");
  }

  let schoolName = null;
  if (schoolId) {
    const schoolDoc = await admin.firestore().collection("schools").doc(schoolId).get();
    schoolName = schoolDoc.exists ? (schoolDoc.data().name || null) : null;
  }

  const transactionId = randomUUID();
  const db = admin.firestore();
  await db.collection("payment_transactions").doc(transactionId).set({
    provider,
    phoneNumber,
    amountUgx,
    status: "pending",
    reference: transactionId,
    // schoolId/schoolName/initiatedByUid: needed so the eventual success/
    // failure email can be addressed to the right school and tenant-checked
    // against the caller who started the charge. The legacy subscription/
    // current doc this flow updates has no per-school concept, but the
    // transaction itself can and must carry one.
    schoolId,
    schoolName,
    initiatedByUid: auth.uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  try {
    if (provider === "mtn") {
      await initiateMtnCharge({ transactionId, phoneNumber, amountUgx });
    } else {
      await initiateAirtelCharge({ transactionId, phoneNumber, amountUgx });
    }
  } catch (err) {
    await db.collection("payment_transactions").doc(transactionId).update({
      status: "failed",
      failureReason: err.message,
    });
    await recordJobFailure("payment_processing", "initiateMobileMoneyCharge", transactionId, err.message);
    throw new HttpsError("internal", `Could not start payment: ${err.message}`);
  }

  return { transactionId };
});

async function markTransactionResult(transactionId, { status, failureReason }) {
  const db = admin.firestore();
  const txRef = db.collection("payment_transactions").doc(transactionId);
  const txDoc = await txRef.get();
  if (!txDoc.exists) return;

  const tx = txDoc.data() || {};
  // Idempotency guard: webhooks are at-least-once delivery, and both
  // providers may redeliver the same callback. Once this transaction has
  // already been resolved, further callbacks for it must not re-run the
  // subscription update or send a second email.
  if (tx.status && tx.status !== "pending") return;

  await txRef.update({
    status,
    ...(failureReason ? { failureReason } : {}),
    completedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  const schoolId = tx.schoolId || null;
  const schoolName = tx.schoolName || "Your school";
  let recipientEmail = null;
  if (tx.initiatedByUid) {
    const initiatorDoc = await db.collection("users").doc(tx.initiatedByUid).get();
    // Tenant check: only email the person who initiated this specific
    // charge, and only if they still belong to the school the transaction
    // was opened against — never derive the recipient from anything on the
    // provider callback payload itself.
    if (initiatorDoc.exists && (!schoolId || initiatorDoc.data().schoolId === schoolId)) {
      recipientEmail = initiatorDoc.data().email || null;
    }
  }

  if (status === "success") {
    const subRef = db.collection("subscription").doc("current");
    const subDoc = await subRef.get();
    const currentRenewal = subDoc.data()?.renewalDate?.toDate() ?? new Date();
    const base = currentRenewal > new Date() ? currentRenewal : new Date();
    const nextRenewal = new Date(base);
    nextRenewal.setMonth(nextRenewal.getMonth() + 1);

    await subRef.set({
      status: "active",
      renewalDate: admin.firestore.Timestamp.fromDate(nextRenewal),
      amountUgx: tx.amountUgx,
      plan: subDoc.data()?.plan ?? "Standard",
    }, { merge: true });

    if (recipientEmail) {
      await enqueueTransactionalEmail({
        eventId: `mobile_money_payment_success_${transactionId}`,
        templateId: "mobile_money_payment_success",
        to: recipientEmail,
        data: {
          schoolName,
          paymentId: transactionId,
          amount: tx.amountUgx,
          planLabel: subDoc.data()?.plan ?? "Standard",
        },
      });
    }
  } else if (status === "failed") {
    await recordJobFailure("payment_processing", "markTransactionResult", transactionId, failureReason || "Payment failed");
    if (recipientEmail) {
      await enqueueTransactionalEmail({
        eventId: `mobile_money_payment_failed_${transactionId}`,
        templateId: "mobile_money_payment_failed",
        to: recipientEmail,
        data: {
          schoolName,
          paymentId: transactionId,
          amount: tx.amountUgx,
          reason: failureReason || "The payment was not completed.",
        },
      });
    }
  }
}

// Neither provider signs its webhook payloads by default, so this shared
// secret in the callback URL's query string is the only thing standing
// between this endpoint and anyone on the internet who guesses the URL.
// Set WEBHOOK_SHARED_SECRET and register the callback URL with the ?secret=
// suffix on each provider's developer portal.
function checkWebhookSecret(req, res) {
  const expected = process.env.WEBHOOK_SHARED_SECRET;
  if (expected && req.query.secret !== expected) {
    res.status(403).send("Forbidden");
    return false;
  }
  return true;
}

// MTN calls this back (via the X-Callback-Url sent on requesttopay) once a
// charge resolves. Register MTN_MOMO_CALLBACK_URL to point here after
// deploying, e.g. https://REGION-PROJECT.cloudfunctions.net/mtnMomoWebhook?secret=...
exports.mtnMomoWebhook = onRequest(async (req, res) => {
  if (!checkWebhookSecret(req, res)) return;
  try {
    const body = req.body || {};
    const transactionId = body.externalId || body.referenceId;
    const status = body.status === "SUCCESSFUL" ? "success" : "failed";
    if (transactionId) {
      await markTransactionResult(transactionId, { status, failureReason: body.reason });
    }
    res.status(200).send("OK");
  } catch (err) {
    console.error("mtnMomoWebhook error", err);
    res.status(500).send("Error");
  }
});

// ============================================================================
// Visitor Management - Overstay Detection
// ============================================================================

/**
 * Periodically checks for visitors who have exceeded their expected departure time
 * and sends alerts to their hosts and security personnel.
 */
exports.checkVisitorOverstays = onSchedule("every 15 minutes", async () => {
  await recordJobRun("checkVisitorOverstays", 15, async () => {
  const now = admin.firestore.Timestamp.now();
  const db = admin.firestore();

  const overstayedVisitors = await db.collection("visitors")
    .where("status", "==", "checkedIn")
    .where("expectedDepartureTime", "<=", now)
    .where("overstayAlertSent", "==", false)
    .get();

  for (const doc of overstayedVisitors.docs) {
    const visitor = doc.data();
    const visitorId = doc.id;

    try {
      // 1. Alert the Host if hostId is available
      if (visitor.hostId) {
        const hostDoc = await db.collection("users").doc(visitor.hostId).get();
        const hostData = hostDoc.data();

        if (hostData && hostData.fcmToken) {
          await db.collection("notification_queue").add({
            token: hostData.fcmToken,
            status: "pending",
            notification: {
              title: "Visitor Overstay Alert",
              body: `Your visitor ${visitor.fullName} has exceeded their scheduled time.`,
            },
            data: {
              type: "visitor_overstay",
              visitorId: visitorId,
              schoolId: visitor.schoolId,
            },
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }

      // 2. Alert Security Topic for the school
      const securityTopic = `topic_Security_${visitor.schoolId.replace(/[^a-zA-Z0-9-_.~%]/g, '_')}`;
      await admin.messaging().send({
        topic: securityTopic,
        notification: {
          title: "SECURITY: Visitor Overstay",
          body: `${visitor.fullName} (Host: ${visitor.host}) has overstayed. Please verify.`,
        },
        android: {
          priority: "high",
          notification: { channelId: "security_alerts", color: "#FF0000" },
        },
        data: {
          type: "visitor_overstay_security",
          visitorId: visitorId,
        },
      });

      // 3. Mark alert as sent to avoid duplicates
      await doc.ref.update({ overstayAlertSent: true });

    } catch (err) {
      console.error(`Failed to process overstay for visitor ${visitorId}:`, err);
    }
  }
  });
});

// Register this URL as the Collection callback on the Airtel developer
// portal, e.g. https://REGION-PROJECT.cloudfunctions.net/airtelMoneyWebhook?secret=...
exports.airtelMoneyWebhook = onRequest(async (req, res) => {
  if (!checkWebhookSecret(req, res)) return;
  try {
    const body = req.body || {};
    const transactionId = body.transaction?.id;
    const success = body.transaction?.status === "TS" || body.transaction?.status_code === "TS";
    if (transactionId) {
      await markTransactionResult(transactionId, {
        status: success ? "success" : "failed",
        failureReason: success ? undefined : body.transaction?.message,
      });
    }
    res.status(200).send("OK");
  } catch (err) {
    console.error("airtelMoneyWebhook error", err);
    res.status(500).send("Error");
  }
});

// ============================================================================
// Public school branding mirror
// ============================================================================

// schools/{id} and schools/{id}/config/institution_profile mix public
// branding (name, initials, logo) with billing/subscription and contact PII,
// so both stay locked to signed-in staff of that school (see firestore.rules
// for schools/{schoolId}). Pre-login screens - the parent "Connect to
// school" code-entry flow - still need to show a school's name/badge before
// any session exists, so this mirrors ONLY the public fields into
// schools/{id}/public/branding, which firestore.rules allows anyone to read.
function schoolPublicBrandingFrom(schoolData, profileData) {
  const nonEmpty = (value) => {
    const text = value == null ? "" : String(value).trim();
    return text.length ? text : null;
  };
  const branding = (schoolData && schoolData.branding) || {};
  return {
    schoolName:
      nonEmpty(profileData && profileData.displayName) ||
      nonEmpty(profileData && profileData.name) ||
      nonEmpty(schoolData && schoolData.name) ||
      nonEmpty(schoolData && schoolData.schoolName) ||
      "School",
    schoolInitials:
      nonEmpty(profileData && profileData.initials) ||
      nonEmpty(profileData && profileData.shortName) ||
      nonEmpty(schoolData && schoolData.initials) ||
      nonEmpty(schoolData && schoolData.schoolInitials) ||
      "",
    badgeUrl:
      nonEmpty(profileData && profileData.badgeUrl) ||
      nonEmpty(branding.badgeUrl) ||
      nonEmpty(profileData && profileData.logoUrl) ||
      nonEmpty(branding.logoUrl) ||
      null,
    city: nonEmpty(schoolData && schoolData.city),
    country: nonEmpty(schoolData && schoolData.country),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

async function syncSchoolPublicBranding(schoolId) {
  const db = admin.firestore();
  const [schoolSnap, profileSnap] = await Promise.all([
    db.collection("schools").doc(schoolId).get(),
    db.collection("schools").doc(schoolId).collection("config").doc("institution_profile").get(),
  ]);
  if (!schoolSnap.exists) return;
  const publicData = schoolPublicBrandingFrom(schoolSnap.data(), profileSnap.exists ? profileSnap.data() : null);
  await db.collection("schools").doc(schoolId).collection("public").doc("branding").set(publicData, { merge: true });
}

exports.syncSchoolPublicBrandingOnSchoolWrite = onDocumentWritten("schools/{schoolId}", async (event) => {
  await syncSchoolPublicBranding(event.params.schoolId);
});

exports.syncSchoolPublicBrandingOnProfileWrite = onDocumentWritten(
  "schools/{schoolId}/config/institution_profile",
  async (event) => {
    await syncSchoolPublicBranding(event.params.schoolId);
  },
);

// One-time backfill for schools that existed before the triggers above -
// they only fire on a future write, so any school untouched since deploy
// has no public/branding doc yet. Any signed-in staff member may trigger
// it (it only syncs their own school's already-public branding fields, so
// there's nothing to gate more tightly); safe to delete once every
// existing tenant has a public/branding doc.
exports.backfillSchoolPublicBranding = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in to continue.");
  const user = await admin.firestore().collection("users").doc(request.auth.uid).get();
  const schoolId = user.data() && user.data().schoolId;
  if (!schoolId) throw new HttpsError("failed-precondition", "No school associated with this account.");
  await syncSchoolPublicBranding(schoolId);
  return { synced: schoolId };
});

// ============================================================================
// Parent Authentication
// ============================================================================

// Secure parent-link invitations deliberately live separately from the
// legacy `parent_access_codes` collection.  The legacy collection uses the
// printable code as its document id and cannot safely meet single-use-code
// requirements.  Nothing in `parent_access_code_invites` contains a raw code.
const PARENT_INVITE_TTL_MS = 7 * 24 * 60 * 60 * 1000;
const PARENT_INVITE_ADMIN_ROLES = new Set([
  "director", "headTeacher", "deputyHead", "schoolAdmin", "admissions", "registrar",
]);
function normalizedParentInviteCode(value) {
  return String(value || "").toUpperCase().replace(/[^A-Z0-9]/g, "");
}
// Tenant-configurable maximum number of standard parent/guardian links a
// single learner may have. Stored on people_policies/{schoolId}
// (maxStandardGuardians); defaults to 2 when the doc or field is absent,
// matching the historical hard-coded rule. Read outside any transaction so
// callers must pass the resolved number into transaction bodies.
async function resolveMaxGuardians(db, schoolId) {
  try {
    const snap = await db.collection("people_policies").doc(String(schoolId)).get();
    const raw = snap.exists ? snap.data().maxStandardGuardians : null;
    const value = Number(raw);
    if (Number.isInteger(value) && value >= 1 && value <= 10) return value;
  } catch (err) {
    console.error("resolveMaxGuardians failed; defaulting to 2", schoolId, err);
  }
  return 2;
}
function parentInviteHash(value) {
  // An HMAC prevents a six-digit invitation hash from being brute-forced if
  // an invitation document were ever exposed. Production must configure the
  // pepper as a Functions secret/environment variable.
  const pepper = process.env.PARENT_ACCESS_CODE_PEPPER || process.env.PIN_HASH_PEPPER;
  if (!pepper) throw new HttpsError("failed-precondition", "Parent access codes are not configured.");
  return createHmac("sha256", pepper).update(normalizedParentInviteCode(value)).digest("hex");
}
function newParentInviteCode(schoolPrefix) {
  const digits = String(randomBytes(4).readUInt32BE(0) % 1000000).padStart(6, "0");
  return `${schoolPrefix}-${digits}P`;
}
function maskPhoneNumber(value) {
  const digits = String(value || "").replace(/\D/g, "");
  if (digits.length < 4) return "***";
  return `***${digits.slice(-4)}`;
}
function parentInviteError() {
  return new HttpsError("permission-denied", "This code is invalid, expired, or already used.");
}
function isSafeParentPin(pin) {
  if (!/^\d{4}$/.test(String(pin || ""))) return false;
  const value = String(pin);
  if (/^(\d)\1{3}$/.test(value)) return false;
  const digits = [...value].map(Number);
  const ascending = digits.every((digit, index) => index === 0 || digit === digits[index - 1] + 1);
  const descending = digits.every((digit, index) => index === 0 || digit === digits[index - 1] - 1);
  return !ascending && !descending;
}
async function parentInviteAdmin(request) {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in to manage parent access codes.");
  const user = await admin.firestore().collection("users").doc(request.auth.uid).get();
  const data = user.data() || {};
  const roles = Array.isArray(data.roles) ? data.roles : [data.role];
  if (!roles.some((role) => PARENT_INVITE_ADMIN_ROLES.has(role))) {
    throw new HttpsError("permission-denied", "You do not have permission to manage parent access codes.");
  }
  return data;
}

/** Admin-only: links one parent to a learner (up to the tenant's configured
 * guardian cap, default two) and returns the raw, one-time code exactly once.
 * When an `email` is supplied a verified invitation is also enqueued.
 *
 * INITIAL-LINK ONLY. This callable only ever adds a new `parent_learner_links`
 * doc for a learner that still has room (fewer than the configured max active
 * links) - it
 * never revokes or mutates an existing active link, so all six
 * PARENT_INVITE_ADMIN_ROLES (director, headTeacher, deputyHead, schoolAdmin,
 * admissions, registrar) can safely use it to onboard a learner's first or
 * second parent. Reassigning/replacing/removing an EXISTING active link is a
 * distinct, more sensitive operation restricted to schoolAdmin only - see
 * reallocateParentLink below. Each written link is tagged linkType: "initial"
 * so the two paths stay auditable and distinguishable in the data itself. */
exports.createParentAccessCode = onCall({ secrets: ["PARENT_ACCESS_CODE_PEPPER"] }, async (request) => {
  const actor = await parentInviteAdmin(request);
  const { parentName, phoneNumber, learners, email } = request.data || {};
  const schoolId = String(actor.schoolId || "");
  const normalizedPhone = String(phoneNumber || "").replace(/\s/g, "");
  if (!schoolId || !String(parentName || "").trim() || !/^\+\d{8,15}$/.test(normalizedPhone) || !Array.isArray(learners) || !learners.length) {
    throw new HttpsError("invalid-argument", "Parent details and at least one learner are required.");
  }
  let normalizedEmail = null;
  if (email !== undefined && email !== null && String(email).trim() !== "") {
    normalizedEmail = String(email).trim().toLowerCase();
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(normalizedEmail)) {
      throw new HttpsError("invalid-argument", "Enter a valid email address.");
    }
  }
  const learnerIds = [...new Set(learners.map((learner) => String(learner.studentId || "")).filter(Boolean))];
  if (learnerIds.length !== learners.length) throw new HttpsError("invalid-argument", "Each learner may be linked once.");
  const db = admin.firestore();
  const studentSnapshots = await Promise.all(learnerIds.map((id) => db.collection("students").doc(id).get()));
  if (studentSnapshots.some((snapshot) => !snapshot.exists || snapshot.data().schoolId !== schoolId)) {
    throw new HttpsError("permission-denied", "One or more learners are unavailable.");
  }
  const schoolSnap = await db.collection("schools").doc(schoolId).get();
  const schoolPrefix = schoolPrefixFrom(schoolSnap.exists ? schoolSnap.data().name : actor.schoolName);
  // Codes are random; collisions are rare but checked for, since the raw
  // code is never stored (only its hash) and must be unique per school.
  let code;
  let codeHash;
  for (let attempt = 0; attempt < 5; attempt++) {
    const candidate = newParentInviteCode(schoolPrefix);
    const candidateHash = parentInviteHash(candidate);
    const collision = await db.collection("parent_access_code_invites").where("schoolId", "==", schoolId).where("codeHash", "==", candidateHash).limit(1).get();
    if (collision.empty) {
      code = candidate;
      codeHash = candidateHash;
      break;
    }
  }
  if (!code) throw new HttpsError("internal", "Could not generate a unique access code. Try again.");
  const maxGuardians = await resolveMaxGuardians(db, schoolId);
  const now = Date.now();
  const inviteRef = db.collection("parent_access_code_invites").doc(randomUUID());
  await db.runTransaction(async (transaction) => {
    for (const studentId of learnerIds) {
      const links = await transaction.get(db.collection("parent_learner_links").where("schoolId", "==", schoolId).where("studentId", "==", studentId));
      const active = links.docs.filter((link) => link.data().status !== "revoked");
      if (active.length >= maxGuardians) throw new HttpsError("failed-precondition", `A learner can have a maximum of ${maxGuardians} parents.`);
      if (active.some((link) => link.data().phoneNumber === normalizedPhone)) throw new HttpsError("already-exists", "This parent is already linked to the learner.");
    }
    transaction.set(inviteRef, {
      schoolId, codeHash, parentName: String(parentName).trim(), phoneNumber: normalizedPhone,
      ...(normalizedEmail ? { email: normalizedEmail } : {}),
      learnerIds, learnerRelationships: learners.map((learner) => ({ studentId: String(learner.studentId), relationship: String(learner.relationship || "Guardian"), isPrimaryContact: learner.isPrimaryContact === true })),
      status: "active", createdBy: request.auth.uid, createdAt: admin.firestore.FieldValue.serverTimestamp(), expiresAt: admin.firestore.Timestamp.fromMillis(now + PARENT_INVITE_TTL_MS),
    });
    for (const learner of learners) transaction.set(db.collection("parent_learner_links").doc(), {
      schoolId, studentId: String(learner.studentId), parentInviteId: inviteRef.id, phoneNumber: normalizedPhone,
      relationship: String(learner.relationship || "Guardian"), isPrimaryContact: learner.isPrimaryContact === true, status: "pending", linkType: "initial", createdBy: request.auth.uid, createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
  await db.collection("audit_logs").add({ schoolId, actorId: request.auth.uid, module: "parent_access", action: "code_generated", targetType: "parent_access_invite", targetId: inviteRef.id, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  // Kick off a verified invitation email when an address is on file. The raw
  // code is passed through so the first email carries it; failure here never
  // fails the link (the admin can still share the code returned below).
  let invitation = { status: "pending_manual", delivered: false };
  if (normalizedEmail) {
    try {
      const now2 = Date.now();
      const recordRef = db.collection("parent_invitations").doc();
      const canResendAt = admin.firestore.Timestamp.fromMillis(now2 + 60 * 1000);
      const expAt = admin.firestore.Timestamp.fromMillis(now2 + PARENT_INVITE_TTL_MS);
      const schoolName = schoolSnap.exists ? (schoolSnap.data().name || "") : "";
      await recordRef.set({
        schoolId, parentInviteId: inviteRef.id, channel: "email",
        maskedTarget: normalizedEmail.replace(/^(.).*(@.*)$/, "$1***$2"),
        status: "sent", createdBy: request.auth.uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(), expiresAt: expAt,
      });
      await enqueueTransactionalEmail({
        eventId: `parent_invite_${recordRef.id}`,
        templateId: "parent_account_created",
        to: normalizedEmail,
        data: { schoolName, parentName: String(parentName).trim(), code, learnerCount: learnerIds.length },
      });
      await inviteRef.set({
        invitationId: recordRef.id, invitationStatus: "sent", invitationChannel: "email",
        invitationSentAt: admin.firestore.FieldValue.serverTimestamp(),
        invitationCanResendAt: canResendAt, invitationExpiresAt: expAt,
      }, { merge: true });
      invitation = { invitationId: recordRef.id, status: "sent", delivered: true, canResendAt: canResendAt.toMillis(), expiresAt: expAt.toMillis() };
    } catch (err) {
      console.error("createParentAccessCode: invitation email failed", inviteRef.id, err);
      invitation = { status: "failed", delivered: false };
    }
  }
  return { inviteId: inviteRef.id, code, expiresAt: now + PARENT_INVITE_TTL_MS, invitation };
});

/** schoolAdmin-only: reassigns/replaces/removes an EXISTING active (or
 * pending) parent_learner_links doc for a learner, atomically revoking the
 * old link and - unless the caller is only removing a slot - issuing a fresh
 * invite/link for the replacement parent. Distinct from createParentAccessCode
 * (initial-link, six roles) per the Day 3 policy: only schoolAdmin may
 * reallocate an existing link, and the acting user's schoolId is validated
 * against both the learner and the link being replaced (not just their
 * role), so a schoolAdmin from another school can never touch this school's
 * links. Every successful reallocation writes one immutable
 * parent_link_audit_log doc (actor uid+role, schoolId, learner id, the old
 * link snapshot, the new link snapshot, a server timestamp, and the reason)
 * before returning - the log is never updated after creation. */
exports.reallocateParentLink = onCall({ secrets: ["PARENT_ACCESS_CODE_PEPPER"] }, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in to manage parent access codes.");
  const actorSnap = await admin.firestore().collection("users").doc(request.auth.uid).get();
  const actor = actorSnap.data() || {};
  const actorRoles = Array.isArray(actor.roles) ? actor.roles : [actor.role];
  if (!actorRoles.includes("schoolAdmin")) {
    throw new HttpsError("permission-denied", "Only a school admin may reallocate an existing parent link.");
  }
  const actorSchoolId = String(actor.schoolId || "");
  if (!actorSchoolId) throw new HttpsError("failed-precondition", "Your account is not assigned to a school.");

  const { linkId, parentName, phoneNumber, reason } = request.data || {};
  if (!String(linkId || "").trim()) {
    throw new HttpsError("invalid-argument", "The existing parent link to reallocate is required.");
  }
  const normalizedPhone = String(phoneNumber || "").replace(/\s/g, "");
  const isRemoval = !parentName && !phoneNumber;
  if (!isRemoval && (!String(parentName || "").trim() || !/^\+\d{8,15}$/.test(normalizedPhone))) {
    throw new HttpsError("invalid-argument", "A replacement parent needs a name and a valid phone number, or omit both to just remove the existing link.");
  }

  const db = admin.firestore();
  const oldLinkRef = db.collection("parent_learner_links").doc(String(linkId));
  const maxGuardians = await resolveMaxGuardians(db, actorSchoolId);

  const result = await db.runTransaction(async (transaction) => {
    const oldLinkSnap = await transaction.get(oldLinkRef);
    if (!oldLinkSnap.exists) throw new HttpsError("not-found", "That parent link no longer exists.");
    const oldLink = oldLinkSnap.data();
    // Cross-school denial: the link's own schoolId is the source of truth,
    // not any schoolId the client might pass - a schoolAdmin's session
    // cannot be tricked into touching another tenant's link.
    if (oldLink.schoolId !== actorSchoolId) {
      throw new HttpsError("permission-denied", "This parent link belongs to a different school.");
    }
    if (oldLink.status === "revoked") {
      throw new HttpsError("failed-precondition", "This parent link has already been revoked.");
    }
    const studentId = String(oldLink.studentId || "");
    const studentSnap = await transaction.get(db.collection("students").doc(studentId));
    if (!studentSnap.exists || studentSnap.data().schoolId !== actorSchoolId) {
      throw new HttpsError("permission-denied", "This learner is unavailable.");
    }

    // All transaction reads happen before any write - Firestore transactions
    // require reads to be executed before writes, so the two-parent-cap
    // lookup and the school-prefix lookup both happen here, ahead of the
    // revoke/create writes below.
    let otherLinksSnap = null;
    let schoolSnap = null;
    if (!isRemoval) {
      otherLinksSnap = await transaction.get(
        db.collection("parent_learner_links").where("schoolId", "==", actorSchoolId).where("studentId", "==", studentId)
      );
      const stillActive = otherLinksSnap.docs.filter((doc) => doc.id !== oldLinkRef.id && doc.data().status !== "revoked");
      if (stillActive.length >= maxGuardians) throw new HttpsError("failed-precondition", `A learner can have a maximum of ${maxGuardians} parents.`);
      if (stillActive.some((doc) => doc.data().phoneNumber === normalizedPhone)) {
        throw new HttpsError("already-exists", "This parent is already linked to the learner.");
      }
      schoolSnap = await transaction.get(db.collection("schools").doc(actorSchoolId));
    }

    // Revoke the old link first so any code reading it after this point
    // within the same transaction sees the intended end state.
    transaction.update(oldLinkRef, {
      status: "revoked",
      revokedAt: admin.firestore.FieldValue.serverTimestamp(),
      revokedBy: request.auth.uid,
      revokedReason: String(reason || "reallocated"),
    });

    if (isRemoval) {
      return { studentId, oldLink, newLink: null, code: null, inviteId: null };
    }

    const schoolPrefix = schoolPrefixFrom(schoolSnap.exists ? schoolSnap.data().name : actor.schoolName);
    const code = newParentInviteCode(schoolPrefix);
    const codeHash = parentInviteHash(code);
    const inviteRef = db.collection("parent_access_code_invites").doc(randomUUID());
    const now = Date.now();
    transaction.set(inviteRef, {
      schoolId: actorSchoolId, codeHash, parentName: String(parentName).trim(), phoneNumber: normalizedPhone,
      learnerIds: [studentId], learnerRelationships: [{ studentId, relationship: String(oldLink.relationship || "Guardian") }],
      status: "active", createdBy: request.auth.uid, createdAt: admin.firestore.FieldValue.serverTimestamp(), expiresAt: admin.firestore.Timestamp.fromMillis(now + PARENT_INVITE_TTL_MS),
    });
    const newLinkRef = db.collection("parent_learner_links").doc();
    const newLink = {
      schoolId: actorSchoolId, studentId, parentInviteId: inviteRef.id, phoneNumber: normalizedPhone,
      relationship: String(oldLink.relationship || "Guardian"), status: "pending", linkType: "reallocation",
      previousLinkId: oldLinkRef.id, createdBy: request.auth.uid, createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    transaction.set(newLinkRef, newLink);

    return { studentId, oldLink, newLink: { ...newLink, id: newLinkRef.id }, code, inviteId: inviteRef.id, expiresAt: now + PARENT_INVITE_TTL_MS };
  });

  // Immutable audit record, written after the transaction commits so it
  // only exists for reallocations that actually succeeded. Never updated
  // after creation - parent_link_audit_log is `allow read, write: if false`
  // in firestore.rules, so only this Admin-SDK write path can create it.
  await db.collection("parent_link_audit_log").add({
    actorUid: request.auth.uid,
    actorRole: "schoolAdmin",
    schoolId: actorSchoolId,
    studentId: result.studentId,
    oldLink: { id: oldLinkRef.id, phoneNumber: result.oldLink.phoneNumber || null, relationship: result.oldLink.relationship || null, status: result.oldLink.status || null },
    newLink: result.newLink ? { id: result.newLink.id, phoneNumber: result.newLink.phoneNumber, relationship: result.newLink.relationship, status: result.newLink.status } : null,
    action: isRemoval ? "removed" : "reallocated",
    reason: String(reason || ""),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  if (isRemoval) return { success: true, removed: true };
  return { success: true, inviteId: result.inviteId, code: result.code, expiresAt: result.expiresAt };
});

/** Read-only, six-role gated (same as createParentAccessCode): lists this
 * school's parent_access_code_invites so the admin UI can render an Access
 * Codes tab without ever reading parent_access_code_invites/
 * parent_learner_links directly (both are `allow read, write: if false`).
 * Never returns phoneNumber or codeHash - only a server-masked phone and
 * code-state fields. status is recomputed here (rather than trusted from the
 * stored field) so an invite past its expiresAt is reported "expired" even
 * if nothing has written that back to Firestore yet. Also returns
 * pendingCount/expiringSoonCount (expiresAt within 48h) computed from this
 * same query so the client never needs its own aggregation query against a
 * collection it cannot read. */
exports.listParentAccessInvites = onCall(async (request) => {
  const actor = await parentInviteAdmin(request);
  const schoolId = String(actor.schoolId || "");
  if (!schoolId) throw new HttpsError("failed-precondition", "Your account is not assigned to a school.");

  const pageSize = Math.min(Math.max(Number(request.data?.pageSize) || 25, 1), 100);
  const cursor = String(request.data?.cursor || "");

  const db = admin.firestore();
  let query = db.collection("parent_access_code_invites")
    .where("schoolId", "==", schoolId)
    .orderBy("createdAt", "desc")
    .limit(pageSize);
  if (cursor) {
    const cursorSnap = await db.collection("parent_access_code_invites").doc(cursor).get();
    if (cursorSnap.exists) query = query.startAfter(cursorSnap);
  }
  const snap = await query.get();

  const now = Date.now();
  const expiringSoonMs = 48 * 60 * 60 * 1000;
  const maskInviteEmail = (v) => {
    const s = String(v || "").trim().toLowerCase();
    const at = s.indexOf("@");
    if (at < 1) return "";
    return `${s[0]}***${s.slice(at)}`;
  };
  const rows = snap.docs.map((doc) => {
    const data = doc.data();
    const expiresAtMs = data.expiresAt?.toMillis?.() ?? 0;
    const isExpired = expiresAtMs > 0 && expiresAtMs < now;
    const status = data.status === "revoked" ? "revoked" : isExpired ? "expired" : "active";
    return {
      inviteId: doc.id,
      parentName: data.parentName || "",
      maskedPhone: maskPhoneNumber(data.phoneNumber),
      maskedEmail: maskInviteEmail(data.email),
      hasEmail: !!data.email,
      learnerCount: Array.isArray(data.learnerIds) ? data.learnerIds.length : 0,
      status,
      // Delivery/acceptance state of the verified invitation, distinct from
      // the code's own active/expired/revoked status. "accepted" is written
      // by the parent redeem flow; anything else means the parent has not
      // signed up yet.
      invitationStatus: data.invitationStatus || (data.email ? "sent" : "pending_manual"),
      invitationSentAt: data.invitationSentAt?.toMillis?.() ?? null,
      canResendAt: data.invitationCanResendAt?.toMillis?.() ?? null,
      createdAt: data.createdAt?.toMillis?.() ?? null,
      expiresAt: expiresAtMs || null,
      expiringSoon: status === "active" && expiresAtMs > 0 && expiresAtMs - now <= expiringSoonMs,
    };
  });

  // Aggregate counts reflect the full school (not just this page), so a
  // second unpaginated query drives them rather than the page above.
  const allSnap = await db.collection("parent_access_code_invites").where("schoolId", "==", schoolId).get();
  let pendingCount = 0;
  let expiringSoonCount = 0;
  let linkedParentCount = 0;
  allSnap.docs.forEach((doc) => {
    const data = doc.data();
    if (data.status === "revoked") return;
    const expiresAtMs = data.expiresAt?.toMillis?.() ?? 0;
    if (expiresAtMs > 0 && expiresAtMs < now) return; // expired, not pending
    if (data.invitationStatus === "accepted") {
      linkedParentCount += 1;
    } else {
      pendingCount += 1;
    }
    if (expiresAtMs > 0 && expiresAtMs - now <= expiringSoonMs) expiringSoonCount += 1;
  });

  const maxGuardians = await resolveMaxGuardians(db, schoolId);

  return {
    rows,
    nextCursor: snap.docs.length === pageSize ? snap.docs[snap.docs.length - 1].id : null,
    pendingCount,
    expiringSoonCount,
    linkedParentCount,
    maxGuardians,
  };
});

/** Admin-gated, tenant-scoped single parent record with resolved learner
 * names + per-learner link ids/relationships/primary-contact flags. Backs
 * the parent detail/access-management screen. Never returns a raw code or
 * codeHash; phone/email are returned in full here (not masked) because the
 * caller is an authenticated same-school admin editing the record - the list
 * endpoint stays masked for the directory view. */
exports.getParentAccessRecord = onCall(async (request) => {
  const actor = await parentInviteAdmin(request);
  const schoolId = String(actor.schoolId || "");
  if (!schoolId) throw new HttpsError("failed-precondition", "Your account is not assigned to a school.");
  const inviteId = String(request.data?.inviteId || "").trim();
  if (!inviteId) throw new HttpsError("invalid-argument", "An invitation id is required.");

  const db = admin.firestore();
  const ref = db.collection("parent_access_code_invites").doc(inviteId);
  const snap = await ref.get();
  if (!snap.exists || String(snap.data().schoolId || "") !== schoolId) {
    throw new HttpsError("not-found", "Parent record not found.");
  }
  const data = snap.data();
  const now = Date.now();
  const expiresAtMs = data.expiresAt?.toMillis?.() ?? 0;
  const isExpired = expiresAtMs > 0 && expiresAtMs < now;
  const status = data.status === "revoked" ? "revoked" : isExpired ? "expired" : "active";

  const linksSnap = await db.collection("parent_learner_links")
    .where("schoolId", "==", schoolId)
    .where("parentInviteId", "==", inviteId)
    .get();
  const linkDocs = linksSnap.docs.map((d) => ({ id: d.id, ...d.data() }));
  const studentIds = [...new Set(linkDocs.map((l) => String(l.studentId)).filter(Boolean))];
  const studentSnaps = await Promise.all(studentIds.map((id) => db.collection("students").doc(id).get()));
  const nameById = {};
  studentSnaps.forEach((s) => {
    if (s.exists) nameById[s.id] = { name: s.data().name || "", className: s.data().className || s.data().classId || "" };
  });

  return {
    inviteId,
    parentName: data.parentName || "",
    phoneNumber: data.phoneNumber || "",
    email: data.email || "",
    status,
    invitationStatus: data.invitationStatus || (data.email ? "sent" : "pending_manual"),
    invitationSentAt: data.invitationSentAt?.toMillis?.() ?? null,
    canResendAt: data.invitationCanResendAt?.toMillis?.() ?? null,
    createdAt: data.createdAt?.toMillis?.() ?? null,
    expiresAt: expiresAtMs || null,
    revokedAt: data.revokedAt?.toMillis?.() ?? null,
    maxGuardians: await resolveMaxGuardians(db, schoolId),
    learners: linkDocs
      .filter((l) => l.status !== "revoked")
      .map((l) => ({
        linkId: l.id,
        studentId: String(l.studentId),
        studentName: nameById[String(l.studentId)]?.name || "",
        className: nameById[String(l.studentId)]?.className || "",
        relationship: l.relationship || "Guardian",
        isPrimaryContact: l.isPrimaryContact === true,
        linkStatus: l.status || "pending",
        linkType: l.linkType || "initial",
      })),
  };
});

exports.revokeParentAccessCode = onCall(async (request) => {
  const actor = await parentInviteAdmin(request);
  const ref = admin.firestore().collection("parent_access_code_invites").doc(String(request.data?.inviteId || ""));
  const invite = await ref.get();
  if (!invite.exists || invite.data().schoolId !== actor.schoolId) throw new HttpsError("not-found", "Access code not found.");
  await ref.update({ status: "revoked", revokedAt: admin.firestore.FieldValue.serverTimestamp(), revokedBy: request.auth.uid, invitationStatus: "cancelled" });
  const invitationId = invite.data().invitationId;
  if (invitationId) {
    await admin.firestore().collection("parent_invitations").doc(invitationId).set(
      { status: "cancelled", cancelledAt: admin.firestore.FieldValue.serverTimestamp(), cancelledBy: request.auth.uid },
      { merge: true },
    );
  }
  await admin.firestore().collection("audit_logs").add({ schoolId: actor.schoolId, actorId: request.auth.uid, module: "parent_access", action: "code_revoked", targetType: "parent_access_invite", targetId: ref.id, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  return { success: true };
});

// This is called only after Firebase Phone Auth has verified possession of
// the submitted number. It never distinguishes bad code, phone, expiry,
// revocation, or consumption.
exports.redeemParentAccessCode = onCall({ secrets: ["PARENT_ACCESS_CODE_PEPPER"] }, async (request) => {
  const phoneNumber = request.auth?.token?.phone_number;
  const hash = parentInviteHash(request.data?.code);
  const db = admin.firestore();
  const matches = await db.collection("parent_access_code_invites").where("codeHash", "==", hash).limit(1).get();
  const invite = matches.docs[0];
  const genericFailure = async () => {
    await db.collection("parent_access_code_attempts").add({ codeHash: hash, phoneHash: createHash("sha256").update(String(phoneNumber || request.data?.phoneNumber || "")).digest("hex"), outcome: "failed", createdAt: admin.firestore.FieldValue.serverTimestamp() });
    throw parentInviteError();
  };
  if (!phoneNumber || !invite || invite.data().status !== "active" || invite.data().phoneNumber !== phoneNumber || invite.data().expiresAt.toMillis() < Date.now()) return genericFailure();
  const data = invite.data();
  const students = await Promise.all(data.learnerIds.map((id) => db.collection("students").doc(id).get()));
  if (students.some((student) => !student.exists || student.data().schoolId !== data.schoolId)) return genericFailure();
  await db.collection("parent_access_code_attempts").add({ inviteId: invite.id, outcome: "verified", createdAt: admin.firestore.FieldValue.serverTimestamp() });
  const school = await db.collection("schools").doc(data.schoolId).get();
  return { inviteId: invite.id, schoolName: school.data()?.name || "School", parentName: data.parentName, learners: students.map((student) => ({ name: student.data().name, className: student.data().className || student.data().classId || "" })) };
});

exports.completeParentAccessCodeSetup = onCall({ secrets: ["PARENT_ACCESS_CODE_PEPPER"] }, async (request) => {
  const phoneNumber = request.auth?.token?.phone_number;
  const hash = parentInviteHash(request.data?.code);
  const pin = String(request.data?.pin || "");
  if (!phoneNumber || !isSafeParentPin(pin)) throw new HttpsError("invalid-argument", "Choose a secure four-digit PIN.");
  const db = admin.firestore();
  const matches = await db.collection("parent_access_code_invites").where("codeHash", "==", hash).limit(1).get();
  const invite = matches.docs[0];
  if (!invite) throw parentInviteError();
  const data = invite.data();
  if (data.status !== "active" || data.phoneNumber !== phoneNumber || data.expiresAt.toMillis() < Date.now()) throw parentInviteError();
  await db.runTransaction(async (transaction) => {
    const current = await transaction.get(invite.ref);
    if (!current.exists || current.data().status !== "active") throw parentInviteError();
    transaction.update(invite.ref, { status: "used", usedBy: request.auth.uid, usedAt: admin.firestore.FieldValue.serverTimestamp(), pin: hashPin(pin) });
    transaction.set(db.collection("users").doc(request.auth.uid), { role: "parent", roles: ["parent"], schoolId: data.schoolId, name: data.parentName, phoneNumber, studentIds: data.learnerIds, isActive: true, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    for (const studentId of data.learnerIds) {
      const links = await transaction.get(db.collection("parent_learner_links").where("parentInviteId", "==", invite.id).where("studentId", "==", studentId));
      links.docs.forEach((link) => transaction.update(link.ref, { status: "active", parentUserId: request.auth.uid, activatedAt: admin.firestore.FieldValue.serverTimestamp() }));
    }
  });
  await db.collection("audit_logs").add({ schoolId: data.schoolId, actorId: request.auth.uid, module: "parent_access", action: "code_redeemed", targetType: "parent_access_invite", targetId: invite.id, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  return { success: true };
});

/**
 * Verifies a parent's access code + phone + PIN server-side (parent_access_
 * codes/{code} is publicly readable by design so the pre-login screens can
 * show the parent's name - see firestore.rules - so the PIN comparison can
 * no longer happen trustingly on the client) and mints a Firebase custom
 * token so the parent gets a real Firebase Auth session. Also mirrors a
 * users/{uid} profile so Firestore rules (myUser/isParentOf) and the
 * "groups" a parent belongs to for broadcast targeting can be resolved.
 */
exports.loginParent = onCall(async (request) => {
  const { code, phoneNumber, pin } = request.data || {};
  if (!code || !phoneNumber || !pin) {
    throw new HttpsError("invalid-argument", "Access code, phone number, and PIN are required.");
  }

  const codeRef = admin.firestore().collection("parent_access_codes").doc(code);
  const doc = await codeRef.get();
  if (!doc.exists) {
    throw new HttpsError("not-found", "Invalid access code.");
  }

  const data = doc.data();
  if (data.isActive === false) {
    const reason = data.deactivationReason ? `\nReason: ${data.deactivationReason}` : "";
    throw new HttpsError("permission-denied", `This access code has been deactivated.${reason}`);
  }
  if (data.phoneNumber !== phoneNumber) {
    throw new HttpsError("permission-denied", "Phone number does not match this access code.");
  }
  assertNotLockedOut(data, HttpsError);
  const verification = verifyPin(pin, data.pin);
  if (!verification.valid) {
    await codeRef.update(failedAttemptUpdate(data, admin));
    throw new HttpsError("permission-denied", "Incorrect PIN.");
  }
  const lockoutUpdate = clearLockoutUpdate(admin);
  if (verification.legacy) {
    // Opportunistically upgrade a legacy plaintext PIN to a hashed one now
    // that it's been proven correct.
    lockoutUpdate.pin = hashPin(pin);
  }
  await codeRef.update(lockoutUpdate);

  const uid = `parent_${code}`;
  const studentIds = data.studentIds || [];

  // Resolve each child's class so the parent can be scoped to "Class:X"
  // broadcasts, in addition to the general "Parents" group.
  const groups = new Set(["Parents"]);
  if (studentIds.length > 0) {
    const studentDocs = await admin.firestore().getAll(
      ...studentIds.map((id) => admin.firestore().collection("students").doc(id))
    );
    for (const sDoc of studentDocs) {
      const classId = sDoc.exists ? (sDoc.data().classId || sDoc.data().className) : null;
      if (classId) groups.add(`Class:${classId}`);
    }
  }

  await admin.firestore().collection("users").doc(uid).set({
    role: "parent",
    studentIds,
    groups: Array.from(groups),
    name: data.parentName || "Parent",
    phoneNumber: data.phoneNumber,
    schoolId: data.schoolId || "",
    isActive: true,
  }, { merge: true });

  const token = await admin.auth().createCustomToken(uid, { role: "parent" });
  return { token, mustChangePin: !!data.mustChangePin };
});

/**
 * Sets a parent's PIN (first-time setup or reset). Runs before the parent
 * has a Firebase Auth session, so identity is proven with code+phone
 * instead of request.auth.
 */
exports.completeParentPinSetup = onCall(async (request) => {
  const { code, phoneNumber, newPin } = request.data || {};
  if (!code || !phoneNumber || !newPin) {
    throw new HttpsError("invalid-argument", "Access code, phone number, and new PIN are required.");
  }

  const codeRef = admin.firestore().collection("parent_access_codes").doc(code);
  const doc = await codeRef.get();
  if (!doc.exists) {
    throw new HttpsError("not-found", "Invalid access code.");
  }
  const data = doc.data();
  if (data.isActive === false) {
    throw new HttpsError("permission-denied", "This access code has been deactivated.");
  }
  if (data.phoneNumber !== phoneNumber) {
    throw new HttpsError("permission-denied", "Phone number does not match this access code.");
  }

  await codeRef.update({
    pin: hashPin(newPin),
    mustChangePin: false,
    failedPinAttempts: 0,
    pinLockedUntil: admin.firestore.FieldValue.delete(),
  });
  return { success: true };
});

/**
 * Mints a custom-token session for a single student, verified by
 * code+phone+PIN against a student_access_codes doc - same shape as
 * loginParent, scoped to one studentId instead of a sibling group.
 */
exports.loginStudent = onCall(async (request) => {
  const { code, phoneNumber, pin } = request.data || {};
  if (!code || !phoneNumber || !pin) {
    throw new HttpsError("invalid-argument", "Access code, phone number, and PIN are required.");
  }

  const codeRef = admin.firestore().collection("student_access_codes").doc(code);
  const doc = await codeRef.get();
  if (!doc.exists) {
    throw new HttpsError("not-found", "Invalid access code.");
  }

  const data = doc.data();
  if (data.isActive === false) {
    const reason = data.deactivationReason ? `\nReason: ${data.deactivationReason}` : "";
    throw new HttpsError("permission-denied", `This access code has been deactivated.${reason}`);
  }
  if (data.phoneNumber !== phoneNumber) {
    throw new HttpsError("permission-denied", "Phone number does not match this access code.");
  }
  assertNotLockedOut(data, HttpsError);
  const verification = verifyPin(pin, data.pin);
  if (!verification.valid) {
    await codeRef.update(failedAttemptUpdate(data, admin));
    throw new HttpsError("permission-denied", "Incorrect PIN.");
  }
  const lockoutUpdate = clearLockoutUpdate(admin);
  if (verification.legacy) {
    lockoutUpdate.pin = hashPin(pin);
  }
  await codeRef.update(lockoutUpdate);

  const uid = data.studentId;
  if (!uid) {
    throw new HttpsError("failed-precondition", "This access code is not linked to a student.");
  }

  await admin.firestore().collection("users").doc(uid).set({
    role: "student",
    studentId: uid,
    name: data.studentName || "Student",
    phoneNumber: data.phoneNumber,
    schoolId: data.schoolId || "",
    isActive: true,
  }, { merge: true });

  const token = await admin.auth().createCustomToken(uid, { role: "student" });
  return { token, mustChangePin: !!data.mustChangePin };
});

/**
 * Sets a student's PIN (first-time setup or reset). Runs before the
 * student has a Firebase Auth session, so identity is proven with
 * code+phone instead of request.auth - mirrors completeParentPinSetup.
 */
exports.completeStudentPinSetup = onCall(async (request) => {
  const { code, phoneNumber, newPin } = request.data || {};
  if (!code || !phoneNumber || !newPin) {
    throw new HttpsError("invalid-argument", "Access code, phone number, and new PIN are required.");
  }

  const codeRef = admin.firestore().collection("student_access_codes").doc(code);
  const doc = await codeRef.get();
  if (!doc.exists) {
    throw new HttpsError("not-found", "Invalid access code.");
  }
  const data = doc.data();
  if (data.isActive === false) {
    throw new HttpsError("permission-denied", "This access code has been deactivated.");
  }
  if (data.phoneNumber !== phoneNumber) {
    throw new HttpsError("permission-denied", "Phone number does not match this access code.");
  }

  await codeRef.update({
    pin: hashPin(newPin),
    mustChangePin: false,
    failedPinAttempts: 0,
    pinLockedUntil: admin.firestore.FieldValue.delete(),
  });
  return { success: true };
});

/**
 * Signs a student's digital-identity QR payload server-side, so the
 * credential can be verified as authentic (not just decoded) by any future
 * scanner. The QR never encodes PII - only the identity's opaque
 * uniqueSystemId, its tenant scope, and an issue timestamp, HMAC-signed
 * with a server-only secret so it can't be forged client-side. Envelope
 * format: "<base64(uniqueSystemId|schoolId|issuedAtMillis)>.<hmacHex>".
 */
function studentCredentialSecret() {
  const secret = process.env.STUDENT_CREDENTIAL_HMAC_SECRET;
  if (!secret) {
    throw new HttpsError(
      "failed-precondition",
      "Student credential signing secret is not configured.",
    );
  }
  return secret;
}

function signStudentCredentialPayload(uniqueSystemId, schoolId, issuedAtMillis) {
  const payload = `${uniqueSystemId}|${schoolId}|${issuedAtMillis}`;
  const payloadB64 = Buffer.from(payload, "utf8").toString("base64url");
  const hmac = createHmac("sha256", studentCredentialSecret())
    .update(payload)
    .digest("hex");
  return `${payloadB64}.${hmac}`;
}

exports.signStudentCredential = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  const { studentId } = request.data || {};
  if (!studentId) {
    throw new HttpsError("invalid-argument", "studentId is required.");
  }

  const identitySnap = await admin
    .firestore()
    .collection("student_identities")
    .where("studentId", "==", studentId)
    .limit(1)
    .get();
  if (identitySnap.empty) {
    throw new HttpsError("not-found", "No identity found for this student.");
  }
  const identityDoc = identitySnap.docs[0];
  const identity = identityDoc.data();

  const callerSnap = await admin.firestore().collection("users").doc(request.auth.uid).get();
  const callerSchoolId = callerSnap.exists ? callerSnap.data().schoolId : null;
  if (!callerSchoolId || callerSchoolId !== identity.schoolId) {
    throw new HttpsError("permission-denied", "Cannot sign a credential outside your school.");
  }

  const issuedAtMillis = Date.now();
  const qrCodeData = signStudentCredentialPayload(
    identity.uniqueSystemId,
    identity.schoolId,
    issuedAtMillis,
  );

  await identityDoc.ref.update({ qrCodeData, credentialIssuedAt: issuedAtMillis });
  return { qrCodeData, issuedAtMillis };
});

/**
 * Verifies a scanned QR envelope's signature and returns the identity it
 * refers to, without ever trusting the client-decoded payload directly.
 * Future modules (attendance, library, transport, etc.) should call this
 * rather than re-implementing verification against the raw Firestore data.
 */
exports.verifyStudentCredential = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  const { qrCodeData } = request.data || {};
  if (!qrCodeData || !qrCodeData.includes(".")) {
    throw new HttpsError("invalid-argument", "qrCodeData is required.");
  }

  const [payloadB64, providedHmac] = qrCodeData.split(".");
  let payload;
  try {
    payload = Buffer.from(payloadB64, "base64url").toString("utf8");
  } catch (err) {
    throw new HttpsError("invalid-argument", "Malformed credential.");
  }
  const expectedHmac = createHmac("sha256", studentCredentialSecret())
    .update(payload)
    .digest("hex");
  if (expectedHmac !== providedHmac) {
    throw new HttpsError("permission-denied", "Credential signature is invalid.");
  }

  const [uniqueSystemId, schoolId] = payload.split("|");

  const callerSnap = await admin.firestore().collection("users").doc(request.auth.uid).get();
  const callerSchoolId = callerSnap.exists ? callerSnap.data().schoolId : null;
  if (!callerSchoolId || callerSchoolId !== schoolId) {
    throw new HttpsError("permission-denied", "Credential belongs to a different school.");
  }

  return { valid: true, uniqueSystemId, schoolId };
});

// ============================================================================
// Notification Delivery Triggers
// ============================================================================

/**
 * Triggered when a new document is added to 'broadcast_queue'.
 * Delivers push notifications to FCM topics based on targetGroups.
 */
exports.processBroadcastQueue = onDocumentCreated("broadcast_queue/{id}", async (event) => {
  const data = event.data.data();
  if (data.status !== "pending") return;

  const { notification, targets } = data;

  try {
    // Send to each target group as an FCM topic
    // Targets in DB are like ['Parents', 'Class:P.1']
    // We map these to topics like 'topic_Parents', 'topic_Class_P1'
    const sendPromises = targets.map(target => {
      const topicName = target.replace(/[^a-zA-Z0-9-_.~%]/g, '_');
      return admin.messaging().send({
        topic: `topic_${topicName}`,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        android: {
          priority: "high",
          notification: { channelId: "school_pulse_alerts" },
        },
        apns: {
          payload: { aps: { sound: "default" } },
        },
      });
    });

    await Promise.all(sendPromises);
    await event.data.ref.update({ status: "sent", sentAt: admin.firestore.FieldValue.serverTimestamp() });
  } catch (err) {
    console.error("Broadcast failed:", err);
    await event.data.ref.update({ status: "failed", error: err.message });
  }
});

/**
 * Triggered when a new document is added to 'notification_queue'.
 * Delivers a direct push notification to a specific device token.
 */
exports.processDirectNotificationQueue = onDocumentCreated("notification_queue/{id}", async (event) => {
  const data = event.data.data();
  if (data.status !== "pending") return;

  const { token, notification, data: extraData } = data;

  try {
    await admin.messaging().send({
      token: token,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: extraData || {},
      android: {
        priority: "high",
        notification: { channelId: "school_pulse_alerts" },
      },
      apns: {
        payload: { aps: { sound: "default" } },
      },
    });
    await event.data.ref.update({ status: "sent", sentAt: admin.firestore.FieldValue.serverTimestamp() });
  } catch (err) {
    console.error("Direct notification failed:", err);
    await event.data.ref.update({ status: "failed", error: err.message });
  }
});

/**
 * Pushes a new chat message to everyone in the conversation except the
 * sender.
 *
 * This deliberately runs server-side rather than in the app: fanning out
 * would otherwise mean the sending client reading every recipient's token
 * subcollection on every keystroke-length message, which is both slow on a
 * phone and impossible to secure (a client must not be able to decide who
 * gets pushed). Recipients who muted the chat are skipped, and the data
 * payload carries the conversation id so tapping the notification can deep
 * link straight into the thread.
 */
exports.processChatMessage = onDocumentCreated(
  "conversations/{conversationId}/messages/{messageId}",
  async (event) => {
    const message = event.data.data();
    const { conversationId } = event.params;

    const conversationRef = admin.firestore().collection("conversations").doc(conversationId);
    const conversationSnap = await conversationRef.get();
    if (!conversationSnap.exists) return;

    const conversation = conversationSnap.data();
    const muted = conversation.mutedBy || [];
    const recipients = (conversation.participantIds || [])
      .filter((uid) => uid !== message.senderId && !muted.includes(uid));
    if (recipients.length === 0) return;

    // A 1:1 chat shows the sender's name; a group shows "Sender · Group".
    const title = conversation.type === "direct"
      ? message.senderName
      : `${message.senderName} · ${conversation.title || "Group"}`;
    const body = previewForPush(message);

    const tokenLookups = await Promise.all(
      recipients.map((uid) =>
        admin.firestore().collection("users").doc(uid).collection("tokens").get()
      )
    );
    const tokens = tokenLookups.flatMap((snap) => snap.docs.map((doc) => doc.id));
    if (tokens.length === 0) return;

    try {
      await admin.messaging().sendEachForMulticast({
        tokens,
        notification: { title, body },
        // Shaped for NotificationPushPayload.tryParse on the client: it
        // needs an id, a NotificationType name, and the conversation id -
        // that trio is what lets NotificationDeepLinkRouter open
        // /messages/chat/<id> when the notification is tapped.
        data: {
          notificationId: event.params.messageId,
          type: conversation.type === "direct" ? "newMessage" : "groupMessage",
          relatedConversationId: conversationId,
          conversationId,
        },
        android: {
          priority: "high",
          notification: { channelId: "school_pulse_alerts" },
        },
        apns: { payload: { aps: { sound: "default" } } },
      });
    } catch (err) {
      console.error("Chat message push failed:", err);
    }
  }
);

/** Mirrors ChatMessageModel.preview on the client. */
function previewForPush(message) {
  switch (message.type) {
    case "image": return "📷 Photo";
    case "video": return "🎬 Video";
    case "audio": return "🎤 Voice message";
    case "file": return `📄 ${message.fileName || "Document"}`;
    case "location": return "📍 Location";
    case "contact": return "👤 Contact";
    case "poll": return "📊 Poll";
    case "event": return "📅 Event";
    default: return message.content || "New message";
  }
}

/**
 * No SMS provider is wired up yet (no Twilio/Africa's Talking call exists
 * anywhere in this codebase). BroadcastSmsScreen's composer UI already
 * disables the SMS channel and never lets it be selected, so this should be
 * unreachable today - but if that guard is ever removed without wiring a
 * real provider here, this must not report success. "not_configured"
 * (rather than "sent"/"processed_placeholder") keeps the alerts audit doc
 * that Broadcast History reads from lying about whether anything was
 * actually dispatched.
 */
exports.processSmsQueue = onDocumentCreated("sms_queue/{id}", async (event) => {
  const data = event.data.data();
  if (data.status !== "pending") return;

  console.warn("SMS Queue triggered but no provider is configured:", data.targets);
  await event.data.ref.update({ status: "not_configured" });

  const matchingAlerts = await admin.firestore()
    .collection("alerts")
    .where("type", "==", "SMS")
    .where("status", "==", "sent")
    .where("body", "==", data.body)
    .limit(5)
    .get();
  await Promise.all(
    matchingAlerts.docs.map((doc) => doc.ref.update({ status: "not_configured" }))
  );
});

/**
 * processBroadcastQueue/processSmsQueue above only fire once, when the
 * queue doc is first created, and both ignore status "scheduled" - so a
 * broadcast scheduled for later was written once and then silently never
 * revisited by anything. This runs periodically and delivers any broadcast
 * whose scheduled time has arrived.
 */
exports.processScheduledBroadcasts = onSchedule("every 5 minutes", async () => {
  await recordJobRun("processScheduledBroadcasts", 5, async () => {
  const now = admin.firestore.Timestamp.now();

  const dueBroadcasts = await admin.firestore()
    .collection("broadcast_queue")
    .where("status", "==", "scheduled")
    .where("scheduledAt", "<=", now)
    .get();

  for (const doc of dueBroadcasts.docs) {
    const { notification, targets } = doc.data();
    try {
      await Promise.all(targets.map((target) => {
        const topicName = target.replace(/[^a-zA-Z0-9-_.~%]/g, "_");
        return admin.messaging().send({
          topic: `topic_${topicName}`,
          notification: { title: notification.title, body: notification.body },
          android: { priority: "high", notification: { channelId: "school_pulse_alerts" } },
          apns: { payload: { aps: { sound: "default" } } },
        });
      }));
      await doc.ref.update({ status: "sent", sentAt: admin.firestore.FieldValue.serverTimestamp() });
    } catch (err) {
      console.error("Scheduled broadcast failed:", err);
      await doc.ref.update({ status: "failed", error: err.message });
    }
  }

  const dueSms = await admin.firestore()
    .collection("sms_queue")
    .where("status", "==", "scheduled")
    .where("scheduledAt", "<=", now)
    .get();
  for (const doc of dueSms.docs) {
    console.warn("Scheduled SMS queue triggered but no provider is configured:", doc.data().targets);
    await doc.ref.update({ status: "not_configured" });
  }

  // Keep the matching 'alerts' audit doc (Recent Broadcasts list) in sync
  // so its status badge doesn't stay stuck on "scheduled" forever. SMS
  // alerts are marked separately since no provider actually dispatched them
  // (see processSmsQueue) - only Push alerts get a genuine "sent".
  const dueAlerts = await admin.firestore()
    .collection("alerts")
    .where("status", "==", "scheduled")
    .where("scheduledAt", "<=", now)
    .get();
  for (const doc of dueAlerts.docs) {
    const isSms = doc.data().type === "SMS";
    await doc.ref.update({ status: isSms ? "not_configured" : "sent" });
  }
  });
});

/**
 * Fallback poll for while webhooks aren't registered on the provider
 * dashboard yet (or in case one is missed) - checks status directly
 * against MTN/Airtel rather than waiting on a callback.
 */
exports.checkPaymentStatus = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "You must be signed in.");

  const { transactionId } = request.data || {};
  if (!transactionId) throw new HttpsError("invalid-argument", "transactionId is required.");

  const db = admin.firestore();
  const txDoc = await db.collection("payment_transactions").doc(transactionId).get();
  if (!txDoc.exists) throw new HttpsError("not-found", "Transaction not found.");
  const tx = txDoc.data();

  if (tx.status !== "pending") {
    return { status: tx.status };
  }

  if (tx.provider === "mtn") {
    const base = process.env.MTN_MOMO_BASE_URL;
    const subKey = process.env.MTN_MOMO_SUBSCRIPTION_KEY;
    const targetEnv = process.env.MTN_MOMO_TARGET_ENVIRONMENT || "sandbox";
    const accessToken = await getMtnAccessToken();
    const res = await fetch(`${base}/collection/v1_0/requesttopay/${transactionId}`, {
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "X-Target-Environment": targetEnv,
        "Ocp-Apim-Subscription-Key": subKey,
      },
    });
    if (!res.ok) throw new HttpsError("internal", `MTN status check failed: ${res.status}`);
    const data = await res.json();
    const status = data.status === "SUCCESSFUL" ? "success" : (data.status === "FAILED" ? "failed" : "pending");
    if (status !== "pending") await markTransactionResult(transactionId, { status, failureReason: data.reason });
    return { status };
  }

  if (tx.provider === "airtel") {
    const base = process.env.AIRTEL_BASE_URL;
    const accessToken = await getAirtelAccessToken();
    const res = await fetch(`${base}/standard/v1/payments/${transactionId}`, {
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "X-Country": "UG",
        "X-Currency": "UGX",
      },
    });
    if (!res.ok) throw new HttpsError("internal", `Airtel status check failed: ${res.status}`);
    const data = await res.json();
    const success = data.data?.transaction?.status === "TS";
    const failed = data.data?.transaction?.status === "TF";
    const status = success ? "success" : (failed ? "failed" : "pending");
    if (status !== "pending") await markTransactionResult(transactionId, { status });
    return { status };
  }

  throw new HttpsError("invalid-argument", "Unknown provider.");
});

/**
 * Notification module (fan-out, scheduling, escalation, retention, delivery
 * testing). Kept in its own file so this one is not disturbed; re-exported
 * here because the Firebase CLI only deploys what index.js exports.
 */
const notificationFunctions = require("./notifications");

exports.processNotificationRequest = notificationFunctions.processNotificationRequest;
exports.dispatchScheduledNotifications = notificationFunctions.dispatchScheduledNotifications;
exports.escalateUnacknowledgedAlerts = notificationFunctions.escalateUnacknowledgedAlerts;
exports.purgeExpiredNotifications = notificationFunctions.purgeExpiredNotifications;
exports.sendTestNotification = notificationFunctions.sendTestNotification;

// Communication Center orchestrates the notification service; it does not
// introduce another delivery engine.
const communicationCampaignFunctions = require("./communication_campaigns");
exports.saveCommunicationDraft = communicationCampaignFunctions.saveCommunicationDraft;
exports.publishCommunicationCampaign = communicationCampaignFunctions.publishCommunicationCampaign;
exports.cancelCommunicationCampaign = communicationCampaignFunctions.cancelCommunicationCampaign;
exports.supersedeCommunicationCampaign = communicationCampaignFunctions.supersedeCommunicationCampaign;
exports.previewCommunicationAudience = communicationCampaignFunctions.previewCommunicationAudience;
exports.saveCommunicationTemplate = communicationCampaignFunctions.saveCommunicationTemplate;
exports.deleteCommunicationTemplate = communicationCampaignFunctions.deleteCommunicationTemplate;
exports.acknowledgeCommunicationCampaign = communicationCampaignFunctions.acknowledgeCommunicationCampaign;
exports.reconcileCommunicationCampaigns = communicationCampaignFunctions.reconcileCommunicationCampaigns;

const appointmentFunctions = require('./appointments');
exports.queueAppointmentNotifications = appointmentFunctions.queueAppointmentNotifications;
exports.notifyAppointmentStatusChange = appointmentFunctions.notifyAppointmentStatusChange;
exports.sendAppointmentReminderEmails = appointmentFunctions.sendAppointmentReminderEmails;

/**
 * Attendance -> Google Sheets OAuth connection (per-school Google account).
 * Kept separate from attendance_sheets.js so the export logic doesn't carry
 * OAuth/token concerns directly.
 */
const attendanceSheetsOAuthFunctions = require("./attendance_sheets_oauth");
exports.startGoogleSheetsOAuth = attendanceSheetsOAuthFunctions.startGoogleSheetsOAuth;
exports.googleSheetsOAuthCallback = attendanceSheetsOAuthFunctions.googleSheetsOAuthCallback;
exports.disconnectGoogleSheetsOAuth = attendanceSheetsOAuthFunctions.disconnectGoogleSheetsOAuth;

/**
 * Attendance -> Google Sheets export. Kept in its own file for the same
 * reason as notifications.js above.
 */
const attendanceSheetsFunctions = require("./attendance_sheets");
exports.exportAttendanceRecordToSheets = attendanceSheetsFunctions.exportAttendanceRecordToSheets;
exports.syncAttendanceToSheetsNow = attendanceSheetsFunctions.syncAttendanceToSheetsNow;
exports.resyncAttendanceToSheets = attendanceSheetsFunctions.resyncAttendanceToSheets;
exports.exportAttendanceSessionToSheets = attendanceSheetsFunctions.exportAttendanceSessionToSheets;

/**
 * Student roster/identity -> Google Sheets export. Manual-only, reuses the
 * same per-school OAuth connection and spreadsheet as attendance_sheets.js
 * (a second worksheet tab, not a second Google account grant).
 */
const rosterSheetsFunctions = require("./roster_sheets");
exports.exportStudentRosterToSheets = rosterSheetsFunctions.exportStudentRosterToSheets;

// The integration control plane owns safe tenant configuration and audit
// metadata. Provider credentials remain in server-side secret storage.
const integrationCenterFunctions = require("./integration_center");
exports.getIntegrationCenter = integrationCenterFunctions.getIntegrationCenter;
exports.saveIntegrationMetadata = integrationCenterFunctions.saveIntegrationMetadata;
exports.testIntegrationConnection = integrationCenterFunctions.testIntegrationConnection;
exports.disconnectIntegration = integrationCenterFunctions.disconnectIntegration;

const integrationHealthFunctions = require("./integration_health");
exports.getIntegrationHealthSummary = integrationHealthFunctions.getIntegrationHealthSummary;

const integrationDeviceFunctions = require("./integration_devices");
exports.registerIntegrationDevice = integrationDeviceFunctions.registerIntegrationDevice;
exports.updateIntegrationDeviceStatus = integrationDeviceFunctions.updateIntegrationDeviceStatus;
exports.revokeIntegrationDevice = integrationDeviceFunctions.revokeIntegrationDevice;
exports.listIntegrationDevices = integrationDeviceFunctions.listIntegrationDevices;

const integrationWebhookFunctions = require("./integration_webhooks");
exports.createIntegrationWebhook = integrationWebhookFunctions.createIntegrationWebhook;
exports.listIntegrationWebhooks = integrationWebhookFunctions.listIntegrationWebhooks;
exports.disableIntegrationWebhook = integrationWebhookFunctions.disableIntegrationWebhook;

const integrationSyncJobFunctions = require("./integration_sync_jobs");
exports.startIntegrationSync = integrationSyncJobFunctions.startIntegrationSync;
exports.getIntegrationSyncJobs = integrationSyncJobFunctions.getIntegrationSyncJobs;
const institutionHealthFunctions = require("./institution_health");
exports.requestInstitutionHealthRecheck = institutionHealthFunctions.requestInstitutionHealthRecheck;
exports.resolveInstitutionHealthIssue = institutionHealthFunctions.resolveInstitutionHealthIssue;

/**
 * Subscription change requests and usage-metric refreshes. Confirmed by the
 * schoolAdmin audit as callables the Flutter client already calls
 * (SubscriptionRepository) but that never existed - see
 * subscription_management.js for the full scope/approximation notes.
 */
const subscriptionManagementFunctions = require("./subscription_management");
exports.requestSubscriptionChange = subscriptionManagementFunctions.requestSubscriptionChange;
exports.requestSubscriptionUsageRefresh = subscriptionManagementFunctions.requestSubscriptionUsageRefresh;

/**
 * Term-based SaaS billing Phase 1: academic calendar confirmation +
 * subscription_cycles generation. See academic_calendar_billing.js for the
 * full scope note (Phase 1 only - no invoicing/reminders/suspension yet).
 */
const academicCalendarBillingFunctions = require("./academic_calendar_billing");
exports.confirmAcademicCalendar = academicCalendarBillingFunctions.confirmAcademicCalendar;
exports.getRenewalBillingConfig = academicCalendarBillingFunctions.getRenewalBillingConfig;
exports.updateRenewalBillingConfig = academicCalendarBillingFunctions.updateRenewalBillingConfig;

// Phase 3A: student-count-band pricing engine (replaces plan-based pricing
// for cycle generation - see student_pricing_bands.js header).
const studentPricingBandFunctions = require("./student_pricing_bands");
exports.createPricingBand = studentPricingBandFunctions.createPricingBand;
exports.updatePricingBand = studentPricingBandFunctions.updatePricingBand;
exports.deactivatePricingBand = studentPricingBandFunctions.deactivatePricingBand;
exports.getPricingBands = studentPricingBandFunctions.getPricingBands;

/**
 * Student creation with transactional maxStudents cap enforcement. Kept in
 * its own file for the same reason as notifications.js/attendance_sheets.js
 * above - index.js is already large, and this is a self-contained concern.
 */
const studentCapacityFunctions = require("./student_capacity");
exports.createStudentWithCapacityCheck = studentCapacityFunctions.createStudentWithCapacityCheck;
exports.updateStudentStatusWithCapacityAdjustment = studentCapacityFunctions.updateStudentStatusWithCapacityAdjustment;
exports.backfillActiveStudentCounts = studentCapacityFunctions.backfillActiveStudentCounts;

/**
 * Student identity credential issuance (QR). Kept out of the Flutter client
 * for the same reason payments/capacity checks are: minting a token and
 * reserving a school-scoped sequence number must be atomic and must not
 * trust the caller's own randomness, which the old client-side
 * StudentIdentityRepositoryImpl write path did.
 */
const studentCredentialFunctions = require("./student_credentials");
exports.issueStudentIdentity = studentCredentialFunctions.issueStudentIdentity;
exports.regenerateStudentQrCredential = studentCredentialFunctions.regenerateStudentQrCredential;
exports.assignNfcCredential = studentCredentialFunctions.assignNfcCredential;
// Close the "only assign is server-enforced" gap: replace/revoke/reactivate
// now go through the same transactional, audited path as assign, instead of
// the old client-direct-write to schools/{schoolId}/credentials.
exports.replaceNfcCredential = studentCredentialFunctions.replaceNfcCredential;
exports.revokeNfcCredential = studentCredentialFunctions.revokeNfcCredential;
exports.reactivateNfcCredential = studentCredentialFunctions.reactivateNfcCredential;
// Server-side legacy-credential resolver/migration for cards issued before
// credential.identityId was canonicalized to students/{studentId}.
exports.resolveStudentCredential = studentCredentialFunctions.resolveStudentCredential;
// Owner-gated, one-time-per-school backfill for students that predate the
// issueStudentIdentity callable - see functions/student_credentials.js for
// the idempotent/resumable transaction it shares with issueStudentIdentity.
exports.backfillStudentIdentities = studentCredentialFunctions.backfillStudentIdentities;
// Student Portal access-code provisioning (admin generate/reset/enable-
// disable) - server-side for the same reason as above: code entropy and
// PIN clearing must not trust the caller.
exports.provisionStudentAccessCode = studentCredentialFunctions.provisionStudentAccessCode;
exports.resetStudentPin = studentCredentialFunctions.resetStudentPin;
exports.setStudentAccessCodeStatus = studentCredentialFunctions.setStudentAccessCodeStatus;

// Staff ID card + NFC - mirrors the student credential functions above
// against users/staff_identities instead of students/student_identities.
// Kept in a separate file/export set rather than parametrizing the student
// functions so a staff-side change can never regress the shipped student
// flow. See functions/staff_credentials.js.
const staffCredentialFunctions = require("./staff_credentials");
exports.issueStaffIdentity = staffCredentialFunctions.issueStaffIdentity;
exports.regenerateStaffQrCredential = staffCredentialFunctions.regenerateStaffQrCredential;
exports.assignStaffNfcCredential = staffCredentialFunctions.assignStaffNfcCredential;

const studentViewFunctions = require("./student_view");
// Server-side relationship + permission resolver for reading a student's
// data by section (identity/academic/finance/health/discipline/security) -
// see functions/student_view.js's doc comment for why Firestore Rules
// alone cannot enforce e.g. "a Subject Teacher may only read marks for
// students in their own assigned class/subject".
exports.getStudentView = studentViewFunctions.getStudentView;

// ---------------------------------------------------------------------------
// Class Teacher student-care hand-offs
//
// A class teacher can raise a concern, but must never write a clinical record
// or approve a student's absence.  These callable functions create a small,
// auditable hand-off record and let the notification service fan it out to the
// people who own the next decision.
// ---------------------------------------------------------------------------

const STUDENT_CARE_ADMIN_ROLES = [
  "director", "headTeacher", "deputyHead", "deanOfStudies", "schoolAdmin",
];

function rolesOf(profile = {}) {
  return Array.from(new Set([
    profile.role,
    ...(Array.isArray(profile.roles) ? profile.roles : []),
  ].filter(Boolean)));
}

async function requireClassTeacherForStudent(auth, studentId) {
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
  if (!studentId || typeof studentId !== "string") {
    throw new HttpsError("invalid-argument", "studentId is required.");
  }

  const firestore = admin.firestore();
  const [callerDoc, studentDoc] = await Promise.all([
    firestore.collection("users").doc(auth.uid).get(),
    firestore.collection("students").doc(studentId).get(),
  ]);
  if (!callerDoc.exists || !studentDoc.exists) {
    throw new HttpsError("not-found", "The staff member or student was not found.");
  }

  const caller = callerDoc.data();
  const student = studentDoc.data();
  const roles = rolesOf(caller);
  if (!caller.schoolId || caller.schoolId !== student.schoolId) {
    throw new HttpsError("permission-denied", "This student belongs to another school.");
  }

  const isAdmin = roles.some((role) => STUDENT_CARE_ADMIN_ROLES.includes(role));
  let isAssignedTeacher = roles.includes("classTeacher") &&
    caller.assignedClass && caller.assignedClass === student.className;

  // Newer accounts may hold more than one class responsibility.  Preserve
  // that scope here while supporting existing flat assignedClass accounts.
  if (!isAssignedTeacher && roles.includes("classTeacher")) {
    const assignments = await firestore
      .collection("schools")
      .doc(caller.schoolId)
      .collection("staff_role_assignments")
      .where("schoolId", "==", caller.schoolId)
      .where("staffId", "==", auth.uid)
      .where("roleType", "==", "classTeacher")
      .get();
    isAssignedTeacher = assignments.docs.some((doc) => {
      const assignment = doc.data();
      return assignment.status === "active" && assignment.className === student.className;
    });
  }
  if (!isAdmin && !isAssignedTeacher) {
    throw new HttpsError(
      "permission-denied",
      "You are not assigned as this student's class teacher."
    );
  }

  return { caller, student, roles };
}

async function queueStudentCareNotification({
  schoolId, senderId, sender, audience, category, type, title, body,
  studentId, studentName, sourceEntityId, priority = "high",
}) {
  await admin.firestore().collection("notification_requests").add({
    schoolId,
    senderId,
    senderNameSnapshot: sender.name || "Class Teacher",
    senderRoleSnapshot: "Class Teacher",
    senderKind: "human",
    audience,
    category,
    type,
    title,
    shortBody: body,
    fullBody: body,
    sourceModule: "class_teacher",
    sourceEntityId,
    relatedStudentId: studentId,
    relatedStudentName: studentName,
    priority,
    persistence: "permanent",
    requiresAcknowledgment: priority === "urgent",
    status: "pending",
    idempotencyKey: `${sourceEntityId}-${category}`,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

exports.referStudentToNurse = onCall(async (request) => {
  const { studentId, concern, urgency = "standard" } = request.data || {};
  const cleanConcern = typeof concern === "string" ? concern.trim() : "";
  if (cleanConcern.length < 5 || cleanConcern.length > 2000) {
    throw new HttpsError("invalid-argument", "Enter a health concern between 5 and 2,000 characters.");
  }
  if (!["standard", "urgent"].includes(urgency)) {
    throw new HttpsError("invalid-argument", "urgency must be standard or urgent.");
  }
  const { caller, student } = await requireClassTeacherForStudent(request.auth, studentId);
  const firestore = admin.firestore();
  const referral = firestore.collection("student_health_referrals").doc();
  const studentName = student.fullName || student.name || "Student";
  await referral.set({
    schoolId: caller.schoolId,
    studentId,
    studentName,
    className: student.className || null,
    concern: cleanConcern,
    urgency,
    status: "awaiting_nurse_review",
    referredBy: request.auth.uid,
    referredByName: caller.name || "Class Teacher",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await queueStudentCareNotification({
    schoolId: caller.schoolId,
    senderId: request.auth.uid,
    sender: caller,
    audience: { kind: "anyOf", definitions: [
      { kind: "roles", roles: ["nurse"] },
      { kind: "roles", roles: STUDENT_CARE_ADMIN_ROLES },
    ] },
    category: "medical",
    type: "nurseAlert",
    title: `${urgency === "urgent" ? "Urgent " : ""}student health referral`,
    body: `${studentName} has been referred by the class teacher.`,
    studentId,
    studentName,
    sourceEntityId: referral.id,
    priority: urgency === "urgent" ? "urgent" : "high",
  });
  return { referralId: referral.id, status: "awaiting_nurse_review" };
});

exports.submitClassTeacherLeaveApplication = onCall(async (request) => {
  const { studentId, reason, destination, departureDate, expectedReturnDate } = request.data || {};
  const cleanReason = typeof reason === "string" ? reason.trim() : "";
  const cleanDestination = typeof destination === "string" ? destination.trim() : "";
  const departure = new Date(departureDate);
  const expectedReturn = new Date(expectedReturnDate);
  if (cleanReason.length < 5 || cleanReason.length > 1000 || !cleanDestination) {
    throw new HttpsError("invalid-argument", "Reason and destination are required.");
  }
  if (Number.isNaN(departure.getTime()) || Number.isNaN(expectedReturn.getTime()) || expectedReturn < departure) {
    throw new HttpsError("invalid-argument", "Enter valid leave and return dates.");
  }
  const { caller, student } = await requireClassTeacherForStudent(request.auth, studentId);
  const firestore = admin.firestore();
  // Reuse the boarding leave queue that the Patron/Matron already works from;
  // this makes a class-teacher request actionable in their existing module.
  const leave = firestore.collection("boarding_leave_requests").doc();
  const studentName = student.fullName || student.name || "Student";
  const gender = String(student.gender || "").toLowerCase();
  const isFemale = gender === "female" || gender === "f";
  const patronRole = isFemale ? "boardingMatron" : "boardingPatron";
  await leave.set({
    schoolId: caller.schoolId,
    studentId,
    studentName,
    className: student.className || null,
    reason: cleanReason,
    destination: cleanDestination,
    departureDate: admin.firestore.Timestamp.fromDate(departure),
    expectedReturnDate: admin.firestore.Timestamp.fromDate(expectedReturn),
    dormitoryId: student.dormitoryId || "",
    gender: isFemale ? "Female" : "Male",
    status: "Pending",
    source: "class_teacher",
    patronRole,
    requestedBy: request.auth.uid,
    requestedByName: caller.name || "Class Teacher",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  await queueStudentCareNotification({
    schoolId: caller.schoolId,
    senderId: request.auth.uid,
    sender: caller,
    audience: { kind: "anyOf", definitions: [
      { kind: "roles", roles: [patronRole] },
      { kind: "roles", roles: ["nurse"] },
      { kind: "roles", roles: STUDENT_CARE_ADMIN_ROLES },
    ] },
    category: "hostel",
    type: "hostelNotice",
    title: "Student leave application awaiting review",
    body: `${studentName}'s leave application needs patron review. The nurse and school leadership have been informed.`,
    studentId,
    studentName,
    sourceEntityId: leave.id,
  });
  return { leaveApplicationId: leave.id, status: "awaiting_patron_review" };
});

/** Read-only, scoped projection for the Class Teacher's More menu. */
exports.getClassTeacherStudentMoreData = onCall(async (request) => {
  const { studentId, section } = request.data || {};
  const allowedSections = ["contact", "documents", "siblings", "notes", "timeline"];
  if (!allowedSections.includes(section)) {
    throw new HttpsError("invalid-argument", "Unknown More Options section.");
  }
  const { caller, student } = await requireClassTeacherForStudent(request.auth, studentId);
  const firestore = admin.firestore();
  const timestamp = (value) => value && typeof value.toDate === "function"
    ? value.toDate().toISOString() : null;
  if (section === "contact") {
    return { contacts: (student.emergencyContacts || []).map((contact) => ({
      name: contact.name || "Guardian", relationship: contact.relationship || "Guardian",
      phoneNumber: contact.phoneNumber || null, email: contact.email || null,
    })) };
  }
  if (section === "documents") {
    return { documents: Object.entries(student.documents || {}).map(([type, url]) => ({ type, url })) };
  }
  if (section === "siblings") {
    const parentIds = Array.isArray(student.parentIds) ? student.parentIds.filter(Boolean) : [];
    if (parentIds.length === 0) return { siblings: [] };
    const siblings = await firestore.collection("students")
      .where("schoolId", "==", caller.schoolId)
      .where("parentIds", "array-contains-any", parentIds.slice(0, 30)).get();
    return { siblings: siblings.docs.filter((doc) => doc.id !== studentId).map((doc) => {
      const data = doc.data();
      return { studentId: doc.id, name: data.name || data.fullName || "Student", className: data.className || "", status: data.status || "active" };
    }) };
  }
  const notes = await firestore.collection("class_teacher_student_notes")
    .where("schoolId", "==", caller.schoolId).where("studentId", "==", studentId).get();
  const noteRows = notes.docs.map((doc) => {
    const data = doc.data();
    return { id: doc.id, text: data.text, createdByName: data.createdByName || "Class Teacher", createdAt: timestamp(data.createdAt), type: "note" };
  });
  if (section === "notes") return { notes: noteRows.sort((a, b) => String(b.createdAt).localeCompare(String(a.createdAt))) };
  const [referrals, leaves] = await Promise.all([
    firestore.collection("student_health_referrals").where("schoolId", "==", caller.schoolId).where("studentId", "==", studentId).get(),
    firestore.collection("boarding_leave_requests").where("schoolId", "==", caller.schoolId).where("studentId", "==", studentId).get(),
  ]);
  const timeline = [
    ...noteRows,
    ...referrals.docs.map((doc) => { const data = doc.data(); return { id: doc.id, type: "health_referral", title: "Health referral", detail: data.status || "awaiting nurse review", createdAt: timestamp(data.createdAt) }; }),
    ...leaves.docs.map((doc) => { const data = doc.data(); return { id: doc.id, type: "leave", title: "Leave application", detail: data.status || "awaiting patron review", createdAt: timestamp(data.createdAt) }; }),
  ].sort((a, b) => String(b.createdAt).localeCompare(String(a.createdAt)));
  return { timeline };
});

exports.addClassTeacherStudentNote = onCall(async (request) => {
  const { studentId, text } = request.data || {};
  const cleanText = typeof text === "string" ? text.trim() : "";
  if (cleanText.length < 2 || cleanText.length > 2000) {
    throw new HttpsError("invalid-argument", "A note must be between 2 and 2,000 characters.");
  }
  const { caller, student } = await requireClassTeacherForStudent(request.auth, studentId);
  const note = admin.firestore().collection("class_teacher_student_notes").doc();
  await note.set({
    schoolId: caller.schoolId, studentId, studentName: student.name || student.fullName || "Student",
    text: cleanText, createdBy: request.auth.uid, createdByName: caller.name || "Class Teacher",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { noteId: note.id };
});

/**
 * Records a class-teacher observation in the canonical class behaviour
 * collection.  The client cannot decide scope or attribution: both come from
 * the authenticated teacher and the student's current placement.
 */
exports.recordClassTeacherBehaviour = onCall(async (request) => {
  const { studentId, categoryCode, note, recommendation, followUpRequired = false } = request.data || {};
  const cleanNote = typeof note === "string" ? note.trim() : "";
  const cleanCategory = typeof categoryCode === "string" ? categoryCode.trim() : "";
  const cleanRecommendation = typeof recommendation === "string" ? recommendation.trim() : "";
  if (!cleanCategory || cleanCategory.length > 100 || cleanNote.length < 5 || cleanNote.length > 2000) {
    throw new HttpsError("invalid-argument", "Select a category and enter a behaviour note between 5 and 2,000 characters.");
  }
  const { caller, student } = await requireClassTeacherForStudent(request.auth, studentId);
  if (!student.classId || !student.academicYearId) {
    throw new HttpsError("failed-precondition", "This student does not have an active class placement.");
  }
  const firestore = admin.firestore();
  const record = firestore.collection("schools").doc(caller.schoolId)
    .collection("class_behaviour_records").doc();
  const concernCodes = new Set(["lateness", "disruption", "incomplete_work"]);
  const isConcern = concernCodes.has(cleanCategory) || followUpRequired;
  await record.set({
    schoolId: caller.schoolId,
    campusId: student.campusId || caller.campusId || "",
    classId: student.classId,
    className: student.className || "",
    streamId: student.streamId || null,
    academicYearId: student.academicYearId,
    termId: student.termId || "",
    studentId,
    studentName: student.name || student.fullName || "Student",
    category: cleanCategory,
    note: cleanNote,
    recommendation: cleanRecommendation || null,
    followUpRequired: followUpRequired === true,
    followUpClosed: false,
    followUpNote: null,
    disciplineCaseId: null,
    disciplineStatus: null,
    recordedBy: request.auth.uid,
    recordedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedBy: request.auth.uid,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    // Flat assignment accounts do not have a stable assignment id. This is
    // an audit field only; authorization happened above.
    roleAssignmentId: "server-validated",
  });
  if (isConcern && followUpRequired === true) {
    await queueStudentCareNotification({
      schoolId: caller.schoolId,
      senderId: request.auth.uid,
      sender: caller,
      audience: { kind: "anyOf", definitions: [
        { kind: "roles", roles: ["guidanceDiscipline"] },
        { kind: "roles", roles: STUDENT_CARE_ADMIN_ROLES },
      ] },
      category: "discipline",
      type: "disciplineCase",
      title: "Student behaviour follow-up required",
      body: `${student.name || student.fullName || "A student"} has a class-teacher follow-up record.`,
      studentId,
      studentName: student.name || student.fullName || "Student",
      sourceEntityId: record.id,
    });
  }
  return { recordId: record.id };
});

// ---------------------------------------------------------------------------
// Class Teacher panel - the three actions that must not be a client write.
//
// Each of these decides something a teacher would otherwise be deciding about
// their own authority: whether a report reaches parents, whether a historical
// register may be rewritten, and whether one staff member may hold a second
// class. The Admin SDK bypasses Firestore rules entirely, so the checks in
// here are the only gate.
// ---------------------------------------------------------------------------

const ACADEMIC_ADMIN_ROLES = ["director", "headTeacher", "deputyHead", "schoolAdmin"];

/** Loads the caller's profile and refuses anyone outside the named roles. */
async function requireRole(auth, roles, action) {
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const callerDoc = await admin.firestore().collection("users").doc(auth.uid).get();
  const caller = callerDoc.exists ? callerDoc.data() : {};
  const callerRoles = Array.isArray(caller.roles)
    ? caller.roles
    : [caller.role].filter(Boolean);

  if (!callerRoles.some((role) => roles.includes(role))) {
    throw new HttpsError("permission-denied", action);
  }
  if (!caller.schoolId) {
    throw new HttpsError(
      "failed-precondition",
      "Your account is not assigned to a school."
    );
  }

  return { uid: auth.uid, schoolId: caller.schoolId, roles: callerRoles };
}

/** Appends to the same audit trail the app writes, so one trail covers both. */
async function writeAudit(schoolId, entry) {
  await admin
    .firestore()
    .collection("schools")
    .doc(schoolId)
    .collection("subject_audit_logs")
    .add({
      schoolId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      platform: "cloud_function",
      ...entry,
    });
}

/**
 * Authorizes a report-card generation/publication call from either the
 * academic office (ACADEMIC_ADMIN_ROLES, unconditional) or a Class Teacher
 * holding a live `staff_role_assignments` row that actually covers this
 * class/year and grants `class.report.generate` - the same two conditions
 * firestore.rules' holdsAssignment()/grantsPermission() enforce for the
 * client-side class_report_entries write path. Re-checked here because the
 * Admin SDK bypasses those rules entirely.
 */
async function requireClassReportGenerationAccess(auth, { classId, academicYearId }) {
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
  const db = admin.firestore();
  const callerDoc = await db.collection("users").doc(auth.uid).get();
  const caller = callerDoc.exists ? callerDoc.data() : {};
  const callerRoles = Array.isArray(caller.roles)
    ? caller.roles
    : [caller.role].filter(Boolean);
  if (!caller.schoolId) {
    throw new HttpsError(
      "failed-precondition",
      "Your account is not assigned to a school."
    );
  }
  if (callerRoles.some((role) => ACADEMIC_ADMIN_ROLES.includes(role))) {
    return { uid: auth.uid, schoolId: caller.schoolId, roles: callerRoles };
  }

  // Not academic office - must hold a live, matching class-teacher assignment.
  const assignments = await db
    .collection("schools")
    .doc(caller.schoolId)
    .collection("staff_role_assignments")
    .where("userId", "==", auth.uid)
    .where("classId", "==", classId)
    .where("academicYearId", "==", academicYearId)
    .where("status", "==", "active")
    .limit(1)
    .get();

  const authorized = assignments.docs.some((doc) => {
    const permissions = doc.data()?.permissionScope?.permissions;
    return Array.isArray(permissions) && permissions.includes("class.report.generate");
  });

  if (!authorized) {
    throw new HttpsError(
      "permission-denied",
      "You do not hold the class.report.generate permission for this class."
    );
  }
  return { uid: auth.uid, schoolId: caller.schoolId, roles: callerRoles };
}

/**
 * Loads the school's applicable grading system + bands, following the same
 * resolution the (dead) client-side pipeline used: the school's single
 * active default. See lib/features/teacher/data/datasources/
 * teacher_remote_data_source.dart's _resolveDefaultGradingSystem - this is
 * intentionally the same behaviour, not a new richer one, so a school does
 * not see two different grading resolutions depending on which code path
 * happened to run.
 */
async function loadDefaultGradingSystem(schoolId) {
  const db = admin.firestore();
  const systemSnap = await db
    .collection("structure_grading_systems")
    .where("schoolId", "==", schoolId)
    .where("isActive", "==", true)
    .where("isDefault", "==", true)
    .limit(1)
    .get();
  if (systemSnap.empty) return { gradingSystem: null, gradeBands: [] };

  const doc = systemSnap.docs[0];
  const data = doc.data();
  const gradingSystem = {
    id: doc.id,
    schoolId: data.schoolId,
    name: data.name || "",
    isActive: data.isActive !== false,
    isDefault: data.isDefault === true,
    version: data.version || 1,
    decimalPlaces: data.decimalPlaces ?? 2,
    passingScore: data.passingScore ?? null,
    passingGradeCode: data.passingGradeCode ?? null,
  };

  const bandsSnap = await db
    .collection("grade_bands")
    .where("schoolId", "==", schoolId)
    .where("gradingSystemId", "==", gradingSystem.id)
    .get();
  const gradeBands = bandsSnap.docs.map((b) => {
    const band = b.data();
    return {
      id: b.id,
      schoolId: band.schoolId,
      gradingSystemId: band.gradingSystemId,
      grade: band.grade || "",
      label: band.label || "",
      minScore: (band.minScore ?? 0),
      maxScore: (band.maxScore ?? 0),
      order: band.order ?? 0,
      remarks: band.remarks || "",
      gradePoint: band.gradePoint ?? null,
      isPassing: band.isPassing !== false,
      hasNumericBoundary: band.hasNumericBoundary !== false,
    };
  });

  return { gradingSystem, gradeBands };
}

/**
 * The Report Card Engine: reads every approved subject_assessments/
 * student_marks row for one class/year/term, resolves grades from the
 * school's active grading configuration, aggregates each learner's totals
 * and (if enabled) class position, and writes one immutable snapshot per
 * learner under schools/{schoolId}/reportCards/{reportCardId}.
 *
 * Idempotent: a repeat call with unchanged source data resolves to the same
 * sourceHash as the existing non-finalized snapshot and is a no-op (counted
 * as "unchanged"). A changed hash before finalization replaces the working
 * snapshot in place, bumping `version`. A finalized (isFinalized: true)
 * snapshot is never touched - a correction must go through a distinct
 * supersession path, which is out of scope for this phase.
 */
async function _generateClassReportCardsInternal({
  schoolId,
  classId,
  streamId,
  academicYearId,
  termId,
  studentIds,
  actorUid,
}) {
  const db = admin.firestore();
  const school = db.collection("schools").doc(schoolId);
  const batchId = db.collection("_ids").doc().id;

  const { gradingSystem, gradeBands } = await loadDefaultGradingSystem(schoolId);
  const bandErrors = reportCardEngine.validateGradeBands(gradeBands);
  if (gradingSystem && bandErrors.length > 0) {
    return {
      created: [],
      unchanged: [],
      skipped: [],
      failed: [],
      configurationErrors: bandErrors,
      batchId,
    };
  }

  // class_report_entries is the Class Teacher's own worklist - it names
  // which learners are in scope and carries their comments/conduct/
  // attendance-verification, but owns none of the grading itself (see
  // ClassReportEntry's doc comment in class_report_entry.dart).
  let entriesQuery = school
    .collection("class_report_entries")
    .where("classId", "==", classId)
    .where("academicYearId", "==", academicYearId)
    .where("termId", "==", termId);
  const entriesSnap = await entriesQuery.get();

  const entries = entriesSnap.docs
    .map((d) => ({ id: d.id, ref: d.ref, ...d.data() }))
    .filter((e) => !Array.isArray(studentIds) || studentIds.length === 0 || studentIds.includes(e.studentId));

  if (entries.length === 0) {
    return { created: [], unchanged: [], skipped: [], failed: [], configurationErrors: [], batchId };
  }

  // Only assessments the Dean has actually approved (or published/locked
  // downstream of approval) contribute - draft/submitted/returned marks
  // must never leak into a generated report, whatever their score.
  let assessmentsQuery = school
    .collection("subject_assessments")
    .where("classId", "==", classId)
    .where("academicYearId", "==", academicYearId)
    .where("termId", "==", termId);
  if (streamId) {
    // Assessments are not always stream-scoped; a class-wide assessment
    // (no streamId on the doc) still applies to every stream in the class.
  }
  const assessmentsSnap = await assessmentsQuery.get();
  const approvedAssessments = assessmentsSnap.docs
    .map((d) => ({ id: d.id, ...d.data() }))
    .filter((a) => reportCardEngine.APPROVED_MARK_STATUSES.has(a.status) || a.status === "approved");
  const approvedAssessmentIds = new Set(approvedAssessments.map((a) => a.id));
  const componentBySubjectAssessment = new Map();
  for (const assessment of approvedAssessments) {
    const components = Array.isArray(assessment.components) && assessment.components.length > 0
      ? assessment.components
      : [{ id: assessment.id, name: assessment.title || "", maximumMark: assessment.maximumMark || 100, weight: 100 }];
    for (const component of components) {
      componentBySubjectAssessment.set(`${assessment.id}_${component.id}`, {
        subjectId: assessment.subjectId,
        componentName: component.name,
        maximumMark: component.maximumMark,
        weight: component.weight,
      });
    }
  }

  let marksQuery = school
    .collection("student_marks")
    .where("classId", "==", classId)
    .where("academicYearId", "==", academicYearId)
    .where("termId", "==", termId);
  const marksSnap = await marksQuery.get();

  // Grouped studentId -> subjectId -> [markRow], restricted to marks whose
  // markStatus is settled AND whose parent assessment was actually approved
  // - both gates matter: a mark can be locally 'approved' on a stale copy
  // of an assessment that was later returned, and the assessment id is the
  // one Dean-approval actually acts on.
  const marksByStudentSubject = new Map();
  for (const doc of marksSnap.docs) {
    const mark = doc.data();
    if (!reportCardEngine.APPROVED_MARK_STATUSES.has(mark.markStatus)) continue;
    if (!approvedAssessmentIds.has(mark.assessmentId)) continue;
    const componentMeta = componentBySubjectAssessment.get(`${mark.assessmentId}_${mark.componentId}`);
    if (!componentMeta) continue;

    const key = `${mark.studentId}::${componentMeta.subjectId}`;
    const row = {
      assessmentId: mark.assessmentId,
      componentId: mark.componentId,
      componentName: componentMeta.componentName,
      subjectId: componentMeta.subjectId,
      score: mark.score ?? null,
      entryStatus: mark.entryStatus || (typeof mark.score === "number" ? "scored" : "notEntered"),
      maximumMark: componentMeta.maximumMark,
      weight: componentMeta.weight,
      markStatus: mark.markStatus,
      updatedAtMillis: mark.updatedAt && mark.updatedAt.toMillis ? mark.updatedAt.toMillis() : null,
    };
    if (!marksByStudentSubject.has(key)) marksByStudentSubject.set(key, []);
    marksByStudentSubject.get(key).push(row);
  }

  // Every subject the class was actually assessed in this term (from
  // approved assessments), not just the subjects a given learner happens to
  // have a mark row for - a learner missing a subject entirely (e.g. never
  // entered at all, as opposed to entered-and-absent) must still show that
  // subject as incomplete, not have it silently vanish from their report.
  const classSubjectIds = new Set(approvedAssessments.map((a) => a.subjectId));

  // One aggregate per learner, so ranking can run across the whole class
  // before any document is written - position must never be computed one
  // learner at a time, or a later learner's write could invalidate an
  // earlier one's already-written position.
  const learnerAggregates = entries.map((entry) => {
    const subjects = [...classSubjectIds].sort().map((subjectId) => {
      const rows = marksByStudentSubject.get(`${entry.studentId}::${subjectId}`) || [];
      return reportCardEngine.aggregateSubject({ subjectId, rows, gradingSystem, gradeBands });
    });

    const completeSubjects = subjects.filter((s) => s.isComplete);
    const isEligibleForRanking = subjects.length > 0 && completeSubjects.length === subjects.length;
    const totalScore = completeSubjects.reduce((sum, s) => sum + (s.average || 0), 0);
    const overallAverage = completeSubjects.length > 0 ? totalScore / completeSubjects.length : null;
    const overallGrade = overallAverage === null
      ? null
      : reportCardEngine.resolveGrade({ score: overallAverage, gradingSystem, gradeBands });
    const aggregatePoints = completeSubjects.every((s) => s.gradePoint !== null && s.gradePoint !== undefined)
      && completeSubjects.length > 0
      ? completeSubjects.reduce((sum, s) => sum + s.gradePoint, 0)
      : null;

    const allMarkRows = [...marksByStudentSubject.entries()]
      .filter(([key]) => key.startsWith(`${entry.studentId}::`))
      .flatMap(([, rows]) => rows);

    return {
      entry,
      subjects,
      hasAnyMarks: allMarkRows.length > 0,
      isEligibleForRanking,
      overallAverage,
      overallTotal: totalScore,
      overallGrade: overallGrade ? overallGrade.gradeCode : null,
      overallGradeLabel: overallGrade ? overallGrade.gradeLabel : null,
      isOverallPassing: overallGrade ? overallGrade.isPassing : null,
      aggregatePoints,
      sourceHash: reportCardEngine.sourceHash({ markRows: allMarkRows, gradingSystem, gradeBands, classEntry: entry }),
    };
  });

  // Ranking is a school-configurable preference; without an explicit signal
  // that a school wants positions off, computing them is harmless (a report
  // template that doesn't render position simply doesn't show the field),
  // but only students with every subject complete are ranked at all - an
  // incomplete learner is not comparable to a complete one.
  const rankable = learnerAggregates.filter((a) => a.isEligibleForRanking && a.overallAverage !== null);
  const positions = reportCardEngine.rankByMetric(
    rankable.map((a) => ({ studentId: a.entry.studentId, metric: a.overallAverage }))
  );

  const created = [];
  const unchanged = [];
  const skipped = [];
  const failed = [];

  const chunks = [];
  for (let i = 0; i < learnerAggregates.length; i += 400) chunks.push(learnerAggregates.slice(i, i + 400));

  for (const chunk of chunks) {
    const batch = db.batch();
    let hasWrites = false;

    for (const aggregate of chunk) {
      const { entry } = aggregate;
      if (!aggregate.hasAnyMarks) {
        skipped.push({ studentId: entry.studentId, reason: "no_approved_marks" });
        continue;
      }

      const id = reportCardEngine.reportCardId({
        schoolId,
        studentId: entry.studentId,
        academicYearId,
        termId,
      });
      const ref = school.collection("reportCards").doc(id);
      // eslint-disable-next-line no-await-in-loop
      const existing = await ref.get();

      if (existing.exists) {
        const existingData = existing.data();
        if (existingData.isFinalized) {
          // A finalized report is immutable. A source change after
          // finalization is a correction, not a regeneration, and
          // corrections are out of scope for this phase - surface it as a
          // clear skip rather than silently doing nothing or throwing.
          skipped.push({ studentId: entry.studentId, reason: "already_finalized" });
          continue;
        }
        if (existingData.sourceHash === aggregate.sourceHash) {
          unchanged.push({ studentId: entry.studentId, reportCardId: id });
          continue;
        }
      }

      const position = positions.get(entry.studentId) ?? null;
      const snapshot = {
        schemaVersion: reportCardEngine.SCHEMA_VERSION,
        reportCardId: id,
        schoolId,
        studentId: entry.studentId,
        studentName: entry.studentName || "",
        academicYearId,
        termId,
        classId,
        streamId: entry.streamId ?? streamId ?? null,
        gradingSystemId: gradingSystem ? gradingSystem.id : null,
        gradingSystemVersion: gradingSystem ? gradingSystem.version : null,
        subjectResults: aggregate.subjects,
        totalScore: aggregate.overallTotal,
        average: aggregate.overallAverage,
        overallGrade: aggregate.overallGrade,
        overallGradeLabel: aggregate.overallGradeLabel,
        isOverallPassing: aggregate.isOverallPassing,
        aggregatePoints: aggregate.aggregatePoints,
        position,
        isRanked: position !== null,
        attendanceVerified: entry.attendanceVerified ?? false,
        overallConductCode: entry.overallConductCode ?? null,
        conduct: entry.conduct || [],
        classTeacherComment: entry.teacherComment ?? null,
        classTeacherUid: entry.updatedBy || (existing.exists ? existing.data().classTeacherUid ?? null : null),
        recommendations: entry.recommendations || [],
        // Academic approval workflow (Class Teacher review -> Dean sign ->
        // Headteacher sign -> academically finalized). A freshly generated
        // or regenerated (source changed) report always resets to
        // `generated`, since a change to the underlying marks means
        // whatever review happened on the prior version no longer applies.
        // Regenerating a report already past classTeacherReview is refused
        // elsewhere in the workflow functions themselves (submission
        // requires the current sourceHash), not here - generation's job is
        // only ever to produce a correct snapshot.
        academicStatus: reportCardEngine.ACADEMIC_STATUS.GENERATED,
        currentApprovalStage: "classTeacher",
        submittedBy: null,
        submittedAt: null,
        classTeacherReview: null,
        deanDecision: null,
        headteacherDecision: null,
        academicallyFinalizedAt: null,
        academicallyFinalizedBy: null,
        supersededByReportCardId: existing.exists ? (existing.data().supersededByReportCardId ?? null) : null,
        approvalHistory: existing.exists && !existing.data().isFinalized ? (existing.data().approvalHistory || []) : [],
        isFinalized: false,
        version: existing.exists ? (existing.data().version || 1) + 1 : 1,
        generationBatchId: batchId,
        sourceRecordIds: {
          classReportEntryId: entry.id,
          assessmentIds: [...new Set(aggregate.subjects.flatMap((s) => s.componentResults.map((c) => c.assessmentId)))],
        },
        sourceHash: aggregate.sourceHash,
        supersedesReportCardId: existing.exists ? (existing.data().supersedesReportCardId ?? null) : null,
        generatedBy: actorUid,
        generatedAt: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: existing.exists ? existing.data().createdAt : admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      batch.set(ref, snapshot, { merge: false });
      batch.update(entry.ref, {
        reportCardId: id,
        reportCardGenerationStatus: "generated",
        reportCardGeneratedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      hasWrites = true;
      created.push({ studentId: entry.studentId, reportCardId: id, version: snapshot.version });
    }

    if (hasWrites) {
      // eslint-disable-next-line no-await-in-loop
      await batch.commit();
    }
  }

  return { created, unchanged, skipped, failed, configurationErrors: [], batchId };
}

/**
 * Generates canonical report-card snapshots for a class - the Class
 * Teacher's "Compile" action (ClassReportsGenerated). Authorization allows
 * either the academic office or the Class Teacher who actually holds this
 * class, matching the two real callers; a client-supplied total or grade
 * never reaches the snapshot, since every number here is recomputed from
 * `student_marks` and the school's grading configuration.
 */
exports.generateClassReportCards = onCall(async (request) => {
  const { classId, streamId, academicYearId, termId, studentIds } = request.data || {};
  if (!classId || !academicYearId || !termId) {
    throw new HttpsError(
      "invalid-argument",
      "classId, academicYearId and termId are required."
    );
  }

  const caller = await requireClassReportGenerationAccess(request.auth, { classId, academicYearId });

  const result = await _generateClassReportCardsInternal({
    schoolId: caller.schoolId,
    classId,
    streamId: streamId || null,
    academicYearId,
    termId,
    studentIds,
    actorUid: caller.uid,
  });

  await writeAudit(caller.schoolId, {
    userId: caller.uid,
    action: "report_card.generated",
    entityType: "reportCards",
    entityId: classId,
    academicYearId,
    termId,
    classId,
    newValue: {
      created: result.created.length,
      unchanged: result.unchanged.length,
      skipped: result.skipped.length,
      failed: result.failed.length,
      batchId: result.batchId,
    },
  });

  return result;
});

// ---------------------------------------------------------------------------
// Academic approval workflow: Class Teacher review -> Dean signature ->
// Headteacher signature -> academic finalization. This is deliberately a
// separate concern from `publishClassReports` below, which is a *financial*
// publication step (releasing an already-finalized report to parents) and
// must never be confused with academic submission - see the module
// docstring in report_card_engine.js's ACADEMIC_STATUS section. Nothing in
// this block ever grants Parent/Student read access.
// ---------------------------------------------------------------------------

const DEAN_ROLES = ["deanOfStudies", "director", "schoolAdmin"];
const HEADTEACHER_ROLES = ["headTeacher", "director", "schoolAdmin"];

/** Loads the caller's profile/roles and confirms they belong to a school. */
async function loadCallerProfile(auth) {
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
  const db = admin.firestore();
  const callerDoc = await db.collection("users").doc(auth.uid).get();
  const caller = callerDoc.exists ? callerDoc.data() : {};
  const roles = Array.isArray(caller.roles) ? caller.roles : [caller.role].filter(Boolean);
  if (!caller.schoolId) {
    throw new HttpsError("failed-precondition", "Your account is not assigned to a school.");
  }
  return {
    uid: auth.uid,
    schoolId: caller.schoolId,
    roles,
    displayName: caller.name || caller.displayName || "Staff member",
  };
}

/** Refuses unless the caller holds one of the given roles. */
function requireAnyRole(caller, roles, message) {
  if (!roles.some((role) => caller.roles.includes(role))) {
    throw new HttpsError("permission-denied", message);
  }
}

/**
 * Loads a reportCards doc, confirms it belongs to the caller's school (a
 * document ID never crosses tenants, but a caller cannot be trusted to have
 * supplied the right schoolId either), and returns both the ref and data.
 */
async function loadReportCardForSchool(schoolId, reportCardId) {
  const ref = admin
    .firestore()
    .collection("schools")
    .doc(schoolId)
    .collection("reportCards")
    .doc(reportCardId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", `Report card ${reportCardId} was not found.`);
  }
  const data = snap.data();
  if (data.schoolId !== schoolId) {
    // Cannot happen via the nested path itself, but defends against a
    // caller-supplied schoolId that simply does not match the document -
    // fail closed rather than trust the mismatch away.
    throw new HttpsError("permission-denied", "This report does not belong to your school.");
  }
  return { ref, data };
}

/**
 * Enqueues a real in-app/push notification via the existing
 * notification_requests -> processNotificationRequest -> notifications
 * fan-out (see functions/notifications.js). Never writes to `notifications`
 * directly - that would skip recipient resolution, push delivery and the
 * channel/email/SMS copies the trigger already centralizes.
 *
 * idempotencyKey is deliberately based on (reportCardId, action, version) so
 * a retried callable invocation (e.g. a client double-tap that reached the
 * server twice) enqueues the same key twice; downstream dedup is the
 * trigger's concern via idempotencyKey the same way appointments.js already
 * relies on it, not this helper's.
 */
async function enqueueReportCardNotification({
  schoolId, recipientUid, recipientRoles, type, title, shortBody, reportCardId, action, reportVersion,
}) {
  const audience = recipientUid
    ? { kind: "users", userIds: [recipientUid] }
    : recipientRoles && recipientRoles.length > 0
      ? { kind: "roles", roles: recipientRoles }
      : null;
  if (!audience) return;
  await admin.firestore().collection("notification_requests").add({
    schoolId,
    category: "academics",
    type,
    title,
    shortBody,
    priority: "medium",
    senderNameSnapshot: "School Pulse",
    senderRoleSnapshot: "Report Card Engine",
    senderKind: "automated",
    sourceModule: "reportCards",
    // The app's deep-link router keys off sourceEntityId for reportCard
    // destinations - set it so a parent "now available" notification opens
    // the report screen (the router re-checks access server-side anyway).
    ...(reportCardId ? { sourceEntityId: reportCardId } : {}),
    audience,
    status: "pending",
    idempotencyKey: `report_card_${action}_${reportCardId}_v${reportVersion}`,
    metadata: { reportCardId, action, reportVersion },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Applies one workflow transition inside a Firestore transaction, so two
 * concurrent calls (e.g. a double-tap, or the Dean and an admin acting at
 * the same instant) can never both succeed against the same version. Reads
 * the current document state itself rather than trusting a snapshot the
 * caller already read outside the transaction - that snapshot could be
 * stale by the time this runs.
 *
 * `decide` receives the freshly-read data and must return either
 * `{ ok: true, updates, historyEntry, notification }` or
 * `{ ok: false, httpsError }`. Returning `ok:false` inside the transaction
 * still throws (transactions abort on thrown errors), but structuring it
 * this way keeps every validation message in one place per caller.
 */
async function runWorkflowTransition({ schoolId, reportCardId, decide }) {
  const db = admin.firestore();
  const ref = db.collection("schools").doc(schoolId).collection("reportCards").doc(reportCardId);

  let notification = null;
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) {
      throw new HttpsError("not-found", `Report card ${reportCardId} was not found.`);
    }
    const data = snap.data();
    if (data.schoolId !== schoolId) {
      throw new HttpsError("permission-denied", "This report does not belong to your school.");
    }

    const outcome = decide(data);
    if (!outcome.ok) {
      throw outcome.httpsError;
    }

    const history = Array.isArray(data.approvalHistory) ? data.approvalHistory : [];
    if (outcome.historyEntry && isDuplicateDecisionCheck(history, outcome.historyEntry)) {
      // Idempotent no-op: the exact same actor+action+version was already
      // recorded (a retried call). Nothing to write, and the caller below
      // treats this as success without a second notification.
      notification = null;
      return;
    }

    tx.update(ref, {
      ...outcome.updates,
      approvalHistory: outcome.historyEntry
        ? admin.firestore.FieldValue.arrayUnion(outcome.historyEntry)
        : admin.firestore.FieldValue.arrayUnion(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    notification = outcome.notification || null;
  });

  if (notification) {
    await enqueueReportCardNotification(notification);
  }
}

function isDuplicateDecisionCheck(history, candidateEntry) {
  if (history.length === 0) return false;
  const last = history[history.length - 1];
  return (
    last.action === candidateEntry.action &&
    last.actorUid === candidateEntry.actorUid &&
    last.reportVersion === candidateEntry.reportVersion
  );
}

/**
 * Class Teacher review -> submit to Dean, one or many report cards.
 *
 * Before each report moves, re-validates against live data rather than
 * trusting the client's copy: a stale sourceHash (marks changed underneath
 * the teacher after they opened the preview) or a report that has drifted
 * out of the expected status is rejected for that report specifically, not
 * the whole batch.
 */
exports.submitReportCardsToDean = onCall(async (request) => {
  const caller = await loadCallerProfile(request.auth);
  const { reportCardIds } = request.data || {};
  if (!Array.isArray(reportCardIds) || reportCardIds.length === 0) {
    throw new HttpsError("invalid-argument", "reportCardIds must be a non-empty array.");
  }

  const submitted = [];
  const skipped = [];
  const failed = [];

  for (const reportCardId of reportCardIds) {
    try {
      // eslint-disable-next-line no-await-in-loop
      await runWorkflowTransition({
        schoolId: caller.schoolId,
        reportCardId,
        decide: (data) => {
          const fromStatus = data.academicStatus === reportCardEngine.ACADEMIC_STATUS.GENERATED
            || data.academicStatus === reportCardEngine.ACADEMIC_STATUS.RETURNED_BY_DEAN
            || data.academicStatus === reportCardEngine.ACADEMIC_STATUS.RETURNED_BY_HEADTEACHER
            ? reportCardEngine.ACADEMIC_STATUS.CLASS_TEACHER_REVIEW
            : data.academicStatus;

          if (data.isFinalized || data.academicStatus === reportCardEngine.ACADEMIC_STATUS.SUPERSEDED) {
            return { ok: false, httpsError: new HttpsError("failed-precondition", "This report is finalized or superseded.") };
          }
          if (!reportCardEngine.isValidTransition(fromStatus, reportCardEngine.ACADEMIC_STATUS.SUBMITTED_TO_DEAN)) {
            return { ok: false, httpsError: new HttpsError("failed-precondition", `Cannot submit a report in status "${data.academicStatus}".`) };
          }

          const historyEntry = reportCardEngine.buildApprovalHistoryEntry({
            action: "classTeacher.submittedToDean",
            actorUid: caller.uid,
            actorRole: "classTeacher",
            actorDisplayName: caller.displayName,
            reportVersion: data.version,
            sourceHashReviewed: data.sourceHash,
            schoolId: caller.schoolId,
            serverTimestamp: new Date().toISOString(),
          });

          return {
            ok: true,
            updates: {
              academicStatus: reportCardEngine.ACADEMIC_STATUS.SUBMITTED_TO_DEAN,
              currentApprovalStage: "dean",
              submittedBy: caller.uid,
              submittedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            historyEntry,
            notification: {
              schoolId: caller.schoolId,
              recipientRoles: DEAN_ROLES,
              type: "report_card_awaiting_dean_signature",
              title: "A report card is awaiting your signature",
              shortBody: `${data.studentName || "A learner"}'s report card was submitted for your review.`,
              reportCardId,
              action: "submittedToDean",
              reportVersion: data.version,
            },
          };
        },
      });
      submitted.push(reportCardId);
    } catch (err) {
      failed.push({ reportCardId, reason: err.message || "unknown_error" });
    }
  }

  await writeAudit(caller.schoolId, {
    userId: caller.uid,
    action: "report_card.submitted_to_dean",
    entityType: "reportCards",
    entityId: reportCardIds.join(","),
    newValue: { submitted: submitted.length, skipped: skipped.length, failed: failed.length },
  });

  return { submitted, skipped, failed };
});

/** The Dean returns one report to the Class Teacher, with a mandatory reason. */
exports.returnReportCardByDean = onCall(async (request) => {
  const caller = await loadCallerProfile(request.auth);
  requireAnyRole(caller, DEAN_ROLES, "Only the Dean of Studies may return a report at this stage.");

  const { reportCardId, reason } = request.data || {};
  if (!reportCardId || !reason || !reason.trim()) {
    throw new HttpsError("invalid-argument", "reportCardId and a non-empty reason are required.");
  }

  let studentName = "";
  let classTeacherUid = null;
  await runWorkflowTransition({
    schoolId: caller.schoolId,
    reportCardId,
    decide: (data) => {
      studentName = data.studentName || "";
      classTeacherUid = data.classTeacherUid || null;
      if (!reportCardEngine.isValidTransition(data.academicStatus, reportCardEngine.ACADEMIC_STATUS.RETURNED_BY_DEAN)) {
        return { ok: false, httpsError: new HttpsError("failed-precondition", `Cannot return a report in status "${data.academicStatus}".`) };
      }
      const historyEntry = reportCardEngine.buildApprovalHistoryEntry({
        action: "dean.returned",
        actorUid: caller.uid,
        actorRole: "deanOfStudies",
        actorDisplayName: caller.displayName,
        reason: reason.trim(),
        reportVersion: data.version,
        sourceHashReviewed: data.sourceHash,
        schoolId: caller.schoolId,
        serverTimestamp: new Date().toISOString(),
      });
      return {
        ok: true,
        updates: {
          academicStatus: reportCardEngine.ACADEMIC_STATUS.RETURNED_BY_DEAN,
          currentApprovalStage: "classTeacher",
          deanDecision: { decision: "returned", reason: reason.trim(), actorUid: caller.uid, actorDisplayName: caller.displayName, reportVersion: data.version, decidedAt: admin.firestore.FieldValue.serverTimestamp() },
        },
        historyEntry,
        notification: classTeacherUid
          ? {
              schoolId: caller.schoolId,
              recipientUid: classTeacherUid,
              type: "report_card_returned_by_dean",
              title: "A report card was returned to you",
              shortBody: `The Dean returned ${studentName || "a learner"}'s report card: ${reason.trim()}`,
              reportCardId,
              action: "returnedByDean",
              reportVersion: data.version,
            }
          : null,
      };
    },
  });

  await writeAudit(caller.schoolId, {
    userId: caller.uid, action: "report_card.returned_by_dean", entityType: "reportCards", entityId: reportCardId, newValue: { reason },
  });

  return { reportCardId, status: reportCardEngine.ACADEMIC_STATUS.RETURNED_BY_DEAN };
});

/**
 * The Dean signs one report. Verifies the report is complete, in the right
 * stage, and that its version/sourceHash match what the Dean's client last
 * fetched - a change to the underlying marks between the Dean opening the
 * preview and pressing "Sign" must not be silently approved.
 */
exports.signReportCardAsDean = onCall(async (request) => {
  const caller = await loadCallerProfile(request.auth);
  requireAnyRole(caller, DEAN_ROLES, "Only the Dean of Studies may sign at this stage.");

  const { reportCardId, expectedVersion, expectedSourceHash } = request.data || {};
  if (!reportCardId) {
    throw new HttpsError("invalid-argument", "reportCardId is required.");
  }

  await runWorkflowTransition({
    schoolId: caller.schoolId,
    reportCardId,
    decide: (data) => {
      if (!reportCardEngine.isValidTransition(data.academicStatus, reportCardEngine.ACADEMIC_STATUS.DEAN_SIGNED)) {
        return { ok: false, httpsError: new HttpsError("failed-precondition", `Cannot sign a report in status "${data.academicStatus}".`) };
      }
      if (expectedVersion != null && expectedVersion !== data.version) {
        return { ok: false, httpsError: new HttpsError("failed-precondition", "This report changed since you reviewed it. Please re-open it before signing.") };
      }
      if (expectedSourceHash != null && expectedSourceHash !== data.sourceHash) {
        return { ok: false, httpsError: new HttpsError("failed-precondition", "The underlying marks changed since you reviewed this report. Please re-open it before signing.") };
      }
      if (!data.subjectResults || data.subjectResults.length === 0) {
        return { ok: false, httpsError: new HttpsError("failed-precondition", "This report has no subject results and cannot be signed.") };
      }

      const historyEntry = reportCardEngine.buildApprovalHistoryEntry({
        action: "dean.signed",
        actorUid: caller.uid,
        actorRole: "deanOfStudies",
        actorDisplayName: caller.displayName,
        reportVersion: data.version,
        sourceHashReviewed: data.sourceHash,
        schoolId: caller.schoolId,
        serverTimestamp: new Date().toISOString(),
        signatureRef: { signedBy: caller.uid, signedByName: caller.displayName, signedByRole: "deanOfStudies" },
      });

      return {
        ok: true,
        updates: {
          academicStatus: reportCardEngine.ACADEMIC_STATUS.DEAN_SIGNED,
          currentApprovalStage: "deanSigned",
          deanDecision: {
            decision: "signed", actorUid: caller.uid, actorDisplayName: caller.displayName,
            reportVersion: data.version, sourceHashReviewed: data.sourceHash,
            decidedAt: admin.firestore.FieldValue.serverTimestamp(),
            signatureRef: { signedBy: caller.uid, signedByName: caller.displayName, signedByRole: "deanOfStudies" },
          },
        },
        historyEntry,
        notification: null, // forwarding notification fires from submitReportCardsToHeadteacher
      };
    },
  });

  await writeAudit(caller.schoolId, {
    userId: caller.uid, action: "report_card.signed_by_dean", entityType: "reportCards", entityId: reportCardId, newValue: {},
  });

  return { reportCardId, status: reportCardEngine.ACADEMIC_STATUS.DEAN_SIGNED };
});

/** Forwards Dean-signed reports to the Headteacher queue. */
exports.submitReportCardsToHeadteacher = onCall(async (request) => {
  const caller = await loadCallerProfile(request.auth);
  requireAnyRole(caller, DEAN_ROLES, "Only the Dean of Studies may forward a report to the Headteacher.");

  const { reportCardIds } = request.data || {};
  if (!Array.isArray(reportCardIds) || reportCardIds.length === 0) {
    throw new HttpsError("invalid-argument", "reportCardIds must be a non-empty array.");
  }

  const submitted = [];
  const failed = [];

  for (const reportCardId of reportCardIds) {
    try {
      // eslint-disable-next-line no-await-in-loop
      await runWorkflowTransition({
        schoolId: caller.schoolId,
        reportCardId,
        decide: (data) => {
          if (!reportCardEngine.isValidTransition(data.academicStatus, reportCardEngine.ACADEMIC_STATUS.SUBMITTED_TO_HEADTEACHER)) {
            return { ok: false, httpsError: new HttpsError("failed-precondition", `Cannot forward a report in status "${data.academicStatus}".`) };
          }
          const historyEntry = reportCardEngine.buildApprovalHistoryEntry({
            action: "dean.forwardedToHeadteacher",
            actorUid: caller.uid,
            actorRole: "deanOfStudies",
            actorDisplayName: caller.displayName,
            reportVersion: data.version,
            sourceHashReviewed: data.sourceHash,
            schoolId: caller.schoolId,
            serverTimestamp: new Date().toISOString(),
          });
          return {
            ok: true,
            updates: { academicStatus: reportCardEngine.ACADEMIC_STATUS.SUBMITTED_TO_HEADTEACHER, currentApprovalStage: "headteacher" },
            historyEntry,
            notification: {
              schoolId: caller.schoolId,
              recipientRoles: HEADTEACHER_ROLES,
              type: "report_card_awaiting_headteacher_signature",
              title: "A report card is awaiting your signature",
              shortBody: `${data.studentName || "A learner"}'s report card was signed by the Dean and needs your review.`,
              reportCardId,
              action: "submittedToHeadteacher",
              reportVersion: data.version,
            },
          };
        },
      });
      submitted.push(reportCardId);
    } catch (err) {
      failed.push({ reportCardId, reason: err.message || "unknown_error" });
    }
  }

  await writeAudit(caller.schoolId, {
    userId: caller.uid, action: "report_card.submitted_to_headteacher", entityType: "reportCards",
    entityId: reportCardIds.join(","), newValue: { submitted: submitted.length, failed: failed.length },
  });

  return { submitted, failed };
});

/** The Headteacher returns one report, with a mandatory reason. */
exports.returnReportCardByHeadteacher = onCall(async (request) => {
  const caller = await loadCallerProfile(request.auth);
  requireAnyRole(caller, HEADTEACHER_ROLES, "Only the Headteacher may return a report at this stage.");

  const { reportCardId, reason, academicContentChanged } = request.data || {};
  if (!reportCardId || !reason || !reason.trim()) {
    throw new HttpsError("invalid-argument", "reportCardId and a non-empty reason are required.");
  }

  let classTeacherUid = null;
  let deanUid = null;
  let studentName = "";
  let targetStatus = null;

  await runWorkflowTransition({
    schoolId: caller.schoolId,
    reportCardId,
    decide: (data) => {
      classTeacherUid = data.classTeacherUid || null;
      deanUid = data.deanDecision && data.deanDecision.actorUid ? data.deanDecision.actorUid : null;
      studentName = data.studentName || "";

      // Default safely: any ambiguity about what changed is treated as an
      // academic-content change, sending the report all the way back to
      // the Class Teacher rather than assuming the Dean's signature can
      // still stand.
      targetStatus = reportCardEngine.resolveHeadteacherReturnTarget({
        academicContentChanged: academicContentChanged !== false,
      });

      if (!reportCardEngine.isValidTransition(data.academicStatus, reportCardEngine.ACADEMIC_STATUS.RETURNED_BY_HEADTEACHER)) {
        return { ok: false, httpsError: new HttpsError("failed-precondition", `Cannot return a report in status "${data.academicStatus}".`) };
      }

      const historyEntry = reportCardEngine.buildApprovalHistoryEntry({
        action: "headteacher.returned",
        actorUid: caller.uid,
        actorRole: "headTeacher",
        actorDisplayName: caller.displayName,
        reason: reason.trim(),
        reportVersion: data.version,
        sourceHashReviewed: data.sourceHash,
        schoolId: caller.schoolId,
        serverTimestamp: new Date().toISOString(),
      });

      const updates = {
        academicStatus: targetStatus,
        currentApprovalStage: targetStatus === reportCardEngine.ACADEMIC_STATUS.CLASS_TEACHER_REVIEW ? "classTeacher" : "dean",
        headteacherDecision: {
          decision: "returned", reason: reason.trim(), actorUid: caller.uid, actorDisplayName: caller.displayName,
          reportVersion: data.version, decidedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      };

      // A Headteacher return that sends the report back past the Dean
      // invalidates the Dean's prior signature - it no longer speaks for
      // this version of the content, and re-review is mandatory.
      if (targetStatus === reportCardEngine.ACADEMIC_STATUS.CLASS_TEACHER_REVIEW) {
        updates.deanDecision = null;
      }

      return {
        ok: true,
        updates,
        historyEntry,
        notification: (targetStatus === reportCardEngine.ACADEMIC_STATUS.CLASS_TEACHER_REVIEW ? classTeacherUid : deanUid)
          ? {
              schoolId: caller.schoolId,
              recipientUid: targetStatus === reportCardEngine.ACADEMIC_STATUS.CLASS_TEACHER_REVIEW ? classTeacherUid : deanUid,
              type: "report_card_returned_by_headteacher",
              title: "A report card was returned to you",
              shortBody: `The Headteacher returned ${studentName || "a learner"}'s report card: ${reason.trim()}`,
              reportCardId,
              action: "returnedByHeadteacher",
              reportVersion: data.version,
            }
          : null,
      };
    },
  });

  await writeAudit(caller.schoolId, {
    userId: caller.uid, action: "report_card.returned_by_headteacher", entityType: "reportCards", entityId: reportCardId, newValue: { reason, targetStatus },
  });

  return { reportCardId, status: targetStatus };
});

/**
 * The Headteacher signs and academically finalizes a report - the terminal
 * academic action in this phase. Requires a live Dean signature for the
 * exact same version/sourceHash; a Dean signature from an earlier version
 * (invalidated by a Headteacher return, or superseded by a correction) does
 * not carry forward.
 */
exports.signReportCardAsHeadteacher = onCall(async (request) => {
  const caller = await loadCallerProfile(request.auth);
  requireAnyRole(caller, HEADTEACHER_ROLES, "Only the Headteacher may sign at this stage.");

  const { reportCardId, expectedVersion, expectedSourceHash } = request.data || {};
  if (!reportCardId) {
    throw new HttpsError("invalid-argument", "reportCardId is required.");
  }

  let finalizedReportContext = null;

  await runWorkflowTransition({
    schoolId: caller.schoolId,
    reportCardId,
    decide: (data) => {
      finalizedReportContext = {
        studentId: data.studentId,
        academicYearId: data.academicYearId,
        termId: data.termId,
      };
      if (!reportCardEngine.isValidTransition(data.academicStatus, reportCardEngine.ACADEMIC_STATUS.ACADEMICALLY_FINALIZED)) {
        return { ok: false, httpsError: new HttpsError("failed-precondition", `Cannot finalize a report in status "${data.academicStatus}".`) };
      }
      if (!data.deanDecision || data.deanDecision.decision !== "signed") {
        return { ok: false, httpsError: new HttpsError("failed-precondition", "This report has no live Dean signature.") };
      }
      if (data.deanDecision.reportVersion !== data.version) {
        return { ok: false, httpsError: new HttpsError("failed-precondition", "The Dean's signature is for an earlier version of this report.") };
      }
      if (expectedVersion != null && expectedVersion !== data.version) {
        return { ok: false, httpsError: new HttpsError("failed-precondition", "This report changed since you reviewed it. Please re-open it before signing.") };
      }
      if (expectedSourceHash != null && expectedSourceHash !== data.sourceHash) {
        return { ok: false, httpsError: new HttpsError("failed-precondition", "The underlying marks changed since you reviewed this report. Please re-open it before signing.") };
      }

      const historyEntry = reportCardEngine.buildApprovalHistoryEntry({
        action: "headteacher.signed",
        actorUid: caller.uid,
        actorRole: "headTeacher",
        actorDisplayName: caller.displayName,
        reportVersion: data.version,
        sourceHashReviewed: data.sourceHash,
        schoolId: caller.schoolId,
        serverTimestamp: new Date().toISOString(),
        signatureRef: { signedBy: caller.uid, signedByName: caller.displayName, signedByRole: "headTeacher" },
      });

      return {
        ok: true,
        updates: {
          academicStatus: reportCardEngine.ACADEMIC_STATUS.ACADEMICALLY_FINALIZED,
          currentApprovalStage: "finalized",
          isFinalized: true,
          // A brand-new finalized report always starts under the automatic
          // fee-payment gate (never a Bursar decision yet) - whether it opens
          // released or held is decided right after this transaction commits,
          // in the recheckFn passed to runWorkflowTransition below.
          financialAccessStatus: "held",
          financialAccessSource: "auto",
          headteacherDecision: {
            decision: "signed", actorUid: caller.uid, actorDisplayName: caller.displayName,
            reportVersion: data.version, sourceHashReviewed: data.sourceHash,
            decidedAt: admin.firestore.FieldValue.serverTimestamp(),
            signatureRef: { signedBy: caller.uid, signedByName: caller.displayName, signedByRole: "headTeacher" },
          },
          academicallyFinalizedAt: admin.firestore.FieldValue.serverTimestamp(),
          academicallyFinalizedBy: caller.uid,
        },
        historyEntry,
        notification: data.classTeacherUid
          ? {
              schoolId: caller.schoolId,
              recipientUid: data.classTeacherUid,
              type: "report_card_academically_finalized",
              title: "A report card was finalized",
              shortBody: `${data.studentName || "A learner"}'s report card has been academically finalized.`,
              reportCardId,
              action: "academicallyFinalized",
              reportVersion: data.version,
            }
          : null,
      };
    },
  });

  if (finalizedReportContext) {
    // Decides whether this just-finalized report opens released or held,
    // based on the term's current fee balance - see
    // maybeAutoUpdateReportCardFinancialAccess's doc comment. Best-effort:
    // a failure here must not undo the finalization itself, since a Bursar
    // can always release the report manually if the automatic check fails.
    await maybeAutoUpdateReportCardFinancialAccess({
      schoolId: caller.schoolId,
      ...finalizedReportContext,
    }).catch((err) => {
      console.error("maybeAutoUpdateReportCardFinancialAccess failed after finalization", err);
    });

    // If the report was published but the learner is not financially cleared
    // (and no active exception released it), let the Bursar know - they may
    // want to grant a release exception. Best-effort; never fails finalize.
    try {
      const rcSnap = await admin
        .firestore()
        .doc(`schools/${caller.schoolId}/reportCards/${reportCardId}`)
        .get();
      if (rcSnap.exists && rcSnap.data().financialAccessStatus !== "released") {
        await enqueueReportCardNotification({
          schoolId: caller.schoolId,
          recipientRoles: ["bursar", "director", "schoolAdmin"],
          type: "report_card.published_not_cleared",
          title: "Report published — learner not financially cleared",
          shortBody: `${rcSnap.data().studentName || "A learner"}'s report card is finalized but withheld pending financial clearance.`,
          reportCardId,
          action: "published_not_cleared",
          reportVersion: rcSnap.data().version,
        });
      }
    } catch (err) {
      console.error("published_not_cleared Bursar notify failed", err);
    }
  }

  await writeAudit(caller.schoolId, {
    userId: caller.uid, action: "report_card.academically_finalized", entityType: "reportCards", entityId: reportCardId, newValue: {},
  });

  return { reportCardId, status: reportCardEngine.ACADEMIC_STATUS.ACADEMICALLY_FINALIZED };
});

// ---------------------------------------------------------------------------
// Report Card PDF + QR verification, and Bursar-controlled financial access.
// ---------------------------------------------------------------------------

const VERIFICATION_ORIGIN = "https://schoolpulseapp.com/verify-report";
const BURSAR_ROLES = ["bursar", "director", "schoolAdmin"];

function reportCardVerificationUrl(token) {
  return `${VERIFICATION_ORIGIN}?token=${encodeURIComponent(token)}`;
}

/**
 * Loads the institution's branding fields for the PDF header. Falls back to
 * empty strings rather than throwing - a school that hasn't finished
 * configuring its profile must still be able to generate a report.
 */
async function loadInstitutionBranding(schoolId) {
  const doc = await admin
    .firestore()
    .collection("schools")
    .doc(schoolId)
    .collection("config")
    .doc("institution_profile")
    .get();
  const data = doc.exists ? doc.data() : {};
  const contactParts = [data.phone, data.email].filter(Boolean);
  return {
    schoolName: data.name || data.displayName || "",
    schoolAddress: [data.address, data.city, data.district].filter(Boolean).join(", "),
    schoolContacts: contactParts.join(" · "),
    schoolLogoUrl: data.logoUrl || null,
  };
}

/**
 * Renders and previews a report card as a PDF without persisting anything
 * official. Available to any authorized staff (Class Teacher of that class,
 * Dean, Headteacher, or academic admin) at any workflow stage, always
 * carrying the DRAFT/AWAITING-SIGNATURES watermark until the report is
 * academically finalized - a client can never be shown a fake "official"
 * PDF before the real signatures exist.
 */
exports.previewReportCardPdf = onCall(async (request) => {
  const caller = await loadCallerProfile(request.auth);
  const { reportCardId } = request.data || {};
  if (!reportCardId) {
    throw new HttpsError("invalid-argument", "reportCardId is required.");
  }

  const { data } = await loadReportCardForSchool(caller.schoolId, reportCardId);

  const isAcademicStaff = caller.roles.some((role) =>
    [...DEAN_ROLES, ...HEADTEACHER_ROLES, "classTeacher", "subjectTeacher"].includes(role)
  );
  if (!isAcademicStaff) {
    throw new HttpsError("permission-denied", "You do not have permission to preview this report.");
  }

  const branding = await loadInstitutionBranding(caller.schoolId);
  const pdf = await renderReportCardPdf({
    ...data,
    ...branding,
    isDraftPreview: !data.isFinalized,
    verificationUrl: data.verificationCode
      ? reportCardVerificationUrl(data.verificationCode)
      : reportCardVerificationUrl("preview-not-yet-issued"),
  });

  return { base64Pdf: pdf.toString("base64") };
});

/**
 * Issues the official, immutable PDF for an academically finalized report.
 * Idempotent: retrying after the PDF already exists returns the existing
 * pdfUrl/verificationCode rather than re-rendering - a finalized report's
 * official PDF is never regenerated in place. A correction must go through
 * the (separate, not-yet-built) new-version workflow, which would carry its
 * own reportCardId and therefore its own PDF.
 */
exports.generateReportCardPdf = onCall(async (request) => {
  const caller = await loadCallerProfile(request.auth);
  const { reportCardId } = request.data || {};
  if (!reportCardId) {
    throw new HttpsError("invalid-argument", "reportCardId is required.");
  }

  const isAcademicStaff = caller.roles.some((role) =>
    [...DEAN_ROLES, ...HEADTEACHER_ROLES, "classTeacher"].includes(role)
  );
  if (!isAcademicStaff) {
    throw new HttpsError("permission-denied", "You do not have permission to generate this report's PDF.");
  }

  const db = admin.firestore();
  const ref = db.collection("schools").doc(caller.schoolId).collection("reportCards").doc(reportCardId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Report card not found.");
  const data = snap.data();
  if (data.schoolId !== caller.schoolId) {
    throw new HttpsError("permission-denied", "This report does not belong to your school.");
  }
  if (!data.isFinalized) {
    throw new HttpsError("failed-precondition", "Only an academically finalized report can have an official PDF.");
  }

  // Already issued for this exact version - never regenerate over it.
  if (data.pdfUrl && data.pdfGeneratedVersion === data.version) {
    return { pdfUrl: data.pdfUrl, verificationCode: data.verificationCode };
  }

  const verificationCode = data.verificationCode || randomBytes(18).toString("base64url");
  const branding = await loadInstitutionBranding(caller.schoolId);
  const verificationUrl = reportCardVerificationUrl(verificationCode);
  const pdf = await renderReportCardPdf({ ...data, ...branding, isDraftPreview: false, verificationUrl });

  const storagePath = `schools/${caller.schoolId}/reportCards/${reportCardId}/${data.version}.pdf`;
  await admin.storage().bucket().file(storagePath).save(pdf, {
    resumable: false,
    contentType: "application/pdf",
    metadata: { cacheControl: "private, max-age=0" },
  });
  const checksum = createHash("sha256").update(pdf).digest("hex");

  // The verification lookup doc - public get() only via the verifyReportCard
  // HTTP endpoint (Admin SDK; not subject to firestore.rules at all), and
  // firestore.rules itself still denies list() and any client write on this
  // subcollection - carries only safe fields, never marks/comments/fee data.
  // `verificationCode` is stored as a field (in addition to being the doc
  // id) purely so the endpoint can resolve it via a collectionGroup query
  // without knowing which school the token belongs to in advance.
  await db
    .collection("schools")
    .doc(caller.schoolId)
    .collection("reportVerifications")
    .doc(verificationCode)
    .set({
      verificationCode,
      schoolId: caller.schoolId,
      schoolNameSnapshot: branding.schoolName,
      reportCardId,
      studentDisplayName: (data.studentName || "").split(" ")[0] || "Student",
      academicYearId: data.academicYearId,
      termId: data.termId,
      version: data.version,
      isFinalized: true,
      isCurrent: true,
      checksum,
      issuedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

  await ref.update({
    pdfUrl: storagePath,
    pdfGeneratedAt: admin.firestore.FieldValue.serverTimestamp(),
    pdfGeneratedVersion: data.version,
    pdfChecksum: checksum,
    verificationCode,
  });

  await writeAudit(caller.schoolId, {
    userId: caller.uid,
    action: "report_card.pdf_generated",
    entityType: "reportCards",
    entityId: reportCardId,
    newValue: { version: data.version, verificationCode },
  });

  return { pdfUrl: storagePath, verificationCode };
});

/**
 * Returns a short-lived signed download URL for an already-generated
 * official PDF. Never streams the PDF through Storage rules directly (the
 * bucket path has no client-readable rule at all - see storage.rules) so
 * every download is gated by this function's own authorization check,
 * mirroring the same permission model as the report itself.
 */
exports.getReportCardPdfDownloadUrl = onCall(async (request) => {
  const caller = await loadCallerProfile(request.auth);
  const { reportCardId } = request.data || {};
  if (!reportCardId) {
    throw new HttpsError("invalid-argument", "reportCardId is required.");
  }

  const { data } = await loadReportCardForSchool(caller.schoolId, reportCardId);
  if (!data.pdfUrl) {
    throw new HttpsError("failed-precondition", "This report's official PDF has not been generated yet.");
  }

  const isAcademicStaff = caller.roles.some((role) =>
    [...DEAN_ROLES, ...HEADTEACHER_ROLES, "classTeacher", "subjectTeacher"].includes(role)
  );

  if (!isAcademicStaff) {
    // Parent/Student path: require linked-student + released financial access.
    if (!caller.roles.includes("parent") && !caller.roles.includes("student")) {
      throw new HttpsError("permission-denied", "You do not have permission to download this report.");
    }
    if (data.financialAccessStatus !== "released") {
      throw new HttpsError(
        "permission-denied",
        "Report not yet released. Please contact the school bursar's office for assistance."
      );
    }
    const linked = await isUserLinkedToStudent(caller.uid, data.studentId, caller.schoolId);
    if (!linked) {
      throw new HttpsError("permission-denied", "You are not linked to this learner.");
    }
  }

  const [url] = await admin
    .storage()
    .bucket()
    .file(data.pdfUrl)
    .getSignedUrl({ action: "read", expires: Date.now() + 5 * 60 * 1000 });

  return { url, expiresInSeconds: 300 };
});

/** Confirms the authenticated caller (parent or student) is actually linked to this student, in this school. */
async function isUserLinkedToStudent(uid, studentId, schoolId) {
  const userDoc = await admin.firestore().collection("users").doc(uid).get();
  const user = userDoc.exists ? userDoc.data() : {};
  if (user.schoolId !== schoolId) return false;
  if (Array.isArray(user.studentIds) && user.studentIds.includes(studentId)) return true;
  // Student's own account: their uid resolves to their own studentId via a
  // linked field on the user doc (the same convention student-login uses
  // elsewhere in this codebase).
  if (user.studentId === studentId) return true;
  return false;
}

/**
 * Bursar-controlled financial access. Held/Released/Revoked is entirely
 * separate from academicStatus - this function never touches marks, grades,
 * comments, signatures or any academic field, only financialAccessStatus and
 * its own audit trail. Requires a reason for every action, individual or
 * bulk, and only ever acts on academically finalized reports.
 */
exports.setReportCardFinancialAccess = onCall(async (request) => {
  const caller = await loadCallerProfile(request.auth);
  requireAnyRole(caller, BURSAR_ROLES, "Only the Bursar may control report release.");

  const { reportCardIds, action, reason } = request.data || {};
  if (!Array.isArray(reportCardIds) || reportCardIds.length === 0) {
    throw new HttpsError("invalid-argument", "reportCardIds must be a non-empty array.");
  }
  if (!["release", "hold", "revoke"].includes(action)) {
    throw new HttpsError("invalid-argument", "action must be one of release, hold, revoke.");
  }
  if (!reason || !reason.trim()) {
    throw new HttpsError("invalid-argument", "A reason is required for every release-control action.");
  }

  const statusFor = { release: "released", hold: "held", revoke: "revoked" }[action];
  const db = admin.firestore();
  const succeeded = [];
  const failed = [];
  const newlyReleased = []; // { reportCardId, studentId } for parent notify

  for (const reportCardId of reportCardIds) {
    try {
      const ref = db.collection("schools").doc(caller.schoolId).collection("reportCards").doc(reportCardId);
      // eslint-disable-next-line no-await-in-loop
      await db.runTransaction(async (tx) => {
        const snap = await tx.get(ref);
        if (!snap.exists) throw new HttpsError("not-found", `Report card ${reportCardId} was not found.`);
        const data = snap.data();
        if (data.schoolId !== caller.schoolId) {
          throw new HttpsError("permission-denied", "This report does not belong to your school.");
        }
        if (!data.isFinalized) {
          throw new HttpsError(
            "failed-precondition",
            "Only an academically finalized report may have its financial access changed."
          );
        }
        if (action === "release" && data.financialAccessStatus !== "released") {
          newlyReleased.push({ reportCardId, studentId: data.studentId });
        }
        tx.update(ref, {
          financialAccessStatus: statusFor,
          // Marks this decision as a human Bursar override so the automatic
          // fee-payment gate (see maybeAutoUpdateReportCardFinancialAccess)
          // never silently overwrites it - a Bursar's manual release/hold/
          // revoke is authoritative until a Bursar changes it again,
          // regardless of what the fee balance does afterwards.
          financialAccessSource: "bursar",
          financialAccessUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
          financialAccessUpdatedBy: caller.uid,
          financialAccessReason: reason.trim(),
        });
        tx.set(ref.collection("auditLog").doc(), {
          action: `financial_access.${action}`,
          actorUid: caller.uid,
          actorDisplayName: caller.displayName,
          reason: reason.trim(),
          reportVersion: data.version,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      });
      succeeded.push(reportCardId);
    } catch (err) {
      failed.push({ reportCardId, reason: err.message || "unknown_error" });
    }
  }

  await writeAudit(caller.schoolId, {
    userId: caller.uid,
    action: `report_card.financial_access.${action}`,
    entityType: "reportCards",
    entityId: reportCardIds.join(","),
    newValue: { succeeded: succeeded.length, failed: failed.length, reason },
  });

  // Notify linked parents/students when a withheld report just became
  // available. Best-effort; a failure here must not fail the release itself.
  for (const { reportCardId, studentId } of newlyReleased) {
    if (!succeeded.includes(reportCardId)) continue;
    try {
      const usersSnap = await db
        .collection("users")
        .where("schoolId", "==", caller.schoolId)
        .where("studentIds", "array-contains", studentId)
        .get();
      for (const u of usersSnap.docs) {
        await enqueueReportCardNotification({
          schoolId: caller.schoolId,
          recipientUid: u.id,
          // Matches the app's reportCardPublished deep-link mapping so the
          // parent lands on the report screen.
          type: "reportCardPublished",
          title: "Report card now available",
          shortBody:
            "A report card that was awaiting financial clearance is now available to view.",
          reportCardId,
          action: "released",
          reportVersion: 0,
        });
      }
    } catch (err) {
      console.error("parent report_card.released notify failed", reportCardId, err);
    }
  }

  return { succeeded, failed };
});

/**
 * Public, read-only report-card verification page. Never serves the PDF or
 * any private field - only school identity, student first-name-only
 * identity, academic period, version, finalization status, and whether the
 * report is current or superseded. Mirrors
 * public_functions/documents/verification_endpoint.js's pattern: GET-only,
 * no-store, token-format pre-check before ever touching Firestore.
 */
exports.verifyReportCard = onRequest(async (req, res) => {
  res.set("Cache-Control", "no-store, max-age=0");
  if (req.method !== "GET") {
    res.status(405).send("Method not allowed.");
    return;
  }
  const token = String(req.query.token || "");
  if (!/^[A-Za-z0-9_-]{16,80}$/.test(token)) {
    res.status(400).send("Invalid verification token.");
    return;
  }

  try {
    // The token is stored as both the document id and a `verificationCode`
    // field within each school's reportVerifications subcollection (see
    // generateReportCardPdf) specifically so it can be resolved here via a
    // collectionGroup query without knowing which school issued it in
    // advance - a collectionGroup query cannot filter on a bare document id
    // alone.
    const tokenQuery = await admin
      .firestore()
      .collectionGroup("reportVerifications")
      .where("verificationCode", "==", token)
      .limit(1)
      .get();

    if (tokenQuery.empty) {
      res.status(404).send(renderVerificationHtml({ found: false }));
      return;
    }

    const data = tokenQuery.docs[0].data();
    res.status(200).send(
      renderVerificationHtml({
        found: true,
        schoolName: data.schoolNameSnapshot || "",
        studentDisplayName: data.studentDisplayName || "Student",
        academicYearId: data.academicYearId,
        termId: data.termId,
        version: data.version,
        isFinalized: data.isFinalized,
        isCurrent: data.isCurrent !== false,
      })
    );
  } catch (err) {
    console.error("verifyReportCard failed:", err);
    res.status(503).send(
      "Verification is temporarily unavailable. Please try again shortly."
    );
  }
});

function escapeHtml(value) {
  return String(value ?? "").replace(/[&<>"']/g, (c) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
  }[c]));
}

function renderVerificationHtml(result) {
  if (!result.found) {
    return `<!doctype html><html><head><meta charset="utf-8"><title>Verification</title></head>
      <body style="font-family:sans-serif;text-align:center;padding:40px;">
        <h2>Verification failed</h2>
        <p>This verification code does not match a known report card.</p>
      </body></html>`;
  }
  const statusLabel = !result.isFinalized
    ? "Not yet academically finalized"
    : result.isCurrent
      ? "Current and authentic"
      : "Superseded by a corrected version";
  return `<!doctype html><html><head><meta charset="utf-8"><title>Report Card Verification</title></head>
    <body style="font-family:sans-serif;text-align:center;padding:40px;">
      <h2>${escapeHtml(result.schoolName)}</h2>
      <p><strong>${escapeHtml(result.studentDisplayName)}</strong></p>
      <p>Academic Year ${escapeHtml(result.academicYearId)} · Term ${escapeHtml(result.termId)} · v${escapeHtml(result.version)}</p>
      <p style="font-size:20px;font-weight:bold;color:${result.isFinalized && result.isCurrent ? "#16823A" : "#B42318"};">
        ${escapeHtml(statusLabel)}
      </p>
    </body></html>`;
}

/**
 * Publishes report cards to parents.
 *
 * Kept server-side because publication is the moment a report becomes a
 * record a family acts on, and because the fee-release policy has to be read
 * at the same instant - a client that could write `status: published` could
 * also skip that read.
 */
exports.publishClassReports = onCall(async (request) => {
  const caller = await requireRole(
    request.auth,
    ACADEMIC_ADMIN_ROLES,
    "Only the academic office can publish reports."
  );

  const { classId, academicYearId, termId, studentIds } = request.data || {};
  if (!classId || !academicYearId || !termId) {
    throw new HttpsError(
      "invalid-argument",
      "classId, academicYearId and termId are required."
    );
  }

  const db = admin.firestore();
  const school = db.collection("schools").doc(caller.schoolId);

  // Ensures every learner being published has a reportCards snapshot that
  // reflects the current approved marks, whether or not the Class Teacher's
  // own Compile action already ran. Idempotent - a snapshot already
  // matching the current source hash is left untouched.
  const generation = await _generateClassReportCardsInternal({
    schoolId: caller.schoolId,
    classId,
    streamId: null,
    academicYearId,
    termId,
    studentIds,
    actorUid: caller.uid,
  });

  // Finance's hold list, read here rather than trusted from the caller.
  const policyDoc = await school.collection("configs").doc("reportReleasePolicy").get();
  const policy = policyDoc.exists ? policyDoc.data() : {};
  const withheld = new Set(policy.withheldStudentIds || []);

  let query = school
    .collection("class_report_entries")
    .where("classId", "==", classId)
    .where("academicYearId", "==", academicYearId)
    .where("termId", "==", termId);

  const snapshot = await query.get();
  const batch = db.batch();
  const published = [];
  const skipped = [];

  snapshot.forEach((doc) => {
    const data = doc.data();
    if (Array.isArray(studentIds) && studentIds.length > 0
        && !studentIds.includes(data.studentId)) {
      return;
    }

    // A report the class teacher has not finished is not publishable, and a
    // student on the finance hold list is not released however this was
    // called.
    if (data.status !== "classTeacherCompleted"
        && data.status !== "academicOfficeApproved"
        && data.status !== "leadershipApproved") {
      skipped.push({ studentId: data.studentId, reason: "not_ready" });
      return;
    }
    if (withheld.has(data.studentId)) {
      skipped.push({ studentId: data.studentId, reason: "release_withheld" });
      return;
    }

    batch.update(doc.ref, {
      status: "published",
      publishedAt: admin.firestore.FieldValue.serverTimestamp(),
      publishedBy: caller.uid,
    });
    published.push(data.studentId);
  });

  if (published.length > 0) await batch.commit();

  await writeAudit(caller.schoolId, {
    userId: caller.uid,
    action: "report.published",
    entityType: "class_report_entry",
    entityId: classId,
    academicYearId,
    termId,
    classId,
    newValue: {
      publishedCount: published.length,
      skipped,
      reportCardsGenerated: generation.created.length,
      reportCardsUnchanged: generation.unchanged.length,
    },
  });

  if (published.length > 0) {
    notifyParentsOfPublishedReports({
      schoolId: caller.schoolId,
      studentIds: published,
      termId,
    }).catch((err) => console.error("report_available email fan-out failed", classId, err));
  }

  return { published: published.length, skipped, reportCardGeneration: generation };
});

/** One idempotency key per (student, term, recipient) - never per report content, so a duplicate publish event can't double-email. */
function reportAvailableEventId(studentId, termId, parentId) {
  return `report_available_${studentId}_${termId}_${parentId}`;
}

/** Firestore's `in` query operator accepts at most 10 values per query. */
function chunkIds(ids, size = 10) {
  const chunks = [];
  for (let i = 0; i < ids.length; i += size) chunks.push(ids.slice(i, i + size));
  return chunks;
}

/**
 * Emails each published student's parent(s) that a report is now available.
 * Uses the same schoolId-scoped students lookup pattern as notifications.js's
 * "student_parents" audience resolution (students filtered by caller.schoolId,
 * never a client-supplied schoolId), so a studentId can never resolve to a
 * parent outside the caller's own school. Does not attach or embed the
 * report's actual content - the email is a notification only, and existing
 * report-access/fee-clearance rules remain the sole gate on viewing it.
 */
async function notifyParentsOfPublishedReports({ schoolId, studentIds, termId }) {
  const db = admin.firestore();
  const schoolDoc = await db.collection("schools").doc(schoolId).get();
  const schoolName = schoolDoc.exists ? (schoolDoc.data().name || "Your school") : "Your school";
  const publishedAtLabel = new Date().toLocaleDateString("en-GB", {
    day: "numeric", month: "long", year: "numeric",
  });

  for (const idChunk of chunkIds(studentIds)) {
    const students = await db.collection("students")
      .where("schoolId", "==", schoolId)
      .where(admin.firestore.FieldPath.documentId(), "in", idChunk)
      .get();

    for (const student of students.docs) {
      const studentData = student.data() || {};
      const studentName = studentData.name || "Your child";
      const parentIds = studentData.parentIds || [];
      if (!parentIds.length) continue;

      const parents = await db.collection("users")
        .where(admin.firestore.FieldPath.documentId(), "in", parentIds.slice(0, 10))
        .get();

      for (const parent of parents.docs) {
        const email = parent.data()?.email;
        if (!email) continue;
        await enqueueTransactionalEmail({
          eventId: reportAvailableEventId(student.id, termId, parent.id),
          templateId: "report_available",
          to: email,
          data: {
            schoolName,
            studentName,
            reportId: `${student.id}_${termId}`,
            reportName: `${studentName}'s report`,
            periodLabel: termId,
            publishedByLabel: publishedAtLabel,
          },
        }).catch((err) => console.error("report_available email enqueue failed", student.id, parent.id, err));
      }
    }
  }
}

/**
 * Decides a teacher's request to change a register they may no longer edit.
 *
 * The teacher raises the request from the app; only this can act on it. Doing
 * it client-side would mean the person who wants the change is also the person
 * approving it.
 */
exports.decideAttendanceCorrection = onCall(async (request) => {
  const caller = await requireRole(
    request.auth,
    ACADEMIC_ADMIN_ROLES,
    "Only the academic office can decide attendance corrections."
  );

  const { correctionId, approve, decisionNote } = request.data || {};
  if (!correctionId || typeof approve !== "boolean") {
    throw new HttpsError(
      "invalid-argument",
      "correctionId and approve are required."
    );
  }

  const db = admin.firestore();
  const school = db.collection("schools").doc(caller.schoolId);
  const correctionRef = school.collection("class_attendance_corrections").doc(correctionId);
  const correctionDoc = await correctionRef.get();

  if (!correctionDoc.exists) {
    throw new HttpsError("not-found", "That correction request no longer exists.");
  }

  const correction = correctionDoc.data();
  if (correction.status !== "pending") {
    throw new HttpsError(
      "failed-precondition",
      "That correction request has already been decided."
    );
  }

  await correctionRef.update({
    status: approve ? "approved" : "rejected",
    decidedByUserId: caller.uid,
    decidedAt: admin.firestore.FieldValue.serverTimestamp(),
    decisionNote: decisionNote || null,
  });

  if (approve) {
    // Applied here rather than handed back to the teacher's device: the
    // register is locked to them, and a client write would need a permission
    // that would then also let them skip the approval.
    const sessionRef = school
      .collection("class_attendance_sessions")
      .doc(correction.sessionId);
    const sessionDoc = await sessionRef.get();

    if (sessionDoc.exists) {
      const session = sessionDoc.data();
      const entries = (session.entries || []).map((entry) =>
        entry.studentId === correction.studentId
          ? { ...entry, status: correction.requestedStatusCode }
          : entry
      );

      await sessionRef.update({
        entries,
        lastCorrectedAt: admin.firestore.FieldValue.serverTimestamp(),
        lastCorrectedBy: caller.uid,
      });
    }
  }

  await writeAudit(caller.schoolId, {
    userId: caller.uid,
    action: approve ? "attendance.correction_approved" : "attendance.correction_rejected",
    entityType: "class_attendance_session",
    entityId: correction.sessionId,
    classId: correction.classId,
    academicYearId: correction.academicYearId,
    studentId: correction.studentId,
    previousValue: { status: correction.previousStatusCode },
    newValue: { status: correction.requestedStatusCode },
    reason: correction.reason,
  });

  return { status: approve ? "approved" : "rejected" };
});

/**
 * Gives one staff member a second concurrent Class Teacher assignment.
 *
 * The default is one class per staff member per academic year and campus.
 * This is the only way past that, and it is deliberately awkward: it needs an
 * admin, an explicit reason, and it writes an audit row naming both classes.
 */
exports.overrideClassTeacherAssignment = onCall(async (request) => {
  const caller = await requireRole(
    request.auth,
    ACADEMIC_ADMIN_ROLES,
    "Only school administrators can override the one-class rule."
  );

  const { staffId, classId, className, academicYearId, campusId, reason } =
    request.data || {};

  if (!staffId || !classId || !academicYearId) {
    throw new HttpsError(
      "invalid-argument",
      "staffId, classId and academicYearId are required."
    );
  }
  if (!reason || reason.trim().length < 10) {
    throw new HttpsError(
      "invalid-argument",
      "Give a reason of at least 10 characters for the override."
    );
  }

  const db = admin.firestore();
  const assignments = db
    .collection("schools")
    .doc(caller.schoolId)
    .collection("staff_role_assignments");

  const existing = await assignments
    .where("staffId", "==", staffId)
    .where("roleType", "==", "classTeacher")
    .where("academicYearId", "==", academicYearId)
    .where("status", "==", "active")
    .get();

  const conflicting = existing.docs
    .map((d) => d.data())
    .filter((a) => (a.campusId || "") === (campusId || ""));

  // Nothing to override - the ordinary assignment path should have been used,
  // and silently accepting would hide that from the audit trail.
  if (conflicting.length === 0) {
    throw new HttpsError(
      "failed-precondition",
      "This staff member holds no class this year. Assign the class normally."
    );
  }

  const newAssignment = await assignments.add({
    schoolId: caller.schoolId,
    campusId: campusId || "",
    staffId,
    userId: staffId,
    roleType: "classTeacher",
    academicYearId,
    classId,
    className: className || classId,
    startDate: admin.firestore.FieldValue.serverTimestamp(),
    endDate: null,
    status: "active",
    permissionScope: {
      permissions: [],
      classId,
      academicYearId,
      termIds: [],
    },
    assignedBy: caller.uid,
    assignedAt: admin.firestore.FieldValue.serverTimestamp(),
    overrideReason: reason.trim(),
    isMultiClassOverride: true,
  });

  await writeAudit(caller.schoolId, {
    userId: caller.uid,
    action: "assignment.multi_class_override",
    entityType: "staff_role_assignment",
    entityId: newAssignment.id,
    classId,
    academicYearId,
    newValue: {
      staffId,
      addedClass: classId,
      alreadyHeld: conflicting.map((a) => a.classId),
    },
    reason: reason.trim(),
  });

  return {
    assignmentId: newAssignment.id,
    classesHeld: conflicting.length + 1,
  };
});

// Phase 8 Data Management entrypoint. It creates only tenant-scoped job
// metadata; parsing, validation and all source-record writes are delegated to
// a module-owned worker. Keeping this boundary here prevents a spreadsheet
// client from becoming a privileged Firestore writer.
exports.requestDataOperation = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in to manage data.");
  const data = request.data || {};
  const institutionId = String(data.institutionId || "");
  const operation = String(data.operation || "");
  const moduleKey = String(data.moduleKey || "data");
  const supported = new Set(["import", "export", "quality", "migrationDryRun", "archiveReview", "restoreRequest"]);
  if (!institutionId || !supported.has(operation)) {
    throw new HttpsError("invalid-argument", "Unsupported data operation.");
  }
  const db = admin.firestore();
  const user = await db.collection("users").doc(request.auth.uid).get();
  if (!user.exists) throw new HttpsError("permission-denied", "No active institution profile.");
  const profile = user.data();
  const membership = await db.collection("institution_memberships")
    .doc(`${request.auth.uid}_${institutionId}`).get();
  const isHomeInstitution = profile.schoolId === institutionId;
  if (!isHomeInstitution && (!membership.exists || membership.data().status !== "active")) {
    throw new HttpsError("permission-denied", "You are not an active member of this institution.");
  }
  const roles = Array.isArray(profile.roles) ? profile.roles : [profile.role];
  const adminRole = roles.some((role) => ["schoolAdmin", "headTeacher", "director"].includes(role));
  const permissions = Array.isArray(profile.permissions) ? profile.permissions : [];
  const required = {
    import: "data.import", export: "data.export", quality: "data.run_quality",
    migrationDryRun: "data.run_migration", archiveReview: "data.archive", restoreRequest: "data.request_restore",
  }[operation];
  if (!adminRole && !permissions.includes(required)) {
    throw new HttpsError("permission-denied", "Your effective permissions do not allow this data operation.");
  }
  if (operation === "import") {
    const ext = String(data.fileName || "").split(".").pop().toLowerCase();
    if (!["csv", "xlsx"].includes(ext) || !data.fileReference || !data.templateVersion) {
      throw new HttpsError("invalid-argument", "Imports require a CSV/XLSX file and a current template version.");
    }
    const prefix = `institutions/${institutionId}/data_operations/imports/`;
    if (!String(data.fileReference).startsWith(prefix)) {
      throw new HttpsError("permission-denied", "Import files must use the institution data-operations path.");
    }
  }
  const correlationId = randomUUID();
  const collection = operation === "import" ? "import_jobs" : operation === "export" ? "export_jobs" :
    operation === "quality" ? "data_quality_runs" : operation === "migrationDryRun" ? "migration_jobs" : "restore_requests";
  const job = db.collection("institutions").doc(institutionId).collection(collection).doc();
  const base = {
    institutionId, moduleKey, correlationId, requestedBy: request.auth.uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(), updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  if (operation === "import") Object.assign(base, {
    importJobId: job.id, uploadedBy: request.auth.uid, fileReference: data.fileReference,
    fileName: String(data.fileName), templateVersion: String(data.templateVersion), status: "uploaded",
    totalRows: 0, validRows: 0, invalidRows: 0, duplicateRows: 0, processedRows: 0, failedRows: 0,
  });
  if (operation === "export") Object.assign(base, {
    exportJobId: job.id, requestedBy: request.auth.uid, exportType: moduleKey, filters: data.filters || {},
    format: data.format || "xlsx", status: "queued", totalRecords: 0, processedRecords: 0, expiresAt: null,
  });
  if (operation === "migrationDryRun") Object.assign(base, {
    migrationJobId: job.id, migrationKey: moduleKey, sourceVersion: data.sourceVersion || "unknown",
    targetVersion: data.targetVersion || "current", status: "queued", dryRun: true,
    recordsScanned: 0, migrated: 0, skipped: 0, ambiguous: 0, failed: 0,
  });
  if (operation === "quality") Object.assign(base, { status: "queued", runId: job.id });
  if (operation === "restoreRequest") Object.assign(base, {
    restoreRequestId: job.id, reason: String(data.reason || "Institution restore request"),
    requestedScope: data.requestedScope || "full institution", status: "requested", urgency: data.urgency || "normal",
  });
  await job.create(base);
  await writeAudit(institutionId, {
    userId: request.auth.uid, action: `data.${operation}`, entityType: "data_operation", entityId: job.id,
    newValue: { moduleKey, correlationId }, reason: operation === "restoreRequest" ? base.reason : null,
  });
  return { jobId: job.id, correlationId, status: base.status };
});

exports.__test__ = {
  reportAvailableEventId, chunkIds, notifyParentsOfPublishedReports, isDelegationValid, validatePolicyStages, STAFF_ROLES, ADMIN_ROLES,
  generateClassReportCardsInternal: _generateClassReportCardsInternal,
  requireClassReportGenerationAccess,
  loadDefaultGradingSystem,
  RESPONSIBILITY_DEFAULT_PERMISSIONS,
};

// Support and audit are isolated in their own module so source business
// modules only need to emit their existing events, never duplicate tickets.
exports.submitInstitutionSupportRequest = supportAuditFunctions.submitInstitutionSupportRequest;
exports.addInstitutionSupportResponse = supportAuditFunctions.addInstitutionSupportResponse;
exports.addInstitutionSupportAttachment = supportAuditFunctions.addInstitutionSupportAttachment;
exports.changeInstitutionSupportStatus = supportAuditFunctions.changeInstitutionSupportStatus;
exports.decideSupportAccess = supportAuditFunctions.decideSupportAccess;
exports.expireSupportAccess = supportAuditFunctions.expireSupportAccess;

// Admission/Enrollment Setup Wizard audit trail - see
// functions/enrollment_audit.js. Writes into the same
// institutions/{schoolId}/audit_events collection as support_audit.js,
// with the same server-authored actor/timestamp trust model.
exports.recordEnrollmentAuditEvent = enrollmentAuditFunctions.recordEnrollmentAuditEvent;

// Adapter for legacy module activity. It preserves the legacy source while
// making a normalized, tenant-scoped row available to the Audit Center.
exports.normalizeLegacyAuditEvent = onDocumentCreated("audit_logs/{auditId}", async (event) => {
  const data = event.data?.data();
  if (!data?.schoolId) return;
  const ref = admin.firestore().doc(`institutions/${data.schoolId}/audit_events/legacy_${event.params.auditId}`);
  await ref.create({
    auditEventId: ref.id, institutionId: data.schoolId, moduleKey: data.moduleKey || "legacy",
    eventType: data.eventType || "Custom", action: data.action || data.title || "activity",
    actorId: data.userId || null, actorNameSnapshot: data.actorName || null,
    targetType: data.entityType || "record", targetId: data.relatedEntityId || null,
    targetDisplaySnapshot: data.description || null, previousValueSummary: null,
    newValueSummary: null, reason: null, status: "success", sensitivity: "normal",
    source: "legacy_adapter", correlationId: data.correlationId || event.params.auditId,
    metadataSafe: {}, createdAt: data.timestamp || admin.firestore.FieldValue.serverTimestamp(),
  });
});

/**
 * Guardian consent for direct-enrolment Step 6 (Documents & consent). See
 * guardian_consent.js for the full scope note (three tenant-gated capture
 * methods, append-only audit records, single-use time-limited links).
 */
const guardianConsentFunctions = require("./guardian_consent");
exports.recordGuardianConsentByStaff = guardianConsentFunctions.recordGuardianConsentByStaff;
exports.requestGuardianConsentLink = guardianConsentFunctions.requestGuardianConsentLink;
exports.resolveGuardianConsentLink = guardianConsentFunctions.resolveGuardianConsentLink;
exports.withdrawGuardianConsent = guardianConsentFunctions.withdrawGuardianConsent;
