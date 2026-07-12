import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/usecases/complete_parent_pin_setup.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_current_user.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_parent.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_with_email.dart';
import 'package:school_pulse/features/auth/domain/usecases/logout.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail loginWithEmail;
  final LoginParent loginParent;
  final CompleteParentPinSetup completeParentPinSetup;
  final Logout logout;
  final GetCurrentUser getCurrentUser;
  final ResolveParentAccessCode resolveParentAccessCode;

  AuthBloc({
    required this.loginWithEmail,
    required this.loginParent,
    required this.completeParentPinSetup,
    required this.logout,
    required this.getCurrentUser,
    required this.resolveParentAccessCode,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginWithEmailPressed>(_onLoginWithEmail);
    on<LoginParentPressed>(_onLoginParent);
    on<CompleteParentPinSetupRequested>(_onCompleteParentPinSetup);
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

  Future<void> _onLoginParent(LoginParentPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginParent(LoginParentParams(
      code: event.code,
      phoneNumber: event.phoneNumber,
      pin: event.pin,
    ));
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onCompleteParentPinSetup(CompleteParentPinSetupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await completeParentPinSetup(CompleteParentPinSetupParams(
      code: event.code,
      newPin: event.newPin,
    ));
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) => add(AuthCheckRequested()), // Refresh auth state
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
