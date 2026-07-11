import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_current_user.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_with_email.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_with_phone.dart';
import 'package:school_pulse/features/auth/domain/usecases/logout.dart';
import 'package:school_pulse/features/auth/domain/usecases/verify_otp.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail loginWithEmail;
  final LoginWithPhone loginWithPhone;
  final VerifyOtp verifyOtp;
  final Logout logout;
  final GetCurrentUser getCurrentUser;
  final ResolveParentAccessCode resolveParentAccessCode;

  AuthBloc({
    required this.loginWithEmail,
    required this.loginWithPhone,
    required this.verifyOtp,
    required this.logout,
    required this.getCurrentUser,
    required this.resolveParentAccessCode,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginWithEmailPressed>(_onLoginWithEmail);
    on<LoginWithPhonePressed>(_onLoginWithPhone);
    on<VerifyOtpPressed>(_onVerifyOtp);
    on<LogoutPressed>(_onLogout);
    on<ResolveAccessCodeRequested>(_onResolveAccessCode);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await getCurrentUser(NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated()),
    );
  }

  Future<void> _onLoginWithEmail(LoginWithEmailPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginWithEmail(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginWithPhone(LoginWithPhonePressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginWithPhone(event.phoneNumber);
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (verificationId) => emit(AuthOtpSent(verificationId)),
    );
  }

  Future<void> _onVerifyOtp(VerifyOtpPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await verifyOtp(VerifyOtpParams(
      verificationId: event.verificationId,
      smsCode: event.smsCode,
      linkedStudentIds: event.linkedStudentIds,
    ));
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogout(LogoutPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await logout(NoParams());
    emit(AuthUnauthenticated());
  }

  Future<void> _onResolveAccessCode(ResolveAccessCodeRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await resolveParentAccessCode(event.code);
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (code) {
        if (code == null) {
          emit(const AuthFailureState('Invalid access code. Please check and try again.'));
        } else {
          emit(AuthAccessCodeResolved(code));
        }
      },
    );
  }
}
