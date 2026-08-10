import 'package:flutter/material.dart';

class PlanSettingsScreen extends StatelessWidget {
  const PlanSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060910),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Configure default settings for plans',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  _buildSettingItem(
                    'Default Trial Period',
                    'Set default trial period for new schools',
                    '14 days',
                    Icons.timer_outlined,
                    const Color(0xFF3B82F6),
                  ),
                  _buildSettingItem(
                    'Currency',
                    'Set default currency for all plans',
                    'UGX',
                    Icons.payments_outlined,
                    const Color(0xFF10B981),
                  ),
                  _buildSettingItem(
                    'Tax Settings',
                    'Configure tax rates and rules',
                    null,
                    Icons.receipt_long_outlined,
                    const Color(0xFF8B5CF6),
                  ),
                  _buildSettingItem(
                    'Grace Period',
                    'Set payment grace period',
                    '7 days',
                    Icons.history_rounded,
                    const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchSetting(
                    'Auto Suspend',
                    'Automatically suspend after due date',
                    true,
                    Icons.block_flipped,
                    const Color(0xFFEF4444),
                  ),
                  _buildSwitchSetting(
                    'Plan Upgrade',
                    'Allow schools to upgrade plans',
                    true,
                    Icons.upgrade_outlined,
                    const Color(0xFF6366F1),
                  ),
                  _buildSwitchSetting(
                    'Plan Downgrade',
                    'Allow schools to downgrade plans',
                    false,
                    Icons.file_download_outlined,
                    const Color(0xFFA855F7),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingItem(
                    'Cancellation Policy',
                    'Configure cancellation rules',
                    null,
                    Icons.cancel_outlined,
                    const Color(0xFFF43F5E),
                  ),
                  _buildSettingItem(
                    'Refund Policy',
                    'Configure refund rules',
                    null,
                    Icons.replay_rounded,
                    const Color(0xFFF97316),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            'Plans Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    String? value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (value != null)
            Text(
              value,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {},
            activeThumbColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }
}
