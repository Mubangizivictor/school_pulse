import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:school_pulse/core/services/nfc/nfc_credential_reader_adapter.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/biometrics/presentation/screens/biometric_enrollment_screen.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/injection_container.dart';

import '../../../student/domain/entities/student.dart';
import '../../domain/entities/student_identity.dart';
import '../../domain/services/id_card_service.dart';
import '../bloc/student_identity_bloc.dart';
import '../bloc/student_identity_event.dart';
import '../bloc/student_identity_state.dart';

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
    context.read<StudentIdentityBloc>().add(
      LoadStudentIdentityEvent(
        widget.student.id,
        schoolId: widget.student.schoolId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student ID Card')),
      body: BlocConsumer<StudentIdentityBloc, StudentIdentityState>(
        listener: (context, state) {
          if (state is StudentIdentityActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is StudentIdentityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is StudentIdentityLoading) {
            return const Center(child: SchoolPulseLoader());
          }

          if (state is StudentIdentityLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _IdCardPreview(
                    student: widget.student,
                    identity: state.identity,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _printIdCard(context, state.identity),
                        icon: const Icon(Icons.print_outlined),
                        label: const Text('Print ID Card'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.read<StudentIdentityBloc>().add(
                          RegenerateQrCredentialEvent(state.identity),
                        ),
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('Replace QR'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),
                  _NfcCardSection(
                    student: widget.student,
                    identity: state.identity,
                    assignedCardUid: state.assignedCardUid,
                  ),
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),
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
            );
          }

          if (state is StudentIdentityError) {
            return _IdentityErrorState(
              message: state.message,
              onRetry: () => context.read<StudentIdentityBloc>().add(
                GenerateStudentIdentityEvent(widget.student),
              ),
            );
          }

          return Center(
            child: FilledButton.icon(
              onPressed: () => context.read<StudentIdentityBloc>().add(
                GenerateStudentIdentityEvent(widget.student),
              ),
              icon: const Icon(Icons.badge_outlined),
              label: const Text('Generate Student ID'),
            ),
          );
        },
      ),
    );
  }

  Future<void> _printIdCard(
    BuildContext context,
    StudentIdentity identity,
  ) async {
    final idCardService = GetIt.I<IdCardService>();
    final schoolName =
        context.read<ThemeProvider>().config?.schoolName ?? 'School Pulse Academy';
    try {
      final pdfData = await idCardService.generateIdCardPdf(
        schoolName: schoolName,
        studentName: widget.student.name,
        admissionNumber: widget.student.studentId,
        studentId: identity.uniqueSystemId,
        className: widget.student.className,
        stream: '',
        uniqueSystemId: identity.uniqueSystemId,
        qrCodeData: identity.qrCodeData.isNotEmpty
            ? identity.qrCodeData
            : identity.uniqueSystemId,
      );
      await idCardService.printIdCard(pdfData);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print ID card: $error')),
      );
    }
  }
}

class _IdentityErrorState extends StatelessWidget {
  const _IdentityErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

class _IdCardPreview extends StatelessWidget {
  const _IdCardPreview({required this.student, required this.identity});

  final Student student;
  final StudentIdentity identity;

  @override
  Widget build(BuildContext context) {
    final schoolName =
        context.watch<ThemeProvider>().config?.schoolName ?? 'SCHOOL PULSE ACADEMY';
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              schoolName.toUpperCase(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
            ),
            const SizedBox(height: 18),
            CircleAvatar(
              radius: 46,
              backgroundImage: student.photoUrl?.isNotEmpty == true
                  ? NetworkImage(student.photoUrl!)
                  : null,
              child: student.photoUrl?.isNotEmpty == true
                  ? null
                  : const Icon(Icons.person, size: 44),
            ),
            const SizedBox(height: 14),
            Text(
              student.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 14),
            Text('Admission: ${student.studentId}'),
            Text('Class: ${student.className}'),
            const SizedBox(height: 18),
            QrImageView(
              data: identity.qrCodeData.isNotEmpty
                  ? identity.qrCodeData
                  : identity.uniqueSystemId,
              version: QrVersions.auto,
              size: 132,
            ),
          ],
        ),
      ),
    );
  }
}

class _NfcCardSection extends StatefulWidget {
  const _NfcCardSection({
    required this.student,
    required this.identity,
    required this.assignedCardUid,
  });

  final Student student;
  final StudentIdentity identity;
  final String? assignedCardUid;

  @override
  State<_NfcCardSection> createState() => _NfcCardSectionState();
}

class _NfcCardSectionState extends State<_NfcCardSection> {
  bool _scanning = false;

  Future<String?> _scanCard(String promptMessage) async {
    if (_scanning) return null;

    final adapter = sl<NfcCredentialReaderAdapter>();
    StreamSubscription<ScanCredential>? subscription;
    final completer = Completer<String?>();

    try {
      final available = await adapter.isAvailable();
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'NFC is unavailable. NFC card scanning must be tested on a physical NFC-capable iPhone, not the iOS Simulator.',
              ),
            ),
          );
        }
        return null;
      }

      final auth = context.read<AuthBloc>().state;
      if (auth is! AuthAuthenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your session is not ready. Sign in again and retry.')),
          );
        }
        return null;
      }

      if (mounted) {
        setState(() => _scanning = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(promptMessage),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      subscription = adapter.credentials.listen(
        (credential) {
          if (credential is NfcScanCredential && !completer.isCompleted) {
            completer.complete(credential.cardUid);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!completer.isCompleted) completer.completeError(error, stackTrace);
        },
      );

      final verificationContext = VerificationContext(
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
        operatorUser: auth.user,
        purpose: 'student_identity.nfc_assign',
        deviceId: 'app',
        requestedAt: DateTime.now(),
      );

      // On a physical iPhone this starts Apple's native Core NFC sheet.
      // We deliberately do not put a Flutter AlertDialog on top of it.
      await adapter.start(verificationContext);

      final uid = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => null,
      );

      if (uid == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No NFC card was detected. Try again and hold the card near the top edge of the physical iPhone.'),
          ),
        );
      }
      return uid;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start NFC scan: $error')),
        );
      }
      return null;
    } finally {
      try {
        await adapter.stop();
      } catch (_) {}
      await subscription?.cancel();
      if (mounted) setState(() => _scanning = false);
    }
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

  Future<void> _assign() async {
    final uid = await _scanCard(
      'Hold the card near the top edge of your physical iPhone until Apple confirms the scan.',
    );
    if (uid == null || !mounted) return;
    context.read<StudentIdentityBloc>().add(
      AssignNfcCardEvent(
        cardUid: uid,
        studentId: widget.student.id,
        uniqueSystemId: widget.identity.uniqueSystemId,
        schoolId: widget.student.schoolId,
      ),
    );
  }

  Future<void> _replace() async {
    final oldUid = widget.assignedCardUid;
    if (oldUid == null) return;
    final reason = await _pickReason();
    if (reason == null || !mounted) return;
    final newUid = await _scanCard(
      'Hold the replacement card near the top edge of your physical iPhone.',
    );
    if (newUid == null || !mounted) return;
    context.read<StudentIdentityBloc>().add(
      ReplaceNfcCardEvent(
        oldCardUid: oldUid,
        newCardUid: newUid,
        studentId: widget.student.id,
        uniqueSystemId: widget.identity.uniqueSystemId,
        schoolId: widget.student.schoolId,
        reason: reason,
      ),
    );
  }

  Future<void> _revoke() async {
    final uid = widget.assignedCardUid;
    if (uid == null) return;
    final reason = await _pickReason();
    if (reason == null || !mounted) return;
    context.read<StudentIdentityBloc>().add(
      RevokeNfcCardEvent(
        cardUid: uid,
        studentId: widget.student.id,
        schoolId: widget.student.schoolId,
        reason: reason,
      ),
    );
  }

  void _reactivate() {
    final uid = widget.assignedCardUid;
    if (uid == null) return;
    context.read<StudentIdentityBloc>().add(
      ReactivateNfcCardEvent(
        cardUid: uid,
        studentId: widget.student.id,
        schoolId: widget.student.schoolId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.identity.nfcStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'NFC Card',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(width: 10),
            Chip(label: Text(status.toUpperCase())),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _scanning
              ? 'Waiting for a physical NFC card…'
              : 'Assign a physical NFC card to this student. iOS will show its native NFC scan sheet.',
        ),
        const SizedBox(height: 14),
        if (_scanning)
          const Center(child: SchoolPulseLoader())
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (status != 'active')
                FilledButton.icon(
                  onPressed: _assign,
                  icon: const Icon(Icons.nfc),
                  label: Text(
                    status == 'revoked' ? 'Assign Replacement Card' : 'Assign Card',
                  ),
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
                  label: const Text('Revoke'),
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
