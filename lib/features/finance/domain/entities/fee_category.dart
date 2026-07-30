import 'package:equatable/equatable.dart';

class FeeCategory extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String? description;
  final bool isMandatory;
  final int priority; // For payment allocation

  const FeeCategory({
    required this.id,
    required this.schoolId,
    required this.name,
    this.description,
    this.isMandatory = true,
    this.priority = 0,
  });

  @override
  List<Object?> get props => [id, schoolId, name, description, isMandatory, priority];
}
