import '../entities/curriculum_assignment.dart';

abstract class CurriculumAssignmentRepository {
  Stream<List<CurriculumAssignment>> watchAssignments();
  Future<void> saveAssignment(CurriculumAssignment assignment);
  Future<void> deactivateAssignment(String assignmentId);
}
