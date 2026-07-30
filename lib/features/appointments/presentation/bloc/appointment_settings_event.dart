import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_type.dart';
import '../../domain/entities/staff_availability.dart';

abstract class AppointmentSettingsEvent extends Equatable {
  const AppointmentSettingsEvent();

  @override
  List<Object?> get props => [];
}

class WatchAppointmentTypesEvent extends AppointmentSettingsEvent {
  final String schoolId;
  const WatchAppointmentTypesEvent(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class SaveAppointmentTypeEvent extends AppointmentSettingsEvent {
  final AppointmentType type;
  const SaveAppointmentTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
}

class DeleteAppointmentTypeEvent extends AppointmentSettingsEvent {
  final String id;
  const DeleteAppointmentTypeEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadStaffAvailabilityEvent extends AppointmentSettingsEvent {
  final String staffId;
  final String schoolId;
  const LoadStaffAvailabilityEvent(this.staffId, this.schoolId);

  @override
  List<Object?> get props => [staffId, schoolId];
}

class SaveStaffAvailabilityEvent extends AppointmentSettingsEvent {
  final StaffAvailability availability;
  const SaveStaffAvailabilityEvent(this.availability);

  @override
  List<Object?> get props => [availability];
}
