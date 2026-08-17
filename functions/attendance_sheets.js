/**
 * Attendance -> Google Sheets export.
 *
 * Firestore (via AttendanceRepository/AttendanceRemoteDataSource on the
 * client) remains the source of truth for attendance. This module only
 * mirrors confirmed attendance_records rows into a school's connected
 * Google Sheet for reporting/backup - it never reads attendance back out of
 * Sheets.
 *
 * Auth: each school connects its own Google account via the OAuth flow in
 * attendance_sheets_oauth.js. Tokens are never held here - every export
 * path asks getAuthorizedSheetsClient(schoolId) for a ready-to-use client.
 *
 * Idempotency: schools/{schoolId}/attendance_sheets_export_state/{recordId}
 * is a ledger doc created only after a record's row has been successfully
 * appended. Every export path (auto-sync trigger, Sync Now, Resync,
 * session export) checks this ledger before appending and writes it after
 * a successful append, so re-running any of them never duplicates rows.
 *
 * Flow: attendance_records/{id} onCreate -> look up the school's
 * SheetsIntegration config -> append one row (if not already ledgered) ->
 * record a SheetsSyncLogEntry + update lastSyncAt/lastSyncStatus.
 * Corrections never overwrite in place (attendance_records has no update
 * path - see firestore.rules), so this only ever appends, never edits
 * existing rows.
 */

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { getAuthorizedSheetsClient, HEADER_ROW } = require("./attendance_sheets_oauth");

const db = () => admin.firestore();

const APPEND_BATCH_SIZE = 500;
const RESYNC_DEFAULT_WINDOW_DAYS = 90;
const RETRY_DELAYS_MS = [500, 2000, 8000];

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function retryWithBackoff(fn) {
  let lastErr;
  for (let attempt = 0; attempt <= RETRY_DELAYS_MS.length; attempt += 1) {
    try {
      return await fn();
    } catch (err) {
      lastErr = err;
      const status = err.code || err.status || (err.response && err.response.status);
      const transient = status === 429 || (typeof status === "number" && status >= 500);
      if (!transient || attempt === RETRY_DELAYS_MS.length) throw err;
      await sleep(RETRY_DELAYS_MS[attempt]);
    }
  }
  throw lastErr;
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

function exportStateCollection(schoolId) {
  return db()
    .collection("schools")
    .doc(schoolId)
    .collection("attendance_sheets_export_state");
}

/**
 * Splits recordIds into already-exported vs. not-yet-exported, using the
 * ledger. Firestore getAll() is used instead of one get() per id to keep
 * this to a single round trip per chunk (chunked at 300 to stay well under
 * getAll's practical limits alongside other traffic).
 */
async function partitionByLedger(schoolId, recordIds) {
  const pending = [];
  const alreadyExported = [];
  const chunkSize = 300;
  for (let i = 0; i < recordIds.length; i += chunkSize) {
    const chunk = recordIds.slice(i, i + chunkSize);
    const refs = chunk.map((id) => exportStateCollection(schoolId).doc(id));
    const snaps = await db().getAll(...refs);
    snaps.forEach((snap, idx) => {
      if (snap.exists) alreadyExported.push(chunk[idx]);
      else pending.push(chunk[idx]);
    });
  }
  return { pending, alreadyExported };
}

async function markExported(schoolId, recordIds, spreadsheetId) {
  const chunkSize = 500;
  for (let i = 0; i < recordIds.length; i += chunkSize) {
    const chunk = recordIds.slice(i, i + chunkSize);
    const batch = db().batch();
    chunk.forEach((id) => {
      batch.set(exportStateCollection(schoolId).doc(id), {
        exportedAt: admin.firestore.FieldValue.serverTimestamp(),
        spreadsheetId,
      });
    });
    await batch.commit();
  }
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

async function appendRowBatches(sheets, spreadsheetId, worksheetName, rows) {
  await ensureWorksheet(sheets, spreadsheetId, worksheetName);
  for (let i = 0; i < rows.length; i += APPEND_BATCH_SIZE) {
    const batch = rows.slice(i, i + APPEND_BATCH_SIZE);
    await retryWithBackoff(() =>
      sheets.spreadsheets.values.append({
        spreadsheetId,
        range: `'${worksheetName}'!A1`,
        valueInputOption: "USER_ENTERED",
        insertDataOption: "INSERT_ROWS",
        requestBody: { values: batch },
      })
    );
  }
}

/**
 * Exports a set of {id, data} attendance records, skipping any already in
 * the ledger and marking the survivors as exported only after a
 * successful append - so a failed batch is safely retryable by simply
 * calling the exporting operation again.
 */
async function exportRecords(schoolId, spreadsheetId, worksheetName, records) {
  const { pending, alreadyExported } = await partitionByLedger(
    schoolId,
    records.map((r) => r.id)
  );
  if (pending.length === 0) {
    return { exported: 0, alreadyExported: alreadyExported.length };
  }
  const pendingSet = new Set(pending);
  const pendingRecords = records.filter((r) => pendingSet.has(r.id));
  const sheets = await getAuthorizedSheetsClient(schoolId);
  const rows = pendingRecords.map((r) => rowFor(r.data));
  await appendRowBatches(sheets, spreadsheetId, worksheetName, rows);
  await markExported(schoolId, pendingRecords.map((r) => r.id), spreadsheetId);
  return { exported: pendingRecords.length, alreadyExported: alreadyExported.length };
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

async function callerSchoolId(uid) {
  const callerDoc = await db().collection("users").doc(uid).get();
  const schoolId = callerDoc.exists ? callerDoc.data().schoolId : null;
  if (!schoolId) {
    throw new HttpsError("failed-precondition", "Your account is not assigned to a school.");
  }
  return schoolId;
}

function friendlyError(err) {
  if (err.code === "not_connected") {
    return new HttpsError("failed-precondition", "Connect Google Sheets first.", {
      reason: "not_connected",
    });
  }
  if (err.code === "needs_reauth") {
    return new HttpsError(
      "failed-precondition",
      "Google Sheets connection needs to be renewed.",
      { reason: "needs_reauth" }
    );
  }
  return new HttpsError(
    "internal",
    "Attendance is saved. Google Sheets will sync automatically when available.",
    { reason: "temporary" }
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
    const { schoolId, recordId } = event.params;
    const snap = event.data;
    if (!snap) return;
    const record = snap.data();

    const integration = await getIntegration(schoolId);
    if (!integration || !integration.linked || integration.autoSync === false) {
      return;
    }
    if (!integration.spreadsheetId) {
      return;
    }

    try {
      const result = await exportRecords(
        schoolId,
        integration.spreadsheetId,
        integration.worksheetName || "Attendance Records",
        [{ id: recordId, data: record }]
      );
      await logSyncResult(schoolId, { success: true, recordCount: result.exported });
    } catch (err) {
      console.error(`Sheets export failed for ${schoolId}/${recordId}:`, err);
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
 * a run of failed auto-syncs. Ledger-guarded, so re-running this never
 * duplicates rows the auto-sync trigger already exported. Bounded to today
 * only: a full historical backfill is what Resync (below) is for.
 */
exports.syncAttendanceToSheetsNow = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "You must be signed in.");
  const schoolId = await callerSchoolId(auth.uid);

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

  const records = recordsSnap.docs.map((doc) => ({ id: doc.id, data: doc.data() }));

  try {
    const result = await exportRecords(
      schoolId,
      integration.spreadsheetId,
      integration.worksheetName || "Attendance Records",
      records
    );
    await logSyncResult(schoolId, { success: true, recordCount: result.exported });
    return { recordCount: result.exported, alreadyExportedCount: result.alreadyExported };
  } catch (err) {
    await logSyncResult(schoolId, {
      success: false,
      recordCount: 0,
      errorMessage: err.message,
    });
    throw friendlyError(err);
  }
});

/**
 * Authorized administrative operation that safely reconstructs/updates a
 * school's Google Sheet from authoritative attendance history. Idempotent
 * via the same ledger as every other export path, and resumable: a batch
 * that fails is never marked exported, so a second call to this function
 * picks up exactly where the previous one left off. Defaults to the last
 * 90 days when no explicit range is supplied - a full all-time backfill
 * for a school with years of history could mean tens of thousands of rows
 * and is left to an explicit, deliberate date range instead.
 */
exports.resyncAttendanceToSheets = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "You must be signed in.");
  const schoolId = await callerSchoolId(auth.uid);

  const integration = await getIntegration(schoolId);
  if (!integration || !integration.linked || !integration.spreadsheetId) {
    throw new HttpsError("failed-precondition", "Connect a Google Sheet first.");
  }

  const now = new Date();
  const defaultStart = new Date(now.getTime() - RESYNC_DEFAULT_WINDOW_DAYS * 24 * 60 * 60 * 1000);
  const startDate = request.data?.startDate ? new Date(request.data.startDate) : defaultStart;
  const endDate = request.data?.endDate ? new Date(request.data.endDate) : now;

  let recordsScanned = 0;
  let recordsExported = 0;
  let recordsSkippedAlreadyExported = 0;
  let batches = 0;
  let cursor = null;
  const pageSize = 1000;

  try {
    // eslint-disable-next-line no-constant-condition
    while (true) {
      let query = db()
        .collection("schools")
        .doc(schoolId)
        .collection("attendance_records")
        .where("date", ">=", admin.firestore.Timestamp.fromDate(startDate))
        .where("date", "<=", admin.firestore.Timestamp.fromDate(endDate))
        .orderBy("date")
        .limit(pageSize);
      if (cursor) query = query.startAfter(cursor);

      const pageSnap = await query.get();
      if (pageSnap.empty) break;

      const records = pageSnap.docs.map((doc) => ({ id: doc.id, data: doc.data() }));
      recordsScanned += records.length;

      const result = await exportRecords(
        schoolId,
        integration.spreadsheetId,
        integration.worksheetName || "Attendance Records",
        records
      );
      recordsExported += result.exported;
      recordsSkippedAlreadyExported += result.alreadyExported;
      if (result.exported > 0) batches += 1;

      cursor = pageSnap.docs[pageSnap.docs.length - 1];
      if (pageSnap.docs.length < pageSize) break;
    }

    await logSyncResult(schoolId, { success: true, recordCount: recordsExported });
    await db()
      .collection("schools")
      .doc(schoolId)
      .collection("integration_logs")
      .add({
        institutionId: schoolId,
        integrationKey: "google_sheets",
        action: "resynced",
        actorId: auth.uid,
        metadata: { recordsExported, startDate: startDate.toISOString(), endDate: endDate.toISOString() },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    return { recordsScanned, recordsExported, recordsSkippedAlreadyExported, batches };
  } catch (err) {
    await logSyncResult(schoolId, {
      success: false,
      recordCount: recordsExported,
      errorMessage: err.message,
    });
    throw friendlyError(err);
  }
});

/**
 * Exports only the records for one Previous Attendance session, called from
 * AttendanceDetailScreen's Export action. The Flutter screen already holds
 * the full set of records for the session in memory, so it passes their ids
 * directly rather than this function re-deriving "session" server-side.
 */
exports.__test__ = { rowFor, retryWithBackoff, friendlyError };

exports.exportAttendanceSessionToSheets = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "You must be signed in.");
  const schoolId = await callerSchoolId(auth.uid);

  const recordIds = Array.isArray(request.data?.recordIds) ? request.data.recordIds : [];
  if (recordIds.length === 0) {
    throw new HttpsError("invalid-argument", "No records to export.");
  }

  const integration = await getIntegration(schoolId);
  if (!integration || !integration.linked || !integration.spreadsheetId) {
    throw new HttpsError("failed-precondition", "Connect a Google Sheet first.");
  }

  const chunkSize = 500;
  const records = [];
  for (let i = 0; i < recordIds.length; i += chunkSize) {
    const chunk = recordIds.slice(i, i + chunkSize);
    const refs = chunk.map((id) =>
      db().collection("schools").doc(schoolId).collection("attendance_records").doc(id)
    );
    const snaps = await db().getAll(...refs);
    snaps.forEach((snap) => {
      if (snap.exists) records.push({ id: snap.id, data: snap.data() });
    });
  }

  try {
    const result = await exportRecords(
      schoolId,
      integration.spreadsheetId,
      integration.worksheetName || "Attendance Records",
      records
    );
    await logSyncResult(schoolId, { success: true, recordCount: result.exported });
    await db()
      .collection("schools")
      .doc(schoolId)
      .collection("integration_logs")
      .add({
        institutionId: schoolId,
        integrationKey: "google_sheets",
        action: "session_exported",
        actorId: auth.uid,
        metadata: { recordCount: result.exported, sessionRecordIds: recordIds.slice(0, 50) },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    return { recordCount: result.exported, alreadyExportedCount: result.alreadyExported };
  } catch (err) {
    await logSyncResult(schoolId, {
      success: false,
      recordCount: 0,
      errorMessage: err.message,
    });
    throw friendlyError(err);
  }
});
