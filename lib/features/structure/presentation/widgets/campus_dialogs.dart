import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import '../../domain/entities/campus_entities.dart';
import 'structure_dialogs.dart' show kSubjectColorSwatches;
import 'structure_ui_kit.dart';

String _colorToHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).substring(2)}';

Future<void> showCampusFormDialog(
  BuildContext context, {
  Campus? existing,
  required String schoolId,
  required void Function(Campus) onSave,
}) {
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
      final campus = Campus(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: existing?.schoolId ?? schoolId,
        name: nameController.text,
        code: codeController.text,
        address: addressController.text,
        district: districtController.text,
        contactPhone: phoneController.text.isEmpty
            ? null
            : phoneController.text,
        contactEmail: emailController.text.isEmpty
            ? null
            : emailController.text,
        isPrimary: isPrimary,
        isActive: isActive,
        order: existing?.order ?? 0,
        archivedAt: existing?.archivedAt,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.pop(context);
      onSave(campus);
    },
  );
}

Future<void> showHouseFormDialog(
  BuildContext context, {
  House? existing,
  required String schoolId,
  required void Function(House) onSave,
}) {
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
              Text(
                'House Color',
                style: Theme.of(context).textTheme.labelMedium,
              ),
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
                      child: selected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
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
      final house = House(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: existing?.schoolId ?? schoolId,
        name: nameController.text,
        colorHex: _colorToHex(selectedColor),
        description: descController.text,
        isActive: isActive,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.pop(context);
      onSave(house);
    },
  );
}

Future<void> showClubFormDialog(
  BuildContext context, {
  Club? existing,
  required String schoolId,
  required void Function(Club) onSave,
}) {
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
      final club = Club(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: existing?.schoolId ?? schoolId,
        name: nameController.text,
        category: categoryController.text,
        description: descController.text,
        patronName: patronController.text,
        isActive: isActive,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.pop(context);
      onSave(club);
    },
  );
}

const facilityTypeOptions = [
  'Library',
  'Classroom',
  'Laboratory',
  'Hall',
  'Workshop',
  'Office',
  'Other',
];

IconData facilityTypeIcon(String type) => switch (type) {
  'Library' => Icons.local_library_outlined,
  'Classroom' => Icons.meeting_room_outlined,
  'Laboratory' => Icons.science_outlined,
  'Hall' => Icons.groups_outlined,
  'Workshop' => Icons.build_outlined,
  'Office' => Icons.business_center_outlined,
  _ => Icons.holiday_village_outlined,
};

Future<void> showFacilityFormDialog(
  BuildContext context, {
  Facility? existing,
  required String schoolId,
  required List<Campus> campuses,
  required void Function(Facility) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final roomController = TextEditingController(text: existing?.location);
  final capacityController = TextEditingController(
    text: existing != null && existing.capacity > 0
        ? existing.capacity.toString()
        : '',
  );
  String selectedType = facilityTypeOptions.contains(existing?.facilityType)
      ? existing!.facilityType
      : facilityTypeOptions.first;
  String? selectedCampusId =
      existing?.campusId.isNotEmpty == true && existing != null
      ? existing.campusId
      : (campuses.isNotEmpty ? campuses.first.id : null);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          existing == null ? 'Add space' : 'Edit space',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: scheme.surfaceContainerHighest,
                          shape: const CircleBorder(),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add a room or facility used by the school.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Space name'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: facilityTypeOptions
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(
                                  facilityTypeIcon(type),
                                  size: 18,
                                  color: scheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(type),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => selectedType = v);
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedCampusId,
                          decoration: const InputDecoration(
                            labelText: 'Building',
                          ),
                          items: campuses
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          validator: (v) =>
                              v == null ? 'Select a building' : null,
                          onChanged: (v) =>
                              setState(() => selectedCampusId = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: roomController,
                          decoration: const InputDecoration(labelText: 'Room'),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: capacityController,
                    decoration: const InputDecoration(labelText: 'Capacity'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        int.tryParse(v ?? '') == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final facility = Facility(
                          id: existing?.id ?? const Uuid().v4(),
                          schoolId: existing?.schoolId ?? schoolId,
                          name: nameController.text.trim(),
                          facilityType: selectedType,
                          campusId: selectedCampusId ?? '',
                          location: roomController.text.trim(),
                          capacity: int.tryParse(capacityController.text) ?? 0,
                          description: existing?.description ?? '',
                          isActive: existing?.isActive ?? true,
                        );
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.pop(context);
                        onSave(facility);
                      },
                      child: const Text('Add space'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
