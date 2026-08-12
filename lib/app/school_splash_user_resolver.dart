import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

/// Resolves which [UserEntity] the `/school-splash` route should render.
///
/// `state.extra` only survives a fresh `context.go('/school-splash', extra:
/// user)` push - it does not survive a route rebuild that isn't that exact
/// push (e.g. a redirect re-running the current match after an unrelated
/// Bloc/Firestore update), so it can legitimately come back null or of the
/// wrong type. Falling back to [AuthBloc]'s current user covers that case
/// without an unsafe `as UserEntity` cast; if there's truly no authenticated
/// user this route has nothing to show.
UserEntity? resolveSchoolSplashUser(Object? extra, AuthState authState) {
  if (extra is UserEntity) return extra;
  if (authState is AuthAuthenticated) return authState.user;
  return null;
}
