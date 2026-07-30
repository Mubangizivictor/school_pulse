import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import 'package:school_pulse/features/visitors/domain/entities/visitor.dart';
import 'package:school_pulse/features/visitors/domain/entities/visitor_blacklist.dart';
import '../../domain/usecases/visitor_usecases.dart';
import 'visitors_event.dart';
import 'visitors_state.dart';

class VisitorsBloc extends Bloc<VisitorsEvent, VisitorsState> {
  final GetVisitors getVisitors;
  final WatchVisitors watchVisitors;
  final CheckInVisitor checkInVisitor;
  final CheckOutVisitor checkOutVisitor;
  final SearchVisitors searchVisitors;
  final GetVisitorBlacklist getVisitorBlacklist;
  final AddToBlacklist addToBlacklist;
  final GetPreApprovedVisitors getPreApprovedVisitors;
  final MarkPreApprovedAsUsed markPreApprovedAsUsed;
  final SyncVisitors syncVisitors;
  final NotificationService notificationService = NotificationService();
  
  // Enterprise UseCases
  final GetActiveVisitors getActiveVisitors;
  final GetOverstayedVisitors getOverstayedVisitors;
  final GetScheduledVisits getScheduledVisits;
  final ApproveScheduledVisit approveScheduledVisit;
  final RejectScheduledVisit rejectScheduledVisit;
  final CheckInScheduledVisit checkInScheduledVisit;
  final LogPackageDelivery logPackageDelivery;
  final GetPackageDeliveries getPackageDeliveries;
  final MarkPackageAsCollected markPackageAsCollected;
  final ExportVisitorsToSheets exportVisitorsToSheets;
  final ReissueBadge reissueBadge;

  StreamSubscription? _visitorsSubscription;
  DateTime? _lastOverstayAlertTime;

  VisitorsBloc({
    required this.getVisitors,
    required this.watchVisitors,
    required this.checkInVisitor,
    required this.checkOutVisitor,
    required this.searchVisitors,
    required this.getVisitorBlacklist,
    required this.addToBlacklist,
    required this.getPreApprovedVisitors,
    required this.markPreApprovedAsUsed,
    required this.syncVisitors,
    required this.getActiveVisitors,
    required this.getOverstayedVisitors,
    required this.getScheduledVisits,
    required this.approveScheduledVisit,
    required this.rejectScheduledVisit,
    required this.checkInScheduledVisit,
    required this.logPackageDelivery,
    required this.getPackageDeliveries,
    required this.markPackageAsCollected,
    required this.exportVisitorsToSheets,
    required this.reissueBadge,
  }) : super(VisitorsInitial()) {
    on<LoadVisitors>(_onLoadVisitors);
    on<WatchVisitorsList>(_onWatchVisitorsList);
    on<CheckInNewVisitor>(_onCheckInVisitor);
    on<CheckOutVisitorEvent>(_onCheckOutVisitor);
    on<SearchVisitorsEvent>(_onSearchVisitors);
    on<SyncPendingVisitors>(_onSyncVisitors);
    on<LoadPreApprovedVisitors>(_onLoadPreApprovedVisitors);
    on<AddToBlacklistEvent>(_onAddToBlacklist);
    
    // Enterprise events
    on<LoadEmergencyRollCall>(_onLoadEmergencyRollCall);
    on<LoadScheduledVisits>(_onLoadScheduledVisits);
    on<ApproveScheduledVisitEvent>(_onApproveScheduledVisit);
    on<RejectScheduledVisitEvent>(_onRejectScheduledVisit);
    on<LoadPackageDeliveries>(_onLoadPackageDeliveries);
    on<LogNewPackageDelivery>(_onLogPackageDelivery);
    on<MarkPackageCollectedEvent>(_onMarkPackageCollected);
    on<ExportVisitorsEvent>(_onExportVisitors);
    on<ReissueBadgeEvent>(_onReissueBadge);
  }

  Future<void> _onLoadVisitors(LoadVisitors event, Emitter<VisitorsState> emit) async {
    emit(VisitorsLoading());
    final result = await getVisitors(event.schoolId);
    final blacklistResult = await getVisitorBlacklist(event.schoolId);
    final activeResult = await getActiveVisitors(event.schoolId);
    final overstayedResult = await getOverstayedVisitors(event.schoolId);
    
    result.fold(
      (failure) => emit(const VisitorsError('Failed to load visitors')),
      (visitors) {
        final blacklist = blacklistResult.fold((_) => <VisitorBlacklist>[], (b) => b);
        final active = activeResult.fold((_) => <Visitor>[], (a) => a);
        final overstayed = overstayedResult.fold((_) => <Visitor>[], (o) => o);

        emit(VisitorsLoaded(
          visitors: visitors,
          blacklist: blacklist,
          activeVisitors: active,
          overstayedVisitors: overstayed,
        ));
        
        // Notify about overstays with throttling (once per hour)
        final now = DateTime.now();
        if (overstayed.isNotEmpty && 
            (_lastOverstayAlertTime == null || 
             now.difference(_lastOverstayAlertTime!).inHours >= 1)) {
          notificationService.sendSecurityAlert(
            title: 'Overstay Alert',
            body: '${overstayed.length} visitors have exceeded their expected duration.',
          );
          _lastOverstayAlertTime = now;
        }

        // Load other metadata
        add(LoadPreApprovedVisitors(event.schoolId));
        add(LoadScheduledVisits(event.schoolId));
        add(LoadPackageDeliveries(event.schoolId));
      },
    );
  }

  Future<void> _onWatchVisitorsList(WatchVisitorsList event, Emitter<VisitorsState> emit) async {
    await _visitorsSubscription?.cancel();
    _visitorsSubscription = watchVisitors(event.schoolId).listen((visitors) {
      add(LoadVisitors(event.schoolId));
    });
  }

  Future<void> _onCheckInVisitor(CheckInNewVisitor event, Emitter<VisitorsState> emit) async {
    final result = await checkInVisitor(event.visitor);
    result.fold(
      (failure) => emit(const VisitorsError('Failed to check in visitor')),
      (_) async {
        if (event.preApprovedId != null) {
          await markPreApprovedAsUsed(event.preApprovedId!);
        }
        if (event.visitor.scheduledVisitId != null) {
          await checkInScheduledVisit(event.visitor.scheduledVisitId!);
        }

        // Notify Host
        if (event.visitor.hostId != null) {
          notificationService.sendDirectNotification(
            userId: event.visitor.hostId!,
            title: 'Visitor Arrived',
            body: '${event.visitor.fullName} is here to see you for ${event.visitor.purpose}.',
          );
        }

        add(LoadVisitors(event.visitor.schoolId));
        add(const SyncPendingVisitors());
      },
    );
  }

  Future<void> _onCheckOutVisitor(CheckOutVisitorEvent event, Emitter<VisitorsState> emit) async {
    final result = await checkOutVisitor(event.visitorId, event.departureTime, event.duration);
    result.fold(
      (failure) => emit(const VisitorsError('Failed to check out visitor')),
      (visitor) {
        add(LoadVisitors(visitor.schoolId));
        add(const SyncPendingVisitors());
      },
    );
  }

  Future<void> _onSearchVisitors(SearchVisitorsEvent event, Emitter<VisitorsState> emit) async {
    if (event.query.isEmpty) {
      add(LoadVisitors(event.schoolId));
      return;
    }
    final result = await searchVisitors(event.schoolId, event.query);
    result.fold(
      (failure) => emit(const VisitorsError('Search failed')),
      (visitors) {
        if (state is VisitorsLoaded) {
          final currentState = state as VisitorsLoaded;
          emit(currentState.copyWith(visitors: visitors));
        } else {
          emit(VisitorsLoaded(visitors: visitors));
        }
      },
    );
  }

  Future<void> _onSyncVisitors(SyncPendingVisitors event, Emitter<VisitorsState> emit) async {
    await syncVisitors();
  }

  Future<void> _onLoadPreApprovedVisitors(LoadPreApprovedVisitors event, Emitter<VisitorsState> emit) async {
    final result = await getPreApprovedVisitors(event.schoolId);
    result.fold(
      (failure) => null,
      (preApproved) {
        if (state is VisitorsLoaded) {
          final currentState = state as VisitorsLoaded;
          emit(currentState.copyWith(preApprovedVisitors: preApproved));
        }
      },
    );
  }

  Future<void> _onAddToBlacklist(AddToBlacklistEvent event, Emitter<VisitorsState> emit) async {
    final result = await addToBlacklist(event.blacklist);
    result.fold(
      (failure) => emit(const VisitorsError('Failed to blacklist visitor')),
      (_) {
        if (state is VisitorsLoaded) {
          final currentState = state as VisitorsLoaded;
          final updatedBlacklist = List<VisitorBlacklist>.from(currentState.blacklist)
            ..add(event.blacklist);
          emit(currentState.copyWith(blacklist: updatedBlacklist));
        }
      },
    );
  }

  Future<void> _onLoadEmergencyRollCall(LoadEmergencyRollCall event, Emitter<VisitorsState> emit) async {
    final result = await getActiveVisitors(event.schoolId);
    result.fold(
      (failure) => null,
      (active) {
        if (state is VisitorsLoaded) {
          emit((state as VisitorsLoaded).copyWith(activeVisitors: active));
        }
      },
    );
  }

  Future<void> _onLoadScheduledVisits(LoadScheduledVisits event, Emitter<VisitorsState> emit) async {
    final result = await getScheduledVisits(event.schoolId);
    result.fold(
      (failure) => null,
      (visits) {
        if (state is VisitorsLoaded) {
          emit((state as VisitorsLoaded).copyWith(scheduledVisits: visits));
        }
      },
    );
  }

  Future<void> _onApproveScheduledVisit(ApproveScheduledVisitEvent event, Emitter<VisitorsState> emit) async {
    await approveScheduledVisit(event.visitId);
    _reloadScheduledVisitsFromState();
  }

  Future<void> _onRejectScheduledVisit(RejectScheduledVisitEvent event, Emitter<VisitorsState> emit) async {
    await rejectScheduledVisit(event.visitId);
    _reloadScheduledVisitsFromState();
  }

  void _reloadScheduledVisitsFromState() {
    if (state is VisitorsLoaded) {
      final loaded = state as VisitorsLoaded;
      final schoolId = loaded.visitors.isNotEmpty
          ? loaded.visitors.first.schoolId
          : (loaded.scheduledVisits.isNotEmpty ? loaded.scheduledVisits.first.schoolId : null);
      if (schoolId != null) {
        add(LoadScheduledVisits(schoolId));
      }
    }
  }

  Future<void> _onLoadPackageDeliveries(LoadPackageDeliveries event, Emitter<VisitorsState> emit) async {
    final result = await getPackageDeliveries(event.schoolId);
    result.fold(
      (failure) => null,
      (packages) {
        if (state is VisitorsLoaded) {
          emit((state as VisitorsLoaded).copyWith(packageDeliveries: packages));
        }
      },
    );
  }

  Future<void> _onLogPackageDelivery(LogNewPackageDelivery event, Emitter<VisitorsState> emit) async {
    final result = await logPackageDelivery(event.delivery);
    result.fold(
      (failure) => emit(const VisitorsError('Failed to log package')),
      (_) {
        // Notify recipient if they exist
        if (event.delivery.recipientId != null) {
          notificationService.sendDirectNotification(
            userId: event.delivery.recipientId!,
            title: 'Package Arrived',
            body: 'A package from ${event.delivery.courierName} has been received for you at the gate.',
          );
        }
        add(LoadPackageDeliveries(event.delivery.schoolId));
      },
    );
  }

  Future<void> _onMarkPackageCollected(MarkPackageCollectedEvent event, Emitter<VisitorsState> emit) async {
    await markPackageAsCollected(event.packageId, event.collectedBy);
    if (state is VisitorsLoaded) {
       final visitors = (state as VisitorsLoaded).visitors;
       if (visitors.isNotEmpty) {
         add(LoadPackageDeliveries(visitors.first.schoolId));
       }
    }
  }

  Future<void> _onExportVisitors(ExportVisitorsEvent event, Emitter<VisitorsState> emit) async {
    emit(VisitorsExporting());
    final result = await exportVisitorsToSheets(event.schoolId, event.schoolName);
    result.fold(
      (failure) => emit(VisitorsError(failure.message)),
      (_) {
        emit(const VisitorsExportSuccess('Visitor logs exported successfully to Google Sheets'));
        // Return to Loaded state after a short delay or just emit loaded again
        if (state is VisitorsLoaded || true) {
           add(LoadVisitors(event.schoolId));
        }
      },
    );
  }

  Future<void> _onReissueBadge(ReissueBadgeEvent event, Emitter<VisitorsState> emit) async {
    final result = await reissueBadge(event.visitorId);
    result.fold(
      (failure) => emit(const VisitorsError('Failed to reissue badge')),
      (visitor) {
        emit(BadgeReissued(visitor));
        add(LoadVisitors(visitor.schoolId));
      },
    );
  }

  @override
  Future<void> close() {
    _visitorsSubscription?.cancel();
    return super.close();
  }
}

