import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

import '../../../../core/constants/support_contact.dart';
import 'privacy_policy_screen.dart';

/// Contact & About screen for the SaaS owner console.
///
/// Rows genuinely omitted (documented per spec rather than fabricated):
/// - Live Chat: no real chat implementation exists in this codebase.
/// - Terms of Service: no externally-hosted URL exists anywhere in the app.
///   A local static "Terms of Service" screen exists for staff
///   (`terms_of_service_screen.dart`, routed at
///   `/staff/more/terms-of-service`) but is not a real published URL
///   suitable for url_launcher and is a different audience (staff, not the
///   SaaS owner), so it is not reused here. Unlike Privacy Policy, no draft
///   was requested for this row, so it stays omitted rather than fabricated.
///
/// Privacy Policy has no externally-hosted URL either, but a local in-app
/// draft screen ([PrivacyPolicyScreen]) is shown instead, per an explicit
/// request for a placeholder to edit later.
class ContactAboutScreen extends StatefulWidget {
  const ContactAboutScreen({super.key});

  @override
  State<ContactAboutScreen> createState() => _ContactAboutScreenState();
}

class _ContactAboutScreenState extends State<ContactAboutScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _packageInfo = info);
  }

  Future<void> _emailSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: SupportContact.supportEmail,
      query:
          'subject=${Uri.encodeComponent('School Pulse Owner Console Support')}',
    );
    await launchUrl(uri);
  }

  Future<void> _callSupport(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/${SupportContact.whatsappNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWebsite() async {
    final uri = Uri.parse(SupportContact.websiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openPrivacyPolicy() {
    context.push('/super-admin/settings/about/privacy-policy');
  }

  String get _platformName {
    if (kIsWeb) return 'Web';
    // `defaultTargetPlatform` is a pure Flutter compile-time constant on
    // every platform including web, unlike `dart:io`'s `Platform`, whose
    // getters throw `UnsupportedError` there - safe to read unconditionally
    // even though this line only runs once `kIsWeb` is already false above.
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _packageInfo;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Contact & About')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.l,
        ),
        children: [
          _SectionLabel(label: 'Contact'),
          _InfoTile(
            icon: Icons.business_outlined,
            title: SupportContact.companyName,
            subtitle: 'Platform provider',
          ),
          _InfoTile(
            icon: Icons.email_outlined,
            title: SupportContact.supportEmail,
            subtitle: 'Support email',
            onTap: _emailSupport,
          ),
          _InfoTile(
            icon: Icons.call_outlined,
            title: SupportContact.supportPhone,
            subtitle: 'Support phone',
            onTap: () => _callSupport(SupportContact.supportPhoneInternational),
          ),
          _InfoTile(
            icon: Icons.chat_outlined,
            title: SupportContact.supportPhone,
            subtitle: 'WhatsApp',
            onTap: _openWhatsApp,
          ),
          _InfoTile(
            icon: Icons.public_outlined,
            title: SupportContact.websiteUrl,
            subtitle: 'Website',
            onTap: _openWebsite,
          ),
          _InfoTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: _openPrivacyPolicy,
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel(label: 'About'),
          _InfoTile(
            icon: Icons.info_outline,
            title: info == null
                ? 'Loading...'
                : '${info.version} (Build ${info.buildNumber})',
            subtitle: 'App version',
          ),
          _InfoTile(
            icon: Icons.phone_iphone_outlined,
            title: _platformName,
            subtitle: 'Platform',
          ),
          if (info != null)
            _InfoTile(
              icon: Icons.badge_outlined,
              title: info.packageName,
              subtitle: 'Application ID',
            ),
        ],
      ),
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

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
            color: color,
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
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right_rounded)
            : null,
      ),
    );
  }
}
