import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/app_components.dart';

/// The class teacher's own device-local attendance defaults.
///
/// Deliberately per-device rather than synced to the school: these are
/// preferences about how one teacher likes to take attendance, not a
/// school-wide policy, so there is nothing here worth a server round trip.
class AttendanceSettingsScreen extends StatefulWidget {
  const AttendanceSettingsScreen({super.key});

  @override
  State<AttendanceSettingsScreen> createState() =>
      _AttendanceSettingsScreenState();
}

enum _DefaultMethod { nfc, qr, manual }

class _AttendanceSettingsScreenState extends State<AttendanceSettingsScreen> {
  static const _keyMethod = 'attendance_settings.default_method';
  static const _keyReminder = 'attendance_settings.reminder_enabled';
  static const _keyReminderTime = 'attendance_settings.reminder_time';

  _DefaultMethod _method = _DefaultMethod.manual;
  bool _reminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 30);
  bool _loading = true;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final methodName = prefs.getString(_keyMethod);
    final minutes = prefs.getInt(_keyReminderTime);
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _method = _DefaultMethod.values.firstWhere(
        (m) => m.name == methodName,
        orElse: () => _DefaultMethod.manual,
      );
      _reminderEnabled = prefs.getBool(_keyReminder) ?? true;
      if (minutes != null) {
        _reminderTime = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
      }
      _loading = false;
    });
  }

  Future<void> _setMethod(_DefaultMethod method) async {
    setState(() => _method = method);
    await _prefs?.setString(_keyMethod, method.name);
  }

  Future<void> _setReminderEnabled(bool value) async {
    setState(() => _reminderEnabled = value);
    await _prefs?.setBool(_keyReminder, value);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(context: context, initialTime: _reminderTime);
    if (picked == null) return;
    setState(() => _reminderTime = picked);
    await _prefs?.setInt(_keyReminderTime, picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Attendance Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SectionHeader(title: 'Default Method'),
                const SizedBox(height: 8),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _methodTile(
                        'NFC Scan',
                        'Mark attendance using NFC card',
                        Icons.nfc,
                        _DefaultMethod.nfc,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _methodTile(
                        'QR Code Scanner',
                        'Scan student QR code',
                        Icons.qr_code_scanner,
                        _DefaultMethod.qr,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _methodTile(
                        'Manual Attendance',
                        'Mark attendance manually',
                        Icons.checklist,
                        _DefaultMethod.manual,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Reminder'),
                const SizedBox(height: 8),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        value: _reminderEnabled,
                        onChanged: _setReminderEnabled,
                        title: const Text('Daily reminder'),
                        subtitle: const Text('Get nudged if attendance is not taken'),
                      ),
                      if (_reminderEnabled) ...[
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          title: const Text('Remind me at'),
                          trailing: Text(
                            _reminderTime.format(context),
                            style: TextStyle(
                              color: AppColors.primary(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: _pickReminderTime,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _methodTile(
    String title,
    String subtitle,
    IconData icon,
    _DefaultMethod method,
  ) {
    final selected = _method == method;
    return RadioListTile<_DefaultMethod>.adaptive(
      value: method,
      groupValue: _method,
      onChanged: (m) => _setMethod(m!),
      secondary: Icon(icon, color: selected ? AppColors.primary(context) : null),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
