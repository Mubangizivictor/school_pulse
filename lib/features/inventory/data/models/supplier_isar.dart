import 'package:isar/isar.dart';
import '../../domain/entities/supplier.dart';

part 'supplier_isar.g.dart';

@collection
class SupplierIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String supplierId;

  late String schoolId;
  late String name;
  late String category;
  late String contactPerson;
  late String email;
  late String phone;
  String? address;
  late double rating;
  late DateTime createdAt;

  SupplierIsar();

  factory SupplierIsar.fromEntity(Supplier entity) {
    return SupplierIsar()
      ..supplierId = entity.id
      ..schoolId = entity.schoolId
      ..name = entity.name
      ..category = entity.category
      ..contactPerson = entity.contactPerson
      ..email = entity.email
      ..phone = entity.phone
      ..address = entity.address
      ..rating = entity.rating
      ..createdAt = entity.createdAt;
  }

  Supplier toEntity() {
    return Supplier(
      id: supplierId,
      schoolId: schoolId,
      name: name,
      category: category,
      contactPerson: contactPerson,
      email: email,
      phone: phone,
      address: address,
      rating: rating,
      createdAt: createdAt,
    );
  }
}
