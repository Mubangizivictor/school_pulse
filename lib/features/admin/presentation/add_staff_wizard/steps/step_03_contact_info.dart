import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/design_system/components/wizard_scaffold.dart';

import '../add_staff_wizard_controller.dart';

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
    _nationality = TextEditingController(text: draft.nationality);
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
              number: 4,
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
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()))
                  return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _altPhone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Alternative Phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
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
              decoration: const InputDecoration(
                labelText: 'Nationality',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
