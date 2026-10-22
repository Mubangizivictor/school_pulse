import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/strategic_goal.dart';
import '../../domain/entities/leadership_meeting.dart';

/// Client-side CRUD for the Director's Strategic Goals and Leadership
/// Meetings. Unlike Approval Center these are single-owner (director-authored)
/// records with no multi-party workflow to protect, so writes go straight
/// through Firestore under rules restricted to director/headTeacher/
/// deputyHead rather than through callable functions.
class DirectorGovernanceRepository {
  DirectorGovernanceRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _goals(String schoolId) =>
      _firestore
          .collection('schools')
          .doc(schoolId)
          .collection('strategic_goals');

  CollectionReference<Map<String, dynamic>> _meetings(String schoolId) =>
      _firestore
          .collection('schools')
          .doc(schoolId)
          .collection('leadership_meetings');

  Stream<List<StrategicGoal>> watchGoals(String schoolId) => _goals(schoolId)
      .orderBy('deadline')
      .snapshots()
      .map(
        (s) => s.docs
            .map((d) => StrategicGoal.fromMap({...d.data(), 'goalId': d.id}))
            .toList(),
      );

  Future<String> saveGoal(String schoolId, StrategicGoal goal) async {
    final ref = goal.goalId.isEmpty
        ? _goals(schoolId).doc()
        : _goals(schoolId).doc(goal.goalId);
    await ref.set(goal.toMap(), SetOptions(merge: true));
    return ref.id;
  }

  Future<void> updateGoalProgress(
    String schoolId,
    String goalId, {
    required double currentValue,
    required GoalStatus status,
  }) => _goals(
    schoolId,
  ).doc(goalId).update({'currentValue': currentValue, 'status': status.wire});

  Future<void> deleteGoal(String schoolId, String goalId) =>
      _goals(schoolId).doc(goalId).delete();

  Stream<List<LeadershipMeeting>> watchMeetings(String schoolId) =>
      _meetings(schoolId)
          .orderBy('scheduledAt', descending: true)
          .snapshots()
          .map(
            (s) => s.docs
                .map(
                  (d) => LeadershipMeeting.fromMap({
                    ...d.data(),
                    'meetingId': d.id,
                  }),
                )
                .toList(),
          );

  Future<String> saveMeeting(String schoolId, LeadershipMeeting meeting) async {
    final ref = meeting.meetingId.isEmpty
        ? _meetings(schoolId).doc()
        : _meetings(schoolId).doc(meeting.meetingId);
    await ref.set(meeting.toMap(), SetOptions(merge: true));
    return ref.id;
  }

  Future<void> toggleActionCompleted(
    String schoolId,
    LeadershipMeeting meeting,
    int actionIndex,
  ) async {
    final updated = [...meeting.actions];
    updated[actionIndex] = updated[actionIndex].copyWith(
      completed: !updated[actionIndex].completed,
    );
    await _meetings(schoolId).doc(meeting.meetingId).update({
      'actions': updated.map((a) => a.toMap()).toList(),
    });
  }

  Future<void> deleteMeeting(String schoolId, String meetingId) =>
      _meetings(schoolId).doc(meetingId).delete();
}
