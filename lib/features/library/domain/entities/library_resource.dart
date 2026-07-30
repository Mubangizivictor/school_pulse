import 'package:equatable/equatable.dart';

enum ResourceType {
  book,
  referenceMaterial,
  pastPaper,
  magazine,
  newspaper,
  teachingGuide,
  teacherManual,
  digitalResource,
  map,
  scienceModel,
  learningKit,
  audioResource,
  videoResource,
  educationalEquipment
}

enum ResourceCondition { excellent, good, fair, poor, damaged, lost }

enum ResourceStatus { available, borrowed, reserved, underRepair, archived }

class LibraryResource extends Equatable {
  final String id;
  final String schoolId;
  final String libraryId; // For multiple branches
  final String barcode;
  final String qrCode;
  final String? isbn;
  final String title;
  final String author;
  final String? publisher;
  final String? edition;
  final String category;
  final String subject;
  final String shelf;
  final String rack;
  final int totalQuantity;
  final int availableCopies;
  final DateTime? purchaseDate;
  final double? purchaseCost;
  final String? supplier;
  final ResourceCondition condition;
  final ResourceType type;
  final ResourceStatus status;
  final String? coverImageUrl;
  final String? digitalAttachmentUrl;
  final Map<String, dynamic>? metadata;

  const LibraryResource({
    required this.id,
    required this.schoolId,
    required this.libraryId,
    required this.barcode,
    required this.qrCode,
    this.isbn,
    required this.title,
    required this.author,
    this.publisher,
    this.edition,
    required this.category,
    required this.subject,
    required this.shelf,
    required this.rack,
    required this.totalQuantity,
    required this.availableCopies,
    this.purchaseDate,
    this.purchaseCost,
    this.supplier,
    this.condition = ResourceCondition.good,
    this.type = ResourceType.book,
    this.status = ResourceStatus.available,
    this.coverImageUrl,
    this.digitalAttachmentUrl,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        schoolId,
        libraryId,
        barcode,
        qrCode,
        isbn,
        title,
        author,
        publisher,
        edition,
        category,
        subject,
        shelf,
        rack,
        totalQuantity,
        availableCopies,
        purchaseDate,
        purchaseCost,
        supplier,
        condition,
        type,
        status,
        coverImageUrl,
        digitalAttachmentUrl,
        metadata,
      ];
}
