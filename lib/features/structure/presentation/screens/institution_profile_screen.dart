import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/institution_profile.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Full institutional identity/profile - a single form, saved as one
/// document (like Feature Toggles), not a list of records.
class InstitutionProfileScreen extends StatelessWidget {
  const InstitutionProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) =>
          _InstitutionProfileForm(profile: state.institutionProfile),
    );
  }
}

class _InstitutionProfileForm extends StatefulWidget {
  final InstitutionProfile profile;
  const _InstitutionProfileForm({required this.profile});

  @override
  State<_InstitutionProfileForm> createState() =>
      _InstitutionProfileFormState();
}

class _InstitutionProfileFormState extends State<_InstitutionProfileForm> {
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
  late final TextEditingController _schoolType;
  late final TextEditingController _schoolCategory;
  late final TextEditingController _registrationNumber;
  late final TextEditingController _ministryRegistrationNumber;
  late final TextEditingController _taxNumber;
  late final TextEditingController _country;
  late final TextEditingController _district;
  late final TextEditingController _city;
  late final TextEditingController _address;
  late final TextEditingController _gpsLat;
  late final TextEditingController _gpsLng;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _website;
  late final TextEditingController _timeZone;
  late final TextEditingController _currency;
  late final TextEditingController _language;
  late final TextEditingController _dateFormat;
  late final TextEditingController _timeFormat;

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
    _schoolType = TextEditingController(text: p.schoolType);
    _schoolCategory = TextEditingController(text: p.schoolCategory);
    _registrationNumber = TextEditingController(text: p.registrationNumber);
    _ministryRegistrationNumber = TextEditingController(
      text: p.ministryRegistrationNumber,
    );
    _taxNumber = TextEditingController(text: p.taxNumber);
    _country = TextEditingController(
      text: p.country.isEmpty ? 'Uganda' : p.country,
    );
    _district = TextEditingController(text: p.district);
    _city = TextEditingController(text: p.city);
    _address = TextEditingController(text: p.address);
    _gpsLat = TextEditingController(text: p.gpsLat?.toString() ?? '');
    _gpsLng = TextEditingController(text: p.gpsLng?.toString() ?? '');
    _phone = TextEditingController(text: p.phone);
    _email = TextEditingController(text: p.email);
    _website = TextEditingController(text: p.website);
    _timeZone = TextEditingController(
      text: p.timeZone.isEmpty ? 'Africa/Kampala' : p.timeZone,
    );
    _currency = TextEditingController(
      text: p.currency.isEmpty ? 'UGX' : p.currency,
    );
    _language = TextEditingController(
      text: p.language.isEmpty ? 'English' : p.language,
    );
    _dateFormat = TextEditingController(
      text: p.dateFormat.isEmpty ? 'dd/MM/yyyy' : p.dateFormat,
    );
    _timeFormat = TextEditingController(
      text: p.timeFormat.isEmpty ? '24-hour' : p.timeFormat,
    );
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _shortName,
      _motto,
      _vision,
      _mission,
      _schoolType,
      _schoolCategory,
      _registrationNumber,
      _ministryRegistrationNumber,
      _taxNumber,
      _country,
      _district,
      _city,
      _address,
      _gpsLat,
      _gpsLng,
      _phone,
      _email,
      _website,
      _timeZone,
      _currency,
      _language,
      _dateFormat,
      _timeFormat,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final profile = InstitutionProfile(
      name: _name.text,
      shortName: _shortName.text,
      motto: _motto.text,
      vision: _vision.text,
      mission: _mission.text,
      logoUrl: _logoUrl,
      badgeUrl: _badgeUrl,
      colors: widget.profile.colors,
      schoolType: _schoolType.text,
      schoolCategory: _schoolCategory.text,
      registrationNumber: _registrationNumber.text,
      ministryRegistrationNumber: _ministryRegistrationNumber.text,
      taxNumber: _taxNumber.text,
      country: _country.text,
      district: _district.text,
      city: _city.text,
      address: _address.text,
      gpsLat: double.tryParse(_gpsLat.text),
      gpsLng: double.tryParse(_gpsLng.text),
      phone: _phone.text,
      email: _email.text,
      website: _website.text,
      socialMedia: widget.profile.socialMedia,
      timeZone: _timeZone.text,
      currency: _currency.text,
      language: _language.text,
      dateFormat: _dateFormat.text,
      timeFormat: _timeFormat.text,
    );
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    context.read<StructureBloc>().add(
      UpdateInstitutionProfileRequested(profile, schoolId),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const _InstitutionProfileSuccessScreen(),
      ),
    );
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
    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _gpsLat.text = position.latitude.toStringAsFixed(6);
      _gpsLng.text = position.longitude.toStringAsFixed(6);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location coordinates detected.')),
    );
  }

  Future<void> _pickBrandingImage({required bool isLogo}) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (image == null || !mounted) return;

    setState(() {
      if (isLogo) {
        _isUploadingLogo = true;
      } else {
        _isUploadingBadge = true;
      }
    });

    try {
      final schoolId =
          (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
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

  Future<void> _removeBrandingImage({required bool isLogo}) async {
    final url = isLogo ? _logoUrl : _badgeUrl;
    if (url.isEmpty) return;
    try {
      await di.sl<FirebaseStorage>().refFromURL(url).delete();
    } catch (_) {
      // The prior file may have been removed already, or may be a legacy URL.
      // Clearing the profile reference is still the required user action.
    }
    if (!mounted) return;
    setState(() {
      if (isLogo) {
        _logoUrl = '';
      } else {
        _badgeUrl = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institution Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProfileSection(
              icon: Icons.badge_outlined,
              color: Colors.indigo,
              title: 'Identity',
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Institution Name',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the institution name'
                      : null,
                ),
                TextField(
                  controller: _shortName,
                  decoration: const InputDecoration(labelText: 'Short Name'),
                ),
                TextField(
                  controller: _motto,
                  decoration: const InputDecoration(labelText: 'Motto'),
                ),
                TextField(
                  controller: _vision,
                  decoration: const InputDecoration(labelText: 'Vision'),
                  maxLines: 2,
                ),
                TextField(
                  controller: _mission,
                  decoration: const InputDecoration(labelText: 'Mission'),
                  maxLines: 2,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _BrandImagePicker(
                        label: 'School logo',
                        imageUrl: _logoUrl,
                        isUploading: _isUploadingLogo,
                        onPick: () => _pickBrandingImage(isLogo: true),
                        onRemove: _logoUrl.isEmpty
                            ? null
                            : () => _removeBrandingImage(isLogo: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BrandImagePicker(
                        label: 'School badge',
                        imageUrl: _badgeUrl,
                        isUploading: _isUploadingBadge,
                        onPick: () => _pickBrandingImage(isLogo: false),
                        onRemove: _badgeUrl.isEmpty
                            ? null
                            : () => _removeBrandingImage(isLogo: false),
                      ),
                    ),
                  ],
                ),
                _ProfileDropdown(
                  label: 'School type',
                  value: _schoolType.text,
                  values: const [
                    'Nursery',
                    'Primary',
                    'Secondary',
                    'Mixed school',
                    'Vocational',
                    'College',
                    'University',
                  ],
                  onChanged: (value) =>
                      setState(() => _schoolType.text = value),
                ),
                _ProfileDropdown(
                  label: 'School category',
                  value: _schoolCategory.text,
                  values: const [
                    'Government',
                    'Private',
                    'Community',
                    'Faith-based',
                    'International',
                  ],
                  onChanged: (value) =>
                      setState(() => _schoolCategory.text = value),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ProfileSection(
              icon: Icons.gavel_outlined,
              color: Colors.teal,
              title: 'Registration',
              children: [
                TextField(
                  controller: _registrationNumber,
                  decoration: const InputDecoration(
                    labelText: 'Registration Number',
                  ),
                ),
                TextField(
                  controller: _ministryRegistrationNumber,
                  decoration: const InputDecoration(
                    labelText: 'Ministry Registration',
                  ),
                ),
                TextField(
                  controller: _taxNumber,
                  decoration: const InputDecoration(
                    labelText: 'Tax Number (optional)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ProfileSection(
              icon: Icons.place_outlined,
              color: Colors.brown,
              title: 'Location',
              children: [
                TextFormField(
                  controller: _country,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Country'),
                ),
                _ProfileDropdown(
                  label: 'District',
                  value: _district.text,
                  values: const [
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
                  ],
                  onChanged: (value) => setState(() => _district.text = value),
                ),
                TextField(
                  controller: _city,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                TextField(
                  controller: _address,
                  decoration: const InputDecoration(labelText: 'Address'),
                  maxLines: 2,
                ),
                TextButton.icon(
                  onPressed: _detectLocation,
                  icon: const Icon(Icons.my_location_outlined),
                  label: const Text('Detect current location'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _gpsLat,
                        decoration: const InputDecoration(
                          labelText: 'GPS Latitude',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _gpsLng,
                        decoration: const InputDecoration(
                          labelText: 'GPS Longitude',
                        ),
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
              ],
            ),
            const SizedBox(height: 14),
            _ProfileSection(
              icon: Icons.call_outlined,
              color: Colors.blue,
              title: 'Contact',
              children: [
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Phone (+256…)'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    return RegExp(r'^\+?[0-9]{9,15}$').hasMatch(value)
                        ? null
                        : 'Enter a valid phone number';
                  },
                ),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)
                        ? null
                        : 'Enter a valid email address';
                  },
                ),
                TextField(
                  controller: _website,
                  decoration: const InputDecoration(labelText: 'Website'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ProfileSection(
              icon: Icons.public_outlined,
              color: Colors.deepOrange,
              title: 'Regional Settings',
              children: [
                _ProfileDropdown(
                  label: 'Time zone',
                  value: _timeZone.text,
                  values: const ['Africa/Kampala'],
                  onChanged: (value) => setState(() => _timeZone.text = value),
                ),
                _ProfileDropdown(
                  label: 'Currency',
                  value: _currency.text,
                  values: const ['UGX'],
                  onChanged: (value) => setState(() => _currency.text = value),
                ),
                _ProfileDropdown(
                  label: 'Language',
                  value: _language.text,
                  values: const ['English'],
                  onChanged: (value) => setState(() => _language.text = value),
                ),
                _ProfileDropdown(
                  label: 'Date format',
                  value: _dateFormat.text,
                  values: const ['dd/MM/yyyy', 'MM/dd/yyyy'],
                  onChanged: (value) =>
                      setState(() => _dateFormat.text = value),
                ),
                _ProfileDropdown(
                  label: 'Time format',
                  value: _timeFormat.text,
                  values: const ['24-hour', '12-hour'],
                  onChanged: (value) =>
                      setState(() => _timeFormat.text = value),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<Widget> children;

  const _ProfileSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  const _ProfileDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: values.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: values
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator: (value) => value == null ? 'Choose $label' : null,
    );
  }
}

class _InstitutionProfileSuccessScreen extends StatelessWidget {
  const _InstitutionProfileSuccessScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: .15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Institution profile saved',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Continue with the academic setup for your school.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () =>
                      context.go('/staff/admin/structure/academic?tab=0'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continue to academics'),
                ),
                TextButton(
                  onPressed: () =>
                      context.go('/staff/admin/structure?section=overview'),
                  child: const Text('Back to Structure'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandImagePicker extends StatelessWidget {
  const _BrandImagePicker({
    required this.label,
    required this.imageUrl,
    required this.isUploading,
    required this.onPick,
    this.onRemove,
  });

  final String label;
  final String imageUrl;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1,
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: isUploading ? null : onPick,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(Icons.broken_image_outlined, size: 32),
                      ),
                    )
                  else
                    const Center(
                      child: Icon(Icons.add_photo_alternate_outlined, size: 32),
                    ),
                  if (isUploading)
                    const ColoredBox(
                      color: Color(0x99000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ColoredBox(
                      color: Color(0x99000000),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          hasImage ? 'Change image' : 'Choose image',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onRemove != null)
          TextButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Remove'),
          ),
      ],
    );
  }
}
