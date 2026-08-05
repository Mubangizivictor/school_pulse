import 'package:isar/isar.dart';

part 'isar_assessment_mark.g.dart';

@collection
class IsarAssessmentMark {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId;

  late String studentId;
  late String assessmentTypeId;
  late String subjectId;
  late String teacherId;
  double? score;
  String? competencyLevel;
  String? teacherComment;
  late String status; // draft, submitted, etc.
  late DateTime createdAt;
  late DateTime updatedAt;
  String? moderatedBy;
  String? approvedBy;

  bool isSynced = true;
}
