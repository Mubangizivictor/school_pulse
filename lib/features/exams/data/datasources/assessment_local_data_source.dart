import 'package:isar/isar.dart';
import '../models/isar_assessment_mark.dart';

abstract class AssessmentLocalDataSource {
  Future<void> cacheMarks(List<IsarAssessmentMark> marks);
  Future<List<IsarAssessmentMark>> getCachedMarks({
    String? assessmentTypeId,
    String? subjectId,
    String? studentId,
  });
  Future<List<IsarAssessmentMark>> getUnsyncedMarks();
  Future<void> markAsSynced(List<String> remoteIds);
}

class AssessmentLocalDataSourceImpl implements AssessmentLocalDataSource {
  final Isar isar;

  AssessmentLocalDataSourceImpl({required this.isar});

  @override
  Future<void> cacheMarks(List<IsarAssessmentMark> marks) async {
    await isar.writeTxn(() async {
      await isar.isarAssessmentMarks.putAll(marks);
    });
  }

  @override
  Future<List<IsarAssessmentMark>> getCachedMarks({
    String? assessmentTypeId,
    String? subjectId,
    String? studentId,
  }) async {
    var query = isar.isarAssessmentMarks.where();
    
    if (assessmentTypeId != null) {
      return await query.filter().assessmentTypeIdEqualTo(assessmentTypeId).findAll();
    }
    if (subjectId != null) {
      return await query.filter().subjectIdEqualTo(subjectId).findAll();
    }
    if (studentId != null) {
      return await query.filter().studentIdEqualTo(studentId).findAll();
    }
    
    return await query.findAll();
  }

  @override
  Future<List<IsarAssessmentMark>> getUnsyncedMarks() async {
    return await isar.isarAssessmentMarks.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<void> markAsSynced(List<String> remoteIds) async {
    await isar.writeTxn(() async {
      for (var id in remoteIds) {
        final mark = await isar.isarAssessmentMarks.filter().remoteIdEqualTo(id).findFirst();
        if (mark != null) {
          mark.isSynced = true;
          await isar.isarAssessmentMarks.put(mark);
        }
      }
    });
  }
}
