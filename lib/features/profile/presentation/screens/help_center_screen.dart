import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:school_pulse/core/constants/support_contact.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

/// Help entry point for staff, with Class Teacher topics linked directly to
/// their existing, scoped workflows. There is deliberately no local article
/// content here: the app has no article CMS or help-content repository.
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _topics = <_HelpTopic>[
    _HelpTopic(
      icon: Icons.lightbulb_outline_rounded,
      title: 'Getting Started',
      route: '/staff/dashboard',
    ),
    _HelpTopic(
      icon: Icons.speed_outlined,
      title: 'Using Class Performance',
      route: null,
    ),
    _HelpTopic(
      icon: Icons.checklist_rtl_rounded,
      title: 'Taking Attendance',
      route: '/staff/roll-call',
    ),
    _HelpTopic(
      icon: Icons.edit_note_rounded,
      title: 'Entering Marks',
      route: '/staff/reports',
    ),
    _HelpTopic(
      icon: Icons.calendar_month_outlined,
      title: 'Creating Homework',
      route: '/staff/homework',
    ),
    _HelpTopic(
      icon: Icons.bar_chart_rounded,
      title: 'Generating Reports',
      route: '/staff/reports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        toolbarHeight: 66,
        backgroundColor: AppColors.background(context),
        surfaceTintColor: Colors.transparent,
        leadingWidth: 58,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 25),
          onPressed: () => _goBack(context),
        ),
        title: Text(
          'Help Center',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.45,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Keep the phone reference's 20px gutter; cap wide layouts so
            // cards remain readable and cannot overflow.
            final horizontalPadding = constraints.maxWidth >= 720
                ? (constraints.maxWidth - 640) / 2
                : 20.0;
            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                10,
                horizontalPadding,
                28,
              ),
              children: [
                const _HelpHero(),
                const SizedBox(height: 24),
                Text(
                  'Common Topics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'In-app help articles aren\'t available yet - mention a topic below '
                  'when you contact support and we\'ll help directly.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                    height: 1.42,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppRadius.large,
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Column(
                    children: [
                      for (var index = 0; index < _topics.length; index++)
                        _TopicRow(
                          topic: _topics[index],
                          isLast: index == _topics.length - 1,
                          onTap: () => _openTopic(context, _topics[index]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _ContactSupportCard(onTap: () => _contactSupport(context)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/staff/more');
    }
  }

  void _openTopic(BuildContext context, _HelpTopic topic) {
    if (topic.route != null) {
      context.go(topic.route!);
      return;
    }

    final classId = context
        .read<ClassTeacherContextBloc>()
        .state
        .active
        ?.classId;
    if (classId != null && classId.isNotEmpty) {
      context.go('/staff/classes/$classId/performance');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Class performance is available once a class is assigned.',
        ),
      ),
    );
  }

  Future<void> _contactSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: SupportContact.supportEmail,
      queryParameters: const {'subject': 'School Pulse Support'},
    );
    if (await canLaunchUrl(uri) && context.mounted) {
      await launchUrl(uri);
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email app is available on this device.'),
        ),
      );
    }
  }
}

class _HelpHero extends StatelessWidget {
  const _HelpHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 156),
      padding: const EdgeInsets.fromLTRB(36, 24, 20, 20),
      decoration: BoxDecoration(
        borderRadius: AppRadius.large,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Colors.black],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help you?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    height: 1.12,
                    letterSpacing: -0.55,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Browse help articles or contact our\nsupport team.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.42,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const _HeroIllustration(),
        ],
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 116,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.headset_mic_rounded, size: 112, color: Colors.white),
          Positioned(
            bottom: 7,
            child: Icon(Icons.forum_rounded, size: 48, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({
    required this.topic,
    required this.isLast,
    required this.onTap,
  });

  final _HelpTopic topic;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.large,
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        topic.icon,
                        color: AppColors.primary(context),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        topic.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.15,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary(context),
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
            if (!isLast)
              Divider(
                height: 1,
                indent: 76,
                endIndent: 18,
                color: AppColors.border(context),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactSupportCard extends StatelessWidget {
  const _ContactSupportCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.large,
        child: Ink(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: AppColors.primary(context),
            borderRadius: AppRadius.large,
            border: Border.all(color: AppColors.primary(context)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.headset_mic_outlined,
                color: AppColors.primary(context),
                size: 39,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Support',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chat with our support team or send us an email',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary(context),
                        fontSize: 12,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary(context),
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpTopic {
  const _HelpTopic({required this.icon, required this.title, this.route});

  final IconData icon;
  final String title;
  final String? route;
}
