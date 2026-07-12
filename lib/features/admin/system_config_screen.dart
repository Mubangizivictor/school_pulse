import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  late TextEditingController _termController;
  late TextEditingController _yearController;
  Color? _primaryColor;
  Color? _secondaryColor;
  DateTime? _termStart;
  DateTime? _termEnd;
  bool _mfaEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _mottoController = TextEditingController();
    _logoUrlController = TextEditingController();
    _termController = TextEditingController();
    _yearController = TextEditingController();

    // Initialize with current state if already loaded
    final currentState = context.read<SystemConfigBloc>().state;
    if (currentState is SystemConfigLoaded) {
      _initializeControllers(currentState.config);
    } else if (currentState is SystemConfigError && currentState.config != null) {
      _initializeControllers(currentState.config!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mottoController.dispose();
    _logoUrlController.dispose();
    _termController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _initializeControllers(SystemConfig config) {
    _nameController.text = config.schoolName;
    _mottoController.text = config.schoolMotto;
    _logoUrlController.text = config.schoolLogoUrl ?? '';
    _termController.text = config.currentTerm;
    _yearController.text = config.academicYear;
    _primaryColor = config.primaryColor != null ? Color(int.parse(config.primaryColor!)) : null;
    _secondaryColor = config.secondaryColor != null ? Color(int.parse(config.secondaryColor!)) : null;
    _termStart = config.termStart;
    _termEnd = config.termEnd;
    _mfaEnabled = config.mfaEnabled;
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
              const SnackBar(content: Text('Configuration updated successfully')),
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
            return const Center(child: CircularProgressIndicator());
          }

          final config = state is SystemConfigLoaded
              ? state.config
              : (state is SystemConfigLogoUploading
                  ? state.config
                  : (state is SystemConfigUpdated
                      ? state.config
                      : (state is SystemConfigError ? state.config : null)));

          if (config != null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSchoolIdentitySection(context, config, state),
                    const SizedBox(height: 24),
                    _buildThemeSection(context),
                    const SizedBox(height: 24),
                    _buildAcademicCalendarSection(context),
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
        schoolLogoUrl: _logoUrlController.text.isEmpty ? oldConfig.schoolLogoUrl : _logoUrlController.text,
        primaryColor: _primaryColor?.toARGB32().toString(),
        secondaryColor: _secondaryColor?.toARGB32().toString(),
        currentTerm: _termController.text,
        academicYear: _yearController.text,
        termStart: _termStart ?? oldConfig.termStart,
        termEnd: _termEnd ?? oldConfig.termEnd,
        mfaEnabled: _mfaEnabled,
        smsGatewayStatus: oldConfig.smsGatewayStatus,
        smsCredits: oldConfig.smsCredits,
      );
      context.read<SystemConfigBloc>().add(UpdateSystemConfig(newConfig));
    }
  }

  Widget _buildSchoolIdentitySection(BuildContext context, SystemConfig config, SystemConfigState state) {
    final isUploadingLogo = state is SystemConfigLogoUploading;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('School Identity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
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
                          child: CircularProgressIndicator(color: Colors.white),
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
                      decoration: const InputDecoration(labelText: 'School Name', hintText: 'e.g. Kampala Heights Academy'),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mottoController,
                      decoration: const InputDecoration(labelText: 'School Motto', hintText: 'e.g. Excellence in Service'),
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
        context.read<SystemConfigBloc>().add(UploadSchoolLogo(File(pickedFile.path)));
      }
    }
  }

  Widget _buildThemeSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Branding & Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        border: Border.all(color: Theme.of(context).dividerColor),
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
                        color: _secondaryColor ?? Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).dividerColor),
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
            pickerColor: (isPrimary ? _primaryColor : _secondaryColor) ?? Colors.blue,
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
        ],
      ),
    );
  }

  Widget _buildAcademicCalendarSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Term & Session Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _termController,
                  decoration: const InputDecoration(labelText: 'Current Term', hintText: 'Term 3'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Academic Year', hintText: '2023/2024'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
                    decoration: const InputDecoration(labelText: 'Term Start Date', suffixIcon: Icon(Icons.calendar_today)),
                    child: Text(_termStart != null ? DateFormat('MMM dd, yyyy').format(_termStart!) : 'Select Date'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Term End Date', suffixIcon: Icon(Icons.calendar_today)),
                    child: Text(_termEnd != null ? DateFormat('MMM dd, yyyy').format(_termEnd!) : 'Select Date'),
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

  Widget _buildIntegrationSettings(BuildContext context, SystemConfig config) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('External Integrations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.sms_outlined),
            title: const Text('SMS Gateway (Twilio)'),
            subtitle: Text('Status: ${config.smsGatewayStatus} • ${config.smsCredits} Credits remaining'),
            trailing: Switch(
              value: config.smsGatewayStatus == 'Connected',
              onChanged: (connect) {
                context.read<SystemConfigBloc>().add(UpdateSystemConfig(SystemConfig(
                      schoolName: config.schoolName,
                      schoolMotto: config.schoolMotto,
                      currentTerm: config.currentTerm,
                      academicYear: config.academicYear,
                      termStart: config.termStart,
                      termEnd: config.termEnd,
                      mfaEnabled: config.mfaEnabled,
                      smsGatewayStatus: connect ? 'Connected' : 'Disconnected',
                      smsCredits: config.smsCredits,
                    )));
              },
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.payment_outlined),
            title: Text('Payment Provider (Flutterwave)'),
            subtitle: Text('Not yet integrated - contact support to enable online payments'),
            trailing: Switch(value: false, onChanged: null),
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
                return const Center(child: CircularProgressIndicator());
              }
              if (sessions.isEmpty) {
                return const Center(child: Text('No past sessions archived yet.\nThey appear here once you change the term or academic year.', textAlign: TextAlign.center));
              }
              return ListView.separated(
                itemCount: sessions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final s = sessions[index];
                  return ListTile(
                    dense: true,
                    title: Text('${s['currentTerm'] ?? ''} • ${s['academicYear'] ?? ''}'),
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
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Security & Access Control', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text('Enforce Multi-Factor Authentication (MFA)'),
            subtitle: const Text('Require MFA for all staff with Admin/Bursar roles'),
            value: _mfaEnabled, 
            onChanged: (v) {
              setState(() {
                _mfaEnabled = v ?? false;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Restrict Login by IP Range'),
            subtitle: const Text('Limit staff logins to school network only'),
            value: false, 
            onChanged: (v) {},
          ),
        ],
      ),
    );
  }
}
