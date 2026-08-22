import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/models/add_staff_draft.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/update_staff_member.dart';
import 'package:school_pulse/features/structure/domain/entities/campus_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

const _employmentTypes = ['Permanent', 'Contract', 'Part-Time', 'Volunteer'];

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

/// Editable counterpart to StaffDetailScreen's read-only Profile tab.
/// Reached via the AppBar edit action, gated by
/// AddStaffWizardController.canSubmit on the current admin's roles.
class EditStaffScreen extends StatefulWidget {
  final UserEntity user;
  const EditStaffScreen({super.key, required this.user});

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  late final StructureRepository _structureRepository;

  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _altPhone;
  late final TextEditingController _address;
  late final TextEditingController _nationality;

  String? _employmentType;
  String? _departmentId;
  String? _designationId;
  String? _campusId;
  DateTime? _dateJoined;
  late List<StaffDocumentRef> _documents;

  bool _saving = false;
  StaffDocumentType? _uploadingType;

  @override
  void initState() {
    super.initState();
    _structureRepository = di.sl<StructureRepository>();
    final user = widget.user;
    _name = TextEditingController(text: user.name);
    _email = TextEditingController(text: user.email);
    _phone = TextEditingController(text: user.phoneNumber ?? '');
    _altPhone = TextEditingController(text: user.alternatePhone ?? '');
    _address = TextEditingController(text: user.address ?? '');
    _nationality = TextEditingController(text: user.nationality ?? '');
    _employmentType = user.employmentType;
    _departmentId = user.departmentId;
    _designationId = user.designationId;
    _campusId = user.campusId;
    _dateJoined = user.dateJoined;
    _documents = List.of(user.documents);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _altPhone.dispose();
    _address.dispose();
    _nationality.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateJoined ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dateJoined = picked);
  }

  Future<void> _pickAndUpload(StaffDocumentType type) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    if (result == null || result.files.single.path == null) return;
    final file = result.files.single;
    setState(() => _uploadingType = type);
    try {
      final storagePath =
          'schools/${widget.user.schoolId}/staff/${widget.user.id}/documents/${type.name}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      await FirebaseStorage.instance.ref(storagePath).putFile(File(file.path!));
      final newRef = StaffDocumentRef(
        type: type.name,
        fileName: file.name,
        storagePath: storagePath,
        uploadedAt: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .update({
            'documents': FieldValue.arrayUnion([newRef.toJson()]),
          });
      if (!mounted) return;
      setState(() {
        _documents = [..._documents.where((d) => d.type != type.name), newRef];
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload ${file.name}')));
    } finally {
      if (mounted) setState(() => _uploadingType = null);
    }
  }

  Future<void> _viewDocument(StaffDocumentRef doc) async {
    try {
      final url = await FirebaseStorage.instance
          .ref(doc.storagePath)
          .getDownloadURL();
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open document')));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updated = widget.user.copyWith(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phoneNumber: _phone.text.trim(),
      alternatePhone: _altPhone.text.trim(),
      address: _address.text.trim(),
      nationality: _nationality.text.trim(),
      employmentType: _employmentType,
      departmentId: _departmentId,
      designationId: _designationId,
      campusId: _campusId,
      dateJoined: _dateJoined,
      documents: _documents,
    );

    final result = await di.sl<UpdateStaffMember>()(updated);
    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: ${failure.message}')),
      ),
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Staff profile updated')));
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AdminAppBar(
        title: 'Edit Staff',
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address *',
                      prefixIcon: Icon(Icons.email_outlined),
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
                  TextFormField(
                    controller: _address,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
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
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employment Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _employmentType,
                    decoration: const InputDecoration(
                      labelText: 'Employment Type',
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                    items: _employmentTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _employmentType = v),
                  ),
                  const SizedBox(height: 14),
                  StreamBuilder<List<Department>>(
                    stream: _structureRepository.watchDepartments(
                      widget.user.schoolId,
                    ),
                    builder: (context, snapshot) {
                      final departments =
                          (snapshot.data ?? const [])
                              .where((d) => d.isActive)
                              .toList()
                            ..sort((a, b) => a.name.compareTo(b.name));
                      final value =
                          departments.any((d) => d.id == _departmentId)
                          ? _departmentId
                          : null;
                      return DropdownButtonFormField<String>(
                        initialValue: value,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          prefixIcon: Icon(Icons.apartment_outlined),
                        ),
                        items: departments
                            .map(
                              (d) => DropdownMenuItem(
                                value: d.id,
                                child: Text(d.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _departmentId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  StreamBuilder<List<StaffDesignation>>(
                    stream: _structureRepository.watchDesignations(
                      widget.user.schoolId,
                    ),
                    builder: (context, snapshot) {
                      final designations = (snapshot.data ?? const []).toList()
                        ..sort((a, b) => a.name.compareTo(b.name));
                      final value =
                          designations.any((d) => d.id == _designationId)
                          ? _designationId
                          : null;
                      return DropdownButtonFormField<String>(
                        initialValue: value,
                        decoration: const InputDecoration(
                          labelText: 'Designation',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        items: designations
                            .map(
                              (d) => DropdownMenuItem(
                                value: d.id,
                                child: Text(d.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _designationId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  StreamBuilder<List<Campus>>(
                    stream: _structureRepository.watchCampuses(
                      widget.user.schoolId,
                    ),
                    builder: (context, snapshot) {
                      final campuses =
                          (snapshot.data ?? const [])
                              .where((c) => c.isActive)
                              .toList()
                            ..sort((a, b) => a.order.compareTo(b.order));
                      if (campuses.length <= 1) return const SizedBox.shrink();
                      final value = campuses.any((c) => c.id == _campusId)
                          ? _campusId
                          : null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: DropdownButtonFormField<String>(
                          initialValue: value,
                          decoration: const InputDecoration(
                            labelText: 'Campus',
                            prefixIcon: Icon(Icons.location_city_outlined),
                          ),
                          items: campuses
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _campusId = v),
                        ),
                      );
                    },
                  ),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date Joined',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        _dateJoined != null
                            ? '${_dateJoined!.day}/${_dateJoined!.month}/${_dateJoined!.year}'
                            : 'Not set',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Documents',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            ...StaffDocumentType.values.map((type) {
              final existing = _documents
                  .where((d) => d.type == type.name)
                  .lastOrNull;
              final uploading = _uploadingType == type;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: AppColors.primary(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.label,
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              existing?.fileName ?? 'No document uploaded',
                              style: TextStyle(
                                color: AppColors.textMuted(context),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (uploading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else ...[
                        if (existing != null)
                          IconButton(
                            icon: const Icon(Icons.open_in_new),
                            tooltip: 'View',
                            onPressed: () => _viewDocument(existing),
                          ),
                        IconButton(
                          icon: Icon(
                            existing == null
                                ? Icons.upload_outlined
                                : Icons.refresh,
                          ),
                          tooltip: existing == null ? 'Upload' : 'Replace',
                          onPressed: () => _pickAndUpload(type),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Save Changes',
              onPressed: _saving ? null : _save,
              isLoading: _saving,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

extension _LastOrNull<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
