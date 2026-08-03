import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import '../../domain/entities/campus_entities.dart';
import 'structure_dialogs.dart' show kSubjectColorSwatches;
import 'structure_ui_kit.dart';

String _colorToHex(Color color) => '#${color.toARGB32().toRadixString(16).substring(2)}';

Future<void> showCampusFormDialog(BuildContext context, {Campus? existing, required String schoolId, required void Function(Campus) onSave}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final codeController = TextEditingController(text: existing?.code);
  final addressController = TextEditingController(text: existing?.address);
  final districtController = TextEditingController(text: existing?.district);
  final phoneController = TextEditingController(text: existing?.contactPhone);
  final emailController = TextEditingController(text: existing?.contactEmail);
  bool isPrimary = existing?.isPrimary ?? false;
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Campus' : 'Edit Campus',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          PulseTextField(
            label: 'Campus Name',
            hint: 'e.g. Main Campus, Jinja Branch',
            controller: nameController,
            isRequired: true,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          PulseTextField(
            label: 'Code',
            hint: 'Optional',
            controller: codeController,
          ),
          PulseTextField(
            label: 'Address',
            hint: 'Optional',
            controller: addressController,
          ),
          PulseTextField(
            label: 'District',
            hint: 'Optional',
            controller: districtController,
          ),
          PulseTextField(
            label: 'Contact Phone',
            hint: 'Optional',
            controller: phoneController,
          ),
          PulseTextField(
            label: 'Contact Email',
            hint: 'Optional',
            controller: emailController,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Primary Campus'),
            value: isPrimary,
            onChanged: (v) => setState(() => isPrimary = v),
          ),
          if (existing != null)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
            ),
        ],
      ),
    ),
    onSubmit: () {
      if (!formKey.currentState!.validate()) return;
      onSave(Campus(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: existing?.schoolId ?? schoolId,
        name: nameController.text,
        code: codeController.text,
        address: addressController.text,
        district: districtController.text,
        contactPhone: phoneController.text.isEmpty ? null : phoneController.text,
        contactEmail: emailController.text.isEmpty ? null : emailController.text,
        isPrimary: isPrimary,
        isActive: isActive,
        order: existing?.order ?? 0,
        archivedAt: existing?.archivedAt,
      ));
      Navigator.pop(context);
    },
  );
}

Future<void> showHouseFormDialog(BuildContext context, {House? existing, required String schoolId, required void Function(House) onSave}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final descController = TextEditingController(text: existing?.description);
  Color selectedColor = existing?.colorHex.isNotEmpty == true
      ? Color(int.parse(existing!.colorHex.replaceFirst('#', '0xff')))
      : kSubjectColorSwatches.first;
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add House' : 'Edit House',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          PulseTextField(
            label: 'House Name',
            hint: 'e.g. Blue House',
            controller: nameController,
            isRequired: true,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('House Color', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: kSubjectColorSwatches.map((c) {
                  final selected = c.toARGB32() == selectedColor.toARGB32();
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = c),
                    child: CircleAvatar(
                      backgroundColor: c,
                      radius: 14,
                      child: selected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          PulseTextField(
            label: 'Description',
            hint: 'Optional',
            controller: descController,
            maxLines: 2,
          ),
          if (existing != null)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
            ),
        ],
      ),
    ),
    onSubmit: () {
      if (!formKey.currentState!.validate()) return;
      onSave(House(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: existing?.schoolId ?? schoolId,
        name: nameController.text,
        colorHex: _colorToHex(selectedColor),
        description: descController.text,
        isActive: isActive,
      ));
      Navigator.pop(context);
    },
  );
}

Future<void> showClubFormDialog(BuildContext context, {Club? existing, required String schoolId, required void Function(Club) onSave}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final categoryController = TextEditingController(text: existing?.category);
  final descController = TextEditingController(text: existing?.description);
  final patronController = TextEditingController(text: existing?.patronName);
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Club / Society' : 'Edit Club / Society',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          PulseTextField(
            label: 'Club Name',
            hint: 'e.g. Debate, Robotics',
            controller: nameController,
            isRequired: true,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          PulseTextField(
            label: 'Category',
            hint: 'Optional',
            controller: categoryController,
          ),
          PulseTextField(
            label: 'Patron',
            hint: 'Optional',
            controller: patronController,
          ),
          PulseTextField(
            label: 'Description',
            hint: 'Optional',
            controller: descController,
            maxLines: 2,
          ),
          if (existing != null)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
            ),
        ],
      ),
    ),
    onSubmit: () {
      if (!formKey.currentState!.validate()) return;
      onSave(Club(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: existing?.schoolId ?? schoolId,
        name: nameController.text,
        category: categoryController.text,
        description: descController.text,
        patronName: patronController.text,
        isActive: isActive,
      ));
      Navigator.pop(context);
    },
  );
}

Future<void> showFacilityFormDialog(BuildContext context, {Facility? existing, required String schoolId, required void Function(Facility) onSave}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final typeController = TextEditingController(text: existing?.facilityType);
  final locationController = TextEditingController(text: existing?.location);
  final capacityController = TextEditingController(text: existing?.capacity.toString() ?? '0');
  final descController = TextEditingController(text: existing?.description);
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Facility' : 'Edit Facility',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          PulseTextField(
            label: 'Facility Name',
            hint: 'e.g. Main Library',
            controller: nameController,
            isRequired: true,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          PulseTextField(
            label: 'Type',
            hint: 'e.g. Library, Laboratory',
            controller: typeController,
          ),
          PulseTextField(
            label: 'Location / Building',
            hint: 'Optional',
            controller: locationController,
          ),
          PulseTextField(
            label: 'Capacity',
            hint: 'Optional',
            controller: capacityController,
            keyboardType: TextInputType.number,
          ),
          PulseTextField(
            label: 'Description',
            hint: 'Optional',
            controller: descController,
            maxLines: 2,
          ),
          if (existing != null)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
            ),
        ],
      ),
    ),
    onSubmit: () {
      if (!formKey.currentState!.validate()) return;
      onSave(Facility(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: existing?.schoolId ?? schoolId,
        name: nameController.text,
        facilityType: typeController.text,
        location: locationController.text,
        capacity: int.tryParse(capacityController.text) ?? 0,
        description: descController.text,
        isActive: isActive,
      ));
      Navigator.pop(context);
    },
  );
}
