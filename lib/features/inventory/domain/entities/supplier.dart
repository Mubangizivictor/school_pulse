import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String category;
  final String contactPerson;
  final String email;
  final String phone;
  final String? address;
  final double rating;
  final DateTime createdAt;

  const Supplier({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.category,
    required this.contactPerson,
    required this.email,
    required this.phone,
    this.address,
    this.rating = 0.0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, schoolId, name, category, contactPerson, email, phone, address, rating, createdAt];
}
