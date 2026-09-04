import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/registration_reference_data.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../registration_theme.dart';
import '../widgets/reg_widgets.dart';

class Step1SchoolDetailsPage extends StatefulWidget {
  const Step1SchoolDetailsPage({super.key});

  @override
  State<Step1SchoolDetailsPage> createState() => _Step1SchoolDetailsPageState();
}

class _Step1SchoolDetailsPageState extends State<Step1SchoolDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _phone;
  late TextEditingController _email;
  late TextEditingController _prefix;
  late String _type;

  @override
  void initState() {
    super.initState();
    final s = context.read<RegistrationBloc>().state;
    _name = TextEditingController(text: s.schoolName);
    _phone = TextEditingController(text: s.contactPhone);
    _email = TextEditingController(text: s.contactEmail);
    _prefix = TextEditingController(text: s.prefix);
    _type = s.schoolType.isEmpty ? 'Government Aided' : s.schoolType;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _prefix.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    context.read<RegistrationBloc>().add(SchoolDetailsSubmitted(
          schoolName: _name.text.trim(),
          schoolType: _type,
          contactPhone: _phone.text.trim(),
          contactEmail: _email.text.trim(),
          prefix: _prefix.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return RegStepScaffold(
      step: 1,
      title: 'School details',
      onBack: () => context.read<RegistrationBloc>().add(const RegistrationStepBack()),
      onContinue: _continue,
      infoBanner: const RegInfoBanner(
        'Ensure the information above is accurate. You can update it later in your dashboard.',
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RegFieldLabel('School name'),
            TextFormField(
              controller: _name,
              style: const TextStyle(color: RegColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Kawempe Primary School'),
              validator: (v) => (v == null || v.trim().length < 3) ? 'Enter the school name' : null,
            ),
            const RegFieldLabel('School type'),
            DropdownButtonFormField<String>(
              initialValue: kSchoolTypes.contains(_type) ? _type : (_type.isEmpty ? null : null),
              items: [
                for (final t in const ['Government Aided', 'Private', 'Community', ...kSchoolTypes])
                  DropdownMenuItem(value: t, child: Text(t)),
              ],
              dropdownColor: RegColors.surfaceElevated,
              style: const TextStyle(color: RegColors.textPrimary, fontSize: 14),
              onChanged: (v) => setState(() => _type = v ?? _type),
              validator: (v) => (v == null || v.isEmpty) ? 'Select a school type' : null,
            ),
            const RegFieldLabel('Contact phone'),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: RegColors.textPrimary),
              decoration: const InputDecoration(hintText: '+256 712 345 678'),
              validator: (v) => (v == null || v.trim().length < 7) ? 'Enter a valid phone number' : null,
            ),
            const RegFieldLabel('Contact email'),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: RegColors.textPrimary),
              decoration: const InputDecoration(hintText: 'kawempeps@gmail.com'),
              validator: (v) =>
                  (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) ? 'Enter a valid email' : null,
            ),
            const RegFieldLabel('School initials / prefix'),
            TextFormField(
              controller: _prefix,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: RegColors.textPrimary),
              decoration: const InputDecoration(hintText: 'KPS'),
              validator: (v) => (v == null || v.trim().length < 2) ? 'At least 2 characters' : null,
            ),
          ],
        ),
      ),
    );
  }
}
