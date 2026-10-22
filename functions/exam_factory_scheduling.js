// Pure scheduling-conflict logic for Exam Factory sittings and invigilator
// assignments, extracted so it can be unit-tested without Admin SDK/
// Firestore - the two call sites in exam_factory_operations.js (venue
// double-booking, invigilator double-booking) both reduce to the same
// half-open interval overlap check.

/**
 * True when [startA, endA) and [startB, endB) intersect. Half-open so a
 * sitting ending exactly when another starts is NOT a conflict - back-to-
 * back exams in the same venue/with the same invigilator are allowed.
 */
function windowsOverlap(startA, endA, startB, endB) {
  return startA < endB && endA > startB;
}

/** endTime for a sitting given its start and duration in minutes. */
function sittingEndTime(startTime, durationMinutes) {
  return new Date(startTime.getTime() + Number(durationMinutes || 60) * 60000);
}

module.exports = { windowsOverlap, sittingEndTime };
