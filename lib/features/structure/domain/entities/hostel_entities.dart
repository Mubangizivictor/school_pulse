import 'package:equatable/equatable.dart';

/// A boarding hostel's structural definition (name, gender, warden,
/// capacity). Day-to-day occupancy/attendance stays with Matron/Patron's
/// existing operational Dormitory entities - this is master data only.
class Hostel extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String gender;
  final String wardenName;
  final String wardenContact;
  final String? wardenStaffId;
  final int capacity;
  final String description;
  final bool isActive;

  const Hostel({
    required this.id,
    required this.schoolId,
    required this.name,
    this.gender = '',
    this.wardenName = '',
    this.wardenContact = '',
    this.wardenStaffId,
    this.capacity = 0,
    this.description = '',
    this.isActive = true,
  });

  Hostel copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? gender,
    String? wardenName,
    String? wardenContact,
    String? wardenStaffId,
    int? capacity,
    String? description,
    bool? isActive,
  }) {
    return Hostel(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      wardenName: wardenName ?? this.wardenName,
      wardenContact: wardenContact ?? this.wardenContact,
      wardenStaffId: wardenStaffId ?? this.wardenStaffId,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    gender,
    wardenName,
    wardenContact,
    wardenStaffId,
    capacity,
    description,
    isActive,
  ];
}

/// A room within a hostel (optionally grouped by block), with a bed
/// capacity. Individual bed assignment remains operational data elsewhere.
class HostelRoom extends Equatable {
  final String id;
  final String schoolId;
  final String hostelId;
  final String blockName;
  final String roomNumber;
  final int bedCapacity;
  final bool isActive;

  const HostelRoom({
    required this.id,
    required this.schoolId,
    required this.hostelId,
    this.blockName = '',
    required this.roomNumber,
    this.bedCapacity = 0,
    this.isActive = true,
  });

  HostelRoom copyWith({
    String? id,
    String? schoolId,
    String? hostelId,
    String? blockName,
    String? roomNumber,
    int? bedCapacity,
    bool? isActive,
  }) {
    return HostelRoom(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      hostelId: hostelId ?? this.hostelId,
      blockName: blockName ?? this.blockName,
      roomNumber: roomNumber ?? this.roomNumber,
      bedCapacity: bedCapacity ?? this.bedCapacity,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    hostelId,
    blockName,
    roomNumber,
    bedCapacity,
    isActive,
  ];
}
