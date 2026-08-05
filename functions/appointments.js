const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

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
