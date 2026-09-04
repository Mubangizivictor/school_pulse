import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';

import '../widgets/super_admin_unsaved_changes_guard.dart';

/// Editable profile screen for the SaaS Owner, reached from the Account
/// tile on Settings. Mirrors the parent/staff EditProfileScreen's avatar
/// upload + form pattern, but writes only to `users/{uid}` — the platform
/// owner isn't a school contact, so the school_contacts side effect that
/// screen relies on is skipped for superAdmin in updateProfile.
class SuperAdminProfileScreen extends StatefulWidget {
  const SuperAdminProfileScreen({super.key});

  @override
  State<SuperAdminProfileScreen> createState() =>
      _SuperAdminProfileScreenState();
}

class _SuperAdminProfileScreenState extends State<SuperAdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  bool _uploadingPhoto = false;
  bool _dirty = false;
  String? _photoUrl;

  static final _phoneInputFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) =>
        RegExp(r'^\+?\d*$').hasMatch(newValue.text) ? newValue : oldValue,
  );

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;
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

  void _markDirty() {
    if (!_dirty && mounted) setState(() => _dirty = true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    final user = authState.user;
    final colors = Theme.of(context).colorScheme;

    if (!_initialized) {
      _nameController.text = user.name;
      _phoneController.text = user.phoneNumber ?? '';
      _photoUrl = user.photoUrl;
      _nameController.addListener(_markDirty);
      _phoneController.addListener(_markDirty);
      _initialized = true;
    }

    return SuperAdminUnsavedChangesGuard(
      hasUnsavedChanges: _dirty && !_saving && !_uploadingPhoto,
      message: 'Your profile changes have not been saved.',
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.information(context),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.informationSurface(context),
                        backgroundImage: _photoUrl?.isNotEmpty == true
                            ? NetworkImage(_photoUrl!)
                            : null,
                        child: _photoUrl?.isNotEmpty == true
                            ? null
                            : Text(
                                _initials(user.name),
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.information(context),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Material(
                        color: AppColors.information(context),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _uploadingPhoto ? null : _choosePhoto,
                          child: Tooltip(
                            message: 'Change profile picture',
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.surface,
                                  width: 3,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: _uploadingPhoto
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.surface,
                                      ),
                                    )
                                  : Icon(
                                      Icons.camera_alt_outlined,
                                      color: colors.surface,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text(
                  'Platform Owner',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PulseTextField(
                label: 'Full Name',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                isRequired: true,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter your full name.'
                    : null,
              ),
              const SizedBox(height: AppSpacing.m),
              PulseTextField(
                label: 'Email Address',
                controller: TextEditingController(text: user.email),
                prefixIcon: Icons.email_outlined,
                enabled: false,
              ),
              const SizedBox(height: AppSpacing.m),
              PulseTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                helperText: 'Use digits, optionally starting with +.',
                inputFormatters: [_phoneInputFormatter],
                validator: _validatePhone,
              ),
              const SizedBox(height: AppSpacing.xl),
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
                    phoneNumber: _phoneController.text.trim().isEmpty
                        ? null
                        : _phoneController.text.trim(),
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
                      setState(() => _dirty = false);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
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
    final XFile? image;
    if (kIsWeb) {
      // No camera / gallery sheet on web - just open the browser file
      // picker. maxWidth/maxHeight/imageQuality are also skipped: the web
      // resize path can silently return null in some browsers, which was
      // making "nothing happen" when a photo was chosen.
      try {
        image = await ImagePicker().pickImage(source: ImageSource.gallery);
      } catch (e) {
        _showPhotoError('Could not open the file picker. $e');
        return;
      }
    } else {
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
      image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
    }
    if (image == null || !mounted) return;
    _markDirty();

    // image_cropper's native crop UI (AndroidUiSettings / IOSUiSettings) is
    // a no-op on Flutter web and its sourcePath crop can resolve to null
    // there, which silently aborted the whole upload. On web, skip the
    // cropper and upload the picked image as-is; keep the square crop step
    // on mobile.
    final Uint8List bytes;
    if (kIsWeb) {
      bytes = await image.readAsBytes();
    } else {
      final cropped = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(title: 'Crop Photo', aspectRatioLockEnabled: true),
        ],
      );
      if (cropped == null || !mounted) return;
      bytes = await cropped.readAsBytes();
    }

    setState(() => _uploadingPhoto = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw StateError('You are not signed in.');
      final reference = FirebaseStorage.instance.ref(
        'profile_photos/$uid/profile.jpg',
      );
      await reference.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await reference.getDownloadURL();
      // set(merge:true), not update(): update() fails if users/{uid} does
      // not exist yet for this owner.
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'photoUrl': url},
        SetOptions(merge: true),
      );
      if (mounted) {
        setState(() => _photoUrl = url);
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    } on FirebaseException catch (e) {
      _showPhotoError(
        e.message == null || e.message!.isEmpty
            ? 'Could not upload the profile picture. (${e.code})'
            : '${e.message} (${e.code})',
      );
    } catch (e) {
      _showPhotoError('Could not upload the profile picture. $e');
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
