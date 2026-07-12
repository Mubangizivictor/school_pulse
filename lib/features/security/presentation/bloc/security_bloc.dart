import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/security_repository.dart';
import 'security_event.dart';
import 'security_state.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  final SecurityRepository repository;

  SecurityBloc({required this.repository}) : super(SecurityInitial()) {
    on<SecurityDashboardRequested>((event, emit) async {
      emit(SecurityLoading());
      final result = await repository.getDashboardData();
      result.fold(
        (failure) => emit(SecurityError(failure.message)),
        (data) => emit(data),
      );
    });
  }
}
