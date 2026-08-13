import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/data/models/user_model.dart';

/// Minimal admin-facing read view of another staff member's profile -
/// personal/employment/roles - reached from the Add Staff wizard's Success
/// screen. Distinct from staff_profile_screen.dart, which is a self-view
/// screen driven by the currently signed-in user.
class StaffDetailScreen extends StatelessWidget {
  final String uid;
  const StaffDetailScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const AdminAppBar(title: 'Staff Profile'),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: SchoolPulseLoader());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Staff member not found',
              message: 'This profile may have been removed.',
            );
          }
          final user = UserModel.fromJson({
            ...snapshot.data!.data()!,
            'id': uid,
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      AvatarInitials(name: user.name, size: 80),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.staffCode ?? '',
                        style: TextStyle(color: AppColors.textMuted(context)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        alignment: WrapAlignment.center,
                        children: user.roles
                            .map(
                              (r) => StatusBadge(
                                label: UserRoleDisplay.name(r),
                                color: AppColors.primary(context),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user.phoneNumber ?? '—',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employment Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.apartment_outlined,
                        label: 'School',
                        value: user.schoolName ?? '—',
                      ),
                      if (user.assignedClass != null)
                        _InfoRow(
                          icon: Icons.meeting_room_outlined,
                          label: 'Assigned Class',
                          value: user.assignedClass!,
                        ),
                      _InfoRow(
                        icon: Icons.circle,
                        label: 'Status',
                        value: user.isActive ? 'Active' : 'Inactive',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted(context)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
