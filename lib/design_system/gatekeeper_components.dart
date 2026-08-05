import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';

/// Large icon+label tile for Gatekeeper Simple Mode's home screen action
/// grid. Deliberately much larger than [QuickActionGrid]'s admin-dashboard
/// tiles (20px icon / 11px text) - Gatekeeper Simple Mode requires >=60
/// logical-pixel touch targets and icons/labels legible at a glance for
/// guards with limited digital literacy.
class GatekeeperActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badgeCount;

  const GatekeeperActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 34),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              top: -4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeCount! > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum GatekeeperButtonTone { success, danger, warning, info }

/// Full-width, >=60px-tall primary action button for Gatekeeper Simple Mode
/// confirm screens (CHECK IN, ENTER, RELEASE, ...). Color, icon and text
/// always travel together, per spec: never rely on color alone to convey
/// meaning (green+checkmark=success, red+warning=deny, amber=pending,
/// blue=info).
class GatekeeperPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final GatekeeperButtonTone tone;
  final bool isLoading;

  const GatekeeperPrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.tone = GatekeeperButtonTone.success,
    this.isLoading = false,
  });

  Color _colorFor(SemanticColors colors) {
    switch (tone) {
      case GatekeeperButtonTone.success:
        return colors.success;
      case GatekeeperButtonTone.danger:
        return colors.error;
      case GatekeeperButtonTone.warning:
        return colors.warning;
      case GatekeeperButtonTone.info:
        return colors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<SemanticColors>()!;
    final color = _colorFor(colors);
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        icon: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 26),
        label: Text(label),
      ),
    );
  }
}

enum GatekeeperConnectionState { online, offline, syncing }

/// Plain-language online/offline/syncing indicator for the Gatekeeper home
/// header. Never surfaces raw Firebase/network errors to the guard - per
/// spec, technical failures must read as "Saved. Waiting for internet."
/// style messages, not exceptions or stack traces.
class GatekeeperStatusChip extends StatelessWidget {
  final GatekeeperConnectionState state;
  final int pendingSyncCount;

  const GatekeeperStatusChip({
    super.key,
    required this.state,
    this.pendingSyncCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<SemanticColors>()!;
    Color color;
    IconData icon;
    String label;
    switch (state) {
      case GatekeeperConnectionState.online:
        color = colors.success;
        icon = Icons.cloud_done_outlined;
        label = pendingSyncCount > 0
            ? 'Online • $pendingSyncCount waiting'
            : 'Online';
        break;
      case GatekeeperConnectionState.syncing:
        color = colors.info;
        icon = Icons.sync;
        label = 'Syncing…';
        break;
      case GatekeeperConnectionState.offline:
        color = colors.warning;
        icon = Icons.cloud_off_outlined;
        label = pendingSyncCount > 0
            ? 'No internet • $pendingSyncCount saved'
            : 'No internet';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive column count for the Gatekeeper home action grid: 1 column on
/// narrow phones, up to 4 on kiosk/tablet landscape and desktop, so every
/// tile keeps a large, thumb-friendly footprint regardless of device.
int gatekeeperGridColumns(double width) {
  if (width >= 1000) return 4;
  if (width >= 700) return 3;
  if (width >= 400) return 2;
  return 1;
}
