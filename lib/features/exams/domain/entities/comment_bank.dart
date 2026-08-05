import 'package:equatable/equatable.dart';

class CommentCategory extends Equatable {
  final String id;
  final String schoolId;
  final String name; // e.g., 'Academic Performance', 'Conduct', 'Social Skills'

  const CommentCategory({
    required this.id,
    required this.schoolId,
    required this.name,
  });

  @override
  List<Object?> get props => [id, schoolId, name];
}

class CommentTemplate extends Equatable {
  final String id;
  final String categoryId;
  final String text; // e.g., "Exhibited great improvement in {subject}."
  final String performanceLevel; // 'Excellent', 'Good', 'Average', 'Poor'

  const CommentTemplate({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.performanceLevel,
  });

  @override
  List<Object?> get props => [id, categoryId, text, performanceLevel];
}
