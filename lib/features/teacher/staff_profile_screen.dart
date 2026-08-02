import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/services/staff_id_card_service.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key});

  Future<void> _printIdCard(BuildContext context, UserEntity user) async {
    final idCardService = GetIt.I<StaffIdCardService>();
    // Assuming school name from context or a constant for UI purposes
    const schoolName = 'School Pulse Academy';
    try {
      final pdfData = await idCardService.generateStaffIdCardPdf(
        schoolName: schoolName,
        staffName: user.name,
        staffCode: user.staffCode ?? user.id,
        roleLabel: user.role.name,
      );
      await idCardService.printIdCard(pdfData);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to print ID card: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            backgroundColor: Color(0xFF070914),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = state.user;

        return Scaffold(
          backgroundColor: const Color(0xFF070914),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'My Profile',
              style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.badge_outlined, color: Color(0xFF3B82F6)),
                tooltip: 'Print Staff ID Card',
                onPressed: () => _printIdCard(context, user),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.role.name,
                  style: AppTypography.bodyMedium.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildInfoSection('PERSONAL INFORMATION', [
                  _ProfileInfoItem(label: 'Full Name', value: user.name),
                  _ProfileInfoItem(label: 'Email Address', value: user.email),
                  _ProfileInfoItem(label: 'Phone Number', value: user.phoneNumber ?? '—'),
                ]),
                
                const SizedBox(height: 24),
                _buildInfoSection('WORK INFORMATION', [
                  _ProfileInfoItem(label: 'Staff ID', value: user.staffCode ?? user.id),
                  if (user.assignedClass != null) _ProfileInfoItem(label: 'Primary Class', value: user.assignedClass!),
                  _ProfileInfoItem(label: 'Date Joined', value: 'Aug 12, 2022'),
                ]),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFF64748B),
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151929),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: const Color(0xFF64748B)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
