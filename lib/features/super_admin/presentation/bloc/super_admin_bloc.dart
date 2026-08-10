import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/super_admin_repository.dart';
import '../../domain/repositories/billing_repository.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/entities/school.dart';
import 'super_admin_event.dart';
import 'super_admin_state.dart';

class SuperAdminBloc extends Bloc<SuperAdminEvent, SuperAdminState> {
  final SuperAdminRepository repository;
  final BillingRepository billingRepository;
  final FirebaseAuth auth;

  SuperAdminBloc({
    required this.repository,
    required this.billingRepository,
    required this.auth,
  }) : super(const SuperAdminState()) {
    on<LoadSuperAdminDashboard>(_onLoadDashboard);
    on<CreateSchoolEvent>(_onCreateSchool);
    on<ApproveSchoolApplicationEvent>(_onApproveSchoolApplication);
    on<RejectSchoolApplicationEvent>(_onRejectSchoolApplication);
    on<UpdateSchoolStatusEvent>(_onUpdateSchoolStatus);
    on<UpdateSubscriptionEvent>(_onUpdateSubscription);
    on<ToggleFeatureEvent>(_onToggleFeature);
    on<LoadInvoicesEvent>(_onLoadInvoices);
    on<InitiatePaymentEvent>(_onInitiatePayment);
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
      emit(state.copyWith(errorMessage: e.toString()));
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
      emit(state.copyWith(errorMessage: e.toString()));
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

  Future<void> _onInitiatePayment(
    InitiatePaymentEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      await billingRepository.initiateSubscriptionPayment(
        schoolId: event.schoolId,
        amount: event.amount,
        email: event.email,
        phoneNumber: event.phoneNumber,
        planId: event.planId,
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
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
      final results = await Future.wait([
        repository.getAllSchools(),
        repository.getSchoolApplications(),
        repository.getSubscriptionPlans(),
        repository.getPlatformStats(),
        billingRepository.getInvoices(),
      ]);

      emit(
        state.copyWith(
          status: SuperAdminStatus.success,
          schools: results[0] as List<School>,
          applications: results[1] as dynamic,
          plans: results[2] as dynamic,
          stats: results[3] as Map<String, dynamic>,
          invoices: results[4] as dynamic,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SuperAdminStatus.failure,
          errorMessage: e.toString(),
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
      final schools = await repository.getAllSchools();
      final applications = await repository.getSchoolApplications();
      final stats = await repository.getPlatformStats();
      emit(
        state.copyWith(
          schools: schools,
          applications: applications,
          stats: stats,
          clearReviewingApplicationId: true,
          actionMessage: 'School approved and activated. School ID: $schoolId',
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          clearReviewingApplicationId: true,
          errorMessage: e.toString(),
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
      await repository.rejectSchoolApplication(event.applicationId, event.reason);
      final applications = await repository.getSchoolApplications();
      final stats = await repository.getPlatformStats();
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
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadInvoices(
    LoadInvoicesEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      final invoices = await billingRepository.getInvoices(
        schoolId: event.schoolId,
      );
      emit(state.copyWith(invoices: invoices));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateSchool(
    CreateSchoolEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      await repository.createSchool(
        event.school,
        event.adminEmail,
        event.adminPassword,
      );

      await repository.logAction(
        AuditLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          ownerId: _ownerId,
          action: 'CREATE_SCHOOL',
          schoolId: event.school.id,
          timestamp: DateTime.now(),
          device: 'Platform Dashboard',
          metadata: {'schoolName': event.school.name},
        ),
      );

      add(LoadSuperAdminDashboard());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateSchoolStatus(
    UpdateSchoolStatusEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      if (event.status == SchoolStatus.suspended) {
        await repository.suspendSchool(
          event.schoolId,
          event.reason ?? 'No reason provided',
        );
      } else if (event.status == SchoolStatus.active) {
        await repository.activateSchool(event.schoolId);
      }

      await repository.logAction(
        AuditLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          ownerId: _ownerId,
          action: 'UPDATE_SCHOOL_STATUS',
          schoolId: event.schoolId,
          timestamp: DateTime.now(),
          device: 'Platform Dashboard',
          reason: event.reason,
          metadata: {'newStatus': event.status.name},
        ),
      );

      add(LoadSuperAdminDashboard());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateSubscription(
    UpdateSubscriptionEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      await repository.updateSchoolSubscription(
        event.schoolId,
        event.planId,
        event.expiry,
      );

      await repository.logAction(
        AuditLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          ownerId: _ownerId,
          action: 'UPDATE_SUBSCRIPTION',
          schoolId: event.schoolId,
          timestamp: DateTime.now(),
          device: 'Platform Dashboard',
          metadata: {
            'planId': event.planId,
            'expiry': event.expiry.toIso8601String(),
          },
        ),
      );

      add(LoadSuperAdminDashboard());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
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
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
