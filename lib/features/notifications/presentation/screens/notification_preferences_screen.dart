import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  final Map<String, bool> _preferences = {
    'Announcements': true,
    'Attendance': true,
    'Finance': true,
    'Transport': true,
    'Homework & Assignments': true,
    'Library': false,
    'Messages': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notification Preferences', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._preferences.keys.map((key) => _buildPreferenceTile(
                  key,
                  _getDescription(key),
                  _getIcon(key),
                  _getColor(key),
                  _preferences[key]!,
                )),
            const SizedBox(height: 32),
            const Text('Alert Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildActionTile('Push Notifications', 'Sound & Vibration'),
            _buildActionTile('Email Digest', 'Weekly'),
            _buildActionTile('SMS Alerts', 'Urgent Only'),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceTile(String title, String subtitle, IconData icon, Color color, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        trailing: Switch(
          value: value,
          onChanged: (val) => setState(() => _preferences[title] = val),
          activeColor: const Color(0xFF6366F1),
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          Row(
            children: [
              Text(value, style: const TextStyle(color: Colors.white60)),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white30),
            ],
          ),
        ],
      ),
    );
  }

  String _getDescription(String key) {
    switch (key) {
      case 'Announcements': return 'Receive all school announcements';
      case 'Attendance': return 'Alerts about attendance & absences';
      case 'Finance': return 'Fees, payments & receipts';
      case 'Transport': return 'Bus route & transport updates';
      case 'Homework & Assignments': return 'Homework, assignments & tasks';
      case 'Library': return 'Books, due dates & reminders';
      case 'Messages': return 'Direct messages from staff';
      default: return '';
    }
  }

  IconData _getIcon(String key) {
    switch (key) {
      case 'Announcements': return Icons.campaign;
      case 'Attendance': return Icons.person_pin_circle;
      case 'Finance': return Icons.payments;
      case 'Transport': return Icons.directions_bus;
      case 'Homework & Assignments': return Icons.assignment;
      case 'Library': return Icons.local_library;
      case 'Messages': return Icons.message;
      default: return Icons.notifications;
    }
  }

  Color _getColor(String key) {
    switch (key) {
      case 'Announcements': return const Color(0xFF6366F1);
      case 'Attendance': return const Color(0xFF10B981);
      case 'Finance': return const Color(0xFFF59E0B);
      case 'Transport': return const Color(0xFF3B82F6);
      case 'Homework & Assignments': return const Color(0xFFEC4899);
      case 'Library': return const Color(0xFF06B6D4);
      case 'Messages': return const Color(0xFF8B5CF6);
      default: return Colors.white60;
    }
  }
}
