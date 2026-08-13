import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/security_settings_remote_data_source.dart';

/// The owner's persisted security preferences. Booleans default to sane,
/// honest defaults (not "Enabled" by default) so a first-run owner sees
/// their real state rather than a fabricated one.
class SecuritySettings extends Equatable {
  /// Whether the owner wants an alert (currently: audit log entry) recorded
  /// whenever a new sign-in occurs. Persisted; not yet wired to an actual
  /// push/email notification, since no such delivery mechanism exists for
  /// this event today - see report for the honest caveat.
  final bool loginAlertsEnabled;

  /// Whether the owner has opted in to biometric unlock. Only ever set to
  /// true after a real `local_auth` `authenticate()` call succeeds - see
  /// `SecurityCenterScreen`.
  final bool biometricEnabled;

  /// Whether the app should require biometric re-auth on resume from
  /// background after an idle period. Only meaningful when
  /// [biometricEnabled] is also true; the UI enforces that dependency.
  final bool appLockEnabled;

  const SecuritySettings({
    this.loginAlertsEnabled = false,
    this.biometricEnabled = false,
    this.appLockEnabled = false,
  });

  factory SecuritySettings.fromMap(Map<String, dynamic> map) {
    return SecuritySettings(
      loginAlertsEnabled: map['loginAlertsEnabled'] as bool? ?? false,
      biometricEnabled: map['biometricEnabled'] as bool? ?? false,
      appLockEnabled: map['appLockEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'loginAlertsEnabled': loginAlertsEnabled,
    'biometricEnabled': biometricEnabled,
    'appLockEnabled': appLockEnabled,
  };

  SecuritySettings copyWith({
    bool? loginAlertsEnabled,
    bool? biometricEnabled,
    bool? appLockEnabled,
  }) => SecuritySettings(
    loginAlertsEnabled: loginAlertsEnabled ?? this.loginAlertsEnabled,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    appLockEnabled: appLockEnabled ?? this.appLockEnabled,
  );

  @override
  List<Object?> get props => [
    loginAlertsEnabled,
    biometricEnabled,
    appLockEnabled,
  ];
}

enum SecuritySettingsStatus { loading, ready, error }

class SecuritySettingsState extends Equatable {
  final SecuritySettingsStatus status;
  final SecuritySettings settings;
  final String? errorMessage;

  const SecuritySettingsState({
    this.status = SecuritySettingsStatus.loading,
    this.settings = const SecuritySettings(),
    this.errorMessage,
  });

  SecuritySettingsState copyWith({
    SecuritySettingsStatus? status,
    SecuritySettings? settings,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SecuritySettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, settings, errorMessage];
}

/// Owns the SaaS owner's `security` preferences sub-map and exposes the
/// actions the Security Overview / Security Settings screens trigger.
/// Deliberately separate from [SuperAdminBloc] to keep this feature's diff
/// isolated from the sibling Notifications/Help&Support work landing on
/// that shared bloc in the same window.
class SecuritySettingsCubit extends Cubit<SecuritySettingsState> {
  final SecuritySettingsRemoteDataSource dataSource;
  final String ownerId;

  SecuritySettingsCubit({required this.dataSource, required this.ownerId})
    : super(const SecuritySettingsState()) {
    _subscribe();
  }

  void _subscribe() {
    dataSource
        .watchSecuritySettings(ownerId)
        .listen(
          (map) => emit(
            state.copyWith(
              status: SecuritySettingsStatus.ready,
              settings: SecuritySettings.fromMap(map),
              clearError: true,
            ),
          ),
          onError: (Object e) => emit(
            state.copyWith(
              status: SecuritySettingsStatus.error,
              errorMessage: '$e',
            ),
          ),
        );
  }

  Future<void> setLoginAlertsEnabled(bool enabled) async {
    final previous = state.settings;
    emit(
      state.copyWith(settings: previous.copyWith(loginAlertsEnabled: enabled)),
    );
    try {
      await dataSource.updateSecuritySettings(ownerId, {
        'loginAlertsEnabled': enabled,
      });
    } catch (e) {
      emit(
        state.copyWith(
          settings: previous,
          status: SecuritySettingsStatus.error,
          errorMessage: 'Could not save Login Alerts: $e',
        ),
      );
    }
  }

  /// Persists the real biometric-unlock preference. Callers must have
  /// already confirmed real device capability + a successful
  /// `local_auth.authenticate()` challenge before turning this on; this
  /// cubit only owns persistence, not the capability check itself.
  /// Turning biometrics off also forces App Lock off, since App Lock is
  /// only meaningful when biometrics are enabled.
  Future<void> setBiometricEnabled(bool enabled) async {
    final previous = state.settings;
    final next = enabled
        ? previous.copyWith(biometricEnabled: true)
        : previous.copyWith(biometricEnabled: false, appLockEnabled: false);
    emit(state.copyWith(settings: next));
    try {
      await dataSource.updateSecuritySettings(ownerId, {
        'biometricEnabled': next.biometricEnabled,
        'appLockEnabled': next.appLockEnabled,
      });
    } catch (e) {
      emit(
        state.copyWith(
          settings: previous,
          status: SecuritySettingsStatus.error,
          errorMessage: 'Could not save biometric preference: $e',
        ),
      );
    }
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    final previous = state.settings;
    if (enabled && !previous.biometricEnabled) return;
    emit(state.copyWith(settings: previous.copyWith(appLockEnabled: enabled)));
    try {
      await dataSource.updateSecuritySettings(ownerId, {
        'appLockEnabled': enabled,
      });
    } catch (e) {
      emit(
        state.copyWith(
          settings: previous,
          status: SecuritySettingsStatus.error,
          errorMessage: 'Could not save App Lock preference: $e',
        ),
      );
    }
  }

  Future<void> logSecurityEvent({
    required String action,
    String? reason,
    Map<String, dynamic> metadata = const {},
  }) {
    return dataSource.logSecurityEvent(
      ownerId: ownerId,
      action: action,
      reason: reason,
      metadata: metadata,
    );
  }
}
