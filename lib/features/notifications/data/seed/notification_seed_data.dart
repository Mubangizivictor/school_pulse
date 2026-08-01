import '../../domain/entities/notification_model.dart';

/// Development-only seed notifications.
///
/// Covers every UI state the notification centre can render, so the screens
/// can be exercised without waiting for real events: read/unread/pinned/
/// archived, each priority, acknowledgement required and satisfied, delivery
/// failure, scheduled, missing image, expired deep-link target, and one
/// notification per audience (parent, student, teacher, staff).
///
/// Every id is prefixed [seedIdPrefix] so seeding is idempotent (re-running
/// replaces rather than duplicates) and removal is exact. Nothing here runs
/// automatically - see NotificationSeedRunner, which refuses to run in a
/// release build.
class NotificationSeedData {
  const NotificationSeedData._();

  /// Marks a record as seeded. Removal deletes exactly the ids carrying it.
  static const seedIdPrefix = 'seed_notif_';

  /// Written into `metadata` so a seeded row is identifiable server-side too.
  static const seedMetadataKey = 'seedData';

  /// Builds the full seed set for one recipient.
  ///
  /// Timestamps are relative to [now] so the date grouping in the centre
  /// always shows a realistic spread (today / yesterday / this week) whenever
  /// the seed is run.
  static List<NotificationItem> build({
    required String schoolId,
    required String recipientUserId,
    required String recipientRole,
    DateTime? now,
    String studentId = 'seed_student_1',
    String studentName = 'Brian Mukasa',
  }) {
    final at = now ?? DateTime.now();
    NotificationItem seed({
      required String id,
      required String title,
      required String description,
      required String senderName,
      required String senderRole,
      required NotificationCategory category,
      required NotificationType type,
      required Duration ago,
      NotificationPriority priority = NotificationPriority.medium,
      NotificationStatus status = NotificationStatus.unread,
      NotificationPersistence persistence = NotificationPersistence.permanent,
      String? longMessage,
      String? bannerImageUrl,
      String? relatedStudentId,
      String? relatedStudentName,
      String? relatedConversationId,
      String? sourceModule,
      String? sourceEntityId,
      List<NotificationAttachment> attachments = const [],
      List<NotificationAction> actions = const [],
      bool requiresAcknowledgment = false,
      DateTime? acknowledgedAt,
      DateTime? scheduledAt,
      DateTime? expiresAt,
      bool isArchived = false,
      bool automated = false,
      String? senderPhotoUrl,
      NotificationDeliveryStatus pushStatus =
          NotificationDeliveryStatus.delivered,
      String? failureReason,
    }) {
      final timestamp = at.subtract(ago);
      return NotificationItem(
        id: '$seedIdPrefix$id',
        title: title,
        description: description,
        senderName: senderName,
        senderRole: senderRole,
        senderAvatar: senderPhotoUrl,
        timestamp: timestamp,
        category: category,
        priority: priority,
        status: status,
        attachments: attachments,
        bannerImageUrl: bannerImageUrl,
        longMessage: longMessage,
        schoolId: schoolId,
        recipientUserId: recipientUserId,
        recipientRole: recipientRole,
        type: type,
        persistence: persistence,
        sender: automated
            ? NotificationSender.automated(
                module: sourceModule ?? 'system',
                reason: 'Seeded development data',
              )
            : NotificationSender(
                senderId: 'seed_sender',
                nameSnapshot: senderName,
                roleSnapshot: senderRole,
                photoUrl: senderPhotoUrl,
              ),
        sourceModule: sourceModule,
        sourceEntityId: sourceEntityId,
        relatedStudentId: relatedStudentId,
        relatedStudentName: relatedStudentName,
        relatedConversationId: relatedConversationId,
        actions: actions,
        scheduledAt: scheduledAt,
        sentAt: timestamp,
        deliveredAt: pushStatus == NotificationDeliveryStatus.delivered
            ? timestamp
            : null,
        readAt: status == NotificationStatus.unread ? null : timestamp,
        acknowledgedAt: acknowledgedAt,
        expiresAt: expiresAt,
        requiresAcknowledgment: requiresAcknowledgment,
        isArchived: isArchived,
        pushDeliveryStatus: pushStatus,
        failureReason: failureReason,
        metadata: const {seedMetadataKey: 'true'},
      );
    }

    return [
      // --- Announcement with image and attachment -------------------------
      seed(
        id: 'announcement_image',
        title: 'Sports Day 2026',
        description:
            'Inter-house sports day takes place on Saturday. Parents welcome.',
        longMessage:
            'Inter-house sports day takes place this Saturday from 8:00am on '
            'the main field.\n\nAll parents and guardians are warmly invited. '
            'Students should report in their house colours.\n\nRefreshments '
            'will be available.',
        senderName: 'Academic Office',
        senderRole: 'School Administration',
        category: NotificationCategory.announcements,
        type: NotificationType.announcement,
        ago: const Duration(minutes: 22),
        bannerImageUrl:
            'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800',
        attachments: [
          NotificationAttachment(
            name: 'Sports_Day_Programme.pdf',
            type: 'PDF',
            size: '1.2 MB',
            url: 'https://example.com/sports-day.pdf',
          ),
        ],
        sourceModule: 'announcements',
        sourceEntityId: 'seed_announcement_1',
      ),

      // --- Attendance: gate arrival (automated) ---------------------------
      seed(
        id: 'gate_arrival',
        title: 'Arrived at school',
        description: '$studentName was scanned in at the main gate at 7:12am.',
        senderName: 'Automated System',
        senderRole: 'Gate Attendance',
        category: NotificationCategory.gate,
        type: NotificationType.gateEntry,
        priority: NotificationPriority.high,
        ago: const Duration(hours: 3),
        automated: true,
        relatedStudentId: studentId,
        relatedStudentName: studentName,
        sourceModule: 'attendance',
        sourceEntityId: 'seed_gate_1',
      ),

      // --- Late arrival ---------------------------------------------------
      seed(
        id: 'late_arrival',
        title: 'Late arrival',
        description: '$studentName arrived 25 minutes after assembly began.',
        senderName: 'Automated System',
        senderRole: 'Attendance System',
        category: NotificationCategory.attendance,
        type: NotificationType.lateArrival,
        ago: const Duration(days: 1, hours: 2),
        automated: true,
        relatedStudentId: studentId,
        relatedStudentName: studentName,
        sourceModule: 'attendance',
        sourceEntityId: 'seed_late_1',
      ),

      // --- Report card published (read) -----------------------------------
      seed(
        id: 'report_card',
        title: 'Term 2 report card published',
        description: "$studentName's report card is now available to view.",
        senderName: 'Sarah Namusoke',
        senderRole: 'Class Teacher',
        category: NotificationCategory.results,
        type: NotificationType.reportCardPublished,
        status: NotificationStatus.read,
        ago: const Duration(days: 2),
        relatedStudentId: studentId,
        relatedStudentName: studentName,
        sourceModule: 'reports',
        sourceEntityId: 'seed_report_1',
        actions: const [
          NotificationAction(
            id: 'view_report',
            label: 'View report card',
            deepLinkRoute: '/parent/academics/report-card',
          ),
        ],
      ),

      // --- Fee reminder (high priority, pinned) ---------------------------
      seed(
        id: 'fee_reminder',
        title: 'Term 2 fees due',
        description: 'A balance of UGX 450,000 is due by 30 August 2026.',
        senderName: 'Finance Office',
        senderRole: 'Bursar',
        category: NotificationCategory.finance,
        type: NotificationType.feeReminder,
        priority: NotificationPriority.high,
        status: NotificationStatus.pinned,
        ago: const Duration(hours: 6),
        relatedStudentId: studentId,
        relatedStudentName: studentName,
        sourceModule: 'finance',
        sourceEntityId: 'seed_fee_1',
        expiresAt: at.add(const Duration(days: 21)),
        actions: const [
          NotificationAction(
            id: 'view_statement',
            label: 'View statement',
            deepLinkRoute: '/parent/fees',
          ),
          NotificationAction(
            id: 'pay_now',
            label: 'Pay now',
            deepLinkRoute: '/parent/fees/pay',
          ),
        ],
      ),

      // --- Payment received (receipt) -------------------------------------
      seed(
        id: 'payment_received',
        title: 'Payment received',
        description: 'UGX 300,000 received. Receipt SP-2026-00841 generated.',
        senderName: 'Finance Office',
        senderRole: 'Bursar',
        category: NotificationCategory.finance,
        type: NotificationType.paymentReceived,
        status: NotificationStatus.read,
        ago: const Duration(days: 4),
        relatedStudentId: studentId,
        relatedStudentName: studentName,
        sourceModule: 'finance',
        sourceEntityId: 'seed_receipt_1',
        attachments: [
          NotificationAttachment(
            name: 'Receipt_SP-2026-00841.pdf',
            type: 'PDF',
            size: '184 KB',
            url: 'https://example.com/receipt.pdf',
          ),
        ],
      ),

      // --- New message (transient) ----------------------------------------
      seed(
        id: 'new_message',
        title: 'Sarah Namusoke',
        description: 'Good morning, could we discuss Brian\'s progress?',
        senderName: 'Sarah Namusoke',
        senderRole: 'Class Teacher',
        category: NotificationCategory.messages,
        type: NotificationType.newMessage,
        persistence: NotificationPersistence.transient,
        ago: const Duration(minutes: 8),
        relatedConversationId: 'seed_chat_1',
        sourceModule: 'messages',
        sourceEntityId: 'seed_chat_1',
      ),

      // --- Appointment approved -------------------------------------------
      seed(
        id: 'appointment_approved',
        title: 'Appointment confirmed',
        description:
            'Your meeting with the Head Teacher is confirmed for Thursday 2pm.',
        senderName: 'Reception',
        senderRole: 'Front Office',
        category: NotificationCategory.appointments,
        type: NotificationType.appointmentApproved,
        status: NotificationStatus.read,
        ago: const Duration(days: 1, hours: 5),
        sourceModule: 'appointments',
        sourceEntityId: 'seed_appointment_1',
      ),

      // --- Visitor arrived (staff-facing) ---------------------------------
      seed(
        id: 'visitor_arrived',
        title: 'Visitor at the gate',
        description: 'Mr John Kato is waiting at reception to see you.',
        senderName: 'Security Office',
        senderRole: 'Gatekeeper',
        category: NotificationCategory.visitors,
        type: NotificationType.visitorArrived,
        priority: NotificationPriority.high,
        ago: const Duration(minutes: 45),
        sourceModule: 'visitors',
        sourceEntityId: 'seed_visitor_1',
      ),

      // --- Transport delay ------------------------------------------------
      seed(
        id: 'transport_delay',
        title: 'Bus 15 running late',
        description:
            'Route 15 is approximately 20 minutes behind due to traffic.',
        senderName: 'Transport Desk',
        senderRole: 'Transport Coordinator',
        category: NotificationCategory.transport,
        type: NotificationType.busDelayed,
        ago: const Duration(hours: 9),
        relatedStudentId: studentId,
        relatedStudentName: studentName,
        sourceModule: 'transport',
        sourceEntityId: 'seed_trip_1',
      ),

      // --- Library overdue ------------------------------------------------
      seed(
        id: 'library_overdue',
        title: 'Overdue library book',
        description: '"Things Fall Apart" was due back on 28 July.',
        senderName: 'School Library',
        senderRole: 'Librarian',
        category: NotificationCategory.library,
        type: NotificationType.bookOverdue,
        priority: NotificationPriority.low,
        status: NotificationStatus.read,
        ago: const Duration(days: 3),
        relatedStudentId: studentId,
        relatedStudentName: studentName,
        sourceModule: 'library',
        sourceEntityId: 'seed_loan_1',
      ),

      // --- Homework assigned ----------------------------------------------
      seed(
        id: 'homework_assigned',
        title: 'New Mathematics homework',
        description: 'Exercise 4.2, due Friday. Estimated 40 minutes.',
        senderName: 'Sarah Namusoke',
        senderRole: 'Class Teacher',
        category: NotificationCategory.homework,
        type: NotificationType.homeworkAssigned,
        ago: const Duration(days: 1),
        relatedStudentId: studentId,
        relatedStudentName: studentName,
        sourceModule: 'homework',
        sourceEntityId: 'seed_homework_1',
      ),

      // --- Examination timetable ------------------------------------------
      seed(
        id: 'exam_timetable',
        title: 'End of term examination timetable',
        description: 'Examinations begin on 12 September. Timetable attached.',
        senderName: 'Academic Office',
        senderRole: 'Dean of Studies',
        category: NotificationCategory.examinations,
        type: NotificationType.examScheduled,
        status: NotificationStatus.read,
        ago: const Duration(days: 5),
        attachments: [
          NotificationAttachment(
            name: 'Exam_Timetable_Term2.pdf',
            type: 'PDF',
            size: '2.4 MB',
            url: 'https://example.com/timetable.pdf',
          ),
        ],
        sourceModule: 'examinations',
        sourceEntityId: 'seed_exam_1',
      ),

      // --- Medical alert (sensitive, acknowledgement required, satisfied) --
      seed(
        id: 'medical_alert',
        title: 'Visit to the school nurse',
        description:
            '$studentName was seen for a minor injury and has returned to class.',
        senderName: 'Grace Auma',
        senderRole: 'School Nurse',
        category: NotificationCategory.medical,
        type: NotificationType.nurseAlert,
        priority: NotificationPriority.high,
        status: NotificationStatus.read,
        ago: const Duration(days: 1, hours: 8),
        requiresAcknowledgment: true,
        acknowledgedAt: at.subtract(const Duration(days: 1, hours: 7)),
        relatedStudentId: studentId,
        relatedStudentName: studentName,
        sourceModule: 'health',
        sourceEntityId: 'seed_clinic_1',
      ),

      // --- Emergency (urgent, acknowledgement outstanding) ----------------
      seed(
        id: 'emergency_closure',
        title: 'School closed tomorrow',
        description:
            'Due to a burst water main the school will be closed on Tuesday.',
        longMessage:
            'Due to a burst water main affecting the entire compound, School '
            'Pulse Academy will be CLOSED on Tuesday 4 August.\n\nAll lessons '
            'are suspended. Boarding students will be supervised as normal.\n\n'
            'Please acknowledge this notice so we know you have received it.',
        senderName: 'Head Teacher',
        senderRole: 'School Leadership',
        category: NotificationCategory.emergency,
        type: NotificationType.emergencyAlert,
        priority: NotificationPriority.urgent,
        ago: const Duration(hours: 1),
        requiresAcknowledgment: true,
        sourceModule: 'emergency',
        sourceEntityId: 'seed_emergency_1',
        actions: const [
          NotificationAction(
            id: 'acknowledge',
            label: 'Acknowledge',
            isAcknowledgement: true,
          ),
        ],
      ),

      // --- Failed delivery -------------------------------------------------
      seed(
        id: 'failed_delivery',
        title: 'Club registration closing',
        description: 'Registration for the debate club closes on Friday.',
        senderName: 'Patrick Ojok',
        senderRole: 'Games Master',
        category: NotificationCategory.clubs,
        type: NotificationType.clubNotice,
        priority: NotificationPriority.low,
        ago: const Duration(days: 2, hours: 4),
        pushStatus: NotificationDeliveryStatus.failed,
        failureReason: 'Device token no longer registered',
        sourceModule: 'clubs',
        sourceEntityId: 'seed_club_1',
      ),

      // --- Scheduled (not yet sent) ---------------------------------------
      seed(
        id: 'scheduled_reminder',
        title: 'Parents evening reminder',
        description: 'Parents evening starts at 4pm tomorrow.',
        senderName: 'Academic Office',
        senderRole: 'School Administration',
        category: NotificationCategory.events,
        type: NotificationType.eventNotice,
        ago: const Duration(minutes: 5),
        scheduledAt: at.add(const Duration(days: 1)),
        pushStatus: NotificationDeliveryStatus.pending,
        sourceModule: 'events',
        sourceEntityId: 'seed_event_1',
      ),

      // --- Broken image reference (fallback path) -------------------------
      seed(
        id: 'broken_image',
        title: 'Library refurbishment complete',
        description: 'The upper library reopens on Monday morning.',
        senderName: 'School Library',
        senderRole: 'Librarian',
        category: NotificationCategory.announcements,
        type: NotificationType.announcement,
        status: NotificationStatus.read,
        ago: const Duration(days: 6),
        // Deliberately unreachable, to exercise the placeholder path.
        bannerImageUrl: 'https://example.invalid/deleted-image.jpg',
        sourceModule: 'announcements',
        sourceEntityId: 'seed_announcement_2',
      ),

      // --- Expired deep-link target ---------------------------------------
      seed(
        id: 'expired_target',
        title: 'Withdrawn results notice',
        description:
            'A results notice that has since been withdrawn by the school.',
        senderName: 'Academic Office',
        senderRole: 'Dean of Studies',
        category: NotificationCategory.results,
        type: NotificationType.resultsPublished,
        status: NotificationStatus.read,
        ago: const Duration(days: 30),
        expiresAt: at.subtract(const Duration(days: 1)),
        relatedStudentId: studentId,
        relatedStudentName: studentName,
        sourceModule: 'reports',
        // Points at a record that does not exist, to exercise the
        // target-missing fallback.
        sourceEntityId: 'seed_deleted_report',
      ),

      // --- Archived --------------------------------------------------------
      seed(
        id: 'archived_notice',
        title: 'Term 1 closing arrangements',
        description: 'Arrangements for the end of Term 1, now concluded.',
        senderName: 'Academic Office',
        senderRole: 'School Administration',
        category: NotificationCategory.announcements,
        type: NotificationType.announcement,
        status: NotificationStatus.read,
        isArchived: true,
        ago: const Duration(days: 60),
        sourceModule: 'announcements',
        sourceEntityId: 'seed_announcement_3',
      ),

      // --- Discipline (sensitive) ------------------------------------------
      seed(
        id: 'discipline_note',
        title: 'Conduct note recorded',
        description:
            'A conduct note has been recorded. Please review at your convenience.',
        senderName: 'Daniel Okello',
        senderRole: 'Guidance & Discipline',
        category: NotificationCategory.discipline,
        type: NotificationType.disciplineCase,
        ago: const Duration(days: 7),
        relatedStudentId: studentId,
        relatedStudentName: studentName,
        sourceModule: 'discipline',
        sourceEntityId: 'seed_discipline_1',
      ),

      // --- Boarding / hostel ------------------------------------------------
      seed(
        id: 'hostel_notice',
        title: 'Dormitory inspection on Sunday',
        description: 'Routine dormitory inspection takes place Sunday evening.',
        senderName: 'Boarding Office',
        senderRole: 'Matron',
        category: NotificationCategory.hostel,
        type: NotificationType.hostelNotice,
        priority: NotificationPriority.low,
        ago: const Duration(days: 2),
        sourceModule: 'boarding',
        sourceEntityId: 'seed_hostel_1',
      ),

      // --- Catering / meal eligibility --------------------------------------
      seed(
        id: 'meal_eligibility',
        title: 'Lunch eligibility updated',
        description: '$studentName is now on the full boarding meal plan.',
        senderName: 'Catering Office',
        senderRole: 'Catering Manager',
        category: NotificationCategory.catering,
        type: NotificationType.mealEligibility,
        priority: NotificationPriority.low,
        status: NotificationStatus.read,
        ago: const Duration(days: 9),
        relatedStudentId: studentId,
        relatedStudentName: studentName,
        sourceModule: 'catering',
        sourceEntityId: 'seed_meal_1',
      ),

      // --- System maintenance ------------------------------------------------
      seed(
        id: 'system_maintenance',
        title: 'Scheduled maintenance',
        description:
            'School Pulse will be briefly unavailable on Sunday at 2am.',
        senderName: 'School Pulse',
        senderRole: 'Platform',
        category: NotificationCategory.system,
        type: NotificationType.systemMaintenance,
        priority: NotificationPriority.low,
        ago: const Duration(days: 11),
        automated: true,
        sourceModule: 'platform',
        sourceEntityId: 'seed_maintenance_1',
      ),
    ];
  }
}
