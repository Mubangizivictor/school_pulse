import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    final user = authState.user;

    if (!_initialized) {
      _nameController.text = user.name;
      _phoneController.text = user.phoneNumber ?? '';
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PulseTextField(
            label: 'Full Name',
            controller: _nameController,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          PulseTextField(
            label: 'Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Save Changes',
            isLoading: _saving,
            onPressed: () async {
              setState(() => _saving = true);
              final updated = UserEntity(
                id: user.id,
                staffCode: user.staffCode,
                name: _nameController.text.trim(),
                email: user.email,
                schoolId: user.schoolId,
                schoolName: user.schoolName,
                phoneNumber: _phoneController.text.trim(),
                roles: user.roles,
                photoUrl: user.photoUrl,
                studentIds: user.studentIds,
                studentId: user.studentId,
                assignedClass: user.assignedClass,
                subjects: user.subjects,
                isActive: user.isActive,
                deactivationReason: user.deactivationReason,
                mustChangePassword: user.mustChangePassword,
                mfaEnabled: user.mfaEnabled,
              );
              final result = await sl<AuthRepository>().updateProfile(updated);
              if (!context.mounted) return;
              setState(() => _saving = false);
              result.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(failure.message)),
                ),
                (_) {
                  context.read<AuthBloc>().add(AuthCheckRequested());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated')),
                  );
                  context.pop();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
