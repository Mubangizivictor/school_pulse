import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/report_card.dart';

class ReportCardModel extends ReportCard {
  const ReportCardModel({
    required super.id,
    required super.studentId,
    required super.studentName,
    required super.className,
    required super.term,
    required super.year,
    super.status,
    super.deanId,
    super.deanSignedAt,
    super.headTeacherId,
    super.headTeacherSignedAt,
    super.classTeacherComment,
    super.averageScore,
  });

  factory ReportCardModel.fromFirestore(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;
    return ReportCardModel(
      id: doc.id,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String? ?? '',
      className: json['className'] as String? ?? '',
      term: json['term'] as String,
      year: json['year'] as String,
      status: ReportCardStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => ReportCardStatus.pending,
      ),
      deanId: json['deanId'] as String?,
      deanSignedAt: json['deanSignedAt'] != null
          ? (json['deanSignedAt'] as Timestamp).toDate()
          : null,
      headTeacherId: json['headTeacherId'] as String?,
      headTeacherSignedAt: json['headTeacherSignedAt'] != null
          ? (json['headTeacherSignedAt'] as Timestamp).toDate()
          : null,
      classTeacherComment: json['classTeacherComment'] as String?,
      averageScore: (json['averageScore'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'className': className,
      'term': term,
      'year': year,
      'status': status.name,
      'deanId': deanId,
      'deanSignedAt': deanSignedAt != null
          ? Timestamp.fromDate(deanSignedAt!)
          : null,
      'headTeacherId': headTeacherId,
      'headTeacherSignedAt': headTeacherSignedAt != null
          ? Timestamp.fromDate(headTeacherSignedAt!)
          : null,
      'classTeacherComment': classTeacherComment,
      'averageScore': averageScore,
    };
  }
}
