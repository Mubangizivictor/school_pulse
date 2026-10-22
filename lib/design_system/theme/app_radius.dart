import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_tokens.g.dart' as tokens;

/// Compatibility aliases backed by generated parent-theme radii.
class AppRadius {
  AppRadius._();
  static const double s = tokens.AppRadius.sm;
  static const double m = tokens.AppRadius.md;
  static const double l = tokens.AppRadius.lg;
  static const double xl = tokens.AppRadius.xl;
  static const double pill = tokens.AppRadius.pill;
  static BorderRadius get small => BorderRadius.circular(s);
  static BorderRadius get medium => BorderRadius.circular(m);
  static BorderRadius get large => BorderRadius.circular(l);
  static BorderRadius get extraLarge => BorderRadius.circular(xl);
  static BorderRadius get full => BorderRadius.circular(pill);
}
