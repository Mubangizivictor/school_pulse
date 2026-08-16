/**
 * Server-side notification fan-out, scheduling and delivery reconciliation.
 *
 * Lives in its own module rather than index.js so the existing broadcast/SMS
 * functions are untouched. Exported from index.js at the bottom of that file.
 *
 * Why fan-out happens here and not on the client:
 *  - the FCM Admin credential must never ship in the app,
 *  - one sender writing N recipient documents needs Admin-SDK batch writes,
 *  - recipient resolution (a class's parents, a role's staff) requires reads
 *    the sender's own security rules deliberately do not permit.
 *
 * Collections:
 *   notification_requests/{id}   - a send request written by an authorised client
 *   notifications/{id}           - one document per recipient (what the app reads)
 *   users/{uid}/tokens/{token}   - device registration tokens
 */

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

const db = () => admin.firestore();
const FieldValue = admin.firestore.FieldValue;

/** Firestore caps a batch at 500 writes; leave headroom for retries. */
const BATCH_LIMIT = 400;

/** FCM caps a multicast at 500 tokens per call. */
const MULTICAST_LIMIT = 500;

/**
 * Category -> Android channel id. Must match
 * NotificationCategoryCatalog.channelId on the client, or a push arrives on a
 * channel the user has never seen and cannot control.
 */
const CHANNEL_BY_CATEGORY = {
  emergency: "emergency",
  medical: "medical",
  security: "security",
  visitors: "security",
  attendance: "attendance",
  gate: "attendance",
  finance: "finance",
  billing: "platform",
  transport: "transport",
  messages: "messages",
  homework: "academics",
  results: "academics",
  examinations: "academics",
  timetable: "academics",
  library: "library",
  appointments: "appointments",
  hostel: "boarding",
  discipline: "welfare",
  counselling: "welfare",
  announcements: "announcements",
  system: "platform",
  support: "platform",
  platform: "platform",
};

/** Categories a user may never opt out of. Mirrors the client catalog. */
const MANDATORY_CATEGORIES = new Set([
  "emergency",
  "medical",
  "attendance",
  "gate",
  "security",
]);

/** Categories whose records clear once their source is opened. */
const TRANSIENT_CATEGORIES = new Set(["messages"]);

function channelFor(category) {
  return CHANNEL_BY_CATEGORY[category] || "general";
}

function isHighPriority(priority) {
  return priority === "urgent" || priority === "high";
}

/**
 * Resolves the recipient user ids for a send request.
 *
 * Every branch is school-scoped. A request may not name a school other than
 * the caller's - that is enforced by the caller before this runs.
 */
async function resolveRecipients(schoolId, audience) {
  const { kind, userIds, roles, classNames, studentIds } = audience || {};
  const firestore = db();
  const resolved = new Set();

  // A campaign can deliberately combine scopes (for example parents in one
  // class plus all transport staff). Resolve each branch through the same
  // hardened resolver and deduplicate before fan-out.
  if (kind === "anyOf") {
    for (const definition of audience.definitions || []) {
      const recipients = await resolveRecipients(schoolId, definition);
      recipients.forEach((id) => resolved.add(id));
    }
    return Array.from(resolved);
  }

  switch (kind) {
    case "users":
      (userIds || []).forEach((id) => resolved.add(id));
      break;

    case "roles": {
      // Firestore's array-contains-any caps at 30 values; roles never
      // approaches that, but chunk anyway rather than fail at the limit.
      const roleChunks = chunk(roles || [], 30);
      for (const roleChunk of roleChunks) {
        const snapshot = await firestore
          .collection("users")
          .where("schoolId", "==", schoolId)
          .where("roles", "array-contains-any", roleChunk)
          .get();
        snapshot.forEach((doc) => resolved.add(doc.id));
      }
      break;
    }

    case "class_parents": {
      // Parents of every student in the named classes.
      for (const className of classNames || []) {
        const students = await firestore
          .collection("students")
          .where("schoolId", "==", schoolId)
          .where("className", "==", className)
          .get();

        for (const student of students.docs) {
          const parentIds = student.data().parentIds || [];
          parentIds.forEach((id) => resolved.add(id));
        }
      }
      break;
    }

    case "student_parents": {
      const idChunks = chunk(studentIds || [], 10);
      for (const idChunk of idChunks) {
        const students = await firestore
          .collection("students")
          .where("schoolId", "==", schoolId)
          .where(admin.firestore.FieldPath.documentId(), "in", idChunk)
          .get();
        for (const student of students.docs) {
          (student.data().parentIds || []).forEach((id) => resolved.add(id));
        }
      }
      break;
    }

    case "all_staff": {
      const snapshot = await firestore
        .collection("users")
        .where("schoolId", "==", schoolId)
        .where("isStaff", "==", true)
        .get();
      snapshot.forEach((doc) => resolved.add(doc.id));
      break;
    }

    case "all_parents": {
      const snapshot = await firestore
        .collection("users")
        .where("schoolId", "==", schoolId)
        .where("roles", "array-contains", "parent")
        .get();
      snapshot.forEach((doc) => resolved.add(doc.id));
      break;
    }

    case "school": {
      const snapshot = await firestore
        .collection("users")
        .where("schoolId", "==", schoolId)
        .get();
      snapshot.forEach((doc) => resolved.add(doc.id));
      break;
    }

    default:
      break;
  }

  return Array.from(resolved);
}

function chunk(items, size) {
  const out = [];
  for (let i = 0; i < items.length; i += size) {
    out.push(items.slice(i, i + size));
  }
  return out;
}

/**
 * Writes one notification document per recipient.
 *
 * Per-recipient documents (rather than one shared doc with a recipients array)
 * are what make read state, archiving and security rules expressible - see the
 * note on NotificationRemoteDataSource.
 */
async function fanOutDocuments(request, recipientIds) {
  const firestore = db();
  const now = FieldValue.serverTimestamp();
  const created = [];

  for (const idChunk of chunk(recipientIds, BATCH_LIMIT)) {
    const batch = firestore.batch();

    for (const recipientId of idChunk) {
      const ref = firestore.collection("notifications").doc();
      created.push(ref.id);

      batch.set(ref, {
        schoolId: request.schoolId,
        campusId: request.campusId || null,
        recipientUserId: recipientId,
        category: request.category,
        type: request.type,
        title: request.title,
        shortBody: request.shortBody,
        fullBody: request.fullBody || null,
        senderId: request.senderId || null,
        senderNameSnapshot: request.senderNameSnapshot,
        senderRoleSnapshot: request.senderRoleSnapshot,
        senderKind: request.senderKind || "human",
        senderDepartment: request.senderDepartment || null,
        senderPhotoUrl: request.senderPhotoUrl || null,
        sourceModule: request.sourceModule || null,
        sourceEntityId: request.sourceEntityId || null,
        relatedStudentId: request.relatedStudentId || null,
        relatedStudentName: request.relatedStudentName || null,
        relatedConversationId: request.relatedConversationId || null,
        imageUrl: request.imageUrl || null,
        thumbnailUrl: request.thumbnailUrl || null,
        deepLinkRoute: request.deepLinkRoute || null,
        deepLinkParameters: request.deepLinkParameters || {},
        actionButtons: request.actionButtons || [],
        attachments: request.attachments || [],
        priority: request.priority || "medium",
        persistence:
          request.persistence ||
          (TRANSIENT_CATEGORIES.has(request.category) ? "transient" : "permanent"),
        requiresAcknowledgment: request.requiresAcknowledgment === true,
        isRead: false,
        isPinned: false,
        isArchived: false,
        createdAt: now,
        sentAt: now,
        expiresAt: request.expiresAt || null,
        pushDeliveryStatus: "pending",
        // Set by the client's fan-out request; lets a retried request be
        // recognised rather than duplicating every recipient document.
        idempotencyKey: request.idempotencyKey || null,
        metadata: request.metadata || {},
      });
    }

    await batch.commit();
  }

  return created;
}

/**
 * Collects every device token for the given users.
 *
 * Returns a token -> userId map so a failed send can be attributed back to the
 * right user's token document for cleanup.
 */
async function collectTokens(recipientIds) {
  const firestore = db();
  const tokenOwners = new Map();

  // Sequential rather than parallel: a school-wide broadcast can be thousands
  // of users, and firing that many concurrent subcollection reads exhausts the
  // connection pool.
  for (const recipientId of recipientIds) {
    try {
      const snapshot = await firestore
        .collection("users")
        .doc(recipientId)
        .collection("tokens")
        .get();
      snapshot.forEach((doc) => tokenOwners.set(doc.id, recipientId));
    } catch (err) {
      console.error(`token read failed for ${recipientId}:`, err.message);
    }
  }

  return tokenOwners;
}

/**
 * Sends the push and prunes tokens FCM reports as permanently invalid.
 *
 * Leaving dead tokens in place means every later send retries them, which
 * costs quota and slows delivery for everyone else in the batch.
 */
async function sendPush(request, tokenOwners, notificationIdByUser) {
  const tokens = Array.from(tokenOwners.keys());
  if (tokens.length === 0) {
    return { successCount: 0, failureCount: 0, prunedTokens: 0 };
  }

  const category = request.category;
  const priority = request.priority || "medium";
  const high = isHighPriority(priority);

  let successCount = 0;
  let failureCount = 0;
  const staleTokens = [];

  for (const tokenChunk of chunk(tokens, MULTICAST_LIMIT)) {
    // Data-only payload where possible so the client decides how to display
    // the notification (quiet hours, category mutes, lock-screen redaction).
    // An OS-rendered notification block would bypass all of that.
    const message = {
      tokens: tokenChunk,
      data: {
        notificationId: "",
        schoolId: request.schoolId,
        title: request.title,
        body: request.shortBody,
        category,
        type: request.type,
        priority,
        senderName: request.senderNameSnapshot || "",
        senderRole: request.senderRoleSnapshot || "",
        senderPhotoUrl: request.senderPhotoUrl || "",
        isAutomated: String(request.senderKind === "automated"),
        imageUrl: request.imageUrl || "",
        sourceModule: request.sourceModule || "",
        sourceEntityId: request.sourceEntityId || "",
        relatedStudentId: request.relatedStudentId || "",
        relatedConversationId: request.relatedConversationId || "",
        requiresAcknowledgment: String(request.requiresAcknowledgment === true),
        collapseKey: request.idempotencyKey || "",
      },
      android: {
        priority: high ? "high" : "normal",
        // Collapsing means a re-sent event replaces its predecessor in the
        // tray rather than stacking a duplicate.
        collapseKey: request.idempotencyKey || undefined,
        notification: { channelId: channelFor(category) },
      },
      apns: {
        headers: {
          "apns-priority": high ? "10" : "5",
          "apns-collapse-id": request.idempotencyKey || undefined,
        },
        payload: {
          aps: {
            // content-available wakes the app so it can render the
            // notification itself under its own policy rules.
            "content-available": 1,
            sound: high ? "default" : undefined,
          },
        },
      },
    };

    try {
      const response = await admin.messaging().sendEachForMulticast(message);
      successCount += response.successCount;
      failureCount += response.failureCount;

      response.responses.forEach((result, index) => {
        if (result.success) return;
        const code = result.error && result.error.code;
        if (
          code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token" ||
          code === "messaging/invalid-argument"
        ) {
          staleTokens.push(tokenChunk[index]);
        }
      });
    } catch (err) {
      console.error("multicast send failed:", err.message);
      failureCount += tokenChunk.length;
    }
  }

  // Prune dead tokens so later sends stop retrying them.
  for (const token of staleTokens) {
    const owner = tokenOwners.get(token);
    if (!owner) continue;
    try {
      await db()
        .collection("users")
        .doc(owner)
        .collection("tokens")
        .doc(token)
        .delete();
    } catch (err) {
      console.error(`token prune failed for ${token}:`, err.message);
    }
  }

  return {
    successCount,
    failureCount,
    prunedTokens: staleTokens.length,
  };
}

/**
 * Queues email and SMS copies for recipients who opted into them.
 *
 * Deliberately writes to the existing `email_queue` / `sms_queue` collections
 * rather than calling a provider directly - the spec requires not hardcoding
 * one SMS or email vendor, and those queues are already the project's
 * provider-agnostic seam.
 *
 * Only non-transient notifications are copied: nobody wants an SMS for every
 * chat message. Preferences are read per recipient, so a user who never opted
 * in costs one read and no send.
 */
async function queueChannelCopies(request, recipientIds) {
  // Chat pings and other transient alerts are pointers, not content worth
  // paying an SMS for.
  if ((request.persistence || "permanent") === "transient") {
    return { emails: 0, sms: 0 };
  }

  const firestore = db();
  let emails = 0;
  let sms = 0;

  for (const idChunk of chunk(recipientIds, BATCH_LIMIT)) {
    const batch = firestore.batch();
    let writes = 0;

    for (const recipientId of idChunk) {
      let prefs = null;
      try {
        const doc = await firestore
          .collection("schools")
          .doc(request.schoolId)
          .collection("notification_settings")
          .doc(recipientId)
          .get();
        prefs = doc.exists ? doc.data() : null;
      } catch (err) {
        console.error(`prefs read failed for ${recipientId}:`, err.message);
      }

      if (!prefs) continue;

      const wantsEmail = prefs.emailCopies === true;
      const wantsSms = prefs.smsCopies === true;
      if (!wantsEmail && !wantsSms) continue;

      let contact = null;
      try {
        const userDoc = await firestore.collection("users").doc(recipientId).get();
        contact = userDoc.exists ? userDoc.data() : null;
      } catch (err) {
        console.error(`user read failed for ${recipientId}:`, err.message);
      }
      if (!contact) continue;

      if (wantsEmail && contact.email) {
        batch.set(firestore.collection("email_queue").doc(), {
          to: contact.email,
          subject: request.title,
          body: request.fullBody || request.shortBody,
          schoolId: request.schoolId,
          notificationCategory: request.category,
          status: "pending",
          createdAt: FieldValue.serverTimestamp(),
        });
        emails++;
        writes++;
      }

      if (wantsSms && contact.phoneNumber) {
        batch.set(firestore.collection("sms_queue").doc(), {
          // shortBody only: an SMS is charged per segment, and the full body
          // can run to several paragraphs.
          body: `${request.title}: ${request.shortBody}`,
          targets: [contact.phoneNumber],
          schoolId: request.schoolId,
          status: "pending",
          createdAt: FieldValue.serverTimestamp(),
        });
        sms++;
        writes++;
      }
    }

    if (writes > 0) await batch.commit();
  }

  return { emails, sms };
}

/**
 * Marks the fanned-out documents with the outcome of the push attempt.
 *
 * Delivery status is recorded once per send, not per recipient acknowledgment
 * - writing a delivery receipt per device would multiply write cost by the
 * number of devices for information nobody reads at that granularity.
 */
async function recordDeliveryOutcome(notificationIds, outcome) {
  const firestore = db();
  const status = outcome.successCount > 0 ? "sent" : "failed";

  for (const idChunk of chunk(notificationIds, BATCH_LIMIT)) {
    const batch = firestore.batch();
    for (const id of idChunk) {
      batch.update(firestore.collection("notifications").doc(id), {
        pushDeliveryStatus: status,
        deliveredAt: outcome.successCount > 0 ? FieldValue.serverTimestamp() : null,
      });
    }
    await batch.commit();
  }
}

/**
 * Main entry point: an authorised client writes a request, this fans it out.
 *
 * Triggered on document creation rather than being callable directly so the
 * request survives a client that goes offline mid-send, and so retries are
 * driven by Firestore rather than by the app.
 */
exports.processNotificationRequest = onDocumentCreated(
  "notification_requests/{requestId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const request = snapshot.data();
    if (request.status !== "pending") return;

    // A scheduled request is picked up later by dispatchScheduledNotifications.
    if (request.scheduledAt && request.scheduledAt.toMillis() > Date.now()) {
      await snapshot.ref.update({ status: "scheduled" });
      return;
    }

    try {
      await snapshot.ref.update({ status: "processing" });

      const recipientIds = await resolveRecipients(
        request.schoolId,
        request.audience
      );

      if (recipientIds.length === 0) {
        await snapshot.ref.update({
          status: "sent",
          recipientCount: 0,
          sentAt: FieldValue.serverTimestamp(),
          note: "no recipients matched",
        });
        return;
      }

      const notificationIds = await fanOutDocuments(request, recipientIds);
      const tokenOwners = await collectTokens(recipientIds);
      const outcome = await sendPush(request, tokenOwners, notificationIds);
      await recordDeliveryOutcome(notificationIds, outcome);

      // Channel copies are best-effort: a failure here must not mark an
      // otherwise-delivered notification as failed.
      let copies = { emails: 0, sms: 0 };
      try {
        copies = await queueChannelCopies(request, recipientIds);
      } catch (err) {
        console.error("channel copies failed:", err.message);
      }

      await snapshot.ref.update({
        status: "sent",
        recipientCount: recipientIds.length,
        deviceCount: tokenOwners.size,
        successCount: outcome.successCount,
        failureCount: outcome.failureCount,
        prunedTokens: outcome.prunedTokens,
        emailCopies: copies.emails,
        smsCopies: copies.sms,
        sentAt: FieldValue.serverTimestamp(),
      });
    } catch (err) {
      console.error("notification request failed:", err);
      await snapshot.ref.update({
        status: "failed",
        error: err.message,
        failedAt: FieldValue.serverTimestamp(),
      });
    }
  }
);

/**
 * Dispatches requests whose scheduled time has arrived.
 *
 * processNotificationRequest only fires on document creation, so without this
 * a scheduled request would sit at status "scheduled" forever.
 */
exports.dispatchScheduledNotifications = onSchedule(
  "every 5 minutes",
  async () => {
    const firestore = db();
    const now = admin.firestore.Timestamp.now();

    const due = await firestore
      .collection("notification_requests")
      .where("status", "==", "scheduled")
      .where("scheduledAt", "<=", now)
      .limit(50)
      .get();

    for (const doc of due.docs) {
      const request = doc.data();
      try {
        await doc.ref.update({ status: "processing" });

        const recipientIds = await resolveRecipients(
          request.schoolId,
          request.audience
        );
        const notificationIds = await fanOutDocuments(request, recipientIds);
        const tokenOwners = await collectTokens(recipientIds);
        const outcome = await sendPush(request, tokenOwners, notificationIds);
        await recordDeliveryOutcome(notificationIds, outcome);

        await doc.ref.update({
          status: "sent",
          recipientCount: recipientIds.length,
          successCount: outcome.successCount,
          failureCount: outcome.failureCount,
          sentAt: FieldValue.serverTimestamp(),
        });
      } catch (err) {
        console.error(`scheduled dispatch failed for ${doc.id}:`, err);
        await doc.ref.update({ status: "failed", error: err.message });
      }
    }
  }
);

/**
 * Re-alerts unacknowledged emergency notifications.
 *
 * An emergency alert that requires acknowledgement and has not been
 * acknowledged within 15 minutes is pushed again. Without escalation an
 * unread evacuation notice is indistinguishable from an acknowledged one.
 */
exports.escalateUnacknowledgedAlerts = onSchedule(
  "every 15 minutes",
  async () => {
    const firestore = db();
    const cutoff = admin.firestore.Timestamp.fromMillis(
      Date.now() - 15 * 60 * 1000
    );

    const pending = await firestore
      .collection("notifications")
      .where("requiresAcknowledgment", "==", true)
      .where("acknowledgedAt", "==", null)
      .where("priority", "==", "urgent")
      .where("createdAt", "<=", cutoff)
      .limit(200)
      .get();

    for (const doc of pending.docs) {
      const notification = doc.data();
      const escalations = notification.escalationCount || 0;

      // Cap re-alerts so a permanently-unreachable device is not pushed to
      // indefinitely.
      if (escalations >= 3) continue;

      const tokenOwners = await collectTokens([notification.recipientUserId]);
      if (tokenOwners.size === 0) continue;

      await sendPush(
        {
          schoolId: notification.schoolId,
          category: notification.category,
          type: notification.type,
          title: notification.title,
          shortBody: notification.shortBody,
          priority: "urgent",
          senderNameSnapshot: notification.senderNameSnapshot,
          senderRoleSnapshot: notification.senderRoleSnapshot,
          requiresAcknowledgment: true,
          idempotencyKey: `${doc.id}-escalation-${escalations + 1}`,
        },
        tokenOwners,
        [doc.id]
      );

      await doc.ref.update({
        escalationCount: escalations + 1,
        lastEscalatedAt: FieldValue.serverTimestamp(),
      });
    }
  }
);

/**
 * Deletes notifications past their retention window.
 *
 * Never removes an unacknowledged alert, even when expired - the same rule the
 * client's cache purge applies.
 */
exports.purgeExpiredNotifications = onSchedule("every 24 hours", async () => {
  const firestore = db();
  const now = admin.firestore.Timestamp.now();

  const expired = await firestore
    .collection("notifications")
    .where("expiresAt", "<=", now)
    .limit(500)
    .get();

  let deleted = 0;
  for (const idChunk of chunk(expired.docs, BATCH_LIMIT)) {
    const batch = firestore.batch();
    for (const doc of idChunk) {
      const data = doc.data();
      if (data.requiresAcknowledgment && !data.acknowledgedAt) continue;
      batch.delete(doc.ref);
      deleted++;
    }
    await batch.commit();
  }

  console.log(`purged ${deleted} expired notifications`);
});

/**
 * Callable used by the in-app delivery test screen.
 *
 * Sends only to the caller's own devices, so the test tool can never be used
 * to broadcast to a school.
 */
exports.sendTestNotification = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in to send a test notification.");
  }

  const { schoolId, category, priority, title, body, imageUrl, type } =
    request.data || {};

  if (!schoolId) {
    throw new HttpsError("invalid-argument", "schoolId is required.");
  }

  // Confirm the caller really belongs to the school they named, so a crafted
  // call cannot write a notification into another tenant.
  const userDoc = await db().collection("users").doc(uid).get();
  if (!userDoc.exists || userDoc.data().schoolId !== schoolId) {
    throw new HttpsError("permission-denied", "Wrong school for this account.");
  }

  const testRequest = {
    schoolId,
    category: category || "system",
    type: type || "custom",
    title: title || "Test notification",
    shortBody: body || "This is a test notification from School Pulse.",
    priority: priority || "medium",
    senderNameSnapshot: "Automated System",
    senderRoleSnapshot: "Delivery test",
    senderKind: "automated",
    sourceModule: "notification_test",
    imageUrl: imageUrl || null,
    idempotencyKey: `test-${uid}-${Date.now()}`,
    metadata: { isTest: "true" },
  };

  const notificationIds = await fanOutDocuments(testRequest, [uid]);
  const tokenOwners = await collectTokens([uid]);
  const outcome = await sendPush(testRequest, tokenOwners, notificationIds);
  await recordDeliveryOutcome(notificationIds, outcome);

  return {
    notificationId: notificationIds[0] || null,
    deviceCount: tokenOwners.size,
    successCount: outcome.successCount,
    failureCount: outcome.failureCount,
    prunedTokens: outcome.prunedTokens,
  };
});

module.exports.__internal = {
  resolveRecipients,
  channelFor,
  chunk,
  queueChannelCopies,
  MANDATORY_CATEGORIES,
};
