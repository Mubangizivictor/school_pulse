import 'dart:convert';
import 'dart:io';

const _source = 'design/tokens/school_pulse_theme.json';

String _camel(String value) {
  final parts = value.split(RegExp(r'[^A-Za-z0-9]+'));
  final result =
      parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  return RegExp(r'^\d').hasMatch(result) ? 'x$result' : result;
}

String _double(num value) => value is int ? '$value.0' : '$value';

String _kebab(String value) => value.replaceAllMapped(
  RegExp(r'([a-z0-9])([A-Z])'),
  (match) => '${match[1]}-${match[2]!.toLowerCase()}',
);

String _color(String value) {
  if (value.startsWith('#')) return 'Color(0xFF${value.substring(1)})';
  final rgba = RegExp(
    r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)',
  ).firstMatch(value)!;
  final alpha = (double.parse(rgba[4]!) * 255)
      .round()
      .toRadixString(16)
      .padLeft(2, '0');
  return 'Color(0x$alpha${int.parse(rgba[1]!).toRadixString(16).padLeft(2, '0')}${int.parse(rgba[2]!).toRadixString(16).padLeft(2, '0')}${int.parse(rgba[3]!).toRadixString(16).padLeft(2, '0')})';
}

String _flutter(Map<String, dynamic> json) {
  final light = Map<String, dynamic>.from(json['light']);
  final dark = Map<String, dynamic>.from(json['dark']);
  final keys = light.keys.toList();
  final fields = keys.map((key) => '  final Color ${_camel(key)};').join('\n');
  final params = keys.map((key) => 'required this.${_camel(key)}').join(', ');
  String instance(Map<String, dynamic> colours) => keys
      .map((key) => '    ${_camel(key)}: ${_color(colours[key] as String)},')
      .join('\n');
  final copyParams = keys.map((key) => 'Color? ${_camel(key)}').join(', ');
  final copyFields = keys
      .map(
        (key) => '    ${_camel(key)}: ${_camel(key)} ?? this.${_camel(key)},',
      )
      .join('\n');
  final lerpFields = keys
      .map(
        (key) =>
            '    ${_camel(key)}: Color.lerp(${_camel(key)}, other.${_camel(key)}, t)!,',
      )
      .join('\n');
  final radius = Map<String, dynamic>.from(json['radius']);
  final spacing = Map<String, dynamic>.from(json['spacing']);
  final typeScale = Map<String, dynamic>.from(json['typeScale']);
  final fonts = Map<String, dynamic>.from(json['fonts']);
  final radiusValues = radius.entries
      .where((e) => e.value is num)
      .map((e) => '  static const double ${_camel(e.key)} = ${e.value}.0;')
      .join('\n');
  final spacingValues = spacing.entries
      .map((e) => '  static const double ${_camel(e.key)} = ${e.value}.0;')
      .join('\n');
  final typeValues = typeScale.entries
      .where((e) => e.value is Map && (e.value as Map).containsKey('size'))
      .map((e) {
        final v = Map<String, dynamic>.from(e.value as Map);
        final family = fonts[v['font']] as String;
        return '  static const ${_camel(e.key)} = TextStyle(fontFamily: ${jsonEncode(family)}, fontSize: ${_double(v['size'] as num)}, height: ${v['lineHeight'] / v['size']}, fontWeight: FontWeight.w${v['weight']}, letterSpacing: ${_double(v['letterSpacing'] as num)});';
      })
      .join('\n');
  final colorValues = [
    ...light.entries
        .where((entry) => entry.key != 'shadow')
        .map(
          (entry) =>
              '  static const Color light${entry.key[0].toUpperCase()}${entry.key.substring(1)} = ${_color(entry.value as String)};',
        ),
    ...dark.entries
        .where((entry) => entry.key != 'shadow')
        .map(
          (entry) =>
              '  static const Color dark${entry.key[0].toUpperCase()}${entry.key.substring(1)} = ${_color(entry.value as String)};',
        ),
  ].join('\n');
  return '''// GENERATED, DO NOT EDIT. Run: dart run tool/generate_theme.dart
import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
$fields

  const AppColors({$params});

  static const light = AppColors(
${instance(light)}
  );
  static const dark = AppColors(
${instance(dark)}
  );

  /// Tokens for [context]; falls back to the brightness default when the
  /// theme carries no AppColors extension (e.g. a bare MaterialApp).
  static AppColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  AppColors copyWith({$copyParams}) => AppColors(
$copyFields
  );

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
$lerpFields
    );
  }
}

class AppRadius {
  AppRadius._();
$radiusValues
}

class AppSpacing {
  AppSpacing._();
$spacingValues
}

class AppText {
  AppText._();
$typeValues
}

class AppColorValues {
  AppColorValues._();
  static const Color transparent = Color(0x00000000);
$colorValues
}
''';
}

String _css(Map<String, dynamic> json) {
  final light = Map<String, dynamic>.from(json['light']);
  final dark = Map<String, dynamic>.from(json['dark']);
  final radius = Map<String, dynamic>.from(json['radius']);
  final spacing = Map<String, dynamic>.from(json['spacing']);
  final typeScale = Map<String, dynamic>.from(json['typeScale']);
  String vars(Map<String, dynamic> values) => values.entries
      .map((e) => '  --sp-${_kebab(e.key)}: ${e.value};')
      .join('\n');
  final extras = [
    ...radius.entries.map(
      (e) =>
          '  --sp-radius-${_kebab(e.key)}: ${e.value is num ? '${e.value}px' : e.value};',
    ),
    ...spacing.entries.map(
      (e) => '  --sp-space-${_kebab(e.key)}: ${e.value}px;',
    ),
    '  --sp-font-display: "${json['fonts']['display']}", sans-serif;',
    '  --sp-font-body: "${json['fonts']['body']}", sans-serif;',
    ...typeScale.entries
        .where((e) => e.value is Map && (e.value as Map).containsKey('size'))
        .expand((e) {
          final v = Map<String, dynamic>.from(e.value as Map);
          final name = _kebab(e.key);
          return [
            '  --sp-text-$name-font: var(--sp-font-${v['font']});',
            '  --sp-text-$name-size: ${v['size']}px;',
            '  --sp-text-$name-line-height: ${v['lineHeight']}px;',
            '  --sp-text-$name-weight: ${v['weight']};',
            '  --sp-text-$name-letter-spacing: ${v['letterSpacing']}px;',
          ];
        }),
  ].join('\n');
  // Fixed brand and dark-palette values for surfaces that stay dark in both
  // modes (footer, CTA banners).
  final fixed = [
    ...Map<String, dynamic>.from(
      json['brand'],
    ).entries.map((e) => '  --sp-brand-${_kebab(e.key)}: ${e.value};'),
    ...dark.entries.map((e) => '  --sp-dark-${_kebab(e.key)}: ${e.value};'),
  ].join('\n');
  return '''/* GENERATED, DO NOT EDIT. Run: dart run tool/generate_theme.dart */
:root {
${vars(light)}
$fixed
$extras
}

@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
${vars(dark)}
  }
}

[data-theme="dark"] {
${vars(dark)}
}
''';
}

const _dartOut = 'lib/design_system/theme/app_tokens.g.dart';
const _cssOut = 'web_marketing/public/css/tokens.css';

void main() {
  final json =
      jsonDecode(File(_source).readAsStringSync()) as Map<String, dynamic>;
  File(_dartOut).writeAsStringSync(_flutter(json));
  File(_cssOut).writeAsStringSync(_css(json));
  // Format so regenerating is deterministic and matches committed output.
  final format = Process.runSync('dart', ['format', _dartOut]);
  if (format.exitCode != 0) {
    stderr.write(format.stderr);
    exit(format.exitCode);
  }
}
