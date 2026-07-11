import 'package:flutter_bloc/flutter_bloc.dart';
import 'transport_coordinator_event.dart';
import 'transport_coordinator_state.dart';

class TransportCoordinatorBloc extends Bloc<TransportCoordinatorEvent, TransportCoordinatorState> {
  TransportCoordinatorBloc() : super(TransportCoordinatorInitial()) {
    on<TransportCoordinatorDashboardRequested>((event, emit) async {
      emit(TransportCoordinatorLoading());
      // Mocking delay and data
      await Future.delayed(const Duration(seconds: 1));
      emit(const TransportCoordinatorLoaded(
        activeBuses: 6,
        totalStudents: 124,
        studentsInTransit: 85,
        routes: [
          BusRoute(
            name: 'Kira - Namugongo',
            busNumber: 'Bus 04',
            driver: 'John Katende',
            studentCount: 22,
            status: 'En Route',
          ),
          BusRoute(
            name: 'Kireka - Bweyogerere',
            busNumber: 'Bus 02',
            driver: 'Sarah Nambasa',
            studentCount: 18,
            status: 'At School',
          ),
          BusRoute(
            name: 'Ntinda - Bukoto',
            busNumber: 'Bus 07',
            driver: 'Moses Okello',
            studentCount: 25,
            status: 'En Route',
          ),
        ],
      ));
    });
  }
}
