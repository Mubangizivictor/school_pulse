const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { randomBytes, randomUUID } = require("crypto");
const admin = require("firebase-admin");

admin.initializeApp();

// ... existing roles and helper functions ...
const ADMIN_ROLES = ["director", "headTeacher", "schoolAdmin"];

const STAFF_ROLES = [
  "director", "headTeacher", "deputyHead", "schoolAdmin", "bursar",
  "classTeacher", "subjectTeacher", "librarian", "nurse", "boardingMatron", "boardingPatron",
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

  const { name, email, assignedClass, subjects } = request.data || {};
  // Accept the current multi-role `roles` array, falling back to a legacy
  // singular `role` from any older client build still calling this.
  const roles = Array.isArray(request.data?.roles)
    ? request.data.roles
    : (request.data?.role ? [request.data.role] : []);

  if (typeof name !== "string" || !name.trim()) {
    throw new HttpsError("invalid-argument", "Name is required.");
  }
  if (typeof email !== "string" || !email.trim()) {
    throw new HttpsError("invalid-argument", "Email is required.");
  }
  if (roles.length === 0 || !roles.every((r) => STAFF_ROLES.includes(r))) {
    throw new HttpsError("invalid-argument", "Invalid staff role.");
  }

  // The Admin SDK bypasses Firestore rules entirely, so this check is the
  // only gate on who may create staff accounts - it must happen here.
  const callerDoc = await admin.firestore().collection("users").doc(auth.uid).get();
  const callerData = callerDoc.exists ? callerDoc.data() : {};
  const callerRole = callerData.role || null;
  const schoolId = callerData.schoolId || null;
  if (!ADMIN_ROLES.includes(callerRole)) {
    throw new HttpsError("permission-denied", "Only school administrators can create staff accounts.");
  }
  if (!schoolId) {
    throw new HttpsError(
      "failed-precondition",
      "Your administrator account is not assigned to a school."
    );
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
    const db = admin.firestore();
    const userData = {
      name: name.trim(),
      email: email.trim(),
      role: roles[0],
      roles,
      schoolId,
      studentIds: [],
      mustChangePassword: true,
      createdBy: auth.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      ...(assignedClass ? { assignedClass } : {}),
      ...(Array.isArray(subjects) ? { subjects } : {}),
    };
    const batch = db.batch();
    batch.set(db.collection("users").doc(userRecord.uid), userData);
    batch.set(db.collection("school_contacts").doc(userRecord.uid), {
      name: name.trim(),
      role: roles[0],
      roles,
      schoolId,
      isActive: true,
    });
    await batch.commit();
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

// ============================================================================
// Visitor Management - Overstay Detection
// ============================================================================

/**
 * Periodically checks for visitors who have exceeded their expected departure time
 * and sends alerts to their hosts and security personnel.
 */
exports.checkVisitorOverstays = onSchedule("every 15 minutes", async () => {
  const now = admin.firestore.Timestamp.now();
  const db = admin.firestore();

  const overstayedVisitors = await db.collection("visitors")
    .where("status", "==", "checkedIn")
    .where("expectedDepartureTime", "<=", now)
    .where("overstayAlertSent", "==", false)
    .get();

  for (const doc of overstayedVisitors.docs) {
    const visitor = doc.data();
    const visitorId = doc.id;

    try {
      // 1. Alert the Host if hostId is available
      if (visitor.hostId) {
        const hostDoc = await db.collection("users").doc(visitor.hostId).get();
        const hostData = hostDoc.data();

        if (hostData && hostData.fcmToken) {
          await db.collection("notification_queue").add({
            token: hostData.fcmToken,
            status: "pending",
            notification: {
              title: "Visitor Overstay Alert",
              body: `Your visitor ${visitor.fullName} has exceeded their scheduled time.`,
            },
            data: {
              type: "visitor_overstay",
              visitorId: visitorId,
              schoolId: visitor.schoolId,
            },
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }

      // 2. Alert Security Topic for the school
      const securityTopic = `topic_Security_${visitor.schoolId.replace(/[^a-zA-Z0-9-_.~%]/g, '_')}`;
      await admin.messaging().send({
        topic: securityTopic,
        notification: {
          title: "SECURITY: Visitor Overstay",
          body: `${visitor.fullName} (Host: ${visitor.host}) has overstayed. Please verify.`,
        },
        android: {
          priority: "high",
          notification: { channelId: "security_alerts", color: "#FF0000" },
        },
        data: {
          type: "visitor_overstay_security",
          visitorId: visitorId,
        },
      });

      // 3. Mark alert as sent to avoid duplicates
      await doc.ref.update({ overstayAlertSent: true });

    } catch (err) {
      console.error(`Failed to process overstay for visitor ${visitorId}:`, err);
    }
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

// ============================================================================
// Parent Authentication
// ============================================================================

/**
 * Verifies a parent's access code + phone + PIN server-side (parent_access_
 * codes/{code} is publicly readable by design so the pre-login screens can
 * show the parent's name - see firestore.rules - so the PIN comparison can
 * no longer happen trustingly on the client) and mints a Firebase custom
 * token so the parent gets a real Firebase Auth session. Also mirrors a
 * users/{uid} profile so Firestore rules (myUser/isParentOf) and the
 * "groups" a parent belongs to for broadcast targeting can be resolved.
 */
exports.loginParent = onCall(async (request) => {
  const { code, phoneNumber, pin } = request.data || {};
  if (!code || !phoneNumber || !pin) {
    throw new HttpsError("invalid-argument", "Access code, phone number, and PIN are required.");
  }

  const codeRef = admin.firestore().collection("parent_access_codes").doc(code);
  const doc = await codeRef.get();
  if (!doc.exists) {
    throw new HttpsError("not-found", "Invalid access code.");
  }

  const data = doc.data();
  if (data.isActive === false) {
    const reason = data.deactivationReason ? `\nReason: ${data.deactivationReason}` : "";
    throw new HttpsError("permission-denied", `This access code has been deactivated.${reason}`);
  }
  if (data.phoneNumber !== phoneNumber) {
    throw new HttpsError("permission-denied", "Phone number does not match this access code.");
  }
  if (data.pin !== pin) {
    throw new HttpsError("permission-denied", "Incorrect PIN.");
  }

  const uid = `parent_${code}`;
  const studentIds = data.studentIds || [];

  // Resolve each child's class so the parent can be scoped to "Class:X"
  // broadcasts, in addition to the general "Parents" group.
  const groups = new Set(["Parents"]);
  if (studentIds.length > 0) {
    const studentDocs = await admin.firestore().getAll(
      ...studentIds.map((id) => admin.firestore().collection("students").doc(id))
    );
    for (const sDoc of studentDocs) {
      const className = sDoc.exists ? sDoc.data().className : null;
      if (className) groups.add(`Class:${className}`);
    }
  }

  await admin.firestore().collection("users").doc(uid).set({
    role: "parent",
    studentIds,
    groups: Array.from(groups),
    name: data.parentName || "Parent",
    phoneNumber: data.phoneNumber,
    schoolId: data.schoolId || "",
    isActive: true,
  }, { merge: true });

  const token = await admin.auth().createCustomToken(uid, { role: "parent" });
  return { token, mustChangePin: !!data.mustChangePin };
});

/**
 * Sets a parent's PIN (first-time setup or reset). Runs before the parent
 * has a Firebase Auth session, so identity is proven with code+phone
 * instead of request.auth.
 */
exports.completeParentPinSetup = onCall(async (request) => {
  const { code, phoneNumber, newPin } = request.data || {};
  if (!code || !phoneNumber || !newPin) {
    throw new HttpsError("invalid-argument", "Access code, phone number, and new PIN are required.");
  }

  const codeRef = admin.firestore().collection("parent_access_codes").doc(code);
  const doc = await codeRef.get();
  if (!doc.exists) {
    throw new HttpsError("not-found", "Invalid access code.");
  }
  const data = doc.data();
  if (data.isActive === false) {
    throw new HttpsError("permission-denied", "This access code has been deactivated.");
  }
  if (data.phoneNumber !== phoneNumber) {
    throw new HttpsError("permission-denied", "Phone number does not match this access code.");
  }

  await codeRef.update({ pin: newPin, mustChangePin: false });
  return { success: true };
});

// ============================================================================
// Notification Delivery Triggers
// ============================================================================

/**
 * Triggered when a new document is added to 'broadcast_queue'.
 * Delivers push notifications to FCM topics based on targetGroups.
 */
exports.processBroadcastQueue = onDocumentCreated("broadcast_queue/{id}", async (event) => {
  const data = event.data.data();
  if (data.status !== "pending") return;

  const { notification, targets } = data;

  try {
    // Send to each target group as an FCM topic
    // Targets in DB are like ['Parents', 'Class:P.1']
    // We map these to topics like 'topic_Parents', 'topic_Class_P1'
    const sendPromises = targets.map(target => {
      const topicName = target.replace(/[^a-zA-Z0-9-_.~%]/g, '_');
      return admin.messaging().send({
        topic: `topic_${topicName}`,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        android: {
          priority: "high",
          notification: { channelId: "school_pulse_alerts" },
        },
        apns: {
          payload: { aps: { sound: "default" } },
        },
      });
    });

    await Promise.all(sendPromises);
    await event.data.ref.update({ status: "sent", sentAt: admin.firestore.FieldValue.serverTimestamp() });
  } catch (err) {
    console.error("Broadcast failed:", err);
    await event.data.ref.update({ status: "failed", error: err.message });
  }
});

/**
 * Triggered when a new document is added to 'notification_queue'.
 * Delivers a direct push notification to a specific device token.
 */
exports.processDirectNotificationQueue = onDocumentCreated("notification_queue/{id}", async (event) => {
  const data = event.data.data();
  if (data.status !== "pending") return;

  const { token, notification, data: extraData } = data;

  try {
    await admin.messaging().send({
      token: token,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: extraData || {},
      android: {
        priority: "high",
        notification: { channelId: "school_pulse_alerts" },
      },
      apns: {
        payload: { aps: { sound: "default" } },
      },
    });
    await event.data.ref.update({ status: "sent", sentAt: admin.firestore.FieldValue.serverTimestamp() });
  } catch (err) {
    console.error("Direct notification failed:", err);
    await event.data.ref.update({ status: "failed", error: err.message });
  }
});

/**
 * Placeholder for SMS delivery. In a real app, this would call
 * Twilio or Africa's Talking API.
 */
exports.processSmsQueue = onDocumentCreated("sms_queue/{id}", async (event) => {
  const data = event.data.data();
  if (data.status !== "pending") return;

  // Implementation depends on your SMS provider
  console.log("SMS Queue triggered for:", data.targets);
  await event.data.ref.update({ status: "processed_placeholder" });
});

/**
 * processBroadcastQueue/processSmsQueue above only fire once, when the
 * queue doc is first created, and both ignore status "scheduled" - so a
 * broadcast scheduled for later was written once and then silently never
 * revisited by anything. This runs periodically and delivers any broadcast
 * whose scheduled time has arrived.
 */
exports.processScheduledBroadcasts = onSchedule("every 5 minutes", async () => {
  const now = admin.firestore.Timestamp.now();

  const dueBroadcasts = await admin.firestore()
    .collection("broadcast_queue")
    .where("status", "==", "scheduled")
    .where("scheduledAt", "<=", now)
    .get();

  for (const doc of dueBroadcasts.docs) {
    const { notification, targets } = doc.data();
    try {
      await Promise.all(targets.map((target) => {
        const topicName = target.replace(/[^a-zA-Z0-9-_.~%]/g, "_");
        return admin.messaging().send({
          topic: `topic_${topicName}`,
          notification: { title: notification.title, body: notification.body },
          android: { priority: "high", notification: { channelId: "school_pulse_alerts" } },
          apns: { payload: { aps: { sound: "default" } } },
        });
      }));
      await doc.ref.update({ status: "sent", sentAt: admin.firestore.FieldValue.serverTimestamp() });
    } catch (err) {
      console.error("Scheduled broadcast failed:", err);
      await doc.ref.update({ status: "failed", error: err.message });
    }
  }

  const dueSms = await admin.firestore()
    .collection("sms_queue")
    .where("status", "==", "scheduled")
    .where("scheduledAt", "<=", now)
    .get();
  for (const doc of dueSms.docs) {
    console.log("Scheduled SMS queue triggered for:", doc.data().targets);
    await doc.ref.update({ status: "processed_placeholder" });
  }

  // Keep the matching 'alerts' audit doc (Recent Broadcasts list) in sync
  // so its status badge doesn't stay stuck on "scheduled" forever.
  const dueAlerts = await admin.firestore()
    .collection("alerts")
    .where("status", "==", "scheduled")
    .where("scheduledAt", "<=", now)
    .get();
  for (const doc of dueAlerts.docs) {
    await doc.ref.update({ status: "sent" });
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

/**
 * Notification module (fan-out, scheduling, escalation, retention, delivery
 * testing). Kept in its own file so this one is not disturbed; re-exported
 * here because the Firebase CLI only deploys what index.js exports.
 */
const notificationFunctions = require("./notifications");

exports.processNotificationRequest = notificationFunctions.processNotificationRequest;
exports.dispatchScheduledNotifications = notificationFunctions.dispatchScheduledNotifications;
exports.escalateUnacknowledgedAlerts = notificationFunctions.escalateUnacknowledgedAlerts;
exports.purgeExpiredNotifications = notificationFunctions.purgeExpiredNotifications;
exports.sendTestNotification = notificationFunctions.sendTestNotification;
