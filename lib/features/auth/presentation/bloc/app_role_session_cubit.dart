import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/services/app_role_session_service.dart';

/// Thin Cubit wrapper around AppRoleSessionService so widgets can
/// BlocBuilder on the active top-level role without holding a raw Stream.
class AppRoleSessionCubit extends Cubit<UserRole?> {
  AppRoleSessionCubit({required AppRoleSessionService service})
    : _service = service,
      super(service.current) {
    _subscription = _service.changes.listen(emit);
  }

  final AppRoleSessionService _service;
  late final StreamSubscription<UserRole?> _subscription;

  Future<void> seed(UserEntity user) => _service.resolve(user);

  Future<void> switchTo({required UserEntity user, required UserRole role}) =>
      _service.switchTo(user: user, role: role);

  Future<void> revalidate(UserEntity user) => _service.revalidate(user);

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
