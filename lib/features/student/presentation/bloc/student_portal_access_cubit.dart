import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/manage_student_portal_access.dart';
import 'student_portal_access_state.dart';

/// Wraps the four student-portal-access usecases (provision, reset PIN,
/// enable/disable, fetch). Kept as a small Cubit rather than a full Bloc
/// since there is no complex event stream to model - each action is a
/// direct one-shot call that refreshes the loaded access code afterwards.
class StudentPortalAccessCubit extends Cubit<StudentPortalAccessState> {
  final ProvisionStudentAccessCode provisionStudentAccessCode;
  final ResetStudentPin resetStudentPin;
  final SetStudentAccessCodeStatus setStudentAccessCodeStatus;
  final GetStudentAccessCode getStudentAccessCode;

  StudentPortalAccessCubit({
    required this.provisionStudentAccessCode,
    required this.resetStudentPin,
    required this.setStudentAccessCodeStatus,
    required this.getStudentAccessCode,
  }) : super(StudentPortalAccessInitial());

  Future<void> load(String studentId) async {
    emit(StudentPortalAccessLoading());
    final result = await getStudentAccessCode(studentId);
    result.fold(
      (failure) => emit(StudentPortalAccessError(failure.message)),
      (accessCode) => emit(StudentPortalAccessLoaded(accessCode)),
    );
  }

  Future<void> generateAccessCode(String studentId) async {
    emit(StudentPortalAccessLoading());
    final result = await provisionStudentAccessCode(studentId);
    if (isClosed) return;
    await result.fold(
      (failure) async => emit(StudentPortalAccessError(failure.message)),
      (code) async {
        final refreshed = await getStudentAccessCode(studentId);
        if (isClosed) return;
        refreshed.fold(
          (failure) => emit(StudentPortalAccessError(failure.message)),
          (accessCode) => emit(
            StudentPortalAccessActionSuccess(
              'Access code generated',
              accessCode,
            ),
          ),
        );
      },
    );
  }

  Future<void> resetPin(String studentId, String code) async {
    emit(StudentPortalAccessLoading());
    final result = await resetStudentPin(code);
    if (isClosed) return;
    await result.fold(
      (failure) async => emit(StudentPortalAccessError(failure.message)),
      (_) async {
        final refreshed = await getStudentAccessCode(studentId);
        if (isClosed) return;
        refreshed.fold(
          (failure) => emit(StudentPortalAccessError(failure.message)),
          (accessCode) => emit(
            StudentPortalAccessActionSuccess('PIN reset', accessCode),
          ),
        );
      },
    );
  }

  Future<void> setStatus(
    String studentId,
    String code,
    bool isActive, {
    String? reason,
  }) async {
    emit(StudentPortalAccessLoading());
    final result = await setStudentAccessCodeStatus(
      code,
      isActive,
      reason: reason,
    );
    if (isClosed) return;
    await result.fold(
      (failure) async => emit(StudentPortalAccessError(failure.message)),
      (_) async {
        final refreshed = await getStudentAccessCode(studentId);
        if (isClosed) return;
        refreshed.fold(
          (failure) => emit(StudentPortalAccessError(failure.message)),
          (accessCode) => emit(
            StudentPortalAccessActionSuccess(
              isActive ? 'Portal access enabled' : 'Portal access disabled',
              accessCode,
            ),
          ),
        );
      },
    );
  }
}
