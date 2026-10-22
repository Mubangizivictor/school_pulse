// Firebase Emulator integration test for the Report Card Engine.
// Run with: npm run test:report-card-engine (wraps this in
// `firebase emulators:exec --only firestore`, matching test:rules'
// convention). Uses the Admin SDK directly (bypasses Firestore rules,
// exactly as the real Cloud Function does), and exercises the actual
// exported orchestration function via index.js's __test__ hook rather than
// re-implementing the read/aggregate/write pipeline in the test itself.
const { after, before, beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-report-card-engine-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });

// index.js is required AFTER the emulator env vars are set, so
// admin.initializeApp() (which runs at module load) binds to the emulator.
const functions = require("../index.js");
const { generateClassReportCardsInternal } = functions.__test__;
const admin = require("firebase-admin");

const db = admin.firestore();

async function clearFirestore() {
  const collections = await db.listCollections();
  await Promise.all(collections.map((c) => deleteCollectionRecursive(c)));
}

// listDocuments() (not get()/query) is required here: a document reached
// only through a nested collection write (e.g. schools/schoolA, which this
// suite never .set() directly) has subcollections but is not itself
// returned by a query against its parent collection - Firestore's
// "phantom document" behaviour. Enumerating by listCollections/
// listDocuments walks the real document tree regardless.
async function deleteCollectionRecursive(collectionRef) {
  const docRefs = await collectionRef.listDocuments();
  await Promise.all(
    docRefs.map(async (docRef) => {
      const subcollections = await docRef.listCollections();
      await Promise.all(subcollections.map((c) => deleteCollectionRecursive(c)));
      await docRef.delete();
    })
  );
}

const SCHOOL_A = "schoolA";
const OTHER_SCHOOL = "schoolB";

function assessmentDoc({ id, subjectId, classId, status = "approved", components }) {
  return db
    .collection("schools")
    .doc(SCHOOL_A)
    .collection("subject_assessments")
    .doc(id)
    .set({
      subjectId,
      classId,
      academicYearId: "2026",
      termId: "t2",
      status,
      title: id,
      maximumMark: 100,
      components,
    });
}

function markDoc({ id, assessmentId, componentId, studentId, subjectId, classId, score, entryStatus, markStatus }) {
  return db
    .collection("schools")
    .doc(SCHOOL_A)
    .collection("student_marks")
    .doc(id)
    .set({
      schoolId: SCHOOL_A,
      assessmentId,
      componentId,
      studentId,
      subjectId,
      classId,
      academicYearId: "2026",
      termId: "t2",
      score: score ?? null,
      entryStatus,
      maximumMark: 100,
      markStatus,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}

function classReportEntryDoc({ id, studentId, studentName }) {
  return db
    .collection("schools")
    .doc(SCHOOL_A)
    .collection("class_report_entries")
    .doc(id)
    .set({
      schoolId: SCHOOL_A,
      classId: "p7",
      academicYearId: "2026",
      termId: "t2",
      studentId,
      studentName,
      status: "class_teacher_completed",
    });
}

async function seedGradingSystem() {
  await db.collection("structure_grading_systems").doc("gsA").set({
    schoolId: SCHOOL_A,
    name: "Standard",
    isActive: true,
    isDefault: true,
    version: 1,
  });
  const bands = [
    { grade: "D1", minScore: 90, maxScore: 100, order: 1, gradePoint: 1, isPassing: true },
    { grade: "C3", minScore: 70, maxScore: 89.999, order: 2, gradePoint: 3, isPassing: true },
    { grade: "P7", minScore: 40, maxScore: 69.999, order: 3, gradePoint: 7, isPassing: true },
    { grade: "F9", minScore: 0, maxScore: 39.999, order: 4, gradePoint: 9, isPassing: false },
  ];
  await Promise.all(
    bands.map((b, i) =>
      db
        .collection("grade_bands")
        .doc(`bandA${i}`)
        .set({ ...b, schoolId: SCHOOL_A, gradingSystemId: "gsA" })
    )
  );
}

async function seedBaseClass() {
  // Two subjects, single-component assessments, weight 100 each - the
  // shape createAssessment() actually writes today.
  await Promise.all([
    assessmentDoc({
      id: "mathExam",
      subjectId: "math",
      classId: "p7",
      components: [{ id: "mathExam", name: "Exam", maximumMark: 100, weight: 100 }],
    }),
    assessmentDoc({
      id: "englishExam",
      subjectId: "english",
      classId: "p7",
      components: [{ id: "englishExam", name: "Exam", maximumMark: 100, weight: 100 }],
    }),
  ]);

  // studentComplete: full marks in both subjects, scores tied with studentTiedPeer.
  await Promise.all([
    markDoc({ id: "m1", assessmentId: "mathExam", componentId: "mathExam", studentId: "studentComplete", subjectId: "math", classId: "p7", score: 80, entryStatus: "scored", markStatus: "approved" }),
    markDoc({ id: "m2", assessmentId: "englishExam", componentId: "englishExam", studentId: "studentComplete", subjectId: "english", classId: "p7", score: 80, entryStatus: "scored", markStatus: "approved" }),

    // studentTiedPeer: identical average to studentComplete -> a tie.
    markDoc({ id: "m3", assessmentId: "mathExam", componentId: "mathExam", studentId: "studentTiedPeer", subjectId: "math", classId: "p7", score: 90, entryStatus: "scored", markStatus: "approved" }),
    markDoc({ id: "m4", assessmentId: "englishExam", componentId: "englishExam", studentId: "studentTiedPeer", subjectId: "english", classId: "p7", score: 70, entryStatus: "scored", markStatus: "approved" }),

    // studentAbsent: absent in one subject - must not be zeroed, must not be ranked.
    markDoc({ id: "m5", assessmentId: "mathExam", componentId: "mathExam", studentId: "studentAbsent", subjectId: "math", classId: "p7", score: 95, entryStatus: "scored", markStatus: "approved" }),
    markDoc({ id: "m6", assessmentId: "englishExam", componentId: "englishExam", studentId: "studentAbsent", subjectId: "english", classId: "p7", score: null, entryStatus: "absent", markStatus: "approved" }),

    // studentIncomplete: only one subject has any marks at all - other subject missing entirely.
    markDoc({ id: "m7", assessmentId: "mathExam", componentId: "mathExam", studentId: "studentIncomplete", subjectId: "math", classId: "p7", score: 50, entryStatus: "scored", markStatus: "approved" }),

    // studentUnapprovedOnly: marks exist but are still 'submitted', not approved - must not appear at all.
    markDoc({ id: "m8", assessmentId: "mathExam", componentId: "mathExam", studentId: "studentUnapprovedOnly", subjectId: "math", classId: "p7", score: 60, entryStatus: "scored", markStatus: "submitted" }),
  ]);

  await Promise.all([
    classReportEntryDoc({ id: "eComplete", studentId: "studentComplete", studentName: "Complete Student" }),
    classReportEntryDoc({ id: "eTiedPeer", studentId: "studentTiedPeer", studentName: "Tied Peer" }),
    classReportEntryDoc({ id: "eAbsent", studentId: "studentAbsent", studentName: "Absent Student" }),
    classReportEntryDoc({ id: "eIncomplete", studentId: "studentIncomplete", studentName: "Incomplete Student" }),
    classReportEntryDoc({ id: "eUnapproved", studentId: "studentUnapprovedOnly", studentName: "Unapproved Only" }),
  ]);
}

async function generate(overrides = {}) {
  return generateClassReportCardsInternal({
    schoolId: SCHOOL_A,
    classId: "p7",
    streamId: null,
    academicYearId: "2026",
    termId: "t2",
    studentIds: null,
    actorUid: "deanA",
    ...overrides,
  });
}

async function reportCardsFor(studentId) {
  const snap = await db
    .collection("schools")
    .doc(SCHOOL_A)
    .collection("reportCards")
    .where("studentId", "==", studentId)
    .get();
  return snap.docs.map((d) => d.data());
}

before(async () => {
  await clearFirestore();
});

beforeEach(async () => {
  await clearFirestore();
  await seedGradingSystem();
  await seedBaseClass();
});

after(async () => {
  await clearFirestore();
});

// Node's test runner runs sibling tests concurrently by default; these
// tests share one Firestore emulator instance cleared in beforeEach, so
// they must run one at a time or they corrupt each other's state.
describe("Report Card Engine - emulator scenario", { concurrency: 1 }, () => {
  test("multiple subjects, one absent mark, one incomplete learner, two tied learners all resolve correctly", async () => {
    const result = await generate();

    assert.equal(result.configurationErrors.length, 0);
    // studentComplete, studentTiedPeer, studentAbsent, studentIncomplete all get a
    // snapshot (they have at least one approved mark); studentUnapprovedOnly does not
    // (only a 'submitted' mark, never approved, so no report at all is generated for them).
    const createdIds = result.created.map((c) => c.studentId).sort();
    assert.deepEqual(createdIds, [
      "studentAbsent",
      "studentComplete",
      "studentIncomplete",
      "studentTiedPeer",
    ]);

    const [complete] = await reportCardsFor("studentComplete");
    assert.equal(complete.average, 80);
    assert.equal(complete.overallGrade, "C3");
    assert.equal(complete.isRanked, true);

    const [tiedPeer] = await reportCardsFor("studentTiedPeer");
    assert.equal(tiedPeer.average, 80);
    assert.equal(tiedPeer.isRanked, true);
    // Tied average -> tied position (competition ranking).
    assert.equal(tiedPeer.position, complete.position);

    const [absent] = await reportCardsFor("studentAbsent");
    assert.equal(absent.isRanked, false, "an absent-subject learner must not be ranked");
    assert.equal(absent.subjectResults.find((s) => s.subjectId === "english").incompleteReason, "absent");
    // The subject's numeric field must exist for the scored component but
    // the subject as a whole is still marked incomplete.
    assert.equal(absent.subjectResults.find((s) => s.subjectId === "math").average, 95);

    const [incomplete] = await reportCardsFor("studentIncomplete");
    assert.equal(incomplete.isRanked, false, "a learner missing an entire subject must not be ranked");
    // Both class subjects are represented - the one never entered at all
    // still shows up as its own incomplete subject, rather than vanishing.
    assert.equal(incomplete.subjectResults.length, 2);
    assert.equal(incomplete.subjectResults.find((s) => s.subjectId === "english").incompleteReason, "no_marks");
    assert.equal(incomplete.subjectResults.find((s) => s.subjectId === "math").average, 50);

    const unapproved = await reportCardsFor("studentUnapprovedOnly");
    assert.equal(unapproved.length, 0, "a student with only a submitted (unapproved) mark gets no report at all");
  });

  test("invoking generation twice with unchanged source data creates no duplicates and does not bump version", async () => {
    const first = await generate();
    assert.ok(first.created.length > 0);

    const second = await generate();
    assert.equal(second.created.length, 0, "nothing should be (re)created the second time");
    assert.equal(second.unchanged.length, first.created.length, "every previously created report should now read as unchanged");

    const [complete] = await reportCardsFor("studentComplete");
    assert.equal(complete.version, 1, "version must not increment when source data has not changed");
  });

  test("changing an approved mark's score changes the hash and produces a new version, without duplicating the document", async () => {
    await generate();
    const [before1] = await reportCardsFor("studentComplete");
    assert.equal(before1.version, 1);

    // Simulate a correction workflow re-approving a changed mark.
    await markDoc({ id: "m1", assessmentId: "mathExam", componentId: "mathExam", studentId: "studentComplete", subjectId: "math", classId: "p7", score: 100, entryStatus: "scored", markStatus: "approved" });

    const result = await generate();
    const updatedForComplete = result.created.find((c) => c.studentId === "studentComplete");
    assert.ok(updatedForComplete, "a changed source hash must produce a new (updated) generation entry");
    assert.equal(updatedForComplete.version, 2, "version must increment exactly once for the changed learner");

    const after1 = await reportCardsFor("studentComplete");
    assert.equal(after1.length, 1, "the same reportCardId must be reused - no duplicate document");
    assert.equal(after1[0].version, 2);
    assert.equal(after1[0].average, 90);
  });

  test("a finalized report is never overwritten by a later generation run", async () => {
    await generate();
    const [reportCard] = await reportCardsFor("studentComplete");
    await db
      .collection("schools")
      .doc(SCHOOL_A)
      .collection("reportCards")
      .doc(reportCard.reportCardId)
      .update({ isFinalized: true });

    await markDoc({ id: "m1", assessmentId: "mathExam", componentId: "mathExam", studentId: "studentComplete", subjectId: "math", classId: "p7", score: 10, entryStatus: "scored", markStatus: "approved" });

    const result = await generate();
    const skippedEntry = result.skipped.find((s) => s.studentId === "studentComplete");
    assert.ok(skippedEntry, "a finalized report must be skipped, not silently regenerated");
    assert.equal(skippedEntry.reason, "already_finalized");

    const [stillFinalized] = await reportCardsFor("studentComplete");
    assert.equal(stillFinalized.average, 80, "the finalized snapshot's values must not change");
  });

  test("tenant isolation: a school's grading configuration and marks never leak into another school's generation", async () => {
    await db.collection("structure_grading_systems").doc("gsB").set({
      schoolId: OTHER_SCHOOL, name: "Other", isActive: true, isDefault: true, version: 9,
    });
    await db.collection("schools").doc(OTHER_SCHOOL).collection("class_report_entries").doc("eOther").set({
      schoolId: OTHER_SCHOOL, classId: "p7", academicYearId: "2026", termId: "t2",
      studentId: "studentOtherSchool", studentName: "Other School Student", status: "class_teacher_completed",
    });

    const result = await generate({ schoolId: OTHER_SCHOOL });
    // No assessments/marks exist for schoolB's p7/2026/t2, so nothing should
    // be created despite the class_report_entries row existing.
    assert.equal(result.created.length, 0);

    const otherReports = await db.collection("schools").doc(OTHER_SCHOOL).collection("reportCards").get();
    assert.equal(otherReports.size, 0);
  });

  test("overlapping grade bands are rejected before any report is written", async () => {
    await db.collection("grade_bands").doc("overlapBand").set({
      schoolId: SCHOOL_A, gradingSystemId: "gsA", grade: "BONUS", minScore: 60, maxScore: 95, order: 5,
    });

    const result = await generate();
    assert.ok(result.configurationErrors.length > 0);
    assert.equal(result.created.length, 0, "no report should be written while the grading configuration is invalid");

    const anyReports = await db.collection("schools").doc(SCHOOL_A).collection("reportCards").get();
    assert.equal(anyReports.size, 0);
  });
});
