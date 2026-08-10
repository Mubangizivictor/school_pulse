import 'package:flutter/material.dart';

class FeatureManagementScreen extends StatelessWidget {
  const FeatureManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060910),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Feature Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStatItem('Total Features', '32', const Color(0xFF312E81)),
                const SizedBox(width: 12),
                _buildStatItem('Enabled', '26', const Color(0xFF064E3B)),
                const SizedBox(width: 12),
                _buildStatItem('Disabled', '6', const Color(0xFF450A0A)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Search features...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildTab('All', active: true),
                _buildTab('Core Modules'),
                _buildTab('Add-ons'),
                _buildTab('Integrations'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildCategoryTitle('Core Modules'),
                _buildFeatureTile(
                  icon: Icons.school_outlined,
                  title: 'Student Management',
                  subtitle: 'Manage students and profiles',
                  color: const Color(0xFFA855F7),
                  enabled: true,
                ),
                _buildFeatureTile(
                  icon: Icons.how_to_reg_outlined,
                  title: 'Attendance',
                  subtitle: 'Track attendance and reports',
                  color: const Color(0xFF3B82F6),
                  enabled: true,
                ),
                _buildFeatureTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Finance',
                  subtitle: 'Fee management and billing',
                  color: const Color(0xFF10B981),
                  enabled: true,
                ),
                _buildFeatureTile(
                  icon: Icons.local_library_outlined,
                  title: 'Library',
                  subtitle: 'Library resources management',
                  color: const Color(0xFF6366F1),
                  enabled: true,
                ),
                _buildFeatureTile(
                  icon: Icons.directions_bus_outlined,
                  title: 'Transport',
                  subtitle: 'Transport and route management',
                  color: const Color(0xFFEF4444),
                  enabled: false,
                ),
                _buildCategoryTitle('Add-ons'),
                _buildFeatureTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Attendance',
                  subtitle: 'Fingerprint and face recognition',
                  color: const Color(0xFFF59E0B),
                  enabled: true,
                ),
                _buildFeatureTile(
                  icon: Icons.psychology_outlined,
                  title: 'AI Reports',
                  subtitle: 'AI-powered insights and analytics',
                  color: const Color(0xFFEC4899),
                  enabled: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, {bool active = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6366F1) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF6366F1),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool enabled,
  }) {
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
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
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (val) {},
            activeThumbColor: const Color(0xFF6366F1),
            activeTrackColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
