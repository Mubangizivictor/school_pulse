import 'package:equatable/equatable.dart';
import '../../domain/entities/dean_dashboard_stats.dart';
import '../../../academic/domain/entities/report_card.dart';

abstract class DeanState extends Equatable {
  const DeanState();
  
  @override
  List<Object?> get props => [];
}

class DeanInitial extends DeanState {}

class DeanLoading extends DeanState {}

class DeanLoaded extends DeanState {
  final DeanDashboardStats stats;

  const DeanLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class DeanReportCardsLoaded extends DeanState {
  final List<ReportCard> reportCards;

  const DeanReportCardsLoaded(this.reportCards);

  @override
  List<Object?> get props => [reportCards];
}

class DeanOperationSuccess extends DeanState {
  final String message;

  const DeanOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DeanError extends DeanState {
  final String message;

  const DeanError(this.message);

  @override
  List<Object?> get props => [message];
}
