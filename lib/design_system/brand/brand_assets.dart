import 'package:flutter/material.dart';

/// The illustrated states shipped in `assets/branding/states/`.
enum BrandState {
  empty('empty'),
  loading('loading'),
  success('success'),
  warning('warning'),
  error('error'),
  offline('offline'),
  noAccess('no_access'),
  notFound('not_found');

  const BrandState(this.fileKey);

  /// The `<name>` part of `state_<name>_<light|dark>.png`.
  final String fileKey;

  /// The illustration that matches a legacy state [icon], so existing
  /// empty/error widgets keep their meaning without call-site changes.
  static BrandState fromIcon(IconData icon, {BrandState fallback = empty}) {
    final codePoint = icon.codePoint;
    bool any(List<IconData> icons) =>
        icons.any((candidate) => candidate.codePoint == codePoint);

    if (any(const [
      Icons.cloud_off,
      Icons.cloud_off_outlined,
      Icons.cloud_off_rounded,
      Icons.wifi_off,
      Icons.wifi_off_rounded,
      Icons.signal_wifi_off,
    ])) {
      return offline;
    }
    if (any(const [
      Icons.error_outline,
      Icons.error_outline_rounded,
      Icons.error,
      Icons.error_rounded,
      Icons.report_problem_outlined,
    ])) {
      return error;
    }
    if (any(const [
      Icons.lock_outline,
      Icons.lock_outline_rounded,
      Icons.lock,
      Icons.lock_rounded,
      Icons.block,
      Icons.no_accounts_outlined,
    ])) {
      return noAccess;
    }
    if (any(const [
      Icons.search_off,
      Icons.search_off_rounded,
      Icons.link_off,
      Icons.link_off_rounded,
    ])) {
      return notFound;
    }
    if (any(const [
      Icons.warning_amber,
      Icons.warning_amber_rounded,
      Icons.warning_amber_outlined,
    ])) {
      return warning;
    }
    if (any(const [
      Icons.check_circle,
      Icons.check_circle_outline,
      Icons.check_circle_outline_rounded,
      Icons.task_alt,
    ])) {
      return success;
    }
    return fallback;
  }
}

/// Every School Pulse brand image bundled in `assets/branding/`.
///
/// Screens must use these constants or the brightness-aware helpers below,
/// never a hard-coded asset path. 2.0x/3.0x variants are resolved by Flutter.
abstract final class BrandAssets {
  static const String _root = 'assets/branding';
  static const String _states = '$_root/states';

  // Logo mark (app bars, headers, loaders).
  static const String logoMarkLight = '$_root/logo_mark_light.png';
  static const String logoMarkDark = '$_root/logo_mark_dark.png';

  // Horizontal lockup (login, drawer header, About).
  static const String logoHorizontalLight = '$_root/logo_horizontal_light.png';
  static const String logoHorizontalDark = '$_root/logo_horizontal_dark.png';

  // Wordmark only.
  static const String wordmarkLight = '$_root/wordmark_light.png';
  static const String wordmarkDark = '$_root/wordmark_dark.png';

  /// The launcher icon as an in-app image (About screens).
  static const String appIconRounded = '$_root/app_icon_rounded.png';

  // Legacy file names kept from the previous logo set, redrawn with the new
  // artwork. Splash and launcher configs read the last three.
  static const String logoForLightMode = '$_root/logo_for_light_mode.png';
  static const String logoForDarkMode = '$_root/logo_for_dark_mode.png';
  static const String iconLightMode = '$_root/icon_light_Mode.png';
  static const String iconDarkMode = '$_root/icon_dark_mode.png';
  static const String launcherIcon = '$_root/launcher_icon.png';
  static const String splashLightMode = '$_root/splash_light_mode.png';
  static const String splashDarkMode = '$_root/splash_dark_mode.png';

  // Loading animation (24 frames, ~40 ms each).
  static const String loadingLightGif = '$_root/loading_light.gif';
  static const String loadingDarkGif = '$_root/loading_dark.gif';
  static const int loadingFrameCount = 24;

  // State illustrations (160 px base).
  static const String stateEmptyLight = '$_states/state_empty_light.png';
  static const String stateEmptyDark = '$_states/state_empty_dark.png';
  static const String stateLoadingLight = '$_states/state_loading_light.png';
  static const String stateLoadingDark = '$_states/state_loading_dark.png';
  static const String stateSuccessLight = '$_states/state_success_light.png';
  static const String stateSuccessDark = '$_states/state_success_dark.png';
  static const String stateWarningLight = '$_states/state_warning_light.png';
  static const String stateWarningDark = '$_states/state_warning_dark.png';
  static const String stateErrorLight = '$_states/state_error_light.png';
  static const String stateErrorDark = '$_states/state_error_dark.png';
  static const String stateOfflineLight = '$_states/state_offline_light.png';
  static const String stateOfflineDark = '$_states/state_offline_dark.png';
  static const String stateNoAccessLight = '$_states/state_no_access_light.png';
  static const String stateNoAccessDark = '$_states/state_no_access_dark.png';
  static const String stateNotFoundLight = '$_states/state_not_found_light.png';
  static const String stateNotFoundDark = '$_states/state_not_found_dark.png';

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static String _pick(BuildContext context, String light, String dark) =>
      _isDark(context) ? dark : light;

  static String logoMark(BuildContext context) =>
      _pick(context, logoMarkLight, logoMarkDark);

  static String logoHorizontal(BuildContext context) =>
      _pick(context, logoHorizontalLight, logoHorizontalDark);

  static String wordmark(BuildContext context) =>
      _pick(context, wordmarkLight, wordmarkDark);

  static String loadingGif(BuildContext context) =>
      _pick(context, loadingLightGif, loadingDarkGif);

  /// A single frame of the loading animation, for reduced motion.
  static String loadingFrame(BuildContext context, [int index = 0]) {
    final scheme = _isDark(context) ? 'dark' : 'light';
    final frame = (index % loadingFrameCount).toString().padLeft(2, '0');
    return '$_root/loading/$scheme/loading_$frame.png';
  }

  static String state(BuildContext context, BrandState state) =>
      stateFor(state, dark: _isDark(context));

  static String stateFor(BrandState state, {required bool dark}) =>
      '$_states/state_${state.fileKey}_${dark ? 'dark' : 'light'}.png';
}

/// A brand state illustration sized for empty/error/offline blocks.
class BrandStateImage extends StatelessWidget {
  final BrandState state;
  final double size;

  const BrandStateImage({super.key, required this.state, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      BrandAssets.state(context, state),
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}
