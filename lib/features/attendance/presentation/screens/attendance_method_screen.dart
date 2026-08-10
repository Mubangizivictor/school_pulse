import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_access_context.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_category.dart';
import 'package:school_pulse/features/attendance_hub/domain/repositories/sheets_integration_repository.dart';
import 'package:school_pulse/features/attendance_hub/domain/services/attendance_participant_resolver.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

class AttendanceMethodScreen extends StatefulWidget {
  const AttendanceMethodScreen({super.key});

  @override
  State<AttendanceMethodScreen> createState() => _AttendanceMethodScreenState();
}

// category.label ('Meals/Food', etc.) already matches the bottom-sheet copy
// this screen used before the dropdown became resolver-driven, so labels
// are read straight from AttendanceCategory rather than re-declared here.
const Map<AttendanceCategory, String> _kCategoryLabels = {
  AttendanceCategory.students: 'Students',
  AttendanceCategory.staff: 'Staff',
  AttendanceCategory.gate: 'Gate',
  AttendanceCategory.meals: 'Meals/Food',
  AttendanceCategory.library: 'Library',
  AttendanceCategory.transport: 'Transport',
  AttendanceCategory.visitors: 'Visitors',
  AttendanceCategory.hostel: 'Hostel',
  AttendanceCategory.custom: 'Custom',
};

class _AttendanceMethodScreenState extends State<AttendanceMethodScreen> {
  AttendanceCategory? _selectedCategory;
  bool _sheetsLinked = false;
  bool _loadingAccess = true;
  AttendanceAccessContext? _access;

  @override
  void initState() {
    super.initState();
    _loadAccess();
    _loadSheetsStatus();
  }

  // Resolves what this operator may actually do before the dropdown shows
  // anything, per the spec's "Attendance For must not always contain every
  // domain - dynamically show only domains the current user is authorized
  // to manage." An empty result is a real state (no responsibility
  // assigned), not an error - handled in _buildBody, never a silent
  // fallback to every category.
  Future<void> _loadAccess() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      setState(() => _loadingAccess = false);
      return;
    }
    final result = await di.sl<AttendanceParticipantResolver>().resolve(
      authState.user,
    );
    if (!mounted) return;
    setState(() {
      _access = result.fold((_) => null, (access) => access);
      _loadingAccess = false;
      final domains = _access?.allowedDomains ?? const {};
      // Auto-select when exactly one domain is authorised, per spec step 6
      // ("Auto-select if only one option exists").
      if (domains.length == 1) {
        _selectedCategory = domains.first;
      } else if (domains.contains(AttendanceCategory.students)) {
        _selectedCategory = AttendanceCategory.students;
      } else if (domains.isNotEmpty) {
        _selectedCategory = domains.first;
      }
    });
  }

  Future<void> _loadSheetsStatus() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final result = await di
        .sl<SheetsIntegrationRepository>()
        .getIntegration(authState.user.schoolId);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _sheetsLinked = false),
      (integration) => setState(() => _sheetsLinked = integration.linked),
    );
  }

  void _showTypeSelector() {
    final domains = _access?.allowedDomains.toList() ?? const [];
    if (domains.isEmpty) return;
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
            itemCount: domains.length,
            itemBuilder: (context, index) {
              final category = domains[index];
              return ListTile(
                title: Text(
                  _kCategoryLabels[category] ?? category.label,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: _selectedCategory == category
                    ? const Icon(Icons.check, color: Color(0xFF176BFF))
                    : null,
                onTap: () {
                  setState(() => _selectedCategory = category);
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
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loadingAccess) {
      return const Center(child: SchoolPulseLoader());
    }

    final domains = _access?.allowedDomains ?? const {};
    if (domains.isEmpty) {
      // Per spec: an operator with no active attendance responsibility must
      // never fall back to seeing every category - show the empty state and
      // stop, rather than rendering method cards with nothing to scope them.
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              const Text(
                'No attendance group has been assigned to your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Contact your Institution Administrator.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final selectedLabel = _selectedCategory != null
        ? (_kCategoryLabels[_selectedCategory!] ?? _selectedCategory!.label)
        : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          // Main Title
          Text(
            'Attendance',
            style: AppTypography.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 14),

          // Dropdown Section Card - only shown when there's an actual
          // choice to make (multiple authorised domains); a single-domain
          // operator was already auto-selected in _loadAccess.
          if (domains.length > 1)
            InkWell(
              onTap: _showTypeSelector,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF071229),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1A315B)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF103ECF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.people_alt_rounded,
                          color: Color(0xFF176BFF), size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Attendance for',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // The Dropdown Button UI
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1B3B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1A315B)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF8190AA), size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 14),

          // NFC Card
          _MethodCard(
            title: 'NFC Scan',
            accentColor: const Color(0xFF11A85B),
            icon: Icons.sensors_rounded,
            onTap: () => context.push('/staff/attendance/nfc'),
          ),

          // QR Code Card
          _MethodCard(
            title: 'QR Code Scanner',
            accentColor: const Color(0xFF103ECF),
            icon: Icons.qr_code_2_rounded,
            onTap: () => context.push('/staff/attendance/qr'),
          ),

          // Manual Card
          _MethodCard(
            title: 'Manual Attendance',
            accentColor: const Color(0xFFFFB400),
            icon: Icons.assignment_turned_in_rounded,
            onTap: () => context.push(
              '/staff/attendance/manual',
              extra: _selectedCategory,
            ),
          ),

          // History Card
          _MethodCard(
            title: 'Previous Attendances',
            accentColor: const Color(0xFF7C4DFF),
            icon: Icons.history_rounded,
            onTap: () => context.push('/staff/attendance/history'),
          ),

          // Google Sheets Card
          _IntegrationCard(
            title: 'Google Sheets',
            linked: _sheetsLinked,
            onTap: () async {
              await context.push('/staff/attendance/sheets');
              _loadSheetsStatus();
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final String title;
  final Color accentColor;
  final IconData icon;
  final VoidCallback onTap;

  const _MethodCard({
    required this.title,
    required this.accentColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF071229),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1A315B)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(width: 3, color: accentColor),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withOpacity(0.15),
                        ),
                        child: Icon(icon, color: accentColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFF8190AA), size: 20),
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
  final bool linked;
  final VoidCallback onTap;

  const _IntegrationCard({
    required this.title,
    required this.linked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        linked ? const Color(0xFF11A85B) : const Color(0xFF8190AA);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF071229),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1A315B)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withOpacity(0.15),
              ),
              child: Icon(Icons.description_rounded,
                  color: statusColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
                linked
                    ? Icons.check_circle_rounded
                    : Icons.link_off_rounded,
                color: statusColor,
                size: 16),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF8190AA), size: 20),
          ],
        ),
      ),
    );
  }
}
