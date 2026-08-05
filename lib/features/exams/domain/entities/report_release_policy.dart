import 'package:equatable/equatable.dart';

enum ReleaseOption {
  everyoneImmediate, // Option 1
  onlyFullyClearedFees, // Option 2
  viewEveryoneDownloadCleared, // Option 3
  afterSpecificDate, // Option 4
  manualOverrideOnly, // Option 5
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

  @override
  List<Object?> get props => [
    id,
    schoolId,
    option,
    releaseDate,
    restrictionMessage,
  ];
}
