// Fails when School Pulse interface source introduces a colour outside the
// black/white/transparent policy. User-provided raster media is not Dart UI
// source and is intentionally outside this check.
import 'dart:io';

final _forbidden = <RegExp>[
  RegExp(r'\bColor\((?!0xFF000000\)|0xFFFFFFFF\))', caseSensitive: false),
  RegExp(r'\bColors\.(?!black\b|white\b|transparent\b)'),
  RegExp(r'\.(withOpacity|withValues)\s*\('),
  RegExp(r'\b(LinearGradient|RadialGradient|SweepGradient|MaterialColor)\b'),
  RegExp(r'BoxShadow\s*\('),
];

void main() {
  final violations = <String>[];
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final lines = entity.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      if (_forbidden.any((rule) => rule.hasMatch(lines[index]))) {
        violations.add('${entity.path}:${index + 1}: ${lines[index].trim()}');
      }
    }
  }
  if (violations.isEmpty) {
    stdout.writeln('Monochrome policy: passed.');
    return;
  }
  stderr.writeln('Monochrome policy: ${violations.length} violation(s).');
  for (final violation in violations) {
    stderr.writeln(violation);
  }
  exitCode = 1;
}
