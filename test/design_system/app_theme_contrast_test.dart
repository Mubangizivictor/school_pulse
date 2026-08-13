import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_theme.dart';

/// WCAG 2.1 contrast ratio, per
/// https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
double contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color c) {
  double linearize(double channel) {
    if (channel <= 0.03928) return channel / 12.92;
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * linearize(c.r) +
      0.7152 * linearize(c.g) +
      0.0722 * linearize(c.b);
}

void main() {
  const wcagAANormalText = 4.5;
  const wcagAALargeTextOrIcon = 3.0;

  /// Extracts the actual runtime ColorScheme by pumping a themed widget
  /// tree and capturing `Theme.of(context)` — this checks what the app
  /// really resolves at runtime (via ColorScheme.fromSeed + the explicit
  /// overrides in AppTheme), not just the raw AppColors constants, since
  /// AppColors.textPrimary/textSecondary/surfaceElevated etc. all read
  /// through Theme.of(context).colorScheme rather than returning the
  /// constants directly.
  Future<ColorScheme> resolveColorScheme(
    WidgetTester tester,
    ThemeData theme,
  ) async {
    late ColorScheme scheme;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) {
            scheme = Theme.of(context).colorScheme;
            return const SizedBox();
          },
        ),
      ),
    );
    return scheme;
  }

  group('AppTheme.light() contrast', () {
    testWidgets('text/surface pairs meet WCAG AA', (tester) async {
      final scheme = await resolveColorScheme(tester, AppTheme.light());

      final onSurface = contrastRatio(scheme.onSurface, scheme.surface);
      final onSurfaceVariant = contrastRatio(
        scheme.onSurfaceVariant,
        scheme.surface,
      );
      final onPrimary = contrastRatio(scheme.onPrimary, scheme.primary);

      expect(
        onSurface,
        greaterThanOrEqualTo(wcagAANormalText),
        reason: 'textPrimary vs surface: $onSurface',
      );
      expect(
        onSurfaceVariant,
        greaterThanOrEqualTo(wcagAALargeTextOrIcon),
        reason: 'textSecondary/textMuted vs surface: $onSurfaceVariant',
      );
      expect(
        onPrimary,
        greaterThanOrEqualTo(wcagAALargeTextOrIcon),
        reason:
            'onPrimary (e.g. white nav-bar-selected icon) vs primary: '
            '$onPrimary',
      );
    });

    testWidgets('scaffold background vs onSurface text', (tester) async {
      final theme = AppTheme.light();
      final ratio = contrastRatio(
        theme.colorScheme.onSurface,
        theme.scaffoldBackgroundColor,
      );
      expect(
        ratio,
        greaterThanOrEqualTo(wcagAANormalText),
        reason: 'textPrimary vs scaffoldBackgroundColor: $ratio',
      );
    });
  });

  group('AppTheme.dark() contrast', () {
    testWidgets('text/surface pairs meet WCAG AA', (tester) async {
      final scheme = await resolveColorScheme(tester, AppTheme.dark());

      final onSurface = contrastRatio(scheme.onSurface, scheme.surface);
      final onSurfaceVariant = contrastRatio(
        scheme.onSurfaceVariant,
        scheme.surface,
      );
      final onPrimary = contrastRatio(scheme.onPrimary, scheme.primary);

      expect(
        onSurface,
        greaterThanOrEqualTo(wcagAANormalText),
        reason: 'textPrimary vs surface: $onSurface',
      );
      expect(
        onSurfaceVariant,
        greaterThanOrEqualTo(wcagAALargeTextOrIcon),
        reason: 'textSecondary/textMuted vs surface: $onSurfaceVariant',
      );
      expect(
        onPrimary,
        greaterThanOrEqualTo(wcagAALargeTextOrIcon),
        reason: 'onPrimary vs primary: $onPrimary',
      );
    });

    testWidgets('scaffold background vs onSurface text', (tester) async {
      final theme = AppTheme.dark();
      final ratio = contrastRatio(
        theme.colorScheme.onSurface,
        theme.scaffoldBackgroundColor,
      );
      expect(
        ratio,
        greaterThanOrEqualTo(wcagAANormalText),
        reason: 'textPrimary vs scaffoldBackgroundColor: $ratio',
      );
    });

    testWidgets('bottom nav: unselected icon/label vs nav bar surface', (
      tester,
    ) async {
      // Mirrors super_admin_dashboard.dart's bottom NavigationBar: bar
      // background is AppColors.surfaceElevated(context) ==
      // colorScheme.surface, unselected label/icon color is
      // AppColors.textMuted(context) == colorScheme.onSurfaceVariant.
      final scheme = await resolveColorScheme(tester, AppTheme.dark());
      final ratio = contrastRatio(scheme.onSurfaceVariant, scheme.surface);
      expect(
        ratio,
        greaterThanOrEqualTo(wcagAALargeTextOrIcon),
        reason: 'unselected bottom-nav icon/label vs bar background: $ratio',
      );
    });

    testWidgets('bottom nav: selected icon vs tinted indicator pill', (
      tester,
    ) async {
      // indicatorColor in the dashboard is primary at 14% alpha over the
      // nav bar surface; approximate the composited color the same way
      // Flutter paints it (alpha blend over an opaque background).
      final scheme = await resolveColorScheme(tester, AppTheme.dark());
      final indicator = Color.alphaBlend(
        scheme.primary.withValues(alpha: 0.14),
        scheme.surface,
      );
      final ratio = contrastRatio(scheme.primary, indicator);
      expect(
        ratio,
        greaterThanOrEqualTo(wcagAALargeTextOrIcon),
        reason: 'selected bottom-nav icon vs indicator pill: $ratio',
      );
    });
  });

  group(
    'AppColors raw constant pairs (as documented, not runtime-derived)',
    () {
      test('light: textPrimaryLight vs surfaceLight/bgLight', () {
        final onSurface = contrastRatio(
          AppColors.textPrimaryLight,
          AppColors.surfaceLight,
        );
        final onBg = contrastRatio(
          AppColors.textPrimaryLight,
          AppColors.bgLight,
        );
        expect(onSurface, greaterThanOrEqualTo(wcagAANormalText));
        expect(onBg, greaterThanOrEqualTo(wcagAANormalText));
      });

      test('light: textSecondaryLight/textMutedLight vs surfaceLight', () {
        final secondary = contrastRatio(
          AppColors.textSecondaryLight,
          AppColors.surfaceLight,
        );
        final muted = contrastRatio(
          AppColors.textMutedLight,
          AppColors.surfaceLight,
        );
        expect(secondary, greaterThanOrEqualTo(wcagAANormalText));
        expect(
          muted,
          greaterThanOrEqualTo(wcagAALargeTextOrIcon),
          reason:
              'textMutedLight vs surfaceLight: $muted '
              '(muted text should still clear the large-text/icon floor)',
        );
      });

      test(
        'dark: textPrimaryDark vs surfaceDark/bgDark/elevatedSurfaceDark',
        () {
          final onSurface = contrastRatio(
            AppColors.textPrimaryDark,
            AppColors.surfaceDark,
          );
          final onBg = contrastRatio(
            AppColors.textPrimaryDark,
            AppColors.bgDark,
          );
          final onElevated = contrastRatio(
            AppColors.textPrimaryDark,
            AppColors.elevatedSurfaceDark,
          );
          expect(onSurface, greaterThanOrEqualTo(wcagAANormalText));
          expect(onBg, greaterThanOrEqualTo(wcagAANormalText));
          expect(onElevated, greaterThanOrEqualTo(wcagAANormalText));
        },
      );

      test('dark: textSecondaryDark/textMutedDark vs surfaceDark', () {
        final secondary = contrastRatio(
          AppColors.textSecondaryDark,
          AppColors.surfaceDark,
        );
        final muted = contrastRatio(
          AppColors.textMutedDark,
          AppColors.surfaceDark,
        );
        expect(secondary, greaterThanOrEqualTo(wcagAANormalText));
        expect(
          muted,
          greaterThanOrEqualTo(wcagAALargeTextOrIcon),
          reason:
              'textMutedDark vs surfaceDark: $muted '
              '(the dedicated constant, even though onSurfaceVariant currently '
              'resolves to textSecondaryDark instead at runtime)',
        );
      });

      test('borders are visible (not identical to surface) in both themes', () {
        final lightBorderVsSurface = contrastRatio(
          AppColors.borderLight,
          AppColors.surfaceLight,
        );
        final darkBorderVsSurface = contrastRatio(
          AppColors.borderDark,
          AppColors.surfaceDark,
        );
        // Borders are intentionally subtle (spec section 37), so this is a
        // low floor just to catch a border becoming literally invisible.
        expect(lightBorderVsSurface, greaterThan(1.05));
        expect(darkBorderVsSurface, greaterThan(1.05));
      });
    },
  );
}
