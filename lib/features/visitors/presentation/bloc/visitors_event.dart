import 'package:equatable/equatable.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/entities/visitor_blacklist.dart';
import '../../domain/entities/package_delivery.dart';

abstract class VisitorsEvent extends Equatable {
  const VisitorsEvent();

  @override
  List<Object?> get props => [];
}

class LoadVisitors extends VisitorsEvent {
  final String schoolId;
  const LoadVisitors(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class WatchVisitorsList extends VisitorsEvent {
  final String schoolId;
  const WatchVisitorsList(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class CheckInNewVisitor extends VisitorsEvent {
  final Visitor visitor;
  final String? preApprovedId;
  const CheckInNewVisitor(this.visitor, {this.preApprovedId});

  @override
  List<Object?> get props => [visitor, preApprovedId];
}

class ReissueBadgeEvent extends VisitorsEvent {
  final String visitorId;
  const ReissueBadgeEvent(this.visitorId);

  @override
  List<Object?> get props => [visitorId];
}

class CheckOutVisitorEvent extends VisitorsEvent {
  final String visitorId;
  final DateTime departureTime;
  final String duration;

  const CheckOutVisitorEvent({
    required this.visitorId,
    required this.departureTime,
    required this.duration,
  });

  @override
  List<Object?> get props => [visitorId, departureTime, duration];
}

class SearchVisitorsEvent extends VisitorsEvent {
  final String schoolId;
  final String query;
  const SearchVisitorsEvent(this.schoolId, this.query);

  @override
  List<Object?> get props => [schoolId, query];
}

class SyncPendingVisitors extends VisitorsEvent {
  const SyncPendingVisitors();
}

class LoadPreApprovedVisitors extends VisitorsEvent {
  final String schoolId;
  const LoadPreApprovedVisitors(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class AddToBlacklistEvent extends VisitorsEvent {
  final VisitorBlacklist blacklist;
  const AddToBlacklistEvent(this.blacklist);

  @override
  List<Object?> get props => [blacklist];
}

class LoadEmergencyRollCall extends VisitorsEvent {
  final String schoolId;
  const LoadEmergencyRollCall(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class LoadScheduledVisits extends VisitorsEvent {
  final String schoolId;
  const LoadScheduledVisits(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class ApproveScheduledVisitEvent extends VisitorsEvent {
  final String visitId;
  const ApproveScheduledVisitEvent(this.visitId);

  @override
  List<Object?> get props => [visitId];
}

class RejectScheduledVisitEvent extends VisitorsEvent {
  final String visitId;
  const RejectScheduledVisitEvent(this.visitId);

  @override
  List<Object?> get props => [visitId];
}

class LoadPackageDeliveries extends VisitorsEvent {
  final String schoolId;
  const LoadPackageDeliveries(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class LogNewPackageDelivery extends VisitorsEvent {
  final PackageDelivery delivery;
  const LogNewPackageDelivery(this.delivery);

  @override
  List<Object?> get props => [delivery];
}

class MarkPackageCollectedEvent extends VisitorsEvent {
  final String packageId;
  final String collectedBy;
  const MarkPackageCollectedEvent(this.packageId, this.collectedBy);

  @override
  List<Object?> get props => [packageId, collectedBy];
}

class ExportVisitorsEvent extends VisitorsEvent {
  final String schoolId;
  final String schoolName;
  const ExportVisitorsEvent(this.schoolId, this.schoolName);

  @override
  List<Object?> get props => [schoolId, schoolName];
}
