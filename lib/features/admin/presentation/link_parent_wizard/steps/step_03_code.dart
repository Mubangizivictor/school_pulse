import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../link_parent_wizard_controller.dart';

/// Step 3 - "Create parent access code": the one-time reveal of the raw
/// code, with Copy / Share, a summary of the linked parent + learners, and
/// revoke / create-another actions.
class LinkParentStepCode extends StatefulWidget {
  const LinkParentStepCode({super.key});

  @override
  State<LinkParentStepCode> createState() => _LinkParentStepCodeState();
}

class _LinkParentStepCodeState extends State<LinkParentStepCode> {
  bool _revoked = false;
  bool _revoking = false;

  String _formatCode(String raw) {
    // Codes come back as "SPnnnnnn" (see `_validCode` on the parent-redeem
    // screen); display them grouped as SP-nnn-nnn to match the design.
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 6) return raw;
    return 'SP-${digits.substring(0, 3)}-${digits.substring(3)}';
  }

  Future<void> _copy(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Code copied to clipboard')));
  }

  Future<void> _share(String code, String parentName) async {
    await Share.share(
      'School Pulse parent access code for $parentName: $code\n\n'
      'This code is single use and expires in 7 days. Open the '
      'School Pulse app, choose "Connect to your school", and enter '
      'this code with the phone number given to the school.',
    );
  }

  Future<void> _revoke(LinkParentWizardController controller) async {
    setState(() => _revoking = true);
    final ok = await controller.revoke();
    if (!mounted) return;
    setState(() {
      _revoking = false;
      if (ok) _revoked = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Access code revoked' : 'Could not revoke the access code',
        ),
        backgroundColor: ok
            ? AppColors.success(context)
            : AppColors.danger(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LinkParentWizardController>();
    final code = controller.resultCode ?? '';
    final formatted = _formatCode(code);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Create parent access code'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parent summary',
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.textPrimary(context),
                          child: Icon(
                            Icons.person_outline,
                            size: 18,
                            color: AppColors.background(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            controller.parentName,
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Linked learners (${controller.selectedLearners.length})',
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.selectedLearners
                          .map(
                            (learner) => Chip(
                              label: Text(
                                '${learner.student.name} · ${learner.relationship}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  children: [
                    Icon(
                      _revoked ? Icons.block : Icons.verified_user_outlined,
                      size: 40,
                      color: _revoked
                          ? AppColors.danger(context)
                          : AppColors.textPrimary(context),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _revoked
                          ? 'This access code has been revoked'
                          : 'Your parent access code',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatted,
                      style: TextStyle(
                        color: _revoked
                            ? AppColors.textMuted(context)
                            : AppColors.textPrimary(context),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        decoration: _revoked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_revoked)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _copy(formatted),
                              icon: const Icon(Icons.copy_outlined, size: 18),
                              label: const Text('Copy'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _share(formatted, controller.parentName),
                              icon: const Icon(
                                Icons.ios_share_outlined,
                                size: 18,
                              ),
                              label: const Text('Share / Print'),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: AppColors.textMuted(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Single use · expires in 7 days · not a password.',
                          style: TextStyle(
                            color: AppColors.textMuted(context),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textMuted(context),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Give this code to the parent. They will verify '
                        'their phone number and set their own PIN.',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (!_revoked)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _revoking ? null : () => _revoke(controller),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger(context),
                      side: BorderSide(color: AppColors.danger(context)),
                    ),
                    child: _revoking
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Revoke this code'),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Create another code',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Done',
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
