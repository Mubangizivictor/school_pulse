import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/complete_parent_pin_setup.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_current_user.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_parent.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_with_email.dart';
import 'package:school_pulse/features/auth/domain/usecases/logout.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'auth_event.dart';
import 'auth_state.dart';

import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail loginWithEmail;
  final LoginParent loginParent;
  final CompleteParentPinSetup completeParentPinSetup;
  final Logout logout;
  final GetCurrentUser getCurrentUser;
  final ResolveParentAccessCode resolveParentAccessCode;
  final BrandingBloc brandingBloc;

  AuthBloc({
    required this.loginWithEmail,
    required this.loginParent,
    required this.completeParentPinSetup,
    required this.logout,
    required this.getCurrentUser,
    required this.resolveParentAccessCode,
    required this.brandingBloc,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginWithEmailPressed>(_onLoginWithEmail);
    on<LoginParentPressed>(_onLoginParent);
    on<CompleteParentPinSetupRequested>(_onCompleteParentPinSetup);
    on<LogoutPressed>(_onLogout);
    on<ResolveAccessCodeRequested>(_onResolveAccessCode);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUser(NoParams());
    result.fold((failure) => emit(AuthUnauthenticated()), (user) {
      if (user != null) _syncNotifications(user);
      emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated());
    });
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginWithEmail(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold((failure) => emit(AuthFailureState(failure.message)), (user) {
      _syncNotifications(user);
      emit(AuthAuthenticated(user));
    });
  }

  Future<void> _onLoginParent(
    LoginParentPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginParent(
      LoginParentParams(
        code: event.code,
        phoneNumber: event.phoneNumber,
        pin: event.pin,
      ),
    );
    result.fold((failure) => emit(AuthFailureState(failure.message)), (user) {
      _syncNotifications(user);
      emit(AuthAuthenticated(user));
    });
  }

  Future<void> _onCompleteParentPinSetup(
    CompleteParentPinSetupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await completeParentPinSetup(
      CompleteParentPinSetupParams(
        code: event.code,
        phoneNumber: event.phoneNumber,
        newPin: event.newPin,
      ),
    );
    result.fold((failure) => emit(AuthFailureState(failure.message)), (_) {
      // Auto-login after setting PIN
      add(
        LoginParentPressed(
          code: event.code,
          phoneNumber: event.phoneNumber,
          pin: event.newPin,
        ),
      );
    });
  }

  Future<void> _onLogout(LogoutPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await logout(NoParams());
    brandingBloc.add(ClearBranding());
    emit(AuthUnauthenticated());
  }

  Future<void> _onResolveAccessCode(
    ResolveAccessCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await resolveParentAccessCode(event.code);
    result.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (code) => emit(AuthAccessCodeResolved(code)),
    );
  }

  void _syncNotifications(UserEntity user) {
    NotificationService().syncTopicsForUser(user.id, user.roles).catchError((
      e,
    ) {
      if (kDebugMode) print('Notification sync failed: $e');
    });

    // Also trigger branding update
    brandingBloc.add(FetchBrandingForSchool(user.schoolId));
  }
}
