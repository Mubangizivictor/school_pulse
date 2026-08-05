import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/biometrics/domain/entities/biometric_settings.dart';
import 'package:school_pulse/features/biometrics/presentation/bloc/biometrics_bloc.dart';
import 'package:school_pulse/features/biometrics/presentation/bloc/biometrics_event.dart';
import 'package:school_pulse/features/biometrics/presentation/bloc/biometrics_state.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class BiometricSettingsPage extends StatefulWidget {
  const BiometricSettingsPage({super.key});

  @override
  State<BiometricSettingsPage> createState() => _BiometricSettingsPageState();
}

class _BiometricSettingsPageState extends State<BiometricSettingsPage> {
  late String schoolId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      schoolId = authState.user.schoolId;
      context.read<BiometricsBloc>().add(LoadBiometricSettings(schoolId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric Settings')),
      body: BlocConsumer<BiometricsBloc, BiometricsState>(
        listener: (context, state) {
          if (state is BiometricOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is BiometricOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BiometricsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BiometricsSettingsLoaded) {
            return _buildSettingsList(state.settings);
          }

          return const Center(child: Text('Unable to load settings'));
        },
      ),
    );
  }

  Widget _buildSettingsList(BiometricSettings settings) {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Enable Biometrics'),
          subtitle: const Text('Global switch for biometric features'),
          value: settings.enableBiometrics,
          onChanged: (val) =>
              _updateSettings(settings.copyWith(enableBiometrics: val)),
        ),
        const Divider(),
        _buildSectionTitle('Features'),
        SwitchListTile(
          title: const Text('Student Attendance'),
          value: settings.enableStudentAttendance,
          onChanged: settings.enableBiometrics
              ? (val) => _updateSettings(
                  settings.copyWith(enableStudentAttendance: val),
                )
              : null,
        ),
        SwitchListTile(
          title: const Text('Staff Attendance'),
          value: settings.enableStaffAttendance,
          onChanged: settings.enableBiometrics
              ? (val) => _updateSettings(
                  settings.copyWith(enableStaffAttendance: val),
                )
              : null,
        ),
        SwitchListTile(
          title: const Text('Gate Verification'),
          value: settings.enableGateVerification,
          onChanged: settings.enableBiometrics
              ? (val) => _updateSettings(
                  settings.copyWith(enableGateVerification: val),
                )
              : null,
        ),
        SwitchListTile(
          title: const Text('Library Verification'),
          value: settings.enableLibraryVerification,
          onChanged: settings.enableBiometrics
              ? (val) => _updateSettings(
                  settings.copyWith(enableLibraryVerification: val),
                )
              : null,
        ),
        SwitchListTile(
          title: const Text('Exam Verification'),
          value: settings.enableExamVerification,
          onChanged: settings.enableBiometrics
              ? (val) => _updateSettings(
                  settings.copyWith(enableExamVerification: val),
                )
              : null,
        ),
        const Divider(),
        _buildSectionTitle('Verification Policy'),
        SwitchListTile(
          title: const Text('Allow QR Fallback'),
          subtitle: const Text('Allow using QR code if fingerprint fails'),
          value: settings.allowQrFallback,
          onChanged: settings.enableBiometrics
              ? (val) =>
                    _updateSettings(settings.copyWith(allowQrFallback: val))
              : null,
        ),
        SwitchListTile(
          title: const Text('Require Dual Verification'),
          subtitle: const Text('Fingerprint + QR Code required'),
          value: settings.requireFingerprintAndQr,
          onChanged: settings.enableBiometrics
              ? (val) => _updateSettings(
                  settings.copyWith(requireFingerprintAndQr: val),
                )
              : null,
        ),
        SwitchListTile(
          title: const Text('Offline Verification'),
          subtitle: const Text('Allow matching fingerprints without internet'),
          value: settings.offlineVerificationEnabled,
          onChanged: settings.enableBiometrics
              ? (val) => _updateSettings(
                  settings.copyWith(offlineVerificationEnabled: val),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _updateSettings(BiometricSettings newSettings) {
    context.read<BiometricsBloc>().add(
      UpdateBiometricSettingsEvent(schoolId, newSettings),
    );
  }
}
