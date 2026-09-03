// Pure-logic unit tests for functions/academic_calendar_billing.js's
// server-side term validation (the re-implementation of
// StructureValidationService's overlap/range checks that
// confirmAcademicCalendar runs before confirming/generating cycles).
// Does NOT require the Firebase emulator - _validateTerms is exported
// specifically so this logic can be exercised without auth/Firestore
// plumbing. Auth, cross-tenant denial, idempotent generation, and
// per-school date derivation are covered separately in
// test/academic_calendar_billing.emulator.test.cjs (requires JDK 21 +
// firebase emulators, see that file's header).
const test = require("node:test");
const assert = require("node:assert/strict");
const { _validateTerms } = require("./academic_calendar_billing");

function term(overrides) {
  return {
    id: "t1",
    name: "Term 1",
    order: 1,
    academicYearId: "y1",
    startDate: new Date("2026-01-10"),
    endDate: new Date("2026-04-10"),
    isArchived: false,
    ...overrides,
  };
}

const year = { id: "y1", startDate: new Date("2026-01-01"), endDate: new Date("2026-12-15") };
const yearsById = new Map([["y1", year]]);

test("valid, non-overlapping terms within year range produce no errors", () => {
  const terms = [
    term({ id: "t1", order: 1, startDate: new Date("2026-01-10"), endDate: new Date("2026-04-10") }),
    term({ id: "t2", order: 2, startDate: new Date("2026-05-01"), endDate: new Date("2026-08-10") }),
  ];
  assert.deepEqual(_validateTerms(terms, yearsById), []);
});

test("overlapping terms are rejected", () => {
  const terms = [
    term({ id: "t1", order: 1, startDate: new Date("2026-01-10"), endDate: new Date("2026-04-10") }),
    term({ id: "t2", order: 2, startDate: new Date("2026-03-01"), endDate: new Date("2026-08-10") }),
  ];
  const errors = _validateTerms(terms, yearsById);
  assert(errors.some((e) => e.includes("overlaps")));
});

test("end date before start date is rejected", () => {
  const terms = [term({ startDate: new Date("2026-04-10"), endDate: new Date("2026-01-10") })];
  const errors = _validateTerms(terms, yearsById);
  assert(errors.some((e) => e.includes("end date must be after")));
});

test("duplicate term order/number within the same year is rejected", () => {
  const terms = [
    term({ id: "t1", order: 1, startDate: new Date("2026-01-10"), endDate: new Date("2026-02-10") }),
    term({ id: "t2", order: 1, startDate: new Date("2026-03-10"), endDate: new Date("2026-04-10") }),
  ];
  const errors = _validateTerms(terms, yearsById);
  assert(errors.some((e) => e.includes("Duplicate term order")));
});

test("term dates outside its academic year's range are rejected", () => {
  const terms = [term({ startDate: new Date("2025-12-01"), endDate: new Date("2026-04-10") })];
  const errors = _validateTerms(terms, yearsById);
  assert(errors.some((e) => e.includes("outside its academic year's range")));
});

test("term referencing a nonexistent academic year is rejected", () => {
  const terms = [term({ academicYearId: "missing" })];
  const errors = _validateTerms(terms, yearsById);
  assert(errors.some((e) => e.includes("no longer exists")));
});

test("archived terms are excluded from overlap/order checks", () => {
  const terms = [
    term({ id: "t1", order: 1, startDate: new Date("2026-01-10"), endDate: new Date("2026-04-10") }),
    term({ id: "t2", order: 1, isArchived: true, startDate: new Date("2026-01-10"), endDate: new Date("2026-04-10") }),
  ];
  assert.deepEqual(_validateTerms(terms, yearsById), []);
});
