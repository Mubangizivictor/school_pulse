import 'package:equatable/equatable.dart';

class SchoolEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String createdBy;

  const SchoolEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [id, title, description, date, createdBy];
}
