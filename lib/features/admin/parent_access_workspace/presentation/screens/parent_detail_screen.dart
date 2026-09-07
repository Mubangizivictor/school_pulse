import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

/// Parent detail & access-management screen. Rendered inside the canonical
/// admin shell (desktop sidebar / mobile Parents tab) via
/// [AdminParentsSectionBody]. Full implementation lands in section F of the
/// Parents redesign (guardian identity + edit, learner links + primary
/// contact + safe unlink, invitation state + resend/revoke/expire, audit
/// history). This is the routable shell so navigation and tests can be wired
/// up first.
class ParentDetailScreen extends StatelessWidget {
  final String inviteId;

  const ParentDetailScreen({super.key, required this.inviteId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Parent details'),
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: Center(
        child: Text(
          'Parent detail for $inviteId',
          style: TextStyle(color: AppColors.textMuted(context)),
        ),
      ),
    );
  }
}
