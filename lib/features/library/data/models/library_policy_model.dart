import '../../domain/entities/library_policy.dart';

class LibraryPolicyModel extends LibraryPolicy {
  const LibraryPolicyModel({
    required super.id,
    required super.schoolId,
    required super.borrowerType,
    required super.maxBooks,
    required super.borrowDurationDays,
    required super.renewalLimit,
    required super.gracePeriodDays,
    required super.finePerDay,
    required super.lostBookChargeMultiplier,
    super.canReserve = true,
  });

  factory LibraryPolicyModel.fromFirestore(
    Map<String, dynamic> json,
    String id,
  ) {
    return LibraryPolicyModel(
      id: id,
      schoolId: json['schoolId'] ?? '',
      borrowerType: json['borrowerType'] ?? '',
      maxBooks: json['maxBooks'] ?? 0,
      borrowDurationDays: json['borrowDurationDays'] ?? 0,
      renewalLimit: json['renewalLimit'] ?? 0,
      gracePeriodDays: json['gracePeriodDays'] ?? 0,
      finePerDay: (json['finePerDay'] ?? 0).toDouble(),
      lostBookChargeMultiplier: (json['lostBookChargeMultiplier'] ?? 1.0)
          .toDouble(),
      canReserve: json['canReserve'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'borrowerType': borrowerType,
      'maxBooks': maxBooks,
      'borrowDurationDays': borrowDurationDays,
      'renewalLimit': renewalLimit,
      'gracePeriodDays': gracePeriodDays,
      'finePerDay': finePerDay,
      'lostBookChargeMultiplier': lostBookChargeMultiplier,
      'canReserve': canReserve,
    };
  }

  factory LibraryPolicyModel.fromEntity(LibraryPolicy entity) {
    return LibraryPolicyModel(
      id: entity.id,
      schoolId: entity.schoolId,
      borrowerType: entity.borrowerType,
      maxBooks: entity.maxBooks,
      borrowDurationDays: entity.borrowDurationDays,
      renewalLimit: entity.renewalLimit,
      gracePeriodDays: entity.gracePeriodDays,
      finePerDay: entity.finePerDay,
      lostBookChargeMultiplier: entity.lostBookChargeMultiplier,
      canReserve: entity.canReserve,
    );
  }

  LibraryPolicy toEntity() {
    return LibraryPolicy(
      id: id,
      schoolId: schoolId,
      borrowerType: borrowerType,
      maxBooks: maxBooks,
      borrowDurationDays: borrowDurationDays,
      renewalLimit: renewalLimit,
      gracePeriodDays: gracePeriodDays,
      finePerDay: finePerDay,
      lostBookChargeMultiplier: lostBookChargeMultiplier,
      canReserve: canReserve,
    );
  }
}
