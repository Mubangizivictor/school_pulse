// Plain Node test runner, matching the convention in report_card_engine.test.js.
// Run with: node exam_factory_scheduling.test.js
const assert = require("node:assert/strict");
const { windowsOverlap, sittingEndTime } = require("./exam_factory_scheduling");

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

const t = (hhmm) => new Date(`2026-09-01T${hhmm}:00Z`);

test("identical windows overlap", () => {
  assert.equal(windowsOverlap(t("09:00"), t("10:30"), t("09:00"), t("10:30")), true);
});

test("fully nested window overlaps", () => {
  assert.equal(windowsOverlap(t("09:00"), t("12:00"), t("10:00"), t("10:30")), true);
});

test("partial overlap at the start is detected", () => {
  assert.equal(windowsOverlap(t("09:00"), t("10:30"), t("10:00"), t("11:00")), true);
});

test("partial overlap at the end is detected", () => {
  assert.equal(windowsOverlap(t("10:00"), t("11:00"), t("09:00"), t("10:30")), true);
});

test("back-to-back sittings (end == start) do NOT conflict", () => {
  assert.equal(windowsOverlap(t("09:00"), t("10:30"), t("10:30"), t("12:00")), false);
  assert.equal(windowsOverlap(t("10:30"), t("12:00"), t("09:00"), t("10:30")), false);
});

test("clearly separated windows do not conflict", () => {
  assert.equal(windowsOverlap(t("09:00"), t("10:00"), t("14:00"), t("15:00")), false);
});

test("sittingEndTime adds the duration in minutes", () => {
  const end = sittingEndTime(t("09:00"), 90);
  assert.equal(end.getTime(), t("10:30").getTime());
});

test("sittingEndTime defaults to 60 minutes for a missing/invalid duration", () => {
  assert.equal(sittingEndTime(t("09:00"), undefined).getTime(), t("10:00").getTime());
  assert.equal(sittingEndTime(t("09:00"), 0).getTime(), t("10:00").getTime());
  assert.equal(sittingEndTime(t("09:00"), null).getTime(), t("10:00").getTime());
});

console.log(`\n${passed} passed, ${failed} failed`);
if (failed > 0) process.exit(1);
