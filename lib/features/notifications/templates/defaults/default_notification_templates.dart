import '../../domain/entities/notification_model.dart';
import '../renderer/notification_template.dart';

/// Built-in notification templates.
///
/// These are the wordings every school starts with. A school may override the
/// text of any of them (see `schools/{id}/notification_templates`), but the ids
/// and the required-field sets are fixed, because the modules that raise these
/// events supply values by id.
///
/// Wordings are deliberately plain and specific: a parent reading a push on a
/// lock screen should understand what happened without opening the app.
class DefaultNotificationTemplates {
  const DefaultNotificationTemplates._();

  static const studentArrival = NotificationTemplate(
    id: 'student_arrival',
    name: 'Student arrival',
    category: NotificationCategory.gate,
    type: NotificationType.gateEntry,
    titleTemplate: 'Arrived at school',
    bodyTemplate: '{studentName} was scanned in at {time}.',
    priority: NotificationPriority.high,
    requiredFields: {TemplateField.studentName, TemplateField.time},
  );

  static const studentDeparture = NotificationTemplate(
    id: 'student_departure',
    name: 'Student departure',
    category: NotificationCategory.gate,
    type: NotificationType.gateExit,
    titleTemplate: 'Left school',
    bodyTemplate: '{studentName} was scanned out at {time}.',
    priority: NotificationPriority.high,
    requiredFields: {TemplateField.studentName, TemplateField.time},
  );

  static const studentAbsent = NotificationTemplate(
    id: 'student_absent',
    name: 'Student absent',
    category: NotificationCategory.attendance,
    type: NotificationType.studentAbsent,
    titleTemplate: 'Marked absent',
    bodyTemplate: '{studentName} was marked absent in {className} on {date}.',
    fullBodyTemplate:
        '{studentName} was marked absent in {className} on {date}.\n\n'
        'If this is unexpected, please contact the school office.',
    requiredFields: {
      TemplateField.studentName,
      TemplateField.className,
      TemplateField.date,
    },
  );

  static const lateArrival = NotificationTemplate(
    id: 'late_arrival',
    name: 'Late arrival',
    category: NotificationCategory.attendance,
    type: NotificationType.lateArrival,
    titleTemplate: 'Late arrival',
    bodyTemplate: '{studentName} arrived late at {time}.',
    requiredFields: {TemplateField.studentName, TemplateField.time},
  );

  static const busBoarded = NotificationTemplate(
    id: 'bus_boarded',
    name: 'Bus boarded',
    category: NotificationCategory.transport,
    type: NotificationType.busBoarded,
    titleTemplate: 'Boarded the bus',
    bodyTemplate: '{studentName} boarded {routeName} at {time}.',
    requiredFields: {
      TemplateField.studentName,
      TemplateField.routeName,
      TemplateField.time,
    },
  );

  static const busDelayed = NotificationTemplate(
    id: 'bus_delayed',
    name: 'Bus delayed',
    category: NotificationCategory.transport,
    type: NotificationType.busDelayed,
    titleTemplate: 'Bus running late',
    bodyTemplate: '{routeName} is delayed. Expected at {stopName} by {time}.',
    requiredFields: {
      TemplateField.routeName,
      TemplateField.stopName,
      TemplateField.time,
    },
  );

  static const reportPublished = NotificationTemplate(
    id: 'report_published',
    name: 'Report card published',
    category: NotificationCategory.results,
    type: NotificationType.reportCardPublished,
    titleTemplate: 'Report card available',
    bodyTemplate: "{studentName}'s report card is now available to view.",
    requiredFields: {TemplateField.studentName},
  );

  static const feeReminder = NotificationTemplate(
    id: 'fee_reminder',
    name: 'Fee reminder',
    category: NotificationCategory.finance,
    type: NotificationType.feeReminder,
    titleTemplate: 'Fees due',
    bodyTemplate:
        'A balance of {balance} is outstanding for {studentName}, due {dueDate}.',
    priority: NotificationPriority.high,
    requiredFields: {
      TemplateField.balance,
      TemplateField.studentName,
      TemplateField.dueDate,
    },
  );

  static const paymentReceived = NotificationTemplate(
    id: 'payment_received',
    name: 'Payment received',
    category: NotificationCategory.finance,
    type: NotificationType.paymentReceived,
    titleTemplate: 'Payment received',
    bodyTemplate:
        '{amount} received for {studentName}. Remaining balance: {balance}.',
    requiredFields: {
      TemplateField.amount,
      TemplateField.studentName,
      TemplateField.balance,
    },
  );

  static const appointmentApproved = NotificationTemplate(
    id: 'appointment_approved',
    name: 'Appointment approved',
    category: NotificationCategory.appointments,
    type: NotificationType.appointmentApproved,
    titleTemplate: 'Appointment confirmed',
    bodyTemplate:
        'Your appointment with {staffName} is confirmed for {appointmentTime}.',
    requiredFields: {TemplateField.staffName, TemplateField.appointmentTime},
  );

  static const appointmentChanged = NotificationTemplate(
    id: 'appointment_changed',
    name: 'Appointment changed',
    category: NotificationCategory.appointments,
    type: NotificationType.appointmentChanged,
    titleTemplate: 'Appointment rescheduled',
    bodyTemplate:
        'Your appointment with {staffName} has moved to {appointmentTime}.',
    requiredFields: {TemplateField.staffName, TemplateField.appointmentTime},
  );

  static const visitorArrived = NotificationTemplate(
    id: 'visitor_arrived',
    name: 'Visitor arrived',
    category: NotificationCategory.visitors,
    type: NotificationType.visitorArrived,
    titleTemplate: 'Visitor at the gate',
    bodyTemplate: '{parentName} is waiting at reception to see you.',
    priority: NotificationPriority.high,
    requiredFields: {TemplateField.parentName},
  );

  static const homeworkAssigned = NotificationTemplate(
    id: 'homework_assigned',
    name: 'Homework assigned',
    category: NotificationCategory.homework,
    type: NotificationType.homeworkAssigned,
    titleTemplate: 'New {subjectName} homework',
    bodyTemplate: 'Due {dueDate} for {className}.',
    requiredFields: {
      TemplateField.subjectName,
      TemplateField.dueDate,
      TemplateField.className,
    },
  );

  static const examScheduled = NotificationTemplate(
    id: 'exam_scheduled',
    name: 'Examination scheduled',
    category: NotificationCategory.examinations,
    type: NotificationType.examScheduled,
    titleTemplate: 'Examination scheduled',
    bodyTemplate: '{subjectName} examination on {date} at {time}.',
    requiredFields: {
      TemplateField.subjectName,
      TemplateField.date,
      TemplateField.time,
    },
  );

  static const libraryOverdue = NotificationTemplate(
    id: 'library_overdue',
    name: 'Library book overdue',
    category: NotificationCategory.library,
    type: NotificationType.bookOverdue,
    titleTemplate: 'Overdue library book',
    bodyTemplate: '"{bookTitle}" was due back on {dueDate}.',
    priority: NotificationPriority.low,
    requiredFields: {TemplateField.bookTitle, TemplateField.dueDate},
  );

  static const medicalAlert = NotificationTemplate(
    id: 'medical_alert',
    name: 'Medical alert',
    category: NotificationCategory.medical,
    type: NotificationType.nurseAlert,
    titleTemplate: 'Visit to the school nurse',
    bodyTemplate: '{studentName} was seen by the nurse at {time}.',
    fullBodyTemplate:
        '{studentName} was seen by the school nurse at {time}.\n\n'
        'Reason: {reason}\n\n'
        'Please acknowledge that you have received this notice.',
    priority: NotificationPriority.high,
    requiresAcknowledgment: true,
    requiredFields: {TemplateField.studentName, TemplateField.time},
  );

  static const emergencyClosure = NotificationTemplate(
    id: 'emergency_closure',
    name: 'Emergency closure',
    category: NotificationCategory.emergency,
    type: NotificationType.emergencyAlert,
    titleTemplate: 'School closed',
    bodyTemplate: '{schoolName} will be closed on {date}.',
    fullBodyTemplate:
        '{schoolName} will be CLOSED on {date}.\n\n'
        'Reason: {reason}\n\n'
        'Please acknowledge this notice so we know you have received it.',
    priority: NotificationPriority.urgent,
    requiresAcknowledgment: true,
    requiredFields: {
      TemplateField.schoolName,
      TemplateField.date,
      TemplateField.reason,
    },
  );

  /// Every built-in template, keyed by id.
  static const Map<String, NotificationTemplate> all = {
    'student_arrival': studentArrival,
    'student_departure': studentDeparture,
    'student_absent': studentAbsent,
    'late_arrival': lateArrival,
    'bus_boarded': busBoarded,
    'bus_delayed': busDelayed,
    'report_published': reportPublished,
    'fee_reminder': feeReminder,
    'payment_received': paymentReceived,
    'appointment_approved': appointmentApproved,
    'appointment_changed': appointmentChanged,
    'visitor_arrived': visitorArrived,
    'homework_assigned': homeworkAssigned,
    'exam_scheduled': examScheduled,
    'library_overdue': libraryOverdue,
    'medical_alert': medicalAlert,
    'emergency_closure': emergencyClosure,
  };

  static NotificationTemplate? byId(String id) => all[id];

  static List<NotificationTemplate> get asList => all.values.toList();

  /// Templates belonging to one category, for a picker grouped by module.
  static List<NotificationTemplate> forCategory(NotificationCategory category) =>
      all.values.where((t) => t.category == category).toList();
}
