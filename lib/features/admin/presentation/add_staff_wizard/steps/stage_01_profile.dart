import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/location/nominatim_address_service.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../add_staff_wizard_controller.dart';
import '../models/add_staff_draft.dart';

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

/// Stage 1 - Profile: "Tell us about the person". Combines what used to be
/// Personal Information, Contact Information, and Documents into one stage
/// with clear sections, matching the reference design.
class Stage01Profile extends StatefulWidget {
  final VoidCallback onSaveDraft;

  const Stage01Profile({super.key, required this.onSaveDraft});

  @override
  State<Stage01Profile> createState() => _Stage01ProfileState();
}

class _Stage01ProfileState extends State<Stage01Profile> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _first;
  late final TextEditingController _middle;
  late final TextEditingController _last;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _altPhone;
  late final TextEditingController _address;
  late final TextEditingController _nationality;
  late final TextEditingController _emergencyName;
  late final TextEditingController _emergencyRelationship;
  late final TextEditingController _emergencyPhone;
  late final TextEditingController _emergencyAltPhone;

  bool _emergencyExpanded = true;

  @override
  void initState() {
    super.initState();
    final draft = context.read<AddStaffWizardController>().draft;
    _first = TextEditingController(text: draft.firstName);
    _middle = TextEditingController(text: draft.middleName);
    _last = TextEditingController(text: draft.lastName);
    _email = TextEditingController(text: draft.email);
    _phone = TextEditingController(text: draft.phoneNumber);
    _altPhone = TextEditingController(text: draft.alternatePhone);
    _address = TextEditingController(text: draft.address);
    _nationality = TextEditingController(text: draft.nationality);
    _emergencyName = TextEditingController(text: draft.emergencyContactName);
    _emergencyRelationship = TextEditingController(
      text: draft.emergencyContactRelationship,
    );
    _emergencyPhone = TextEditingController(text: draft.emergencyContactPhone);
    _emergencyAltPhone = TextEditingController(
      text: draft.emergencyContactAlternatePhone,
    );
    _emergencyExpanded =
        draft.emergencyContactName.isNotEmpty ||
        draft.emergencyContactPhone.isNotEmpty;
  }

  @override
  void dispose() {
    _first.dispose();
    _middle.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    _altPhone.dispose();
    _address.dispose();
    _nationality.dispose();
    _emergencyName.dispose();
    _emergencyRelationship.dispose();
    _emergencyPhone.dispose();
    _emergencyAltPhone.dispose();
    super.dispose();
  }

  void _saveFieldsToDraft(AddStaffDraft draft) {
    draft.firstName = _first.text.trim();
    draft.middleName = _middle.text.trim();
    draft.lastName = _last.text.trim();
    draft.email = _email.text.trim();
    draft.phoneNumber = _phone.text.trim();
    draft.alternatePhone = _altPhone.text.trim();
    draft.address = _address.text.trim();
    draft.nationality = _nationality.text.trim();
    draft.emergencyContactName = _emergencyName.text.trim();
    draft.emergencyContactRelationship = _emergencyRelationship.text.trim();
    draft.emergencyContactPhone = _emergencyPhone.text.trim();
    draft.emergencyContactAlternatePhone = _emergencyAltPhone.text.trim();
  }

  Future<void> _pickPhoto(AddStaffWizardController controller) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      controller.draft.photo = File(picked.path);
      controller.notifyDraftChanged();
    }
  }

  Future<void> _pickForType(
    AddStaffWizardController controller,
    StaffDocumentType type,
  ) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    if (result == null || result.files.single.path == null) return;
    final file = result.files.single;
    controller.draft.documents.removeWhere((d) => d.type == type);
    controller.draft.documents.add(
      StagedDocument(type: type, file: File(file.path!), fileName: file.name),
    );
    controller.notifyDraftChanged();
  }

  void _removeDocument(
    AddStaffWizardController controller,
    StaffDocumentType type,
  ) {
    controller.draft.documents.removeWhere((d) => d.type == type);
    controller.notifyDraftChanged();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    final draft = controller.draft;
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.profile),
      onBack: () => Navigator.of(context).maybePop(),
      onSaveDraft: widget.onSaveDraft,
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: 'Continue',
        onBack: () => Navigator.of(context).maybePop(),
        onNext: () {
          if (!_formKey.currentState!.validate()) return;
          _saveFieldsToDraft(draft);
          controller.next();
        },
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WizardStageHeading(
              title: 'Tell us about the person',
              subtitle: 'Add the basic details about this staff member.',
            ),
            const SizedBox(height: 24),
            _PhotoPicker(
              photo: draft.photo,
              fullName: draft.fullName,
              onTap: () => _pickPhoto(controller),
            ),
            const SizedBox(height: 24),
            isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _labeledField(
                          'First name',
                          TextFormField(
                            controller: _first,
                            decoration: const InputDecoration(
                              hintText: 'First name',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _labeledField(
                          'Last name',
                          TextFormField(
                            controller: _last,
                            decoration: const InputDecoration(
                              hintText: 'Last name',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labeledField(
                        'First name',
                        TextFormField(
                          controller: _first,
                          decoration: const InputDecoration(
                            hintText: 'First name',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _labeledField(
                        'Last name',
                        TextFormField(
                          controller: _last,
                          decoration: const InputDecoration(
                            hintText: 'Last name',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 16),
            _labeledField(
              'Middle name (optional)',
              TextFormField(
                controller: _middle,
                decoration: const InputDecoration(hintText: 'Middle name'),
              ),
            ),
            const SizedBox(height: 16),
            _labeledField(
              'Gender',
              Row(
                children: [
                  Expanded(
                    child: _SegmentChip(
                      label: 'Woman',
                      selected: draft.gender == 'Female',
                      onTap: () {
                        draft.gender = 'Female';
                        controller.notifyDraftChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SegmentChip(
                      label: 'Man',
                      selected: draft.gender == 'Male',
                      onTap: () {
                        draft.gender = 'Male';
                        controller.notifyDraftChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SegmentChip(
                      label: 'Prefer not to say',
                      selected: draft.gender == 'Prefer not to say',
                      onTap: () {
                        draft.gender = 'Prefer not to say';
                        controller.notifyDraftChanged();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _labeledField(
              'Nationality (optional)',
              TextFormField(
                controller: _nationality,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(_nameCharPattern),
                ],
                decoration: const InputDecoration(hintText: 'Nationality'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (!_nameWordPattern.hasMatch(v.trim())) {
                    return 'Letters only';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 20),
            WizardSectionLabel(
              label: 'Contact & emergency',
              helper:
                  'How we can reach this staff member and who to contact in an emergency.',
            ),
            const SizedBox(height: 14),
            _labeledField(
              'Email',
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email address'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  ).hasMatch(v.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            _labeledField(
              'Phone',
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(_phoneCharPattern),
                ],
                decoration: const InputDecoration(hintText: 'Phone number'),
                validator: (v) => _validatePhone(v, required: true),
              ),
            ),
            const SizedBox(height: 16),
            _labeledField(
              'Alternate phone (optional)',
              TextFormField(
                controller: _altPhone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(_phoneCharPattern),
                ],
                decoration: const InputDecoration(
                  hintText: 'Alternate phone number',
                ),
                validator: (v) => _validatePhone(v, required: false),
              ),
            ),
            const SizedBox(height: 16),
            _labeledField(
              'Address (optional)',
              _AddressAutocompleteField(controller: _address),
            ),
            const SizedBox(height: 20),
            _EmergencyContactCard(
              expanded: _emergencyExpanded,
              onToggle: () =>
                  setState(() => _emergencyExpanded = !_emergencyExpanded),
              nameController: _emergencyName,
              relationshipController: _emergencyRelationship,
              phoneController: _emergencyPhone,
              altPhoneController: _emergencyAltPhone,
            ),
            const SizedBox(height: 28),
            const Divider(height: 1),
            const SizedBox(height: 20),
            const WizardSectionLabel(
              label: 'Staff documents',
              helper: 'PDF, JPG or PNG. Optional - add now or later.',
            ),
            const SizedBox(height: 12),
            ...StaffDocumentType.values.map((type) {
              final staged = draft.documents
                  .where((d) => d.type == type)
                  .toList();
              return _DocumentRow(
                label: type.label,
                fileName: staged.isEmpty ? null : staged.first.fileName,
                onAdd: () => _pickForType(controller, type),
                onRemove: staged.isEmpty
                    ? null
                    : () => _removeDocument(controller, type),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _labeledField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Builder(
            builder: (context) => Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
        ),
        field,
      ],
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final File? photo;
  final String fullName;
  final VoidCallback onTap;

  const _PhotoPicker({
    required this.photo,
    required this.fullName,
    required this.onTap,
  });

  String get _initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    final first = parts.first[0];
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                DottedCircleAvatar(photo: photo, initials: _initials),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textPrimary(context),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 18,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onTap,
            child: Text(
              'Add photo',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedCircleAvatar extends StatelessWidget {
  final File? photo;
  final String initials;

  const DottedCircleAvatar({super.key, this.photo, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border(context), width: 1.5),
        color: AppColors.surfaceContainer(context),
      ),
      alignment: Alignment.center,
      child: photo != null
          ? ClipOval(
              child: Image.file(
                photo!,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            )
          : (initials.isEmpty
                ? Icon(
                    Icons.person_outline,
                    size: 40,
                    color: AppColors.textMuted(context),
                  )
                : Text(
                    initials,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context),
                    ),
                  )),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.textPrimary(context) : Colors.transparent,
          border: Border.all(color: AppColors.border(context)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : AppColors.textPrimary(context),
          ),
        ),
      ),
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final TextEditingController nameController;
  final TextEditingController relationshipController;
  final TextEditingController phoneController;
  final TextEditingController altPhoneController;

  const _EmergencyContactCard({
    required this.expanded,
    required this.onToggle,
    required this.nameController,
    required this.relationshipController,
    required this.phoneController,
    required this.altPhoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency contact (optional)',
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Used only if the school needs to reach someone.',
                          style: TextStyle(
                            color: AppColors.textMuted(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textMuted(context),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full name'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: relationshipController,
                    decoration: const InputDecoration(
                      labelText: 'Relationship',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(_phoneCharPattern),
                    ],
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (v) => (v?.trim().isNotEmpty ?? false)
                        ? _validatePhone(v, required: false)
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: altPhoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(_phoneCharPattern),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Alternate phone',
                    ),
                    validator: (v) => (v?.trim().isNotEmpty ?? false)
                        ? _validatePhone(v, required: false)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final String label;
  final String? fileName;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;

  const _DocumentRow({
    required this.label,
    required this.fileName,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border(context)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                  Text(
                    fileName ?? 'Not added',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (fileName != null) ...[
              TextButton(onPressed: onAdd, child: const Text('Replace')),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textMuted(context),
                ),
              ),
            ] else
              TextButton(onPressed: onAdd, child: const Text('Add document')),
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
            hintText: 'Address',
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
