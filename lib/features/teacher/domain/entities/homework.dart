import 'package:equatable/equatable.dart';

class Homework extends Equatable {
  final String id;
  final String title;
  final String description;
  final String className;
  final String subject;
  final DateTime dueDate;
  final DateTime createdAt;
  final String teacherId;
  final List<String>? attachments;

  const Homework({
    required this.id,
    required this.title,
    required this.description,
    required this.className,
    required this.subject,
    required this.dueDate,
    required this.createdAt,
    required this.teacherId,
    this.attachments,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    className,
    subject,
    dueDate,
    createdAt,
    teacherId,
    attachments,
  ];

  Homework copyWith({
    String? id,
    String? title,
    String? description,
    String? className,
    String? subject,
    DateTime? dueDate,
    DateTime? createdAt,
    String? teacherId,
    List<String>? attachments,
  }) {
    return Homework(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      className: className ?? this.className,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      teacherId: teacherId ?? this.teacherId,
      attachments: attachments ?? this.attachments,
    );
  }
}
