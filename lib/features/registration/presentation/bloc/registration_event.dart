import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();
  @override
  List<Object?> get props => [];
}

class RegistrationStarted extends RegistrationEvent {
  const RegistrationStarted();
}

class RegistrationStepBack extends RegistrationEvent {
  const RegistrationStepBack();
}

class SchoolDetailsSubmitted extends RegistrationEvent {
  final String schoolName;
  final String schoolType;
  final String contactPhone;
  final String contactEmail;
  final String prefix;

  const SchoolDetailsSubmitted({
    required this.schoolName,
    required this.schoolType,
    required this.contactPhone,
    required this.contactEmail,
    required this.prefix,
  });

  @override
  List<Object?> get props => [schoolName, schoolType, contactPhone, contactEmail, prefix];
}

class AdminAccountCreateRequested extends RegistrationEvent {
  final String fullName;
  final String role;
  final String email;
  final String phone;
  final String password;

  const AdminAccountCreateRequested({
    required this.fullName,
    required this.role,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, role, email, phone, password];
}

class AdminVerificationResendRequested extends RegistrationEvent {
  const AdminVerificationResendRequested();
}

class AdminVerificationCheckRequested extends RegistrationEvent {
  const AdminVerificationCheckRequested();
}

class AdminAccountContinuePressed extends RegistrationEvent {
  const AdminAccountContinuePressed();
}

class CalendarSubmitted extends RegistrationEvent {
  final String schoolYear;
  final String term;
  final DateTime termStart;
  final DateTime termEnd;

  const CalendarSubmitted({
    required this.schoolYear,
    required this.term,
    required this.termStart,
    required this.termEnd,
  });

  @override
  List<Object?> get props => [schoolYear, term, termStart, termEnd];
}

class StudentCountSubmitted extends RegistrationEvent {
  final int studentCount;
  const StudentCountSubmitted(this.studentCount);
  @override
  List<Object?> get props => [studentCount];
}

class RegionSelected extends RegistrationEvent {
  final String region;
  const RegionSelected(this.region);
  @override
  List<Object?> get props => [region];
}

class DistrictSelected extends RegistrationEvent {
  final String district;
  const DistrictSelected(this.district);
  @override
  List<Object?> get props => [district];
}

class AddressChanged extends RegistrationEvent {
  final String address;
  const AddressChanged(this.address);
  @override
  List<Object?> get props => [address];
}

class SubdomainChanged extends RegistrationEvent {
  final String subdomain;
  const SubdomainChanged(this.subdomain);
  @override
  List<Object?> get props => [subdomain];
}

class AddressStepSubmitted extends RegistrationEvent {
  const AddressStepSubmitted();
}

class TermsToggled extends RegistrationEvent {
  final bool accepted;
  const TermsToggled(this.accepted);
  @override
  List<Object?> get props => [accepted];
}

class RegistrationSubmitPressed extends RegistrationEvent {
  const RegistrationSubmitPressed();
}

class ApplicationStatusCheckRequested extends RegistrationEvent {
  const ApplicationStatusCheckRequested();
}

class PaymentContextLoadRequested extends RegistrationEvent {
  const PaymentContextLoadRequested();
}

class PaymentProofSelected extends RegistrationEvent {
  final File file;
  const PaymentProofSelected(this.file);
  @override
  List<Object?> get props => [file];
}

class PaymentProofCleared extends RegistrationEvent {
  const PaymentProofCleared();
}

class ManualPaymentDetailsChanged extends RegistrationEvent {
  final String method;
  final String payerName;
  final String reference;
  final DateTime paymentDate;
  final String note;

  const ManualPaymentDetailsChanged({
    required this.method,
    required this.payerName,
    required this.reference,
    required this.paymentDate,
    required this.note,
  });

  @override
  List<Object?> get props => [method, payerName, reference, paymentDate, note];
}

class PaymentSubmitPressed extends RegistrationEvent {
  const PaymentSubmitPressed();
}

class PaymentStatusCheckRequested extends RegistrationEvent {
  const PaymentStatusCheckRequested();
}

class RetryRequested extends RegistrationEvent {
  const RetryRequested();
}
