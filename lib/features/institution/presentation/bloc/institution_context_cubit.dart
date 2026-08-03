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

  static const _lastInstitutionKey = 'institution_context.current_institution_id';

  StreamSubscription? _watchSubscription;
  String? _currentInstitutionId;

  InstitutionContextCubit({
    required this.repository,
    required this.preferences,
  }) : super(const InstitutionContextInitial());

  String? get currentInstitutionId => _currentInstitutionId;

  /// Loads the given institution and starts watching it for live updates
  /// (status changes, suspension, entitlement changes). Persists the
  /// selection locally so a relaunch can restore the same active tenant.
  Future<void> loadInstitution(String institutionId) async {
    emit(const InstitutionContextLoading());
    _currentInstitutionId = institutionId;
    await preferences.setString(_lastInstitutionKey, institutionId);

    await _watchSubscription?.cancel();
    _watchSubscription = repository.watchContext(institutionId).listen(
      (context) {
        if (context.isSuspended) {
          emit(InstitutionContextSuspended(context));
        } else {
          emit(InstitutionContextLoaded(context));
        }
      },
      onError: (error) => emit(InstitutionContextError(error.toString())),
    );
  }

  /// Switches the active institution context for a multi-institution user.
  /// Callers must have already verified an active membership before calling
  /// this - the cubit itself only loads/watches, it doesn't authorize.
  Future<void> switchTo(String institutionId) => loadInstitution(institutionId);

  /// Restores the last-active institution on app relaunch, falling back to
  /// the user's home schoolId when nothing was previously selected.
  Future<void> restore(String homeInstitutionId) async {
    final lastId = preferences.getString(_lastInstitutionKey);
    await loadInstitution(lastId ?? homeInstitutionId);
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
