import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:intl/intl.dart';
import '../../../../features/catering/presentation/screens/meal_card_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: BlocBuilder<SelectedStudentBloc, SelectedStudentState>(
        builder: (context, state) {
          if (state is! SelectedStudentLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final student = state.student;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    Hero(
                      tag: 'student_avatar_${student.id}',
                      child: AvatarInitials(name: student.name, size: 100),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Student Code: ${student.studentCode}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(context, 'Academic Information', [
                _buildInfoTile(context, 'Admission Number', student.admissionNumber),
                _buildInfoTile(context, 'Class', student.classId),
                _buildInfoTile(context, 'Education Level', student.level.name.toUpperCase()),
                if (student.streamId != null) _buildInfoTile(context, 'Stream', student.streamId!),
              ]),
              const SizedBox(height: 24),
              _buildSection(context, 'Personal Details', [
                _buildInfoTile(context, 'Date of Birth', DateFormat('dd MMMM yyyy').format(student.dateOfBirth)),
                _buildInfoTile(context, 'Gender', student.gender.name.toUpperCase()),
                if (student.medicalInfo?.bloodGroup != null)
                  _buildInfoTile(context, 'Blood Group', student.medicalInfo!.bloodGroup!),
              ]),
              const SizedBox(height: 24),
              if (student.dormLeadershipRole != null) ...[
                _buildSection(context, 'Dorm Leadership', [
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: Text(student.dormLeadershipRole!),
                    subtitle: student.dormLeadershipDormName != null
                        ? Text(student.dormLeadershipDormName!)
                        : null,
                  ),
                ]),
                const SizedBox(height: 24),
              ],
              if (student.emergencyContacts.isNotEmpty)
                _buildSection(context, 'Emergency Contacts',
                  student.emergencyContacts.map((c) => _buildInfoTile(context, c.relationship, '${c.name} (${c.phoneNumber})')).toList(),
                ),
              const SizedBox(height: 24),
              AppCard(
                child: ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: const Text('My Meal Card'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealCardScreen(
                          studentName: student.name,
                          studentCode: student.studentCode,
                          classId: student.classId,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to password change screen
                  },
                ),
              ),
              const SizedBox(height: 48),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    return ListTile(
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
    );
  }
}
