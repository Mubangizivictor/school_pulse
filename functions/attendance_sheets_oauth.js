/**
 * Google Sheets OAuth connection for the Attendance -> Sheets export
 * (attendance_sheets.js). Each school connects its own Google account -
 * there is no shared service account. School Pulse never lets a Google
 * refresh/access token reach the Flutter client or a client-readable
 * Firestore document; only the authorization-code exchange and all token
 * storage/use happen here, server-side.
 *
 * Flow:
 *   Flutter (School Admin) calls startGoogleSheetsOAuth
 *     -> gets an authUrl, opens it in an external browser
 *   Google redirects the browser to googleSheetsOAuthCallback with a code
 *     -> tokens are exchanged, a spreadsheet is created, and the safe
 *        display fields land in attendance_sheets_integration/config
 *   Flutter polls getIntegration until linked == true
 *
 * Tokens live in schools/{schoolId}/attendance_sheets_oauth/tokens, which
 * carries `allow read, write: if false` in firestore.rules - only the
 * Admin SDK (this file) ever touches it.
 */

const crypto = require("crypto");
const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { google } = require("googleapis");

const db = () => admin.firestore();

const SHEETS_SCOPE = "https://www.googleapis.com/auth/spreadsheets";
const USERINFO_EMAIL_SCOPE = "https://www.googleapis.com/auth/userinfo.email";
const OAUTH_STATE_TTL_MS = 10 * 60 * 1000;
const CONNECT_ROLES = new Set(["schoolAdmin", "director", "headTeacher", "deputyHead"]);

function oauth2Client() {
  const clientId = process.env.GOOGLE_SHEETS_OAUTH_CLIENT_ID;
  const clientSecret = process.env.GOOGLE_SHEETS_OAUTH_CLIENT_SECRET;
  const redirectUri = process.env.GOOGLE_SHEETS_OAUTH_REDIRECT_URI;
  if (!clientId || !clientSecret || !redirectUri) {
    throw new Error(
      "Google Sheets OAuth client is not configured - see functions/.env.example."
    );
  }
  return new google.auth.OAuth2(clientId, clientSecret, redirectUri);
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
      "Only a school admin can connect or disconnect Google Sheets."
    );
  }
  return { uid: request.auth.uid, schoolId };
}

async function audit(schoolId, actorId, action, metadata = {}) {
  await db()
    .collection("schools")
    .doc(schoolId)
    .collection("integration_logs")
    .add({
      institutionId: schoolId,
      integrationKey: "google_sheets",
      action,
      actorId,
      metadata,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}

function tokensRef(schoolId) {
  return db()
    .collection("schools")
    .doc(schoolId)
    .collection("attendance_sheets_oauth")
    .doc("tokens");
}

function stateRef(nonce) {
  return db().collection("attendance_sheets_oauth_state").doc(nonce);
}

function configRef(schoolId) {
  return db()
    .collection("schools")
    .doc(schoolId)
    .collection("attendance_sheets_integration")
    .doc("config");
}

async function schoolDisplayName(schoolId) {
  const snap = await db().collection("schools").doc(schoolId).get();
  const name = snap.exists ? snap.data().name : null;
  return (name && String(name).trim()) || "School Pulse";
}

/**
 * Ensures the "Attendance Records" worksheet + header row exists. Mirrors
 * attendance_sheets.js's ensureWorksheet so a freshly-created spreadsheet is
 * immediately ready for exports - kept local (not imported) since it is a
 * tiny, self-contained helper and this file must not depend on the export
 * module (attendance_sheets.js depends on this file, not the other way).
 */
async function primeWorksheet(sheets, spreadsheetId, worksheetName, headerRow) {
  await sheets.spreadsheets.values.update({
    spreadsheetId,
    range: `'${worksheetName}'!A1`,
    valueInputOption: "RAW",
    requestBody: { values: [headerRow] },
  });
}

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

/**
 * Starts the OAuth flow: writes a short-lived CSRF state doc and returns the
 * Google consent URL for the Flutter client to open in a browser.
 */
exports.startGoogleSheetsOAuth = onCall(async (request) => {
  const { uid, schoolId } = await callerContext(request);

  const nonce = crypto.randomBytes(24).toString("hex");
  const now = Date.now();
  await stateRef(nonce).set({
    schoolId,
    uid,
    createdAt: admin.firestore.Timestamp.fromMillis(now),
    expiresAt: admin.firestore.Timestamp.fromMillis(now + OAUTH_STATE_TTL_MS),
  });

  const authUrl = oauth2Client().generateAuthUrl({
    access_type: "offline",
    prompt: "consent",
    scope: [SHEETS_SCOPE, USERINFO_EMAIL_SCOPE],
    state: JSON.stringify({ schoolId, uid, nonce }),
  });

  return { authUrl };
});

function htmlResponse(res, status, title, message) {
  res.status(status).set("Content-Type", "text/html; charset=utf-8").send(`<!doctype html>
<html><head><meta charset="utf-8"><title>${title}</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>body{font-family:-apple-system,Segoe UI,Roboto,sans-serif;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;background:#f5f5f7;color:#1c1c1e;text-align:center;padding:24px}
.card{max-width:420px}</style></head>
<body><div class="card"><h1>${title}</h1><p>${message}</p></div></body></html>`);
}

/**
 * OAuth redirect target. Exchanges the authorization code, creates the
 * school's spreadsheet on first connection, and records only non-secret
 * display fields on attendance_sheets_integration/config.
 */
exports.googleSheetsOAuthCallback = onRequest(async (req, res) => {
  const { code, error, state: rawState } = req.query;

  if (error) {
    htmlResponse(
      res,
      200,
      "Connection cancelled",
      "You can close this window and try connecting again in School Pulse."
    );
    return;
  }

  let parsedState;
  try {
    parsedState = JSON.parse(String(rawState || ""));
  } catch {
    htmlResponse(res, 400, "Invalid request", "This connection link is invalid.");
    return;
  }
  const { nonce } = parsedState || {};
  if (!nonce) {
    htmlResponse(res, 400, "Invalid request", "This connection link is invalid.");
    return;
  }

  const stateSnap = await stateRef(nonce).get();
  await stateRef(nonce).delete().catch(() => {});
  if (!stateSnap.exists) {
    htmlResponse(
      res,
      400,
      "Link expired",
      "This connection link has expired. Please try connecting again from School Pulse."
    );
    return;
  }
  const state = stateSnap.data();
  if (state.expiresAt.toMillis() < Date.now()) {
    htmlResponse(
      res,
      400,
      "Link expired",
      "This connection link has expired. Please try connecting again from School Pulse."
    );
    return;
  }
  const { schoolId, uid } = state;

  if (!code) {
    htmlResponse(res, 400, "Invalid request", "This connection link is invalid.");
    return;
  }

  try {
    const client = oauth2Client();
    const { tokens } = await client.getToken(String(code));
    client.setCredentials(tokens);

    let connectedAccountEmail = "";
    try {
      const oauth2 = google.oauth2({ version: "v2", auth: client });
      const info = await oauth2.userinfo.get();
      connectedAccountEmail = info.data.email || "";
    } catch (err) {
      console.warn(`Could not read connected account email for ${schoolId}:`, err.message);
    }

    // Preserve a previously-stored refresh token if Google didn't issue a
    // new one - Google only returns refresh_token on the very first consent
    // for a given account/scope combination.
    const existing = await tokensRef(schoolId).get();
    const refreshToken = tokens.refresh_token || existing.data()?.refreshToken || null;
    if (!refreshToken) {
      htmlResponse(
        res,
        400,
        "Connection incomplete",
        "Google did not grant a persistent connection. Please try connecting again and make sure to approve access when prompted."
      );
      return;
    }

    const worksheetName = "Attendance Records";
    const schoolName = await schoolDisplayName(schoolId);
    const sheets = google.sheets({ version: "v4", auth: client });
    const created = await sheets.spreadsheets.create({
      requestBody: {
        properties: { title: `School Pulse Attendance — ${schoolName}` },
        sheets: [{ properties: { title: worksheetName } }],
      },
    });
    const spreadsheetId = created.data.spreadsheetId;
    await primeWorksheet(sheets, spreadsheetId, worksheetName, HEADER_ROW);

    const now = admin.firestore.FieldValue.serverTimestamp();
    await tokensRef(schoolId).set({
      accessToken: tokens.access_token || null,
      refreshToken,
      accessTokenExpiresAt: tokens.expiry_date
        ? admin.firestore.Timestamp.fromMillis(tokens.expiry_date)
        : null,
      scope: tokens.scope || "",
      connectedAccountEmail,
      connectedByUid: uid,
      createdAt: existing.exists ? existing.data().createdAt || now : now,
      updatedAt: now,
    });

    await configRef(schoolId).set(
      {
        linked: true,
        spreadsheetId,
        spreadsheetName: created.data.properties?.title || `School Pulse Attendance — ${schoolName}`,
        worksheetName,
        connectedAccountEmail,
        connectionStatus: "connected",
        connectedBy: uid,
        connectedAt: now,
        autoSync: true,
      },
      { merge: true }
    );

    await audit(schoolId, uid, "connected", { connectedAccountEmail, spreadsheetId });

    htmlResponse(
      res,
      200,
      "Connected",
      "Google Sheets is connected. You can close this window and return to School Pulse."
    );
  } catch (err) {
    console.error(`Google Sheets OAuth callback failed for ${schoolId}:`, err);
    htmlResponse(
      res,
      500,
      "Connection failed",
      "Something went wrong connecting Google Sheets. Please try again from School Pulse."
    );
  }
});

/**
 * Disconnects a school's Google account. Best-effort revokes the refresh
 * token with Google, then always clears local state regardless of whether
 * revocation succeeded - a failed revoke call must not leave the school
 * unable to disconnect. Attendance data and the spreadsheet itself are
 * never touched.
 */
exports.disconnectGoogleSheetsOAuth = onCall(async (request) => {
  const { uid, schoolId } = await callerContext(request);

  const tokenSnap = await tokensRef(schoolId).get();
  if (tokenSnap.exists && tokenSnap.data().refreshToken) {
    try {
      await oauth2Client().revokeToken(tokenSnap.data().refreshToken);
    } catch (err) {
      console.warn(`Google token revoke failed for ${schoolId} (continuing):`, err.message);
    }
  }

  await tokensRef(schoolId).delete();
  await configRef(schoolId).set(
    {
      linked: false,
      connectionStatus: "disconnected",
      connectedAccountEmail: "",
      spreadsheetId: admin.firestore.FieldValue.delete(),
      spreadsheetName: admin.firestore.FieldValue.delete(),
      worksheetName: admin.firestore.FieldValue.delete(),
    },
    { merge: true }
  );

  await audit(schoolId, uid, "disconnected", {});
  return { ok: true };
});

/**
 * Returns an authenticated Sheets API client for a school, transparently
 * refreshing the access token when needed and persisting the refreshed
 * token back to Firestore. Throws a typed error (`err.code`) that callers
 * map to friendly messages:
 *   - 'not_connected': no Google account connected yet
 *   - 'needs_reauth': the refresh token was revoked/expired
 */
async function getAuthorizedSheetsClient(schoolId) {
  const tokenSnap = await tokensRef(schoolId).get();
  if (!tokenSnap.exists) {
    const err = new Error("Google Sheets is not connected for this school.");
    err.code = "not_connected";
    throw err;
  }
  const data = tokenSnap.data();

  const client = oauth2Client();
  client.setCredentials({
    access_token: data.accessToken || undefined,
    refresh_token: data.refreshToken,
    expiry_date: data.accessTokenExpiresAt ? data.accessTokenExpiresAt.toMillis() : undefined,
  });

  client.on("tokens", (tokens) => {
    const update = { updatedAt: admin.firestore.FieldValue.serverTimestamp() };
    if (tokens.access_token) update.accessToken = tokens.access_token;
    if (tokens.expiry_date) {
      update.accessTokenExpiresAt = admin.firestore.Timestamp.fromMillis(tokens.expiry_date);
    }
    if (tokens.refresh_token) update.refreshToken = tokens.refresh_token;
    tokensRef(schoolId).set(update, { merge: true }).catch((err) => {
      console.error(`Failed to persist refreshed Google token for ${schoolId}:`, err);
    });
  });

  try {
    // Force a token check now (rather than lazily on first API call) so a
    // revoked/expired grant is surfaced as 'needs_reauth' before any Sheets
    // API call is attempted.
    await client.getAccessToken();
  } catch (err) {
    if (String(err.message || "").includes("invalid_grant")) {
      await configRef(schoolId)
        .set({ connectionStatus: "needs_attention" }, { merge: true })
        .catch(() => {});
      const typed = new Error("Google Sheets connection needs to be renewed.");
      typed.code = "needs_reauth";
      throw typed;
    }
    throw err;
  }

  return google.sheets({ version: "v4", auth: client });
}

exports.getAuthorizedSheetsClient = getAuthorizedSheetsClient;
exports.HEADER_ROW = HEADER_ROW;
