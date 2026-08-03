import 'package:equatable/equatable.dart';

/// A physical site an institution operates from (main campus, a branch,
/// a satellite study centre, ...). Fully optional - a single-site
/// institution has zero Campus records and nothing else in Structure
/// depends on one existing.
class Campus extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String code;
  final String address;
  final String district;
  final String? contactPhone;
  final String? contactEmail;
  final String? headStaffId;
  final bool isPrimary;
  final bool isActive;
  final int order;
  final DateTime? archivedAt;

  const Campus({
    required this.id,
    required this.schoolId,
    required this.name,
    this.code = '',
    this.address = '',
    this.district = '',
    this.contactPhone,
    this.contactEmail,
    this.headStaffId,
    this.isPrimary = false,
    this.isActive = true,
    this.order = 0,
    this.archivedAt,
  });

  Campus copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? code,
    String? address,
    String? district,
    String? contactPhone,
    String? contactEmail,
    String? headStaffId,
    bool? isPrimary,
    bool? isActive,
    int? order,
    DateTime? archivedAt,
  }) {
    return Campus(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      district: district ?? this.district,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      headStaffId: headStaffId ?? this.headStaffId,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        schoolId,
        name,
        code,
        address,
        district,
        contactPhone,
        contactEmail,
        headStaffId,
        isPrimary,
        isActive,
        order,
        archivedAt,
      ];
}

/// A school house (Blue House, Red House, ...) used for inter-house
/// competitions/discipline grouping. Distinct from games' SportsHouse,
/// which is scoped to sports competitions specifically.
class House extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String colorHex;
  final String description;
  final bool isActive;

  const House({
    required this.id,
    required this.schoolId,
    required this.name,
    this.colorHex = '',
    this.description = '',
    this.isActive = true,
  });

  House copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? colorHex,
    String? description,
    bool? isActive,
  }) {
    return House(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, schoolId, name, colorHex, description, isActive];
}

/// A club or society (Debate, Robotics, Scripture Union, ...).
class Club extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String category;
  final String description;
  final String patronName;
  final bool isActive;

  const Club({
    required this.id,
    required this.schoolId,
    required this.name,
    this.category = '',
    this.description = '',
    this.patronName = '',
    this.isActive = true,
  });

  Club copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? category,
    String? description,
    String? patronName,
    bool? isActive,
  }) {
    return Club(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      patronName: patronName ?? this.patronName,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, schoolId, name, category, description, patronName, isActive];
}

/// A physical school facility (library, lab, dormitory, dining hall, ...).
class Facility extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String facilityType;
  final String location;
  final int capacity;
  final String description;
  final bool isActive;

  const Facility({
    required this.id,
    required this.schoolId,
    required this.name,
    this.facilityType = '',
    this.location = '',
    this.capacity = 0,
    this.description = '',
    this.isActive = true,
  });

  Facility copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? facilityType,
    String? location,
    int? capacity,
    String? description,
    bool? isActive,
  }) {
    return Facility(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      facilityType: facilityType ?? this.facilityType,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, schoolId, name, facilityType, location, capacity, description, isActive];
}
