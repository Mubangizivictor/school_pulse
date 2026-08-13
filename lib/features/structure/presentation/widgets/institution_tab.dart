import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/institution_profile.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';

/// The Institution tab's content, embedded directly inside the Structure
/// hub (no separate profile screen/route) - one continuous scrollable form
/// matching the compact enterprise-panel reference layout.
class InstitutionTab extends StatefulWidget {
  const InstitutionTab({super.key});

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) =>
          _InstitutionForm(key: _formKey, profile: state.institutionProfile),
    );
  }
}

const _ugandaDistricts = [
  'Kampala',
  'Wakiso',
  'Mukono',
  'Jinja',
  'Mbarara',
  'Gulu',
  'Mbale',
  'Masaka',
  'Fort Portal',
  'Lira',
  'Other district',
];

class _InstitutionForm extends StatefulWidget {
  const _InstitutionForm({super.key, required this.profile});
  final InstitutionProfile profile;

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
  late String _country;
  late String _district;
  late final TextEditingController _city;
  late final TextEditingController _address;
  late final TextEditingController _gpsLat;
  late final TextEditingController _gpsLng;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _website;
  late String _timeZone;
  late String _currency;
  late String _language;
  late String _dateFormat;
  late String _timeFormat;

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
    _country = p.country.isEmpty ? 'Uganda' : p.country;
    _district = p.district;
    _city = TextEditingController(text: p.city);
    _address = TextEditingController(text: p.address);
    _gpsLat = TextEditingController(text: p.gpsLat?.toString() ?? '');
    _gpsLng = TextEditingController(text: p.gpsLng?.toString() ?? '');
    _phone = TextEditingController(text: p.phone);
    _email = TextEditingController(text: p.email);
    _website = TextEditingController(text: p.website);
    _timeZone = p.timeZone.isEmpty ? 'Africa/Kampala' : p.timeZone;
    _currency = p.currency.isEmpty ? 'UGX' : p.currency;
    _language = p.language.isEmpty ? 'English' : p.language;
    _dateFormat = p.dateFormat.isEmpty ? 'dd/MM/yyyy' : p.dateFormat;
    _timeFormat = p.timeFormat.isEmpty ? '24-hour' : p.timeFormat;

    _textControllers = [
      _name,
      _shortName,
      _motto,
      _vision,
      _mission,
      _registrationNumber,
      _ministryRegistrationNumber,
      _taxNumber,
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
      _country = p.country.isEmpty ? 'Uganda' : p.country;
      _district = p.district;
      _timeZone = p.timeZone.isEmpty ? 'Africa/Kampala' : p.timeZone;
      _currency = p.currency.isEmpty ? 'UGX' : p.currency;
      _language = p.language.isEmpty ? 'English' : p.language;
      _dateFormat = p.dateFormat.isEmpty ? 'dd/MM/yyyy' : p.dateFormat;
      _timeFormat = p.timeFormat.isEmpty ? '24-hour' : p.timeFormat;
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

  InstitutionProfile _buildProfile() => InstitutionProfile(
    name: _name.text.trim(),
    shortName: _shortName.text.trim(),
    motto: _motto.text.trim(),
    vision: _vision.text.trim(),
    mission: _mission.text.trim(),
    logoUrl: _logoUrl,
    badgeUrl: _badgeUrl,
    colors: widget.profile.colors,
    schoolType: _schoolType,
    schoolCategory: _schoolCategory,
    registrationNumber: _registrationNumber.text.trim(),
    ministryRegistrationNumber: _ministryRegistrationNumber.text.trim(),
    taxNumber: _taxNumber.text.trim(),
    country: _country,
    district: _district,
    city: _city.text.trim(),
    address: _address.text.trim(),
    gpsLat: double.tryParse(_gpsLat.text),
    gpsLng: double.tryParse(_gpsLng.text),
    phone: _phone.text.trim(),
    email: _email.text.trim(),
    website: _website.text.trim(),
    socialMedia: widget.profile.socialMedia,
    timeZone: _timeZone,
    currency: _currency,
    language: _language,
    dateFormat: _dateFormat,
    timeFormat: _timeFormat,
  );

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    setState(() => _isSaving = true);
    try {
      context.read<StructureBloc>().add(
        UpdateInstitutionProfileRequested(
          _buildProfile(),
          authState.user.schoolId,
        ),
      );
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
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (image == null || !mounted) return;

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
      final imageBytes = await image.readAsBytes();
      final kind = isLogo ? 'logo' : 'badge';
      final reference = di.sl<FirebaseStorage>().ref(
        'school_assets/${schoolId}_${kind}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await reference.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
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
    } catch (_) {
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
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
                color: Colors.purple,
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
                    ),
                    right: _BrandImagePicker(
                      label: 'School Badge / Crest',
                      actionLabel: 'Change Badge',
                      imageUrl: _badgeUrl,
                      isUploading: _isUploadingBadge,
                      onPick: () => _pickBrandingImage(isLogo: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.sell_outlined,
                color: Colors.green,
                title: 'Institution Classification',
                children: [
                  _TwoCol(
                    isNarrow: isNarrow,
                    left: _dropdown(
                      label: 'School Type',
                      value: _schoolType,
                      values: _schoolTypes,
                      onChanged: (v) => setState(() {
                        _schoolType = v;
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
                color: Colors.orange,
                title: 'Registration',
                children: [
                  _field(
                    controller: _registrationNumber,
                    label: 'Registration Number',
                  ),
                  _field(
                    controller: _ministryRegistrationNumber,
                    label: 'Ministry Registration',
                  ),
                  _field(
                    controller: _taxNumber,
                    label: 'Tax Number (optional)',
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
                    left: _dropdown(
                      label: 'Country',
                      value: _country,
                      values: const ['Uganda'],
                      onChanged: (v) => setState(() {
                        _country = v;
                        _isDirty = true;
                      }),
                    ),
                    right: _dropdown(
                      label: 'District',
                      value: _district,
                      values: _ugandaDistricts,
                      onChanged: (v) => setState(() {
                        _district = v;
                        _isDirty = true;
                      }),
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
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.public_outlined,
                color: Colors.orange,
                title: 'Regional Settings',
                children: [
                  LayoutBuilder(
                    builder: (context, c) {
                      final items = [
                        _dropdown(
                          label: 'Time Zone',
                          value: _timeZone,
                          values: const ['Africa/Kampala'],
                          onChanged: (v) => setState(() {
                            _timeZone = v;
                            _isDirty = true;
                          }),
                        ),
                        _dropdown(
                          label: 'Currency',
                          value: _currency,
                          values: const ['UGX'],
                          onChanged: (v) => setState(() {
                            _currency = v;
                            _isDirty = true;
                          }),
                        ),
                        _dropdown(
                          label: 'Language',
                          value: _language,
                          values: const ['English'],
                          onChanged: (v) => setState(() {
                            _language = v;
                            _isDirty = true;
                          }),
                        ),
                        _dropdown(
                          label: 'Date Format',
                          value: _dateFormat,
                          values: const ['dd/MM/yyyy', 'MM/dd/yyyy'],
                          onChanged: (v) => setState(() {
                            _dateFormat = v;
                            _isDirty = true;
                          }),
                        ),
                        _dropdown(
                          label: 'Time Format',
                          value: _timeFormat,
                          values: const ['24-hour', '12-hour'],
                          onChanged: (v) => setState(() {
                            _timeFormat = v;
                            _isDirty = true;
                          }),
                        ),
                      ];
                      final wide = c.maxWidth >= 640;
                      if (!wide) {
                        return Column(
                          children: [
                            for (int i = 0; i < items.length; i++) ...[
                              if (i > 0) const SizedBox(height: 12),
                              items[i],
                            ],
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < items.length; i++) ...[
                            if (i > 0) const SizedBox(width: 10),
                            Expanded(child: items[i]),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    _isSaving ? 'Saving…' : 'Save Institution',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

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

class _BrandImagePicker extends StatelessWidget {
  const _BrandImagePicker({
    required this.label,
    required this.actionLabel,
    required this.imageUrl,
    required this.isUploading,
    required this.onPick,
  });

  final String label;
  final String actionLabel;
  final String imageUrl;
  final bool isUploading;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = imageUrl.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 96,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scheme.outlineVariant),
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
                      color: scheme.onSurfaceVariant,
                      size: 28,
                    ),
                  ),
                )
              else
                Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: scheme.onSurfaceVariant,
                    size: 28,
                  ),
                ),
              if (isUploading)
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.55),
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
              side: BorderSide(color: scheme.outlineVariant),
            ),
            icon: const Icon(Icons.image_outlined, size: 15),
            label: Text(actionLabel, style: const TextStyle(fontSize: 12.5)),
          ),
        ),
      ],
    );
  }
}
