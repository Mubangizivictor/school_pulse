import 'package:equatable/equatable.dart';

/// A transport route's structural definition. Distinct from the display-
/// only BusRoute in the transport module's state file - this is the
/// master-data definition other modules could eventually read from.
class TransportRoute extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String code;
  final String description;
  final bool isActive;

  const TransportRoute({
    required this.id,
    required this.schoolId,
    required this.name,
    this.code = '',
    this.description = '',
    this.isActive = true,
  });

  TransportRoute copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? code,
    String? description,
    bool? isActive,
  }) {
    return TransportRoute(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, schoolId, name, code, description, isActive];
}

/// A stop/pickup point along a route.
class TransportStop extends Equatable {
  final String id;
  final String schoolId;
  final String routeId;
  final String name;
  final int order;
  final String pickupTime;
  final String zone;
  final bool isActive;

  const TransportStop({
    required this.id,
    required this.schoolId,
    required this.routeId,
    required this.name,
    this.order = 0,
    this.pickupTime = '',
    this.zone = '',
    this.isActive = true,
  });

  TransportStop copyWith({
    String? id,
    String? schoolId,
    String? routeId,
    String? name,
    int? order,
    String? pickupTime,
    String? zone,
    bool? isActive,
  }) {
    return TransportStop(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      routeId: routeId ?? this.routeId,
      name: name ?? this.name,
      order: order ?? this.order,
      pickupTime: pickupTime ?? this.pickupTime,
      zone: zone ?? this.zone,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    routeId,
    name,
    order,
    pickupTime,
    zone,
    isActive,
  ];
}

/// A vehicle (bus number, plate, capacity) optionally assigned to a route.
class TransportVehicle extends Equatable {
  final String id;
  final String schoolId;
  final String busNumber;
  final String plateNumber;
  final int capacity;
  final String driverName;
  final String routeId;
  final bool isActive;

  const TransportVehicle({
    required this.id,
    required this.schoolId,
    required this.busNumber,
    this.plateNumber = '',
    this.capacity = 0,
    this.driverName = '',
    this.routeId = '',
    this.isActive = true,
  });

  TransportVehicle copyWith({
    String? id,
    String? schoolId,
    String? busNumber,
    String? plateNumber,
    int? capacity,
    String? driverName,
    String? routeId,
    bool? isActive,
  }) {
    return TransportVehicle(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      busNumber: busNumber ?? this.busNumber,
      plateNumber: plateNumber ?? this.plateNumber,
      capacity: capacity ?? this.capacity,
      driverName: driverName ?? this.driverName,
      routeId: routeId ?? this.routeId,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    busNumber,
    plateNumber,
    capacity,
    driverName,
    routeId,
    isActive,
  ];
}
