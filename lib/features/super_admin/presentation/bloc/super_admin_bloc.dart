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
    on<UpdateSchoolStatusEvent>(_onUpdateSchoolStatus);
    on<UpdateSubscriptionEvent>(_onUpdateSubscription);
    on<ToggleFeatureEvent>(_onToggleFeature);
    on<LoadInvoicesEvent>(_onLoadInvoices);
    on<InitiatePaymentEvent>(_onInitiatePayment);
    on<LoadAuditLogsEvent>(_onLoadAuditLogs);
    on<EnterSupportModeEvent>(_onEnterSupportMode);
    on<ExitSupportModeEvent>(_onExitSupportMode);
  }

  /// The authenticated owner's uid, attributed on every audit log entry.
  /// Never trust a caller-supplied identity for this - it is always read
  /// fresh from the signed-in Firebase session.
  String get _ownerId => auth.currentUser?.uid ?? 'unknown';

  Future<void> _onLoadAuditLogs(
    LoadAuditLogsEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      final logs = await repository.getAuditLogs(schoolId: event.schoolId);
      emit(state.copyWith(auditLogs: logs));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onEnterSupportMode(
    EnterSupportModeEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      // Audit first: impersonation must never happen off the record, even
      // if the local state update below never completes.
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
    emit(state.copyWith(supportModeSchoolId: null));
  }

  Future<void> _onInitiatePayment(
    InitiatePaymentEvent event,
    Emitter<SuperAdminState> emit,
  ) async {
    try {
      // TODO: surface the returned payment link to the UI (e.g. via state or a side-effect listener) so it can be opened.
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
    emit(state.copyWith(status: SuperAdminStatus.loading));
    try {
      final schools = await repository.getAllSchools();
      final plans = await repository.getSubscriptionPlans();
      final stats = await repository.getPlatformStats();
      final invoices = await billingRepository.getInvoices();

      emit(
        state.copyWith(
          status: SuperAdminStatus.success,
          schools: schools,
          plans: plans,
          stats: stats,
          invoices: invoices,
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
        if (!updatedFeatures.contains(event.feature))
          updatedFeatures.add(event.feature);
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
