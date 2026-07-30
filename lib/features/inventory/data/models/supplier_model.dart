import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/supplier.dart';

class SupplierModel extends Supplier {
  const SupplierModel({
    required super.id,
    required super.schoolId,
    required super.name,
    required super.category,
    required super.contactPerson,
    required super.email,
    required super.phone,
    super.address,
    super.rating,
    required super.createdAt,
  });

  factory SupplierModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupplierModel(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      contactPerson: data['contactPerson'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'],
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'name': name,
      'category': category,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SupplierModel.fromEntity(Supplier supplier) {
    return SupplierModel(
      id: supplier.id,
      schoolId: supplier.schoolId,
      name: supplier.name,
      category: supplier.category,
      contactPerson: supplier.contactPerson,
      email: supplier.email,
      phone: supplier.phone,
      address: supplier.address,
      rating: supplier.rating,
      createdAt: supplier.createdAt,
    );
  }
}
