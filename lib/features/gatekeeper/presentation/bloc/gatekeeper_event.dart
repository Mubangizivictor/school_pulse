import 'package:equatable/equatable.dart';

abstract class GatekeeperEvent extends Equatable {
  const GatekeeperEvent();

  @override
  List<Object?> get props => [];
}

class GatekeeperDashboardRequested extends GatekeeperEvent {}

class LogVisitorEntry extends GatekeeperEvent {
  final String visitorName;
  final String purpose;
  final String contact;

  const LogVisitorEntry({
    required this.visitorName,
    required this.purpose,
    required this.contact,
  });

  @override
  List<Object?> get props => [visitorName, purpose, contact];
}
