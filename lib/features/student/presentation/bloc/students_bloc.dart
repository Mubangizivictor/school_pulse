import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_students_by_ids.dart';
import '../../domain/usecases/get_all_students.dart';
import 'students_event.dart';
import 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final GetStudentsByIds getStudentsByIds;
  final GetAllStudents getAllStudents;

  StudentsBloc({required this.getStudentsByIds, required this.getAllStudents})
    : super(StudentsInitial()) {
    on<FetchStudents>(_onFetchStudents);
    on<LoadSchoolStudents>(_onLoadSchoolStudents);
    on<SearchStudents>(_onSearchStudents);
  }

  Future<void> _onFetchStudents(
    FetchStudents event,
    Emitter<StudentsState> emit,
  ) async {
    emit(StudentsLoading());
    final result = await getStudentsByIds(event.studentIds);
    result.fold(
      (failure) => emit(StudentsError(failure.message)),
      (students) => emit(StudentsLoaded(students)),
    );
  }

  Future<void> _onLoadSchoolStudents(
    LoadSchoolStudents event,
    Emitter<StudentsState> emit,
  ) async {
    emit(StudentsLoading());
    final schoolId = event.schoolId.trim();
    if (schoolId.isEmpty) {
      emit(const StudentsError('School context is required to load students.'));
      return;
    }
    final result = await getAllStudents(schoolId: schoolId);
    result.fold(
      (failure) => emit(StudentsError(failure.message)),
      (students) => emit(StudentsLoaded(students)),
    );
  }

  Future<void> _onSearchStudents(
    SearchStudents event,
    Emitter<StudentsState> emit,
  ) async {
    // Legacy/global search is retained for existing call sites. New tenant
    // administration screens load with LoadSchoolStudents and filter their
    // already school-scoped result locally so an empty query can never cause
    // a cross-tenant collection scan.
    emit(StudentsLoading());
    final result = await getAllStudents();
    result.fold((failure) => emit(StudentsError(failure.message)), (
      students,
    ) {
      final filtered = students.where((s) {
        final query = event.query.toLowerCase();
        return s.name.toLowerCase().contains(query) ||
            s.studentId.toLowerCase().contains(query);
      }).toList();
      emit(StudentsLoaded(filtered));
    });
  }
}
