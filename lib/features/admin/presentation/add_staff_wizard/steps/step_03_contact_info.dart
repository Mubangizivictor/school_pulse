import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/location/nominatim_address_service.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../add_staff_wizard_controller.dart';

final RegExp _phoneCharPattern = RegExp(r'[0-9+\-\s()]');
final RegExp _phoneDigitsPattern = RegExp(r'^\+?[0-9]{7,15}$');
final RegExp _nameCharPattern = RegExp(r"[a-zA-Z\s\-']");
final RegExp _nameWordPattern = RegExp(r"^[a-zA-Z][a-zA-Z\s\-']*$");

String? _validatePhone(String? v, {required bool required}) {
  final value = v?.trim() ?? '';
  if (value.isEmpty) return required ? 'Required' : null;
  final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.length < 7 ||
      !_phoneDigitsPattern.hasMatch(
        value.replaceAll(RegExp(r'[\s()\-]'), ''),
      )) {
    return 'Enter a valid phone number';
  }
  return null;
}

class Step03ContactInfo extends StatefulWidget {
  const Step03ContactInfo({super.key});

  @override
  State<Step03ContactInfo> createState() => _Step03ContactInfoState();
}

class _Step03ContactInfoState extends State<Step03ContactInfo> {
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _altPhone;
  late final TextEditingController _address;
  late final TextEditingController _nationality;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final draft = context.read<AddStaffWizardController>().draft;
    _email = TextEditingController(text: draft.email);
    _phone = TextEditingController(text: draft.phoneNumber);
    _altPhone = TextEditingController(text: draft.alternatePhone);
    _address = TextEditingController(text: draft.address);
    _nationality = TextEditingController(
      text: draft.nationality.isEmpty ? 'Ugandan' : draft.nationality,
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _altPhone.dispose();
    _address.dispose();
    _nationality.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    final draft = controller.draft;

    return WizardScaffold(
      title: 'Add Staff Member',
      currentStep: stepNumberFor(WizardStep.contactInfo),
      totalSteps: kWizardTotalSteps,
      onBack: () => controller.back(),
      footer: WizardFooterButtons(
        onBack: () => controller.back(),
        onNext: () {
          if (!_formKey.currentState!.validate()) return;
          draft.email = _email.text.trim();
          draft.phoneNumber = _phone.text.trim();
          draft.alternatePhone = _altPhone.text.trim();
          draft.address = _address.text.trim();
          draft.nationality = _nationality.text.trim();
          controller.next();
        },
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WizardStepCaption(
              number: 2,
              title: 'Contact Information',
              subtitle: 'Enter contact details',
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(_phoneCharPattern),
              ],
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) => _validatePhone(v, required: true),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _altPhone,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(_phoneCharPattern),
              ],
              decoration: const InputDecoration(
                labelText: 'Alternative Phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) => _validatePhone(v, required: false),
            ),
            const SizedBox(height: 14),
            _AddressAutocompleteField(controller: _address),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nationality,
              inputFormatters: [
                FilteringTextInputFormatter.allow(_nameCharPattern),
              ],
              decoration: const InputDecoration(
                labelText: 'Nationality',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (!_nameWordPattern.hasMatch(v.trim())) {
                  return 'Letters only';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Address field with Nominatim-backed place suggestions. Debounced to
/// respect Nominatim's ~1 request/second usage policy; picking a suggestion
/// fills in county/region/country so the admin doesn't have to type them.
class _AddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;

  const _AddressAutocompleteField({required this.controller});

  @override
  State<_AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<_AddressAutocompleteField> {
  final _service = NominatimAddressService();
  Timer? _debounce;
  List<AddressSuggestion> _suggestions = const [];
  bool _loading = false;
  bool _suppressNextSearch = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_suppressNextSearch) {
      _suppressNextSearch = false;
      return;
    }
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      setState(() => _loading = true);
      final results = await _service.search(value);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _loading = false;
      });
    });
  }

  void _pick(AddressSuggestion s) {
    final parts = [
      s.displayName.split(',').first.trim(),
      if (s.county != null) s.county!,
      if (s.region != null) s.region!,
      if (s.country != null) s.country!,
    ];
    _suppressNextSearch = true;
    widget.controller.text = parts.join(', ');
    widget.controller.selection = TextSelection.collapsed(
      offset: widget.controller.text.length,
    );
    setState(() => _suggestions = const []);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          onChanged: _onChanged,
          decoration: InputDecoration(
            labelText: 'Address',
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _suggestions.map((s) {
                return InkWell(
                  onTap: () => _pick(s),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Text(
                      s.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
