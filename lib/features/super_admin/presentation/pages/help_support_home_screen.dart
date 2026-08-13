import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

import '../../data/support_faq_data.dart';
import 'submit_support_request_screen.dart';

/// SaaS Owner "Help & Support" home. Rows: Help Center, Contact Support,
/// Report a Problem, FAQs, Submit a Request.
///
/// Two rows from the reference spec are deliberately omitted here rather
/// than faked:
/// - "Video Guides": no real video guide content exists anywhere in this
///   codebase, and the spec says to only show this row if real guides
///   exist.
/// - "System Status": no status/health-check service, Cloud Function, or
///   remote config backs a platform-status signal anywhere in this
///   codebase, and the spec says to only show this if a real source
///   exists. Fabricating a green checkmark would be dishonest UI.
class HelpSupportHomeScreen extends StatelessWidget {
  const HelpSupportHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.l,
        ),
        children: [
          _SectionLabel(label: 'Get Help'),
          _SupportTile(
            icon: Icons.menu_book_outlined,
            title: 'Help Center',
            subtitle: 'Guides for managing the owner console',
            onTap: () =>
                context.push('/super-admin/settings/support/help-center'),
          ),
          _SupportTile(
            icon: Icons.headset_mic_outlined,
            title: 'Contact Support',
            subtitle: 'Reach the School Pulse support team',
            onTap: () => context.push('/super-admin/settings/about'),
          ),
          _SupportTile(
            icon: Icons.quiz_outlined,
            title: 'FAQs',
            subtitle:
                'Answers to common billing, schools and payments questions',
            onTap: () => context.push('/super-admin/settings/support/faqs'),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel(label: 'Get In Touch'),
          _SupportTile(
            icon: Icons.report_problem_outlined,
            title: 'Report a Problem',
            subtitle: 'Tell us about a bug or something that\'s not working',
            onTap: () => _openTicketForm(context, origin: 'report_problem'),
          ),
          _SupportTile(
            icon: Icons.add_circle_outline,
            title: 'Submit a Request',
            subtitle: 'Ask for a feature or platform change',
            onTap: () => _openTicketForm(context, origin: 'submit_request'),
          ),
        ],
      ),
    );
  }

  void _openTicketForm(BuildContext context, {required String origin}) {
    context.push(
      '/super-admin/settings/support/new',
      extra: SubmitSupportRequestArgs(origin: origin),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m, left: AppSpacing.s),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary(context),
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      color: AppColors.surfaceElevated(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border(context)),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

/// Local guide-topics content screen for "Help Center" - a maintained local
/// list rather than a link into the unrelated end-user
/// `help_center_screen.dart`, which targets a different audience (school
/// staff, not the SaaS owner).
class SupportHelpCenterScreen extends StatelessWidget {
  const SupportHelpCenterScreen({super.key});

  static const List<_GuideTopic> _topics = [
    _GuideTopic(
      icon: Icons.dashboard_outlined,
      title: 'Owner Console Overview',
      body:
          'The owner console is where you manage every school on the '
          'platform: applications, subscriptions, payments, notifications '
          'and platform-wide settings. Use the sidebar (or bottom '
          'navigation on mobile) to move between sections.',
    ),
    _GuideTopic(
      icon: Icons.school_outlined,
      title: 'Reviewing School Applications',
      body:
          'New school applications appear under School Management. Open '
          'an application to review its details, then approve or reject '
          'it. Approving provisions the school and its admin account.',
    ),
    _GuideTopic(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Configuring Manual Payment Methods',
      body:
          'Settings > Manual Payment Methods lets you set the MTN MoMo '
          'number and bank details schools are instructed to pay '
          'subscriptions into.',
    ),
    _GuideTopic(
      icon: Icons.receipt_long_outlined,
      title: 'Reviewing Submitted Payments',
      body:
          'Payment Review lists every manually submitted payment awaiting '
          'approval, with the proof of payment the school submitted. '
          'Approve or reject each one there.',
    ),
    _GuideTopic(
      icon: Icons.notifications_outlined,
      title: 'Platform Notifications',
      body:
          'The Notifications center streams real-time platform alerts - '
          'new applications, payment submissions, and system notices - as '
          'they happen.',
    ),
    _GuideTopic(
      icon: Icons.history_outlined,
      title: 'Audit Logs',
      body:
          'Audit Logs (Settings > Security) is an append-only record of '
          'platform activity and owner actions, useful for reviewing what '
          'changed and when.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Help Center')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: _topics.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.m),
        itemBuilder: (context, index) {
          final topic = _topics[index];
          return Card(
            elevation: 0,
            color: AppColors.surfaceElevated(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.border(context)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s),
                        decoration: BoxDecoration(
                          color: AppColors.primary(
                            context,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          topic.icon,
                          color: AppColors.primary(context),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Text(
                          topic.title,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    topic.body,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GuideTopic {
  final IconData icon;
  final String title;
  final String body;
  const _GuideTopic({
    required this.icon,
    required this.title,
    required this.body,
  });
}

/// FAQs screen - real backend-free expandable list rendered from the
/// maintained local const data source in `support_faq_data.dart`.
class SupportFaqsScreen extends StatelessWidget {
  const SupportFaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('FAQs')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: kSuperAdminSupportFaqs.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
        itemBuilder: (context, index) {
          final faq = kSuperAdminSupportFaqs[index];
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Card(
              elevation: 0,
              color: AppColors.surfaceElevated(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: AppColors.border(context)),
              ),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                title: Text(
                  faq.question,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    faq.topic,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  0,
                  AppSpacing.l,
                  AppSpacing.l,
                ),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faq.answer,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
