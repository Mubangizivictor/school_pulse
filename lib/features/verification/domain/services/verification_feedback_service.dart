/// Visual/haptic/audio feedback contract for a verification outcome. The
/// domain layer only declares what feedback means; the concrete
/// implementation (haptics, system sound, screen color) lives in the
/// presentation layer since it calls Flutter APIs directly - the same
/// split already used for `BiometricDeviceService`.
abstract class VerificationFeedbackService {
  Future<void> playApproved();
  Future<void> playDenied();
  Future<void> playDuplicate();
  Future<void> playError();
}
