import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:school_pulse/core/constants/support_contact.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/profile/presentation/screens/terms_of_service_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/privacy_policy_screen.dart';

/// A standalone About route, deliberately without a bottom navigation bar.
class AboutSchoolPulseScreen extends StatefulWidget {
  const AboutSchoolPulseScreen({super.key});

  @override
  State<AboutSchoolPulseScreen> createState() => _AboutSchoolPulseScreenState();
}

class _AboutSchoolPulseScreenState extends State<AboutSchoolPulseScreen> {
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

  Future<void> _openUri(Uri uri, {LaunchMode? mode}) async {
    final opened = await launchUrl(
      uri,
      mode: mode ?? LaunchMode.platformDefault,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this link right now.')),
      );
    }
  }

  Future<void> _checkForUpdates() async {
    final packageName = _packageInfo?.packageName;
    if (packageName == null || packageName.isEmpty || kIsWeb) {
      return _openUri(
        Uri.parse(SupportContact.websiteUrl),
        mode: LaunchMode.externalApplication,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final storeUri = Uri.parse('market://details?id=$packageName');
      if (await launchUrl(storeUri, mode: LaunchMode.externalApplication)) {
        return;
      }
      return _openUri(
        Uri.parse('https://play.google.com/store/apps/details?id=$packageName'),
        mode: LaunchMode.externalApplication,
      );
    }
    // The official product site owns the iOS download link. This avoids
    // inventing an App Store identifier and remains valid on desktop builds.
    return _openUri(
      Uri.parse(SupportContact.websiteUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  void _openPrivacyPolicy() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen()));

  void _openTerms() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const TermsOfServiceScreen()));

  void _openLicences() => showLicensePage(
    context: context,
    applicationName: _packageInfo?.appName ?? 'School Pulse',
    applicationVersion: _packageInfo == null
        ? null
        : '${_packageInfo!.version} (${_packageInfo!.buildNumber})',
    applicationIcon: Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Image.asset('assets/logos/icon_dark_mode.png', width: 48),
    ),
  );

  Future<void> _emailSupport() => _openUri(
    Uri(
      scheme: 'mailto',
      path: SupportContact.supportEmail,
      queryParameters: const {'subject': 'School Pulse support'},
    ),
  );

  Future<void> _shareOnFacebook() => _openUri(
    Uri.https('www.facebook.com', '/sharer/sharer.php', {
      'u': SupportContact.websiteUrl,
    }),
    mode: LaunchMode.externalApplication,
  );

  Future<void> _shareOnX() => _openUri(
    Uri.https('twitter.com', '/intent/tweet', {
      'text': 'School Pulse — Educate • Empower • Excel',
      'url': SupportContact.websiteUrl,
    }),
    mode: LaunchMode.externalApplication,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primary(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final logoAsset = isDark
        ? 'assets/logos/logo_for_dark_mode.png'
        : 'assets/logos/logo_for_light_mode.png';

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/staff/more');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('About School Pulse'),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 700 ? 48.0 : 20.0;
            final contentWidth = constraints.maxWidth >= 700
                ? 620.0
                : double.infinity;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    30,
                    horizontalPadding,
                    36,
                  ),
                  children: [
                    _BrandHero(
                      logoAsset: logoAsset,
                      iconAsset: isDark
                          ? 'assets/logos/icon_dark_mode.png'
                          : 'assets/logos/icon_light_Mode.png',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'School Pulse is an all-in-one school management solution that empowers schools to manage academic, administrative and communication processes efficiently.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _VersionCard(
                      info: _packageInfo,
                      primary: primary,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      cardColor: AppColors.surfaceElevated(context),
                      onCheckForUpdates: _checkForUpdates,
                    ),
                    const SizedBox(height: 16),
                    _ActionCard(
                      cardColor: AppColors.surfaceElevated(context),
                      borderColor: AppColors.border(context),
                      items: [
                        _AboutAction(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'Read our privacy policy',
                          onTap: _openPrivacyPolicy,
                        ),
                        _AboutAction(
                          icon: Icons.article_outlined,
                          title: 'Terms of Service',
                          subtitle: 'Read our terms and conditions',
                          onTap: _openTerms,
                        ),
                        _AboutAction(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Licences',
                          subtitle: 'Open source licences and attributions',
                          onTap: _openLicences,
                        ),
                        _AboutAction(
                          icon: Icons.headset_mic_outlined,
                          title: 'Support',
                          subtitle: 'Get help and contact support',
                          onTap: _emailSupport,
                        ),
                        _AboutAction(
                          icon: Icons.groups_2_outlined,
                          title: 'About Us',
                          subtitle: 'Learn more about VictorBee Technologies',
                          onTap: () => _openUri(
                            Uri.parse('https://victorbee.com/'),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: textSecondary, fontSize: 16),
                        children: [
                          const TextSpan(text: 'Made with '),
                          TextSpan(
                            text: '♥',
                            style: TextStyle(color: primary),
                          ),
                          const TextSpan(text: ' by '),
                          TextSpan(
                            text: 'VictorBee Technologies',
                            style: TextStyle(color: primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '© ${DateTime.now().year} All rights reserved.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        _SocialButton(
                          icon: Icons.language_rounded,
                          onPressed: () => _openUri(
                            Uri.parse(SupportContact.websiteUrl),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        _SocialButton(
                          icon: Icons.facebook_rounded,
                          onPressed: _shareOnFacebook,
                        ),
                        _SocialButton(
                          icon: Icons.alternate_email_rounded,
                          onPressed: _shareOnX,
                        ),
                        _SocialButton(
                          icon: Icons.mail_outline_rounded,
                          onPressed: _emailSupport,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The supplied brand artwork is a horizontal lockup.  The reference screen
/// uses its real mark above its wordmark, so this keeps both parts of that
/// same artwork while clipping only its wordmark area.
class _BrandHero extends StatelessWidget {
  const _BrandHero({required this.logoAsset, required this.iconAsset});

  final String logoAsset;
  final String iconAsset;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wordmarkWidth = constraints.maxWidth.clamp(0.0, 360.0).toDouble();
      final lockupWidth = wordmarkWidth / .65;
      return Semantics(
        image: true,
        label: 'School Pulse',
        child: Column(
          children: [
            SizedBox(
              width: wordmarkWidth,
              height: 170,
              child: Image.asset(iconAsset, fit: BoxFit.contain),
            ),
            SizedBox(
              width: wordmarkWidth,
              height: wordmarkWidth * .23,
              child: ClipRect(
                child: Transform.translate(
                  offset: Offset(-lockupWidth * .34, -lockupWidth * .27),
                  child: Image.asset(logoAsset, width: lockupWidth),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _VersionCard extends StatelessWidget {
  const _VersionCard({
    required this.info,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardColor,
    required this.onCheckForUpdates,
  });

  final PackageInfo? info;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardColor;
  final VoidCallback onCheckForUpdates;

  @override
  Widget build(BuildContext context) {
    final version = info == null
        ? 'Loading version…'
        : '${info!.version} (${info!.buildNumber})';
    final build = info == null ? '' : 'Build ${info!.buildNumber}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context, cardColor),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;
          final details = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Version',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  version,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (build.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    build,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          );
          final updateButton = OutlinedButton.icon(
            onPressed: onCheckForUpdates,
            icon: const Icon(Icons.cloud_download_outlined, size: 21),
            label: const Text('Check for Updates'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 52),
              padding: const EdgeInsets.symmetric(horizontal: 15),
            ),
          );
          return compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _VersionIcon(color: primary),
                        const SizedBox(width: 16),
                        details,
                      ],
                    ),
                    const SizedBox(height: 16),
                    updateButton,
                  ],
                )
              : Row(
                  children: [
                    _VersionIcon(color: primary),
                    const SizedBox(width: 16),
                    details,
                    const SizedBox(width: 12),
                    updateButton,
                  ],
                );
        },
      ),
    );
  }
}

class _VersionIcon extends StatelessWidget {
  const _VersionIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 70,
    height: 70,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Icon(Icons.verified_user_outlined, color: color, size: 36),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.cardColor,
    required this.borderColor,
    required this.items,
  });

  final Color cardColor;
  final Color borderColor;
  final List<_AboutAction> items;

  @override
  Widget build(BuildContext context) => Container(
    decoration: _cardDecoration(context, cardColor),
    child: Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _ActionRow(action: items[index]),
          if (index != items.length - 1)
            Divider(height: 1, indent: 84, endIndent: 16, color: borderColor),
        ],
      ],
    ),
  );
}

class _AboutAction {
  const _AboutAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.action});
  final _AboutAction action;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    return Semantics(
      button: true,
      label: action.title,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(action.icon, color: primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary(context),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary(context),
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: IconButton(
      tooltip: 'Open link',
      onPressed: onPressed,
      icon: Icon(icon),
      color: AppColors.primary(context),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.primary(context),
        minimumSize: const Size(52, 52),
      ),
    ),
  );
}

BoxDecoration _cardDecoration(BuildContext context, Color color) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: AppColors.border(context)),
    );
