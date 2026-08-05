import 'package:flutter/material.dart';

class SecurityCenterScreen extends StatelessWidget {
  const SecurityCenterScreen({super.key});

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
          'Security Center',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildSecurityScoreCard(),
            const SizedBox(height: 24),
            const Text(
              'Security Overview',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            _buildSecurityOptionTile(
              icon: Icons.vpn_key_outlined,
              title: 'Two-Factor Authentication',
              subtitle: 'Required for all admins',
              statusText: 'Enabled',
              statusColor: const Color(0xFF22C55E),
            ),
            _buildSecurityOptionTile(
              icon: Icons.fingerprint_rounded,
              title: 'Passkey Authentication',
              subtitle: 'Enhanced login security',
              statusText: 'Enabled',
              statusColor: const Color(0xFF22C55E),
            ),
            _buildSecurityOptionTile(
              icon: Icons.security_outlined,
              title: 'Login Attempt Protection',
              subtitle: 'Brute-force protection active',
              statusText: 'Enabled',
              statusColor: const Color(0xFF22C55E),
            ),
            _buildSecurityOptionTile(
              icon: Icons.public_rounded,
              title: 'IP Whitelist',
              subtitle: 'Restricted IP access',
              statusText: 'Disabled',
              statusColor: const Color(0xFFEF4444),
            ),
            _buildSecurityOptionTile(
              icon: Icons.timer_outlined,
              title: 'Session Timeout',
              subtitle: 'Auto logout after inactivity',
              statusText: '30 min',
              statusColor: Colors.white,
            ),
            _buildSecurityOptionTile(
              icon: Icons.list_alt_rounded,
              title: 'Audit Logging',
              subtitle: 'All actions are being logged',
              statusText: 'Enabled',
              statusColor: const Color(0xFF22C55E),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Security Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  value: 0.92,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  color: const Color(0xFF22C55E),
                  strokeCap: StrokeCap.round,
                ),
              ),
              const Text(
                '92%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Excellent',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your platform security is strong',
                  style: TextStyle(color: Color(0x99FFFFFF), fontSize: 11),
                ),
                SizedBox(height: 8),
                Text(
                  'Last scan: Today, 8:30 AM',
                  style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String statusText,
    required Color statusColor,
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
              color: const Color(0xFFA855F7).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFA855F7), size: 22),
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
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (statusText == 'Enabled') ...[
                const SizedBox(width: 4),
                const Icon(Icons.check, color: Color(0xFF22C55E), size: 14),
              ],
              if (statusText == '30 min') ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.2),
                  size: 16,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
