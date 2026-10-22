import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../link_parent_wizard_controller.dart';

/// Final step - "Invitation sent": a verified-invitation confirmation with
/// resend / revoke / create-another, plus a collapsible fallback one-time
/// code (copy / share). The raw code is shown once and never persisted
/// client-side; no password is ever involved.
class LinkParentStepSent extends StatefulWidget {
  const LinkParentStepSent({super.key});

  @override
  State<LinkParentStepSent> createState() => _LinkParentStepSentState();
}

class _LinkParentStepSentState extends State<LinkParentStepSent> {
  bool _revoked = false;
  bool _busy = false;
  bool _showCode = false;

  String _formatCode(String raw) {
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

  Future<void> _share(String code, String name) async {
    await Share.share(
      'School Pulse parent access code for $name: $code\n\n'
      'Single use, expires in 7 days. Open School Pulse, choose "Connect to '
      'your school", and enter this code with the phone number given to the '
      'school.',
    );
  }

  Future<void> _resend(LinkParentWizardController c) async {
    setState(() => _busy = true);
    final ok = await c.resendInvitation();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Invitation re-sent' : 'Could not resend'),
        backgroundColor: ok
            ? AppColors.success(context)
            : AppColors.danger(context),
      ),
    );
  }

  Future<void> _revoke(LinkParentWizardController c) async {
    setState(() => _busy = true);
    final ok = await c.revoke();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) _revoked = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Access revoked' : 'Could not revoke'),
        backgroundColor: ok
            ? AppColors.success(context)
            : AppColors.danger(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<LinkParentWizardController>();
    final code = c.resultCode ?? '';
    final delivered = c.resultInvitationDelivered;
    final target = c.email.isNotEmpty
        ? '${c.email[0]}***@${c.email.split('@').last}'
        : c.e164Phone;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Link parent to learners'),
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
                  children: [
                    Icon(
                      _revoked
                          ? Icons.block
                          : delivered
                          ? Icons.mark_email_read_outlined
                          : Icons.verified_user_outlined,
                      size: 40,
                      color: _revoked
                          ? AppColors.danger(context)
                          : AppColors.success(context),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _revoked
                          ? 'This parent access has been revoked'
                          : delivered
                          ? 'Invitation sent to $target'
                          : 'Parent record created',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _revoked
                          ? 'The parent can no longer use this invitation.'
                          : delivered
                          ? 'The parent verifies their phone/email and '
                                'sets their own PIN. No password is stored.'
                          : 'Share the one-time code below with the '
                                'parent. No password is stored.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 12.5,
                      ),
                    ),
                    if (!_revoked) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (delivered)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _busy ? null : () => _resend(c),
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Resend'),
                              ),
                            ),
                          if (delivered) const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _busy ? null : () => _revoke(c),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.danger(context),
                                side: BorderSide(
                                  color: AppColors.danger(context),
                                ),
                              ),
                              icon: const Icon(Icons.block, size: 16),
                              label: const Text('Revoke'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!_revoked && code.isNotEmpty)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _showCode = !_showCode),
                        child: Row(
                          children: [
                            Icon(
                              _showCode ? Icons.expand_less : Icons.expand_more,
                              size: 18,
                              color: AppColors.textMuted(context),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              delivered
                                  ? 'Show fallback one-time code'
                                  : 'One-time code',
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showCode || !delivered) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            _formatCode(code),
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _copy(_formatCode(code)),
                                icon: const Icon(Icons.copy_outlined, size: 16),
                                label: const Text('Copy'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _share(_formatCode(code), c.parentName),
                                icon: const Icon(
                                  Icons.ios_share_outlined,
                                  size: 16,
                                ),
                                label: const Text('Share'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Single use · expires in 7 days · not a password.',
                          style: TextStyle(
                            color: AppColors.textMuted(context),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Link another parent',
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Done',
                      onPressed: () => context.pop(true),
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
