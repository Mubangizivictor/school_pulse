import 'dart:io';

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/data/models/system_config.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_event.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_state.dart';

class SystemConfigScreen extends StatefulWidget {
  const SystemConfigScreen({super.key});

  @override
  State<SystemConfigScreen> createState() => _SystemConfigScreenState();
}

class _SystemConfigScreenState extends State<SystemConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mottoController;
  late TextEditingController _logoUrlController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _termController;
  late TextEditingController _yearController;
  Color? _primaryColor;
  Color? _secondaryColor;
  DateTime? _termStart;
  DateTime? _termEnd;
  bool _mfaEnabled = false;
  List<String> _gates = ['Main Gate'];
  final _newGateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _mottoController = TextEditingController();
    _logoUrlController = TextEditingController();
    _addressController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _termController = TextEditingController();
    _yearController = TextEditingController();

    // Initialize with current state if already loaded
    final currentState = context.read<SystemConfigBloc>().state;
    if (currentState is SystemConfigLoaded) {
      _initializeControllers(currentState.config);
    } else if (currentState is SystemConfigError &&
        currentState.config != null) {
      _initializeControllers(currentState.config!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mottoController.dispose();
    _logoUrlController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _termController.dispose();
    _yearController.dispose();
    _newGateController.dispose();
    super.dispose();
  }

  void _initializeControllers(SystemConfig config) {
    _nameController.text = config.schoolName;
    _mottoController.text = config.schoolMotto;
    _logoUrlController.text = config.schoolLogoUrl ?? '';
    _addressController.text = config.schoolAddress ?? '';
    _emailController.text = config.schoolEmail ?? '';
    _phoneController.text = config.schoolPhone ?? '';
    _termController.text = config.currentTerm;
    _yearController.text = config.academicYear;
    _primaryColor = config.primaryColor != null
        ? Color(int.parse(config.primaryColor!))
        : null;
    _secondaryColor = config.secondaryColor != null
        ? Color(int.parse(config.secondaryColor!))
        : null;
    _termStart = config.termStart;
    _termEnd = config.termEnd;
    _mfaEnabled = config.mfaEnabled;
    _gates = List<String>.from(config.visitorGates);
  }

  @override
  Widget build(BuildContext context) {
    // We use the global SystemConfigBloc provided in main.dart
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('System Configuration'),
        actions: [
          BlocBuilder<SystemConfigBloc, SystemConfigState>(
            builder: (context, state) {
              final config = state is SystemConfigLoaded
                  ? state.config
                  : (state is SystemConfigError ? state.config : null);

              if (config != null) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: FilledButton.icon(
                    onPressed: () => _saveConfig(context, config),
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save Changes'),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<SystemConfigBloc, SystemConfigState>(
        listener: (context, state) {
          if (state is SystemConfigLoaded) {
            _initializeControllers(state.config);
          } else if (state is SystemConfigUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Configuration updated successfully'),
              ),
            );
          } else if (state is SystemConfigError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            // If we have a config, re-initialize controllers to stay in sync
            if (state.config != null) {
              _initializeControllers(state.config!);
            }
          }
        },
        builder: (context, state) {
          if (state is SystemConfigLoading || state is SystemConfigInitial) {
            return const Center(child: SchoolPulseLoader());
          }

          final config = state is SystemConfigLoaded
              ? state.config
              : (state is SystemConfigLogoUploading
                    ? state.config
                    : (state is SystemConfigUpdated
                          ? state.config
                          : (state is SystemConfigError
                                ? state.config
                                : null)));

          if (config != null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSchoolIdentitySection(context, config, state),
                    const SizedBox(height: 24),
                    _buildContactInfoSection(context),
                    const SizedBox(height: 24),
                    _buildThemeSection(context),
                    const SizedBox(height: 24),
                    _buildAcademicCalendarSection(context),
                    const SizedBox(height: 24),
                    _buildGatesSection(context),
                    const SizedBox(height: 24),
                    _buildIntegrationSettings(context, config),
                    const SizedBox(height: 24),
                    _buildSecuritySettings(context),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load configuration'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<SystemConfigBloc>().add(LoadSystemConfig()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveConfig(BuildContext context, SystemConfig oldConfig) {
    if (_formKey.currentState!.validate()) {
      final newConfig = SystemConfig(
        schoolName: _nameController.text,
        schoolMotto: _mottoController.text,
        schoolLogoUrl: _logoUrlController.text.isEmpty
            ? oldConfig.schoolLogoUrl
            : _logoUrlController.text,
        schoolAddress: _addressController.text,
        schoolEmail: _emailController.text,
        schoolPhone: _phoneController.text,
        primaryColor: _primaryColor?.toARGB32().toString(),
        secondaryColor: _secondaryColor?.toARGB32().toString(),
        currentTerm: _termController.text,
        academicYear: _yearController.text,
        termStart: _termStart ?? oldConfig.termStart,
        termEnd: _termEnd ?? oldConfig.termEnd,
        mfaEnabled: _mfaEnabled,
        smsGatewayStatus: oldConfig.smsGatewayStatus,
        smsCredits: oldConfig.smsCredits,
        studentPortalConfig: oldConfig.studentPortalConfig,
        visitorGates: _gates,
      );
      context.read<SystemConfigBloc>().add(UpdateSystemConfig(newConfig));
    }
  }

  Widget _buildContactInfoSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'School Address',
              hintText: 'e.g. Plot 12, Wampewo Avenue, Kampala',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'School Email',
                    hintText: 'info@school.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'School Phone',
                    hintText: '+256 700 000000',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolIdentitySection(
    BuildContext context,
    SystemConfig config,
    SystemConfigState state,
  ) {
    final isUploadingLogo = state is SystemConfigLogoUploading;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'School Identity',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: isUploadingLogo ? null : () => _pickImage(context),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        image: config.schoolLogoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(config.schoolLogoUrl!),
                                fit: BoxFit.contain,
                              )
                            : null,
                      ),
                      child: config.schoolLogoUrl == null && !isUploadingLogo
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 32),
                                Text('Logo', style: TextStyle(fontSize: 10)),
                              ],
                            )
                          : null,
                    ),
                    if (isUploadingLogo)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: const SchoolPulseLoader(),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'School Name',
                        hintText: 'e.g. Kampala Heights Academy',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mottoController,
                      decoration: const InputDecoration(
                        labelText: 'School Motto',
                        hintText: 'e.g. Excellence in Service',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (context.mounted) {
        context.read<SystemConfigBloc>().add(
          UploadSchoolLogo(File(pickedFile.path)),
        );
      }
    }
  }

  Widget _buildThemeSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Branding & Theme',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Primary Color'),
                  subtitle: const Text('Used for buttons and headers'),
                  trailing: InkWell(
                    onTap: () => _pickColor(context, true),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _primaryColor ?? Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Secondary Color'),
                  subtitle: const Text('Used for accents and alerts'),
                  trailing: InkWell(
                    onTap: () => _pickColor(context, false),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            _secondaryColor ??
                            Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickColor(BuildContext context, bool isPrimary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor:
                (isPrimary ? _primaryColor : _secondaryColor) ?? Colors.blue,
            onColorChanged: (color) {
              setState(() {
                if (isPrimary) {
                  _primaryColor = color;
                } else {
                  _secondaryColor = color;
                }
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicCalendarSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Term & Session Management',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _termController,
                  decoration: const InputDecoration(
                    labelText: 'Current Term',
                    hintText: 'Term 3',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(
                    labelText: 'Academic Year',
                    hintText: '2023/2024',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Term Start Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _termStart != null
                          ? DateFormat('MMM dd, yyyy').format(_termStart!)
                          : 'Select Date',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Term End Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _termEnd != null
                          ? DateFormat('MMM dd, yyyy').format(_termEnd!)
                          : 'Select Date',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showPastSessions(context),
            icon: const Icon(Icons.history),
            label: const Text('Manage Past Sessions'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _termStart : _termEnd) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _termStart = picked;
        } else {
          _termEnd = picked;
        }
      });
    }
  }

  void _addGate() {
    final name = _newGateController.text.trim();
    if (name.isEmpty ||
        _gates.any((g) => g.toLowerCase() == name.toLowerCase())) {
      return;
    }
    setState(() {
      _gates.add(name);
      _newGateController.clear();
    });
  }

  void _removeGate(String gate) {
    if (_gates.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one gate is required')),
      );
      return;
    }
    setState(() => _gates.remove(gate));
  }

  Widget _buildGatesSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visitor Gates',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Define the physical entry points gatekeepers can select when checking in a visitor.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _gates
                .map(
                  (gate) => Chip(
                    label: Text(gate),
                    onDeleted: () => _removeGate(gate),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _newGateController,
                  decoration: const InputDecoration(
                    labelText: 'Add Gate',
                    hintText: 'e.g. North Gate, Delivery Bay',
                    prefixIcon: Icon(Icons.sensor_door_outlined),
                  ),
                  onFieldSubmitted: (_) => _addGate(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(onPressed: _addGate, child: const Text('Add')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationSettings(BuildContext context, SystemConfig config) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'External Integrations',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.sms_outlined),
            title: const Text('SMS Gateway (Twilio)'),
            subtitle: Text(
              'Status: ${config.smsGatewayStatus} • ${config.smsCredits} Credits remaining',
            ),
            trailing: Switch(
              value: config.smsGatewayStatus == 'Connected',
              onChanged: (connect) {
                context.read<SystemConfigBloc>().add(
                  UpdateSystemConfig(
                    config.copyWith(
                      smsGatewayStatus: connect ? 'Connected' : 'Disconnected',
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment_outlined),
            title: const Text('Subscription & Billing'),
            subtitle: const Text(
              'MTN Mobile Money & Airtel Money - view plan, renew, payment history',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/staff/admin/subscription'),
          ),
        ],
      ),
    );
  }

  void _showPastSessions(BuildContext context) {
    final bloc = context.read<SystemConfigBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Past Sessions'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: bloc.repository.watchPastSessions(),
            builder: (context, snapshot) {
              final sessions = snapshot.data ?? const [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: SchoolPulseLoader());
              }
              if (sessions.isEmpty) {
                return const Center(
                  child: Text(
                    'No past sessions archived yet.\nThey appear here once you change the term or academic year.',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.separated(
                itemCount: sessions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final s = sessions[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      '${s['currentTerm'] ?? ''} • ${s['academicYear'] ?? ''}',
                    ),
                    subtitle: Text(
                      '${s['termStart'] != null ? DateFormat('MMM dd, yyyy').format(DateTime.parse(s['termStart'])) : ''} - ${s['termEnd'] != null ? DateFormat('MMM dd, yyyy').format(DateTime.parse(s['termEnd'])) : ''}',
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security & Access Control',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text('Require MFA for Admin/Bursar roles'),
            subtitle: const Text(
              'Saved as school policy - not yet enforced automatically at login',
            ),
            value: _mfaEnabled,
            onChanged: (v) {
              setState(() {
                _mfaEnabled = v ?? false;
              });
            },
          ),
        ],
      ),
    );
  }
}
