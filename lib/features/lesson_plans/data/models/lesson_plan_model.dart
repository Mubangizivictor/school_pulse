import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/lesson_plan.dart';

class LessonPlanModel extends LessonPlan {
  const LessonPlanModel({
    required super.id,
    required super.teacherId,
    required super.subject,
    required super.className,
    required super.date,
    required super.content,
  });

  factory LessonPlanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LessonPlanModel(
      id: doc.id,
      teacherId: data['teacherId'] ?? '',
      subject: data['subject'] ?? '',
      className: data['className'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      content: data['content'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teacherId': teacherId,
      'subject': subject,
      'className': className,
      'date': Timestamp.fromDate(date),
      'content': content,
    };
  }
}
