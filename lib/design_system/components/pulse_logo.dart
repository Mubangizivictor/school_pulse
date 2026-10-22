import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/brand/brand_assets.dart';

enum PulseLogoVariant {
  /// 16:9 Horizontal format with text and mark
  full,

  /// Square/Vertical format with mark and stacked text
  vertical,

  /// 16:9 Horizontal format (optimized for splash)
  splash,

  /// 16:9 Horizontal format (optimized for auth)
  auth,

  /// Square/Vertical format (mark only or compact)
  shield,

  /// Square/Vertical format
  compact,

  /// 16:9 Horizontal format for headers
  header,

  /// Square/Vertical format for sidebar
  sidebar,
}

class PulseLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final double? size;
  final PulseLogoVariant variant;
  final bool isDark;
  final BoxFit fit;

  const PulseLogo({
    super.key,
    this.width,
    this.height,
    this.size,
    this.variant = PulseLogoVariant.full,
    this.isDark = false,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final useDarkLogo =
        isDark || Theme.of(context).brightness == Brightness.dark;

    switch (variant) {
      // Cropped horizontal lockup: `size` is its height so the wordmark stays
      // legible (the lockup is ~6:1, so a square box would shrink it to a line).
      case PulseLogoVariant.header:
        return Image.asset(
          useDarkLogo
              ? BrandAssets.logoHorizontalDark
              : BrandAssets.logoHorizontalLight,
          width: size == null ? width : null,
          height: size ?? height,
          fit: fit,
        );
      // Mark only, for compact square slots such as a collapsed sidebar.
      case PulseLogoVariant.vertical:
      case PulseLogoVariant.shield:
      case PulseLogoVariant.compact:
      case PulseLogoVariant.sidebar:
        return Image.asset(
          useDarkLogo ? BrandAssets.logoMarkDark : BrandAssets.logoMarkLight,
          width: size ?? width,
          height: size ?? height,
          fit: fit,
        );
      case PulseLogoVariant.full:
      case PulseLogoVariant.splash:
      case PulseLogoVariant.auth:
        return Image.asset(
          useDarkLogo
              ? BrandAssets.logoForDarkMode
              : BrandAssets.logoForLightMode,
          width: size ?? width,
          height: size ?? height,
          fit: fit,
        );
    }
  }
}
