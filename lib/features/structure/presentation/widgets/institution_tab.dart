import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_event.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/institution_profile.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';

/// The Institution tab's content, embedded directly inside the Structure
/// hub (no separate profile screen/route) - one continuous scrollable form
/// matching the compact enterprise-panel reference layout.
class InstitutionTab extends StatefulWidget {
  const InstitutionTab({super.key, this.wizardMode = false});

  /// Step 1 has a deliberately focused mobile layout. The same editor is
  /// still available in the management area without changing that surface.
  final bool wizardMode;

  @override
  State<InstitutionTab> createState() => InstitutionTabState();
}

class InstitutionTabState extends State<InstitutionTab> {
  final _formKey = GlobalKey<_InstitutionFormState>();

  /// Asks to save/discard/cancel if the embedded form has unsaved edits.
  /// Returns true when it is safe for the caller to navigate away.
  Future<bool> confirmDiscardIfDirty(BuildContext context) async {
    final formState = _formKey.currentState;
    if (formState == null) return true;
    return formState.confirmDiscardIfDirty(context);
  }

  /// Saves unsaved, valid edits in place. Returns false when the form is
  /// dirty but fails validation, so the caller can keep the admin here.
  Future<bool> saveIfDirty() async {
    final formState = _formKey.currentState;
    if (formState == null) return true;
    return formState.saveIfDirty();
  }

  /// Validates the wizard's required Step 1 fields before moving ahead.
  Future<bool> saveAndValidateForContinue() async {
    final formState = _formKey.currentState;
    if (formState == null) return false;
    return formState.saveAndValidateForContinue();
  }

  /// Saves whatever is currently filled in without enforcing required-field
  /// validation, so an incomplete Step 1 can still be saved as a draft.
  Future<void> saveDraft() async {
    final formState = _formKey.currentState;
    if (formState == null) return;
    return formState.saveDraft();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) => _InstitutionForm(
        key: _formKey,
        profile: state.institutionProfile,
        wizardMode: widget.wizardMode,
      ),
    );
  }
}

class _InstitutionForm extends StatefulWidget {
  const _InstitutionForm({
    super.key,
    required this.profile,
    required this.wizardMode,
  });
  final InstitutionProfile profile;
  final bool wizardMode;

  @override
  State<_InstitutionForm> createState() => _InstitutionFormState();
}

class _InstitutionFormState extends State<_InstitutionForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _shortName;
  late final TextEditingController _motto;
  late final TextEditingController _vision;
  late final TextEditingController _mission;
  late String _logoUrl;
  late String _badgeUrl;
  bool _isUploadingLogo = false;
  bool _isUploadingBadge = false;
  late String _schoolType;
  late String _schoolCategory;
  late final TextEditingController _registrationNumber;
  late final TextEditingController _ministryRegistrationNumber;
  late final TextEditingController _taxNumber;
  late final TextEditingController _countryText;
  late String _country;
  late String _district;
  late final TextEditingController _districtText;
  late final TextEditingController _city;
  late final TextEditingController _address;
  late final TextEditingController _gpsLat;
  late final TextEditingController _gpsLng;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _website;

  static const _timeZone = 'Africa/Kampala';
  static const _currency = 'UGX';
  static const _language = 'English';
  static const _dateFormat = 'dd/MM/yyyy';
  static const _timeFormat = '24-hour';

  bool _isSaving = false;
  bool _isDirty = false;

  late final List<TextEditingController> _textControllers;

  static const _schoolTypes = [
    'Nursery',
    'Primary',
    'Secondary',
    'Mixed school',
    'Vocational',
    'College',
    'University',
  ];
  static const _schoolCategories = [
    'Government',
    'Private',
    'Community',
    'Faith-based',
    'International',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = TextEditingController(text: p.name);
    _shortName = TextEditingController(text: p.shortName);
    _motto = TextEditingController(text: p.motto);
    _vision = TextEditingController(text: p.vision);
    _mission = TextEditingController(text: p.mission);
    _logoUrl = p.logoUrl;
    _badgeUrl = p.badgeUrl;
    _schoolType = p.schoolType;
    _schoolCategory = p.schoolCategory;
    _registrationNumber = TextEditingController(text: p.registrationNumber);
    _ministryRegistrationNumber = TextEditingController(
      text: p.ministryRegistrationNumber,
    );
    _taxNumber = TextEditingController(text: p.taxNumber);
    _country = p.country;
    _countryText = TextEditingController(text: _country);
    _district = p.district;
    _districtText = TextEditingController(text: p.district);
    _city = TextEditingController(text: p.city);
    _address = TextEditingController(text: p.address);
    _gpsLat = TextEditingController(text: p.gpsLat?.toString() ?? '');
    _gpsLng = TextEditingController(text: p.gpsLng?.toString() ?? '');
    _phone = TextEditingController(text: p.phone);
    _email = TextEditingController(text: p.email);
    _website = TextEditingController(text: p.website);

    _textControllers = [
      _name,
      _shortName,
      _motto,
      _vision,
      _mission,
      _registrationNumber,
      _ministryRegistrationNumber,
      _taxNumber,
      _countryText,
      _districtText,
      _city,
      _address,
      _gpsLat,
      _gpsLng,
      _phone,
      _email,
      _website,
    ];
    for (final c in _textControllers) {
      c.addListener(_markDirty);
    }
  }

  @override
  void didUpdateWidget(covariant _InstitutionForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The live watchInstitutionProfile stream can re-emit after a save
    // completes; only resync fields when we're not mid-edit/mid-save so we
    // never clobber the admin's in-progress typing.
    if (!_isDirty && !_isSaving && oldWidget.profile != widget.profile) {
      _resync(widget.profile);
    }
  }

  void _resync(InstitutionProfile p) {
    _name.text = p.name;
    _shortName.text = p.shortName;
    _motto.text = p.motto;
    _vision.text = p.vision;
    _mission.text = p.mission;
    _registrationNumber.text = p.registrationNumber;
    _ministryRegistrationNumber.text = p.ministryRegistrationNumber;
    _taxNumber.text = p.taxNumber;
    _countryText.text = p.country;
    _districtText.text = p.district;
    _city.text = p.city;
    _address.text = p.address;
    _gpsLat.text = p.gpsLat?.toString() ?? '';
    _gpsLng.text = p.gpsLng?.toString() ?? '';
    _phone.text = p.phone;
    _email.text = p.email;
    _website.text = p.website;
    setState(() {
      _logoUrl = p.logoUrl;
      _badgeUrl = p.badgeUrl;
      _schoolType = p.schoolType;
      _schoolCategory = p.schoolCategory;
      _country = p.country;
      _district = p.district;
    });
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  @override
  void dispose() {
    for (final c in _textControllers) {
      c.dispose();
    }
    super.dispose();
  }

  InstitutionProfile _buildProfile() => widget.profile.copyWith(
    name: _name.text.trim(),
    shortName: _shortName.text.trim(),
    motto: _motto.text.trim(),
    vision: _vision.text.trim(),
    mission: _mission.text.trim(),
    logoUrl: _logoUrl,
    badgeUrl: _badgeUrl,
    schoolType: _schoolType,
    schoolCategory: _schoolCategory,
    registrationNumber: _registrationNumber.text.trim(),
    ministryRegistrationNumber: _ministryRegistrationNumber.text.trim(),
    taxNumber: _taxNumber.text.trim(),
    country: widget.wizardMode ? _countryText.text.trim() : _country,
    district: widget.wizardMode ? _districtText.text.trim() : _district,
    city: _city.text.trim(),
    address: _address.text.trim(),
    gpsLat: double.tryParse(_gpsLat.text),
    gpsLng: double.tryParse(_gpsLng.text),
    phone: _phone.text.trim(),
    email: _email.text.trim(),
    website: _website.text.trim(),
    timeZone: _timeZone,
    currency: _currency,
    language: _language,
    dateFormat: _dateFormat,
    timeFormat: _timeFormat,
  );

  Future<void> _save({bool requireValid = true}) async {
    if (_isSaving) return;
    if (requireValid && !_formKey.currentState!.validate()) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    if (!await di.sl<NetworkInfo>().isConnected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You are offline. Reconnect to save institution profile changes.',
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _isSaving = true);
    try {
      final before = widget.profile;
      final profile = _buildProfile();
      if (!mounted) return;
      context.read<StructureBloc>().add(
        UpdateInstitutionProfileRequested(profile, authState.user.schoolId),
      );
      unawaited(
        _auditInstitutionProfileChange(
          schoolId: authState.user.schoolId,
          userId: authState.user.id,
          before: before,
          after: profile,
        ),
      );
      // The profile stream remains the durable source of truth. This local
      // event gives the active tenant theme an immediate, safe refresh while
      // the Firestore acknowledgement and branding-version update arrive.
      try {
        if (!mounted) return;
        context.read<BrandingBloc>().add(
          BrandingUpdateRequested(
            SchoolBranding(
              schoolId: authState.user.schoolId,
              schoolName: profile.displayName.isNotEmpty
                  ? profile.displayName
                  : profile.name,
              schoolInitials: profile.initials.isNotEmpty
                  ? profile.initials
                  : profile.shortName,
              schoolMotto: profile.motto,
              schoolType: profile.schoolType,
              logoUrl: profile.logoUrl,
              badgeUrl: profile.badgeUrl,
              version: widget.profile.brandingVersion + 1,
            ),
          ),
        );
      } on FlutterError {
        // InstitutionTab is also embedded in isolated setup/test shells that
        // intentionally do not provide the application-level branding bloc.
      }
      // The write is fire-and-forget from the bloc's perspective (it relies
      // on the live stream to reconcile state), so give the UI a brief,
      // deliberate pause before flipping back to a clean/save-disabled
      // state - long enough to read as a real save, short enough to stay
      // responsive.
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _isDirty = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Institution profile saved.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Try again.')),
      );
    }
  }

  /// One audit entry per successful save, naming only which fields changed
  /// (no field values - identity contact details are not secrets, but this
  /// keeps the log itself free of anything worth minimising) plus actor and
  /// timestamps. Runs after the Firestore write is already dispatched, so a
  /// failure here never blocks or rolls back the profile save itself.
  Future<void> _auditInstitutionProfileChange({
    required String schoolId,
    required String userId,
    required InstitutionProfile before,
    required InstitutionProfile after,
  }) async {
    final changedFields = <String>[];
    void diff(String field, Object? a, Object? b) {
      if (a != b) changedFields.add(field);
    }

    diff('name', before.name, after.name);
    diff('shortName', before.shortName, after.shortName);
    diff('schoolType', before.schoolType, after.schoolType);
    diff('schoolCategory', before.schoolCategory, after.schoolCategory);
    diff('phone', before.phone, after.phone);
    diff('email', before.email, after.email);
    diff('website', before.website, after.website);
    diff('address', before.address, after.address);
    diff('district', before.district, after.district);
    diff('city', before.city, after.city);
    diff('country', before.country, after.country);
    diff('logoUrl', before.logoUrl, after.logoUrl);
    if (changedFields.isEmpty) return;
    try {
      await di.sl<AuditRepository>().logAction(
        schoolId: schoolId,
        title: 'School identity updated',
        description: 'Changed: ${changedFields.join(', ')}',
        iconName: 'school_outlined',
        colorHex: '#3A6EA5',
        userId: userId,
        relatedEntityId: 'institution_profile',
      );
    } catch (_) {
      // Audit is best-effort; never surface a failure here as a save error.
    }
  }

  /// Saves in place when the form has unsaved, valid edits. Returns false
  /// (and leaves validation errors visible) when the form is dirty but
  /// invalid, so the caller can keep the admin on this step.
  Future<bool> saveIfDirty() async {
    if (!_isDirty) return true;
    if (!_formKey.currentState!.validate()) return false;
    await _save();
    return true;
  }

  /// Used by the wizard's primary action. Unlike a background save, moving
  /// forward must always check the fields that make Step 1 complete.
  Future<bool> saveAndValidateForContinue() async {
    if (!_formKey.currentState!.validate()) return false;
    if (_isDirty) await _save();
    return true;
  }

  /// Persists whatever is currently filled in without enforcing the
  /// required-field validators used by "Save & continue" - a draft may
  /// legitimately be incomplete.
  Future<void> saveDraft() async {
    if (!_isDirty) return;
    await _save(requireValid: false);
  }

  Future<bool> confirmDiscardIfDirty(BuildContext context) async {
    if (!_isDirty) return true;
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text(
          'You have unsaved changes to the institution profile. Save before leaving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'stay'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'discard'),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, 'save'),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (choice == 'save') {
      await _save();
      return true;
    }
    return choice == 'discard';
  }

  Future<void> _detectLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Turn on Location Services to detect your coordinates.',
            ),
          ),
        );
      }
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission is required to detect coordinates.',
            ),
          ),
        );
      }
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _gpsLat.text = position.latitude.toStringAsFixed(6);
        _gpsLng.text = position.longitude.toStringAsFixed(6);
      });
      _markDirty();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location coordinates detected.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not detect location. Try again.')),
      );
    }
  }

  Future<void> _pickBrandingImage({required bool isLogo}) async {
    XFile? image;
    try {
      if (Theme.of(context).platform == TargetPlatform.android ||
          Theme.of(context).platform == TargetPlatform.iOS) {
        final source = await showModalBottomSheet<ImageSource>(
          context: context,
          builder: (sheetContext) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take a photo'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
        if (source == null) return;
        image = await ImagePicker().pickImage(
          source: source,
          imageQuality: 88,
          maxWidth: 1600,
        );
      } else {
        final result = await file_picker.FilePicker.pickFiles(
          type: file_picker.FileType.custom,
          allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
          withData: true,
        );
        final file = result?.files.single;
        if (file == null) return;
        image = XFile.fromData(
          file.bytes ?? await XFile(file.path!).readAsBytes(),
          name: file.name,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the image picker.')),
        );
      }
      return;
    }
    if (image == null || !mounted) return;

    final bytes = await image.readAsBytes();
    final extension = image.name.split('.').last.toLowerCase();
    const supported = {'png', 'jpg', 'jpeg', 'webp'};
    final maxBytes = 5 * 1024 * 1024;
    if (!supported.contains(extension) ||
        bytes.isEmpty ||
        bytes.length > maxBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !supported.contains(extension)
                  ? 'Use a PNG, JPG, JPEG, or WEBP image.'
                  : 'The ${isLogo ? 'logo' : 'badge'} must be 5 MB or smaller.',
            ),
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Use this ${isLogo ? 'logo' : 'badge'}?'),
        content: SizedBox(
          width: 260,
          height: 180,
          child: Image.memory(bytes, fit: BoxFit.contain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() {
      if (isLogo) {
        _isUploadingLogo = true;
      } else {
        _isUploadingBadge = true;
      }
    });

    try {
      final schoolId = authState.user.schoolId;
      final kind = isLogo ? 'logo' : 'badge';
      final reference = di.sl<FirebaseStorage>().ref(
        'institutions/$schoolId/branding/$kind/${kind}_${DateTime.now().millisecondsSinceEpoch}.$extension',
      );
      await reference.putData(
        bytes,
        SettableMetadata(
          contentType: extension == 'jpg' ? 'image/jpeg' : 'image/$extension',
        ),
      );
      final url = await reference.getDownloadURL();
      if (!mounted) return;
      setState(() {
        if (isLogo) {
          _logoUrl = url;
        } else {
          _badgeUrl = url;
        }
      });
      _markDirty();
    } on FirebaseException catch (e) {
      debugPrint(
        'Branding upload failed (${isLogo ? 'logo' : 'badge'}): '
        '${e.code} — ${e.message}',
      );
      if (!mounted) return;
      final message = e.code == 'unauthorized'
          ? 'You do not have permission to upload this ${isLogo ? 'logo' : 'badge'}.'
          : 'Could not upload the ${isLogo ? 'logo' : 'badge'} (${e.code}). Try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e, stack) {
      debugPrint(
        'Branding upload failed (${isLogo ? 'logo' : 'badge'}): $e\n$stack',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not upload the ${isLogo ? 'logo' : 'badge'}. Try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          if (isLogo) {
            _isUploadingLogo = false;
          } else {
            _isUploadingBadge = false;
          }
        });
      }
    }
  }

  Future<void> _removeBrandingImage({required bool isLogo}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove ${isLogo ? 'logo' : 'badge'}?'),
        content: Text(
          'The institution will fall back to its initials until a new '
          '${isLogo ? 'logo' : 'badge'} is uploaded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      if (isLogo) {
        _logoUrl = '';
      } else {
        _badgeUrl = '';
      }
    });
    _markDirty();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wizardMode) return _buildWizardForm(context);
    final scheme = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _SectionCard(
                icon: Icons.account_balance_outlined,
                color: scheme.primary,
                title: 'School Identity',
                children: [
                  _TwoCol(
                    isNarrow: isNarrow,
                    left: _field(
                      controller: _name,
                      label: 'Institution Name',
                      validator: _requiredValidator,
                    ),
                    right: _field(controller: _shortName, label: 'Short Name'),
                  ),
                  _field(controller: _motto, label: 'Motto'),
                  _TwoCol(
                    isNarrow: isNarrow,
                    left: _field(
                      controller: _vision,
                      label: 'Vision',
                      maxLines: 3,
                    ),
                    right: _field(
                      controller: _mission,
                      label: 'Mission',
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.palette_outlined,
                color: Colors.black,
                title: 'Branding',
                children: [
                  _TwoCol(
                    isNarrow: isNarrow,
                    left: _BrandImagePicker(
                      label: 'School Logo',
                      actionLabel: 'Change Logo',
                      imageUrl: _logoUrl,
                      isUploading: _isUploadingLogo,
                      onPick: () => _pickBrandingImage(isLogo: true),
                      onRemove: () => _removeBrandingImage(isLogo: true),
                    ),
                    right: _BrandImagePicker(
                      label: 'School Badge / Crest',
                      actionLabel: 'Change Badge',
                      imageUrl: _badgeUrl,
                      isUploading: _isUploadingBadge,
                      onPick: () => _pickBrandingImage(isLogo: false),
                      onRemove: () => _removeBrandingImage(isLogo: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.sell_outlined,
                color: Colors.black,
                title: 'Institution Classification',
                children: [
                  _TwoCol(
                    isNarrow: isNarrow,
                    left: _multiSelectField(
                      label: 'School Type',
                      values: _schoolTypes,
                      selected: _schoolTypeSelections,
                      onChanged: (selections) => setState(() {
                        _schoolType = selections.join(', ');
                        _isDirty = true;
                      }),
                    ),
                    right: _dropdown(
                      label: 'School Category',
                      value: _schoolCategory,
                      values: _schoolCategories,
                      onChanged: (v) => setState(() {
                        _schoolCategory = v;
                        _isDirty = true;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.description_outlined,
                color: Colors.black,
                title: 'Registration',
                children: [
                  _field(
                    controller: _registrationNumber,
                    label: 'Registration Number',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9A-Za-z/\-]'),
                      ),
                    ],
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return null;
                      return RegExp(
                            r'^[0-9A-Za-z]+([/\-][0-9A-Za-z]+)*$',
                          ).hasMatch(v)
                          ? null
                          : 'Use letters, numbers, "/" or "-" only (e.g. PSS/R/39)';
                    },
                  ),
                  _field(
                    controller: _ministryRegistrationNumber,
                    label: 'Ministry Registration',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9A-Za-z/\-]'),
                      ),
                    ],
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return null;
                      return RegExp(
                            r'^[0-9A-Za-z]+([/\-][0-9A-Za-z]+)*$',
                          ).hasMatch(v)
                          ? null
                          : 'Use letters, numbers, "/" or "-" only';
                    },
                  ),
                  _field(
                    controller: _taxNumber,
                    label: 'TIN – Tax Identification Number (optional)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return null;
                      return RegExp(r'^\d{10}$').hasMatch(v)
                          ? null
                          : 'TIN must be exactly 10 digits';
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.place_outlined,
                color: scheme.primary,
                title: 'Location',
                trailing: TextButton.icon(
                  onPressed: _detectLocation,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  icon: const Icon(Icons.my_location_outlined, size: 15),
                  label: const Text(
                    'Detect current location',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                children: [
                  _TwoCol(
                    isNarrow: isNarrow,
                    left: _field(controller: _countryText, label: 'Country'),
                    right: _field(
                      controller: _districtText,
                      label: 'District / Region',
                    ),
                  ),
                  _TwoCol(
                    isNarrow: isNarrow,
                    left: _field(controller: _city, label: 'City / Town'),
                    right: _field(controller: _address, label: 'Address'),
                  ),
                  _TwoCol(
                    isNarrow: isNarrow,
                    left: _field(
                      controller: _gpsLat,
                      label: 'GPS Latitude',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                      ],
                    ),
                    right: _field(
                      controller: _gpsLng,
                      label: 'GPS Longitude',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.call_outlined,
                color: scheme.primary,
                title: 'Contact',
                children: [
                  LayoutBuilder(
                    builder: (context, c) {
                      final threeCol = c.maxWidth >= 520;
                      final phone = _field(
                        controller: _phone,
                        label: 'Phone',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          return RegExp(r'^\+?[0-9]{9,15}$').hasMatch(value)
                              ? null
                              : 'Enter a valid phone number';
                        },
                      );
                      final email = _field(
                        controller: _email,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          return RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(value)
                              ? null
                              : 'Enter a valid email address';
                        },
                      );
                      final website = _field(
                        controller: _website,
                        label: 'Website',
                        keyboardType: TextInputType.url,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return null;
                          return RegExp(
                                r'^(https?:\/\/)?([\w-]+\.)+[a-zA-Z]{2,}(\/\S*)?$',
                              ).hasMatch(v)
                              ? null
                              : 'Enter a valid website (e.g. www.school.ac.ug)';
                        },
                      );
                      if (threeCol) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: phone),
                            const SizedBox(width: 10),
                            Expanded(child: email),
                            const SizedBox(width: 10),
                            Expanded(child: website),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          phone,
                          const SizedBox(height: 12),
                          email,
                          const SizedBox(height: 12),
                          website,
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWizardForm(BuildContext context) {
    // Step 1's mobile treatment is deliberately always light/monochrome
    // regardless of the device theme (matching the reference design), so it
    // must be built from a clean light ThemeData rather than `.copyWith()`
    // off the ambient theme - `.copyWith` only replaces the fields passed to
    // it and leaves everything else (inputDecorationTheme's fillColor/
    // labelStyle, chipTheme, etc.) pointing at the ambient theme's tokens,
    // which are inverted (white-on-black) when the device is in dark mode.
    final monochromeTheme = ThemeData.light(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.black,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        outline: Colors.black,
        error: AppColors.dangerLight,
        onError: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        hintStyle: TextStyle(color: Colors.black),
        labelStyle: TextStyle(color: Colors.black),
      ),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
    );
    return Theme(
      data: monochromeTheme,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 340;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              children: [
                const Text(
                  'Tell us about your school.',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'This information helps us set up your school on School '
                  'Pulse. Required fields marked *',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 16),
                _wizardEssentialInfoCard(isNarrow),
                const SizedBox(height: 12),
                _WizardExpandableSection(
                  icon: Icons.description_outlined,
                  title: 'More profile details (optional)',
                  subtitle: 'Short name, motto, vision and mission.',
                  children: [
                    _wizardField(
                      controller: _shortName,
                      label: 'Short name (optional)',
                      hint: 'Enter short name',
                    ),
                    _wizardField(
                      controller: _motto,
                      label: 'Motto (optional)',
                      hint: 'Enter motto',
                    ),
                    _wizardField(
                      controller: _vision,
                      label: 'Vision (optional)',
                      hint: 'Enter vision',
                      maxLines: 3,
                    ),
                    _wizardField(
                      controller: _mission,
                      label: 'Mission (optional)',
                      hint: 'Enter mission',
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _WizardExpandableSection(
                  icon: Icons.account_balance_outlined,
                  title: 'Branding, registration & location (optional)',
                  subtitle:
                      'Logo, crest, registration details, website and GPS '
                      'location.',
                  children: [
                    _wizardSectionTitle('Brand identity'),
                    _WizardTwoColumn(
                      isNarrow: isNarrow,
                      left: _BrandImagePicker(
                        label: 'School logo (optional)',
                        actionLabel: _logoUrl.isEmpty
                            ? 'Upload logo'
                            : 'Replace logo',
                        imageUrl: _logoUrl,
                        isUploading: _isUploadingLogo,
                        monochrome: true,
                        onPick: () => _pickBrandingImage(isLogo: true),
                        onRemove: () => _removeBrandingImage(isLogo: true),
                      ),
                      right: _BrandImagePicker(
                        label: 'School crest (optional)',
                        actionLabel: _badgeUrl.isEmpty
                            ? 'Upload crest'
                            : 'Replace crest',
                        imageUrl: _badgeUrl,
                        isUploading: _isUploadingBadge,
                        monochrome: true,
                        onPick: () => _pickBrandingImage(isLogo: false),
                        onRemove: () => _removeBrandingImage(isLogo: false),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _wizardSectionTitle('Registration details'),
                    _wizardField(
                      controller: _registrationNumber,
                      label: 'Registration number (optional)',
                      hint: 'Enter registration number',
                    ),
                    _wizardField(
                      controller: _ministryRegistrationNumber,
                      label: 'Ministry registration (optional)',
                      hint: 'Enter ministry registration',
                    ),
                    _wizardField(
                      controller: _taxNumber,
                      label: 'TIN (optional)',
                      hint: 'Enter TIN',
                      keyboardType: TextInputType.number,
                    ),
                    _wizardField(
                      controller: _website,
                      label: 'Website (optional)',
                      hint: 'Enter website',
                      keyboardType: TextInputType.url,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      validator: _websiteValidator,
                    ),
                    const SizedBox(height: 12),
                    _wizardSectionTitle('Location coordinates'),
                    _wizardCountryField(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _detectLocation,
                        icon: const Icon(Icons.my_location_outlined, size: 16),
                        label: const Text(
                          'Use current location',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    _WizardTwoColumn(
                      isNarrow: isNarrow,
                      left: _wizardField(
                        controller: _gpsLat,
                        label: 'GPS latitude (optional)',
                        hint: 'Enter latitude',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                      right: _wizardField(
                        controller: _gpsLng,
                        label: 'GPS longitude (optional)',
                        hint: 'Enter longitude',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _WizardInfoNote(
                  text:
                      'You can update this later. You can edit all optional '
                      'details from your school settings any time after '
                      'setup.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _wizardEssentialInfoCard(bool isNarrow) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Essential information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        const Text(
          "Let's start with the basics.",
          style: TextStyle(color: Colors.black54, fontSize: 12.5),
        ),
        const SizedBox(height: 14),
        _wizardField(
          controller: _name,
          label: 'Institution name *',
          hint: 'Enter institution name',
          validator: _requiredValidator,
        ),
        _WizardTwoColumn(
          isNarrow: isNarrow,
          left: _wizardDropdown(
            label: 'School type *',
            hint: 'Select school type',
            value: _schoolType,
            values: _schoolTypes,
            required: true,
            onChanged: (value) => setState(() {
              _schoolType = value;
              _isDirty = true;
            }),
          ),
          right: _wizardDropdown(
            label: 'School category (optional)',
            hint: 'Select school category',
            value: _schoolCategory,
            values: _schoolCategories,
            onChanged: (value) => setState(() {
              _schoolCategory = value;
              _isDirty = true;
            }),
          ),
        ),
        _WizardTwoColumn(
          isNarrow: isNarrow,
          left: _wizardDistrictField(),
          right: _wizardField(
            controller: _city,
            label: 'Town *',
            hint: 'Enter town',
            validator: _requiredValidator,
          ),
        ),
        _wizardField(
          controller: _address,
          label: 'Physical address (optional)',
          hint: 'Enter physical address',
        ),
        _wizardField(
          controller: _phone,
          label: 'Main phone *',
          hint: 'Enter main phone number',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
          ],
          validator: _phoneValidator,
        ),
        _wizardField(
          controller: _email,
          label: 'Main email *',
          hint: 'Enter main email address',
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          validator: _emailValidator,
        ),
      ],
    ),
  );

  Widget _wizardSectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    ),
  );

  Widget _wizardField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: _wizardInputDecoration(hint),
        ),
      ],
    ),
  );

  InputDecoration _wizardInputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.dangerLight, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.dangerLight, width: 1.6),
    ),
  );

  Widget _wizardDropdown({
    required String label,
    required String hint,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
    bool required = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: FormField<String>(
      initialValue: value,
      validator: required
          ? (value) => value == null || value.isEmpty ? 'Required' : null
          : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _wizardOutlinedContainer(
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: values.contains(value) ? value : null,
                isExpanded: true,
                hint: Text(
                  hint,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.black,
                ),
                items: values
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (selected) {
                  if (selected != null) {
                    onChanged(selected);
                    state.didChange(selected);
                  }
                },
              ),
            ),
            state.hasError,
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12),
              child: Text(
                state.errorText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.dangerLight,
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _wizardDistrictField() => _wizardField(
    controller: _districtText,
    label: 'District / Region *',
    hint: 'Enter district or region',
    validator: (value) =>
        value == null || value.trim().isEmpty ? 'Required' : null,
  );

  Widget _wizardCountryField() => _wizardField(
    controller: _countryText,
    label: 'Country (optional)',
    hint: 'Enter country',
  );

  Widget _wizardOutlinedContainer(Widget child, bool hasError) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black, width: hasError ? 1.6 : 1.2),
      borderRadius: BorderRadius.circular(12),
    ),
    constraints: const BoxConstraints(minHeight: 48),
    alignment: Alignment.center,
    child: child,
  );

  String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  String? _phoneValidator(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Required';
    return RegExp(r'^\+?[0-9]{9,15}$').hasMatch(phone)
        ? null
        : 'Enter a valid phone number';
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Required';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
        ? null
        : 'Enter a valid email address';
  }

  String? _websiteValidator(String? value) {
    final website = value?.trim() ?? '';
    if (website.isEmpty) return null;
    return RegExp(
          r'^(https?:\/\/)?([\w-]+\.)+[a-zA-Z]{2,}(\/\S*)?$',
        ).hasMatch(website)
        ? null
        : 'Enter a valid website';
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  List<String> get _schoolTypeSelections => _schoolType
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  Widget _multiSelectField({
    required String label,
    required List<String> values,
    required List<String> selected,
    required ValueChanged<List<String>> onChanged,
  }) {
    final displayText = selected.isEmpty ? '' : selected.join(', ');
    return InkWell(
      onTap: () async {
        var working = List<String>.from(selected);
        final result = await showDialog<List<String>>(
          context: context,
          builder: (dialogContext) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: Text(label),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: values.map((option) {
                        final checked = working.contains(option);
                        return CheckboxListTile(
                          title: Text(option),
                          value: checked,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (v) => setDialogState(() {
                            if (v == true) {
                              working.add(option);
                            } else {
                              working.remove(option);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(working),
                      child: const Text('Done'),
                    ),
                  ],
                );
              },
            );
          },
        );
        if (result != null) onChanged(result);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          displayText.isEmpty ? ' ' : displayText,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: values.contains(value) ? value : null,
      isExpanded: true,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      items: values
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.children,
    this.trailing,
  });

  final IconData icon;
  final Color color;
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      showShadow: false,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _TwoCol extends StatelessWidget {
  const _TwoCol({
    required this.left,
    required this.right,
    required this.isNarrow,
  });
  final Widget left;
  final Widget right;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    if (isNarrow) {
      return Column(children: [left, const SizedBox(height: 10), right]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 10),
        Expanded(child: right),
      ],
    );
  }
}

/// Wider desktop layouts retain a concise two-column form; phones stack each
/// pair while preserving the visual order shown in the setup flow.
class _WizardTwoColumn extends StatelessWidget {
  const _WizardTwoColumn({
    required this.left,
    required this.right,
    required this.isNarrow,
  });

  final Widget left;
  final Widget right;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    if (isNarrow) {
      return Column(children: [left, right]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

/// Collapsed-by-default accordion section used by Step 1's optional field
/// groups ("More profile details", "Branding, registration & location").
class _WizardExpandableSection extends StatelessWidget {
  const _WizardExpandableSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Material(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          leading: Icon(icon, color: Colors.black, size: 20),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          children: children,
        ),
      ),
    );
  }
}

/// Pale-blue "you can update this later" note shown under Step 1's optional
/// sections.
class _WizardInfoNote extends StatelessWidget {
  const _WizardInfoNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF1565C0),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF1565C0), fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandImagePicker extends StatelessWidget {
  const _BrandImagePicker({
    required this.label,
    required this.actionLabel,
    required this.imageUrl,
    required this.isUploading,
    required this.onPick,
    this.onRemove,
    this.monochrome = false,
  });

  final String label;
  final String actionLabel;
  final String imageUrl;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback? onRemove;
  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = imageUrl.isNotEmpty;
    final foreground = monochrome ? Colors.black : scheme.onSurfaceVariant;
    final background = monochrome
        ? Colors.white
        : scheme.surfaceContainerHighest;
    final border = monochrome ? Colors.black : scheme.outlineVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: foreground,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 96,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.broken_image_outlined,
                      color: foreground,
                      size: 28,
                    ),
                  ),
                )
              else
                Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: foreground,
                    size: 28,
                  ),
                ),
              if (isUploading)
                ColoredBox(
                  color: Colors.black,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isUploading ? null : onPick,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 9),
              side: BorderSide(color: border),
              foregroundColor: foreground,
            ),
            icon: const Icon(Icons.image_outlined, size: 15),
            label: Text(actionLabel, style: const TextStyle(fontSize: 12.5)),
          ),
        ),
        if (hasImage && onRemove != null) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: isUploading ? null : onRemove,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                foregroundColor: foreground,
              ),
              icon: const Icon(Icons.delete_outline, size: 15),
              label: const Text('Remove', style: TextStyle(fontSize: 12.5)),
            ),
          ),
        ],
      ],
    );
  }
}
