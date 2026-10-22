import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart' show SemanticColors;

/// The horizontal pill tab row at the top of the Structure hub - a filled
/// primary pill for the active category, outlined pills for the rest.
/// Kept as a plain widget (not a TabBar) so the active pill can be a solid
/// fill rather than an underline indicator.
class StructureTopTabs extends StatelessWidget {
  const StructureTopTabs({
    super.key,
    required this.sections,
    required this.selected,
    required this.onSelected,
  });

  final List<(String, String)> sections;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = sections[index];
          final active = item.$1 == selected;
          return Material(
            color: active ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () => onSelected(item.$1),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: active ? scheme.primary : scheme.primary,
                  ),
                ),
                child: Text(
                  item.$2,
                  style: TextStyle(
                    color: active ? scheme.onPrimary : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The large "Configuration health" card - circular ring, configured/pending
/// counts, and a compact "View details" link to the full progress screen.
class ConfigurationHealthCard extends StatelessWidget {
  const ConfigurationHealthCard({
    super.key,
    required this.percentage,
    required this.ratio,
    required this.configuredCount,
    required this.pendingCount,
    required this.onViewDetails,
  });

  final int percentage;
  final double ratio;
  final int configuredCount;
  final int pendingCount;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      showShadow: false,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: ratio,
                  color: scheme.primary,
                  backgroundColor: scheme.surfaceContainerHighest,
                  strokeWidth: 4,
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration health',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$configuredCount configured · $pendingCount need attention',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: onViewDetails,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View details',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 14, color: scheme.primary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One compact row tile in the Academic structure grid - icon, title, live
/// count, and a trailing chevron. The whole card is the tap target, so no
/// separate management link is needed.
class StructureMetricCard extends StatelessWidget {
  const StructureMetricCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      showShadow: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 14, color: scheme.primary),
        ],
      ),
    );
  }
}

/// The orange "items need attention" banner. Only rendered when there is
/// something real to review - never a decorative placeholder.
class StructureAttentionCard extends StatelessWidget {
  const StructureAttentionCard({
    super.key,
    required this.pendingCount,
    required this.onReview,
  });

  final int pendingCount;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final warning = Theme.of(context).extension<SemanticColors>()!.warning;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: warning.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info_outline, color: warning, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pendingCount item${pendingCount == 1 ? '' : 's'} need attention',
                  style: TextStyle(
                    color: warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Some parts of your structure need to be completed.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: warning,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: onReview,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(
                  'Review now',
                  style: TextStyle(
                    color: warning.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
