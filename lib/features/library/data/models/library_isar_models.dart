import 'package:isar/isar.dart';
import '../../domain/entities/library_resource.dart';
import '../../domain/entities/library_borrowing.dart';

part 'library_isar_models.g.dart';

@collection
class LibraryResourceIsar {
  LibraryResourceIsar();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId;
  
  late String schoolId;
  late String libraryId;
  late String barcode;
  late String qrCode;
  String? isbn;
  late String title;
  late String author;
  String? publisher;
  String? edition;
  late String category;
  late String subject;
  late String shelf;
  late String rack;
  late int totalQuantity;
  late int availableCopies;
  DateTime? purchaseDate;
  double? purchaseCost;
  String? supplier;
  late String condition; // Enum name
  late String type; // Enum name
  late String status; // Enum name
  String? coverImageUrl;
  String? digitalAttachmentUrl;

  LibraryResource toEntity() {
    return LibraryResource(
      id: remoteId,
      schoolId: schoolId,
      libraryId: libraryId,
      barcode: barcode,
      qrCode: qrCode,
      isbn: isbn,
      title: title,
      author: author,
      publisher: publisher,
      edition: edition,
      category: category,
      subject: subject,
      shelf: shelf,
      rack: rack,
      totalQuantity: totalQuantity,
      availableCopies: availableCopies,
      purchaseDate: purchaseDate,
      purchaseCost: purchaseCost,
      supplier: supplier,
      condition: ResourceCondition.values.firstWhere((e) => e.name == condition),
      type: ResourceType.values.firstWhere((e) => e.name == type),
      status: ResourceStatus.values.firstWhere((e) => e.name == status),
      coverImageUrl: coverImageUrl,
      digitalAttachmentUrl: digitalAttachmentUrl,
    );
  }

  factory LibraryResourceIsar.fromEntity(LibraryResource resource) {
    return LibraryResourceIsar()
      ..remoteId = resource.id
      ..schoolId = resource.schoolId
      ..libraryId = resource.libraryId
      ..barcode = resource.barcode
      ..qrCode = resource.qrCode
      ..isbn = resource.isbn
      ..title = resource.title
      ..author = resource.author
      ..publisher = resource.publisher
      ..edition = resource.edition
      ..category = resource.category
      ..subject = resource.subject
      ..shelf = resource.shelf
      ..rack = resource.rack
      ..totalQuantity = resource.totalQuantity
      ..availableCopies = resource.availableCopies
      ..purchaseDate = resource.purchaseDate
      ..purchaseCost = resource.purchaseCost
      ..supplier = resource.supplier
      ..condition = resource.condition.name
      ..type = resource.type.name
      ..status = resource.status.name
      ..coverImageUrl = resource.coverImageUrl
      ..digitalAttachmentUrl = resource.digitalAttachmentUrl;
  }
}

@collection
class LibraryBorrowingIsar {
  LibraryBorrowingIsar();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId;

  late String schoolId;
  late String resourceId;
  late String resourceTitle;
  late String borrowerId;
  late String borrowerName;
  late String borrowerType;
  late DateTime borrowDate;
  late DateTime dueDate;
  DateTime? returnDate;
  late String status;
  late double fineAmount;
  late bool finePaid;
  late String issuedBy;
  String? receivedBy;

  LibraryBorrowing toEntity() {
    return LibraryBorrowing(
      id: remoteId,
      schoolId: schoolId,
      resourceId: resourceId,
      resourceTitle: resourceTitle,
      borrowerId: borrowerId,
      borrowerName: borrowerName,
      borrowerType: borrowerType,
      borrowDate: borrowDate,
      dueDate: dueDate,
      returnDate: returnDate,
      status: BorrowingStatus.values.firstWhere((e) => e.name == status),
      fineAmount: fineAmount,
      finePaid: finePaid,
      issuedBy: issuedBy,
      receivedBy: receivedBy,
    );
  }

  factory LibraryBorrowingIsar.fromEntity(LibraryBorrowing borrowing) {
    return LibraryBorrowingIsar()
      ..remoteId = borrowing.id
      ..schoolId = borrowing.schoolId
      ..resourceId = borrowing.resourceId
      ..resourceTitle = borrowing.resourceTitle
      ..borrowerId = borrowing.borrowerId
      ..borrowerName = borrowing.borrowerName
      ..borrowerType = borrowing.borrowerType
      ..borrowDate = borrowing.borrowDate
      ..dueDate = borrowing.dueDate
      ..returnDate = borrowing.returnDate
      ..status = borrowing.status.name
      ..fineAmount = borrowing.fineAmount
      ..finePaid = borrowing.finePaid
      ..issuedBy = borrowing.issuedBy
      ..receivedBy = borrowing.receivedBy;
  }
}

@collection
class LibraryReservationIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId;

  late String schoolId;
  late String resourceId;
  late String resourceTitle;
  late String borrowerId;
  late String borrowerName;
  late String borrowerType;
  late DateTime reservationDate;
  DateTime? expiryDate;
  late String status;
  late int queuePosition;
}
