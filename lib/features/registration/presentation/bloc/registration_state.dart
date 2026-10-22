import 'dart:io';

import 'package:equatable/equatable.dart';

enum RegWizardStep {
  welcome,
  schoolDetails,
  adminAccount,
  calendar,
  studentCount,
  address,
  review,
}

enum AdminAccountPhase {
  form,
  creating,
  verificationSent,
  waitingVerification,
  checking,
  verified,
  expired,
  failed,
}

enum SubmitPhase { idle, submitting, submitted, failed }

enum ApplicationStatus {
  unknown,
  pendingReview,
  approved,
  rejected,
}

enum PaymentPhase {
  idle,
  loadingContext,
  contextLoaded,
  uploadingProof,
  submitting,
  submitted,
  approved,
  rejected,
  failed,
}

class RegistrationState extends Equatable {
  // Wizard navigation
  final RegWizardStep step;

  // Step 1: School details
  final String schoolName;
  final String schoolType;
  final String contactPhone;
  final String contactEmail;
  final String prefix;

  // Step 2: Administrator
  final String adminFullName;
  final String adminRole;
  final String adminEmail;
  final String adminPhone;
  final AdminAccountPhase adminPhase;
  final String? adminError;
  final int resendCooldownSeconds;

  // Step 3: Calendar
  final String schoolYear;
  final String term;
  final DateTime? termStart;
  final DateTime? termEnd;

  // Step 4: Students & pricing
  final int studentCount;

  // Step 5: Address & subdomain
  final String region;
  final String district;
  final String address;
  final String subdomain;
  final bool checkingSlug;
  final bool? slugAvailable;
  final String? slugMessage;

  // Step 6: Review & submit
  final bool termsAccepted;
  final SubmitPhase submitPhase;
  final String? submitError;
  final String? applicationId;

  // Post-submit status polling
  final ApplicationStatus applicationStatus;
  final bool statusLoading;
  final String? statusError;
  final String? rejectionReason;
  final bool appReady;

  // Payment
  final PaymentPhase paymentPhase;
  final Map<String, dynamic>? paymentContext;
  final File? proofFile;
  final String paymentMethod;
  final String payerName;
  final String paymentReference;
  final DateTime? paymentDate;
  final String paymentNote;
  final String? paymentError;
  final String paymentStatus;
  final String? paymentRejectionReason;

  final bool offline;

  const RegistrationState({
    this.step = RegWizardStep.welcome,
    this.schoolName = '',
    this.schoolType = 'Government Aided',
    this.contactPhone = '',
    this.contactEmail = '',
    this.prefix = '',
    this.adminFullName = '',
    this.adminRole = 'Head Teacher',
    this.adminEmail = '',
    this.adminPhone = '',
    this.adminPhase = AdminAccountPhase.form,
    this.adminError,
    this.resendCooldownSeconds = 0,
    this.schoolYear = '2026',
    this.term = 'Term 1',
    this.termStart,
    this.termEnd,
    this.studentCount = 0,
    this.region = '',
    this.district = '',
    this.address = '',
    this.subdomain = '',
    this.checkingSlug = false,
    this.slugAvailable,
    this.slugMessage,
    this.termsAccepted = false,
    this.submitPhase = SubmitPhase.idle,
    this.submitError,
    this.applicationId,
    this.applicationStatus = ApplicationStatus.unknown,
    this.statusLoading = false,
    this.statusError,
    this.rejectionReason,
    this.appReady = false,
    this.paymentPhase = PaymentPhase.idle,
    this.paymentContext,
    this.proofFile,
    this.paymentMethod = 'mtn',
    this.payerName = '',
    this.paymentReference = '',
    this.paymentDate,
    this.paymentNote = '',
    this.paymentError,
    this.paymentStatus = '',
    this.paymentRejectionReason,
    this.offline = false,
  });

  RegistrationState copyWith({
    RegWizardStep? step,
    String? schoolName,
    String? schoolType,
    String? contactPhone,
    String? contactEmail,
    String? prefix,
    String? adminFullName,
    String? adminRole,
    String? adminEmail,
    String? adminPhone,
    AdminAccountPhase? adminPhase,
    String? adminError,
    bool clearAdminError = false,
    int? resendCooldownSeconds,
    String? schoolYear,
    String? term,
    DateTime? termStart,
    DateTime? termEnd,
    int? studentCount,
    String? region,
    String? district,
    String? address,
    String? subdomain,
    bool? checkingSlug,
    bool? slugAvailable,
    String? slugMessage,
    bool? termsAccepted,
    SubmitPhase? submitPhase,
    String? submitError,
    bool clearSubmitError = false,
    String? applicationId,
    ApplicationStatus? applicationStatus,
    bool? statusLoading,
    String? statusError,
    String? rejectionReason,
    bool? appReady,
    PaymentPhase? paymentPhase,
    Map<String, dynamic>? paymentContext,
    File? proofFile,
    bool clearProofFile = false,
    String? paymentMethod,
    String? payerName,
    String? paymentReference,
    DateTime? paymentDate,
    String? paymentNote,
    String? paymentError,
    bool clearPaymentError = false,
    String? paymentStatus,
    String? paymentRejectionReason,
    bool? offline,
  }) {
    return RegistrationState(
      step: step ?? this.step,
      schoolName: schoolName ?? this.schoolName,
      schoolType: schoolType ?? this.schoolType,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      prefix: prefix ?? this.prefix,
      adminFullName: adminFullName ?? this.adminFullName,
      adminRole: adminRole ?? this.adminRole,
      adminEmail: adminEmail ?? this.adminEmail,
      adminPhone: adminPhone ?? this.adminPhone,
      adminPhase: adminPhase ?? this.adminPhase,
      adminError: clearAdminError ? null : (adminError ?? this.adminError),
      resendCooldownSeconds: resendCooldownSeconds ?? this.resendCooldownSeconds,
      schoolYear: schoolYear ?? this.schoolYear,
      term: term ?? this.term,
      termStart: termStart ?? this.termStart,
      termEnd: termEnd ?? this.termEnd,
      studentCount: studentCount ?? this.studentCount,
      region: region ?? this.region,
      district: district ?? this.district,
      address: address ?? this.address,
      subdomain: subdomain ?? this.subdomain,
      checkingSlug: checkingSlug ?? this.checkingSlug,
      slugAvailable: slugAvailable ?? this.slugAvailable,
      slugMessage: slugMessage ?? this.slugMessage,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      submitPhase: submitPhase ?? this.submitPhase,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      applicationId: applicationId ?? this.applicationId,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      statusLoading: statusLoading ?? this.statusLoading,
      statusError: statusError ?? this.statusError,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      appReady: appReady ?? this.appReady,
      paymentPhase: paymentPhase ?? this.paymentPhase,
      paymentContext: paymentContext ?? this.paymentContext,
      proofFile: clearProofFile ? null : (proofFile ?? this.proofFile),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      payerName: payerName ?? this.payerName,
      paymentReference: paymentReference ?? this.paymentReference,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentNote: paymentNote ?? this.paymentNote,
      paymentError: clearPaymentError ? null : (paymentError ?? this.paymentError),
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentRejectionReason: paymentRejectionReason ?? this.paymentRejectionReason,
      offline: offline ?? this.offline,
    );
  }

  @override
  List<Object?> get props => [
        step,
        schoolName,
        schoolType,
        contactPhone,
        contactEmail,
        prefix,
        adminFullName,
        adminRole,
        adminEmail,
        adminPhone,
        adminPhase,
        adminError,
        resendCooldownSeconds,
        schoolYear,
        term,
        termStart,
        termEnd,
        studentCount,
        region,
        district,
        address,
        subdomain,
        checkingSlug,
        slugAvailable,
        slugMessage,
        termsAccepted,
        submitPhase,
        submitError,
        applicationId,
        applicationStatus,
        statusLoading,
        statusError,
        rejectionReason,
        appReady,
        paymentPhase,
        paymentContext,
        proofFile,
        paymentMethod,
        payerName,
        paymentReference,
        paymentDate,
        paymentNote,
        paymentError,
        paymentStatus,
        paymentRejectionReason,
        offline,
      ];
}
