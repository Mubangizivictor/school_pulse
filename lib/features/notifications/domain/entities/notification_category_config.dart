import 'package:flutter/material.dart';

import 'notification_model.dart';

/// Per-category defaults: presentation treatment, delivery policy and
/// retention. Schools may override individual fields through their notification
/// settings document; this is the fallback when no override exists.
///
/// Kept as data rather than scattered `switch` statements so a school admin
/// toggling "images allowed" or "acknowledgement required" changes behaviour in
/// one place instead of across every screen.
@immutable
class NotificationCategoryConfig {
  final NotificationCategory category;
  final String displayName;
  final IconData icon;

  /// Colour used for the category chip, icon tint and details-screen accent.
  final Color color;

  final NotificationPriority defaultPriority;
  final NotificationPersistence defaultPersistence;

  /// Days a notification of this category is retained before cleanup. `null`
  /// means retain indefinitely (subject to the school's own retention policy).
  final int? retentionDays;

  final bool allowsImages;
  final bool requiresAcknowledgment;

  /// Whether the record survives being opened. Transient categories are cleared
  /// from the centre once the user reaches the underlying source.
  final bool persistsAfterOpen;

  /// Android notification channel id. Grouped so a user silencing "attendance"
  /// silences every attendance-shaped alert at the OS level.
  final String channelId;
  final String? soundName;

  /// Categories carrying personal, medical, financial or safeguarding detail.
  /// These default to a redacted lock-screen preview.
  final bool isSensitive;

  /// Categories a user may not fully disable (legal/safety obligations).
  final bool isMandatory;

  const NotificationCategoryConfig({
    required this.category,
    required this.displayName,
    required this.icon,
    required this.color,
    this.defaultPriority = NotificationPriority.medium,
    this.defaultPersistence = NotificationPersistence.permanent,
    this.retentionDays = 180,
    this.allowsImages = true,
    this.requiresAcknowledgment = false,
    this.persistsAfterOpen = true,
    required this.channelId,
    this.soundName,
    this.isSensitive = false,
    this.isMandatory = false,
  });
}

/// The built-in category catalogue.
///
/// Colours and icons deliberately match what the existing notification screens
/// already draw, so routing category treatment through this table does not
/// change the look of any screen that was previously switching inline.
class NotificationCategoryCatalog {
  const NotificationCategoryCatalog._();

  static const Color _indigo = Colors.black;
  static const Color _green = Colors.black;
  static const Color _amber = Colors.black;
  static const Color _blue = Colors.black;
  static const Color _pink = Colors.black;
  static const Color _violet = Colors.black;
  static const Color _cyan = Colors.black;
  static const Color _slate = Colors.black;
  static const Color _rose = Colors.black;

  static const Map<NotificationCategory, NotificationCategoryConfig>
  _configs = {
    NotificationCategory.announcements: NotificationCategoryConfig(
      category: NotificationCategory.announcements,
      displayName: 'Announcements',
      icon: Icons.campaign,
      color: _indigo,
      channelId: 'announcements',
      retentionDays: 365,
    ),
    NotificationCategory.attendance: NotificationCategoryConfig(
      category: NotificationCategory.attendance,
      displayName: 'Attendance',
      icon: Icons.person_pin_circle,
      color: _green,
      channelId: 'attendance',
      isMandatory: true,
    ),
    NotificationCategory.finance: NotificationCategoryConfig(
      category: NotificationCategory.finance,
      displayName: 'Finance',
      icon: Icons.payments,
      color: _amber,
      channelId: 'finance',
      retentionDays: 730,
      isSensitive: true,
    ),
    NotificationCategory.transport: NotificationCategoryConfig(
      category: NotificationCategory.transport,
      displayName: 'Transport',
      icon: Icons.directions_bus,
      color: _blue,
      channelId: 'transport',
      retentionDays: 90,
    ),
    NotificationCategory.messages: NotificationCategoryConfig(
      category: NotificationCategory.messages,
      displayName: 'Messages',
      icon: Icons.forum,
      color: _violet,
      channelId: 'messages',
      // Chat pings are pointers to a conversation, not records in their own
      // right - they clear once the conversation is opened so the centre does
      // not accumulate one permanent row per message.
      defaultPersistence: NotificationPersistence.transient,
      persistsAfterOpen: false,
      retentionDays: 7,
      allowsImages: false,
    ),
    NotificationCategory.homework: NotificationCategoryConfig(
      category: NotificationCategory.homework,
      displayName: 'Homework',
      icon: Icons.assignment,
      color: _pink,
      channelId: 'academics',
    ),
    NotificationCategory.library: NotificationCategoryConfig(
      category: NotificationCategory.library,
      displayName: 'Library',
      icon: Icons.local_library,
      color: _cyan,
      channelId: 'library',
      retentionDays: 90,
    ),
    NotificationCategory.others: NotificationCategoryConfig(
      category: NotificationCategory.others,
      displayName: 'Others',
      icon: Icons.notifications,
      color: _slate,
      channelId: 'general',
    ),
    NotificationCategory.gate: NotificationCategoryConfig(
      category: NotificationCategory.gate,
      displayName: 'Gate',
      icon: Icons.meeting_room,
      color: _green,
      channelId: 'attendance',
      defaultPriority: NotificationPriority.high,
      retentionDays: 90,
      isMandatory: true,
    ),
    NotificationCategory.results: NotificationCategoryConfig(
      category: NotificationCategory.results,
      displayName: 'Results',
      icon: Icons.grading,
      color: _indigo,
      channelId: 'academics',
      retentionDays: 730,
      isSensitive: true,
    ),
    NotificationCategory.examinations: NotificationCategoryConfig(
      category: NotificationCategory.examinations,
      displayName: 'Examinations',
      icon: Icons.event_note,
      color: _indigo,
      channelId: 'academics',
    ),
    NotificationCategory.timetable: NotificationCategoryConfig(
      category: NotificationCategory.timetable,
      displayName: 'Timetable',
      icon: Icons.schedule,
      color: _blue,
      channelId: 'academics',
      retentionDays: 90,
    ),
    NotificationCategory.medical: NotificationCategoryConfig(
      category: NotificationCategory.medical,
      displayName: 'Medical',
      icon: Icons.medical_services,
      color: _rose,
      channelId: 'medical',
      defaultPriority: NotificationPriority.high,
      requiresAcknowledgment: true,
      isSensitive: true,
      isMandatory: true,
      retentionDays: 730,
    ),
    NotificationCategory.appointments: NotificationCategoryConfig(
      category: NotificationCategory.appointments,
      displayName: 'Appointments',
      icon: Icons.event_available,
      color: _cyan,
      channelId: 'appointments',
    ),
    NotificationCategory.visitors: NotificationCategoryConfig(
      category: NotificationCategory.visitors,
      displayName: 'Visitors',
      icon: Icons.badge,
      color: _blue,
      channelId: 'security',
      retentionDays: 90,
      isSensitive: true,
    ),
    NotificationCategory.security: NotificationCategoryConfig(
      category: NotificationCategory.security,
      displayName: 'Security',
      icon: Icons.shield,
      color: _rose,
      channelId: 'security',
      defaultPriority: NotificationPriority.high,
      requiresAcknowledgment: true,
      isSensitive: true,
      isMandatory: true,
    ),
    NotificationCategory.discipline: NotificationCategoryConfig(
      category: NotificationCategory.discipline,
      displayName: 'Discipline',
      icon: Icons.gavel,
      color: _amber,
      channelId: 'welfare',
      isSensitive: true,
      retentionDays: 730,
    ),
    NotificationCategory.counselling: NotificationCategoryConfig(
      category: NotificationCategory.counselling,
      displayName: 'Counselling',
      icon: Icons.psychology,
      color: _violet,
      channelId: 'welfare',
      isSensitive: true,
      retentionDays: 730,
    ),
    NotificationCategory.clubs: NotificationCategoryConfig(
      category: NotificationCategory.clubs,
      displayName: 'Clubs',
      icon: Icons.groups,
      color: _cyan,
      channelId: 'general',
      retentionDays: 90,
    ),
    NotificationCategory.sports: NotificationCategoryConfig(
      category: NotificationCategory.sports,
      displayName: 'Sports',
      icon: Icons.sports_soccer,
      color: _green,
      channelId: 'general',
      retentionDays: 90,
    ),
    NotificationCategory.catering: NotificationCategoryConfig(
      category: NotificationCategory.catering,
      displayName: 'Catering',
      icon: Icons.restaurant,
      color: _amber,
      channelId: 'general',
      retentionDays: 60,
    ),
    NotificationCategory.hostel: NotificationCategoryConfig(
      category: NotificationCategory.hostel,
      displayName: 'Hostel',
      icon: Icons.night_shelter,
      color: _violet,
      channelId: 'boarding',
    ),
    NotificationCategory.events: NotificationCategoryConfig(
      category: NotificationCategory.events,
      displayName: 'Events',
      icon: Icons.celebration,
      color: _pink,
      channelId: 'general',
      retentionDays: 180,
    ),
    NotificationCategory.emergency: NotificationCategoryConfig(
      category: NotificationCategory.emergency,
      displayName: 'Emergency',
      icon: Icons.warning_amber_rounded,
      color: _rose,
      channelId: 'emergency',
      defaultPriority: NotificationPriority.urgent,
      requiresAcknowledgment: true,
      isMandatory: true,
      retentionDays: null,
      soundName: 'emergency',
    ),
    NotificationCategory.billing: NotificationCategoryConfig(
      category: NotificationCategory.billing,
      displayName: 'Billing',
      icon: Icons.receipt_long,
      color: _amber,
      channelId: 'platform',
      isSensitive: true,
      retentionDays: 730,
    ),
    NotificationCategory.system: NotificationCategoryConfig(
      category: NotificationCategory.system,
      displayName: 'System',
      icon: Icons.settings,
      color: _slate,
      channelId: 'platform',
      retentionDays: 30,
      allowsImages: false,
    ),
    NotificationCategory.support: NotificationCategoryConfig(
      category: NotificationCategory.support,
      displayName: 'Support',
      icon: Icons.support_agent,
      color: _cyan,
      channelId: 'platform',
      retentionDays: 180,
    ),
    NotificationCategory.platform: NotificationCategoryConfig(
      category: NotificationCategory.platform,
      displayName: 'School Pulse',
      icon: Icons.verified,
      color: _indigo,
      channelId: 'platform',
      retentionDays: 180,
    ),
  };

  static const NotificationCategoryConfig _fallback =
      NotificationCategoryConfig(
        category: NotificationCategory.others,
        displayName: 'Notification',
        icon: Icons.notifications,
        color: _slate,
        channelId: 'general',
      );

  /// Config for [category], never null - unknown categories fall back to a
  /// neutral treatment rather than throwing inside a build method.
  static NotificationCategoryConfig of(NotificationCategory category) =>
      _configs[category] ?? _fallback;

  static Iterable<NotificationCategoryConfig> get all => _configs.values;

  /// Categories a user is not permitted to switch off entirely.
  static Set<NotificationCategory> get mandatory => _configs.entries
      .where((e) => e.value.isMandatory)
      .map((e) => e.key)
      .toSet();

  /// Maps a fine-grained [NotificationType] onto the category used for display
  /// grouping. Central so a new event type only needs one entry here to pick up
  /// the right icon, colour, channel and retention behaviour.
  static NotificationCategory categoryForType(NotificationType type) {
    switch (type) {
      case NotificationType.newMessage:
      case NotificationType.groupMessage:
      case NotificationType.messageRequest:
        return NotificationCategory.messages;
      case NotificationType.gateEntry:
      case NotificationType.gateExit:
        return NotificationCategory.gate;
      case NotificationType.lateArrival:
      case NotificationType.studentAbsent:
      case NotificationType.subjectAttendance:
      case NotificationType.boardingRollCall:
        return NotificationCategory.attendance;
      case NotificationType.busBoarded:
      case NotificationType.busDropOff:
      case NotificationType.busDelayed:
      case NotificationType.transportIncident:
        return NotificationCategory.transport;
      case NotificationType.paymentReceived:
      case NotificationType.paymentFailed:
      case NotificationType.feeReminder:
      case NotificationType.receiptGenerated:
        return NotificationCategory.finance;
      case NotificationType.reportCardPublished:
      case NotificationType.resultsPublished:
        return NotificationCategory.results;
      case NotificationType.homeworkAssigned:
      case NotificationType.assignmentDue:
        return NotificationCategory.homework;
      case NotificationType.examScheduled:
      case NotificationType.examQuestionModeration:
      case NotificationType.examPaperWorkflow:
        return NotificationCategory.examinations;
      case NotificationType.timetableUpdated:
        return NotificationCategory.timetable;
      case NotificationType.bookOverdue:
      case NotificationType.bookDueSoon:
        return NotificationCategory.library;
      case NotificationType.nurseAlert:
      case NotificationType.medicalAlert:
        return NotificationCategory.medical;
      case NotificationType.appointmentApproved:
      case NotificationType.appointmentChanged:
      case NotificationType.appointmentReminder:
        return NotificationCategory.appointments;
      case NotificationType.visitorArrived:
        return NotificationCategory.visitors;
      case NotificationType.disciplineCase:
        return NotificationCategory.discipline;
      case NotificationType.counsellingNote:
        return NotificationCategory.counselling;
      case NotificationType.announcement:
        return NotificationCategory.announcements;
      case NotificationType.eventNotice:
        return NotificationCategory.events;
      case NotificationType.clubNotice:
        return NotificationCategory.clubs;
      case NotificationType.sportsNotice:
        return NotificationCategory.sports;
      case NotificationType.mealEligibility:
        return NotificationCategory.catering;
      case NotificationType.hostelNotice:
        return NotificationCategory.hostel;
      case NotificationType.emergencyAlert:
        return NotificationCategory.emergency;
      case NotificationType.securityAlert:
        return NotificationCategory.security;
      case NotificationType.subscriptionNotice:
        return NotificationCategory.billing;
      case NotificationType.systemMaintenance:
        return NotificationCategory.system;
      case NotificationType.supportTicketUpdate:
        return NotificationCategory.support;
      case NotificationType.platformAnnouncement:
        return NotificationCategory.platform;
      case NotificationType.custom:
        return NotificationCategory.others;
    }
  }
}
