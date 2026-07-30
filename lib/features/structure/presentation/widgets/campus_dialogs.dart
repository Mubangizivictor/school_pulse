import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/campus_entities.dart';
import 'structure_dialogs.dart' show kSubjectColorSwatches;
import 'structure_ui_kit.dart';

String _colorToHex(Color color) => '#${color.toARGB32().toRadixString(16).substring(2)}';

Future<void> showHouseFormDialog(BuildContext context, {House? existing, required void Function(House) onSave}) {
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
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'House Name (e.g. Blue House)'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
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
          TextFormField(
            controller: descController,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
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
        name: nameController.text,
        colorHex: _colorToHex(selectedColor),
        description: descController.text,
        isActive: isActive,
      ));
      Navigator.pop(context);
    },
  );
}

Future<void> showClubFormDialog(BuildContext context, {Club? existing, required void Function(Club) onSave}) {
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
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Club Name (e.g. Debate, Robotics)'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Category (optional)'),
          ),
          TextFormField(
            controller: patronController,
            decoration: const InputDecoration(labelText: 'Patron (optional)'),
          ),
          TextFormField(
            controller: descController,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
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

Future<void> showFacilityFormDialog(BuildContext context, {Facility? existing, required void Function(Facility) onSave}) {
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
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Facility Name (e.g. Main Library)'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: typeController,
            decoration: const InputDecoration(labelText: 'Type (e.g. Library, Laboratory, Dormitory)'),
          ),
          TextFormField(
            controller: locationController,
            decoration: const InputDecoration(labelText: 'Location / Building (optional)'),
          ),
          TextFormField(
            controller: capacityController,
            decoration: const InputDecoration(labelText: 'Capacity (optional)'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: descController,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
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
