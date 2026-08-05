import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/library_resource.dart';

class LibraryResourceModel extends LibraryResource {
  const LibraryResourceModel({
    required super.id,
    required super.schoolId,
    required super.libraryId,
    required super.barcode,
    required super.qrCode,
    super.isbn,
    required super.title,
    required super.author,
    super.publisher,
    super.edition,
    required super.category,
    required super.subject,
    required super.shelf,
    required super.rack,
    required super.totalQuantity,
    required super.availableCopies,
    super.purchaseDate,
    super.purchaseCost,
    super.supplier,
    super.condition,
    super.type,
    super.status,
    super.coverImageUrl,
    super.digitalAttachmentUrl,
    super.metadata,
  });

  factory LibraryResourceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LibraryResourceModel(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      libraryId: data['libraryId'] ?? '',
      barcode: data['barcode'] ?? '',
      qrCode: data['qrCode'] ?? '',
      isbn: data['isbn'],
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      publisher: data['publisher'],
      edition: data['edition'],
      category: data['category'] ?? '',
      subject: data['subject'] ?? '',
      shelf: data['shelf'] ?? '',
      rack: data['rack'] ?? '',
      totalQuantity: data['totalQuantity'] ?? 0,
      availableCopies: data['availableCopies'] ?? 0,
      purchaseDate: data['purchaseDate'] != null
          ? (data['purchaseDate'] as Timestamp).toDate()
          : null,
      purchaseCost: (data['purchaseCost'] as num?)?.toDouble(),
      supplier: data['supplier'],
      condition: ResourceCondition.values.firstWhere(
        (e) => e.name == data['condition'],
        orElse: () => ResourceCondition.good,
      ),
      type: ResourceType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ResourceType.book,
      ),
      status: ResourceStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ResourceStatus.available,
      ),
      coverImageUrl: data['coverImageUrl'],
      digitalAttachmentUrl: data['digitalAttachmentUrl'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'libraryId': libraryId,
      'barcode': barcode,
      'qrCode': qrCode,
      'isbn': isbn,
      'title': title,
      'author': author,
      'publisher': publisher,
      'edition': edition,
      'category': category,
      'subject': subject,
      'shelf': shelf,
      'rack': rack,
      'totalQuantity': totalQuantity,
      'availableCopies': availableCopies,
      'purchaseDate': purchaseDate != null
          ? Timestamp.fromDate(purchaseDate!)
          : null,
      'purchaseCost': purchaseCost,
      'supplier': supplier,
      'condition': condition.name,
      'type': type.name,
      'status': status.name,
      'coverImageUrl': coverImageUrl,
      'digitalAttachmentUrl': digitalAttachmentUrl,
      'metadata': metadata,
    };
  }
}
