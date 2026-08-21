// Report Card Engine - server-side grading, aggregation and immutable
// snapshot generation for the canonical schools/{schoolId}/reportCards
// collection.
//
// This module is deliberately split into pure functions (grade resolution,
// subject aggregation, ranking, hashing) that take plain data in and return
// plain data out, and a thin Firestore-aware orchestrator
// (generateClassReportCards) that reads real collections and writes the
// result. The pure functions are what the parity tests and unit tests
// exercise directly - no emulator required for those.
//
// Mirrors, rather than reimplements from scratch:
//   - lib/features/structure/domain/services/grade_resolver.dart
//     (GradeResolver.resolveScore) - resolveScore() below must resolve
//     identically for the same (score, system, bands) triple. See
//     report_card_engine.test.js's "parity fixtures" for the shared cases.
//   - the assessment/marks schema written by
//     lib/features/teacher/data/datasources/subject_teacher_remote_data_source.dart
//     and lib/features/dean/data/datasources/dean_remote_data_source.dart.

const crypto = require("crypto");

const SCHEMA_VERSION = 1;

// Mirrors ReportEntryStatus.storageId (class_report_entry.dart) for the
// statuses a report card generation run can observe on class_report_entries.
const REPORT_ENTRY_READY_STATUSES = new Set([
  "class_teacher_completed",
  "academic_office_approved",
  "leadership_approved",
  "published",
  "archived",
]);

// Marks in any of these markStatus values are not settled and must never
// contribute to a generated report - see student_marks security rules
// (firestore.rules ~line 2352), which only allow 'approved'/'published' to
// be treated as final.
const APPROVED_MARK_STATUSES = new Set(["approved", "published", "locked"]);

// Mirrors MarkEntryStatus (subject_assessment.dart): entryStatus values that
// are not a numeric score and must never be averaged in as zero.
const NON_SCORE_ENTRY_STATUSES = new Set([
  "absent",
  "exempted",
  "missing",
  "notAssessed",
  "notEntered",
]);

/**
 * Deterministic report-card identity: same school + student + period +
 * report type always yields the same id, so a retried/duplicate generation
 * request updates the same document rather than creating a sibling.
 */
function reportCardId({ schoolId, studentId, academicYearId, termId, reportType = "term" }) {
  const raw = [schoolId, studentId, academicYearId, termId, reportType].join("::");
  return crypto.createHash("sha256").update(raw).digest("hex").slice(0, 32);
}

/** Stable JSON stringify - sorts object keys so hash input never depends on property insertion order. */
function stableStringify(value) {
  if (value === null || typeof value !== "object") return JSON.stringify(value);
  if (Array.isArray(value)) return `[${value.map(stableStringify).join(",")}]`;
  const keys = Object.keys(value).sort();
  return `{${keys.map((k) => `${JSON.stringify(k)}:${stableStringify(value[k])}`).join(",")}}`;
}

/**
 * Hashes the exact source data + configuration a report card was computed
 * from. Two generation runs with an identical hash produce an identical
 * snapshot, which is what makes generation idempotent: a retry (or a second
 * click) that sees the same hash as an existing non-finalized snapshot
 * short-circuits rather than incrementing the version.
 */
function sourceHash({ markRows, gradingSystem, gradeBands, classEntry }) {
  const normalizedMarks = markRows
    .map((m) => ({
      assessmentId: m.assessmentId,
      componentId: m.componentId,
      subjectId: m.subjectId,
      score: m.score ?? null,
      entryStatus: m.entryStatus,
      maximumMark: m.maximumMark,
      weight: m.weight,
      markStatus: m.markStatus,
      updatedAtMillis: m.updatedAtMillis ?? null,
    }))
    .sort((a, b) => `${a.assessmentId}_${a.componentId}`.localeCompare(`${b.assessmentId}_${b.componentId}`));

  return crypto
    .createHash("sha256")
    .update(
      stableStringify({
        marks: normalizedMarks,
        gradingSystemId: gradingSystem ? gradingSystem.id : null,
        gradingSystemVersion: gradingSystem ? gradingSystem.version : null,
        gradeBands: (gradeBands || [])
          .map((b) => ({ grade: b.grade, minScore: b.minScore, maxScore: b.maxScore, order: b.order }))
          .sort((a, b) => a.order - b.order),
        classEntry: classEntry
          ? {
              competencies: classEntry.competencies || [],
              conduct: classEntry.conduct || [],
              overallConductCode: classEntry.overallConductCode ?? null,
              teacherComment: classEntry.teacherComment ?? null,
              recommendations: classEntry.recommendations || [],
              attendanceVerified: classEntry.attendanceVerified ?? false,
            }
          : null,
      })
    )
    .digest("hex");
}

/**
 * Resolves one numeric score against a grading system's bands. Must stay in
 * lockstep with GradeResolver.resolveScore (grade_resolver.dart): inclusive
 * bounds, lowest `order` wins on an overlap, no match returns an
 * "unresolved" result rather than a fabricated grade.
 */
function resolveGrade({ score, gradingSystem, gradeBands }) {
  if (!gradingSystem) {
    return { rawScore: score, gradeCode: null, gradeLabel: null, descriptor: null, gradePoint: null, isPassing: null };
  }
  const matching = (gradeBands || [])
    .filter(
      (b) =>
        b.gradingSystemId === gradingSystem.id &&
        b.schoolId === gradingSystem.schoolId &&
        b.hasNumericBoundary !== false &&
        score >= b.minScore &&
        score <= b.maxScore
    )
    .sort((a, b) => (a.order || 0) - (b.order || 0));

  if (matching.length === 0) {
    return { rawScore: score, gradeCode: null, gradeLabel: null, descriptor: null, gradePoint: null, isPassing: null };
  }
  const band = matching[0];
  return {
    rawScore: score,
    gradeCode: band.grade,
    gradeLabel: band.label || band.grade,
    descriptor: band.remarks || null,
    gradePoint: band.gradePoint ?? null,
    isPassing: band.isPassing !== false,
  };
}

/**
 * Validates a grading system's bands for internal consistency before they
 * are trusted for a whole class's generation. Overlap is the only failure
 * mode that would silently make results non-deterministic (a score in the
 * overlap resolving to whichever band's Firestore read order happened to
 * come first), so it is what generation must refuse to proceed past.
 */
function validateGradeBands(gradeBands) {
  const errors = [];
  const numeric = (gradeBands || []).filter((b) => b.hasNumericBoundary !== false);
  const sorted = [...numeric].sort((a, b) => a.minScore - b.minScore);
  for (let i = 0; i < sorted.length; i += 1) {
    const band = sorted[i];
    if (band.minScore > band.maxScore) {
      errors.push(`Grade band "${band.grade}" has minScore > maxScore.`);
    }
    if (i > 0 && sorted[i - 1].maxScore >= band.minScore) {
      errors.push(`Grade bands "${sorted[i - 1].grade}" and "${band.grade}" overlap.`);
    }
  }
  return errors;
}

/**
 * Aggregates one subject's approved mark rows into a single weighted
 * result. Each row is one assessment component; weight is the
 * school-configured share that component contributes (see
 * AssessmentComponent.weight, subject_assessment.dart). A row with a
 * non-score entryStatus (absent/exempted/missing/notAssessed/notEntered)
 * contributes no weight and no score - it is excluded from the weighted
 * total rather than counted as zero, and recorded as its own state so nof
 * the subject is reported as complete when it plainly is not.
 */
function aggregateSubject({ subjectId, rows, gradingSystem, gradeBands }) {
  const componentResults = rows.map((row) => {
    const isScored = row.entryStatus === "scored" && typeof row.score === "number";
    const normalizedScore =
      isScored && row.maximumMark > 0 ? (row.score / row.maximumMark) * 100 : null;
    return {
      assessmentId: row.assessmentId,
      componentId: row.componentId,
      componentName: row.componentName || "",
      entryStatus: row.entryStatus,
      rawScore: isScored ? row.score : null,
      maximumMark: row.maximumMark,
      weight: row.weight || 0,
      normalizedScore,
    };
  });

  const scoredComponents = componentResults.filter((c) => c.normalizedScore !== null);
  const totalWeight = scoredComponents.reduce((sum, c) => sum + c.weight, 0);

  const hasUnscored = componentResults.some((c) => c.normalizedScore === null);
  const isComplete = componentResults.length > 0 && !hasUnscored;

  let weightedAverage = null;
  if (scoredComponents.length > 0) {
    weightedAverage =
      totalWeight > 0
        ? scoredComponents.reduce((sum, c) => sum + c.normalizedScore * c.weight, 0) / totalWeight
        : scoredComponents.reduce((sum, c) => sum + c.normalizedScore, 0) / scoredComponents.length;
  }

  const grade =
    weightedAverage === null
      ? { rawScore: null, gradeCode: null, gradeLabel: null, descriptor: null, gradePoint: null, isPassing: null }
      : resolveGrade({ score: weightedAverage, gradingSystem, gradeBands });

  return {
    subjectId,
    componentResults,
    isComplete,
    // Absent/exempt/missing/not-assessed is a real, visible state - never
    // silently folded into "complete" or averaged in as zero.
    incompleteReason: isComplete
      ? null
      : componentResults.length === 0
        ? "no_marks"
        : componentResults.find((c) => c.normalizedScore === null)?.entryStatus || "incomplete",
    average: weightedAverage,
    grade: grade.gradeCode,
    gradeLabel: grade.gradeLabel,
    gradeDescriptor: grade.descriptor,
    gradePoint: grade.gradePoint,
    isPassing: grade.isPassing,
  };
}

/**
 * Ranks eligible learners by a configured metric using competition ranking
 * (1224 - equal scores share the same position, and the position number
 * itself jumps by the count of the tie, e.g. two students tied at rank 2
 * are both "2", and the next student is "4", never "3"). This is the
 * conventional ranking strategy for school report cards and the one this
 * function implements; a school configuration naming a different supported
 * strategy is out of scope for this phase and should fail loudly rather
 * than silently apply the wrong one.
 *
 * Ties are broken only by the configured metric - never by student name or
 * id, which would make the ranking arbitrary rather than merit-based.
 * Ineligible/incomplete learners are excluded entirely and marked
 * `position: null` by the caller.
 */
function rankByMetric(learnerMetrics, { descending = true } = {}) {
  const sorted = [...learnerMetrics].sort((a, b) =>
    descending ? b.metric - a.metric : a.metric - b.metric
  );
  const positions = new Map();
  let lastMetric = null;
  let lastPosition = 0;
  sorted.forEach((entry, index) => {
    if (lastMetric === null || entry.metric !== lastMetric) {
      lastPosition = index + 1;
      lastMetric = entry.metric;
    }
    positions.set(entry.studentId, lastPosition);
  });
  return positions;
}

module.exports = {
  SCHEMA_VERSION,
  REPORT_ENTRY_READY_STATUSES,
  APPROVED_MARK_STATUSES,
  NON_SCORE_ENTRY_STATUSES,
  reportCardId,
  stableStringify,
  sourceHash,
  resolveGrade,
  validateGradeBands,
  aggregateSubject,
  rankByMetric,
};
