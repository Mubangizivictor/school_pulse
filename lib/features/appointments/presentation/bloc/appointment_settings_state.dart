import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_type.dart';
import '../../domain/entities/staff_availability.dart';

abstract class AppointmentSettingsState extends Equatable {
  const AppointmentSettingsState();

  @override
  List<Object?> get props => [];
}

class AppointmentSettingsInitial extends AppointmentSettingsState {}

class AppointmentSettingsLoading extends AppointmentSettingsState {}

class AppointmentSettingsLoaded extends AppointmentSettingsState {
  final List<AppointmentType> types;
  final StaffAvailability? availability;

  const AppointmentSettingsLoaded({this.types = const [], this.availability});

  AppointmentSettingsLoaded copyWith({
    List<AppointmentType>? types,
    StaffAvailability? availability,
  }) {
    return AppointmentSettingsLoaded(
      types: types ?? this.types,
      availability: availability ?? this.availability,
    );
  }

  @override
  List<Object?> get props => [types, availability];
}

class AppointmentSettingsError extends AppointmentSettingsState {
  final String message;
  const AppointmentSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
