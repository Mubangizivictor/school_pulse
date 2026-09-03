import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/friendly_error_message.dart';
import '../../domain/repositories/super_admin_repository.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/entities/school.dart';
import 'super_admin_event.dart';
import 'super_admin_state.dart';

class SuperAdminBloc extends Bloc<SuperAdminEvent, SuperAdminState> {
  final SuperAdminRepository repository;
  final FirebaseAuth auth;

  SuperAdminBloc({required this.repository, required this.auth})
    : super(const SuperAdminState()) {
    on<LoadSuperAdminDashboard>(_onLoadDashboard);
    on<ApproveSchoolApplicationEvent>(_onApproveSchoolApplication);
    on<RejectSchoolApplicationEvent>(_onRejectSchoolApplication);
    on<UpdateSchoolStatusEvent>(_onUpdateSchoolStatus);
    on<UpdateSchoolInfoEvent>(_onUpdateSchoolInfo);
    on<UpdateSubscriptionEvent>(_onUpdateSubscription);
    on<ToggleFeatureEvent>(_onToggleFeature);
    on<LoadAuditLogsEvent>(_onLoadAuditLogs);
    on<EnterSupportModeEvent>(_onEnterSupportMode);
    on<ExitSupportModeEvent>(_onExitSupportMode);
  }

  String get _ownerId => auth.currentUser?.uid ?? 'unknown';

  Future<void> _onLoadAuditLogs(
    LoadAuditLogsEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      final logs = await repository.getAuditLogs(schoolId: event.schoolId);
      emit(state.copyWith(auditLogs: logs, clearErrorMessage: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: friendlyErrorMessage(e)));
    }
  }

  Future<void> _onEnterSupportMode(
    EnterSupportModeEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      await repository.logAction(
        AuditLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          ownerId: _ownerId,
          action: 'ENTER_SUPPORT_MODE',
          schoolId: event.schoolId,
          timestamp: DateTime.now(),
          device: 'Platform Dashboard',
          reason: event.reason,
        ),
      );
      emit(state.copyWith(supportModeSchoolId: event.schoolId));
    } catch (e) {
      emit(state.copyWith(errorMessage: friendlyErrorMessage(e)));
    }
  }

  Future<void> _onExitSupportMode(
    ExitSupportModeEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    final schoolId = state.supportModeSchoolId;
    if (schoolId != null) {
      await repository.logAction(
        AuditLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          ownerId: _ownerId,
          action: 'EXIT_SUPPORT_MODE',
          schoolId: schoolId,
          timestamp: DateTime.now(),
          device: 'Platform Dashboard',
        ),
      );
    }
    emit(state.copyWith(clearSupportModeSchoolId: true));
  }

  Future<void> _onLoadDashboard(
    LoadSuperAdminDashboard event,
    Emitter<SuperAdminState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SuperAdminStatus.loading,
        clearErrorMessage: true,
        clearActionMessage: true,
      ),
    );
    try {
      final schoolsFuture = repository.getAllSchools();
      final applicationsFuture = repository.getSchoolApplications();
      final plansFuture = repository.getSubscriptionPlans();
      final statsFuture = repository.getPlatformStats();

      final schools = await schoolsFuture;
      final applications = await applicationsFuture;
      final plans = await plansFuture;
      final stats = await statsFuture;

      emit(
        state.copyWith(
          status: SuperAdminStatus.success,
          schools: schools,
          applications: applications,
          plans: plans,
          stats: stats,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SuperAdminStatus.failure,
          errorMessage: friendlyErrorMessage(e),
        ),
      );
    }
  }

  Future<void> _onApproveSchoolApplication(
    ApproveSchoolApplicationEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    if (state.reviewingApplicationId != null) return;
    emit(
      state.copyWith(
        reviewingApplicationId: event.applicationId,
        clearErrorMessage: true,
        clearActionMessage: true,
      ),
    );
    try {
      final schoolId = await repository.approveSchoolApplication(
        event.applicationId,
      );
      final schoolsFuture = repository.getAllSchools();
      final applicationsFuture = repository.getSchoolApplications();
      final statsFuture = repository.getPlatformStats();
      final schools = await schoolsFuture;
      final applications = await applicationsFuture;
      final stats = await statsFuture;
      emit(
        state.copyWith(
          schools: schools,
          applications: applications,
          stats: stats,
          clearReviewingApplicationId: true,
          actionMessage:
              'School approved. Subscription payment is now required. School ID: $schoolId',
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          clearReviewingApplicationId: true,
          errorMessage: friendlyErrorMessage(e),
        ),
      );
    }
  }

  Future<void> _onRejectSchoolApplication(
    RejectSchoolApplicationEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    if (state.reviewingApplicationId != null) return;
    emit(
      state.copyWith(
        reviewingApplicationId: event.applicationId,
        clearErrorMessage: true,
        clearActionMessage: true,
      ),
    );
    try {
      await repository.rejectSchoolApplication(
        event.applicationId,
        event.reason,
      );
      final applicationsFuture = repository.getSchoolApplications();
      final statsFuture = repository.getPlatformStats();
      final applications = await applicationsFuture;
      final stats = await statsFuture;
      emit(
        state.copyWith(
          applications: applications,
          stats: stats,
          clearReviewingApplicationId: true,
          actionMessage: 'School application rejected.',
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          clearReviewingApplicationId: true,
          errorMessage: friendlyErrorMessage(e),
        ),
      );
    }
  }

  Future<void> _onUpdateSchoolStatus(
    UpdateSchoolStatusEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      // The setSchoolLifecycleStatus Cloud Function writes the platform
      // audit entry itself, atomically with the status change - no separate
      // client-side logAction call here, to avoid a duplicate/missing audit
      // entry if the two writes ever raced or one failed independently.
      if (event.status == SchoolStatus.suspended) {
        await repository.suspendSchool(
          event.schoolId,
          event.reason ?? 'No reason provided',
        );
      } else if (event.status == SchoolStatus.active) {
        await repository.activateSchool(event.schoolId);
      } else if (event.status == SchoolStatus.archived) {
        await repository.archiveSchool(
          event.schoolId,
          event.reason ?? 'No reason provided',
        );
      }

      add(LoadSuperAdminDashboard());
    } catch (e) {
      emit(state.copyWith(errorMessage: friendlyErrorMessage(e)));
    }
  }

  Future<void> _onUpdateSchoolInfo(
    UpdateSchoolInfoEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      await repository.updateSchool(event.school);

      await repository.logAction(
        AuditLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          ownerId: _ownerId,
          action: 'UPDATE_SCHOOL_INFO',
          schoolId: event.school.id,
          timestamp: DateTime.now(),
          device: 'Platform Dashboard',
        ),
      );

      add(LoadSuperAdminDashboard());
    } catch (e) {
      emit(state.copyWith(errorMessage: friendlyErrorMessage(e)));
    }
  }

  Future<void> _onUpdateSubscription(
    UpdateSubscriptionEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      // updateSchoolSubscriptionPlan writes the platform audit entry
      // server-side, atomically with the plan/expiry change.
      await repository.updateSchoolSubscription(
        event.schoolId,
        event.planId,
        event.expiry,
      );

      add(LoadSuperAdminDashboard());
    } catch (e) {
      emit(state.copyWith(errorMessage: friendlyErrorMessage(e)));
    }
  }

  Future<void> _onToggleFeature(
    ToggleFeatureEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      final school = state.schools.firstWhere((s) => s.id == event.schoolId);
      final updatedFeatures = List<String>.from(school.enabledFeatures);
      if (event.enabled) {
        if (!updatedFeatures.contains(event.feature)) {
          updatedFeatures.add(event.feature);
        }
      } else {
        updatedFeatures.remove(event.feature);
      }

      await repository.updateSchool(
        school.copyWith(enabledFeatures: updatedFeatures),
      );

      await repository.logAction(
        AuditLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          ownerId: _ownerId,
          action: 'TOGGLE_FEATURE',
          schoolId: event.schoolId,
          timestamp: DateTime.now(),
          device: 'Platform Dashboard',
          metadata: {'feature': event.feature, 'enabled': event.enabled},
        ),
      );

      add(LoadSuperAdminDashboard());
    } catch (e) {
      emit(state.copyWith(errorMessage: friendlyErrorMessage(e)));
    }
  }
}
