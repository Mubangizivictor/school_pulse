import 'package:flutter/material.dart';

class BrandingSettingsScreen extends StatelessWidget {
  const BrandingSettingsScreen({super.key});

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
          'Branding & Appearance',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionTitle('Platform Logos'),
          _buildLogoUploadTile(
            title: 'Primary Logo',
            subtitle: 'Used in the sidebar and dashboard (PNG/SVG)',
            icon: Icons.hexagon_outlined,
          ),
          _buildLogoUploadTile(
            title: 'Favicon',
            subtitle: 'Used in browser tabs and mobile icons',
            icon: Icons.grid_view_rounded,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Primary Colors'),
          _buildColorPickerTile('Brand Color', const Color(0xFF6366F1)),
          _buildColorPickerTile('Accent Color', const Color(0xFFA855F7)),
          _buildColorPickerTile('Success Color', const Color(0xFF22C55E)),
          _buildColorPickerTile('Danger Color', const Color(0xFFEF4444)),
          const SizedBox(height: 24),
          _buildSectionTitle('Theme Customization'),
          _buildThemeOptionTile(
            title: 'Dark Mode (Default)',
            subtitle: 'System-wide dark theme enabled',
            value: true,
          ),
          _buildThemeOptionTile(
            title: 'Custom Font Family',
            subtitle: 'Inter (Default)',
            value: false,
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Save Branding Changes',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6366F1),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildLogoUploadTile({
    required String title,
    required String subtitle,
    required IconData icon,
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
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFA855F7), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.file_upload_outlined, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildColorPickerTile(String title, Color color) {
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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            height: 24,
            width: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
            style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11, fontFamily: 'Monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptionTile({
    required String title,
    required String subtitle,
    required bool value,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {},
            activeColor: const Color(0xFF6366F1),
            activeTrackColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
