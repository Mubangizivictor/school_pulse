import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson_plan_model.dart';

abstract class LessonPlansRemoteDataSource {
  Future<List<LessonPlanModel>> getLessonPlans(String teacherId);
  Future<void> addLessonPlan(LessonPlanModel plan);
}

class LessonPlansRemoteDataSourceImpl implements LessonPlansRemoteDataSource {
  final FirebaseFirestore firestore;

  LessonPlansRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<LessonPlanModel>> getLessonPlans(String teacherId) async {
    final snapshot = await firestore
        .collection('lesson_plans')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => LessonPlanModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> addLessonPlan(LessonPlanModel plan) async {
    await firestore.collection('lesson_plans').add(plan.toFirestore());
  }
}
