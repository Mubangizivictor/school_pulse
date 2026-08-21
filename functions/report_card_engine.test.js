// Plain Node test runner (no framework dependency), matching the convention
// in approvals.test.js. Run with: node report_card_engine.test.js
const assert = require("node:assert/strict");
const {
  reportCardId,
  sourceHash,
  resolveGrade,
  validateGradeBands,
  aggregateSubject,
  rankByMetric,
  ACADEMIC_STATUS,
  isValidTransition,
  resolveHeadteacherReturnTarget,
  buildApprovalHistoryEntry,
  isDuplicateDecision,
} = require("./report_card_engine");

let passed = 0;
let failed = 0;

function test(name, fn) {
  try {
    fn();
    passed += 1;
    console.log(`  ok  - ${name}`);
  } catch (error) {
    failed += 1;
    console.log(`FAIL  - ${name}`);
    console.log(`        ${error.message}`);
  }
}

// A small O-Level-shaped grading system, used purely as one configuration
// fixture among others - nothing here is hardcoded into the engine itself.
const gradingSystem = { id: "gs1", schoolId: "schoolA", version: 3 };
const gradeBands = [
  { grade: "D1", label: "Distinction 1", minScore: 90, maxScore: 100, order: 1, gradePoint: 1, isPassing: true, gradingSystemId: "gs1", schoolId: "schoolA" },
  { grade: "C3", label: "Credit 3", minScore: 70, maxScore: 89.999, order: 2, gradePoint: 3, isPassing: true, gradingSystemId: "gs1", schoolId: "schoolA" },
  { grade: "P7", label: "Pass 7", minScore: 40, maxScore: 69.999, order: 3, gradePoint: 7, isPassing: true, gradingSystemId: "gs1", schoolId: "schoolA" },
  { grade: "F9", label: "Fail 9", minScore: 0, maxScore: 39.999, order: 4, gradePoint: 9, isPassing: false, gradingSystemId: "gs1", schoolId: "schoolA" },
];

console.log("resolveGrade() - parity fixtures shared with grade_resolver_parity_test.dart");

// These exact (score, expected gradeCode) pairs are duplicated in
// test/features/structure/grade_resolver_parity_test.dart against
// GradeResolver.resolveScore with an equivalent GradingSystemDef/GradeBand
// fixture. Keep both lists in sync when either changes.
const parityFixtures = [
  { score: 100, expectedGrade: "D1" },
  { score: 90, expectedGrade: "D1" },
  { score: 89.999, expectedGrade: "C3" },
  { score: 70, expectedGrade: "C3" },
  { score: 69.999, expectedGrade: "P7" },
  { score: 40, expectedGrade: "P7" },
  { score: 39.999, expectedGrade: "F9" },
  { score: 0, expectedGrade: "F9" },
];

for (const fixture of parityFixtures) {
  test(`score ${fixture.score} resolves to ${fixture.expectedGrade}`, () => {
    const result = resolveGrade({ score: fixture.score, gradingSystem, gradeBands });
    assert.equal(result.gradeCode, fixture.expectedGrade);
  });
}

test("a score with no configured grading system is unresolved, not fabricated", () => {
  const result = resolveGrade({ score: 55, gradingSystem: null, gradeBands: [] });
  assert.equal(result.gradeCode, null);
  assert.equal(result.rawScore, 55);
});

test("a score outside every band is unresolved", () => {
  const result = resolveGrade({ score: -5, gradingSystem, gradeBands });
  assert.equal(result.gradeCode, null);
});

test("an overlapping pair of bands resolves to the lowest `order`, deterministically", () => {
  const overlapping = [
    ...gradeBands,
    { grade: "BONUS", minScore: 85, maxScore: 95, order: 0, gradingSystemId: "gs1", schoolId: "schoolA" },
  ];
  const result = resolveGrade({ score: 92, gradingSystem, gradeBands: overlapping });
  assert.equal(result.gradeCode, "BONUS");
});

console.log("\nvalidateGradeBands()");

test("non-overlapping bands are valid", () => {
  assert.deepEqual(validateGradeBands(gradeBands), []);
});

test("overlapping bands are rejected", () => {
  const overlapping = [
    { grade: "A", minScore: 50, maxScore: 100, order: 1 },
    { grade: "B", minScore: 40, maxScore: 60, order: 2 },
  ];
  const errors = validateGradeBands(overlapping);
  assert.equal(errors.length, 1);
  assert.match(errors[0], /overlap/);
});

test("an inverted band (min > max) is rejected", () => {
  const inverted = [{ grade: "X", minScore: 80, maxScore: 20, order: 1 }];
  const errors = validateGradeBands(inverted);
  assert.equal(errors.length, 1);
  assert.match(errors[0], /minScore > maxScore/);
});

test("a non-numeric band (e.g. a competency level) is skipped rather than checked for overlap", () => {
  const mixed = [
    { grade: "Achieved", hasNumericBoundary: false, order: 1 },
    ...gradeBands,
  ];
  assert.deepEqual(validateGradeBands(mixed), []);
});

console.log("\naggregateSubject()");

test("a single fully-scored component resolves a weighted average and grade", () => {
  const result = aggregateSubject({
    subjectId: "math",
    rows: [
      { assessmentId: "a1", componentId: "c1", entryStatus: "scored", score: 45, maximumMark: 50, weight: 100 },
    ],
    gradingSystem,
    gradeBands,
  });
  assert.equal(result.isComplete, true);
  assert.equal(result.average, 90);
  assert.equal(result.grade, "D1");
});

test("two weighted components combine into one weighted average", () => {
  // CAT worth 30%, scored 60/60 = 100%; Exam worth 70%, scored 49/70 = 70%.
  // Weighted: (100*30 + 70*70) / 100 = 79.
  const result = aggregateSubject({
    subjectId: "math",
    rows: [
      { assessmentId: "cat", componentId: "c1", entryStatus: "scored", score: 60, maximumMark: 60, weight: 30 },
      { assessmentId: "exam", componentId: "c2", entryStatus: "scored", score: 49, maximumMark: 70, weight: 70 },
    ],
    gradingSystem,
    gradeBands,
  });
  assert.equal(result.isComplete, true);
  assert.equal(result.average, 79);
  assert.equal(result.grade, "C3");
});

test("an absent component is excluded from the average, not counted as zero", () => {
  const result = aggregateSubject({
    subjectId: "math",
    rows: [
      { assessmentId: "cat", componentId: "c1", entryStatus: "scored", score: 60, maximumMark: 60, weight: 50 },
      { assessmentId: "exam", componentId: "c2", entryStatus: "absent", score: null, maximumMark: 70, weight: 50 },
    ],
    gradingSystem,
    gradeBands,
  });
  // Only the scored component contributes; the subject is marked incomplete
  // (an absent paper is not nothing to report) even though a number exists.
  assert.equal(result.isComplete, false);
  assert.equal(result.incompleteReason, "absent");
  assert.equal(result.average, 100);
});

test("an exempted component behaves the same as absent - excluded, not zeroed", () => {
  const result = aggregateSubject({
    subjectId: "math",
    rows: [
      { assessmentId: "cat", componentId: "c1", entryStatus: "exempted", score: null, maximumMark: 60, weight: 50 },
    ],
    gradingSystem,
    gradeBands,
  });
  assert.equal(result.isComplete, false);
  assert.equal(result.incompleteReason, "exempted");
  assert.equal(result.average, null);
});

test("no marks at all is reported as no_marks, not silently skipped", () => {
  const result = aggregateSubject({ subjectId: "math", rows: [], gradingSystem, gradeBands });
  assert.equal(result.isComplete, false);
  assert.equal(result.incompleteReason, "no_marks");
  assert.equal(result.average, null);
  assert.equal(result.grade, null);
});

test("a mark with maximumMark 0 does not throw a division error and stays unresolved", () => {
  const result = aggregateSubject({
    subjectId: "math",
    rows: [{ assessmentId: "a1", componentId: "c1", entryStatus: "scored", score: 0, maximumMark: 0, weight: 100 }],
    gradingSystem,
    gradeBands,
  });
  assert.equal(result.componentResults[0].normalizedScore, null);
});

console.log("\nrankByMetric() - competition ranking");

test("distinct metrics rank in strict descending order", () => {
  const positions = rankByMetric([
    { studentId: "s1", metric: 90 },
    { studentId: "s2", metric: 80 },
    { studentId: "s3", metric: 70 },
  ]);
  assert.equal(positions.get("s1"), 1);
  assert.equal(positions.get("s2"), 2);
  assert.equal(positions.get("s3"), 3);
});

test("a tie shares the same position, and the next position skips by the tie count", () => {
  const positions = rankByMetric([
    { studentId: "s1", metric: 90 },
    { studentId: "s2", metric: 80 },
    { studentId: "s3", metric: 80 },
    { studentId: "s4", metric: 60 },
  ]);
  assert.equal(positions.get("s1"), 1);
  assert.equal(positions.get("s2"), 2);
  assert.equal(positions.get("s3"), 2);
  // Competition ranking: two students tied at 2nd, so the next is 4th, not 3rd.
  assert.equal(positions.get("s4"), 4);
});

test("all learners tied share position 1", () => {
  const positions = rankByMetric([
    { studentId: "s1", metric: 50 },
    { studentId: "s2", metric: 50 },
  ]);
  assert.equal(positions.get("s1"), 1);
  assert.equal(positions.get("s2"), 1);
});

test("ranking never depends on studentId or name order - reordering the input changes nothing", () => {
  const a = rankByMetric([
    { studentId: "zeta", metric: 80 },
    { studentId: "alpha", metric: 80 },
  ]);
  const b = rankByMetric([
    { studentId: "alpha", metric: 80 },
    { studentId: "zeta", metric: 80 },
  ]);
  assert.equal(a.get("zeta"), b.get("zeta"));
  assert.equal(a.get("alpha"), b.get("alpha"));
  assert.equal(a.get("zeta"), a.get("alpha"));
});

console.log("\nreportCardId() - deterministic identity");

test("the same inputs always produce the same id", () => {
  const args = { schoolId: "schoolA", studentId: "s1", academicYearId: "2026", termId: "t2" };
  assert.equal(reportCardId(args), reportCardId(args));
});

test("a different student produces a different id", () => {
  const base = { schoolId: "schoolA", studentId: "s1", academicYearId: "2026", termId: "t2" };
  assert.notEqual(reportCardId(base), reportCardId({ ...base, studentId: "s2" }));
});

test("a different school produces a different id even for the same student/period - no cross-tenant collision", () => {
  const base = { schoolId: "schoolA", studentId: "s1", academicYearId: "2026", termId: "t2" };
  assert.notEqual(reportCardId(base), reportCardId({ ...base, schoolId: "schoolB" }));
});

console.log("\nsourceHash() - idempotency and change detection");

function marks() {
  return [
    { assessmentId: "a1", componentId: "c1", subjectId: "math", score: 45, entryStatus: "scored", maximumMark: 50, weight: 100, markStatus: "approved" },
  ];
}

test("identical source data produces an identical hash", () => {
  const h1 = sourceHash({ markRows: marks(), gradingSystem, gradeBands, classEntry: null });
  const h2 = sourceHash({ markRows: marks(), gradingSystem, gradeBands, classEntry: null });
  assert.equal(h1, h2);
});

test("hash input order does not affect the hash", () => {
  const rows = marks();
  const reversed = [...rows].reverse();
  const h1 = sourceHash({ markRows: rows, gradingSystem, gradeBands, classEntry: null });
  const h2 = sourceHash({ markRows: reversed, gradingSystem, gradeBands, classEntry: null });
  assert.equal(h1, h2);
});

test("changing a mark's score changes the hash", () => {
  const rows = marks();
  const changed = [{ ...rows[0], score: 46 }];
  const h1 = sourceHash({ markRows: rows, gradingSystem, gradeBands, classEntry: null });
  const h2 = sourceHash({ markRows: changed, gradingSystem, gradeBands, classEntry: null });
  assert.notEqual(h1, h2);
});

test("changing the grading system version changes the hash even if marks are unchanged", () => {
  const h1 = sourceHash({ markRows: marks(), gradingSystem, gradeBands, classEntry: null });
  const h2 = sourceHash({
    markRows: marks(),
    gradingSystem: { ...gradingSystem, version: 4 },
    gradeBands,
    classEntry: null,
  });
  assert.notEqual(h1, h2);
});

console.log("\nisValidTransition() - the academic approval state machine");

const validEdges = [
  [ACADEMIC_STATUS.GENERATED, ACADEMIC_STATUS.CLASS_TEACHER_REVIEW],
  [ACADEMIC_STATUS.CLASS_TEACHER_REVIEW, ACADEMIC_STATUS.SUBMITTED_TO_DEAN],
  [ACADEMIC_STATUS.RETURNED_BY_DEAN, ACADEMIC_STATUS.CLASS_TEACHER_REVIEW],
  [ACADEMIC_STATUS.SUBMITTED_TO_DEAN, ACADEMIC_STATUS.RETURNED_BY_DEAN],
  [ACADEMIC_STATUS.SUBMITTED_TO_DEAN, ACADEMIC_STATUS.DEAN_SIGNED],
  [ACADEMIC_STATUS.DEAN_SIGNED, ACADEMIC_STATUS.SUBMITTED_TO_HEADTEACHER],
  [ACADEMIC_STATUS.SUBMITTED_TO_HEADTEACHER, ACADEMIC_STATUS.RETURNED_BY_HEADTEACHER],
  [ACADEMIC_STATUS.SUBMITTED_TO_HEADTEACHER, ACADEMIC_STATUS.ACADEMICALLY_FINALIZED],
  [ACADEMIC_STATUS.RETURNED_BY_HEADTEACHER, ACADEMIC_STATUS.CLASS_TEACHER_REVIEW],
  [ACADEMIC_STATUS.RETURNED_BY_HEADTEACHER, ACADEMIC_STATUS.SUBMITTED_TO_DEAN],
  [ACADEMIC_STATUS.ACADEMICALLY_FINALIZED, ACADEMIC_STATUS.SUPERSEDED],
];
for (const [from, to] of validEdges) {
  test(`${from} -> ${to} is a valid transition`, () => {
    assert.equal(isValidTransition(from, to), true);
  });
}

const invalidEdges = [
  // Skipping stages entirely.
  [ACADEMIC_STATUS.GENERATED, ACADEMIC_STATUS.SUBMITTED_TO_DEAN],
  [ACADEMIC_STATUS.CLASS_TEACHER_REVIEW, ACADEMIC_STATUS.DEAN_SIGNED],
  [ACADEMIC_STATUS.SUBMITTED_TO_DEAN, ACADEMIC_STATUS.SUBMITTED_TO_HEADTEACHER],
  [ACADEMIC_STATUS.DEAN_SIGNED, ACADEMIC_STATUS.ACADEMICALLY_FINALIZED],
  // Going backwards past where a return would land.
  [ACADEMIC_STATUS.DEAN_SIGNED, ACADEMIC_STATUS.CLASS_TEACHER_REVIEW],
  [ACADEMIC_STATUS.ACADEMICALLY_FINALIZED, ACADEMIC_STATUS.CLASS_TEACHER_REVIEW],
  // Mutating a finalized or superseded report directly.
  [ACADEMIC_STATUS.ACADEMICALLY_FINALIZED, ACADEMIC_STATUS.GENERATED],
  [ACADEMIC_STATUS.SUPERSEDED, ACADEMIC_STATUS.CLASS_TEACHER_REVIEW],
  [ACADEMIC_STATUS.SUPERSEDED, ACADEMIC_STATUS.ACADEMICALLY_FINALIZED],
  // A no-op "transition" to the same status is not a transition.
  [ACADEMIC_STATUS.SUBMITTED_TO_DEAN, ACADEMIC_STATUS.SUBMITTED_TO_DEAN],
];
for (const [from, to] of invalidEdges) {
  test(`${from} -> ${to} is rejected`, () => {
    assert.equal(isValidTransition(from, to), false);
  });
}

console.log("\nresolveHeadteacherReturnTarget()");

test("academic content changed sends the report all the way back to the Class Teacher", () => {
  assert.equal(
    resolveHeadteacherReturnTarget({ academicContentChanged: true }),
    ACADEMIC_STATUS.CLASS_TEACHER_REVIEW
  );
});

test("only non-academic content changed sends the report back to the Dean only", () => {
  assert.equal(
    resolveHeadteacherReturnTarget({ academicContentChanged: false }),
    ACADEMIC_STATUS.SUBMITTED_TO_DEAN
  );
});

console.log("\nisDuplicateDecision() - idempotency guard");

test("an empty history is never a duplicate", () => {
  assert.equal(
    isDuplicateDecision({ approvalHistory: [], action: "dean.signed", actorUid: "deanA", reportVersion: 1 }),
    false
  );
});

test("the exact same actor+action+version repeated is a duplicate", () => {
  const history = [
    buildApprovalHistoryEntry({
      action: "dean.signed", actorUid: "deanA", actorRole: "deanOfStudies",
      actorDisplayName: "Dean A", reportVersion: 1, sourceHashReviewed: "abc",
      schoolId: "schoolA", serverTimestamp: null,
    }),
  ];
  assert.equal(
    isDuplicateDecision({ approvalHistory: history, action: "dean.signed", actorUid: "deanA", reportVersion: 1 }),
    true
  );
});

test("the same action on a new version after a correction is not a duplicate", () => {
  const history = [
    buildApprovalHistoryEntry({
      action: "dean.signed", actorUid: "deanA", actorRole: "deanOfStudies",
      actorDisplayName: "Dean A", reportVersion: 1, sourceHashReviewed: "abc",
      schoolId: "schoolA", serverTimestamp: null,
    }),
  ];
  assert.equal(
    isDuplicateDecision({ approvalHistory: history, action: "dean.signed", actorUid: "deanA", reportVersion: 2 }),
    false
  );
});

test("a different actor performing the same action is not a duplicate", () => {
  const history = [
    buildApprovalHistoryEntry({
      action: "headteacher.returned", actorUid: "htA", actorRole: "headTeacher",
      actorDisplayName: "HT A", reportVersion: 1, sourceHashReviewed: "abc",
      schoolId: "schoolA", serverTimestamp: null,
    }),
  ];
  assert.equal(
    isDuplicateDecision({ approvalHistory: history, action: "headteacher.returned", actorUid: "htB", reportVersion: 1 }),
    false
  );
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
