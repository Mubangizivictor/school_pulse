// Pure-logic unit tests for functions/student_pricing_bands.js's
// band-matching, overlap/gap/shape validation. Does NOT require the
// Firebase emulator - mirrors functions/academic_calendar_billing.test.js's
// style, exercising the exported _internal helpers directly with plain JS
// objects instead of real Firestore docs.
const test = require("node:test");
const assert = require("node:assert/strict");
const { HttpsError } = require("firebase-functions/v2/https");
const {
  validateBandShape,
  assertNoOverlap,
  rangesOverlap,
  findGaps,
  bandCoversCount,
} = require("./student_pricing_bands")._internal;

function band(overrides) {
  return {
    id: "b1",
    minStudents: 1,
    maxStudents: 300,
    amountUgx: 500000,
    isActive: true,
    effectiveFrom: new Date("2026-01-01"),
    effectiveTo: null,
    ...overrides,
  };
}

test("bandCoversCount: boundary values map to the correct band (300 vs 301)", () => {
  const bandA = band({ id: "a", minStudents: 1, maxStudents: 300 });
  const bandB = band({ id: "b", minStudents: 301, maxStudents: 500 });
  const now = new Date("2026-06-01");

  assert.equal(bandCoversCount(bandA, 300, now), true);
  assert.equal(bandCoversCount(bandB, 300, now), false);
  assert.equal(bandCoversCount(bandA, 301, now), false);
  assert.equal(bandCoversCount(bandB, 301, now), true);
});

test("bandCoversCount: 300 students -> 1-300 band, 500 -> 301-500 band", () => {
  const bandA = band({ id: "a", minStudents: 1, maxStudents: 300 });
  const bandB = band({ id: "b", minStudents: 301, maxStudents: 500 });
  const now = new Date("2026-06-01");
  const matchesFor = (count) => [bandA, bandB].filter((b) => bandCoversCount(b, count, now));

  assert.deepEqual(matchesFor(300).map((b) => b.id), ["a"]);
  assert.deepEqual(matchesFor(500).map((b) => b.id), ["b"]);
});

test("bandCoversCount: unbounded final band (maxStudents: null) covers any count above min", () => {
  const unbounded = band({ id: "u", minStudents: 1001, maxStudents: null });
  const now = new Date("2026-06-01");
  assert.equal(bandCoversCount(unbounded, 1001, now), true);
  assert.equal(bandCoversCount(unbounded, 999999, now), true);
  assert.equal(bandCoversCount(unbounded, 1000, now), false);
});

test("bandCoversCount: respects effectiveFrom/effectiveTo window", () => {
  const future = band({ effectiveFrom: new Date("2027-01-01") });
  const expired = band({ effectiveFrom: new Date("2025-01-01"), effectiveTo: new Date("2025-06-01") });
  const now = new Date("2026-06-01");
  assert.equal(bandCoversCount(future, 100, now), false);
  assert.equal(bandCoversCount(expired, 100, now), false);
});

test("validateBandShape: rejects non-integer/negative amountUgx", () => {
  assert.throws(() => validateBandShape({ minStudents: 0, maxStudents: 100, amountUgx: 0 }), HttpsError);
  assert.throws(() => validateBandShape({ minStudents: 0, maxStudents: 100, amountUgx: -5 }), HttpsError);
  assert.throws(() => validateBandShape({ minStudents: 0, maxStudents: 100, amountUgx: 100.5 }), HttpsError);
});

test("validateBandShape: rejects negative minStudents and maxStudents < minStudents", () => {
  assert.throws(() => validateBandShape({ minStudents: -1, maxStudents: 100, amountUgx: 1000 }), HttpsError);
  assert.throws(() => validateBandShape({ minStudents: 500, maxStudents: 100, amountUgx: 1000 }), HttpsError);
});

test("validateBandShape: accepts a valid unbounded band", () => {
  assert.doesNotThrow(() => validateBandShape({ minStudents: 1001, maxStudents: null, amountUgx: 2000000 }));
});

test("rangesOverlap: detects overlap including unbounded ranges", () => {
  assert.equal(rangesOverlap({ minStudents: 1, maxStudents: 300 }, { minStudents: 300, maxStudents: 500 }), true);
  assert.equal(rangesOverlap({ minStudents: 1, maxStudents: 300 }, { minStudents: 301, maxStudents: 500 }), false);
  assert.equal(rangesOverlap({ minStudents: 1, maxStudents: 300 }, { minStudents: 200, maxStudents: null }), true);
});

test("assertNoOverlap: rejects an overlapping candidate against active bands", () => {
  const active = [band({ id: "a", minStudents: 1, maxStudents: 300 })];
  assert.throws(
    () => assertNoOverlap({ minStudents: 250, maxStudents: 400 }, active, null),
    HttpsError
  );
});

test("assertNoOverlap: rejects an exact duplicate range", () => {
  const active = [band({ id: "a", minStudents: 1, maxStudents: 300 })];
  assert.throws(
    () => assertNoOverlap({ minStudents: 1, maxStudents: 300 }, active, null),
    HttpsError
  );
});

test("assertNoOverlap: allows a non-overlapping candidate", () => {
  const active = [band({ id: "a", minStudents: 1, maxStudents: 300 })];
  assert.doesNotThrow(() => assertNoOverlap({ minStudents: 301, maxStudents: 500 }, active, null));
});

test("assertNoOverlap: excludeId lets an update pass against its own unchanged range", () => {
  const active = [band({ id: "a", minStudents: 1, maxStudents: 300 })];
  assert.doesNotThrow(() => assertNoOverlap({ minStudents: 1, maxStudents: 300 }, active, "a"));
});

test("findGaps: detects a gap between two active bands", () => {
  const active = [
    band({ id: "a", minStudents: 0, maxStudents: 300 }),
    band({ id: "b", minStudents: 500, maxStudents: 1000 }),
  ];
  const gaps = findGaps(active);
  assert.deepEqual(gaps, [[301, 499], [1001, null]]);
});

test("findGaps: no gaps when bands are contiguous and end unbounded", () => {
  const active = [
    band({ id: "a", minStudents: 0, maxStudents: 300 }),
    band({ id: "b", minStudents: 301, maxStudents: null }),
  ];
  assert.deepEqual(findGaps(active), []);
});

test("findGaps: entire range is a gap when no bands are configured", () => {
  assert.deepEqual(findGaps([]), [[0, null]]);
});

test("findGaps: gap starting from 0 when first band doesn't start at 0", () => {
  const active = [band({ id: "a", minStudents: 50, maxStudents: null })];
  assert.deepEqual(findGaps(active), [[0, 49]]);
});
