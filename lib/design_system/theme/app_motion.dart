import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve curve = Curves.easeInOutCubic;
}
