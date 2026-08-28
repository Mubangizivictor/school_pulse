import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(body: Center(child: SchoolPulseLoader()));
        }
        final parentName = state.user.name;
        final parentPhone = state.user.phoneNumber ?? '—';
        final parentEmail = state.user.email.isNotEmpty
            ? state.user.email
            : '—';

        return Scaffold(
          backgroundColor: AppColors.background(context),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                children: [
                  _buildProfileHero(context, parentName, state.user.photoUrl),
                  const SizedBox(height: 32),
                  _sectionLabel(context, 'CONTACT DETAILS'),
                  const SizedBox(height: 12),
                  _buildInfoCard(context, [
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone Number',
                      value: parentPhone,
                    ),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: parentEmail,
                    ),
                  ]),
                  const SizedBox(height: 32),
                  _sectionLabel(context, 'CONNECTED STUDENTS'),
                  const SizedBox(height: 12),
                  BlocBuilder<StudentsBloc, StudentsState>(
                    builder: (context, studentsState) {
                      if (studentsState is! StudentsLoaded ||
                          studentsState.students.isEmpty) {
                        return EmptyState(
                          icon: Icons.person_off_outlined,
                          title: 'No linked students',
                          message:
                              'Children linked to your account will appear here.',
                        );
                      }
                      return Column(
                        children: studentsState.students
                            .map(
                              (student) => _buildStudentTile(context, student),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHero(
    BuildContext context,
    String name,
    String? photoUrl,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context), width: 1.25),
      ),
      child: Column(
        children: [
          _buildAvatar(context, name, photoUrl),
          const SizedBox(height: 14),
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Parent account',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String name, String? photoUrl) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return GestureDetector(
      onTap: () => context.push('/parent/profile/edit'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border(context),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.surfaceContainerHigh(context),
              backgroundImage: photoUrl?.isNotEmpty == true
                  ? NetworkImage(photoUrl!)
                  : null,
              child: photoUrl?.isNotEmpty == true
                  ? null
                  : Text(
                      initials,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textPrimary(context),
                border: Border.all(
                  color: AppColors.background(context),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 14,
                color: AppColors.background(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColors.textMuted(context),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<_InfoRow> rows) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      showShadow: false,
      color: AppColors.surfaceContainer(context),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final idx = entry.key;
          final row = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: row,
              ),
              if (idx < rows.length - 1)
                Divider(height: 1, color: AppColors.border(context)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStudentTile(BuildContext context, Student student) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      showShadow: false,
      color: AppColors.surfaceContainer(context),
      child: Row(
        children: [
          AvatarInitials(name: student.name, size: 44),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  student.className.isNotEmpty
                      ? student.className
                      : 'No class assigned',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          if (student.studentCode.isNotEmpty)
            Text(
              student.studentCode,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted(context),
              ),
            ),
        ],
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
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted(context)),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted(context),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}
