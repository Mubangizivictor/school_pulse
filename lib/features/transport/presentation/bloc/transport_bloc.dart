import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_transport_info.dart';
import 'transport_event.dart';
import 'transport_state.dart';

class TransportBloc extends Bloc<TransportEvent, TransportState> {
  final GetTransportInfo getTransportInfo;

  TransportBloc({required this.getTransportInfo}) : super(TransportInitial()) {
    on<FetchTransportInfo>(_onFetchTransportInfo);
  }

  Future<void> _onFetchTransportInfo(FetchTransportInfo event, Emitter<TransportState> emit) async {
    emit(TransportLoading());
    final result = await getTransportInfo(event.studentId);
    result.fold(
      (failure) => emit(const TransportError('Server Failure')),
      (info) => emit(TransportLoaded(info)),
    );
  }
}
