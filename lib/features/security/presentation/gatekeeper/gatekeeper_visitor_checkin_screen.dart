import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/gatekeeper_components.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/visitors/domain/entities/visitor.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_bloc.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_event.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

enum _CheckInStep { details, purpose, host, confirm }

const List<(String, IconData)> _purposeOptions = [
  ('Meeting', Icons.groups_outlined),
  ('School Fees', Icons.payments_outlined),
  ('Student Pickup', Icons.family_restroom),
  ('Delivery', Icons.local_shipping_outlined),
  ('Interview', Icons.badge_outlined),
  ('Maintenance', Icons.build_outlined),
  ('Official Visit', Icons.account_balance_outlined),
  ('Parent Visit', Icons.diversity_3_outlined),
  ('Contractor', Icons.engineering_outlined),
  ('Other', Icons.more_horiz),
];

/// Gatekeeper Simple Mode visitor check-in: the exact 4-step flow spec'd for
/// "Simple Visitor Entry" (identify -> purpose -> host -> confirm), wrapping
/// the same VisitorsBloc.CheckInNewVisitor event and Visitor entity the
/// existing (Reception mode) visitor_check_in_screen.dart uses - that
/// detailed form stays untouched for Reception's fuller data-entry needs.
class GatekeeperVisitorCheckInScreen extends StatefulWidget {
  final Gate gate;
  const GatekeeperVisitorCheckInScreen({super.key, required this.gate});

  @override
  State<GatekeeperVisitorCheckInScreen> createState() => _GatekeeperVisitorCheckInScreenState();
}

class _GatekeeperVisitorCheckInScreenState extends State<GatekeeperVisitorCheckInScreen> {
  _CheckInStep _step = _CheckInStep.details;
  final _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _image;
  String? _purpose;
  UserEntity? _host;
  bool _isSubmitting = false;
  bool _isLoadingStaff = false;
  List<UserEntity> _staff = [];

  String get _schoolId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 800,
      imageQuality: 70,
    );
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoadingStaff = true);
    final result = await di.sl<GetStaffMembers>()(NoParams());
    if (!mounted) return;
    result.fold(
      (failure) => null,
      (members) => setState(() => _staff = members.where((m) => m.schoolId == _schoolId).toList()),
    );
    setState(() => _isLoadingStaff = false);
  }

  bool get _isBlacklisted {
    final visitorsState = context.read<VisitorsBloc>().state;
    if (visitorsState is! VisitorsLoaded) return false;
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    return visitorsState.blacklist.any((b) =>
        (phone.isNotEmpty && b.phone == phone) || (name.isNotEmpty && b.fullName.toLowerCase() == name.toLowerCase()));
  }

  void _confirmCheckIn() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    setState(() => _isSubmitting = true);

    final visitor = Visitor(
      id: const Uuid().v4(),
      schoolId: authState.user.schoolId,
      fullName: _nameController.text.trim().isEmpty ? 'Visitor' : _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      host: _host?.name ?? '',
      hostId: _host?.id,
      department: '',
      purpose: _purpose ?? 'Other',
      arrivalTime: DateTime.now(),
      status: VisitorStatus.checkedIn,
      deviceId: '',
      gateId: widget.gate.id,
      photoLocalPath: _image?.path,
    );
    context.read<VisitorsBloc>().add(CheckInNewVisitor(visitor));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Visitor'),
        leading: _step == _CheckInStep.details
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _step = _CheckInStep.values[_step.index - 1];
                }),
              ),
      ),
      body: switch (_step) {
        _CheckInStep.details => _buildDetailsStep(context),
        _CheckInStep.purpose => _buildPurposeStep(context),
        _CheckInStep.host => _buildHostStep(context),
        _CheckInStep.confirm => _buildConfirmStep(context),
      },
    );
  }

  Widget _buildDetailsStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: GestureDetector(
              onTap: _takePhoto,
              child: CircleAvatar(
                radius: 56,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null ? const Icon(Icons.add_a_photo_outlined, size: 36) : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: TextButton(onPressed: _takePhoto, child: Text(_image == null ? 'Take Photo' : 'Retake Photo'))),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            autofocus: true,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(labelText: 'Visitor name', prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(labelText: 'Phone number (optional)', prefixIcon: Icon(Icons.phone_outlined)),
          ),
          const Spacer(),
          GatekeeperPrimaryButton(
            label: 'NEXT',
            icon: Icons.arrow_forward,
            tone: GatekeeperButtonTone.info,
            onPressed: () => setState(() => _step = _CheckInStep.purpose),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Why are they visiting?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: _purposeOptions.map((option) {
                return GatekeeperActionTile(
                  label: option.$1,
                  icon: option.$2,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    setState(() => _purpose = option.$1);
                    _loadStaff();
                    setState(() => _step = _CheckInStep.host);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('Who are they visiting?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        if (_isLoadingStaff) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _staff.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final person = _staff[index];
              return AppCard(
                onTap: () => setState(() {
                  _host = person;
                  _step = _CheckInStep.confirm;
                }),
                child: Row(
                  children: [
                    AvatarInitials(name: person.name, size: 44),
                    const SizedBox(width: 14),
                    Expanded(child: Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmStep(BuildContext context) {
    final blacklisted = _isBlacklisted;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: AppCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 48, backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null ? const Icon(Icons.person, size: 40) : null),
                  const SizedBox(height: 12),
                  Text(_nameController.text.trim().isEmpty ? 'Visitor' : _nameController.text.trim(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${_purpose ?? ''} • Visiting ${_host?.name ?? ''}', textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('Gate: ${widget.gate.name}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          if (blacklisted) ...[
            const SizedBox(height: 16),
            const AlertBanner(
              title: 'Security Alert',
              message: 'This person is on the security blacklist. Call a supervisor before allowing entry.',
              color: Colors.red,
              icon: Icons.warning_amber_rounded,
            ),
          ],
          const SizedBox(height: 16),
          GatekeeperPrimaryButton(
            label: blacklisted ? 'BLOCKED — CALL SUPERVISOR' : 'CHECK IN',
            icon: blacklisted ? Icons.block : Icons.login,
            tone: blacklisted ? GatekeeperButtonTone.danger : GatekeeperButtonTone.success,
            isLoading: _isSubmitting,
            onPressed: blacklisted ? null : _confirmCheckIn,
          ),
        ],
      ),
    );
  }
}
