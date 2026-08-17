import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import '../../domain/entities/class_timetable_entities.dart';
import '../../domain/entities/curriculum_assignment.dart';
import '../../domain/repositories/class_timetable_repository.dart';
import '../../domain/repositories/curriculum_assignment_repository.dart';
import '../../domain/repositories/structure_people_readiness_repository.dart';
import '../../domain/services/structure_tenant_resolver.dart';

class StructureExtendedSetupState extends Equatable {
  final List<CurriculumAssignment> curriculum;
  final List<UserEntity> staff;
  final List<ClassTimetable> timetables;
  final List<ClassTimetableLesson> lessons;
  final bool isLoading;
  final String? errorMessage;

  const StructureExtendedSetupState({
    this.curriculum = const [],
    this.staff = const [],
    this.timetables = const [],
    this.lessons = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  StructureExtendedSetupState copyWith({
    List<CurriculumAssignment>? curriculum,
    List<UserEntity>? staff,
    List<ClassTimetable>? timetables,
    List<ClassTimetableLesson>? lessons,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StructureExtendedSetupState(
      curriculum: curriculum ?? this.curriculum,
      staff: staff ?? this.staff,
      timetables: timetables ?? this.timetables,
      lessons: lessons ?? this.lessons,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        curriculum,
        staff,
        timetables,
        lessons,
        isLoading,
        errorMessage,
      ];
}

class StructureExtendedSetupCubit extends Cubit<StructureExtendedSetupState> {
  final StructureTenantResolver tenantResolver;
  final CurriculumAssignmentRepository curriculumRepository;
  final ClassTimetableRepository timetableRepository;
  final StructurePeopleReadinessRepository peopleRepository;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Set<String> _loaded = {};

  StructureExtendedSetupCubit({
    required this.tenantResolver,
    required this.curriculumRepository,
    required this.timetableRepository,
    required this.peopleRepository,
  }) : super(const StructureExtendedSetupState()) {
    _start();
  }

  Future<void> _start() async {
    try {
      final schoolId = await tenantResolver.resolve();
      _subscriptions.add(
        curriculumRepository.watchAssignments().listen(
          (value) => _emitLoaded(
            'curriculum',
            state.copyWith(curriculum: value),
          ),
          onError: _onError,
        ),
      );
      _subscriptions.add(
        timetableRepository.watchTimetables().listen(
          (value) => _emitLoaded(
            'timetables',
            state.copyWith(timetables: value),
          ),
          onError: _onError,
        ),
      );
      _subscriptions.add(
        timetableRepository.watchLessons().listen(
          (value) => _emitLoaded('lessons', state.copyWith(lessons: value)),
          onError: _onError,
        ),
      );
      _subscriptions.add(
        peopleRepository.watchSchoolStaff(schoolId).listen(
          (value) => _emitLoaded('staff', state.copyWith(staff: value)),
          onError: _onError,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  void _emitLoaded(String key, StructureExtendedSetupState next) {
    _loaded.add(key);
    emit(
      next.copyWith(
        isLoading: _loaded.length < 4,
        errorMessage: null,
      ),
    );
  }

  void _onError(Object error, StackTrace stackTrace) {
    emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
