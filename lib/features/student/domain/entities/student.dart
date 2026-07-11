import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id;
  final String name;
  final String className;
  final String studentId;
  final String? photoUrl;

  const Student({
    required this.id,
    required this.name,
    required this.className,
    required this.studentId,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    className,
    studentId,
    photoUrl,
  ];
}
