import 'package:flutter/material.dart';

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
    String assetPath;
    final useDarkLogo =
        isDark || Theme.of(context).brightness == Brightness.dark;

    switch (variant) {
      case PulseLogoVariant.full:
      case PulseLogoVariant.splash:
      case PulseLogoVariant.auth:
      case PulseLogoVariant.header:
        assetPath = useDarkLogo
            ? 'assets/logos/logo_for_dark_mode.png'
            : 'assets/logos/logo_for_light_mode.png';
        break;
      case PulseLogoVariant.vertical:
      case PulseLogoVariant.shield:
      case PulseLogoVariant.compact:
      case PulseLogoVariant.sidebar:
        assetPath = useDarkLogo
            ? 'assets/logos/logo_for_dark_mode.png'
            : 'assets/logos/logo_for_light_mode.png';
        break;
    }

    return Image.asset(
      assetPath,
      width: size ?? width,
      height: size ?? height,
      fit: fit,
    );
  }
}
