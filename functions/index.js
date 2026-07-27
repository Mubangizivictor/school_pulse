const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { randomBytes, randomUUID } = require("crypto");
const admin = require("firebase-admin");

admin.initializeApp();

// Roles allowed to land on the /staff/admin screen in the app - the same
// set that's allowed to invite new staff.
const ADMIN_ROLES = ["director", "headTeacher", "schoolAdmin"];

const STAFF_ROLES = [
  "director", "headTeacher", "deputyHead", "schoolAdmin", "bursar",
  "classTeacher", "subjectTeacher", "librarian", "nurse", "boardingMatron",
  "transportCoordinator", "guidanceDiscipline", "storeInventory",
  "receptionist", "gatekeeper", "securityHead",
  "gamesMaster", "cateringManager",
];

// Excludes visually ambiguous characters (0/O, 1/l/I) since admins read
// this aloud or copy it onto a note for the teacher.
const PASSWORD_CHARS = "ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789";

function generateTemporaryPassword() {
  const bytes = randomBytes(12);
  let password = "";
  for (let i = 0; i < bytes.length; i++) {
    password += PASSWORD_CHARS[bytes[i] % PASSWORD_CHARS.length];
  }
  return password;
}

exports.createStaffAccount = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const { name, email, role, assignedClass, subjects } = request.data || {};
  if (typeof name !== "string" || !name.trim()) {
    throw new HttpsError("invalid-argument", "Name is required.");
  }
  if (typeof email !== "string" || !email.trim()) {
    throw new HttpsError("invalid-argument", "Email is required.");
  }
  if (!STAFF_ROLES.includes(role)) {
    throw new HttpsError("invalid-argument", "Invalid staff role.");
  }

  // The Admin SDK bypasses Firestore rules entirely, so this check is the
  // only gate on who may create staff accounts - it must happen here.
  const callerDoc = await admin.firestore().collection("users").doc(auth.uid).get();
  const callerRole = callerDoc.exists ? callerDoc.data().role : null;
  if (!ADMIN_ROLES.includes(callerRole)) {
    throw new HttpsError("permission-denied", "Only school administrators can create staff accounts.");
  }

  const temporaryPassword = generateTemporaryPassword();

  let userRecord;
  try {
    userRecord = await admin.auth().createUser({
      email: email.trim(),
      password: temporaryPassword,
      displayName: name.trim(),
    });
  } catch (err) {
    if (err.code === "auth/email-already-exists") {
      throw new HttpsError("already-exists", "An account with this email already exists.");
    }
    throw new HttpsError("internal", err.message || "Failed to create the account.");
  }

  try {
    await admin.firestore().collection("users").doc(userRecord.uid).set({
      name: name.trim(),
      email: email.trim(),
      role,
      studentIds: [],
      mustChangePassword: true,
      createdBy: auth.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      ...(assignedClass ? { assignedClass } : {}),
      ...(Array.isArray(subjects) ? { subjects } : {}),
    });
  } catch (err) {
    // Don't leave an orphaned Auth user with no matching profile doc - a
    // retry with the same email would otherwise permanently fail with
    // already-exists with no way for the admin to recover.
    await admin.auth().deleteUser(userRecord.uid).catch(() => {});
    throw new HttpsError("internal", err.message || "Failed to save the staff profile.");
  }

  return { uid: userRecord.uid, temporaryPassword };
});

// ============================================================================
// Subscription billing - MTN Mobile Money & Airtel Money
//
// NOT YET LIVE: this is a structurally-correct implementation against each
// provider's public API docs (MTN MoMo Collections API, Airtel Money
// Collection API), but it has never been run against a real sandbox or
// production account - neither was available while writing it. Before
// relying on it:
//   1. Fill in the environment variables listed in functions/.env.example
//      (via `firebase functions:secrets:set NAME` or a functions/.env file).
//   2. Deploy, then trigger one real renewal from a test phone and confirm
//      money actually moves and the webhook fires.
//   3. On the MTN MoMo developer portal / Airtel developer portal, register
//      the deployed webhook URLs as the callback for each product.
//
// Roles allowed to trigger a subscription charge - same admin tier as
// everything else, plus the bursar, since billing is their job day to day.
const BILLING_ROLES = ["director", "headTeacher", "schoolAdmin", "bursar"];

function normalizeUgandaMsisdn(phone) {
  const digits = String(phone).replace(/\D/g, "");
  if (digits.startsWith("256")) return digits;
  if (digits.startsWith("0")) return `256${digits.substring(1)}`;
  return `256${digits}`;
}

async function getMtnAccessToken() {
  const base = process.env.MTN_MOMO_BASE_URL;
  const user = process.env.MTN_MOMO_API_USER;
  const key = process.env.MTN_MOMO_API_KEY;
  const subKey = process.env.MTN_MOMO_SUBSCRIPTION_KEY;
  if (!base || !user || !key || !subKey) {
    throw new Error("MTN MoMo is not configured yet - see functions/.env.example.");
  }
  const basicAuth = Buffer.from(`${user}:${key}`).toString("base64");
  const res = await fetch(`${base}/collection/token/`, {
    method: "POST",
    headers: {
      "Authorization": `Basic ${basicAuth}`,
      "Ocp-Apim-Subscription-Key": subKey,
    },
  });
  if (!res.ok) throw new Error(`MTN token request failed: ${res.status} ${await res.text()}`);
  const data = await res.json();
  return data.access_token;
}

async function initiateMtnCharge({ transactionId, phoneNumber, amountUgx }) {
  const base = process.env.MTN_MOMO_BASE_URL;
  const subKey = process.env.MTN_MOMO_SUBSCRIPTION_KEY;
  const targetEnv = process.env.MTN_MOMO_TARGET_ENVIRONMENT || "sandbox";
  const callbackUrl = process.env.MTN_MOMO_CALLBACK_URL;
  const accessToken = await getMtnAccessToken();

  const res = await fetch(`${base}/collection/v1_0/requesttopay`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${accessToken}`,
      "X-Reference-Id": transactionId,
      "X-Target-Environment": targetEnv,
      "Ocp-Apim-Subscription-Key": subKey,
      "Content-Type": "application/json",
      ...(callbackUrl ? { "X-Callback-Url": callbackUrl } : {}),
    },
    body: JSON.stringify({
      amount: String(amountUgx),
      currency: targetEnv === "sandbox" ? "EUR" : "UGX",
      externalId: transactionId,
      payer: { partyIdType: "MSISDN", partyId: normalizeUgandaMsisdn(phoneNumber) },
      payerMessage: "School Pulse subscription renewal",
      payeeNote: "Monthly subscription",
    }),
  });
  if (res.status !== 202) {
    throw new Error(`MTN requesttopay failed: ${res.status} ${await res.text()}`);
  }
}

async function getAirtelAccessToken() {
  const base = process.env.AIRTEL_BASE_URL;
  const clientId = process.env.AIRTEL_CLIENT_ID;
  const clientSecret = process.env.AIRTEL_CLIENT_SECRET;
  if (!base || !clientId || !clientSecret) {
    throw new Error("Airtel Money is not configured yet - see functions/.env.example.");
  }
  const res = await fetch(`${base}/auth/oauth2/token`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ client_id: clientId, client_secret: clientSecret, grant_type: "client_credentials" }),
  });
  if (!res.ok) throw new Error(`Airtel token request failed: ${res.status} ${await res.text()}`);
  const data = await res.json();
  return data.access_token;
}

async function initiateAirtelCharge({ transactionId, phoneNumber, amountUgx }) {
  const base = process.env.AIRTEL_BASE_URL;
  const accessToken = await getAirtelAccessToken();
  // Airtel wants the subscriber MSISDN without the country code.
  const msisdn = normalizeUgandaMsisdn(phoneNumber).replace(/^256/, "");

  const res = await fetch(`${base}/merchant/v1/payments/`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${accessToken}`,
      "X-Country": "UG",
      "X-Currency": "UGX",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      reference: "School Pulse subscription renewal",
      subscriber: { country: "UG", currency: "UGX", msisdn },
      transaction: { amount: amountUgx, country: "UG", currency: "UGX", id: transactionId },
    }),
  });
  if (!res.ok) {
    throw new Error(`Airtel payment request failed: ${res.status} ${await res.text()}`);
  }
}

/**
 * Client-callable: kicks off a Mobile Money "request to pay" prompt on the
 * subscriber's phone. Writes a pending payment_transactions doc immediately
 * so the UI has something to watch, then calls out to the provider.
 */
exports.initiateMobileMoneyCharge = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "You must be signed in.");

  const userDoc = await admin.firestore().collection("users").doc(auth.uid).get();
  const role = userDoc.data()?.role;
  if (!BILLING_ROLES.includes(role)) {
    throw new HttpsError("permission-denied", "Only admins or the bursar can manage billing.");
  }

  const { provider, phoneNumber, amountUgx } = request.data || {};
  if (!["mtn", "airtel"].includes(provider)) {
    throw new HttpsError("invalid-argument", "provider must be 'mtn' or 'airtel'.");
  }
  if (!phoneNumber || !amountUgx || amountUgx <= 0) {
    throw new HttpsError("invalid-argument", "phoneNumber and a positive amountUgx are required.");
  }

  const transactionId = randomUUID();
  const db = admin.firestore();
  await db.collection("payment_transactions").doc(transactionId).set({
    provider,
    phoneNumber,
    amountUgx,
    status: "pending",
    reference: transactionId,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  try {
    if (provider === "mtn") {
      await initiateMtnCharge({ transactionId, phoneNumber, amountUgx });
    } else {
      await initiateAirtelCharge({ transactionId, phoneNumber, amountUgx });
    }
  } catch (err) {
    await db.collection("payment_transactions").doc(transactionId).update({
      status: "failed",
      failureReason: err.message,
    });
    throw new HttpsError("internal", `Could not start payment: ${err.message}`);
  }

  return { transactionId };
});

async function markTransactionResult(transactionId, { status, failureReason }) {
  const db = admin.firestore();
  const txRef = db.collection("payment_transactions").doc(transactionId);
  const txDoc = await txRef.get();
  if (!txDoc.exists) return;

  await txRef.update({
    status,
    ...(failureReason ? { failureReason } : {}),
    completedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  if (status === "success") {
    const tx = txDoc.data();
    const subRef = db.collection("subscription").doc("current");
    const subDoc = await subRef.get();
    const currentRenewal = subDoc.data()?.renewalDate?.toDate() ?? new Date();
    const base = currentRenewal > new Date() ? currentRenewal : new Date();
    const nextRenewal = new Date(base);
    nextRenewal.setMonth(nextRenewal.getMonth() + 1);

    await subRef.set({
      status: "active",
      renewalDate: admin.firestore.Timestamp.fromDate(nextRenewal),
      amountUgx: tx.amountUgx,
      plan: subDoc.data()?.plan ?? "Standard",
    }, { merge: true });
  }
}

// Neither provider signs its webhook payloads by default, so this shared
// secret in the callback URL's query string is the only thing standing
// between this endpoint and anyone on the internet who guesses the URL.
// Set WEBHOOK_SHARED_SECRET and register the callback URL with the ?secret=
// suffix on each provider's developer portal.
function checkWebhookSecret(req, res) {
  const expected = process.env.WEBHOOK_SHARED_SECRET;
  if (expected && req.query.secret !== expected) {
    res.status(403).send("Forbidden");
    return false;
  }
  return true;
}

// MTN calls this back (via the X-Callback-Url sent on requesttopay) once a
// charge resolves. Register MTN_MOMO_CALLBACK_URL to point here after
// deploying, e.g. https://REGION-PROJECT.cloudfunctions.net/mtnMomoWebhook?secret=...
exports.mtnMomoWebhook = onRequest(async (req, res) => {
  if (!checkWebhookSecret(req, res)) return;
  try {
    const body = req.body || {};
    const transactionId = body.externalId || body.referenceId;
    const status = body.status === "SUCCESSFUL" ? "success" : "failed";
    if (transactionId) {
      await markTransactionResult(transactionId, { status, failureReason: body.reason });
    }
    res.status(200).send("OK");
  } catch (err) {
    console.error("mtnMomoWebhook error", err);
    res.status(500).send("Error");
  }
});

// Register this URL as the Collection callback on the Airtel developer
// portal, e.g. https://REGION-PROJECT.cloudfunctions.net/airtelMoneyWebhook?secret=...
exports.airtelMoneyWebhook = onRequest(async (req, res) => {
  if (!checkWebhookSecret(req, res)) return;
  try {
    const body = req.body || {};
    const transactionId = body.transaction?.id;
    const success = body.transaction?.status === "TS" || body.transaction?.status_code === "TS";
    if (transactionId) {
      await markTransactionResult(transactionId, {
        status: success ? "success" : "failed",
        failureReason: success ? undefined : body.transaction?.message,
      });
    }
    res.status(200).send("OK");
  } catch (err) {
    console.error("airtelMoneyWebhook error", err);
    res.status(500).send("Error");
  }
});

/**
 * Fallback poll for while webhooks aren't registered on the provider
 * dashboard yet (or in case one is missed) - checks status directly
 * against MTN/Airtel rather than waiting on a callback.
 */
exports.checkPaymentStatus = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) throw new HttpsError("unauthenticated", "You must be signed in.");

  const { transactionId } = request.data || {};
  if (!transactionId) throw new HttpsError("invalid-argument", "transactionId is required.");

  const db = admin.firestore();
  const txDoc = await db.collection("payment_transactions").doc(transactionId).get();
  if (!txDoc.exists) throw new HttpsError("not-found", "Transaction not found.");
  const tx = txDoc.data();

  if (tx.status !== "pending") {
    return { status: tx.status };
  }

  if (tx.provider === "mtn") {
    const base = process.env.MTN_MOMO_BASE_URL;
    const subKey = process.env.MTN_MOMO_SUBSCRIPTION_KEY;
    const targetEnv = process.env.MTN_MOMO_TARGET_ENVIRONMENT || "sandbox";
    const accessToken = await getMtnAccessToken();
    const res = await fetch(`${base}/collection/v1_0/requesttopay/${transactionId}`, {
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "X-Target-Environment": targetEnv,
        "Ocp-Apim-Subscription-Key": subKey,
      },
    });
    if (!res.ok) throw new HttpsError("internal", `MTN status check failed: ${res.status}`);
    const data = await res.json();
    const status = data.status === "SUCCESSFUL" ? "success" : (data.status === "FAILED" ? "failed" : "pending");
    if (status !== "pending") await markTransactionResult(transactionId, { status, failureReason: data.reason });
    return { status };
  }

  if (tx.provider === "airtel") {
    const base = process.env.AIRTEL_BASE_URL;
    const accessToken = await getAirtelAccessToken();
    const res = await fetch(`${base}/standard/v1/payments/${transactionId}`, {
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "X-Country": "UG",
        "X-Currency": "UGX",
      },
    });
    if (!res.ok) throw new HttpsError("internal", `Airtel status check failed: ${res.status}`);
    const data = await res.json();
    const success = data.data?.transaction?.status === "TS";
    const failed = data.data?.transaction?.status === "TF";
    const status = success ? "success" : (failed ? "failed" : "pending");
    if (status !== "pending") await markTransactionResult(transactionId, { status });
    return { status };
  }

  throw new HttpsError("invalid-argument", "Unknown provider.");
});
