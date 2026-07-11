import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_alerts.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetAlerts getAlerts;

  NotificationsBloc({required this.getAlerts}) : super(NotificationsInitial()) {
    on<FetchAlerts>(_onFetchAlerts);
  }

  Future<void> _onFetchAlerts(
    FetchAlerts event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    final result = await getAlerts(event.studentIds);
    result.fold(
      (failure) => emit(const NotificationsError('Server Failure')),
      (alerts) => emit(NotificationsLoaded(alerts)),
    );
  }
}
