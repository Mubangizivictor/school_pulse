import '../entities/teaching_assignment.dart';

abstract class TeachingAssignmentRepository {
  Stream<List<TeachingAssignment>> watchAssignments();
  Future<void> saveAssignment(TeachingAssignment assignment);
  Future<void> endAssignment(String assignmentId, {DateTime? endDate});
}
