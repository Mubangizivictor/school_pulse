import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/core/utils/device_info_service.dart';

import '../../data/datasources/owner_session_remote_data_source.dart';
import '../../domain/entities/owner_session.dart';

enum OwnerSessionStatus { loading, ready, error }

class OwnerSessionState extends Equatable {
  final OwnerSessionStatus status;
  final List<OwnerSession> sessions;
  final String? currentDeviceId;
  final String? errorMessage;

  const OwnerSessionState({
    this.status = OwnerSessionStatus.loading,
    this.sessions = const [],
    this.currentDeviceId,
    this.errorMessage,
  });

  OwnerSessionState copyWith({
    OwnerSessionStatus? status,
    List<OwnerSession>? sessions,
    String? currentDeviceId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OwnerSessionState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      currentDeviceId: currentDeviceId ?? this.currentDeviceId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, sessions, currentDeviceId, errorMessage];
}

/// Owns the SaaS owner's real device/session registry: registers this
/// device on load, streams every known device, and exposes trust/remove
/// actions. Registration here (rather than only at login) also covers the
/// case where the owner was already signed in when this cubit is created,
/// so the registry entry always reflects reality without depending on a
/// fresh login.
class OwnerSessionCubit extends Cubit<OwnerSessionState> {
  final OwnerSessionRemoteDataSource dataSource;
  final DeviceIdService deviceIdService;
  final DeviceInfoService deviceInfoService;
  final String ownerId;

  OwnerSessionCubit({
    required this.dataSource,
    required this.deviceIdService,
    required this.deviceInfoService,
    required this.ownerId,
  }) : super(const OwnerSessionState()) {
    _init();
  }

  Future<void> _init() async {
    final deviceId = await deviceIdService.getDeviceId();
    emit(state.copyWith(currentDeviceId: deviceId));

    dataSource
        .watchSessions(ownerId)
        .listen(
          (sessions) => emit(
            state.copyWith(
              status: OwnerSessionStatus.ready,
              sessions: sessions,
              clearError: true,
            ),
          ),
          onError: (Object e) => emit(
            state.copyWith(
              status: OwnerSessionStatus.error,
              errorMessage: '$e',
            ),
          ),
        );

    final isNew = !state.sessions.any((s) => s.deviceId == deviceId);
    await dataSource.upsertSession(
      ownerId: ownerId,
      deviceId: deviceId,
      platform: await deviceInfoService.platformLabel(),
      deviceName: await deviceInfoService.deviceName(),
      isNewSession: isNew,
    );
  }

  Future<void> touchCurrentDevice() async {
    final deviceId =
        state.currentDeviceId ?? await deviceIdService.getDeviceId();
    await dataSource.touchLastActive(ownerId: ownerId, deviceId: deviceId);
  }

  Future<void> setTrusted(String deviceId, bool trusted) {
    return dataSource.setTrusted(
      ownerId: ownerId,
      deviceId: deviceId,
      trusted: trusted,
    );
  }

  Future<void> removeSession(String deviceId) {
    return dataSource.removeSession(
      ownerId: ownerId,
      deviceId: deviceId,
      currentDeviceId: state.currentDeviceId,
    );
  }
}
