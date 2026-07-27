import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../academic/domain/usecases/manage_report_cards.dart';
import '../../domain/usecases/get_dean_stats.dart';
import 'dean_event.dart';
import 'dean_state.dart';

class DeanBloc extends Bloc<DeanEvent, DeanState> {
  final GetDeanStats getDeanStats;
  final GetReportCards getReportCards;
  final SignReportCard signReportCard;

  DeanBloc({
    required this.getDeanStats,
    required this.getReportCards,
    required this.signReportCard,
  }) : super(DeanInitial()) {
    on<DeanStatsRequested>(_onDeanStatsRequested);
    on<DeanReportCardsRequested>(_onDeanReportCardsRequested);
    on<DeanSignReportCardRequested>(_onDeanSignReportCardRequested);
  }

  Future<void> _onDeanStatsRequested(
    DeanStatsRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await getDeanStats(NoParams());
    
    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (stats) => emit(DeanLoaded(stats)),
    );
  }

  Future<void> _onDeanReportCardsRequested(
    DeanReportCardsRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await getReportCards(
      className: event.className,
      term: event.term,
      year: event.year,
      status: event.status,
    );

    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (reportCards) => emit(DeanReportCardsLoaded(reportCards)),
    );
  }

  Future<void> _onDeanSignReportCardRequested(
    DeanSignReportCardRequested event,
    Emitter<DeanState> emit,
  ) async {
    emit(DeanLoading());
    final result = await signReportCard(SignReportParams(
      reportCardId: event.reportCardId,
      signerId: event.deanId,
      isHeadTeacher: false,
    ));

    result.fold(
      (failure) => emit(DeanError(failure.message)),
      (_) {
        emit(const DeanOperationSuccess('Report card signed successfully'));
        add(const DeanReportCardsRequested()); // Refresh the list
      },
    );
  }
}
