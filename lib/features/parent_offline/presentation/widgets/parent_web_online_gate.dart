import 'dart:async';

import 'package:flutter/material.dart';

import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Parent Portal on Flutter web is online-only: no Isar, no IndexedDB, no
/// offline PIN, no cached sensitive parent/learner data. When the network
/// check fails, this replaces the entire Parent Portal subtree with a
/// full-screen "internet required" state rather than letting any web
/// screen fall back to stale/cached data.
///
/// Uses [NetworkInfo] (already environment-appropriate per-platform - see
/// core/network/network_info.dart) rather than a raw connectivity stream,
/// consistent with how the rest of the app treats connectivity as a
/// server-verified fact rather than a device radio state.
class ParentWebOnlineGate extends StatefulWidget {
  const ParentWebOnlineGate({required this.child, super.key});

  final Widget child;

  @override
  State<ParentWebOnlineGate> createState() => _ParentWebOnlineGateState();
}

class _ParentWebOnlineGateState extends State<ParentWebOnlineGate> {
  bool? _online;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _check();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _check());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    final online = await di.sl<NetworkInfo>().isConnected;
    if (mounted) setState(() => _online = online);
  }

  @override
  Widget build(BuildContext context) {
    if (_online == false) {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.x2l),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 48,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Internet connection required to access the Parent '
                    'Portal.',
                    textAlign: TextAlign.center,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: 'Retry',
                    icon: Icons.refresh_rounded,
                    onPressed: _check,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
