import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

import '../../../../core/constants/support_contact.dart';

/// Placeholder Privacy Policy for the SaaS owner console.
///
/// This is a genuine, human-usable draft (not lorem ipsum) intended as a
/// starting point for School Pulse's operator to review and refine — it is
/// not a substitute for legal review before public/commercial use. No
/// externally-hosted Privacy Policy URL exists yet, so this local screen is
/// the source of truth referenced by [SupportContact.privacyPolicyUrl]
/// (currently null).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _lastUpdated = 'August 11, 2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.l,
        ),
        children: [
          Text(
            SupportContact.companyName,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Last updated: $_lastUpdated',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'This is a draft Privacy Policy provided as a starting point '
              'and is subject to change. It has not yet undergone formal '
              'legal review.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _Section(
            title: '1. Introduction',
            body:
                '${SupportContact.companyName} ("we", "our", "the platform") '
                'provides school management software used by schools, '
                'parents, and staff. This Privacy Policy explains what '
                'information we collect through the app, how we use it, and '
                'the choices you have.',
          ),
          _Section(
            title: '2. Information We Collect',
            body:
                'We collect and process the following categories of '
                'information:\n\n'
                '• School records: school profile, class/stream structure, '
                'timetables, and administrative settings.\n'
                '• Student records: names, enrollment and class data, '
                'attendance, academic performance, and guardian/parent '
                'contact details.\n'
                '• Staff records: names, roles, contact details, '
                'attendance, and work-related activity within the app.\n'
                '• Payment information: fee payment records and '
                'transaction references processed via MTN Mobile Money '
                '(MoMo), Airtel Money, or bank transfer details submitted '
                'for verification. We do not store full mobile money PINs '
                'or banking credentials — payments are processed by the '
                'respective mobile money/banking provider.\n'
                '• Notification tokens: device push-notification tokens '
                'used to deliver alerts (e.g. Firebase Cloud Messaging '
                'tokens).\n'
                '• Usage analytics: in-app activity such as feature usage, '
                'session activity, and diagnostic/crash information, used '
                'to improve reliability and performance.',
          ),
          _Section(
            title: '3. How We Use Information',
            body:
                'We use the information we collect to:\n\n'
                '• Operate core features such as attendance, gradebooks, '
                'fee tracking, and messaging between schools, staff, and '
                'parents.\n'
                '• Process and reconcile fee payments made via MTN MoMo, '
                'Airtel Money, or bank transfer.\n'
                '• Send push notifications and alerts relevant to your '
                'account, child, or school.\n'
                '• Maintain security, including detecting fraud, abuse, or '
                'unauthorized access.\n'
                '• Analyze usage to diagnose issues and improve the app.\n'
                '• Comply with legal, regulatory, or school-administrative '
                'obligations.',
          ),
          _Section(
            title: '4. Data Retention',
            body:
                'We retain school, student, staff, and payment records for '
                'as long as the associated school account remains active, '
                'and for a reasonable period afterward as required for '
                'academic record-keeping, financial reconciliation, or '
                'legal/regulatory obligations. Notification tokens and '
                'usage analytics are retained only as long as needed for '
                'the purposes described above and are periodically purged. '
                'Schools or account holders may request deletion of '
                'specific records, subject to legal and administrative '
                'record-keeping requirements.',
          ),
          _Section(
            title: '5. Third-Party Sharing',
            body:
                'We share data with the following categories of '
                'third parties, only as necessary to operate the '
                'platform:\n\n'
                '• Backend infrastructure: we use Firebase, Firestore, and '
                'Cloud Functions (Google) to store data, authenticate '
                'users, and run server-side logic. These providers process '
                'data on our behalf under their own security and privacy '
                'commitments.\n'
                '• Payment processors: MTN Mobile Money and Airtel Money '
                'process mobile money transactions; banks process bank '
                'transfers. We share only the information necessary to '
                'initiate and verify a payment.\n\n'
                'We do not sell personal information to third parties. We '
                'may disclose information if required by law or to protect '
                'the rights, safety, or property of the platform, schools, '
                'or users.',
          ),
          _Section(
            title: '6. Your Rights',
            body:
                'Depending on your role and applicable law, you may have '
                'the right to:\n\n'
                '• Access the personal information we hold about you or '
                'your child.\n'
                '• Request correction of inaccurate information.\n'
                '• Request deletion of your information, subject to legal '
                'and record-keeping obligations.\n'
                '• Withdraw consent for optional communications, such as '
                'non-essential notifications.\n\n'
                'To exercise any of these rights, contact us using the '
                'details below. Requests involving student records may '
                'need to be verified with the relevant school '
                'administrator.',
          ),
          _Section(
            title: '7. Data Security',
            body:
                'We apply reasonable technical and organizational measures '
                '— including authentication, access controls, and '
                'encrypted transport — to protect information against '
                'unauthorized access, alteration, or loss. No system is '
                'completely secure, and we encourage users to protect '
                'their account credentials.',
          ),
          _Section(
            title: '8. Children\'s Data',
            body:
                'Student records, including those of minors, are collected '
                'and managed on behalf of the enrolling school, which acts '
                'as the primary data controller for that student '
                'information. Parents/guardians can contact their school '
                'or us directly with questions about their child\'s data.',
          ),
          _Section(
            title: '9. Changes to This Policy',
            body:
                'We may update this Privacy Policy from time to time. '
                'Material changes will be reflected by updating the "Last '
                'updated" date above. Continued use of the app after '
                'changes take effect constitutes acceptance of the revised '
                'policy.',
          ),
          _Section(
            title: '10. Contact Us',
            body:
                'If you have questions about this Privacy Policy or how '
                'your information is handled, contact us at '
                '${SupportContact.supportEmail}.',
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            body,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
