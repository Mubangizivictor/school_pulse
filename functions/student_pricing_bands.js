/** Phase 3A of the pricing-model replacement: student-count-band pricing.
 *
 * Replaces plan-based pricing (subscription_plans / planSnapshot) with a
 * platform-wide table of [minStudents, maxStudents] -> amountUgx bands.
 * Every feature stays available to every active school regardless of price
 * - price is determined solely by the school's Admin-SDK-verified
 * active/enrolled student count. Billing stays termly (subscription_cycles,
 * one doc per confirmed academic_terms doc - see academic_calendar_billing.js).
 *
 * This file owns:
 *  - the student_pricing_bands CRUD callables (owner-only writes)
 *  - band-matching logic used by academic_calendar_billing.js's
 *    confirmAcademicCalendar to snapshot pricing onto a subscription_cycles
 *    doc (see buildPricingSnapshot, exported below and required from that
 *    file, keeping the plan-snapshot-replacement code and the CRUD code
 *    separated as suggested by the phase spec)
 *  - the verified-student-count helper
 *
 * subscription_plans (collection, Dart model, CRUD callables) is left
 * completely untouched - historical data preservation. Nothing in this file
 * reads or writes it.
 */
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { requirePlatformOwner, OwnerAuthorizationError } = require("./vendor/owner-auth");

const CALLABLE_OPTS = { region: "europe-west1" };
const COLLECTION = "student_pricing_bands";

// Mirrors public_functions/school_counts.js:21's ACTIVE_STUDENT_STATUSES
// EXACTLY. functions/ and public_functions/ deploy as separate Cloud
// Functions codebases (confirmed in Phase 2A research) with no shared
// require() graph, so this cannot be imported directly - it is duplicated
// here on purpose. If the definition of "active/enrolled student" ever
// changes, BOTH this array and public_functions/school_counts.js:21 must be
// updated together, or verified counts used for pricing will silently
// diverge from the counts shown on the School Overview dashboard tile.
const ACTIVE_STUDENT_STATUSES = ["active", "enrolled"];

async function owner(request, db) {
  try {
    return await requirePlatformOwner(request, { db });
  } catch (error) {
    if (error instanceof OwnerAuthorizationError) throw new HttpsError(error.code, error.message);
    throw error;
  }
}

/** Admin-SDK-only, aggregation-only verified student count for one school.
 * NEVER returns/exposes individual student documents. Tenant-scoped by
 * construction (schoolId equality filter). Mirrors the exact query shape of
 * public_functions/school_counts.js's getSchoolCounts studentsQuery -
 * same two-equality-filter query, already covered by the existing
 * `students`: schoolId ASC, status ASC composite index in
 * firestore.indexes.json, so no new index is needed for this count. */
async function getVerifiedStudentCount(db, schoolId) {
  const snap = await db
    .collection("students")
    .where("schoolId", "==", schoolId)
    .where("status", "in", ACTIVE_STUDENT_STATUSES)
    .count()
    .get();
  return snap.data().count;
}

function toDate(value) {
  if (!value) return null;
  if (typeof value.toDate === "function") return value.toDate();
  if (value instanceof Date) return value;
  return new Date(value);
}

function upperBound(band) {
  return band.maxStudents === null || band.maxStudents === undefined
    ? Infinity
    : band.maxStudents;
}

/** True if two [min,max] ranges (null max = unbounded) overlap. */
function rangesOverlap(a, b) {
  const aMax = upperBound(a);
  const bMax = upperBound(b);
  return a.minStudents <= bMax && b.minStudents <= aMax;
}

/** Validates a candidate band's shape (not overlap - that needs sibling
 * bands, done separately) per the phase spec's rules. Throws HttpsError on
 * the first violation. */
function validateBandShape({ minStudents, maxStudents, amountUgx }) {
  if (!Number.isInteger(minStudents) || minStudents < 0) {
    throw new HttpsError("invalid-argument", "minStudents must be a non-negative integer.");
  }
  if (maxStudents !== null && maxStudents !== undefined) {
    if (!Number.isInteger(maxStudents) || maxStudents < minStudents) {
      throw new HttpsError(
        "invalid-argument",
        "maxStudents must be an integer >= minStudents, or null for an unbounded final band."
      );
    }
  }
  if (!Number.isInteger(amountUgx) || amountUgx <= 0) {
    throw new HttpsError("invalid-argument", "amountUgx must be a positive whole number.");
  }
}

/** Rejects a candidate band if it overlaps or exactly duplicates any OTHER
 * currently-active band. excludeId lets an update check against every band
 * except itself. */
function assertNoOverlap(candidate, activeBands, excludeId) {
  for (const existing of activeBands) {
    if (excludeId && existing.id === excludeId) continue;
    if (
      existing.minStudents === candidate.minStudents &&
      upperBound(existing) === upperBound(candidate)
    ) {
      throw new HttpsError(
        "already-exists",
        `An active band with the identical range (${candidate.minStudents}-${
          candidate.maxStudents === null ? "unbounded" : candidate.maxStudents
        }) already exists.`
      );
    }
    if (rangesOverlap(existing, candidate)) {
      throw new HttpsError(
        "failed-precondition",
        `Range overlaps an existing active band (${existing.minStudents}-${
          existing.maxStudents === null ? "unbounded" : existing.maxStudents
        }).`
      );
    }
  }
}

/** Read-time gap report: given the full set of currently-active bands,
 * returns the list of [gapStart, gapEnd] integer ranges NOT covered by
 * exactly one active band, starting from 0. Does not throw - callers decide
 * what to do with gaps. Used by getPricingBands so Super Admin tooling
 * (Phase 3C) can surface "these student counts have no price configured"
 * without this file blocking every mutation that transiently leaves a gap.
 *
 * Judgment call (documented per phase spec): gap enforcement is done at
 * READ time / as a report, not blocked at every single write. Overlaps ARE
 * blocked at write time (assertNoOverlap above) because an overlap is
 * always ambiguous and never a legitimate transient state, but a gap can be
 * a legitimate transient state (e.g. owner is about to add the next band in
 * a second call) - band-matching at cycle-generation time (see
 * buildPricingSnapshot) independently handles "no band matches" safely via
 * pricingReviewRequired, so an uncovered count never produces a fabricated
 * price even if a gap report was never checked. */
function findGaps(activeBands) {
  const sorted = [...activeBands].sort((a, b) => a.minStudents - b.minStudents);
  const gaps = [];
  let expected = 0;
  for (const band of sorted) {
    if (band.minStudents > expected) {
      gaps.push([expected, band.minStudents - 1]);
    }
    expected = Math.max(expected, upperBound(band) + 1);
  }
  if (expected !== Infinity) {
    gaps.push([expected, null]); // unbounded gap - no final open-ended band configured
  }
  return gaps;
}

function bandFromDoc(doc) {
  const d = doc.data();
  return {
    id: doc.id,
    minStudents: d.minStudents,
    maxStudents: d.maxStudents === undefined ? null : d.maxStudents,
    amountUgx: d.amountUgx,
    isActive: d.isActive === true,
    effectiveFrom: toDate(d.effectiveFrom),
    effectiveTo: toDate(d.effectiveTo),
  };
}

async function loadActiveBands(db) {
  const snap = await db.collection(COLLECTION).where("isActive", "==", true).get();
  return snap.docs.map(bandFromDoc);
}

/** True if `count` falls within this band's [min, max-or-unbounded] range
 * AND the band is currently in its effective window (effectiveFrom <= now,
 * effectiveTo null or > now). */
function bandCoversCount(band, count, now) {
  if (count < band.minStudents) return false;
  if (band.maxStudents !== null && count > band.maxStudents) return false;
  if (band.effectiveFrom && band.effectiveFrom > now) return false;
  if (band.effectiveTo && band.effectiveTo <= now) return false;
  return true;
}

/** Core band-matching used by confirmAcademicCalendar to snapshot pricing
 * onto a subscription_cycles doc. Returns either:
 *  - { matched: true, snapshot: {...} } - exactly one active, in-window
 *    band covers `verifiedStudentCount`.
 *  - { matched: false, reason } - zero or multiple bands matched (a gap in
 *    coverage, no bands configured yet, or a validation bug that let two
 *    overlapping bands through) - caller must NOT fabricate a price; it
 *    should set pricingReviewRequired:true with `reason` instead.
 *
 * Field name chosen for the new snapshot: `pricingSnapshot` (replaces the
 * old `planSnapshot` field going forward - see academic_calendar_billing.js
 * for where this gets written onto the cycle doc). */
async function buildPricingSnapshot(db, schoolId) {
  const verifiedStudentCount = await getVerifiedStudentCount(db, schoolId);
  const now = new Date();
  const activeBands = await loadActiveBands(db);
  const matches = activeBands.filter((b) => bandCoversCount(b, verifiedStudentCount, now));

  if (matches.length === 1) {
    const band = matches[0];
    return {
      matched: true,
      verifiedStudentCount,
      snapshot: {
        bandId: band.id,
        minStudents: band.minStudents,
        maxStudents: band.maxStudents,
        amountUgx: band.amountUgx,
        currency: "UGX",
        verifiedStudentCount,
        countedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
    };
  }

  if (matches.length === 0) {
    return {
      matched: false,
      verifiedStudentCount,
      reason:
        activeBands.length === 0
          ? "No active pricing bands are configured."
          : `No active pricing band covers a verified student count of ${verifiedStudentCount}.`,
    };
  }

  // Defensive: write-time validation should prevent this, but never guess.
  return {
    matched: false,
    verifiedStudentCount,
    reason: `${matches.length} active pricing bands ambiguously match a verified student count of ${verifiedStudentCount} (band IDs: ${matches
      .map((b) => b.id)
      .join(", ")}). This indicates a validation bug - contact platform support.`,
  };
}

async function recordAudit(db, actorId, action, metadata) {
  await db.collection("super_admin_audit_logs").add({
    action,
    ownerId: actorId,
    metadata,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/** Owner-only. Creates a new pricing band. Validates shape + overlap
 * against currently-active bands inside a transaction (read-then-write, so
 * two concurrent creates can't both pass the overlap check against a stale
 * read). Always allowed to add a future-effective band - this is the ONLY
 * way to change pricing going forward once a band has been snapshotted by
 * an issued cycle (see updatePricingBand for the immutability guard). */
exports.createPricingBand = onCall(CALLABLE_OPTS, async (request) => {
  const db = admin.firestore();
  const auth = await owner(request, db);
  const d = request.data || {};
  const minStudents = Number(d.minStudents);
  const maxStudents = d.maxStudents === null || d.maxStudents === undefined ? null : Number(d.maxStudents);
  const amountUgx = Number(d.amountUgx);
  const isActive = d.isActive !== false;
  const effectiveFrom = d.effectiveFrom ? new Date(d.effectiveFrom) : new Date();
  const effectiveTo = d.effectiveTo ? new Date(d.effectiveTo) : null;

  validateBandShape({ minStudents, maxStudents, amountUgx });

  const bandId = await db.runTransaction(async (tx) => {
    const activeSnap = await tx.get(db.collection(COLLECTION).where("isActive", "==", true));
    const activeBands = activeSnap.docs.map(bandFromDoc);
    if (isActive) {
      assertNoOverlap({ minStudents, maxStudents }, activeBands, null);
    }
    const ref = db.collection(COLLECTION).doc();
    tx.set(ref, {
      minStudents,
      maxStudents,
      amountUgx,
      isActive,
      effectiveFrom: admin.firestore.Timestamp.fromDate(effectiveFrom),
      effectiveTo: effectiveTo ? admin.firestore.Timestamp.fromDate(effectiveTo) : null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: auth.uid,
      updatedBy: auth.uid,
    });
    return ref.id;
  });

  await recordAudit(db, auth.uid, "CREATE_PRICING_BAND", { bandId, minStudents, maxStudents, amountUgx, isActive });
  return { ok: true, bandId };
});

/** Returns true if `bandId` has already been snapshotted by an issued
 * cycle (invoiceIssuedAt != null) - such a band's amount/range become
 * immutable per the phase spec; a school that has already been invoiced off
 * this band must never see its historical invoice retroactively change. */
async function isBandInvoiced(db, bandId) {
  const snap = await db
    .collection("subscription_cycles")
    .where("pricingSnapshot.bandId", "==", bandId)
    .where("invoiceIssuedAt", "!=", null)
    .limit(1)
    .get();
  return !snap.empty;
}

/** Owner-only. Updates an existing band. Blocks any change to amountUgx,
 * minStudents, or maxStudents if the band has already been snapshotted by
 * an issued cycle (immutability guard) - effectiveFrom/effectiveTo/isActive
 * changes that don't touch the priced range are still allowed even on an
 * invoiced band, since they don't rewrite history. */
exports.updatePricingBand = onCall(CALLABLE_OPTS, async (request) => {
  const db = admin.firestore();
  const auth = await owner(request, db);
  const d = request.data || {};
  const bandId = String(d.bandId || "").trim();
  if (!bandId) throw new HttpsError("invalid-argument", "bandId is required.");

  const ref = db.collection(COLLECTION).doc(bandId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Pricing band not found.");
  const current = bandFromDoc(snap);

  const minStudents = d.minStudents === undefined ? current.minStudents : Number(d.minStudents);
  const maxStudents =
    d.maxStudents === undefined ? current.maxStudents : d.maxStudents === null ? null : Number(d.maxStudents);
  const amountUgx = d.amountUgx === undefined ? current.amountUgx : Number(d.amountUgx);
  const isActive = d.isActive === undefined ? current.isActive : d.isActive === true;

  const rangeOrAmountChanged =
    minStudents !== current.minStudents || maxStudents !== current.maxStudents || amountUgx !== current.amountUgx;

  if (rangeOrAmountChanged && (await isBandInvoiced(db, bandId))) {
    throw new HttpsError(
      "failed-precondition",
      "This band has already been snapshotted by an issued invoice and its amount/range are now immutable. " +
        "Create a new band with a future effectiveFrom to change pricing going forward."
    );
  }

  validateBandShape({ minStudents, maxStudents, amountUgx });

  await db.runTransaction(async (tx) => {
    const activeSnap = await tx.get(db.collection(COLLECTION).where("isActive", "==", true));
    const activeBands = activeSnap.docs.map(bandFromDoc);
    if (isActive) {
      assertNoOverlap({ minStudents, maxStudents }, activeBands, bandId);
    }
    tx.update(ref, {
      minStudents,
      maxStudents,
      amountUgx,
      isActive,
      effectiveFrom: d.effectiveFrom
        ? admin.firestore.Timestamp.fromDate(new Date(d.effectiveFrom))
        : snap.data().effectiveFrom,
      effectiveTo: d.effectiveTo === undefined ? snap.data().effectiveTo ?? null : d.effectiveTo ? admin.firestore.Timestamp.fromDate(new Date(d.effectiveTo)) : null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: auth.uid,
    });
  });

  await recordAudit(db, auth.uid, "UPDATE_PRICING_BAND", { bandId, minStudents, maxStudents, amountUgx, isActive });
  return { ok: true, bandId };
});

/** Owner-only. Soft-deletes (isActive:false) a band. Judgment call
 * (documented per phase spec): this SOFT-WARNS rather than hard-blocking.
 * Deactivating a band a school currently relies on is a real operational
 * risk (their next cycle generation would hit pricingReviewRequired instead
 * of a price), but the phase spec explicitly says bands CAN be deactivated
 * and a hard block here would make it impossible to retire a band ahead of
 * a planned pricing change (the owner may already be adding a replacement
 * band in the same session). Instead: the response includes
 * `affectedActiveCycles` - a best-effort count of subscription_cycles docs
 * in cycleStatus 'upcoming' whose most recent pricingSnapshot.bandId
 * matches this band and whose school's CURRENT verified count would no
 * longer match any OTHER active band - so the owner console (Phase 3C) can
 * surface a warning before/after the call, without this callable itself
 * blocking a legitimate deactivation. Never blocks on an unpriced band
 * (one never referenced by an issued cycle) - always allowed. */
exports.deactivatePricingBand = onCall(CALLABLE_OPTS, async (request) => {
  const db = admin.firestore();
  const auth = await owner(request, db);
  const bandId = String(request.data?.bandId || "").trim();
  if (!bandId) throw new HttpsError("invalid-argument", "bandId is required.");

  const ref = db.collection(COLLECTION).doc(bandId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Pricing band not found.");

  await ref.update({
    isActive: false,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedBy: auth.uid,
  });

  // Best-effort warning count - deliberately does not block the write above.
  const remainingActive = (await loadActiveBands(db)).filter((b) => b.id !== bandId);
  const gaps = findGaps(remainingActive);
  // Firestore rejects an array nested directly inside another array (only
  // inside a map), so [[start,end],...] from findGaps must be converted to
  // {start,end} objects before it can be written into the audit log.
  const resultingGaps = gaps.map(([start, end]) => ({ start, end }));

  await recordAudit(db, auth.uid, "DEACTIVATE_PRICING_BAND", { bandId, resultingGaps });
  return { ok: true, bandId, resultingGaps };
});

/** Callable, not a direct client rule read, kept consistent with this
 * codebase's pattern of exposing read-mostly platform tables (e.g.
 * getRenewalBillingConfig) via onCall even when firestore.rules also allows
 * a direct read for the same data - see student_pricing_bands rules block
 * for the direct-read path Phase 3C's UI can use instead of this callable
 * if a simple watch is preferable to a callable round-trip. This callable
 * exists mainly so owner tooling can get the gap report in the same
 * response as the band list without a second call. Readable by any signed
 * in staff member OR the owner (see rules block: same shape as
 * subscription_plans - shared, non-sensitive pricing catalog data, not
 * tenant-scoped). */
exports.getPricingBands = onCall(CALLABLE_OPTS, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "You must be signed in.");
  const db = admin.firestore();
  const snap = await db.collection(COLLECTION).get();
  const bands = snap.docs.map((doc) => {
    const b = bandFromDoc(doc);
    return {
      id: b.id,
      minStudents: b.minStudents,
      maxStudents: b.maxStudents,
      amountUgx: b.amountUgx,
      isActive: b.isActive,
      effectiveFrom: b.effectiveFrom ? b.effectiveFrom.toISOString() : null,
      effectiveTo: b.effectiveTo ? b.effectiveTo.toISOString() : null,
    };
  });
  const gaps = findGaps(bands.filter((b) => b.isActive));
  return { ok: true, bands, gaps };
});

exports._internal = {
  ACTIVE_STUDENT_STATUSES,
  getVerifiedStudentCount,
  validateBandShape,
  assertNoOverlap,
  rangesOverlap,
  findGaps,
  bandCoversCount,
  buildPricingSnapshot,
  isBandInvoiced,
};
exports.buildPricingSnapshot = buildPricingSnapshot;
exports.getVerifiedStudentCount = getVerifiedStudentCount;
