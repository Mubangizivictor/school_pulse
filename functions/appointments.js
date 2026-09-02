const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');
const { recordJobRun } = require('./platform_health_instrumentation')({ admin });

function text(value, max = 200) {
  return String(value ?? '').trim().slice(0, max);
}

function timeLabel(timestamp) {
  if (!timestamp || typeof timestamp.toDate !== 'function') return '';
  return timestamp.toDate().toLocaleString('en-GB', {
    day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit',
  });
}

/**
 * Enqueue a templated transactional email for the `public_functions`
 * codebase to send — the same cross-codebase queue functions/index.js's
 * own enqueueTransactionalEmail writes to (email/transactional_queue.js in
 * public_functions/ drains transactional_email_queue regardless of which
 * codebase wrote it). Duplicated here rather than imported since index.js
 * doesn't export it and the two Cloud Functions codebases cannot share code
 * directly (same precedent as BILLING_ROLES duplication elsewhere in this
 * codebase).
 */
async function enqueueTransactionalEmail({ eventId, templateId, to, data = {} }) {
  if (!eventId || !to) return;
  await admin.firestore().collection('transactional_email_queue').doc(eventId).set({
    eventId,
    templateId,
    to: String(to).trim().toLowerCase(),
    data,
    schoolBranding: null,
    status: 'queued',
    attempts: 0,
    scheduledAt: admin.firestore.FieldValue.serverTimestamp(),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    sentAt: null,
    resendId: null,
    error: null,
  }, { merge: true });
}

async function requesterEmail(requesterId) {
  if (!requesterId) return '';
  const snap = await admin.firestore().collection('users').doc(requesterId).get();
  return text(snap.data()?.email, 200);
}

async function schoolName(schoolId) {
  if (!schoolId) return 'Your school';
  const snap = await admin.firestore().collection('schools').doc(schoolId).get();
  return text(snap.data()?.name, 160) || 'Your school';
}

/**
 * Pure decision: given a status transition, which (if any) hosted email
 * fires and under what idempotency key. Extracted so it's testable without
 * a Firestore emulator - notifyAppointmentStatusChange below is a thin
 * wrapper that reads the real documents and calls this.
 */
function classifyAppointmentStatusChange(appointmentId, beforeStatus, afterStatus) {
  if (afterStatus === beforeStatus) return null;
  if (afterStatus === 'approved') {
    return { templateId: 'appointment_confirmed', eventId: `appointment_confirmed_${appointmentId}` };
  }
  if (afterStatus === 'cancelled' || afterStatus === 'rejected') {
    return { templateId: 'appointment_cancelled', eventId: `appointment_cancelled_${appointmentId}` };
  }
  return null;
}

// Scheduling is server-side so reminders survive an offline client and never
// trust a caller to name recipients outside its school. The existing
// notification dispatcher consumes these scheduled notification_requests.
exports.queueAppointmentNotifications = onDocumentCreated(
  'meeting_appointments/{appointmentId}',
  async (event) => {
    const appointment = event.data && event.data.data();
    if (!appointment || !appointment.schoolId || !appointment.scheduledStart) return;
    const db = admin.firestore();
    const start = appointment.scheduledStart.toDate();
    const recipients = [...new Set([appointment.staffId, appointment.requesterId].filter(Boolean))];
    const minutes = Array.isArray(appointment.reminderMinutes) && appointment.reminderMinutes.length
      ? appointment.reminderMinutes : [15];
    const batch = db.batch();

    for (const minutesBefore of minutes) {
      const scheduledAt = new Date(start.getTime() - Number(minutesBefore) * 60000);
      if (scheduledAt <= new Date()) continue;
      const ref = db.collection('notification_requests').doc();
      batch.set(ref, {
        schoolId: appointment.schoolId,
        category: 'appointments',
        type: 'appointment_reminder',
        title: 'Appointment reminder',
        shortBody: `${appointment.appointmentTypeName || 'Appointment'} starts in ${minutesBefore} minutes.`,
        priority: appointment.priority === 'urgent' ? 'high' : 'medium',
        senderNameSnapshot: 'School Pulse',
        senderRoleSnapshot: 'Automated schedule',
        senderKind: 'automated',
        sourceModule: 'appointments',
        audience: { kind: 'users', userIds: recipients },
        scheduledAt: admin.firestore.Timestamp.fromDate(scheduledAt),
        status: 'pending',
        idempotencyKey: `appointment-${event.params.appointmentId}-${minutesBefore}`,
        metadata: { appointmentId: event.params.appointmentId },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        // Read by sendAppointmentReminderEmails below - marks whether this
        // scheduled reminder has already had its email enqueued, so the
        // 5-minute sweep never enqueues the same reminder email twice.
        emailQueued: false,
      });
    }
    if (recipients.length) {
      const ref = db.collection('notification_requests').doc();
      batch.set(ref, {
        schoolId: appointment.schoolId, category: 'appointments', type: 'appointment_created',
        title: appointment.requiresApproval ? 'Appointment awaiting approval' : 'Appointment scheduled',
        shortBody: `${appointment.appointmentTypeName || 'Appointment'} with ${appointment.staffName || 'your host'} has been scheduled.`,
        priority: 'medium', senderNameSnapshot: 'School Pulse', senderRoleSnapshot: 'Automated schedule',
        senderKind: 'automated', sourceModule: 'appointments', audience: { kind: 'users', userIds: recipients },
        status: 'pending', idempotencyKey: `appointment-created-${event.params.appointmentId}`,
        metadata: { appointmentId: event.params.appointmentId }, createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  },
);

// Appointment status changes (approve/decline/cancel) happen via a plain
// client-side Firestore update (AppointmentRemoteDataSourceImpl.
// updateAppointment in lib/features/appointments/data/datasources/) — there
// is no callable or other server-side entry point to hook. This trigger is
// the only server-side observation point for "confirmed"/"cancelled"
// emails, so it fires the matching template to the requester. Idempotent
// per appointmentId (one email per appointment ever reaching that status),
// since sendTemplatedEmail dedupes on eventId regardless of how many times
// this trigger re-fires for the same document.
exports.notifyAppointmentStatusChange = onDocumentUpdated(
  'meeting_appointments/{appointmentId}',
  async (event) => {
    const before = event.data?.before?.data() || {};
    const after = event.data?.after?.data();
    if (!after) return;

    const beforeStatus = text(before.status, 40);
    const afterStatus = text(after.status, 40);
    const appointmentId = event.params.appointmentId;
    const decision = classifyAppointmentStatusChange(appointmentId, beforeStatus, afterStatus);
    if (!decision) return;

    const withLabel = text(after.staffName, 160) || 'your host';
    const [to, school] = await Promise.all([
      requesterEmail(after.requesterId),
      schoolName(after.schoolId),
    ]);
    if (!to) return;

    const data = decision.templateId === 'appointment_confirmed'
      ? {
          schoolName: school,
          appointmentId,
          withLabel,
          timeLabel: timeLabel(after.scheduledStart),
          purpose: text(after.reason, 300),
        }
      : {
          schoolName: school,
          appointmentId,
          withLabel,
          timeLabel: timeLabel(after.scheduledStart),
          reason: text(after.responseNote, 500) || 'No reason given.',
        };

    await enqueueTransactionalEmail({ eventId: decision.eventId, templateId: decision.templateId, to, data })
      .catch((err) => console.error(`${decision.templateId} email enqueue failed`, appointmentId, err));
  },
);

// Reminder EMAIL: reuses the SAME scheduled notification_requests docs
// queueAppointmentNotifications already writes (type: 'appointment_reminder',
// scheduledAt = appointment start minus the configured reminder window) as
// the single source of "when is this reminder due" — no second scheduling
// concept is introduced. transactional_email_queue has no notion of a
// future send time of its own (email_service.js sends as soon as the queue
// is drained), so an email cannot be enqueued at appointment-creation time
// without firing immediately; this 5-minute sweep (matching
// public_functions/email/transactional_queue.js's own retry-sweep cadence)
// picks up due reminder docs and enqueues the email at the right moment,
// marking each one emailed exactly once via emailQueued.
exports.sendAppointmentReminderEmails = onSchedule(
  { region: 'europe-west1', schedule: 'every 5 minutes' },
  async () => {
    await recordJobRun('sendAppointmentReminderEmails', 5, async () => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    // Filters on emailQueued + scheduledAt only (matching the existing
    // status+scheduledAt composite index shape already declared for this
    // collection in firestore.indexes.json) rather than adding category/type
    // to the query, which would require a brand-new composite index; those
    // two are checked in-memory below instead.
    const due = await db.collection('notification_requests')
      .where('emailQueued', '==', false)
      .where('scheduledAt', '<=', now)
      .limit(200)
      .get();

    for (const doc of due.docs) {
      const request = doc.data() || {};
      if (request.category !== 'appointments' || request.type !== 'appointment_reminder') continue;
      const appointmentId = text(request.metadata?.appointmentId, 200);
      if (!appointmentId) {
        await doc.ref.set({ emailQueued: true }, { merge: true });
        continue;
      }
      try {
        const apptSnap = await db.collection('meeting_appointments').doc(appointmentId).get();
        if (apptSnap.exists) {
          const appt = apptSnap.data() || {};
          const [to, school] = await Promise.all([
            requesterEmail(appt.requesterId),
            schoolName(appt.schoolId),
          ]);
          if (to) {
            await enqueueTransactionalEmail({
              eventId: `appointment_reminder_${appointmentId}_${doc.id}`,
              templateId: 'appointment_reminder',
              to,
              data: {
                schoolName: school,
                appointmentId,
                withLabel: text(appt.staffName, 160) || 'your host',
                timeLabel: timeLabel(appt.scheduledStart),
                purpose: text(appt.reason, 300),
              },
            });
          }
        }
      } catch (err) {
        console.error('appointment_reminder email enqueue failed', appointmentId, err);
      }
      await doc.ref.set({ emailQueued: true }, { merge: true });
    }
    });
  },
);

exports.__test__ = { classifyAppointmentStatusChange };
