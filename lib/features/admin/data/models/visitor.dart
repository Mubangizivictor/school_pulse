import 'package:cloud_firestore/cloud_firestore.dart';

class Visitor {
  final String id;
  final String name;
  final String purpose;
  final String contact;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String signedInBy; // Staff ID

  Visitor({
    required this.id,
    required this.name,
    required this.purpose,
    required this.contact,
    required this.checkIn,
    this.checkOut,
    required this.signedInBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'purpose': purpose,
      'contact': contact,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': checkOut != null ? Timestamp.fromDate(checkOut!) : null,
      'signedInBy': signedInBy,
    };
  }

  factory Visitor.fromMap(Map<String, dynamic> map, String id) {
    return Visitor(
      id: id,
      name: map['name'] ?? '',
      purpose: map['purpose'] ?? '',
      contact: map['contact'] ?? '',
      checkIn: (map['checkIn'] as Timestamp).toDate(),
      checkOut: (map['checkOut'] as Timestamp?)?.toDate(),
      signedInBy: map['signedInBy'] ?? '',
    );
  }
}
