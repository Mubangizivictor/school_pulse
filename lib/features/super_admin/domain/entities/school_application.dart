import 'package:equatable/equatable.dart';

enum SchoolApplicationStatus {
  emailVerificationPending,
  emailVerified,
  pendingReview,
  approved,
  rejected,
  unknown,
}

SchoolApplicationStatus schoolApplicationStatusFromWire(String? value) {
  switch (value) {
    case 'email_verification_pending':
      return SchoolApplicationStatus.emailVerificationPending;
    case 'email_verified':
      return SchoolApplicationStatus.emailVerified;
    case 'pending_review':
      return SchoolApplicationStatus.pendingReview;
    case 'approved':
      return SchoolApplicationStatus.approved;
    case 'rejected':
      return SchoolApplicationStatus.rejected;
    default:
      return SchoolApplicationStatus.unknown;
  }
}

extension SchoolApplicationStatusX on SchoolApplicationStatus {
  String get wireValue {
    switch (this) {
      case SchoolApplicationStatus.emailVerificationPending:
        return 'email_verification_pending';
      case SchoolApplicationStatus.emailVerified:
        return 'email_verified';
      case SchoolApplicationStatus.pendingReview:
        return 'pending_review';
      case SchoolApplicationStatus.approved:
        return 'approved';
      case SchoolApplicationStatus.rejected:
        return 'rejected';
      case SchoolApplicationStatus.unknown:
        return 'unknown';
    }
  }

  String get label {
    switch (this) {
      case SchoolApplicationStatus.emailVerificationPending:
        return 'Awaiting email verification';
      case SchoolApplicationStatus.emailVerified:
        return 'Email verified';
      case SchoolApplicationStatus.pendingReview:
        return 'Pending review';
      case SchoolApplicationStatus.approved:
        return 'Approved';
      case SchoolApplicationStatus.rejected:
        return 'Rejected';
      case SchoolApplicationStatus.unknown:
        return 'Unknown';
    }
  }
}

class SchoolApplication extends Equatable {
  final String id;
  final String authUid;
  final SchoolApplicationStatus status;
  final String schoolName;
  final String shortName;
  final String schoolEmail;
  final String schoolPhone;
  final String category;
  final String prefix;
  final String motto;
  final String region;
  final String district;
  final String address;
  final String website;
  final String plan;
  final List<String> selectedModules;
  final String administratorName;
  final String administratorEmail;
  final String administratorPhone;
  final bool administratorEmailVerified;
  final bool termsAccepted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;
  final String? schoolId;
  final bool appReady;

  const SchoolApplication({
    required this.id,
    required this.authUid,
    required this.status,
    required this.schoolName,
    required this.shortName,
    required this.schoolEmail,
    required this.schoolPhone,
    required this.category,
    required this.prefix,
    required this.motto,
    required this.region,
    required this.district,
    required this.address,
    required this.website,
    required this.plan,
    required this.selectedModules,
    required this.administratorName,
    required this.administratorEmail,
    required this.administratorPhone,
    required this.administratorEmailVerified,
    required this.termsAccepted,
    this.createdAt,
    this.updatedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
    this.schoolId,
    this.appReady = false,
  });

  bool get canReview => status == SchoolApplicationStatus.pendingReview;

  @override
  List<Object?> get props => [
        id,
        authUid,
        status,
        schoolName,
        shortName,
        schoolEmail,
        schoolPhone,
        category,
        prefix,
        motto,
        region,
        district,
        address,
        website,
        plan,
        selectedModules,
        administratorName,
        administratorEmail,
        administratorPhone,
        administratorEmailVerified,
        termsAccepted,
        createdAt,
        updatedAt,
        reviewedAt,
        reviewedBy,
        rejectionReason,
        schoolId,
        appReady,
      ];
}
