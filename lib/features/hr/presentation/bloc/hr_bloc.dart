import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/hr/domain/repositories/hr_repository.dart';
import 'hr_event.dart';
import 'hr_state.dart';

class HrBloc extends Bloc<HrEvent, HrState> {
  final HrRepository repository;

  HrBloc({required this.repository}) : super(HrInitial()) {
    on<LoadPayrollRecords>(_onLoadPayrollRecords);
    on<GeneratePayroll>(_onGeneratePayroll);
  }

  Future<void> _onLoadPayrollRecords(
    LoadPayrollRecords event,
    Emitter<HrState> emit,
  ) async {
    emit(HrLoading());
    try {
      final records = await repository.getPayrollRecords(event.schoolId);
      emit(PayrollRecordsLoaded(records));
    } catch (e) {
      emit(HrError(e.toString()));
    }
  }

  Future<void> _onGeneratePayroll(
    GeneratePayroll event,
    Emitter<HrState> emit,
  ) async {
    try {
      await repository.generatePayroll(event.record);
      emit(PayrollGenerated());
      add(LoadPayrollRecords(event.record.schoolId));
    } catch (e) {
      emit(HrError(e.toString()));
    }
  }
}
