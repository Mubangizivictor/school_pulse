import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/appointment_type.dart';
import '../../domain/usecases/appointment_usecases.dart';
import 'appointment_settings_event.dart';
import 'appointment_settings_state.dart';

class AppointmentSettingsBloc
    extends Bloc<AppointmentSettingsEvent, AppointmentSettingsState> {
  final WatchAppointmentTypes watchAppointmentTypes;
  final SaveAppointmentType saveAppointmentType;
  final DeleteAppointmentType deleteAppointmentType;
  final GetStaffAvailability getStaffAvailability;
  final SaveStaffAvailability saveStaffAvailability;

  StreamSubscription<List<AppointmentType>>? _typesSubscription;

  AppointmentSettingsBloc({
    required this.watchAppointmentTypes,
    required this.saveAppointmentType,
    required this.deleteAppointmentType,
    required this.getStaffAvailability,
    required this.saveStaffAvailability,
  }) : super(AppointmentSettingsInitial()) {
    on<WatchAppointmentTypesEvent>(_onWatchTypes);
    on<SaveAppointmentTypeEvent>(_onSaveType);
    on<DeleteAppointmentTypeEvent>(_onDeleteType);
    on<LoadStaffAvailabilityEvent>(_onLoadAvailability);
    on<SaveStaffAvailabilityEvent>(_onSaveAvailability);
  }

  Future<void> _onWatchTypes(
    WatchAppointmentTypesEvent event,
    Emitter<AppointmentSettingsState> emit,
  ) async {
    if (state is! AppointmentSettingsLoaded) emit(AppointmentSettingsLoading());
    await _typesSubscription?.cancel();
    final completer = Completer<void>();
    _typesSubscription = watchAppointmentTypes(event.schoolId).listen((types) {
      final current = state;
      if (current is AppointmentSettingsLoaded) {
        emit(current.copyWith(types: types));
      } else {
        emit(AppointmentSettingsLoaded(types: types));
      }
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
  }

  Future<void> _onSaveType(
    SaveAppointmentTypeEvent event,
    Emitter<AppointmentSettingsState> emit,
  ) async {
    final result = await saveAppointmentType(event.type);
    result.fold(
      (failure) => emit(AppointmentSettingsError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onDeleteType(
    DeleteAppointmentTypeEvent event,
    Emitter<AppointmentSettingsState> emit,
  ) async {
    final result = await deleteAppointmentType(event.id);
    result.fold(
      (failure) => emit(AppointmentSettingsError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onLoadAvailability(
    LoadStaffAvailabilityEvent event,
    Emitter<AppointmentSettingsState> emit,
  ) async {
    final result = await getStaffAvailability(event.staffId, event.schoolId);
    result.fold((failure) => emit(AppointmentSettingsError(failure.message)), (
      availability,
    ) {
      final current = state;
      if (current is AppointmentSettingsLoaded) {
        emit(current.copyWith(availability: availability));
      } else {
        emit(AppointmentSettingsLoaded(availability: availability));
      }
    });
  }

  Future<void> _onSaveAvailability(
    SaveStaffAvailabilityEvent event,
    Emitter<AppointmentSettingsState> emit,
  ) async {
    final result = await saveStaffAvailability(event.availability);
    result.fold((failure) => emit(AppointmentSettingsError(failure.message)), (
      _,
    ) {
      final current = state;
      if (current is AppointmentSettingsLoaded) {
        emit(current.copyWith(availability: event.availability));
      } else {
        emit(AppointmentSettingsLoaded(availability: event.availability));
      }
    });
  }

  @override
  Future<void> close() {
    _typesSubscription?.cancel();
    return super.close();
  }
}
