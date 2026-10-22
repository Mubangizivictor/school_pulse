import 'package:cloud_functions/cloud_functions.dart';

/// Real student/staff counts for one school, read via [getSchoolCounts]
/// (public_functions/school_counts.js). Count only - no student/staff
/// personal data crosses the wire, since the callable runs Admin-SDK
/// count() aggregation queries server-side rather than returning documents.
class SchoolCounts {
  const SchoolCounts({
    required this.studentCount,
    required this.staffCount,
    required this.updatedAt,
  });

  final int studentCount;
  final int staffCount;
  final DateTime updatedAt;

  factory SchoolCounts.fromJson(Map<String, dynamic> json) {
    return SchoolCounts(
      studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
      staffCount: (json['staffCount'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['updatedAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}

class SchoolCountsService {
  SchoolCountsService({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFunctions _functions;

  Future<SchoolCounts> fetch(String schoolId) async {
    final result = await _functions
        .httpsCallable('getSchoolCounts')
        .call<Map<String, dynamic>>({'schoolId': schoolId});
    return SchoolCounts.fromJson(Map<String, dynamic>.from(result.data));
  }
}
