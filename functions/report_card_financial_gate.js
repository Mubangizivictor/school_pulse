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
 */
module.exports = ({ admin }) => {
  const db = admin.firestore();

  /**
   * Whether a student's fees for one term are fully settled. "Fully paid"
   * means every bill issued to this student for this exact
   * academicYearId+termId has balanceUgx <= 0. A term with no bill at all is
   * deliberately NOT treated as paid - a report must never auto-release just
   * because billing was never set up for that term.
   */
  async function areTermFeesFullyPaid({ schoolId, studentId, academicYearId, termId }) {
    const billsSnap = await db
      .collection(`schools/${schoolId}/student_accounts/${studentId}/bills`)
      .where("academicYearId", "==", academicYearId)
      .where("termId", "==", termId)
      .get();
    if (billsSnap.empty) return false;
    return billsSnap.docs.every((doc) => Number(doc.data().balanceUgx || 0) <= 0);
  }

  /**
   * Keeps financialAccessStatus in sync with fee payment for every finalized
   * report still under automatic control (financialAccessSource === "auto").
   * A report the Bursar has manually released/held/revoked
   * (financialAccessSource === "bursar") is never touched here - a human
   * override always wins over the automatic fee check until a Bursar changes
   * it again via setReportCardFinancialAccess.
   *
   * Called after headteacher finalization (a fresh report, decide its
   * opening state) and after any payment/adjustment/reversal that changes a
   * bill's balanceUgx (an already-finalized report may need to flip either
   * way).
   */
  async function maybeAutoUpdateReportCardFinancialAccess({ schoolId, studentId, academicYearId, termId }) {
    const reportsSnap = await db
      .collection(`schools/${schoolId}/reportCards`)
      .where("studentId", "==", studentId)
      .where("academicYearId", "==", academicYearId)
      .where("termId", "==", termId)
      .where("isFinalized", "==", true)
      .get();
    if (reportsSnap.empty) return;

    const fullyPaid = await areTermFeesFullyPaid({ schoolId, studentId, academicYearId, termId });
    const targetStatus = fullyPaid ? "released" : "held";

    await Promise.all(reportsSnap.docs.map(async (doc) => {
      const data = doc.data();
      if (data.financialAccessSource === "bursar") return; // human override, never auto-touched
      if (data.financialAccessStatus === targetStatus) return; // already correct, avoid a no-op write
      await doc.ref.update({
        financialAccessStatus: targetStatus,
        financialAccessSource: "auto",
        financialAccessUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        financialAccessUpdatedBy: null,
        financialAccessReason: fullyPaid
          ? "Automatically released: term fees fully paid."
          : "Automatically held: term fees balance outstanding.",
      });
    }));
  }

  return { areTermFeesFullyPaid, maybeAutoUpdateReportCardFinancialAccess };
};
