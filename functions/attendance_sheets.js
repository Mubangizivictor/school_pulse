/**
 * Attendance -> Google Sheets export.
 *
 * Firestore (via AttendanceRepository/AttendanceRemoteDataSource on the
 * client) remains the source of truth for attendance. This module only
 * mirrors confirmed attendance_records rows into a school's connected
 * Google Sheet for reporting/backup - it never reads attendance back out of
 * Sheets.
 *
 * Auth: a single Google service account (credentials in the
 * GOOGLE_SHEETS_SERVICE_ACCOUNT_JSON secret) shared across all schools. Each
 * school shares its spreadsheet with that service account's email once,
 * during setup (see sheets_integration_screen.dart), the same way any
 * third-party Sheets integration is granted access.
 *
 * Flow: attendance_records/{id} onCreate -> look up the school's
 * SheetsIntegration config -> append one row -> record a
 * SheetsSyncLogEntry + update lastSyncAt/lastSyncStatus. Corrections never
 * overwrite in place (attendance_records has no update path - see
 * firestore.rules), so this only ever appends, never edits existing rows.
 */

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { google } = require("googleapis");

const db = () => admin.firestore();

const HEADER_ROW = [
  "Date",
  "Category",
  "Scope",
  "Person",
  "Status",
  "Method",
  "Marked By",
  "Recorded At",
];

function sheetsAuth() {
  const raw = process.env.GOOGLE_SHEETS_SERVICE_ACCOUNT_JSON;
  if (!raw) {
    throw new Error(
      "Google Sheets service account is not configured - see functions/.env.example."
    );
  }
  const credentials = JSON.parse(raw);
  return new google.auth.GoogleAuth({
    credentials,
    scopes: ["https://www.googleapis.com/auth/spreadsheets"],
  });
}

async function sheetsClient() {
  const auth = sheetsAuth();
  return google.sheets({ version: "v4", auth });
}

function rowFor(record) {
  const date = record.date && record.date.toDate ? record.date.toDate() : null;
  const createdAt =
    record.createdAt && record.createdAt.toDate ? record.createdAt.toDate() : null;
  return [
    date ? date.toISOString().slice(0, 10) : "",
    record.category || "",
    record.scopeName || record.scopeId || "",
    record.personName || record.personId || "",
    record.status || "",
    record.method || "",
    record.markedBy || "",
    createdAt ? createdAt.toISOString() : "",
  ];
}

/**
 * Ensures the target worksheet exists (creating it if not) and carries a
 * header row - a school's very first export lands in a spreadsheet whose
 * only tab is the default "Sheet1", so this cannot assume the worksheet is
 * already there.
 */
async function ensureWorksheet(sheets, spreadsheetId, worksheetName) {
  const meta = await sheets.spreadsheets.get({ spreadsheetId });
  const existing = (meta.data.sheets || []).some(
    (s) => s.properties && s.properties.title === worksheetName
  );
  if (!existing) {
    await sheets.spreadsheets.batchUpdate({
      spreadsheetId,
      requestBody: {
        requests: [{ addSheet: { properties: { title: worksheetName } } }],
      },
    });
    await sheets.spreadsheets.values.update({
      spreadsheetId,
      range: `'${worksheetName}'!A1`,
      valueInputOption: "RAW",
      requestBody: { values: [HEADER_ROW] },
    });
  }
}

async function appendRows(spreadsheetId, worksheetName, rows) {
  const sheets = await sheetsClient();
  await ensureWorksheet(sheets, spreadsheetId, worksheetName);
  await sheets.spreadsheets.values.append({
    spreadsheetId,
    range: `'${worksheetName}'!A1`,
    valueInputOption: "USER_ENTERED",
    insertDataOption: "INSERT_ROWS",
    requestBody: { values: rows },
  });
}

async function getIntegration(schoolId) {
  const doc = await db()
    .collection("schools")
    .doc(schoolId)
    .collection("attendance_sheets_integration")
    .doc("config")
    .get();
  return doc.exists ? doc.data() : null;
}

async function logSyncResult(schoolId, { success, recordCount, errorMessage }) {
  const firestore = db();
  await firestore
    .collection("schools")
    .doc(schoolId)
    .collection("attendance_sheets_sync_log")
    .add({
      startedAt: admin.firestore.FieldValue.serverTimestamp(),
      success,
      recordCount,
      errorMessage: errorMessage || null,
    });
  await firestore
    .collection("schools")
    .doc(schoolId)
    .collection("attendance_sheets_integration")
    .doc("config")
    .set(
      {
        lastSyncAt: admin.firestore.FieldValue.serverTimestamp(),
        lastSyncStatus: success ? "success" : "failed",
      },
      { merge: true }
    );
}

/**
 * Fires once per confirmed attendance mark. Auto-sync only - a school that
 * hasn't linked a spreadsheet, or has turned autoSync off, is a no-op so
 * this never surprises anyone with an unexpected write to a personal sheet.
 */
exports.exportAttendanceRecordToSheets = onDocumentCreated(
  "schools/{schoolId}/attendance_records/{recordId}",
  async (event) => {
    const { schoolId } = event.params;
    const snap = event.data;
    if (!snap) return;
    const record = snap.data();

    const integration = await getIntegration(schoolId);
    if (!integration || !integration.linked || integration.autoSync === false) {
      return;
    }
    if (!integration.spreadsheetId) {
      // Linked in the UI but never actually granted a real spreadsheet id -
      // nothing to export to.
      return;
    }

    try {
      await appendRows(
        integration.spreadsheetId,
        integration.worksheetName || "Attendance Records",
        [rowFor(record)]
      );
      await logSyncResult(schoolId, { success: true, recordCount: 1 });
    } catch (err) {
      console.error(`Sheets export failed for ${schoolId}/${event.params.recordId}:`, err);
      await logSyncResult(schoolId, {
        success: false,
        recordCount: 0,
        errorMessage: err.message,
      });
    }
  }
);

/**
 * Callable used by the "Sync Now" button - re-exports today's records as a
 * manual catch-up, e.g. after reconnecting a spreadsheet or recovering from
 * a run of failed auto-syncs. Bounded to today only: a full historical
 * backfill is a much bigger operation (pagination, rate limits) that this
 * button was never meant to trigger.
 */
exports.syncAttendanceToSheetsNow = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "You must be signed in.");

  const callerDoc = await db().collection("users").doc(auth.uid).get();
  const schoolId = callerDoc.exists ? callerDoc.data().schoolId : null;
  if (!schoolId) {
    throw new HttpsError("failed-precondition", "Your account is not assigned to a school.");
  }

  const integration = await getIntegration(schoolId);
  if (!integration || !integration.linked) {
    throw new HttpsError("failed-precondition", "Connect a Google Sheet first.");
  }
  if (!integration.spreadsheetId) {
    throw new HttpsError(
      "failed-precondition",
      "This spreadsheet was linked without a spreadsheet id - reconnect it."
    );
  }

  const startOfDay = new Date();
  startOfDay.setHours(0, 0, 0, 0);

  const recordsSnap = await db()
    .collection("schools")
    .doc(schoolId)
    .collection("attendance_records")
    .where("date", ">=", admin.firestore.Timestamp.fromDate(startOfDay))
    .get();

  const rows = recordsSnap.docs.map((doc) => rowFor(doc.data()));

  try {
    if (rows.length > 0) {
      await appendRows(
        integration.spreadsheetId,
        integration.worksheetName || "Attendance Records",
        rows
      );
    }
    await logSyncResult(schoolId, { success: true, recordCount: rows.length });
    return { recordCount: rows.length };
  } catch (err) {
    await logSyncResult(schoolId, {
      success: false,
      recordCount: 0,
      errorMessage: err.message,
    });
    throw new HttpsError("internal", err.message || "Sync failed.");
  }
});
