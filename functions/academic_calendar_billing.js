/** Phase 1 of term-based SaaS billing: academic calendar confirmation and
 * subscription_cycles generation.
 *
 * Scope is deliberately narrow - this file ONLY confirms a school's
 * academic_terms and generates one subscription_cycles doc per confirmed
 * term (status always "upcoming"). It does NOT invoice, send reminders,
 * suspend schools, apply discounts, queue offline writes, or migrate/
 * backfill existing schools - all of that is explicitly Phase 2.
 *
 * Kept separate from subscription_management.js (which handles plan-change
 * requests and usage-metric refreshes) because this is a different concern:
 * calendar confirmation + billing-cycle materialization, not subscription
 * changes. Auth/audit helpers below intentionally mirror that file's style
 * rather than importing from it, so each file stays independently readable.
 */
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { buildPricingSnapshot } = require("./student_pricing_bands");

// Mirrors subscription_management.js's ADMIN_ROLES.
const ADMIN_ROLES = new Set(["schoolAdmin", "headTeacher", "director"]);

// The Flutter client calls this via
// FirebaseFunctions.instanceFor(region: 'europe-west1') to match every
// other callable in this app - must stay in sync or calls 404.
const CALLABLE_OPTS = { region: "europe-west1" };

const DEFAULT_GRACE_PERIOD_DAYS = 7;
const DEFAULT_INVOICE_LEAD_DAYS = 14;

async function requireSchoolAdmin(request, schoolId) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
  const db = admin.firestore();
  const callerSnap = await db.collection("users").doc(request.auth.uid).get();
  const caller = callerSnap.exists ? callerSnap.data() : null;
  if (!caller || !caller.schoolId || caller.isActive === false) {
    throw new HttpsError("permission-denied", "No active institution membership.");
  }
  const roles = [caller.role, ...(Array.isArray(caller.roles) ? caller.roles : [])];
  if (!roles.some((role) => ADMIN_ROLES.has(role))) {
    throw new HttpsError(
      "permission-denied",
      "Only a school admin, head teacher, or director may confirm the academic calendar."
    );
  }
  // Cross-tenant denial: the caller's own schoolId must match the schoolId
  // they are trying to confirm a calendar for. Never trust a client-passed
  // schoolId to imply authorization by itself.
  if (schoolId && caller.schoolId !== schoolId) {
    throw new HttpsError(
      "permission-denied",
      "You may only confirm the academic calendar for your own school."
    );
  }
  return { db, uid: request.auth.uid, schoolId: caller.schoolId, callerName: caller.name || "" };
}

async function recordAuditEvent(db, schoolId, actorId, action, metadata) {
  await db
    .collection("institutions")
    .doc(schoolId)
    .collection("audit_events")
    .add({
      actorId,
      action,
      metadata,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}

function toDate(value) {
  if (!value) return null;
  if (typeof value.toDate === "function") return value.toDate();
  if (value instanceof Date) return value;
  return new Date(value);
}

/** Re-implements StructureValidationService's overlap/range checks
 * server-side (Dart logic can't be called from Cloud Functions, and client-
 * passed dates are never trusted for validation - only the freshly re-read
 * Firestore docs are used here). */
function validateTerms(terms, yearsById) {
  const errors = [];
  const activeTerms = terms.filter((t) => !t.isArchived);

  for (const term of activeTerms) {
    if (!(term.startDate instanceof Date) || !(term.endDate instanceof Date)) {
      errors.push(`"${term.name}" is missing valid start/end dates.`);
      continue;
    }
    if (!(term.endDate > term.startDate)) {
      errors.push(`"${term.name}" end date must be after its start date.`);
    }
    const year = yearsById.get(term.academicYearId);
    if (!year) {
      errors.push(`"${term.name}" references an academic year that no longer exists.`);
    } else if (term.startDate < year.startDate || term.endDate > year.endDate) {
      errors.push(`"${term.name}" dates fall outside its academic year's range.`);
    }
  }

  // Overlap + duplicate-order check, grouped by academic year.
  const byYear = new Map();
  for (const term of activeTerms) {
    if (!byYear.has(term.academicYearId)) byYear.set(term.academicYearId, []);
    byYear.get(term.academicYearId).push(term);
  }
  for (const [, yearTerms] of byYear) {
    const sorted = [...yearTerms].sort((a, b) => (a.startDate || 0) - (b.startDate || 0));
    for (let i = 1; i < sorted.length; i++) {
      const prev = sorted[i - 1];
      const cur = sorted[i];
      if (cur.startDate && prev.endDate && cur.startDate <= prev.endDate) {
        errors.push(`"${cur.name}" overlaps "${prev.name}".`);
      }
    }
    const orderCounts = new Map();
    for (const term of yearTerms) {
      orderCounts.set(term.order, (orderCounts.get(term.order) || 0) + 1);
    }
    for (const [order, count] of orderCounts) {
      if (count > 1) {
        errors.push(`Duplicate term order/number (${order}) within the same academic year.`);
      }
    }
  }

  return errors;
}

/** Confirms a school's academic calendar and (re-)generates one
 * subscription_cycles doc per confirmed term. Idempotent: re-running for
 * already-confirmed terms updates cycles in place (merge) rather than
 * duplicating them, keyed by `${schoolId}_${termId}`. */
exports.confirmAcademicCalendar = onCall(CALLABLE_OPTS, async (request) => {
  const requestedSchoolId = request.data?.schoolId
    ? String(request.data.schoolId).trim()
    : null;
  const { db, uid, schoolId, callerName } = await requireSchoolAdmin(request, requestedSchoolId);

  // Re-read the school's academic_terms/academic_years server-side - never
  // trust client-passed dates for validation or generation.
  const [termsSnap, yearsSnap, schoolSnap, configSnap] = await Promise.all([
    db.collection("academic_terms").where("schoolId", "==", schoolId).get(),
    db.collection("academic_years").where("schoolId", "==", schoolId).get(),
    db.collection("schools").doc(schoolId).get(),
    db.collection("platform_billing_config").doc("renewal").get(),
  ]);

  if (termsSnap.empty) {
    throw new HttpsError("failed-precondition", "No academic terms exist for this school yet.");
  }

  const yearsById = new Map();
  for (const doc of yearsSnap.docs) {
    const data = doc.data();
    yearsById.set(doc.id, {
      id: doc.id,
      startDate: toDate(data.startDate),
      endDate: toDate(data.endDate),
    });
  }

  const requestedTermIds = Array.isArray(request.data?.termIds)
    ? request.data.termIds.map((v) => String(v))
    : null;

  const allTerms = termsSnap.docs.map((doc) => {
    const data = doc.data();
    return {
      docId: doc.id,
      id: doc.id,
      name: data.name || "",
      order: data.order || 0,
      academicYearId: data.academicYearId || "",
      startDate: toDate(data.startDate),
      endDate: toDate(data.endDate),
      isArchived: data.isArchived === true,
      isConfirmed: data.isConfirmed === true,
      ref: doc.ref,
    };
  });

  const targetTerms = requestedTermIds
    ? allTerms.filter((t) => requestedTermIds.includes(t.id))
    : allTerms.filter((t) => !t.isArchived);

  if (targetTerms.length === 0) {
    throw new HttpsError("invalid-argument", "No matching terms to confirm.");
  }

  // Server-side re-validation against ALL of the school's terms (not just
  // the target subset), so confirming one term can't silently ignore an
  // overlap introduced by a sibling term.
  const validationErrors = validateTerms(allTerms, yearsById);
  if (validationErrors.length > 0) {
    throw new HttpsError(
      "failed-precondition",
      `Academic calendar has validation errors: ${validationErrors.join(" ")}`
    );
  }

  // Block re-confirming a term that is already confirmed AND already has a
  // subscription_cycles doc in a status beyond "upcoming" (invoiced,
  // paymentPending, paid, gracePeriod, overdue) without explicit Super
  // Admin override. Phase 1 has no override flow - just block with a clear
  // error, per spec.
  const guardedStatuses = new Set([
    "invoiced",
    "paymentPending",
    "paid",
    "gracePeriod",
    "overdue",
  ]);
  const blockedTerms = [];
  for (const term of targetTerms) {
    if (!term.isConfirmed) continue;
    const cycleId = `${schoolId}_${term.id}`;
    const cycleSnap = await db.collection("subscription_cycles").doc(cycleId).get();
    if (cycleSnap.exists && guardedStatuses.has(cycleSnap.data().cycleStatus)) {
      blockedTerms.push(term.name);
    }
  }
  if (blockedTerms.length > 0) {
    throw new HttpsError(
      "failed-precondition",
      `Cannot modify already-confirmed term(s) with an active billing cycle: ${blockedTerms.join(", ")}. ` +
        "This requires Super Admin override, which is not available in this release."
    );
  }

  // Phase 3A: plan-based pricing (subscription_plans / planSnapshot) is
  // replaced by student-count-band pricing. Price is determined solely by
  // this school's Admin-SDK-verified active/enrolled student count against
  // the platform-wide student_pricing_bands table - see
  // student_pricing_bands.js's buildPricingSnapshot for the matching logic
  // and field-name rationale. subscription_plans itself is left untouched
  // (historical data preservation) and nothing below reads it anymore.
  const pricingResult = await buildPricingSnapshot(db, schoolId);
  const pricingSnapshot = pricingResult.matched ? pricingResult.snapshot : null;
  const pricingReviewRequired = !pricingResult.matched;
  const pricingReviewReason = pricingResult.matched ? null : pricingResult.reason;

  const config = configSnap.exists ? configSnap.data() : {};
  const gracePeriodDays = Number.isFinite(config.gracePeriodDays)
    ? config.gracePeriodDays
    : DEFAULT_GRACE_PERIOD_DAYS;

  const now = admin.firestore.FieldValue.serverTimestamp();
  const batch = db.batch();
  const confirmedTermIds = [];
  const generatedCycleIds = [];

  // Read existing cycle docs first so createdAt is only ever set once (a
  // merge:true write with serverTimestamp would otherwise overwrite it on
  // every re-confirm, breaking "immutable plan/price snapshot at
  // generation time").
  const existingCycleSnaps = await Promise.all(
    targetTerms.map((term) =>
      db.collection("subscription_cycles").doc(`${schoolId}_${term.id}`).get()
    )
  );
  const existingCycleById = new Map(
    existingCycleSnaps.map((snap) => [snap.id, snap.exists])
  );

  for (const term of targetTerms) {
    batch.set(
      term.ref,
      { isConfirmed: true, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true }
    );
    confirmedTermIds.push(term.id);

    // paymentDueAt/graceEndsAt derive strictly from this term's own dates -
    // never a fixed calendar or constant offset from "today".
    const paymentDueAt = term.startDate;
    const graceEndsAt = new Date(term.startDate.getTime());
    graceEndsAt.setDate(graceEndsAt.getDate() + gracePeriodDays);

    const cycleId = `${schoolId}_${term.id}`;
    const cycleRef = db.collection("subscription_cycles").doc(cycleId);
    const alreadyExists = existingCycleById.get(cycleId) === true;
    batch.set(
      cycleRef,
      {
        schoolId,
        subscriptionId: schoolId, // stand-in: no separate subscriptions collection exists yet
        academicYearId: term.academicYearId,
        termId: term.id,
        termNumber: term.order,
        termStart: admin.firestore.Timestamp.fromDate(term.startDate),
        termEnd: admin.firestore.Timestamp.fromDate(term.endDate),
        invoiceIssuedAt: null,
        paymentDueAt: admin.firestore.Timestamp.fromDate(paymentDueAt),
        graceEndsAt: admin.firestore.Timestamp.fromDate(graceEndsAt),
        pricingSnapshot,
        pricingReviewRequired,
        ...(pricingReviewReason ? { pricingReviewReason } : {}),
        discountSnapshot: null,
        paymentStatus: "unpaid",
        cycleStatus: "upcoming",
        updatedAt: now,
        ...(alreadyExists ? {} : { createdAt: now }),
      },
      { merge: true }
    );
    generatedCycleIds.push(cycleId);
  }

  await batch.commit();

  await recordAuditEvent(db, schoolId, uid, "academic_calendar_confirmed", {
    termIds: confirmedTermIds,
    cycleIds: generatedCycleIds,
    actorName: callerName,
  });

  return {
    ok: true,
    confirmedTermIds,
    cycleIds: generatedCycleIds,
  };
});

/** Owner-only read/write for `platform_billing_config/renewal` (invoice
 * lead days + grace period days). Kept intentionally minimal - mirrors
 * getManualPaymentConfig/updateManualPaymentConfig in public_functions/
 * payments.js - because a settings UI for it is Phase 2. Without this doc
 * present, confirmAcademicCalendar simply falls back to the hardcoded
 * defaults above. */
async function requirePlatformOwnerLocal(request) {
  // Deliberately does not import public_functions/vendor/owner-auth to
  // avoid cross-package coupling between functions/ and public_functions/
  // (they deploy as separate Cloud Functions codebases in this repo). This
  // mirrors the same custom-claim check that vendor/owner-auth performs.
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
  const claims = request.auth.token || {};
  if (claims.platformOwner !== true && claims.role !== "platformOwner") {
    throw new HttpsError("permission-denied", "Platform owner access required.");
  }
  return admin.firestore();
}

exports.getRenewalBillingConfig = onCall(CALLABLE_OPTS, async (request) => {
  const db = await requirePlatformOwnerLocal(request);
  const snap = await db.collection("platform_billing_config").doc("renewal").get();
  const config = snap.exists ? snap.data() : {};
  return {
    ok: true,
    invoiceLeadDays: Number.isFinite(config.invoiceLeadDays)
      ? config.invoiceLeadDays
      : DEFAULT_INVOICE_LEAD_DAYS,
    gracePeriodDays: Number.isFinite(config.gracePeriodDays)
      ? config.gracePeriodDays
      : DEFAULT_GRACE_PERIOD_DAYS,
  };
});

exports.updateRenewalBillingConfig = onCall(CALLABLE_OPTS, async (request) => {
  const db = await requirePlatformOwnerLocal(request);
  const invoiceLeadDays = Number(request.data?.invoiceLeadDays);
  const gracePeriodDays = Number(request.data?.gracePeriodDays);
  if (!Number.isFinite(invoiceLeadDays) || invoiceLeadDays < 0) {
    throw new HttpsError("invalid-argument", "invoiceLeadDays must be a non-negative number.");
  }
  if (!Number.isFinite(gracePeriodDays) || gracePeriodDays < 0) {
    throw new HttpsError("invalid-argument", "gracePeriodDays must be a non-negative number.");
  }
  await db.collection("platform_billing_config").doc("renewal").set(
    {
      invoiceLeadDays,
      gracePeriodDays,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: request.auth.uid,
    },
    { merge: true }
  );
  return { ok: true, invoiceLeadDays, gracePeriodDays };
});

exports.DEFAULT_GRACE_PERIOD_DAYS = DEFAULT_GRACE_PERIOD_DAYS;
exports.DEFAULT_INVOICE_LEAD_DAYS = DEFAULT_INVOICE_LEAD_DAYS;
exports._validateTerms = validateTerms;
