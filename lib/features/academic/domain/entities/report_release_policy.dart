import 'package:equatable/equatable.dart';

/// Configurable report release policy - never hardcoded. Integrates
/// read-only with the Finance module's fee-clearance status.
enum ReleaseOption {
  everyoneImmediate, // Option 1: everyone can view and download immediately
  onlyFullyClearedFees, // Option 2: only cleared students can view/download
  viewEveryoneDownloadCleared, // Option 3: everyone views, only cleared download/print
  afterSpecificDate, // Option 4: released after a configured date
  manualOverrideOnly, // Option 5: only Bursar/Headteacher can override
}

class ReportReleasePolicy extends Equatable {
  final String id;
  final String schoolId;
  final ReleaseOption option;
  final DateTime? releaseDate; // For Option 4
  final String restrictionMessage;

  const ReportReleasePolicy({
    required this.id,
    required this.schoolId,
    required this.option,
    this.releaseDate,
    this.restrictionMessage =
        "Your report card has been published but cannot be downloaded because your school's fee clearance policy has not yet been met. Please contact the Bursar for assistance.",
  });

  ReportReleasePolicy copyWith({
    ReleaseOption? option,
    DateTime? releaseDate,
    String? restrictionMessage,
  }) {
    return ReportReleasePolicy(
      id: id,
      schoolId: schoolId,
      option: option ?? this.option,
      releaseDate: releaseDate ?? this.releaseDate,
      restrictionMessage: restrictionMessage ?? this.restrictionMessage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    option,
    releaseDate,
    restrictionMessage,
  ];
}
