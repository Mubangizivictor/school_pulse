import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/school_calendar/domain/entities/academic_year.dart';

class AcademicYearModel extends AcademicYear {
  const AcademicYearModel({
    required super.id,
    required super.schoolId,
    required super.name,
    required super.startDate,
    required super.endDate,
    super.isCurrent,
  });

  factory AcademicYearModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AcademicYearModel(
      id: doc.id,
      schoolId: data['schoolId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      isCurrent: data['isCurrent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isCurrent': isCurrent,
    };
  }
}
