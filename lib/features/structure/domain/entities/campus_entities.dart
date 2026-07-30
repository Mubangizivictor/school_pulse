import 'package:equatable/equatable.dart';

/// A school house (Blue House, Red House, ...) used for inter-house
/// competitions/discipline grouping. Distinct from games' SportsHouse,
/// which is scoped to sports competitions specifically.
class House extends Equatable {
  final String id;
  final String name;
  final String colorHex;
  final String description;
  final bool isActive;

  const House({
    required this.id,
    required this.name,
    this.colorHex = '',
    this.description = '',
    this.isActive = true,
  });

  House copyWith({
    String? id,
    String? name,
    String? colorHex,
    String? description,
    bool? isActive,
  }) {
    return House(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, colorHex, description, isActive];
}

/// A club or society (Debate, Robotics, Scripture Union, ...).
class Club extends Equatable {
  final String id;
  final String name;
  final String category;
  final String description;
  final String patronName;
  final bool isActive;

  const Club({
    required this.id,
    required this.name,
    this.category = '',
    this.description = '',
    this.patronName = '',
    this.isActive = true,
  });

  Club copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? patronName,
    bool? isActive,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      patronName: patronName ?? this.patronName,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, category, description, patronName, isActive];
}

/// A physical school facility (library, lab, dormitory, dining hall, ...).
class Facility extends Equatable {
  final String id;
  final String name;
  final String facilityType;
  final String location;
  final int capacity;
  final String description;
  final bool isActive;

  const Facility({
    required this.id,
    required this.name,
    this.facilityType = '',
    this.location = '',
    this.capacity = 0,
    this.description = '',
    this.isActive = true,
  });

  Facility copyWith({
    String? id,
    String? name,
    String? facilityType,
    String? location,
    int? capacity,
    String? description,
    bool? isActive,
  }) {
    return Facility(
      id: id ?? this.id,
      name: name ?? this.name,
      facilityType: facilityType ?? this.facilityType,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, facilityType, location, capacity, description, isActive];
}
