import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus { pending, success, failed }

class PaymentTransaction {
  final String id;
  final String provider; // 'mtn' | 'airtel'
  final String phoneNumber;
  final int amountUgx;
  final PaymentStatus status;
  final String? reference;
  final String? failureReason;
  final DateTime createdAt;

  const PaymentTransaction({
    required this.id,
    required this.provider,
    required this.phoneNumber,
    required this.amountUgx,
    required this.status,
    required this.createdAt,
    this.reference,
    this.failureReason,
  });

  factory PaymentTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentTransaction(
      id: doc.id,
      provider: data['provider'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      amountUgx: (data['amountUgx'] ?? 0) as int,
      status: PaymentStatus.values.firstWhere(
        (s) => s.name == (data['status'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      reference: data['reference'],
      failureReason: data['failureReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
