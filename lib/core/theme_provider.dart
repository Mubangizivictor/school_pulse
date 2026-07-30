import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/admin/data/models/system_config.dart';
import '../features/branding/domain/entities/school_branding.dart';
import 'theme/branding_theme_engine.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  SystemConfig? _config;
  SystemConfig? get config => _config;

  SchoolBranding? _branding;
  SchoolBranding? get branding => _branding;

  static const _themeKey = 'theme_mode';
  static const _configKey = 'system_config';

  ThemeData get lightTheme => BrandingThemeEngine.createTheme(_branding, Brightness.light);
  ThemeData get darkTheme => BrandingThemeEngine.createTheme(_branding, Brightness.dark);

  Future<void> initialize() async {
    await Future.wait([
      _loadTheme(),
      _loadConfig(),
    ]);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString(_configKey);
    if (configJson != null) {
      try {
        _config = SystemConfig.fromMap(json.decode(configJson));
      } catch (e) {
        debugPrint('Error loading cached config: $e');
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> updateConfig(SystemConfig config) async {
    _config = config;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, json.encode(config.toMap()));
  }

  void updateBranding(SchoolBranding? branding) {
    _branding = branding;
    notifyListeners();
  }
}
