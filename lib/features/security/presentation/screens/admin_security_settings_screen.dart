import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/verification_method.dart';

/// Admin-configurable rules for the security module: default verification
/// methods, visitor/pickup policy toggles, and emergency contacts. Stored
/// at schools/{schoolId}/configs/securitySettings (rules restrict writes to
/// securityHead/schoolAdmin/director/headTeacher).
class AdminSecuritySettingsScreen extends StatefulWidget {
  const AdminSecuritySettingsScreen({super.key});

  @override
  State<AdminSecuritySettingsScreen> createState() => _AdminSecuritySettingsScreenState();
}

class _AdminSecuritySettingsScreenState extends State<AdminSecuritySettingsScreen> {
  bool _isLoading = true;
  bool _requirePhotoForPickup = true;
  bool _requireIdDocumentForPickup = false;
  bool _allowManualOverride = true;
  Set<VerificationMethod> _defaultMethods = {VerificationMethod.qrStudentId, VerificationMethod.manualSearch};
  List<Map<String, String>> _emergencyContacts = [];
  List<UserEntity> _securityStaff = [];

  String get _schoolId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  DocumentReference<Map<String, dynamic>> get _docRef =>
      FirebaseFirestore.instance.collection('schools').doc(_schoolId).collection('configs').doc('securitySettings');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final doc = await _docRef.get();
    final data = doc.data();
    final staffResult = await di.sl<GetStaffMembers>()(NoParams());
    if (!mounted) return;

    setState(() {
      if (data != null) {
        _requirePhotoForPickup = data['requirePhotoForPickup'] ?? true;
        _requireIdDocumentForPickup = data['requireIdDocumentForPickup'] ?? false;
        _allowManualOverride = data['allowManualOverride'] ?? true;
        final methodIds = List<String>.from(data['defaultVerificationMethods'] ?? []);
        _defaultMethods = methodIds.map(VerificationMethod.fromId).whereType<VerificationMethod>().toSet();
        _emergencyContacts = List<Map<String, dynamic>>.from(data['emergencyContacts'] ?? [])
            .map((c) => {'name': '${c['name'] ?? ''}', 'phone': '${c['phone'] ?? ''}'})
            .toList();
      }
      _securityStaff = staffResult.fold(
        (failure) => [],
        (members) => members
            .where((m) => m.schoolId == _schoolId && m.roles.any((r) => NotificationGroups.securityRoles.contains(r)))
            .toList(),
      );
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    await _docRef.set({
      'requirePhotoForPickup': _requirePhotoForPickup,
      'requireIdDocumentForPickup': _requireIdDocumentForPickup,
      'allowManualOverride': _allowManualOverride,
      'defaultVerificationMethods': _defaultMethods.map((m) => m.id).toList(),
      'emergencyContacts': _emergencyContacts,
      'schoolId': _schoolId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Security settings saved')));
  }

  void _addContact() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name / Role')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              setState(() => _emergencyContacts.add({'name': nameController.text.trim(), 'phone': phoneController.text.trim()}));
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Security Settings'),
        actions: [IconButton(icon: const Icon(Icons.save_outlined), onPressed: _save)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.door_front_door_outlined),
                    title: const Text('Manage Gates'),
                    subtitle: const Text('Gate names, hours, roles, verification methods'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/staff/security/gates'),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Security Officers', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_securityStaff.isEmpty)
                  const Text('No staff assigned a security role yet.', style: TextStyle(color: Colors.grey))
                else
                  ..._securityStaff.map((s) => ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.badge_outlined)),
                        title: Text(s.name),
                        subtitle: Text(s.roles.map(UserRoleDisplay.name).join(', ')),
                      )),
                const Divider(height: 32),
                Text('Default Verification Methods', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: VerificationMethod.values.map((method) {
                    final selected = _defaultMethods.contains(method);
                    return FilterChip(
                      label: Text(method.label),
                      selected: selected,
                      onSelected: (v) => setState(() {
                        if (v) {
                          _defaultMethods.add(method);
                        } else {
                          _defaultMethods.remove(method);
                        }
                      }),
                    );
                  }).toList(),
                ),
                const Divider(height: 32),
                Text('Pickup Rules', style: Theme.of(context).textTheme.titleMedium),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Require photo for pickup authorization'),
                  value: _requirePhotoForPickup,
                  onChanged: (v) => setState(() => _requirePhotoForPickup = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Require ID document for pickup authorization'),
                  value: _requireIdDocumentForPickup,
                  onChanged: (v) => setState(() => _requireIdDocumentForPickup = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Allow officer override when no match is found'),
                  value: _allowManualOverride,
                  onChanged: (v) => setState(() => _allowManualOverride = v),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Emergency Contacts', style: Theme.of(context).textTheme.titleMedium),
                    IconButton(icon: const Icon(Icons.add_circle), onPressed: _addContact),
                  ],
                ),
                if (_emergencyContacts.isEmpty)
                  const Text('No emergency contacts added.', style: TextStyle(color: Colors.grey))
                else
                  ..._emergencyContacts.map((c) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.phone_outlined),
                        title: Text(c['name'] ?? ''),
                        subtitle: Text(c['phone'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => setState(() => _emergencyContacts.remove(c)),
                        ),
                      )),
                const SizedBox(height: 24),
                FilledButton(onPressed: _save, child: const Text('Save Settings')),
              ],
            ),
    );
  }
}
