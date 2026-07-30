import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../domain/entities/institution_profile.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';

/// Full institutional identity/profile - a single form, saved as one
/// document (like Feature Toggles), not a list of records.
class InstitutionProfileScreen extends StatelessWidget {
  const InstitutionProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) => _InstitutionProfileForm(profile: state.institutionProfile),
    );
  }
}

class _InstitutionProfileForm extends StatefulWidget {
  final InstitutionProfile profile;
  const _InstitutionProfileForm({required this.profile});

  @override
  State<_InstitutionProfileForm> createState() => _InstitutionProfileFormState();
}

class _InstitutionProfileFormState extends State<_InstitutionProfileForm> {
  late final TextEditingController _name;
  late final TextEditingController _shortName;
  late final TextEditingController _motto;
  late final TextEditingController _vision;
  late final TextEditingController _mission;
  late final TextEditingController _logoUrl;
  late final TextEditingController _badgeUrl;
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
    _logoUrl = TextEditingController(text: p.logoUrl);
    _badgeUrl = TextEditingController(text: p.badgeUrl);
    _schoolType = TextEditingController(text: p.schoolType);
    _schoolCategory = TextEditingController(text: p.schoolCategory);
    _registrationNumber = TextEditingController(text: p.registrationNumber);
    _ministryRegistrationNumber = TextEditingController(text: p.ministryRegistrationNumber);
    _taxNumber = TextEditingController(text: p.taxNumber);
    _country = TextEditingController(text: p.country);
    _district = TextEditingController(text: p.district);
    _city = TextEditingController(text: p.city);
    _address = TextEditingController(text: p.address);
    _gpsLat = TextEditingController(text: p.gpsLat?.toString() ?? '');
    _gpsLng = TextEditingController(text: p.gpsLng?.toString() ?? '');
    _phone = TextEditingController(text: p.phone);
    _email = TextEditingController(text: p.email);
    _website = TextEditingController(text: p.website);
    _timeZone = TextEditingController(text: p.timeZone);
    _currency = TextEditingController(text: p.currency);
    _language = TextEditingController(text: p.language);
    _dateFormat = TextEditingController(text: p.dateFormat);
    _timeFormat = TextEditingController(text: p.timeFormat);
  }

  @override
  void dispose() {
    for (final c in [
      _name, _shortName, _motto, _vision, _mission, _logoUrl, _badgeUrl, _schoolType, _schoolCategory,
      _registrationNumber, _ministryRegistrationNumber, _taxNumber, _country, _district, _city, _address,
      _gpsLat, _gpsLng, _phone, _email, _website, _timeZone, _currency, _language, _dateFormat, _timeFormat,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final profile = InstitutionProfile(
      name: _name.text,
      shortName: _shortName.text,
      motto: _motto.text,
      vision: _vision.text,
      mission: _mission.text,
      logoUrl: _logoUrl.text,
      badgeUrl: _badgeUrl.text,
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
    context.read<StructureBloc>().add(UpdateInstitutionProfileRequested(profile));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Institution profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institution Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.save_outlined), tooltip: 'Save', onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileSection(
            icon: Icons.badge_outlined,
            color: Colors.indigo,
            title: 'Identity',
            children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Institution Name')),
              TextField(controller: _shortName, decoration: const InputDecoration(labelText: 'Short Name')),
              TextField(controller: _motto, decoration: const InputDecoration(labelText: 'Motto')),
              TextField(controller: _vision, decoration: const InputDecoration(labelText: 'Vision'), maxLines: 2),
              TextField(controller: _mission, decoration: const InputDecoration(labelText: 'Mission'), maxLines: 2),
              TextField(controller: _logoUrl, decoration: const InputDecoration(labelText: 'Logo URL')),
              TextField(controller: _badgeUrl, decoration: const InputDecoration(labelText: 'Badge URL')),
              TextField(controller: _schoolType, decoration: const InputDecoration(labelText: 'School Type')),
              TextField(controller: _schoolCategory, decoration: const InputDecoration(labelText: 'School Category')),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSection(
            icon: Icons.gavel_outlined,
            color: Colors.teal,
            title: 'Registration',
            children: [
              TextField(controller: _registrationNumber, decoration: const InputDecoration(labelText: 'Registration Number')),
              TextField(controller: _ministryRegistrationNumber, decoration: const InputDecoration(labelText: 'Ministry Registration')),
              TextField(controller: _taxNumber, decoration: const InputDecoration(labelText: 'Tax Number (optional)')),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSection(
            icon: Icons.place_outlined,
            color: Colors.brown,
            title: 'Location',
            children: [
              TextField(controller: _country, decoration: const InputDecoration(labelText: 'Country')),
              TextField(controller: _district, decoration: const InputDecoration(labelText: 'District')),
              TextField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
              TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address'), maxLines: 2),
              Row(
                children: [
                  Expanded(child: TextField(controller: _gpsLat, decoration: const InputDecoration(labelText: 'GPS Latitude'), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _gpsLng, decoration: const InputDecoration(labelText: 'GPS Longitude'), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true))),
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
              TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: _website, decoration: const InputDecoration(labelText: 'Website')),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileSection(
            icon: Icons.public_outlined,
            color: Colors.deepOrange,
            title: 'Regional Settings',
            children: [
              TextField(controller: _timeZone, decoration: const InputDecoration(labelText: 'Time Zone')),
              TextField(controller: _currency, decoration: const InputDecoration(labelText: 'Currency')),
              TextField(controller: _language, decoration: const InputDecoration(labelText: 'Language')),
              TextField(controller: _dateFormat, decoration: const InputDecoration(labelText: 'Date Format (e.g. dd/MM/yyyy)')),
              TextField(controller: _timeFormat, decoration: const InputDecoration(labelText: 'Time Format (e.g. 24-hour)')),
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
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.icon, required this.color, required this.title, required this.children});

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
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
