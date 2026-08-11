import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class Skeleton extends StatelessWidget {
  final double? height;
  final double? width;
  final double borderRadius;

  const Skeleton({super.key, this.height, this.width, this.borderRadius = 8});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final bool showBorder;
  final bool showShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderColor,
    this.showBorder = true,
    this.showShadow = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _controller.reverse() : null,
      onTapUp: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapCancel: widget.onTap != null ? () => _controller.forward() : null,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: widget.margin,
          decoration: BoxDecoration(
            color:
                widget.color ??
                (isDark ? Theme.of(context).colorScheme.surface : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: widget.showBorder
                ? Border.all(
                    color:
                        widget.borderColor ??
                        Theme.of(context).colorScheme.outlineVariant.withValues(
                          alpha: isDark ? 0.7 : 0.8,
                        ),
                    width: 1,
                  )
                : null,
            boxShadow: (widget.showShadow && !isDark)
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          clipBehavior: Clip.antiAlias,
          // A Material ancestor here (rather than relying on whatever
          // Scaffold happens to be further up the tree) is required so
          // ListTile/InkWell children paint their background and ink
          // splashes correctly instead of being hidden behind this
          // Container's own opaque decoration.
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(16.0),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: isDark ? Color.lerp(color, Colors.white, 0.4) : color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class AlertBanner extends StatelessWidget {
  final String title;
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback? onDismiss;

  const AlertBanner({
    super.key,
    required this.title,
    required this.message,
    required this.color,
    this.icon = Icons.info_outline,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: Icon(Icons.close, color: color, size: 18),
                onPressed: onDismiss,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
      );
    }
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.ctaLabel,
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 24),
              SecondaryButton(label: ctaLabel!, onPressed: onCtaPressed),
            ],
          ],
        ),
      ),
    );
  }
}

class OfflineIndicator extends StatelessWidget {
  final bool isOffline;
  final DateTime lastSynced;

  const OfflineIndicator({
    super.key,
    required this.isOffline,
    required this.lastSynced,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.grey[800],
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Text(
        'Offline — showing data from ${lastSynced.hour}:${lastSynced.minute.toString().padLeft(2, '0')}',
        style: const TextStyle(color: Colors.white, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class AvatarInitials extends StatelessWidget {
  final String name;
  final double size;
  final Color? ringColor;
  final VoidCallback? onTap;

  const AvatarInitials({
    super.key,
    required this.name,
    this.size = 40,
    this.ringColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
          border: ringColor != null
              ? Border.all(color: ringColor!, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedNumberText extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final String suffix;
  final String prefix;
  final Duration duration;
  final int decimalPlaces;

  const AnimatedNumberText({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
    this.prefix = '',
    this.duration = const Duration(milliseconds: 1000),
    this.decimalPlaces = 0,
  });

  @override
  State<AnimatedNumberText> createState() => _AnimatedNumberTextState();
}

class _AnimatedNumberTextState extends State<AnimatedNumberText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedNumberText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: oldWidget.value, end: widget.value)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo),
          );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix}${_groupThousands(_animation.value.toStringAsFixed(widget.decimalPlaces))}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }

  /// Inserts thousands separators into the integer part of a formatted
  /// number string (e.g. "350000" -> "350,000", "1234.50" -> "1,234.50").
  static String _groupThousands(String formatted) {
    final negative = formatted.startsWith('-');
    final unsigned = negative ? formatted.substring(1) : formatted;
    final dotIndex = unsigned.indexOf('.');
    final wholePart = dotIndex == -1
        ? unsigned
        : unsigned.substring(0, dotIndex);
    final fractionPart = dotIndex == -1 ? '' : unsigned.substring(dotIndex);
    final buffer = StringBuffer();
    for (int i = 0; i < wholePart.length; i++) {
      if (i > 0 && (wholePart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(wholePart[i]);
    }
    return '${negative ? '-' : ''}$buffer$fractionPart';
  }
}

/// Direction a [FadeInSlide] travels from as it appears.
///
/// Named for where the motion starts: `bt` slides up from below, `tb` down
/// from above, and so on.
enum FadeInDirection {
  /// Bottom to top.
  bt,

  /// Top to bottom.
  tb,

  /// Left to right.
  lr,

  /// Right to left.
  rl;

  /// Starting displacement, as a fraction of the travel distance
  /// [FadeInSlide] applies.
  Offset get offset {
    switch (this) {
      case FadeInDirection.bt:
        return const Offset(0, 0.1);
      case FadeInDirection.tb:
        return const Offset(0, -0.1);
      case FadeInDirection.lr:
        return const Offset(-0.1, 0);
      case FadeInDirection.rl:
        return const Offset(0.1, 0);
    }
  }
}

class FadeInSlide extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  /// Explicit displacement. Ignored when [direction] is set.
  final Offset offset;

  /// Convenience alternative to [offset] for the four common directions.
  /// Takes precedence when both are given.
  final FadeInDirection? direction;

  const FadeInSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.1),
    this.direction,
  });

  /// The displacement actually animated. Kept as a getter so [direction] and
  /// [offset] cannot drift apart.
  Offset get _effectiveOffset => direction?.offset ?? offset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          tween: Tween(
            begin: 0.0,
            end: snapshot.connectionState == ConnectionState.done ? 1.0 : 0.0,
          ),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final from = _effectiveOffset;
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(
                  from.dx * (1 - value) * 100,
                  from.dy * (1 - value) * 100,
                ),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }
}

class DashboardStatCard extends StatefulWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? isPositiveTrend;
  final String suffix;
  final int decimalPlaces;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.isPositiveTrend,
    this.suffix = '',
    this.decimalPlaces = 0,
  });

  @override
  State<DashboardStatCard> createState() => _DashboardStatCardState();
}

class _DashboardStatCardState extends State<DashboardStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _iconAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ScaleTransition(
                  scale: _iconAnimation,
                  child: RotationTransition(
                    turns: Tween(begin: -0.1, end: 0.0).animate(_controller),
                    child: Icon(widget.icon, color: widget.color, size: 14),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.trend != null)
                FadeInSlide(
                  delay: const Duration(milliseconds: 400),
                  child: StatusBadge(
                    label: widget.trend!,
                    color: widget.isPositiveTrend ?? true
                        ? semantic.success
                        : semantic.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          AnimatedNumberText(
            value: widget.value,
            suffix: widget.suffix,
            decimalPlaces: widget.decimalPlaces,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticalStatCard extends StatefulWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? isPositiveTrend;
  final String suffix;
  final int decimalPlaces;

  const AnalyticalStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.isPositiveTrend,
    this.suffix = '',
    this.decimalPlaces = 0,
  });

  @override
  State<AnalyticalStatCard> createState() => _AnalyticalStatCardState();
}

class _AnalyticalStatCardState extends State<AnalyticalStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _iconAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      showShadow: false,
      color: Colors.transparent,
      borderColor: widget.color.withValues(alpha: isDark ? 0.2 : 0.15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.color.withValues(alpha: isDark ? 0.15 : 0.08),
              widget.color.withValues(alpha: isDark ? 0.05 : 0.02),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: ScaleTransition(
                scale: _iconAnimation,
                child: Icon(widget.icon, color: widget.color, size: 16),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.trend != null)
                    Text(
                      widget.trend!,
                      style: TextStyle(
                        color: widget.isPositiveTrend ?? true
                            ? semantic.success
                            : semantic.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedNumberText(
              value: widget.value,
              suffix: widget.suffix,
              decimalPlaces: widget.decimalPlaces,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final double progress; // 0.0 to 1.0
  final String subtitle;
  final Color? color;

  const ProgressCard({
    super.key,
    required this.title,
    required this.progress,
    required this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Theme.of(context).colorScheme.primary;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: activeColor.withValues(alpha: 0.1),
            color: activeColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class PerformanceBarChart extends StatelessWidget {
  final Map<String, double>
  data; // Label to value; bars scale relative to maxValue
  final Color? color;
  final String title;
  final double maxValue;
  final bool showPercentSign;

  const PerformanceBarChart({
    super.key,
    required this.data,
    this.color,
    this.title = 'Subject Performance',
    this.maxValue = 100,
    this.showPercentSign = true,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Theme.of(context).colorScheme.primary;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.entries.map((entry) {
                  final fraction = maxValue <= 0
                      ? 0.0
                      : (entry.value / maxValue).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.value.round()}${showPercentSign ? '%' : ''}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 24,
                          height: 100 * fraction,
                          decoration: BoxDecoration(
                            color: activeColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.key.length > 3
                              ? entry.key.substring(0, 3)
                              : entry.key,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionGrid extends StatelessWidget {
  final List<QuickActionItem> items;

  const QuickActionGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return AppCard(
          onTap: item.onTap,
          padding: EdgeInsets.zero,
          showShadow: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class QuickActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class AppSearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const AppSearchField({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

Future<bool?> confirmActionDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: isDestructive ? Colors.red : null),
          ),
        ),
      ],
    ),
  );
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Widget? trailing;
  final Color? color;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
    this.trailing,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          if (actionLabel != null)
            TextButton(onPressed: onActionPressed, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// Theme preference row for the "More"/Settings screens.
///
/// Reads and writes [ThemeProvider] directly so any screen can drop it in
/// without plumbing the provider through its own state - which is the point,
/// since the student, parent and staff More screens all need the same row.
class ThemeSwitchTile extends StatelessWidget {
  const ThemeSwitchTile({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return ListTile(
      leading: Icon(switch (themeProvider.themeMode) {
        ThemeMode.light => Icons.light_mode_rounded,
        ThemeMode.dark => Icons.dark_mode_rounded,
        ThemeMode.system => Icons.brightness_auto_rounded,
      }, color: Theme.of(context).colorScheme.primary),
      title: const Text('App Theme'),
      trailing: Text(
        switch (themeProvider.themeMode) {
          ThemeMode.light => 'Light',
          ThemeMode.dark => 'Dark',
          ThemeMode.system => 'System',
        },
        style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13),
      ),
      onTap: () => _showSelector(context, themeProvider),
    );
  }

  void _showSelector(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Theme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(sheetContext),
                ),
              ),
            ),
            _option(
              sheetContext,
              themeProvider,
              ThemeMode.system,
              Icons.brightness_auto_rounded,
              'System Default',
            ),
            _option(
              sheetContext,
              themeProvider,
              ThemeMode.light,
              Icons.light_mode_rounded,
              'Light Mode',
            ),
            _option(
              sheetContext,
              themeProvider,
              ThemeMode.dark,
              Icons.dark_mode_rounded,
              'Dark Mode',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _option(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    IconData icon,
    String label,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      selected: isSelected,
      selectedTileColor: colors.primaryContainer,
      selectedColor: colors.onPrimaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(
        icon,
        color: isSelected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
      ),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: colors.onPrimaryContainer)
          : null,
      onTap: () {
        themeProvider.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}
