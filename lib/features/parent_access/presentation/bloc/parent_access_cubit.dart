import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/relationships/domain/entities/parent_student_relationship.dart';
import 'package:school_pulse/features/relationships/domain/entities/people_policy.dart';
import 'package:school_pulse/features/relationships/domain/usecases/get_people_policy.dart';
import 'package:school_pulse/features/relationships/domain/usecases/get_relationships_for_parent.dart';
import 'package:school_pulse/features/structure/domain/entities/feature_toggles.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import '../../domain/services/parent_module_resolver.dart';
import 'parent_access_state.dart';

/// Keeps [ParentAccessState] resolved for whichever child is currently
/// selected. Subscribes to [SelectedStudentBloc] so switching children
/// automatically cancels the previous child's feature-toggle watch and
/// re-resolves visibility from scratch - callers never see stale
/// permissions from the previously selected child (Phase 4C spec §45:
/// child switching must not bleed data/permissions across children).
class ParentAccessCubit extends Cubit<ParentAccessState> {
  final GetRelationshipsForParent getRelationshipsForParent;
  final GetPeoplePolicy getPeoplePolicy;
  final StructureRepository structureRepository;
  final String parentUserId;
  final ParentModuleResolver resolver;

  StreamSubscription<SelectedStudentState>? _selectedStudentSubscription;
  StreamSubscription<FeatureToggles>? _featureTogglesSubscription;
  String? _currentStudentId;

  ParentAccessCubit({
    required this.getRelationshipsForParent,
    required this.getPeoplePolicy,
    required this.structureRepository,
    required this.parentUserId,
    required SelectedStudentBloc selectedStudentBloc,
    this.resolver = const ParentModuleResolver(),
  }) : super(const ParentAccessInitial()) {
    final initial = selectedStudentBloc.state;
    if (initial is SelectedStudentLoaded) {
      _resolveFor(initial.student);
    }
    _selectedStudentSubscription = selectedStudentBloc.stream.listen((state) {
      if (state is SelectedStudentLoaded) {
        _resolveFor(state.student);
      }
    });
  }

  Future<void> _resolveFor(Student student) async {
    if (_currentStudentId == student.id) return;
    _currentStudentId = student.id;

    await _featureTogglesSubscription?.cancel();
    emit(const ParentAccessLoading());

    final relationshipsResult = await getRelationshipsForParent(
      GetRelationshipsForParentParams(
        schoolId: student.schoolId,
        userId: parentUserId,
      ),
    );

    final relationship = relationshipsResult.fold(
      (failure) => null,
      (relationships) => _activeRelationshipFor(relationships, student.id),
    );

    if (relationship == null) {
      emit(
        ParentAccessDenied(
          studentId: student.id,
          reason: 'No active relationship found for this child.',
        ),
      );
      return;
    }

    final policyResult = await getPeoplePolicy(student.schoolId);
    final policy = policyResult.fold(
      (failure) => PeoplePolicy.defaultFor(student.schoolId),
      (policy) => policy,
    );

    _featureTogglesSubscription = structureRepository
        .watchFeatureToggles(student.schoolId)
        .listen((toggles) {
          if (_currentStudentId != student.id) return;
          emit(
            ParentAccessResolved(
              studentId: student.id,
              visibility: resolver.resolve(
                relationship: relationship,
                policy: policy,
                featureToggles: toggles,
              ),
            ),
          );
        });
  }

  ParentStudentRelationship? _activeRelationshipFor(
    List<ParentStudentRelationship> relationships,
    String studentId,
  ) {
    for (final relationship in relationships) {
      if (relationship.studentId == studentId && relationship.isActive) {
        return relationship;
      }
    }
    return null;
  }

  @override
  Future<void> close() {
    _selectedStudentSubscription?.cancel();
    _featureTogglesSubscription?.cancel();
    return super.close();
  }
}
