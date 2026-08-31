/**
 * Shared helper for enqueueing a notification via the
 * notification_requests -> notifications pipeline (functions/notifications.js
 * processNotificationRequest trigger fans this out to per-user documents,
 * push, and best-effort email/SMS). Callers must never write to the
 * `notifications` collection directly - this is the only supported entry
 * point, originally inlined in report_card_release.js and extracted here so
 * every module (report cards, Exam Factory, ...) shares one implementation.
 *
 * Keep notification bodies generic for anything gated or confidential -
 * identifiers belong in `sourceEntityId`/`metadata`, never grades, marks,
 * question text or financial amounts in `title`/`shortBody`. The deep-link
 * router re-checks access before the recipient ever sees real content, so
 * the notification itself must not leak it first.
 */
module.exports = ({ admin }) => {
  const db = admin.firestore();
  const FieldValue = admin.firestore.FieldValue;

  async function enqueueNotification({
    schoolId,
    recipientUid,
    recipientRoles,
    type,
    title,
    shortBody,
    idempotencyKey,
    category = 'academics',
    priority = 'medium',
    senderNameSnapshot = 'School Pulse',
    senderRoleSnapshot = 'System',
    sourceModule = 'system',
    sourceEntityId = null,
    metadata = {},
  }) {
    const audience = recipientUid
      ? { kind: 'users', userIds: [recipientUid] }
      : recipientRoles && recipientRoles.length
        ? { kind: 'roles', roles: recipientRoles }
        : null;
    if (!audience) return;
    await db.collection('notification_requests').add({
      schoolId,
      category,
      type,
      title,
      shortBody,
      priority,
      senderNameSnapshot,
      senderRoleSnapshot,
      senderKind: 'automated',
      sourceModule,
      ...(sourceEntityId ? { sourceEntityId } : {}),
      audience,
      status: 'pending',
      idempotencyKey,
      metadata,
      createdAt: FieldValue.serverTimestamp(),
    });
  }

  return { enqueueNotification };
};
