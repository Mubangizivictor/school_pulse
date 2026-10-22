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

// Phone fields deliberately accept only digits and an optional leading `+`.
// This prevents letters and spaces from ever being entered.
final RegExp _phoneCharPattern = RegExp(r'[0-9+]');
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

String? _validateRequiredName(String? v) {
  final value = v?.trim() ?? '';
  if (value.isEmpty) return 'Required';
  return _nameWordPattern.hasMatch(value)
      ? null
      : 'Use letters, spaces, hyphens, or apostrophes only';
}

/// Stage 1 - Profile: "Tell us about the person". Required identity/contact
/// fields are always visible; everything optional (middle name, preferred
/// name, gender, nationality, alternate phone, address, emergency contact)
/// sits behind "More personal details" / "More contact details" disclosures
/// so the step reads as fast to fill on both desktop and mobile, matching
/// the reference design's two-column desktop layout / single-column mobile
/// disclosure layout.
class Stage01Profile extends StatefulWidget {
  final VoidCallback onSaveDraft;
  final VoidCallback onExit;

  const Stage01Profile({
    super.key,
    required this.onSaveDraft,
    required this.onExit,
  });

  @override
  State<Stage01Profile> createState() => _Stage01ProfileState();
}

class _Stage01ProfileState extends State<Stage01Profile> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _middle;
  late final TextEditingController _preferred;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _altPhone;
  late final TextEditingController _address;
  late final TextEditingController _nationality;
  late final TextEditingController _emergencyName;
  late final TextEditingController _emergencyRelationship;
  late final TextEditingController _emergencyPhone;
  late final TextEditingController _emergencyAltPhone;

  bool _morePersonalExpanded = false;
  bool _moreContactExpanded = false;

  static const List<String> _genderOptions = [
    'Female',
    'Male',
    'Prefer not to say',
  ];

  AddStaffWizardController? _controller;

  @override
  void initState() {
    super.initState();
    final draft = context.read<AddStaffWizardController>().draft;
    _first = TextEditingController(text: draft.firstName);
    _last = TextEditingController(text: draft.lastName);
    _middle = TextEditingController(text: draft.middleName);
    _preferred = TextEditingController(text: draft.preferredName);
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

    _morePersonalExpanded =
        draft.middleName.isNotEmpty ||
        draft.preferredName.isNotEmpty ||
        draft.nationality.isNotEmpty ||
        (draft.gender.isNotEmpty && draft.gender != 'Prefer not to say');
    _moreContactExpanded =
        draft.alternatePhone.isNotEmpty ||
        draft.address.isNotEmpty ||
        draft.emergencyContactName.isNotEmpty ||
        draft.emergencyContactPhone.isNotEmpty;

    // On first build, a saved draft may still be loading asynchronously
    // (AddStaffWizardPage awaits restoreDraftIfPresent() in a post-frame
    // callback, after this initState already captured the pre-restore,
    // empty draft into these controllers). Listen for the controller's
    // notifyListeners() from that restore and sync the text fields once -
    // TextEditingControllers are only seeded in initState and otherwise
    // never re-read draft values on rebuild, unlike the avatar initials
    // which are recomputed live from draft.fullName on every build.
    _controller = context.read<AddStaffWizardController>();
    _controller!.addListener(_syncFromDraftIfEmpty);
  }

  void _syncFromDraftIfEmpty() {
    if (!mounted) return;
    final draft = _controller!.draft;
    if (_first.text.isEmpty && draft.firstName.isNotEmpty) {
      _first.text = draft.firstName;
    }
    if (_last.text.isEmpty && draft.lastName.isNotEmpty) {
      _last.text = draft.lastName;
    }
    if (_middle.text.isEmpty && draft.middleName.isNotEmpty) {
      _middle.text = draft.middleName;
    }
    if (_preferred.text.isEmpty && draft.preferredName.isNotEmpty) {
      _preferred.text = draft.preferredName;
    }
    if (_email.text.isEmpty && draft.email.isNotEmpty) {
      _email.text = draft.email;
    }
    if (_phone.text.isEmpty && draft.phoneNumber.isNotEmpty) {
      _phone.text = draft.phoneNumber;
    }
    if (_altPhone.text.isEmpty && draft.alternatePhone.isNotEmpty) {
      _altPhone.text = draft.alternatePhone;
    }
    if (_address.text.isEmpty && draft.address.isNotEmpty) {
      _address.text = draft.address;
    }
    if (_nationality.text.isEmpty && draft.nationality.isNotEmpty) {
      _nationality.text = draft.nationality;
    }
    if (_emergencyName.text.isEmpty && draft.emergencyContactName.isNotEmpty) {
      _emergencyName.text = draft.emergencyContactName;
    }
    if (_emergencyRelationship.text.isEmpty &&
        draft.emergencyContactRelationship.isNotEmpty) {
      _emergencyRelationship.text = draft.emergencyContactRelationship;
    }
    if (_emergencyPhone.text.isEmpty &&
        draft.emergencyContactPhone.isNotEmpty) {
      _emergencyPhone.text = draft.emergencyContactPhone;
    }
    if (_emergencyAltPhone.text.isEmpty &&
        draft.emergencyContactAlternatePhone.isNotEmpty) {
      _emergencyAltPhone.text = draft.emergencyContactAlternatePhone;
    }
    setState(() {
      _morePersonalExpanded =
          _morePersonalExpanded ||
          draft.middleName.isNotEmpty ||
          draft.preferredName.isNotEmpty ||
          draft.nationality.isNotEmpty ||
          (draft.gender.isNotEmpty && draft.gender != 'Prefer not to say');
      _moreContactExpanded =
          _moreContactExpanded ||
          draft.alternatePhone.isNotEmpty ||
          draft.address.isNotEmpty ||
          draft.emergencyContactName.isNotEmpty ||
          draft.emergencyContactPhone.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(_syncFromDraftIfEmpty);
    _first.dispose();
    _last.dispose();
    _middle.dispose();
    _preferred.dispose();
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
    draft.lastName = _last.text.trim();
    draft.middleName = _middle.text.trim();
    draft.preferredName = _preferred.text.trim();
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
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.profile),
      onBack: widget.onExit,
      onSaveDraft: widget.onSaveDraft,
      contentPadding: EdgeInsets.fromLTRB(20, 0, 20, isWide ? 32 : 24),
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: 'Continue',
        onBack: widget.onExit,
        onNext: () {
          if (!_formKey.currentState!.validate()) return;
          _saveFieldsToDraft(draft);
          controller.next();
        },
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WizardStageHeading(
              title: 'Tell us about the person',
              subtitle: isWide
                  ? 'Add the essential details for this staff member. You can add work details and account access next.'
                  : 'Add the essential details for this staff member. You can add more details and account access next.',
            ),
            const SizedBox(height: 24),
            if (isWide)
              _DesktopLayout(
                photo: _PhotoPicker(
                  photo: draft.photo,
                  fullName: draft.fullName,
                  onTap: () => _pickPhoto(controller),
                ),
                personalDetails: _PersonalDetailsCard(
                  isWide: true,
                  firstController: _first,
                  lastController: _last,
                  middleController: _middle,
                  preferredController: _preferred,
                  nationalityController: _nationality,
                  gender: draft.gender,
                  onGenderChanged: (g) {
                    draft.gender = g;
                    controller.notifyDraftChanged();
                  },
                  expanded: _morePersonalExpanded,
                  onToggle: () => setState(
                    () => _morePersonalExpanded = !_morePersonalExpanded,
                  ),
                ),
                contactDetails: _ContactDetailsCard(
                  isWide: true,
                  emailController: _email,
                  phoneController: _phone,
                  altPhoneController: _altPhone,
                  addressController: _address,
                  emergencyNameController: _emergencyName,
                  emergencyRelationshipController: _emergencyRelationship,
                  emergencyPhoneController: _emergencyPhone,
                  emergencyAltPhoneController: _emergencyAltPhone,
                  expanded: _moreContactExpanded,
                  onToggle: () => setState(
                    () => _moreContactExpanded = !_moreContactExpanded,
                  ),
                ),
              )
            else
              _MobileLayout(
                photo: _PhotoPicker(
                  photo: draft.photo,
                  fullName: draft.fullName,
                  onTap: () => _pickPhoto(controller),
                ),
                personalDetails: _PersonalDetailsCard(
                  isWide: false,
                  firstController: _first,
                  lastController: _last,
                  middleController: _middle,
                  preferredController: _preferred,
                  nationalityController: _nationality,
                  gender: draft.gender,
                  onGenderChanged: (g) {
                    draft.gender = g;
                    controller.notifyDraftChanged();
                  },
                  expanded: _morePersonalExpanded,
                  onToggle: () => setState(
                    () => _morePersonalExpanded = !_morePersonalExpanded,
                  ),
                ),
                contactDetails: _ContactDetailsCard(
                  isWide: false,
                  emailController: _email,
                  phoneController: _phone,
                  altPhoneController: _altPhone,
                  addressController: _address,
                  emergencyNameController: _emergencyName,
                  emergencyRelationshipController: _emergencyRelationship,
                  emergencyPhoneController: _emergencyPhone,
                  emergencyAltPhoneController: _emergencyAltPhone,
                  expanded: _moreContactExpanded,
                  onToggle: () => setState(
                    () => _moreContactExpanded = !_moreContactExpanded,
                  ),
                ),
              ),
            const SizedBox(height: 14),
            _PrivacyNotice(
              text: 'Only authorised staff can view private contact details.',
            ),
            const SizedBox(height: 24),
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
}

/// Desktop: two-column layout - a wide "Personal details" + "Contact
/// details" column on the left, a narrow "Profile photo" card on the right.
class _DesktopLayout extends StatelessWidget {
  final Widget photo;
  final Widget personalDetails;
  final Widget contactDetails;

  const _DesktopLayout({
    required this.photo,
    required this.personalDetails,
    required this.contactDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              personalDetails,
              const SizedBox(height: 20),
              contactDetails,
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: _CardShell(
            title: 'Profile photo (optional)',
            child: Center(child: photo),
          ),
        ),
      ],
    );
  }
}

/// Mobile: single column - photo at the top, then Personal details and
/// Contact details cards each with an internal disclosure.
class _MobileLayout extends StatelessWidget {
  final Widget photo;
  final Widget personalDetails;
  final Widget contactDetails;

  const _MobileLayout({
    required this.photo,
    required this.personalDetails,
    required this.contactDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(alignment: Alignment.centerRight, child: photo),
        const SizedBox(height: 20),
        personalDetails,
        const SizedBox(height: 16),
        contactDetails,
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PersonalDetailsCard extends StatelessWidget {
  final bool isWide;
  final TextEditingController firstController;
  final TextEditingController lastController;
  final TextEditingController middleController;
  final TextEditingController preferredController;
  final TextEditingController nationalityController;
  final String gender;
  final ValueChanged<String> onGenderChanged;
  final bool expanded;
  final VoidCallback onToggle;

  const _PersonalDetailsCard({
    required this.isWide,
    required this.firstController,
    required this.lastController,
    required this.middleController,
    required this.preferredController,
    required this.nationalityController,
    required this.gender,
    required this.onGenderChanged,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final nameFields = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _labeledField(
                  context,
                  'First name',
                  required: true,
                  child: TextFormField(
                    controller: firstController,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(_nameCharPattern),
                    ],
                    decoration: const InputDecoration(hintText: 'First name'),
                    validator: _validateRequiredName,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _labeledField(
                  context,
                  'Last name',
                  required: true,
                  child: TextFormField(
                    controller: lastController,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(_nameCharPattern),
                    ],
                    decoration: const InputDecoration(hintText: 'Last name'),
                    validator: _validateRequiredName,
                  ),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labeledField(
                context,
                'First name',
                required: true,
                child: TextFormField(
                  controller: firstController,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(_nameCharPattern),
                  ],
                  decoration: const InputDecoration(hintText: 'First name'),
                  validator: _validateRequiredName,
                ),
              ),
              const SizedBox(height: 16),
              _labeledField(
                context,
                'Last name',
                required: true,
                child: TextFormField(
                  controller: lastController,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(_nameCharPattern),
                  ],
                  decoration: const InputDecoration(hintText: 'Last name'),
                  validator: _validateRequiredName,
                ),
              ),
            ],
          );

    final moreFields = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _labeledField(
                      context,
                      'Middle name (optional)',
                      child: TextFormField(
                        controller: middleController,
                        decoration: const InputDecoration(
                          hintText: 'Middle name',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _labeledField(
                      context,
                      'Preferred name (optional)',
                      child: TextFormField(
                        controller: preferredController,
                        decoration: const InputDecoration(
                          hintText: 'Preferred name',
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _labeledField(
                    context,
                    'Middle name (optional)',
                    child: TextFormField(
                      controller: middleController,
                      decoration: const InputDecoration(
                        hintText: 'Middle name',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _labeledField(
                    context,
                    'Preferred name (optional)',
                    child: TextFormField(
                      controller: preferredController,
                      decoration: const InputDecoration(
                        hintText: 'Preferred name',
                      ),
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 16),
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _labeledField(
                      context,
                      'Gender (optional)',
                      child: _GenderDropdown(
                        value: gender,
                        onChanged: onGenderChanged,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _labeledField(
                      context,
                      'Nationality (optional)',
                      child: TextFormField(
                        controller: nationalityController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(_nameCharPattern),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Nationality',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          if (!_nameWordPattern.hasMatch(v.trim())) {
                            return 'Letters only';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _labeledField(
                    context,
                    'Gender (optional)',
                    child: _GenderDropdown(
                      value: gender,
                      onChanged: onGenderChanged,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _labeledField(
                    context,
                    'Nationality (optional)',
                    child: TextFormField(
                      controller: nationalityController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(_nameCharPattern),
                      ],
                      decoration: const InputDecoration(
                        hintText: 'Nationality',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (!_nameWordPattern.hasMatch(v.trim())) {
                          return 'Letters only';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
      ],
    );

    return _CardShell(
      title: 'Personal details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          nameFields,
          const SizedBox(height: 4),
          _DisclosureToggle(
            label: 'More personal details (optional)',
            helper: 'Middle name, preferred name, gender, nationality',
            expanded: expanded,
            onTap: onToggle,
          ),
          if (expanded) moreFields,
        ],
      ),
    );
  }
}

class _ContactDetailsCard extends StatelessWidget {
  final bool isWide;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController altPhoneController;
  final TextEditingController addressController;
  final TextEditingController emergencyNameController;
  final TextEditingController emergencyRelationshipController;
  final TextEditingController emergencyPhoneController;
  final TextEditingController emergencyAltPhoneController;
  final bool expanded;
  final VoidCallback onToggle;

  const _ContactDetailsCard({
    required this.isWide,
    required this.emailController,
    required this.phoneController,
    required this.altPhoneController,
    required this.addressController,
    required this.emergencyNameController,
    required this.emergencyRelationshipController,
    required this.emergencyPhoneController,
    required this.emergencyAltPhoneController,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final primaryFields = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _labeledField(
                  context,
                  'Work email',
                  required: true,
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'name@school.edu',
                      prefixIcon: Icon(Icons.mail_outline, size: 18),
                    ),
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
                  helper: 'Used for account access and communications.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _labeledField(
                  context,
                  'Phone number',
                  required: true,
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(_phoneCharPattern),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Phone number',
                      prefixIcon: Icon(Icons.call_outlined, size: 18),
                    ),
                    validator: (v) => _validatePhone(v, required: true),
                  ),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labeledField(
                context,
                'Work email',
                required: true,
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'name@school.edu',
                    prefixIcon: Icon(Icons.mail_outline, size: 18),
                  ),
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
                helper: 'Used for account access and communications.',
              ),
              const SizedBox(height: 16),
              _labeledField(
                context,
                'Phone number',
                required: true,
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(_phoneCharPattern),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Phone number',
                    prefixIcon: Icon(Icons.call_outlined, size: 18),
                  ),
                  validator: (v) => _validatePhone(v, required: true),
                ),
              ),
            ],
          );

    final moreFields = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        _labeledField(
          context,
          'Alternate phone (optional)',
          child: TextFormField(
            controller: altPhoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(_phoneCharPattern),
            ],
            decoration: const InputDecoration(
              hintText: 'Alternate phone number',
              prefixIcon: Icon(Icons.call_outlined, size: 18),
            ),
            validator: (v) => _validatePhone(v, required: false),
          ),
        ),
        const SizedBox(height: 16),
        _labeledField(
          context,
          'Address (optional)',
          child: _AddressAutocompleteField(controller: addressController),
        ),
        const SizedBox(height: 16),
        _EmergencyContactFields(
          nameController: emergencyNameController,
          relationshipController: emergencyRelationshipController,
          phoneController: emergencyPhoneController,
          altPhoneController: emergencyAltPhoneController,
        ),
      ],
    );

    return _CardShell(
      title: 'Contact details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          primaryFields,
          const SizedBox(height: 4),
          _DisclosureToggle(
            label: 'More contact details (optional)',
            helper: 'Add address and emergency contact information.',
            icon: Icons.location_on_outlined,
            expanded: expanded,
            onTap: onToggle,
          ),
          if (expanded) moreFields,
        ],
      ),
    );
  }
}

Widget _labeledField(
  BuildContext context,
  String label, {
  required Widget child,
  bool required = false,
  String? helper,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
            children: required
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.danger(context)),
                    ),
                  ]
                : const [],
          ),
        ),
      ),
      child,
      if (helper != null)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            helper,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 11.5,
            ),
          ),
        ),
    ],
  );
}

class _GenderDropdown extends StatelessWidget {
  final String gender;
  final ValueChanged<String> onChanged;

  const _GenderDropdown({required String value, required this.onChanged})
    : gender = value;

  @override
  Widget build(BuildContext context) {
    final current = _Stage01ProfileState._genderOptions.contains(gender)
        ? gender
        : 'Prefer not to say';
    return DropdownButtonFormField<String>(
      initialValue: current,
      decoration: const InputDecoration(hintText: 'Gender'),
      items: _Stage01ProfileState._genderOptions
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _DisclosureToggle extends StatelessWidget {
  final String label;
  final String helper;
  final IconData? icon;
  final bool expanded;
  final VoidCallback onTap;

  const _DisclosureToggle({
    required this.label,
    required this.helper,
    this.icon,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border(context)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.textMuted(context)),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    helper,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: DottedCircleAvatar(photo: photo, initials: _initials),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.file_upload_outlined, size: 16),
          label: const Text('Upload photo'),
        ),
        const SizedBox(height: 8),
        Text(
          'Used only where your school chooses to display staff profiles.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted(context), fontSize: 11),
        ),
      ],
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

class _EmergencyContactFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController relationshipController;
  final TextEditingController phoneController;
  final TextEditingController altPhoneController;

  const _EmergencyContactFields({
    required this.nameController,
    required this.relationshipController,
    required this.phoneController,
    required this.altPhoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency contact (optional)',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Used only if the school needs to reach someone.',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: relationshipController,
            decoration: const InputDecoration(labelText: 'Relationship'),
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
            decoration: const InputDecoration(labelText: 'Alternate phone'),
            validator: (v) => (v?.trim().isNotEmpty ?? false)
                ? _validatePhone(v, required: false)
                : null,
          ),
        ],
      ),
    );
  }
}

class _PrivacyNotice extends StatelessWidget {
  final String text;

  const _PrivacyNotice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.shield_outlined,
          size: 16,
          color: AppColors.textMuted(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
          ),
        ),
      ],
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
                      fontSize: 12.5,
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
            prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
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
