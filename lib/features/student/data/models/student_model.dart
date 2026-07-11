import '../../domain/entities/student.dart';

class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    required super.className,
    required super.studentId,
    super.photoUrl,
  });

  factory StudentModel.fromFirestore(Map<String, dynamic> json, String id) {
    return StudentModel(
      id: id,
      name: json['name'] as String,
      className: json['className'] as String,
      studentId: json['studentId'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'className': className,
      'studentId': studentId,
      'photoUrl': photoUrl,
    };
  }
}
