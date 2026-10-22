import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/registration_reference_data.dart';
import '../../data/registration_service.dart';
import 'registration_event.dart';
import 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final RegistrationService _service;
  Timer? _resendTimer;

  RegistrationBloc({RegistrationService? service})
    : _service = service ?? RegistrationService.instance,
      super(const RegistrationState()) {
    on<RegistrationStarted>((event, emit) {
      emit(state.copyWith(step: RegWizardStep.schoolDetails));
    });

    on<RegistrationStepBack>(_onStepBack);
    on<SchoolDetailsSubmitted>(_onSchoolDetailsSubmitted);
    on<AdminAccountCreateRequested>(_onAdminAccountCreateRequested);
    on<AdminVerificationResendRequested>(_onResendRequested);
    on<AdminVerificationCheckRequested>(_onVerificationCheckRequested);
    on<AdminAccountContinuePressed>((event, emit) {
      emit(state.copyWith(step: RegWizardStep.calendar));
    });
    on<CalendarSubmitted>((event, emit) {
      emit(
        state.copyWith(
          schoolYear: event.schoolYear,
          term: event.term,
          termStart: event.termStart,
          termEnd: event.termEnd,
          step: RegWizardStep.studentCount,
        ),
      );
    });
    on<StudentCountSubmitted>((event, emit) {
      emit(
        state.copyWith(
          studentCount: event.studentCount,
          step: RegWizardStep.address,
        ),
      );
    });
    on<RegionSelected>((event, emit) {
      emit(state.copyWith(region: event.region, district: ''));
    });
    on<DistrictSelected>((event, emit) {
      emit(state.copyWith(district: event.district));
    });
    on<AddressChanged>((event, emit) {
      emit(state.copyWith(address: event.address));
    });
    on<SubdomainChanged>(_onSubdomainChanged);
    on<AddressStepSubmitted>((event, emit) {
      emit(state.copyWith(step: RegWizardStep.review));
    });
    on<TermsToggled>((event, emit) {
      emit(state.copyWith(termsAccepted: event.accepted));
    });
    on<RegistrationSubmitPressed>(_onSubmitPressed);
    on<ApplicationStatusCheckRequested>(_onStatusCheckRequested);
    on<PaymentContextLoadRequested>(_onPaymentContextLoadRequested);
    on<PaymentProofSelected>((event, emit) {
      emit(state.copyWith(proofFile: event.file, clearPaymentError: true));
    });
    on<PaymentProofCleared>((event, emit) {
      emit(state.copyWith(clearProofFile: true));
    });
    on<ManualPaymentDetailsChanged>((event, emit) {
      emit(
        state.copyWith(
          paymentMethod: event.method,
          payerName: event.payerName,
          paymentReference: event.reference,
          paymentDate: event.paymentDate,
          paymentNote: event.note,
        ),
      );
    });
    on<PaymentSubmitPressed>(_onPaymentSubmitPressed);
    on<PaymentStatusCheckRequested>(_onPaymentContextLoadRequested);
    on<RetryRequested>((event, emit) {
      emit(
        state.copyWith(
          offline: false,
          clearSubmitError: true,
          clearPaymentError: true,
        ),
      );
    });
    on<_ResendCooldownTicked>((event, emit) {
      emit(state.copyWith(resendCooldownSeconds: event.remaining));
    });
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }

  void _onStepBack(
    RegistrationStepBack event,
    Emitter<RegistrationState> emit,
  ) {
    final order = [
      RegWizardStep.welcome,
      RegWizardStep.schoolDetails,
      RegWizardStep.adminAccount,
      RegWizardStep.calendar,
      RegWizardStep.studentCount,
      RegWizardStep.address,
      RegWizardStep.review,
    ];
    final idx = order.indexOf(state.step);
    if (idx > 0) emit(state.copyWith(step: order[idx - 1]));
  }

  void _onSchoolDetailsSubmitted(
    SchoolDetailsSubmitted event,
    Emitter<RegistrationState> emit,
  ) {
    emit(
      state.copyWith(
        schoolName: event.schoolName,
        schoolType: event.schoolType,
        contactPhone: event.contactPhone,
        contactEmail: event.contactEmail,
        prefix: event.prefix,
        step: RegWizardStep.adminAccount,
      ),
    );
  }

  Future<void> _onAdminAccountCreateRequested(
    AdminAccountCreateRequested event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(
      state.copyWith(
        adminFullName: event.fullName,
        adminRole: event.role,
        adminEmail: event.email,
        adminPhone: event.phone,
        adminPhase: AdminAccountPhase.creating,
        clearAdminError: true,
      ),
    );
    try {
      // A visitor returning to an in-progress registration already has a
      // verified session for this email — skip straight to verified,
      // matching register-submit.js's currentUser() check.
      final existing = _service.currentUser;
      if (existing != null &&
          existing.emailVerified &&
          existing.email?.toLowerCase() == event.email.toLowerCase()) {
        emit(state.copyWith(adminPhase: AdminAccountPhase.verified));
        return;
      }
      try {
        await _service.createAccount(
          email: event.email,
          password: event.password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          await _service.signIn(email: event.email, password: event.password);
        } else {
          rethrow;
        }
      }
      await _service.requestEmailVerification();
      emit(
        state.copyWith(
          adminPhase: AdminAccountPhase.verificationSent,
          resendCooldownSeconds: 60,
        ),
      );
      _startResendCooldown();
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          adminPhase: AdminAccountPhase.failed,
          adminError:
              e.message ?? 'Could not create the account. Please try again.',
        ),
      );
    } on RegistrationApiException catch (e) {
      emit(
        state.copyWith(
          adminPhase: AdminAccountPhase.failed,
          adminError: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          adminPhase: AdminAccountPhase.failed,
          adminError:
              'Something went wrong. Please check your connection and try again.',
        ),
      );
    }
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.resendCooldownSeconds - 1;
      if (remaining <= 0) timer.cancel();
      if (!isClosed) add(_ResendCooldownTicked(remaining < 0 ? 0 : remaining));
    });
  }

  Future<void> _onResendRequested(
    AdminVerificationResendRequested event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state.resendCooldownSeconds > 0) return;
    try {
      await _service.requestEmailVerification();
      emit(
        state.copyWith(
          adminPhase: AdminAccountPhase.verificationSent,
          resendCooldownSeconds: 60,
          clearAdminError: true,
        ),
      );
      _startResendCooldown();
    } on RegistrationApiException catch (e) {
      emit(state.copyWith(adminError: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          adminError: 'Could not resend the email. Please try again.',
        ),
      );
    }
  }

  Future<void> _onVerificationCheckRequested(
    AdminVerificationCheckRequested event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(
      state.copyWith(
        adminPhase: AdminAccountPhase.checking,
        clearAdminError: true,
      ),
    );
    try {
      final verified = await _service.reloadAndCheckVerified();
      if (verified) {
        emit(state.copyWith(adminPhase: AdminAccountPhase.verified));
      } else {
        emit(
          state.copyWith(
            adminPhase: AdminAccountPhase.waitingVerification,
            adminError:
                'Still not verified yet. Check your inbox (and spam folder), click the link, then try again.',
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          adminPhase: AdminAccountPhase.waitingVerification,
          adminError: 'Could not check verification status. Please try again.',
        ),
      );
    }
  }

  Future<void> _onSubdomainChanged(
    SubdomainChanged event,
    Emitter<RegistrationState> emit,
  ) async {
    final sanitized = event.subdomain.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9-]'),
      '',
    );
    emit(
      state.copyWith(
        subdomain: sanitized,
        slugAvailable: null,
        slugMessage: null,
      ),
    );
    if (sanitized.length < 3) return;
    emit(state.copyWith(checkingSlug: true));
    try {
      final result = await _service.checkSlugAvailability(sanitized);
      if (state.subdomain != sanitized) return;
      emit(
        state.copyWith(
          checkingSlug: false,
          slugAvailable: result.available,
          slugMessage: result.available
              ? 'Available'
              : (result.reason == 'invalid_or_reserved'
                    ? 'This web address is not allowed. Try another.'
                    : 'Already taken. Try another.'),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          checkingSlug: false,
          slugAvailable: null,
          slugMessage: 'Could not check availability right now.',
        ),
      );
    }
  }

  Future<void> _onSubmitPressed(
    RegistrationSubmitPressed event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state.submitPhase == SubmitPhase.submitting) return;
    final tier = tierForCount(state.studentCount);
    final plan = tier.plan;
    if (plan == null) {
      emit(
        state.copyWith(
          submitPhase: SubmitPhase.failed,
          submitError:
              'Your student count needs a custom plan. Please contact support to continue.',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        submitPhase: SubmitPhase.submitting,
        clearSubmitError: true,
      ),
    );
    final nameParts = state.adminFullName.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.isNotEmpty
        ? nameParts.first
        : state.adminFullName;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    try {
      final result = await _service.submitSchoolApplication({
        'school': {
          'name': state.schoolName,
          'shortName': state.prefix,
          'email': state.contactEmail,
          'phone': state.contactPhone,
          'prefix': state.prefix,
          'category': state.schoolType,
          'studentCapacity': state.studentCount,
          'slug': state.subdomain,
        },
        'location': {
          'region': state.region,
          'district': state.district,
          'address': state.address,
        },
        'administrator': {
          'firstName': firstName,
          'lastName': lastName,
          'phone': state.adminPhone,
          'email': state.adminEmail,
        },
        'academicCalendar': {
          'schoolYear': state.schoolYear,
          'term': state.term,
          'termStart': state.termStart?.toIso8601String(),
          'termEnd': state.termEnd?.toIso8601String(),
        },
        'plan': plan,
        'selectedModules': const [],
        'termsAccepted': state.termsAccepted,
        'marketingOptIn': false,
      });
      emit(
        state.copyWith(
          submitPhase: SubmitPhase.submitted,
          applicationId: result['applicationId'] as String?,
          applicationStatus: ApplicationStatus.pendingReview,
        ),
      );
    } on RegistrationApiException catch (e) {
      emit(
        state.copyWith(submitPhase: SubmitPhase.failed, submitError: e.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          submitPhase: SubmitPhase.failed,
          submitError:
              'Could not submit your registration. Please check your connection and try again.',
        ),
      );
    }
  }

  Future<void> _onStatusCheckRequested(
    ApplicationStatusCheckRequested event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(state.copyWith(statusLoading: true, statusError: null));
    try {
      final result = await _service.getSchoolApplicationStatus();
      final status = _mapStatus(result['status'] as String?);
      emit(
        state.copyWith(
          statusLoading: false,
          applicationStatus: status,
          rejectionReason: result['rejectionReason'] as String?,
          appReady: result['appReady'] == true,
        ),
      );
    } on RegistrationApiException catch (e) {
      emit(state.copyWith(statusLoading: false, statusError: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          statusLoading: false,
          statusError:
              'Could not check your registration status. Please try again.',
        ),
      );
    }
  }

  ApplicationStatus _mapStatus(String? raw) {
    switch (raw) {
      case 'approved':
        return ApplicationStatus.approved;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'pending_review':
        return ApplicationStatus.pendingReview;
      default:
        return ApplicationStatus.unknown;
    }
  }

  Future<void> _onPaymentContextLoadRequested(
    RegistrationEvent event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(
      state.copyWith(
        paymentPhase: PaymentPhase.loadingContext,
        clearPaymentError: true,
      ),
    );
    try {
      final result = await _service.getManualPaymentContext();
      emit(
        state.copyWith(
          paymentPhase: PaymentPhase.contextLoaded,
          paymentContext: result,
          paymentStatus: (result['paymentStatus'] as String?) ?? '',
          paymentRejectionReason: result['paymentRejectionReason'] as String?,
        ),
      );
    } on RegistrationApiException catch (e) {
      emit(
        state.copyWith(
          paymentPhase: PaymentPhase.failed,
          paymentError: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          paymentPhase: PaymentPhase.failed,
          paymentError:
              'Could not load payment instructions. Please try again.',
        ),
      );
    }
  }

  Future<void> _onPaymentSubmitPressed(
    PaymentSubmitPressed event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state.proofFile == null) {
      emit(
        state.copyWith(paymentError: 'Please upload proof of payment first.'),
      );
      return;
    }
    if (state.payerName.trim().isEmpty ||
        state.paymentReference.trim().length < 3) {
      emit(
        state.copyWith(
          paymentError:
              'Payer name and a transaction/receipt reference (min 3 characters) are required.',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        paymentPhase: PaymentPhase.uploadingProof,
        clearPaymentError: true,
      ),
    );
    try {
      final proofPath = await _service.uploadPaymentProof(
        state.proofFile!,
        state.proofFile!.path.split('/').last,
      );
      emit(state.copyWith(paymentPhase: PaymentPhase.submitting));
      final plan = state.paymentContext?['plan'] as Map<String, dynamic>?;
      final expectedAmount = plan?['expectedAmount'] as int? ?? 0;
      final result = await _service.submitManualPayment({
        'amount': expectedAmount,
        'method': state.paymentMethod,
        'payerName': state.payerName,
        'reference': state.paymentReference,
        'paymentDate': (state.paymentDate ?? DateTime.now()).toIso8601String(),
        'note': state.paymentNote,
        'proofStoragePath': proofPath,
        'submissionId':
            'sp_${DateTime.now().millisecondsSinceEpoch}_${state.paymentReference.hashCode.abs()}',
      });
      emit(
        state.copyWith(
          paymentPhase: PaymentPhase.submitted,
          paymentStatus:
              (result['status'] as String?) ?? 'awaiting_confirmation',
        ),
      );
    } on RegistrationApiException catch (e) {
      emit(
        state.copyWith(
          paymentPhase: PaymentPhase.failed,
          paymentError: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          paymentPhase: PaymentPhase.failed,
          paymentError:
              'Could not submit your payment proof. Please check your connection and try again.',
        ),
      );
    }
  }
}

/// Internal event carrying the resend-cooldown timer's tick into the BLoC's
/// event stream, so the countdown state is only ever changed through a
/// registered handler (never by emitting from inside a raw Timer callback).
class _ResendCooldownTicked extends RegistrationEvent {
  final int remaining;
  const _ResendCooldownTicked(this.remaining);
  @override
  List<Object?> get props => [remaining];
}
