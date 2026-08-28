import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

/// "You're offline — showing saved information." banner for cached Parent
/// Portal screens. Purely presentational - callers decide when to show it
/// (typically driven by `NetworkInfo.isConnected`).
class ParentOfflineBanner extends StatelessWidget {
  const ParentOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      color: AppColors.warningSurface(context),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: AppColors.warning(context),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              "You're offline — showing saved information.",
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.warning(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Last updated <time>" caption for a cached screen/section.
class ParentLastUpdatedLabel extends StatelessWidget {
  const ParentLastUpdatedLabel({required this.updatedAt, super.key});

  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    if (updatedAt == null) return const SizedBox.shrink();
    return Text(
      'Last updated ${DateFormat('MMM d, h:mm a').format(updatedAt!)}',
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.textSecondary(context),
      ),
    );
  }
}

enum ParentOfflineItemState {
  savedForOffline,
  notAvailableOffline,
  waitingToSync,
  syncFailed,
  updatedJustNow,
}

/// Small state chip for one queued/cached item ("Waiting to sync", "Sync
/// failed — Retry", etc.) per the spec's required state vocabulary.
class ParentOfflineStateChip extends StatelessWidget {
  const ParentOfflineStateChip({required this.state, this.onRetry, super.key});

  final ParentOfflineItemState state;
  final VoidCallback? onRetry;

  String get _label => switch (state) {
    ParentOfflineItemState.savedForOffline => 'Saved for offline',
    ParentOfflineItemState.notAvailableOffline => 'Not available offline yet',
    ParentOfflineItemState.waitingToSync => 'Waiting to sync',
    ParentOfflineItemState.syncFailed => 'Sync failed',
    ParentOfflineItemState.updatedJustNow => 'Updated just now',
  };

  Color _color(BuildContext context) => switch (state) {
    ParentOfflineItemState.savedForOffline => AppColors.textSecondary(context),
    ParentOfflineItemState.notAvailableOffline => AppColors.textSecondary(
      context,
    ),
    ParentOfflineItemState.waitingToSync => AppColors.warning(context),
    ParentOfflineItemState.syncFailed => AppColors.danger(context),
    ParentOfflineItemState.updatedJustNow => AppColors.success(context),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _label,
          style: AppTypography.bodySmall.copyWith(
            color: _color(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (state == ParentOfflineItemState.syncFailed && onRetry != null) ...[
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              '— Retry',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
