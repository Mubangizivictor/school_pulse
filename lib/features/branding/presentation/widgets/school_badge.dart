import 'dart:async';

import 'package:flutter/material.dart';

/// A single safe rendering point for tenant badge artwork.
class SchoolBadge extends StatefulWidget {
  const SchoolBadge({super.key, this.badgeUrl, this.size = 112, this.fallback});

  final String? badgeUrl;
  final double size;

  /// Shown instead of the generic placeholder when there is no badge, or it
  /// fails to load.
  final Widget? fallback;

  @override
  State<SchoolBadge> createState() => _SchoolBadgeState();
}

class _SchoolBadgeState extends State<SchoolBadge> {
  bool _timedOut = false;
  Timer? _timeoutTimer;

  bool get _hasBadge =>
      widget.badgeUrl != null && widget.badgeUrl!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _armTimeout();
  }

  @override
  void didUpdateWidget(covariant SchoolBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.badgeUrl != widget.badgeUrl) {
      _timedOut = false;
      _armTimeout();
    }
  }

  // Image.network on web silently stalls (no error, no completed frame)
  // when a badge URL is blocked by CORS instead of firing errorBuilder -
  // leaving a blank box forever. This forces a fallback to the visible
  // placeholder if the image hasn't resolved within a few seconds.
  void _armTimeout() {
    _timeoutTimer?.cancel();
    if (!_hasBadge) return;
    _timeoutTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _timedOut = true);
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.size * .24);
    final placeholder =
        widget.fallback ?? _SchoolBadgePlaceholder(size: widget.size);
    if (!_hasBadge || _timedOut) return placeholder;

    return Container(
      width: widget.size,
      height: widget.size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: radius,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Image.network(
        widget.badgeUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => placeholder,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame != null) _timeoutTimer?.cancel();
          return frame == null && !wasSynchronouslyLoaded ? placeholder : child;
        },
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
