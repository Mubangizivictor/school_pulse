import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  bool _uploadingPhoto = false;
  String? _photoUrl;

  static final _phoneInputFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) =>
        RegExp(r'^\+?\d*$').hasMatch(newValue.text) ? newValue : oldValue,
  );

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Enter a phone number.';
    final digits = phone.replaceFirst('+', '');
    if (digits.length < 7 || digits.length > 15) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

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
      _photoUrl = user.photoUrl;
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: AppColors.primary(
                      context,
                    ).withValues(alpha: 0.12),
                    backgroundImage: _photoUrl?.isNotEmpty == true
                        ? NetworkImage(_photoUrl!)
                        : null,
                    child: _photoUrl?.isNotEmpty == true
                        ? null
                        : Text(
                            _initials(user.name),
                            style: TextStyle(
                              fontSize: 34,
                              color: AppColors.primary(context),
                            ),
                          ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: IconButton.filled(
                      tooltip: 'Change profile picture',
                      onPressed: _uploadingPhoto ? null : _choosePhoto,
                      icon: _uploadingPhoto
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.camera_alt_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            PulseTextField(
              label: 'Full Name',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
              isRequired: true,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter your full name.'
                  : null,
            ),
            const SizedBox(height: 16),
            PulseTextField(
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              isRequired: true,
              helperText: 'Use digits, optionally starting with +.',
              inputFormatters: [_phoneInputFormatter],
              validator: _validatePhone,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Save Changes',
              isLoading: _saving,
              onPressed: () async {
                if (!(_formKey.currentState?.validate() ?? false)) return;
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
                  photoUrl: _photoUrl,
                  studentIds: user.studentIds,
                  studentId: user.studentId,
                  assignedClass: user.assignedClass,
                  subjects: user.subjects,
                  isActive: user.isActive,
                  deactivationReason: user.deactivationReason,
                  mustChangePassword: user.mustChangePassword,
                  mfaEnabled: user.mfaEnabled,
                );
                final result = await sl<AuthRepository>().updateProfile(
                  updated,
                );
                if (!context.mounted) return;
                setState(() => _saving = false);
                result.fold(
                  (failure) => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(failure.message))),
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
      ),
    );
  }

  String _initials(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  Future<void> _choosePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final image = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw StateError('You are not signed in.');
      final bytes = await image.readAsBytes();
      final reference = FirebaseStorage.instance.ref(
        'profile_photos/$uid/profile.jpg',
      );
      await reference.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await reference.getDownloadURL();
      if (mounted) setState(() => _photoUrl = url);
    } on FirebaseException catch (e) {
      _showPhotoError(e.message ?? 'Could not upload the profile picture.');
    } catch (_) {
      _showPhotoError('Could not upload the profile picture.');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _showPhotoError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
