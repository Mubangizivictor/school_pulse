import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/app_role_session_cubit.dart';
import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_event.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_state.dart';
import 'package:school_pulse/features/branding/presentation/widgets/school_badge.dart';

/// The one post-auth splash: resolves tenant branding and shows the
/// school's identity before handing off to the dashboard.
class SchoolSplashScreen extends StatefulWidget {
  const SchoolSplashScreen({super.key, required this.user});
  final UserEntity user;

  @override
  State<SchoolSplashScreen> createState() => _SchoolSplashScreenState();
}

class _SchoolSplashScreenState extends State<SchoolSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _routed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureBranding());
    // The branding fetch and this recognition moment overlap: this is a
    // maximum, not a stacked delay after branding has already been loaded.
    Timer(const Duration(seconds: 2), _routeToWorkspace);
  }

  void _ensureBranding() {
    if (widget.user.schoolId.isEmpty) return;
    final branding = context.read<BrandingBloc>().state;
    if (branding is BrandingLoaded &&
        branding.branding?.schoolId == widget.user.schoolId) {
      return;
    }
    context.read<BrandingBloc>().add(
      FetchBrandingForSchool(widget.user.schoolId),
    );
  }

  void _routeToWorkspace() {
    if (!mounted || _routed) return;
    _routed = true;
    final user = widget.user;
    if (user.roles.length > 1 && user.role != UserRole.parent) {
      // A previously-persisted active role (set by RoleSwitcherSheet, or
      // restored on a prior launch) skips the hub and returns the user
      // straight to where they left off. A first-ever session, or one
      // where the persisted role was since revoked, has nothing to
      // restore - AppRoleSessionCubit.seed (called from main.dart's
      // AuthAuthenticated listener) resolves that case to roles.first,
      // which is intentionally NOT good enough to skip the hub, since the
      // user never actually chose that role.
      final activeRole = context.read<AppRoleSessionCubit>().state;
      if (activeRole != null) {
        context.go(UserRoleRouting.dashboardPath(activeRole));
        return;
      }
      context.go('/staff/hub');
      return;
    }
    context.go(UserRoleRouting.dashboardPath(user.role));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandingBloc, BrandingState>(
      builder: (context, state) {
        final branding = state is BrandingLoaded ? state.branding : null;
        if (branding == null || branding.schoolId != widget.user.schoolId) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  if (state is BrandingError) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _ensureBranding,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry connection'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return _SchoolIdentity(branding: branding, animation: _controller);
      },
    );
  }
}

class _SchoolIdentity extends StatelessWidget {
  const _SchoolIdentity({required this.branding, required this.animation});
  final SchoolBranding branding;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [scheme.primaryContainer, scheme.surface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: ScaleTransition(
                  scale: Tween<double>(begin: .94, end: 1).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SchoolBadge(
                        badgeUrl: branding.badgeUrl ?? branding.logoUrl,
                        size: 120,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        branding.schoolName.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                      ),
                      if (branding.schoolMotto.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          branding.schoolMotto,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      const SizedBox(height: 36),
                      Text(
                        'Powered by School Pulse',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
