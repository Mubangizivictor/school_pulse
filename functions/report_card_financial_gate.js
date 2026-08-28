/**
 * The automatic half of report-card financial access: keeps
 * financialAccessStatus in sync with a student's fee balance for the same
 * term, without ever overriding a Bursar's manual decision.
 *
 * Shared by index.js (report-card finalization) and student_fee_billing.js
 * (payments/adjustments/reversals that change a bill's balanceUgx) - kept in
 * its own module, rather than defined in index.js, so student_fee_billing.js
 * can require it without a circular dependency (index.js requires
 * student_fee_billing.js at module-load time, before any of index.js's own
 * function declarations exist yet).
 *
 * "Financially cleared" is a per-school configurable policy (full balance
 * zero / selected fee categories paid / minimum % paid) plus an active,
 * authorised report-card release exception. The policy engine and the
 * exception layer both live in report_card_release.js; this module lazily
 * requires it (report_card_release.js is Object.assign()-ed onto exports in
 * index.js AFTER this module, so a top-level require here would be circular).
 */
module.exports = ({ admin }) => {
  const db = admin.firestore();

  // Lazy handle to report_card_release.js's shared engine. Resolved on first
  // use, never at module-load (avoids the require cycle described above).
  let _release = null;
  const release = () => {
    if (!_release) {
      _release = require("./report_card_release")({ admin }).__internals;
    }
    return _release;
  };

  /**
   * Whether a student's fees for one term satisfy the school's configured
   * clearance policy. Delegates to the policy engine in
   * report_card_release.js. A term with no bill at all is deliberately NOT
   * treated as cleared - a report must never auto-release just because
   * billing was never set up for that term.
   */
  async function areTermFeesFullyPaid({ schoolId, studentId, academicYearId, termId }) {
    const { cleared } = await release().computeFinancialClearance({
      schoolId,
      studentId,
      academicYearId,
      termId,
    });
    return cleared;
  }

  /**
   * Keeps financialAccessStatus in sync for every finalized report in a
   * period, from the configured clearance policy AND any active authorised
   * release exception. A report the Bursar has manually released/held/
   * revoked (financialAccessSource === "bursar") is never touched here - a
   * human override always wins until a Bursar changes it again via
   * setReportCardFinancialAccess. Notifies linked parents when a previously
   * withheld report becomes available.
   *
   * Called after headteacher finalization and after any payment/adjustment/
   * reversal that changes a bill's balanceUgx.
   */
  async function maybeAutoUpdateReportCardFinancialAccess({ schoolId, studentId, academicYearId, termId }) {
    await release().syncPeriodReportAccess({
      schoolId,
      studentId,
      academicYearId,
      termId,
      source: "auto",
      reason: null,
      exceptionId: null,
      caller: null,
    });
  }

  return { areTermFeesFullyPaid, maybeAutoUpdateReportCardFinancialAccess };
};
