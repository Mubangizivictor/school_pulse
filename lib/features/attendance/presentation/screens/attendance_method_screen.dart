import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_category.dart';

class AttendanceMethodScreen extends StatefulWidget {
  const AttendanceMethodScreen({super.key});

  @override
  State<AttendanceMethodScreen> createState() => _AttendanceMethodScreenState();
}

class _AttendanceMethodScreenState extends State<AttendanceMethodScreen> {
  String selectedType = 'Students';
  final List<String> attendanceTypes = [
    'Students',
    'Staff',
    'Gate',
    'Meals/Food',
    'Library',
    'Transport',
    'Visitors',
    'Hostel',
    'Custom',
  ];

  AttendanceCategory get _selectedCategory {
    switch (selectedType) {
      case 'Students':
        return AttendanceCategory.students;
      case 'Staff':
        return AttendanceCategory.staff;
      case 'Gate':
        return AttendanceCategory.gate;
      case 'Meals/Food':
        return AttendanceCategory.meals;
      case 'Library':
        return AttendanceCategory.library;
      case 'Transport':
        return AttendanceCategory.transport;
      case 'Visitors':
        return AttendanceCategory.visitors;
      case 'Hostel':
        return AttendanceCategory.hostel;
      default:
        return AttendanceCategory.custom;
    }
  }

  void _showTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF071229),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: attendanceTypes.length,
            itemBuilder: (context, index) {
              final type = attendanceTypes[index];
              return ListTile(
                title: Text(
                  type,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: selectedType == type
                    ? const Icon(Icons.check, color: Color(0xFF176BFF))
                    : null,
                onTap: () {
                  setState(() => selectedType = type);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010818), // Deepest navy
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Main Title
              Text(
                'Attendance',
                style: AppTypography.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 34,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              // Subtitle
              Text(
                'Choose attendance type and method',
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF8190AA),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Dropdown Section Card
              InkWell(
                onTap: _showTypeSelector,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071229),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1A315B)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF103ECF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.people_alt_rounded,
                            color: Color(0xFF176BFF), size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'What are you taking attendance for?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Select the category you want to take attendance for.',
                              style: TextStyle(
                                color: Color(0xFF8190AA),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // The Dropdown Button UI
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1B3B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1A315B)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_pin_circle_outlined,
                                color: Color(0xFF176BFF), size: 20),
                            const SizedBox(width: 10),
                            Text(
                              selectedType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF8190AA), size: 22),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),
              const Text(
                'Choose Attendance Method',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 18),

              // NFC Card
              _MethodCard(
                title: 'NFC Scan',
                subtitle:
                    'Tap student ID card on NFC reader\nto mark attendance instantly.',
                badgeLabel: 'Fast & Secure',
                badgeIcon: Icons.bolt_rounded,
                accentColor: const Color(0xFF11A85B),
                icon: Icons.sensors_rounded,
                onTap: () => context.push('/staff/attendance/nfc'),
              ),

              // QR Code Card
              _MethodCard(
                title: 'QR Code Scanner',
                subtitle: 'Scan student QR code to\nmark attendance.',
                badgeLabel: 'Quick & Easy',
                badgeIcon: Icons.bolt_rounded,
                accentColor: const Color(0xFF103ECF),
                icon: Icons.qr_code_2_rounded,
                onTap: () => context.push('/staff/attendance/qr'),
              ),

              // Manual Card
              _MethodCard(
                title: 'Manual Attendance',
                subtitle: 'Select students manually from\nthe list to mark attendance.',
                badgeLabel: 'Classic Method',
                badgeIcon: Icons.person_search_rounded,
                accentColor: const Color(0xFFFFB400),
                icon: Icons.assignment_turned_in_rounded,
                onTap: () => context.push(
                  '/staff/attendance/manual',
                  extra: _selectedCategory,
                ),
              ),

              // History Card
              _MethodCard(
                title: 'View Previous Attendances',
                subtitle: 'View and manage previously taken\nattendance records.',
                accentColor: const Color(0xFF7C4DFF),
                icon: Icons.history_rounded,
                onTap: () => context.push('/staff/attendance/history'),
              ),

              // Google Sheets Card
              _IntegrationCard(
                title: 'Google Sheets Integration',
                subtitle:
                    'Export and sync attendance records\nto Google Sheets automatically.',
                statusLabel: 'Linked',
                onTap: () => context.push('/staff/attendance/sheets'),
              ),

              // Safety Information Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF071229),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1A315B)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF176BFF).withOpacity(0.6),
                            width: 2),
                      ),
                      child: const Icon(Icons.info_outline_rounded,
                          color: Color(0xFF176BFF), size: 28),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'All attendance records are safe',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Records are securely saved and synced\nacross all your devices.',
                            style: TextStyle(
                              color: Color(0xFF8190AA),
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.cloud_upload_rounded,
                        color: Color(0xFF176BFF), size: 36),
                  ],
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeLabel;
  final IconData? badgeIcon;
  final Color accentColor;
  final IconData icon;
  final VoidCallback onTap;

  const _MethodCard({
    required this.title,
    required this.subtitle,
    this.badgeLabel,
    this.badgeIcon,
    required this.accentColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF071229),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A315B)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: accentColor.withOpacity(0.3), width: 1),
                          gradient: RadialGradient(
                            colors: [
                              accentColor.withOpacity(0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Icon(icon, color: accentColor, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Color(0xFF8190AA),
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                            if (badgeLabel != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF020716),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: accentColor.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(badgeIcon,
                                        color: accentColor, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      badgeLabel!,
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFF8190AA), size: 26),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusLabel;
  final VoidCallback onTap;

  const _IntegrationCard({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF071229),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A315B)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF11A85B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_rounded,
                color: Color(0xFF11A85B), size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8190AA),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF11A85B).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFF11A85B).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF11A85B), size: 16),
                const SizedBox(width: 6),
                Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Color(0xFF11A85B),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFF8190AA), size: 26),
        ],
      ),
    );
  }
}
