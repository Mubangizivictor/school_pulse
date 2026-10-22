/**
 * Phase 3B of the pricing-model migration: READ-ONLY dry-run report.
 *
 * This script NEVER writes, updates, or deletes any Firestore document. It
 * only ever calls `.get()` / `.count().get()` against Firestore. There is no
 * `.set(`, `.update(`, `.delete(`, `.add(`, or `runTransaction(` anywhere in
 * this file - grep it yourself if in doubt. Its sole purpose is to inspect
 * the current state of `schools`, `subscription_plans`,
 * `student_pricing_bands`, and `subscription_cycles` and print a migration
 * PLAN for Phase 3C (a future, separate, write-performing script) to later
 * execute. Running this script against production is safe by construction:
 * there is nothing here that can mutate data. It does NOT commit, push,
 * deploy, or touch any file from Phase 1/2A/2B/3A.
 *
 * What it reads:
 *  - schools/*                    (status, accessMode, subscriptionPlanId,
 *                                   subscriptionExpiry, subscription snapshot,
 *                                   enabledFeatures)
 *  - subscription_plans/*         (count only - collection stays for history)
 *  - student_pricing_bands/*      (active bands + gap report, reusing
 *                                   functions/student_pricing_bands.js's
 *                                   exported findGaps/getVerifiedStudentCount/
 *                                   ACTIVE_STUDENT_STATUSES directly rather
 *                                   than reimplementing them)
 *  - subscription_cycles where schoolId==<id>  (per school, to report
 *                                   invoiced-vs-mutable cycles)
 *  - students where schoolId==<id> and status in ['active','enrolled']
 *                                   (count() aggregation only, mirrors
 *                                   Phase 3A's getVerifiedStudentCount /
 *                                   public_functions/school_counts.js)
 *
 * Migration-plan logic:
 *  1. Feature-flag recommendation: today `enabledFeatures` (a flat array on
 *     each school doc) is the ONLY real entitlement-gating mechanism in the
 *     codebase (confirmed - no plan-to-feature derivation exists anywhere).
 *     The business decision is "every feature to every active school", so
 *     for each trial/active school this script reports its CURRENT
 *     enabledFeatures list and flags it as a school that WOULD be migrated.
 *     It does not know the full canonical feature-id list (that lives in
 *     Flutter/Dart, not in this Node script), so it cannot compute a diff -
 *     it only flags "this school's enabledFeatures would be widened".
 *  2. Pricing-band matching: for each trial/active school, get its verified
 *     student count (students where schoolId==X, status in
 *     ACTIVE_STUDENT_STATUSES, .count().get()) and check which active
 *     student_pricing_bands doc (if any) covers that count "as of now".
 *     Schools with no matching band are listed under "would require
 *     pricing review" - never a guessed/zero price, exactly per the phase
 *     spec's `pricingReviewRequired` rule mirrored from
 *     confirmAcademicCalendar / buildPricingSnapshot.
 *  3. Cycle-immutability detection: for each school's existing
 *     subscription_cycles docs (expected to be zero today, since that
 *     collection is brand-new/uncommitted, but the script handles a
 *     non-empty result correctly for future re-runs), it partitions them
 *     into `invoiceIssuedAt != null` (already invoiced - IMMUTABLE, must
 *     NEVER be touched by any future migration write) vs still
 *     upcoming/mutable.
 *
 * Recommendation for Phase 3C (`allFeaturesIncluded` representation):
 *   Prefer a single boolean override flag `allFeaturesIncluded: true` on the
 *   school doc, read by the same two call sites that read `enabledFeatures`
 *   today (institution_context.dart, central_reports_screen.dart), rather
 *   than writing out every canonical feature id into `enabledFeatures`
 *   itself. Reasoning: (a) it survives the canonical feature list growing
 *   over time without a re-migration - a new feature ships already-on for
 *   every migrated school; (b) it keeps a clear textual record that a
 *   school was moved onto "all features" for pricing-model reasons, instead
 *   of an opaque long array that looks identical to a school someone
 *   manually granted every current feature to by hand; (c) it's a trivial,
 *   additive, backward-compatible read change (`enabledFeatures.contains(x)
 *   || allFeaturesIncluded`) with no schema migration needed on the Dart
 *   side beyond that one-line OR. Phase 3C should NOT delete or blank out
 *   the existing `enabledFeatures` array when it sets this flag - leave it
 *   as-is for audit/history, exactly like `subscription` and
 *   `subscription_plans` are left as historical data by this phase.
 *
 * Judgment calls made in this script:
 *  - Band matching here mirrors buildPricingSnapshot's "matched.length===1"
 *    logic (see student_pricing_bands.js) rather than re-deriving it, to
 *    avoid any drift between the dry-run report and the real
 *    confirmAcademicCalendar behavior. If zero or >1 active bands cover a
 *    school's count, it is reported as needing pricing review, exactly as
 *    a real cycle-generation run would flag it.
 *  - "Active" schools for the purposes of student-count/band-matching are
 *    status in ['trial','active'] only, per the spec's explicit instruction
 *    ("For each school with status in ['trial','active']"). Suspended/
 *    archived schools are still listed in the per-status breakdown but are
 *    NOT counted/band-matched (no assumption is made about whether a
 *    suspended school should be billed).
 *  - Schools with legacy `subscriptionPlanId`/`subscriptionExpiry` set but
 *    zero subscription_cycles docs are reported as "legacy flat-billing,
 *    no cycles yet" - this is expected to be EVERY current school, since
 *    subscription_cycles is a brand-new, still-uncommitted collection.
 *
 * How to run:
 *   Emulator (safe, recommended):
 *     FIRESTORE_EMULATOR_HOST=localhost:8080 GCLOUD_PROJECT=school-pulse-3d95b \
 *       node scripts/migration_dry_run_pricing_bands.js         (from functions/)
 *   Production (read-only, but requires real Admin SDK credentials which
 *   this sandbox does not have configured):
 *     node scripts/migration_dry_run_pricing_bands.js
 *
 * Safe-to-rerun guarantee: yes, unconditionally - this script performs zero
 * writes of any kind, so running it any number of times, against any
 * environment, changes nothing.
 */
const path = require("path");

const usingEmulator = !!process.env.FIRESTORE_EMULATOR_HOST;
if (!process.env.GCLOUD_PROJECT) {
  process.env.GCLOUD_PROJECT = "school-pulse-3d95b";
}

const admin = require("firebase-admin");
admin.initializeApp({ projectId: process.env.GCLOUD_PROJECT });
const db = admin.firestore();

// Reuse Phase 3A's exported pure helpers directly rather than reimplementing
// them, per the task instructions.
const {
  _internal: { ACTIVE_STUDENT_STATUSES, findGaps, bandCoversCount },
} = require(path.join(__dirname, "..", "student_pricing_bands"));

function toMillis(value) {
  if (!value) return null;
  if (typeof value.toMillis === "function") return value.toMillis();
  if (typeof value === "number") return value;
  return null;
}

async function getVerifiedStudentCount(schoolId) {
  const snap = await db
    .collection("students")
    .where("schoolId", "==", schoolId)
    .where("status", "in", ACTIVE_STUDENT_STATUSES)
    .count()
    .get();
  return snap.data().count;
}

function bandFromDoc(doc) {
  const d = doc.data();
  return {
    id: doc.id,
    minStudents: d.minStudents,
    maxStudents: d.maxStudents === undefined ? null : d.maxStudents,
    amountUgx: d.amountUgx,
    isActive: d.isActive === true,
    effectiveFrom: d.effectiveFrom && typeof d.effectiveFrom.toDate === "function" ? d.effectiveFrom.toDate() : null,
    effectiveTo: d.effectiveTo && typeof d.effectiveTo.toDate === "function" ? d.effectiveTo.toDate() : null,
  };
}

async function main() {
  console.log(`=== Phase 3B pricing-model migration dry-run report ===`);
  console.log(`Project: ${process.env.GCLOUD_PROJECT}`);
  console.log(
    usingEmulator
      ? `Connection: FIRESTORE EMULATOR (${process.env.FIRESTORE_EMULATOR_HOST})`
      : `Connection: LIVE Firestore (no FIRESTORE_EMULATOR_HOST set) - READ-ONLY, no writes will occur.`
  );
  console.log("");

  // --- 1. schools ---
  console.log("--- Reading schools ---");
  const schoolsSnap = await db.collection("schools").get();
  console.log(`Found ${schoolsSnap.size} school doc(s).`);

  const statusBuckets = { trial: [], active: [], suspended: [], archived: [], other: [] };
  const legacyFlatBillingSchools = [];
  const schoolsWithCyclesAlready = [];
  const schoolsWithLegacySubscriptionSnapshot = [];
  const featureMigrationPlan = [];

  const schools = schoolsSnap.docs.map((doc) => ({ id: doc.id, data: doc.data() }));

  for (const { id, data } of schools) {
    const status = statusBuckets[data.status] ? data.status : "other";
    statusBuckets[status].push(id);

    if (data.subscriptionPlanId || data.subscriptionExpiry) {
      legacyFlatBillingSchools.push({
        schoolId: id,
        subscriptionPlanId: data.subscriptionPlanId || null,
        subscriptionExpiry: toMillis(data.subscriptionExpiry) || data.subscriptionExpiry || null,
      });
    }

    if (data.subscription && typeof data.subscription === "object") {
      schoolsWithLegacySubscriptionSnapshot.push(id);
    }

    console.log(
      `  school=${id} status=${data.status || "(none)"} accessMode=${data.accessMode || "(none)"} ` +
        `enabledFeatures=${JSON.stringify(data.enabledFeatures || [])}`
    );

    const cyclesSnap = await db.collection("subscription_cycles").where("schoolId", "==", id).get();
    if (!cyclesSnap.empty) {
      schoolsWithCyclesAlready.push(id);
    }

    // Feature-migration plan entry for every school (report only - the
    // actual "would migrate to all features" decision is scoped to
    // trial/active below, but we record the current list for every school
    // here so Phase 3C has the full historical picture).
    featureMigrationPlan.push({
      schoolId: id,
      status: data.status || null,
      currentEnabledFeatures: data.enabledFeatures || [],
      wouldMigrateToAllFeatures: status === "trial" || status === "active",
    });

    // --- 5. cycle immutability detection (per school) ---
    if (!cyclesSnap.empty) {
      const invoiced = [];
      const mutable = [];
      cyclesSnap.docs.forEach((cycleDoc) => {
        const c = cycleDoc.data();
        if (c.invoiceIssuedAt !== null && c.invoiceIssuedAt !== undefined) {
          invoiced.push(cycleDoc.id);
        } else {
          mutable.push(cycleDoc.id);
        }
      });
      console.log(
        `    subscription_cycles for ${id}: ${invoiced.length} invoiced (IMMUTABLE) / ${mutable.length} mutable/upcoming`
      );
    }
  }

  // --- 2. subscription_plans ---
  console.log("");
  console.log("--- Reading subscription_plans ---");
  const plansSnap = await db.collection("subscription_plans").get();
  console.log(`Found ${plansSnap.size} subscription_plans doc(s). None will be deleted - kept for history.`);

  // --- 3. student_pricing_bands ---
  console.log("");
  console.log("--- Reading student_pricing_bands ---");
  const bandsSnap = await db.collection("student_pricing_bands").get();
  const allBands = bandsSnap.docs.map(bandFromDoc);
  const activeBands = allBands.filter((b) => b.isActive);
  console.log(`Found ${bandsSnap.size} pricing band doc(s), ${activeBands.length} active.`);
  const gaps = findGaps(activeBands);
  if (gaps.length === 0) {
    console.log("  Active bands fully cover [0, unbounded) with no gaps.");
  } else {
    console.log(`  Coverage gaps in active bands: ${JSON.stringify(gaps)}`);
  }

  // --- 4. per-school band matching for trial/active schools ---
  console.log("");
  console.log("--- Matching trial/active schools against pricing bands (verified student counts) ---");
  const wouldRequirePricingReview = [];
  const bandMatchPlan = [];
  const now = new Date();

  const trialAndActive = schools.filter((s) => s.data.status === "trial" || s.data.status === "active");
  for (const { id } of trialAndActive) {
    const verifiedStudentCount = await getVerifiedStudentCount(id);
    const matches = activeBands.filter((b) => bandCoversCount(b, verifiedStudentCount, now));

    if (matches.length === 1) {
      const band = matches[0];
      console.log(
        `  school=${id} verifiedStudentCount=${verifiedStudentCount} -> matches band ${band.id} ` +
          `(${band.minStudents}-${band.maxStudents === null ? "unbounded" : band.maxStudents}, ${band.amountUgx} UGX)`
      );
      bandMatchPlan.push({
        schoolId: id,
        verifiedStudentCount,
        matchedBandId: band.id,
        amountUgx: band.amountUgx,
      });
    } else {
      const reason =
        matches.length === 0
          ? activeBands.length === 0
            ? "No active pricing bands are configured."
            : `No active pricing band covers a verified student count of ${verifiedStudentCount}.`
          : `${matches.length} active pricing bands ambiguously match (bug) - band IDs: ${matches.map((b) => b.id).join(", ")}.`;
      console.log(`  school=${id} verifiedStudentCount=${verifiedStudentCount} -> WOULD REQUIRE PRICING REVIEW: ${reason}`);
      wouldRequirePricingReview.push({ schoolId: id, verifiedStudentCount, reason });
    }
  }

  // --- 6. final summary ---
  const summary = {
    schoolCounts: {
      total: schools.length,
      trial: statusBuckets.trial.length,
      active: statusBuckets.active.length,
      suspended: statusBuckets.suspended.length,
      archived: statusBuckets.archived.length,
      other: statusBuckets.other.length,
    },
    subscriptionPlansCount: plansSnap.size,
    pricingBandsCount: { total: bandsSnap.size, active: activeBands.length },
    pricingBandCoverageGaps: gaps,
    legacyFlatBillingSchoolIds: legacyFlatBillingSchools.map((s) => s.schoolId),
    schoolsWithExistingSubscriptionCycles: schoolsWithCyclesAlready,
    schoolsWithLegacySubscriptionSnapshot,
    featureMigrationPlan,
    bandMatchPlan,
    schoolIdsRequiringPricingReview: wouldRequirePricingReview.map((s) => s.schoolId),
    pricingReviewDetails: wouldRequirePricingReview,
    recommendation: {
      allFeaturesIncludedField:
        "Add a boolean `allFeaturesIncluded: true` flag on the school doc (see file header comment for full reasoning) rather than expanding `enabledFeatures` itself.",
    },
    writesPerformed: 0,
    confirmation: "NO WRITES WERE PERFORMED. This script only ever called .get()/.count().get().",
  };

  console.log("");
  console.log("--- SUMMARY (JSON) ---");
  console.log(JSON.stringify(summary, null, 2));
  console.log("");
  console.log("NO WRITES WERE PERFORMED.");
}

main().catch((err) => {
  console.error("Dry-run report failed:", err);
  process.exit(1);
});
