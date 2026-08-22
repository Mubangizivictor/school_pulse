import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import '../../domain/repositories/structure_people_readiness_repository.dart';

class StructurePeopleReadinessState extends Equatable {
  final List<UserEntity> staff;
  final bool isLoading;
  final String? errorMessage;

  const StructurePeopleReadinessState({
    this.staff = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [staff, isLoading, errorMessage];
}

class StructurePeopleReadinessCubit
    extends Cubit<StructurePeopleReadinessState> {
  final StructurePeopleReadinessRepository repository;
  final String schoolId;
  StreamSubscription<List<UserEntity>>? _subscription;

  StructurePeopleReadinessCubit({
    required this.repository,
    required this.schoolId,
  }) : super(const StructurePeopleReadinessState()) {
    _subscription = repository
        .watchSchoolStaff(schoolId)
        .listen(
          (staff) => emit(
            StructurePeopleReadinessState(staff: staff, isLoading: false),
          ),
          onError: (Object error, StackTrace stackTrace) => emit(
            StructurePeopleReadinessState(
              staff: state.staff,
              isLoading: false,
              errorMessage: error.toString(),
            ),
          ),
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
