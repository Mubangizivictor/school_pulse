import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/school.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';

const List<(String, InstitutionClassification)> _kSchoolTypes = [
  ('Kindergarten', InstitutionClassification.kindergarten),
  ('Primary', InstitutionClassification.primary),
  ('Secondary', InstitutionClassification.secondary),
  ('Combined (Primary + Secondary)', InstitutionClassification.combined),
  ('Vocational', InstitutionClassification.vocational),
  ('Technical Institute', InstitutionClassification.technicalInstitute),
  ('College', InstitutionClassification.college),
  ('University', InstitutionClassification.university),
  ('Special-needs', InstitutionClassification.specialNeeds),
  ('Training Centre', InstitutionClassification.trainingCentre),
  ('Multi-purpose', InstitutionClassification.multiCampus),
  ('Other', InstitutionClassification.other),
];

const List<(String, String)> _kPlans = [
  ('Basic', 'basic'),
  ('Professional', 'pro'),
  ('Enterprise', 'enterprise'),
];

String _generateTempPassword() {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%';
  final rand = DateTime.now().microsecondsSinceEpoch;
  return List.generate(10, (i) => chars[(rand + i * 37) % chars.length]).join();
}

class AddSchoolWizard extends StatefulWidget {
  const AddSchoolWizard({super.key});

  @override
  State<AddSchoolWizard> createState() => _AddSchoolWizardState();
}

class _AddSchoolWizardState extends State<AddSchoolWizard> {
  int _currentStep = 1;
  bool _submitting = false;

  // Step 1 - School Info
  final _schoolNameController = TextEditingController();
  final _initialsController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolEmailController = TextEditingController();
  InstitutionClassification _schoolType = InstitutionClassification.secondary;
  bool _parentPortalEnabled = true;
  bool _studentPortalEnabled = true;

  // Step 2 - Admin Info
  final _adminFirstNameController = TextEditingController();
  final _adminLastNameController = TextEditingController();
  final _adminTitleController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPhoneController = TextEditingController();

  // Step 3 - Subscription
  String _selectedPlanId = 'pro';
  bool _trialEnabled = false;

  late final String _tempPassword;

  @override
  void initState() {
    super.initState();
    _tempPassword = _generateTempPassword();
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _initialsController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _schoolEmailController.dispose();
    _adminFirstNameController.dispose();
    _adminLastNameController.dispose();
    _adminTitleController.dispose();
    _adminEmailController.dispose();
    _adminPhoneController.dispose();
    super.dispose();
  }

  String get _schoolTypeLabel =>
      _kSchoolTypes.firstWhere((t) => t.$2 == _schoolType).$1;

  String get _planLabel =>
      _kPlans.firstWhere((p) => p.$2 == _selectedPlanId).$1;

  bool _validateStep1() {
    if (_schoolNameController.text.trim().isEmpty) {
      _showError('School name is required.');
      return false;
    }
    if (_initialsController.text.trim().isEmpty) {
      _showError('School initials are required.');
      return false;
    }
    if (_cityController.text.trim().isEmpty) {
      _showError('City / town is required.');
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      _showError('School address is required.');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_adminFirstNameController.text.trim().isEmpty ||
        _adminLastNameController.text.trim().isEmpty) {
      _showError('Administrator name is required.');
      return false;
    }
    final email = _adminEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showError('A valid administrator email is required.');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _goNext() {
    if (_currentStep == 1) {
      if (!_validateStep1()) return;
      setState(() => _currentStep = 2);
      return;
    }
    if (_currentStep == 2) {
      if (!_validateStep2()) return;
      setState(() => _currentStep = 3);
      return;
    }
    if (_currentStep == 3) {
      setState(() => _currentStep = 4);
      return;
    }
    _submit();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final school = School(
      id: const Uuid().v4(),
      name: _schoolNameController.text.trim(),
      tenantId: _initialsController.text.trim().toUpperCase(),
      address:
          '${_addressController.text.trim()}, ${_cityController.text.trim()}',
      contactEmail: _schoolEmailController.text.trim(),
      contactPhone: _phoneController.text.trim(),
      status: _trialEnabled ? SchoolStatus.trial : SchoolStatus.active,
      subscriptionPlanId: _selectedPlanId,
      createdAt: DateTime.now(),
      subscriptionExpiry: DateTime.now().add(
        _trialEnabled ? const Duration(days: 14) : const Duration(days: 365),
      ),
      enabledFeatures: [
        if (_parentPortalEnabled) 'parentPortal',
        if (_studentPortalEnabled) 'studentPortal',
      ],
      classification: _schoolType,
    );

    context.read<SuperAdminBloc>().add(
      CreateSchoolEvent(
        school: school,
        adminEmail: _adminEmailController.text.trim(),
        adminPassword: _tempPassword,
      ),
    );

    // CreateSchoolEvent has no completion signal on SuperAdminState today -
    // the bloc fires LoadSuperAdminDashboard() on success and only surfaces
    // failures via errorMessage. Give the write a moment, then check for an
    // error before treating this as done; err on the side of not blocking
    // the owner if nothing surfaces.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final error = context.read<SuperAdminBloc>().state.errorMessage;
    setState(() => _submitting = false);
    if (error != null) {
      _showError('Failed to create school: $error');
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('School Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_schoolNameController.text.trim()} has been provisioned.'),
            const SizedBox(height: 16),
            const Text(
              'Administrator Temporary Password:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _tempPassword,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const Text(
              'Share this with the school administrator. They will be prompted to set a new password on first login.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New School',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a new school and its administrator account',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 32),
                  _buildStepIndicator(),
                  const SizedBox(height: 32),
                  if (_currentStep == 1) _buildSchoolInfoStep(),
                  if (_currentStep == 2) _buildAdminInfoStep(),
                  if (_currentStep == 3) _buildSubscriptionStep(),
                  if (_currentStep == 4) _buildReviewStep(),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF64748B)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.layers_outlined,
              color: Color(0xFF6366F1),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'School Pulse',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                'SaaS Owner Console',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStep(1, 'School Info', _currentStep >= 1),
        _buildDivider(_currentStep > 1),
        _buildStep(2, 'Admin Info', _currentStep >= 2),
        _buildDivider(_currentStep > 2),
        _buildStep(3, 'Subscription Plan', _currentStep >= 3),
        _buildDivider(_currentStep > 3),
        _buildStep(4, 'Review & Confirm', _currentStep >= 4),
      ],
    );
  }

  Widget _buildStep(int number, String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF6366F1) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF64748B),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isActive) {
    return Container(
      width: 40,
      height: 1,
      color: isActive ? const Color(0xFF6366F1) : const Color(0xFFCBD5E1),
      margin: const EdgeInsets.only(bottom: 24),
    );
  }

  Widget _buildSchoolInfoStep() {
    return Column(
      children: [
        _buildSectionCard(
          icon: Icons.business_outlined,
          title: 'School Information',
          subtitle: 'Basic details about the school',
          content: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'School Name *',
                      'Enter school name',
                      _schoolNameController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'School Initials *',
                      'e.g. GFHS',
                      _initialsController,
                      helperText: 'Used in codes, IDs and reports',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      'School Type *',
                      _schoolTypeLabel,
                      onTap: _showSchoolTypePicker,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'City / Town *',
                      'Enter city or town',
                      _cityController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'School Address *',
                'Enter full school address',
                _addressController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Phone Number',
                      '+256 700 000 000',
                      _phoneController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'School Email',
                      'official@school.ac.ug',
                      _schoolEmailController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          icon: Icons.settings_outlined,
          title: 'School Configuration',
          subtitle: 'Basic platform configuration for the school',
          content: Column(
            children: [
              _buildSwitchRow(
                'Allow Parent Portal Access',
                'Enable parent portal for this school',
                _parentPortalEnabled,
                (v) => setState(() => _parentPortalEnabled = v),
              ),
              const Divider(height: 32),
              _buildSwitchRow(
                'Allow Student Portal Access',
                'Enable student portal for this school',
                _studentPortalEnabled,
                (v) => setState(() => _studentPortalEnabled = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildImportantNote(),
      ],
    );
  }

  void _showSchoolTypePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: _kSchoolTypes
              .map(
                (t) => ListTile(
                  title: Text(t.$1),
                  trailing: t.$2 == _schoolType
                      ? const Icon(Icons.check, color: Color(0xFF6366F1))
                      : null,
                  onTap: () {
                    setState(() => _schoolType = t.$2);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          content,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value, {
    IconData? leadingIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: 20, color: const Color(0xFF1E293B)),
                  const SizedBox(width: 8),
                ],
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF6366F1),
        ),
      ],
    );
  }

  Widget _buildImportantNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF6366F1)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'School administrator will be created in the next steps with temporary login credentials.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminInfoStep() {
    return Column(
      children: [
        _buildSectionCard(
          icon: Icons.person_outline,
          title: 'Primary Administrator',
          subtitle: 'The main contact person for this school',
          content: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'First Name *',
                      'Enter first name',
                      _adminFirstNameController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Last Name *',
                      'Enter last name',
                      _adminLastNameController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Job Title / Position',
                'e.g. Principal',
                _adminTitleController,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Email Address *',
                'admin@school.ac.ug',
                _adminEmailController,
                helperText: 'This will be the primary login username',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Phone Number',
                '+256 700 000 000',
                _adminPhoneController,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionStep() {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Select Subscription Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildPlanCard(
              planId: 'basic',
              title: 'Basic',
              price: '\$49',
              features: const [
                'Up to 500 Students',
                'Core Modules',
                'Email Support',
              ],
            ),
            const SizedBox(width: 16),
            _buildPlanCard(
              planId: 'pro',
              title: 'Professional',
              price: '\$99',
              features: const [
                'Up to 2000 Students',
                'All Modules',
                'Priority Support',
              ],
              isPopular: true,
            ),
            const SizedBox(width: 16),
            _buildPlanCard(
              planId: 'enterprise',
              title: 'Enterprise',
              price: 'Custom',
              features: const [
                'Unlimited Students',
                'Custom Modules',
                '24/7 Support',
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSectionCard(
          icon: Icons.calendar_today_outlined,
          title: 'Billing Details',
          subtitle: 'Configure the trial period for this school',
          content: _buildSwitchRow(
            'Trial Period',
            'Start this school on a 14-day free trial instead of an active subscription',
            _trialEnabled,
            (v) => setState(() => _trialEnabled = v),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String planId,
    required String title,
    required String price,
    required List<String> features,
    bool isPopular = false,
  }) {
    final isSelected = _selectedPlanId == planId;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPlanId = planId),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      price,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  if (price != 'Custom')
                    const Text(
                      '/mo',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                ],
              ),
              const Divider(height: 24),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return Column(
      children: [
        _buildSectionCard(
          icon: Icons.visibility_outlined,
          title: 'Review Summary',
          subtitle: 'Please review all information before confirming',
          content: Column(
            children: [
              _buildReviewRow('School Name', _schoolNameController.text),
              _buildReviewRow(
                'School Initials',
                _initialsController.text.toUpperCase(),
              ),
              _buildReviewRow('School Type', _schoolTypeLabel),
              _buildReviewRow('Location', _cityController.text),
              const Divider(height: 32),
              _buildReviewRow(
                'Administrator',
                '${_adminFirstNameController.text} ${_adminLastNameController.text}',
              ),
              _buildReviewRow('Email', _adminEmailController.text),
              const Divider(height: 32),
              _buildReviewRow('Plan', _planLabel),
              _buildReviewRow(
                'Billing',
                _trialEnabled ? '14-day free trial' : 'Active subscription',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFEE2E2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'By clicking "Confirm and Create", a new school instance will be provisioned and an invitation will be sent to the administrator account.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    String nextLabel = 'Next: Administrator Information';
    if (_currentStep == 2) nextLabel = 'Next: Subscription Plan';
    if (_currentStep == 3) nextLabel = 'Next: Review & Confirm';
    if (_currentStep == 4) nextLabel = 'Confirm and Create School';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _submitting
                  ? null
                  : () {
                      if (_currentStep > 1) {
                        setState(() => _currentStep--);
                      } else {
                        Navigator.pop(context);
                      }
                    },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Text(
                _currentStep == 1 ? 'Cancel' : 'Back',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _submitting ? null : _goNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          nextLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_currentStep < 4)
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 16,
                          ),
                        if (_currentStep == 4)
                          const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
