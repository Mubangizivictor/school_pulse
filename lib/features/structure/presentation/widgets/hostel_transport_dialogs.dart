import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/hostel_entities.dart';
import '../../domain/entities/transport_structure_entities.dart';
import 'structure_ui_kit.dart';

const List<String> kHostelGenders = ['Male', 'Female', 'Mixed'];

Future<void> showHostelFormDialog(BuildContext context, {Hostel? existing, required void Function(Hostel) onSave}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final wardenNameController = TextEditingController(text: existing?.wardenName);
  final wardenContactController = TextEditingController(text: existing?.wardenContact);
  final capacityController = TextEditingController(text: existing?.capacity.toString() ?? '0');
  final descController = TextEditingController(text: existing?.description);
  String selectedGender = kHostelGenders.contains(existing?.gender) ? existing!.gender : kHostelGenders.first;
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Hostel' : 'Edit Hostel',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Hostel Name'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: selectedGender,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: kHostelGenders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (v) => setState(() => selectedGender = v ?? selectedGender),
          ),
          TextFormField(
            controller: wardenNameController,
            decoration: const InputDecoration(labelText: 'Warden Name (optional)'),
          ),
          TextFormField(
            controller: wardenContactController,
            decoration: const InputDecoration(labelText: 'Warden Contact (optional)'),
          ),
          TextFormField(
            controller: capacityController,
            decoration: const InputDecoration(labelText: 'Capacity'),
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
      onSave(Hostel(
        id: existing?.id ?? const Uuid().v4(),
        name: nameController.text,
        gender: selectedGender,
        wardenName: wardenNameController.text,
        wardenContact: wardenContactController.text,
        capacity: int.tryParse(capacityController.text) ?? 0,
        description: descController.text,
        isActive: isActive,
      ));
      Navigator.pop(context);
    },
  );
}

Future<void> showHostelRoomFormDialog(
  BuildContext context, {
  HostelRoom? existing,
  required List<Hostel> hostels,
  required void Function(HostelRoom) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final blockController = TextEditingController(text: existing?.blockName);
  final roomController = TextEditingController(text: existing?.roomNumber);
  final bedCapacityController = TextEditingController(text: existing?.bedCapacity.toString() ?? '0');
  String? selectedHostelId = existing?.hostelId.isNotEmpty == true ? existing!.hostelId : (hostels.isNotEmpty ? hostels.first.id : null);
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Room' : 'Edit Room',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedHostelId,
            decoration: const InputDecoration(labelText: 'Hostel'),
            items: hostels.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))).toList(),
            onChanged: (v) => setState(() => selectedHostelId = v),
            validator: (v) => v == null ? 'Select a hostel' : null,
          ),
          TextFormField(
            controller: blockController,
            decoration: const InputDecoration(labelText: 'Block Name (optional)'),
          ),
          TextFormField(
            controller: roomController,
            decoration: const InputDecoration(labelText: 'Room Number'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: bedCapacityController,
            decoration: const InputDecoration(labelText: 'Bed Capacity'),
            keyboardType: TextInputType.number,
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
      onSave(HostelRoom(
        id: existing?.id ?? const Uuid().v4(),
        hostelId: selectedHostelId!,
        blockName: blockController.text,
        roomNumber: roomController.text,
        bedCapacity: int.tryParse(bedCapacityController.text) ?? 0,
        isActive: isActive,
      ));
      Navigator.pop(context);
    },
  );
}

Future<void> showTransportRouteFormDialog(BuildContext context, {TransportRoute? existing, required void Function(TransportRoute) onSave}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final codeController = TextEditingController(text: existing?.code);
  final descController = TextEditingController(text: existing?.description);
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Route' : 'Edit Route',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Route Name'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: codeController,
            decoration: const InputDecoration(labelText: 'Code (optional)'),
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
      onSave(TransportRoute(
        id: existing?.id ?? const Uuid().v4(),
        name: nameController.text,
        code: codeController.text,
        description: descController.text,
        isActive: isActive,
      ));
      Navigator.pop(context);
    },
  );
}

Future<void> showTransportStopFormDialog(
  BuildContext context, {
  TransportStop? existing,
  required List<TransportRoute> routes,
  required void Function(TransportStop) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final orderController = TextEditingController(text: existing?.order.toString() ?? '0');
  final pickupTimeController = TextEditingController(text: existing?.pickupTime);
  final zoneController = TextEditingController(text: existing?.zone);
  String? selectedRouteId = existing?.routeId.isNotEmpty == true ? existing!.routeId : (routes.isNotEmpty ? routes.first.id : null);
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Stop' : 'Edit Stop',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedRouteId,
            decoration: const InputDecoration(labelText: 'Route'),
            items: routes.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
            onChanged: (v) => setState(() => selectedRouteId = v),
            validator: (v) => v == null ? 'Select a route' : null,
          ),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Stop Name'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: orderController,
            decoration: const InputDecoration(labelText: 'Stop Order'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: pickupTimeController,
            decoration: const InputDecoration(labelText: 'Pickup Time (optional, e.g. 07:00)'),
          ),
          TextFormField(
            controller: zoneController,
            decoration: const InputDecoration(labelText: 'Zone (optional)'),
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
      onSave(TransportStop(
        id: existing?.id ?? const Uuid().v4(),
        routeId: selectedRouteId!,
        name: nameController.text,
        order: int.tryParse(orderController.text) ?? 0,
        pickupTime: pickupTimeController.text,
        zone: zoneController.text,
        isActive: isActive,
      ));
      Navigator.pop(context);
    },
  );
}

Future<void> showTransportVehicleFormDialog(
  BuildContext context, {
  TransportVehicle? existing,
  required List<TransportRoute> routes,
  required void Function(TransportVehicle) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final busNumberController = TextEditingController(text: existing?.busNumber);
  final plateController = TextEditingController(text: existing?.plateNumber);
  final capacityController = TextEditingController(text: existing?.capacity.toString() ?? '0');
  final driverController = TextEditingController(text: existing?.driverName);
  String? selectedRouteId = existing?.routeId.isNotEmpty == true ? existing!.routeId : null;
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Vehicle' : 'Edit Vehicle',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          TextFormField(
            controller: busNumberController,
            decoration: const InputDecoration(labelText: 'Bus Number'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: plateController,
            decoration: const InputDecoration(labelText: 'Plate Number (optional)'),
          ),
          TextFormField(
            controller: capacityController,
            decoration: const InputDecoration(labelText: 'Capacity'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: driverController,
            decoration: const InputDecoration(labelText: 'Driver Name (optional)'),
          ),
          DropdownButtonFormField<String>(
            initialValue: selectedRouteId,
            decoration: const InputDecoration(labelText: 'Assigned Route (optional)'),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('None')),
              ...routes.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))),
            ],
            onChanged: (v) => setState(() => selectedRouteId = v),
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
      onSave(TransportVehicle(
        id: existing?.id ?? const Uuid().v4(),
        busNumber: busNumberController.text,
        plateNumber: plateController.text,
        capacity: int.tryParse(capacityController.text) ?? 0,
        driverName: driverController.text,
        routeId: selectedRouteId ?? '',
        isActive: isActive,
      ));
      Navigator.pop(context);
    },
  );
}
