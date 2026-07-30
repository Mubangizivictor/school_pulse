import 'package:flutter/services.dart';
import 'package:school_pulse/features/verification/domain/services/verification_feedback_service.dart';

/// Uses Flutter's built-in haptics/system sound APIs so Phase 1 doesn't
/// need a new audio-asset dependency. Distinct custom sound files (per
/// the end-state spec's "configurable sounds per outcome") are a
/// fast-follow once Phase 1's visual/haptic feedback is validated.
class HapticVerificationFeedbackService implements VerificationFeedbackService {
  @override
  Future<void> playApproved() async {
    await HapticFeedback.mediumImpact();
    await SystemSound.play(SystemSoundType.click);
  }

  @override
  Future<void> playDenied() async {
    await HapticFeedback.heavyImpact();
    await SystemSound.play(SystemSoundType.alert);
  }

  @override
  Future<void> playDuplicate() async {
    await HapticFeedback.vibrate();
    await SystemSound.play(SystemSoundType.click);
  }

  @override
  Future<void> playError() async {
    await HapticFeedback.heavyImpact();
    await SystemSound.play(SystemSoundType.alert);
  }
}
