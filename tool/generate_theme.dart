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
  final keys = light.keys.where((key) => key != 'shadow').toList();
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
''';
}

String _css(Map<String, dynamic> json) {
  final light = Map<String, dynamic>.from(json['light']);
  final dark = Map<String, dynamic>.from(json['dark']);
  final radius = Map<String, dynamic>.from(json['radius']);
  final spacing = Map<String, dynamic>.from(json['spacing']);
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
    '  --sp-font-display: ${json['fonts']['display']}, sans-serif;',
    '  --sp-font-body: ${json['fonts']['body']}, sans-serif;',
  ].join('\n');
  return '''/* GENERATED, DO NOT EDIT. Run: dart run tool/generate_theme.dart */
:root {
${vars(light)}
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

void main() {
  final json =
      jsonDecode(File(_source).readAsStringSync()) as Map<String, dynamic>;
  File(
    'lib/design_system/theme/app_tokens.g.dart',
  ).writeAsStringSync(_flutter(json));
  File('web_marketing/public/css/tokens.css').writeAsStringSync(_css(json));
}
