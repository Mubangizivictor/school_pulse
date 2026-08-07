import 'package:equatable/equatable.dart';
import '../../domain/entities/parent_module_visibility.dart';

sealed class ParentAccessState extends Equatable {
  const ParentAccessState();

  @override
  List<Object?> get props => [];
}

class ParentAccessInitial extends ParentAccessState {
  const ParentAccessInitial();
}

class ParentAccessLoading extends ParentAccessState {
  const ParentAccessLoading();
}

class ParentAccessResolved extends ParentAccessState {
  final String studentId;
  final ParentModuleVisibility visibility;

  const ParentAccessResolved({
    required this.studentId,
    required this.visibility,
  });

  @override
  List<Object?> get props => [studentId, visibility];
}

/// No active relationship found for this parent+student, or a load error.
/// Callers should treat this the same as [ParentModuleVisibility.none] -
/// deny student-scoped access rather than fail open.
class ParentAccessDenied extends ParentAccessState {
  final String studentId;
  final String reason;

  const ParentAccessDenied({required this.studentId, required this.reason});

  @override
  List<Object?> get props => [studentId, reason];
}
