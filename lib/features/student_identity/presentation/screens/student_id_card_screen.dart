import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:school_pulse/core/services/nfc/nfc_credential_reader_adapter.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/biometrics/presentation/screens/biometric_enrollment_screen.dart';
import '../../../student/domain/entities/student.dart';
import '../../domain/entities/student_identity.dart';
import '../bloc/student_identity_bloc.dart';
import '../bloc/student_identity_event.dart';
import '../bloc/student_identity_state.dart';
import '../../domain/services/id_card_service.dart';
import 'package:get_it/get_it.dart';
import 'package:school_pulse/core/theme_provider.dart';

class StudentIdCardScreen extends StatefulWidget {
  final Student student;

  const StudentIdCardScreen({super.key, required this.student});

  @override
  State<StudentIdCardScreen> createState() => _StudentIdCardScreenState();
}

class _StudentIdCardScreenState extends State<StudentIdCardScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<StudentIdentityBloc>()
        .add(LoadStudentIdentityEvent(widget.student.id, schoolId: widget.student.schoolId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student ID Card'),
        actions: [
          BlocBuilder<StudentIdentityBloc, StudentIdentityState>(
            builder: (context, state) {
              if (state is StudentIdentityLoaded) {
                return IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () => _printIdCard(context, state.identity),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<StudentIdentityBloc, StudentIdentityState>(
        listener: (context, state) {
          if (state is StudentIdentityActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is StudentIdentityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is StudentIdentityLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StudentIdentityLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    _IdCardPreview(
                      student: widget.student,
                      identity: state.identity,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _printIdCard(context, state.identity),
                      icon: const Icon(Icons.print),
                      label: const Text('Print ID Card'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),
                    _NfcCardSection(student: widget.student, identity: state.identity, assignedCardUid: state.assignedCardUid),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BiometricEnrollmentScreen(
                            personId: widget.student.id,
                            personName: widget.student.name,
                            schoolId: widget.student.schoolId,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Enroll Fingerprint'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is StudentIdentityError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<StudentIdentityBloc>().add(
                            GenerateStudentIdentityEvent(widget.student),
                          );
                    },
                    child: const Text('Generate Identity'),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<StudentIdentityBloc>().add(
                      GenerateStudentIdentityEvent(widget.student),
                    );
              },
              child: const Text('Generate Student ID'),
            ),
          );
        },
      ),
    );
  }

  Future<void> _printIdCard(BuildContext context, StudentIdentity identity) async {
    final idCardService = GetIt.I<IdCardService>();
    final schoolName = context.read<ThemeProvider>().config?.schoolName ?? 'School Pulse Academy';
    try {
      final pdfData = await idCardService.generateIdCardPdf(
        schoolName: schoolName,
        studentName: widget.student.name,
        admissionNumber: widget.student.studentId,
        studentId: identity.uniqueSystemId,
        className: widget.student.className,
        stream: '', // Assuming stream is part of className or not available yet
        uniqueSystemId: identity.uniqueSystemId,
      );
      await idCardService.printIdCard(pdfData);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to print ID card: $e')),
        );
      }
    }
  }
}

class _IdCardPreview extends StatelessWidget {
  final Student student;
  final StudentIdentity identity;

  const _IdCardPreview({
    required this.student,
    required this.identity,
  });

  @override
  Widget build(BuildContext context) {
    final schoolName = context.watch<ThemeProvider>().config?.schoolName ?? 'SCHOOL PULSE ACADEMY';
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              schoolName.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: student.photoUrl != null
                  ? NetworkImage(student.photoUrl!)
                  : null,
              child: student.photoUrl == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              student.name.toUpperCase(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 32),
            _buildInfoRow('Admission No', student.studentId),
            _buildInfoRow('Class', student.className),
            _buildInfoRow('System ID', identity.uniqueSystemId),
            const SizedBox(height: 24),
            QrImageView(
              data: identity.uniqueSystemId,
              version: QrVersions.auto,
              size: 120.0,
            ),
            const SizedBox(height: 8),
            Text(
              identity.uniqueSystemId,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

// NFC card lifecycle - assign/replace/revoke/reactivate - surfaced right
// on the identity screen since that's where nfcStatus already lives.
class _NfcCardSection extends StatefulWidget {
  final Student student;
  final StudentIdentity identity;
  final String? assignedCardUid;

  const _NfcCardSection({required this.student, required this.identity, required this.assignedCardUid});

  @override
  State<_NfcCardSection> createState() => _NfcCardSectionState();
}

class _NfcCardSectionState extends State<_NfcCardSection> {
  bool _scanning = false;

  Future<String?> _scanCard(String promptMessage) async {
    final adapter = sl<NfcCredentialReaderAdapter>();
    if (!await adapter.isAvailable()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NFC is not available on this device')),
        );
      }
      return null;
    }

    setState(() => _scanning = true);
    final completer = Completer<String?>();
    StreamSubscription<ScanCredential>? subscription;

    subscription = adapter.credentials.listen((credential) {
      if (credential is NfcScanCredential && !completer.isCompleted) {
        completer.complete(credential.cardUid);
      }
    });

    // The NFC adapter never reads VerificationContext internally (it's
    // only required to satisfy the shared CredentialReaderAdapter
    // interface) - this placeholder exists purely to satisfy the type.
    final placeholderContext = VerificationContext(
      gate: Gate(
        id: 'nfc-assign',
        name: 'NFC Card Assignment',
        type: 'internal',
        location: '',
        assignedOfficerIds: const [],
        operatingHours: const {},
        allowedUserRoles: const [],
        requiredVerificationMethods: const [],
        schoolId: widget.student.schoolId,
      ),
      operatorUser: (context.read<AuthBloc>().state as AuthAuthenticated).user,
      purpose: 'student_identity.nfc_assign',
      deviceId: 'app',
      requestedAt: DateTime.now(),
    );

    if (mounted) {
      unawaited(showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Scan NFC Card'),
          content: Text(promptMessage),
          actions: [
            TextButton(
              onPressed: () {
                if (!completer.isCompleted) completer.complete(null);
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ));
    }

    await adapter.start(placeholderContext);
    final uid = await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => null,
    );
    await adapter.stop();
    await subscription.cancel();
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
    setState(() => _scanning = false);
    return uid;
  }

  Future<String?> _pickReason() {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Reason'),
        children: [
          for (final reason in const ['Lost', 'Stolen', 'Damaged', 'Other'])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, reason.toLowerCase()),
              child: Text(reason),
            ),
        ],
      ),
    );
  }

  void _assign() async {
    final uid = await _scanCard('Hold the new card near the device to assign it.');
    if (uid == null || !mounted) return;
    context.read<StudentIdentityBloc>().add(AssignNfcCardEvent(
          cardUid: uid,
          studentId: widget.student.id,
          uniqueSystemId: widget.identity.uniqueSystemId,
          schoolId: widget.student.schoolId,
        ));
  }

  void _replace() async {
    final oldUid = widget.assignedCardUid;
    if (oldUid == null) return;
    final reason = await _pickReason();
    if (reason == null || !mounted) return;
    final newUid = await _scanCard('Hold the replacement card near the device.');
    if (newUid == null || !mounted) return;
    context.read<StudentIdentityBloc>().add(ReplaceNfcCardEvent(
          oldCardUid: oldUid,
          newCardUid: newUid,
          studentId: widget.student.id,
          uniqueSystemId: widget.identity.uniqueSystemId,
          schoolId: widget.student.schoolId,
          reason: reason,
        ));
  }

  void _revoke() async {
    final uid = widget.assignedCardUid;
    if (uid == null) return;
    final reason = await _pickReason();
    if (reason == null || !mounted) return;
    context.read<StudentIdentityBloc>().add(RevokeNfcCardEvent(
          cardUid: uid,
          studentId: widget.student.id,
          schoolId: widget.student.schoolId,
          reason: reason,
        ));
  }

  void _reactivate() {
    final uid = widget.assignedCardUid;
    if (uid == null) return;
    context.read<StudentIdentityBloc>().add(ReactivateNfcCardEvent(
          cardUid: uid,
          studentId: widget.student.id,
          schoolId: widget.student.schoolId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.identity.nfcStatus;
    final Color statusColor = switch (status) {
      'active' => Colors.green,
      'revoked' => Colors.red,
      _ => Colors.grey,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('NFC Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 12),
            Chip(
              label: Text(status.toUpperCase()),
              backgroundColor: statusColor.withValues(alpha: 0.12),
              labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_scanning)
          const Center(child: CircularProgressIndicator())
        else
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (status != 'active')
                FilledButton.icon(
                  onPressed: _assign,
                  icon: const Icon(Icons.nfc),
                  label: Text(status == 'revoked' ? 'Assign Replacement Card' : 'Assign Card'),
                ),
              if (status == 'active' && widget.assignedCardUid != null) ...[
                OutlinedButton.icon(
                  onPressed: _replace,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Replace'),
                ),
                OutlinedButton.icon(
                  onPressed: _revoke,
                  icon: const Icon(Icons.block),
                  label: const Text('Revoke (lost/stolen)'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
              if (status == 'revoked' && widget.assignedCardUid != null)
                OutlinedButton.icon(
                  onPressed: _reactivate,
                  icon: const Icon(Icons.restore),
                  label: const Text('Reactivate Same Card'),
                ),
            ],
          ),
      ],
    );
  }
}
