import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 22.0;
  static const double pill = 999.0;

  static BorderRadius get small => BorderRadius.circular(s);
  static BorderRadius get medium => BorderRadius.circular(m);
  static BorderRadius get large => BorderRadius.circular(l);
  static BorderRadius get extraLarge => BorderRadius.circular(xl);
  static BorderRadius get full => BorderRadius.circular(pill);
}
