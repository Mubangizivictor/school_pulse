import '../../domain/entities/report_release_policy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportReleasePolicyModel extends ReportReleasePolicy {
  const ReportReleasePolicyModel({
    required super.id,
    required super.schoolId,
    required super.option,
    super.releaseDate,
    super.restrictionMessage,
  });

  factory ReportReleasePolicyModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportReleasePolicyModel(
      id: id,
      schoolId: map['schoolId'] ?? '',
      option: ReleaseOption.values.firstWhere(
        (e) => e.toString().split('.').last == map['option'],
        orElse: () => ReleaseOption.everyoneImmediate,
      ),
      releaseDate: (map['releaseDate'] as Timestamp?)?.toDate(),
      restrictionMessage: map['restrictionMessage'] ?? "Your report card has been published but cannot be downloaded because your school's fee clearance policy has not yet been met. Please contact the Bursar for assistance.",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schoolId': schoolId,
      'option': option.toString().split('.').last,
      'releaseDate': releaseDate != null ? Timestamp.fromDate(releaseDate!) : null,
      'restrictionMessage': restrictionMessage,
    };
  }
}
