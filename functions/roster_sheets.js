/**
 * Student roster/identity -> Google Sheets export.
 *
 * Manual-only (an admin explicitly triggers "Export roster to Sheets") -
 * unlike attendance_sheets.js, there is no onCreate/onUpdate auto-sync
 * trigger here. A roster export is a snapshot, not a live feed, and
 * students/identities change far less often and in less export-worthy ways
 * than attendance marks - triggering a Sheets write on every student edit
 * would be noisy churn for no real benefit.
 *
 * Auth: reuses the exact same per-school Google Sheets OAuth connection as
 * attendance_sheets.js (attendance_sheets_oauth.js's getAuthorizedSheetsClient)
 * - one Google account connection per school, one spreadsheet, a second
 * worksheet tab ("Student Roster") added to it. No second OAuth flow, no
 * second spreadsheet to manage.
 *
 * Security: only nfcStatus/qrCredentialStatus/issuedAt are ever exported
 * from StudentIdentity - never the raw qrCodeData token, uniqueSystemId,
 * or an NFC card UID. Same rule this app already enforces in the Identity
 * tab and ID card preview UI (never render/export a raw credential value).
 */

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { getAuthorizedSheetsClient } = require("./attendance_sheets_oauth");

const db = () => admin.firestore();

const WORKSHEET_NAME = "Student Roster";
const APPEND_BATCH_SIZE = 500;
const RETRY_DELAYS_MS = [500, 2000, 8000];
const CONNECT_ROLES = new Set(["schoolAdmin", "director", "headTeacher", "deputyHead"]);

const HEADER_ROW = [
  "Student No.",
  "Admission No.",
  "Name",
  "Class",
  "Status",
  "NFC Status",
  "QR Credential Status",
  "Issued",
];

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

async function callerContext(request) {
  if (!request.auth) throw new HttpsError("unauthenticated", "You must be signed in.");
  const userDoc = await db().collection("users").doc(request.auth.uid).get();
  if (!userDoc.exists) {
    throw new HttpsError("failed-precondition", "Your account is not assigned to a school.");
  }
  const data = userDoc.data();
  const schoolId = data.schoolId;
  if (!schoolId) {
    throw new HttpsError("failed-precondition", "Your account is not assigned to a school.");
  }
  const roles = [data.role, ...(Array.isArray(data.roles) ? data.roles : [])];
  if (!roles.some((role) => CONNECT_ROLES.has(role))) {
    throw new HttpsError(
      "permission-denied",
      "Only a school admin can export the roster to Google Sheets."
    );
  }
  return { uid: request.auth.uid, schoolId };
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

/**
 * Ensures the "Student Roster" worksheet exists on the school's already-
 * connected spreadsheet (shared with attendance_sheets.js), carrying its
 * own header row - independent of whatever tabs attendance has created.
 */
async function ensureWorksheet(sheets, spreadsheetId) {
  const meta = await sheets.spreadsheets.get({ spreadsheetId });
  const existing = (meta.data.sheets || []).some(
    (s) => s.properties && s.properties.title === WORKSHEET_NAME
  );
  if (!existing) {
    await sheets.spreadsheets.batchUpdate({
      spreadsheetId,
      requestBody: {
        requests: [{ addSheet: { properties: { title: WORKSHEET_NAME } } }],
      },
    });
  }
  // Always rewrite the header row (not just on creation) so a stale export
  // from before a header change stays consistent - the roster export
  // replaces its own tab wholesale each run rather than appending forever
  // (see exportStudentRosterToSheets), so this is cheap and always correct.
  await sheets.spreadsheets.values.update({
    spreadsheetId,
    range: `'${WORKSHEET_NAME}'!A1`,
    valueInputOption: "RAW",
    requestBody: { values: [HEADER_ROW] },
  });
}

function formatDate(timestampOrNull) {
  if (!timestampOrNull) return "";
  const date = timestampOrNull.toDate ? timestampOrNull.toDate() : new Date(timestampOrNull);
  return date.toISOString().slice(0, 10);
}

function rowFor(student, identity, className) {
  const readableNumber = student.admissionNumber || student.studentCode || "";
  return [
    student.studentCode || "",
    readableNumber,
    student.name || "",
    className || "",
    student.status || "",
    identity ? identity.nfcStatus || "unassigned" : "not issued",
    identity ? identity.qrCredentialStatus || "active" : "not issued",
    identity ? formatDate(identity.issuedAt) : "",
  ];
}

/**
 * Exports the school's current student roster as a full snapshot: clears
 * the "Student Roster" tab's data rows and rewrites them from scratch. A
 * roster is small enough (hundreds, not millions, of rows) that a full
 * snapshot on every manual export is simpler and more correct than an
 * incremental ledger - it can never drift from Firestore, and a
 * withdrawn/graduated student naturally disappears from the sheet on the
 * next export instead of needing an explicit removal path.
 */
exports.exportStudentRosterToSheets = onCall(async (request) => {
  const { schoolId } = await callerContext(request);

  const integration = await getIntegration(schoolId);
  if (!integration || !integration.linked || !integration.spreadsheetId) {
    throw new HttpsError(
      "failed-precondition",
      "Connect Google Sheets first (Attendance > Google Sheets)."
    );
  }

  const [studentsSnap, identitiesSnap, classesSnap] = await Promise.all([
    db().collection("students").where("schoolId", "==", schoolId).get(),
    db().collection("student_identities").where("schoolId", "==", schoolId).get(),
    db().collection("classes").where("schoolId", "==", schoolId).get(),
  ]);

  const identityByStudentId = new Map();
  identitiesSnap.docs.forEach((doc) => {
    const data = doc.data();
    if (data.studentId) identityByStudentId.set(data.studentId, data);
  });
  const classNameById = new Map();
  classesSnap.docs.forEach((doc) => {
    classNameById.set(doc.id, doc.data().name || "");
  });

  const rows = studentsSnap.docs.map((doc) => {
    const student = doc.data();
    const identity = identityByStudentId.get(doc.id) || null;
    const className = classNameById.get(student.classId) || "";
    return rowFor(student, identity, className);
  });

  try {
    const sheets = await getAuthorizedSheetsClient(schoolId);
    await ensureWorksheet(sheets, integration.spreadsheetId);

    // Clear existing data rows (below the header) before rewriting - a full
    // snapshot export, not an append.
    await retryWithBackoff(() =>
      sheets.spreadsheets.values.clear({
        spreadsheetId: integration.spreadsheetId,
        range: `'${WORKSHEET_NAME}'!A2:Z`,
      })
    );

    for (let i = 0; i < rows.length; i += APPEND_BATCH_SIZE) {
      const batch = rows.slice(i, i + APPEND_BATCH_SIZE);
      await retryWithBackoff(() =>
        sheets.spreadsheets.values.append({
          spreadsheetId: integration.spreadsheetId,
          range: `'${WORKSHEET_NAME}'!A1`,
          valueInputOption: "USER_ENTERED",
          insertDataOption: "INSERT_ROWS",
          requestBody: { values: batch },
        })
      );
    }

    await db()
      .collection("schools")
      .doc(schoolId)
      .collection("integration_logs")
      .add({
        institutionId: schoolId,
        integrationKey: "google_sheets",
        action: "roster_exported",
        actorId: request.auth.uid,
        metadata: { studentCount: rows.length },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    return { studentCount: rows.length };
  } catch (err) {
    if (err.code === "not_connected") {
      throw new HttpsError("failed-precondition", "Connect Google Sheets first.", {
        reason: "not_connected",
      });
    }
    if (err.code === "needs_reauth") {
      throw new HttpsError(
        "failed-precondition",
        "Google Sheets connection needs to be renewed.",
        { reason: "needs_reauth" }
      );
    }
    console.error(`Roster export to Sheets failed for ${schoolId}:`, err);
    throw new HttpsError("internal", "Could not export the roster to Google Sheets.", {
      reason: "temporary",
    });
  }
});

exports.__test__ = { rowFor, formatDate, HEADER_ROW };
