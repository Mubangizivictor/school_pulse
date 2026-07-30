import 'package:equatable/equatable.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/entities/visitor_blacklist.dart';
import '../../domain/entities/pre_approved_visitor.dart';
import '../../domain/entities/scheduled_visit.dart';
import '../../domain/entities/package_delivery.dart';

abstract class VisitorsState extends Equatable {
  const VisitorsState();

  @override
  List<Object?> get props => [];
}

class VisitorsInitial extends VisitorsState {}

class VisitorsLoading extends VisitorsState {}

class VisitorsLoaded extends VisitorsState {
  final List<Visitor> visitors;
  final List<Visitor> activeVisitors;
  final List<Visitor> overstayedVisitors;
  final List<VisitorBlacklist> blacklist;
  final List<PreApprovedVisitor> preApprovedVisitors;
  final List<ScheduledVisit> scheduledVisits;
  final List<PackageDelivery> packageDeliveries;

  const VisitorsLoaded({
    required this.visitors,
    this.activeVisitors = const [],
    this.overstayedVisitors = const [],
    this.blacklist = const [],
    this.preApprovedVisitors = const [],
    this.scheduledVisits = const [],
    this.packageDeliveries = const [],
  });

  @override
  List<Object?> get props => [
        visitors,
        activeVisitors,
        overstayedVisitors,
        blacklist,
        preApprovedVisitors,
        scheduledVisits,
        packageDeliveries,
      ];

  VisitorsLoaded copyWith({
    List<Visitor>? visitors,
    List<Visitor>? activeVisitors,
    List<Visitor>? overstayedVisitors,
    List<VisitorBlacklist>? blacklist,
    List<PreApprovedVisitor>? preApprovedVisitors,
    List<ScheduledVisit>? scheduledVisits,
    List<PackageDelivery>? packageDeliveries,
  }) {
    return VisitorsLoaded(
      visitors: visitors ?? this.visitors,
      activeVisitors: activeVisitors ?? this.activeVisitors,
      overstayedVisitors: overstayedVisitors ?? this.overstayedVisitors,
      blacklist: blacklist ?? this.blacklist,
      preApprovedVisitors: preApprovedVisitors ?? this.preApprovedVisitors,
      scheduledVisits: scheduledVisits ?? this.scheduledVisits,
      packageDeliveries: packageDeliveries ?? this.packageDeliveries,
    );
  }
}

class VisitorsError extends VisitorsState {
  final String message;
  const VisitorsError(this.message);

  @override
  List<Object?> get props => [message];
}

class VisitorsExporting extends VisitorsState {}

class VisitorsExportSuccess extends VisitorsState {
  final String message;
  const VisitorsExportSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BadgeReissued extends VisitorsState {
  final Visitor visitor;
  const BadgeReissued(this.visitor);

  @override
  List<Object?> get props => [visitor];
}
