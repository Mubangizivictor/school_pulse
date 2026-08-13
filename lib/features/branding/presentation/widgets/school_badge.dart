import 'package:flutter/material.dart';

/// A single safe rendering point for tenant badge artwork.
class SchoolBadge extends StatelessWidget {
  const SchoolBadge({super.key, this.badgeUrl, this.size = 112});

  final String? badgeUrl;
  final double size;

  bool get _hasBadge => badgeUrl != null && badgeUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * .24);
    final placeholder = _SchoolBadgePlaceholder(size: size);
    if (!_hasBadge) return placeholder;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: radius,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Image.network(
        badgeUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => placeholder,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
      ),
    );
  }
}

class _SchoolBadgePlaceholder extends StatelessWidget {
  const _SchoolBadgePlaceholder({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(size * .24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Icon(
        Icons.school_outlined,
        size: size * .46,
        color: scheme.primary,
      ),
    );
  }
}
