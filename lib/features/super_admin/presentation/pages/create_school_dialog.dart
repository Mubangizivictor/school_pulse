import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/school.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';

class CreateSchoolDialog extends StatefulWidget {
  const CreateSchoolDialog({super.key});

  @override
  State<CreateSchoolDialog> createState() => _CreateSchoolDialogState();
}

class _CreateSchoolDialogState extends State<CreateSchoolDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tenantIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _tempPasswordController = TextEditingController();
  
  String _selectedPlanId = 'starter'; // Default plan

  @override
  void dispose() {
    _nameController.dispose();
    _tenantIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _adminEmailController.dispose();
    _tempPasswordController.dispose();
    super.dispose();
  }

  Widget _fieldPair(BuildContext context, Widget first, Widget second) {
    if (MediaQuery.sizeOf(context).width - 80 < 500) {
      return Column(
        children: [first, const SizedBox(height: 16), second],
      );
    }
    return Row(
      children: [
        Expanded(child: first),
        const SizedBox(width: 16),
        Expanded(child: second),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = (MediaQuery.sizeOf(context).width - 80).clamp(240, 600).toDouble();
    return AlertDialog(
      title: const Text('Register New School'),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('School Information', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _fieldPair(
                  context,
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'School Name'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _tenantIdController,
                    decoration: const InputDecoration(labelText: 'Tenant ID (Short Code)'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Physical Address'),
                ),
                const SizedBox(height: 16),
                _fieldPair(
                  context,
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Contact Email'),
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Contact Phone'),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Initial Admin Account', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _adminEmailController,
                  decoration: const InputDecoration(labelText: 'Admin Email'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tempPasswordController,
                  decoration: const InputDecoration(labelText: 'Temporary Password'),
                  obscureText: true,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 32),
                const Text('Subscription Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPlanId,
                  decoration: const InputDecoration(labelText: 'Select Plan'),
                  items: const [
                    DropdownMenuItem(value: 'starter', child: Text('Starter (Yearly)')),
                    DropdownMenuItem(value: 'pro', child: Text('Professional (Termly)')),
                    DropdownMenuItem(value: 'enterprise', child: Text('Enterprise (Yearly)')),
                  ],
                  onChanged: (v) => setState(() => _selectedPlanId = v!),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Create School'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final school = School(
        id: const Uuid().v4(),
        name: _nameController.text,
        tenantId: _tenantIdController.text.toUpperCase(),
        address: _addressController.text,
        contactEmail: _emailController.text,
        contactPhone: _phoneController.text,
        status: SchoolStatus.active,
        subscriptionPlanId: _selectedPlanId,
        createdAt: DateTime.now(),
        subscriptionExpiry: DateTime.now().add(const Duration(days: 365)),
        enabledFeatures: const ['attendance', 'finance', 'exams'],
      );

      context.read<SuperAdminBloc>().add(
        CreateSchoolEvent(
          school: school,
          adminEmail: _adminEmailController.text,
          adminPassword: _tempPasswordController.text,
        ),
      );
      
      Navigator.pop(context);
    }
  }
}
