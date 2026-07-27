import 'package:equatable/equatable.dart';
import '../../../academic/domain/entities/report_card.dart';

abstract class DeanEvent extends Equatable {
  const DeanEvent();

  @override
  List<Object?> get props => [];
}

class DeanStatsRequested extends DeanEvent {}

class DeanReportCardsRequested extends DeanEvent {
  final String? className;
  final String? term;
  final String? year;
  final ReportCardStatus? status;

  const DeanReportCardsRequested({
    this.className,
    this.term,
    this.year,
    this.status,
  });

  @override
  List<Object?> get props => [className, term, year, status];
}

class DeanSignReportCardRequested extends DeanEvent {
  final String reportCardId;
  final String deanId;

  const DeanSignReportCardRequested({
    required this.reportCardId,
    required this.deanId,
  });

  @override
  List<Object?> get props => [reportCardId, deanId];
}
