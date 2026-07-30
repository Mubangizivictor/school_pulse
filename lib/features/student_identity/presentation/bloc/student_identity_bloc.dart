import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/student_identity_repository.dart';
import 'student_identity_event.dart';
import 'student_identity_state.dart';

class StudentIdentityBloc extends Bloc<StudentIdentityEvent, StudentIdentityState> {
  final StudentIdentityRepository repository;

  StudentIdentityBloc({required this.repository}) : super(StudentIdentityInitial()) {
    on<LoadStudentIdentityEvent>((event, emit) async {
      emit(StudentIdentityLoading());
      final result = await repository.getStudentIdentity(event.studentId);
      result.fold(
        (failure) => emit(StudentIdentityError(failure.message)),
        (identity) => emit(StudentIdentityLoaded(identity)),
      );
    });

    on<GenerateStudentIdentityEvent>((event, emit) async {
      emit(StudentIdentityLoading());
      final result = await repository.generateStudentIdentity(event.student);
      result.fold(
        (failure) => emit(StudentIdentityError(failure.message)),
        (identity) => emit(StudentIdentityLoaded(identity)),
      );
    });

    on<CacheStudentsOfflineEvent>((event, emit) async {
      emit(StudentIdentityLoading());
      final result = await repository.cacheStudentsForOffline(event.students);
      result.fold(
        (failure) => emit(StudentIdentityError(failure.message)),
        (_) => emit(StudentIdentityCacheSuccess()),
      );
    });
  }
}
