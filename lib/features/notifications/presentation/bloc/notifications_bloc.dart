import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_alerts.dart';
import '../../domain/usecases/mark_alert_read.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetAlerts getAlerts;
  final MarkAlertRead markAlertRead;

  NotificationsBloc({required this.getAlerts, required this.markAlertRead}) : super(NotificationsInitial()) {
    on<FetchAlerts>(_onFetchAlerts);
    on<DismissAlert>(_onDismissAlert);
  }

  void _onDismissAlert(DismissAlert event, Emitter<NotificationsState> emit) {
    final current = state;
    if (current is NotificationsLoaded) {
      emit(NotificationsLoaded(
        current.alerts.where((a) => a.id != event.alertId).toList(),
      ));
    }
    // Fire-and-forget: persist so the alert doesn't reappear as unread on
    // the next FetchAlerts (e.g. app restart), and so the bell badge clears.
    markAlertRead(event.alertId, event.uid);
  }

  Future<void> _onFetchAlerts(
    FetchAlerts event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    final result = await getAlerts(event.studentIds, groups: event.groups);
    result.fold(
      (failure) => emit(const NotificationsError('Server Failure')),
      (alerts) => emit(NotificationsLoaded(alerts)),
    );
  }
}
