import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/domain/owner_security_policy.dart';

/// Super Admin > Settings > Security > Recovery Codes.
///
/// Generation/regeneration calls the server-side `generateOwnerRecoveryCodes`
/// callable (public_functions/owner_recovery_codes.js), which creates 10
/// cryptographically random codes, persists only their SHA-256 hashes to a
/// collection the client can never read (`owner_recovery_codes/{ownerId}`,
/// `allow read, write: if false` in firestore.rules), and returns the raw
/// codes in the callable's response exactly once. This screen never
/// persists the raw codes anywhere client-side - no SharedPreferences, no
/// local cache - only the transient in-memory state of the reveal screen,
/// which is gone the moment the owner navigates away.
class RecoveryCodesScreen extends StatefulWidget {
  const RecoveryCodesScreen({super.key});

  @override
  State<RecoveryCodesScreen> createState() => _RecoveryCodesScreenState();
}

class _RecoveryCodesScreenState extends State<RecoveryCodesScreen> {
  bool _loadingStatus = true;
  bool _exists = false;
  int _remaining = 0;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _loadingStatus = true);
    try {
      final result = await FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('getOwnerRecoveryCodesStatus')
          .call<Map<String, dynamic>>();
      final data = result.data;
      if (mounted) {
        setState(() {
          _exists = data['exists'] as bool? ?? false;
          _remaining = (data['remaining'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Could not load recovery code status.');
      }
    } finally {
      if (mounted) setState(() => _loadingStatus = false);
    }
  }

  Future<void> _generate() async {
    final hasTotp =
        await FirebaseAuth.instance.currentUser?.multiFactor
            .getEnrolledFactors()
            .then((factors) => factors.isNotEmpty) ??
        false;
    if (!hasTotp) {
      setState(
        () => _error =
            'Set up Two-Step Verification first - recovery codes exist to '
            'recover access to that.',
      );
      return;
    }

    if (_exists) {
      final confirmed = await confirmActionDialog(
        context,
        title: 'Regenerate recovery codes?',
        message:
            'Your existing recovery codes will stop working immediately. '
            'Only the new codes shown next will be valid.',
        confirmLabel: 'Regenerate',
        isDestructive: true,
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final fresh = await OwnerSecurityPolicy.ensureFreshAuthentication(
        context,
        reason: 'Confirm it\'s you before generating recovery codes.',
      );
      if (!fresh) {
        setState(() => _error = 'Reauthentication is required.');
        return;
      }

      final result = await FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('generateOwnerRecoveryCodes')
          .call<Map<String, dynamic>>();
      final codes = (result.data['codes'] as List).cast<String>();

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _RecoveryCodesRevealScreen(codes: codes),
        ),
      );
      await _loadStatus();
    } on FirebaseFunctionsException catch (e) {
      setState(
        () => _error = e.code == 'resource-exhausted'
            ? 'Too many attempts. Try again later.'
            : (e.message ?? 'Could not generate recovery codes.'),
      );
    } catch (_) {
      setState(() => _error = 'Could not generate recovery codes.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Codes'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          if (_error != null) ...[
            AlertBanner(
              title: 'Could not complete that action',
              message: _error!,
              color: AppColors.danger(context),
              icon: Icons.error_outline,
            ),
            const SizedBox(height: AppSpacing.l),
          ],
          Text(
            'Recovery codes let you sign in if you lose access to your '
            'authenticator app. Each code works once. Store them somewhere '
            'safe - they are shown in full only at the moment you generate '
            'them.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            showShadow: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.key_rounded,
                      color: _exists
                          ? AppColors.success(context)
                          : AppColors.textMuted(context),
                    ),
                    const SizedBox(width: AppSpacing.l),
                    Expanded(
                      child: Text(
                        _loadingStatus
                            ? 'Checking status…'
                            : _exists
                            ? '$_remaining of 10 codes remaining'
                            : 'No recovery codes generated yet',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: _exists ? 'Regenerate Codes' : 'Generate Codes',
                    isLoading: _busy,
                    onPressed: _generate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown exactly once, immediately after generation/regeneration. Nothing
/// on this screen is persisted - closing it (there is no way back to it)
/// is the only "storage" this app ever offers for the raw codes; the owner
/// is expected to copy or download them here.
class _RecoveryCodesRevealScreen extends StatelessWidget {
  const _RecoveryCodesRevealScreen({required this.codes});
  final List<String> codes;

  void _copyAll(BuildContext context) {
    Clipboard.setData(ClipboardData(text: codes.join('\n')));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Recovery codes copied.')));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Your Recovery Codes')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            AlertBanner(
              title: 'Save these now',
              message:
                  'These codes will not be shown again. Store them somewhere '
                  'safe - each one can only be used once.',
              color: AppColors.warning(context),
              icon: Icons.warning_amber_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              showShadow: false,
              child: Column(
                children: [
                  for (final code in codes)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s,
                      ),
                      child: Text(
                        code,
                        style: AppTypography.titleMedium.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _copyAll(context),
                icon: const Icon(Icons.copy_all_rounded),
                label: const Text('Copy All'),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'I\'ve saved these codes',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
