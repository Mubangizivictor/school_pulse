import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/complete_parent_pin_setup.dart';
import 'package:school_pulse/features/auth/domain/usecases/enter_support_mode.dart';
import 'package:school_pulse/features/auth/domain/usecases/exit_support_mode.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_current_user.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_owner.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_parent.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_with_email.dart';
import 'package:school_pulse/features/auth/data/datasources/remembered_login_store.dart';
import 'package:school_pulse/features/auth/domain/usecases/logout.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'package:school_pulse/features/verification/data/datasources/verification_local_data_source.dart';
import 'package:school_pulse/features/attendance_hub/domain/repositories/attendance_repository.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/domain/services/active_responsibility_service.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/core/utils/device_info_service.dart';
import 'package:school_pulse/features/parent_offline/domain/parent_offline_cache_service.dart';
import 'package:school_pulse/features/parent_offline/domain/parent_offline_queue_service.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'auth_event.dart';
import 'auth_state.dart';

import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail loginWithEmail;
  final LoginOwnerWithEmail loginOwnerWithEmail;
  final LoginOwnerWithGoogle loginOwnerWithGoogle;
  final LoginOwnerWithApple loginOwnerWithApple;
  final VerifyOwnerSession verifyOwnerSession;
  final LoginParent loginParent;
  final CompleteParentPinSetup completeParentPinSetup;
  final Logout logout;
  final GetCurrentUser getCurrentUser;
  final ResolveParentAccessCode resolveParentAccessCode;
  final EnterSupportMode enterSupportMode;
  final ExitSupportMode exitSupportMode;
  final BrandingBloc brandingBloc;
  final VerificationLocalDataSource verificationLocalDataSource;
  final ClassTeacherLocalDataSource classTeacherLocalDataSource;
  final SubjectTeacherLocalDataSource subjectTeacherLocalDataSource;
  final ActiveResponsibilityService activeResponsibilityService;
  final RememberedLoginStore _rememberedLoginStore = RememberedLoginStore();

  AuthBloc({
    required this.loginWithEmail,
    required this.loginOwnerWithEmail,
    required this.loginOwnerWithGoogle,
    required this.loginOwnerWithApple,
    required this.verifyOwnerSession,
    required this.loginParent,
    required this.completeParentPinSetup,
    required this.logout,
    required this.getCurrentUser,
    required this.resolveParentAccessCode,
    required this.enterSupportMode,
    required this.exitSupportMode,
    required this.brandingBloc,
    required this.verificationLocalDataSource,
    required this.classTeacherLocalDataSource,
    required this.subjectTeacherLocalDataSource,
    required this.activeResponsibilityService,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginWithEmailPressed>(_onLoginWithEmail);
    on<LoginOwnerWithEmailPressed>(_onLoginOwnerWithEmail);
    on<LoginOwnerWithGooglePressed>(_onLoginOwnerWithGoogle);
    on<LoginOwnerWithApplePressed>(_onLoginOwnerWithApple);
    on<LoginParentPressed>(_onLoginParent);
    on<CompleteParentPinSetupRequested>(_onCompleteParentPinSetup);
    on<LogoutPressed>(_onLogout);
    on<ResolveAccessCodeRequested>(_onResolveAccessCode);
    on<EnterSupportModeRequested>(_onEnterSupportMode);
    on<ExitSupportModePressed>(_onExitSupportMode);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUser(NoParams());
    final resolved = await result.fold<Future<UserEntity?>>(
      (failure) async => null,
      (user) async => user,
    );
    if (resolved == null) {
      emit(AuthUnauthenticated());
      return;
    }
    // A superAdmin profile can reach this point via a path that never ran
    // the dedicated owner login (an MFA-resolved sign-in, or Firebase
    // restoring a persisted session on app restart/web reload) - re-assert
    // server-side owner authorization here so the check still gates every
    // such session, not just the Platform Owner Access screen's own logins.
    if (resolved.roles.contains(UserRole.superAdmin)) {
      final ownerCheck = await verifyOwnerSession(NoParams());
      final denied = ownerCheck.fold((failure) => true, (_) => false);
      if (denied) {
        emit(AuthUnauthenticated());
        return;
      }
    }
    _syncNotifications(resolved);
    emit(AuthAuthenticated(resolved));
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await loginWithEmail(
        LoginParams(email: event.email, password: event.password),
      );
      result.fold(
        (failure) {
          _recordSecurityLoginFailure(event.email);
          emit(AuthFailureState(failure.message));
        },
        (user) {
          _syncNotifications(user);
          emit(AuthAuthenticated(user));
        },
      );
    } on FirebaseAuthMultiFactorException catch (e) {
      emit(AuthMfaChallengeRequired(e.resolver));
    }
  }

  Future<void> _onLoginOwnerWithEmail(
    LoginOwnerWithEmailPressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await loginOwnerWithEmail(
        LoginOwnerParams(email: event.email, password: event.password),
      );
      result.fold((failure) => emit(AuthFailureState(failure.message)), (user) {
        _syncNotifications(user);
        emit(AuthAuthenticated(user));
      });
    } on FirebaseAuthMultiFactorException catch (e) {
      emit(AuthMfaChallengeRequired(e.resolver));
    }
  }

  Future<void> _onLoginOwnerWithGoogle(
    LoginOwnerWithGooglePressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await loginOwnerWithGoogle(NoParams());
      result.fold((failure) => emit(AuthFailureState(failure.message)), (user) {
        _syncNotifications(user);
        emit(AuthAuthenticated(user));
      });
    } on FirebaseAuthMultiFactorException catch (e) {
      emit(AuthMfaChallengeRequired(e.resolver));
    }
  }

  Future<void> _onLoginOwnerWithApple(
    LoginOwnerWithApplePressed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await loginOwnerWithApple(NoParams());
      result.fold((failure) => emit(AuthFailureState(failure.message)), (user) {
        _syncNotifications(user);
        emit(AuthAuthenticated(user));
      });
    } on FirebaseAuthMultiFactorException catch (e) {
      emit(AuthMfaChallengeRequired(e.resolver));
    }
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
      // Every successful online parent login is a real network-verified
      // identity check - piggyback it to (re)set the mobile local
      // PIN/biometric re-entry gate so this parent can reopen the Parent
      // Portal offline afterward. Mirrors their just-typed server PIN
      // rather than asking them to choose a second one; a device-local
      // salted hash only, never the server PIN itself (see
      // ParentLocalPinStore doc). No-ops on web.
      unawaited(
        di.sl<ParentOfflineCacheService>().setOfflineGatePin(
          parentId: user.id,
          pin: event.pin,
        ),
      );
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
    final previousUser = state is AuthAuthenticated
        ? (state as AuthAuthenticated).user
        : null;

    await logout(NoParams());
    await _rememberedLoginStore.setStaffEmail(null);
    await _rememberedLoginStore.setParentIdentity();
    brandingBloc.add(ClearBranding());

    // Best-effort: the Firebase Auth sign-out above is what actually ends
    // the session, so a failure clearing on-device caches shouldn't block
    // logout - it would just mean stale data lingers on this device.
    if (previousUser != null) {
      try {
        await verificationLocalDataSource.clearPermissionSnapshot(
          previousUser.id,
        );
      } catch (_) {}
    }
    // Class/Subject Teacher caches (roster, dashboard figures, attendance
    // drafts, the offline sync queue, the resolved responsibility) are keyed
    // to the device, not the session - left uncleared, they would hand the
    // next person to sign in on this device the previous teacher's class
    // data until every cache entry happened to be overwritten.
    try {
      await classTeacherLocalDataSource.clear();
    } catch (_) {}
    try {
      await subjectTeacherLocalDataSource.clearAll();
    } catch (_) {}
    try {
      await activeResponsibilityService.clear();
    } catch (_) {}
    // Attendance's own local queue (student/staff/gate/hostel marks awaiting
    // sync) is keyed to the device, not the session, same reasoning as the
    // class/subject teacher caches above - left uncleared it would let the
    // next person to sign in on this device see or resume the previous
    // operator's queued marks.
    try {
      await di.sl<AttendanceRepository>().clearLocalQueue();
    } catch (_) {}
    try {
      await NotificationService().unsubscribeAllTopics();
    } catch (_) {}
    // Parent Portal offline cache + queue + local PIN gate are all keyed
    // to (tenantId, parentId) but stored on-device - clear them on logout
    // so a subsequent parent/user on this device can never read the
    // previous parent's cached data or unlock with their offline PIN.
    if (previousUser != null && previousUser.roles.contains(UserRole.parent)) {
      try {
        await di.sl<ParentOfflineCacheService>().clearAllForParent(
          tenantId: previousUser.schoolId,
          parentId: previousUser.id,
        );
      } catch (_) {}
      try {
        await di.sl<ParentOfflineQueueService>().clearAllForParent(
          tenantId: previousUser.schoolId,
          parentId: previousUser.id,
        );
      } catch (_) {}
    }

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

  Future<void> _onEnterSupportMode(
    EnterSupportModeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await enterSupportMode(
      EnterSupportModeParams(schoolId: event.schoolId, reason: event.reason),
    );
    result.fold((failure) => emit(AuthFailureState(failure.message)), (
      session,
    ) {
      _syncNotifications(session.user);
      emit(
        AuthAuthenticated(
          session.user,
          supportMode: SupportModeInfo(
            ownerId: session.ownerId,
            schoolName: session.schoolName,
            expiresAt: session.expiresAt,
          ),
        ),
      );
    });
  }

  Future<void> _onExitSupportMode(
    ExitSupportModePressed event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    final ownerId = current is AuthAuthenticated
        ? current.supportMode?.ownerId
        : null;
    if (ownerId == null) {
      emit(AuthUnauthenticated());
      return;
    }
    emit(AuthLoading());
    await exitSupportMode(ExitSupportModeParams(ownerId: ownerId));
    brandingBloc.add(ClearBranding());
    emit(AuthUnauthenticated());
  }

  void _syncNotifications(UserEntity user) {
    NotificationService().syncTopicsForUser(user.id, user.roles).catchError((
      e,
    ) {
      if (kDebugMode) print('Notification sync failed: $e');
    });

    // --- Additive: SaaS owner sign-in event logging (security feature) ---
    // Fire-and-forget call to the `logOwnerSignIn` Cloud Function so the
    // Security Settings "Suspicious Activity" screen has real data. Only
    // invoked for superAdmin accounts; failures are swallowed so this can
    // never block or break the normal login flow for any user.
    if (user.roles.contains(UserRole.superAdmin)) {
      _logOwnerSignIn();
    } else {
      _registerInstitutionSecuritySession(user);
    }
    // --- End additive block ---
  }

  /// Best-effort registry heartbeat. It never carries an Auth token or blocks
  /// sign-in; the callable resolves tenant ownership from the authenticated
  /// server-side profile rather than trusting client-supplied school data.
  Future<void> _registerInstitutionSecuritySession(UserEntity user) async {
    try {
      final deviceId = await di.sl<DeviceIdService>().getDeviceId();
      final info = di.sl<DeviceInfoService>();
      await FirebaseFunctions.instance
          .httpsCallable('registerSecuritySession')
          .call({
            'deviceId': deviceId,
            'deviceName': await info.deviceName(),
            'platform': await info.platformLabel(),
          });
    } catch (e) {
      if (kDebugMode) print('Security session registration failed: $e');
    }
  }

  Future<void> _recordSecurityLoginFailure(String identifier) async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('recordSecurityLoginFailure')
          .call({'identifier': identifier});
    } catch (_) {
      // Login errors must remain private and must never be masked by logging.
    }
  }

  Future<void> _logOwnerSignIn() async {
    try {
      await FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('logOwnerSignIn')
          .call({'platform': defaultTargetPlatform.name});
    } catch (e) {
      if (kDebugMode) print('Owner sign-in logging failed: $e');
    }
  }
}
