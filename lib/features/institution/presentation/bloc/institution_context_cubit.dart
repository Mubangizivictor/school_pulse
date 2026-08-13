import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_pulse/features/institution/domain/repositories/institution_context_repository.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_state.dart';

/// Single source of truth for the active institution tenant. Fed by
/// AuthBloc's schoolId (a one-way trigger, never read directly from Auth
/// claims) so it stays decoupled from authentication concerns. Individual
/// modules must consume this rather than building their own tenant context.
class InstitutionContextCubit extends Cubit<InstitutionContextState> {
  final InstitutionContextRepository repository;
  final SharedPreferences preferences;

  static const _lastInstitutionKey =
      'institution_context.current_institution_id';

  StreamSubscription? _watchSubscription;
  String? _currentInstitutionId;

  InstitutionContextCubit({required this.repository, required this.preferences})
    : super(const InstitutionContextInitial());

  String? get currentInstitutionId => _currentInstitutionId;

  /// Loads the authenticated tenant and starts watching it for live updates
  /// (status changes, suspension, entitlement changes).
  ///
  /// The selected tenant is deliberately never persisted. A device-local
  /// school id is not an authorization grant and restoring one before the
  /// current authenticated membership has been verified can expose stale
  /// tenant state after an account switch.
  Future<void> loadInstitution(String institutionId) async {
    emit(const InstitutionContextLoading());
    _currentInstitutionId = institutionId;
    await preferences.remove(_lastInstitutionKey);

    await _watchSubscription?.cancel();
    _watchSubscription = repository.watchContext(institutionId).listen((
      context,
    ) {
      if (context.isSuspended) {
        emit(InstitutionContextSuspended(context));
      } else {
        emit(InstitutionContextLoaded(context));
      }
    }, onError: (error) => emit(InstitutionContextError(error.toString())));
  }

  /// Tenant switching is unavailable until the session resolver can return
  /// an authenticated, server-authorized membership for the target school.
  /// Loading an ID selected in the UI would make the client cache an
  /// unverified tenant context, so fail closed instead.
  Future<void> switchTo(String institutionId) {
    if (institutionId == _currentInstitutionId) return Future.value();
    return Future.error(
      StateError('Institution switching requires a verified session.'),
    );
  }

  /// Resolves context from the authenticated user's server-backed schoolId.
  /// Never restore a tenant from local preferences: it is only a cache and
  /// cannot prove the current user is still a member of that tenant.
  Future<void> restore(String homeInstitutionId) async {
    await preferences.remove(_lastInstitutionKey);
    await loadInstitution(homeInstitutionId);
  }

  void clear() {
    _watchSubscription?.cancel();
    _watchSubscription = null;
    _currentInstitutionId = null;
    preferences.remove(_lastInstitutionKey);
    emit(const InstitutionContextInitial());
  }

  @override
  Future<void> close() {
    _watchSubscription?.cancel();
    return super.close();
  }
}
