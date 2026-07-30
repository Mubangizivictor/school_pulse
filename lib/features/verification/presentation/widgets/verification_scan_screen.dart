import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_decision.dart';
import 'package:school_pulse/features/verification/domain/repositories/credential_reader_adapter.dart';
import 'package:school_pulse/features/verification/presentation/bloc/credential_scan_bloc.dart';
import 'package:school_pulse/features/verification/presentation/bloc/credential_scan_event.dart';
import 'package:school_pulse/features/verification/presentation/bloc/verification_session_bloc.dart';
import 'package:school_pulse/features/verification/presentation/bloc/verification_session_event.dart';
import 'package:school_pulse/features/verification/presentation/bloc/verification_session_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Shared, full-screen, high-contrast verification result view used by
/// every authorized entry point (Security Dashboard's Verify Entry/Exit,
/// Gatekeeper Simple Mode's Scan tile). Exactly one of [initialCredential]
/// (QR/manual/staff/parent-code - already captured by the calling
/// screen's own selection UI) or [liveKind] (NFC - this screen opens the
/// reader session itself) must be supplied.
class VerificationScanScreen extends StatefulWidget {
  final VerificationContext context;
  final ScanCredential? initialCredential;
  final ScanCredentialKind? liveKind;

  const VerificationScanScreen({
    super.key,
    required this.context,
    this.initialCredential,
    this.liveKind,
  }) : assert(
          (initialCredential == null) != (liveKind == null),
          'Supply exactly one of initialCredential or liveKind',
        );

  @override
  State<VerificationScanScreen> createState() => _VerificationScanScreenState();
}

class _VerificationScanScreenState extends State<VerificationScanScreen> {
  late final VerificationSessionBloc _sessionBloc;
  CredentialScanBloc? _scanBloc;

  @override
  void initState() {
    super.initState();
    _sessionBloc = di.sl<VerificationSessionBloc>();

    final initial = widget.initialCredential;
    if (initial != null) {
      _sessionBloc.add(VerificationCredentialCaptured(credential: initial, context: widget.context));
    } else {
      _scanBloc = di.sl<CredentialScanBloc>()
        ..add(StartCredentialScan(kind: widget.liveKind!, context: widget.context))
        ..stream.listen((state) {
          if (state.lastCredential != null) {
            _sessionBloc.add(VerificationCredentialCaptured(
              credential: state.lastCredential!,
              context: widget.context,
            ));
          }
        });
    }
  }

  @override
  void dispose() {
    _scanBloc?.close();
    _sessionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _sessionBloc,
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<VerificationSessionBloc, VerificationSessionState>(
            builder: (context, state) => switch (state) {
              VerificationIdle() || VerificationResolving() => const _StatusView(
                  color: Colors.blue,
                  icon: Icons.sensors,
                  title: 'Scanning…',
                  message: 'Present a card, code, or scan a QR to continue.',
                ),
              VerificationDecided(:final decision) => _DecidedView(decision: decision),
              VerificationRecording() => const _StatusView(
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                  title: 'Recording…',
                  message: '',
                ),
              VerificationRecorded(:final decision, :final direction) => _RecordedView(
                  decision: decision,
                  direction: direction,
                ),
              VerificationSessionError(:final message) => _StatusView(
                  color: Colors.red,
                  icon: Icons.error_outline,
                  title: 'Something went wrong',
                  message: message,
                  showDone: true,
                ),
            },
          ),
        ),
      ),
    );
  }
}

class _DecidedView extends StatelessWidget {
  final VerificationDecision decision;

  const _DecidedView({required this.decision});

  @override
  Widget build(BuildContext context) {
    final isAllowed = decision.outcome == VerificationOutcome.allowed;
    final isWarning = decision.outcome == VerificationOutcome.alreadyRecorded ||
        decision.outcome == VerificationOutcome.requiresOverride;
    final color = isAllowed ? Colors.green : (isWarning ? Colors.orange : Colors.red);
    final icon = isAllowed ? Icons.check_circle : (isWarning ? Icons.warning_amber_rounded : Icons.cancel);
    final title = isAllowed ? 'VERIFIED' : (isWarning ? 'ALREADY RECORDED' : 'DENIED');

    return _ResultScaffold(
      color: color,
      icon: icon,
      title: title,
      subtitle: _identityLabel(decision.identity),
      message: decision.message,
      footer: isAllowed
          ? _DirectionConfirmButtons(suggestedDirection: decision.suggestedDirection)
          : const _DoneButton(),
    );
  }

  String _identityLabel(ResolvedIdentity identity) => switch (identity) {
        StudentResolvedIdentity(:final name, :final studentCode) => '$name • $studentCode',
        StaffResolvedIdentity(:final name, :final staffCode) => '$name • ${staffCode ?? 'Staff'}',
        ParentPickupResolvedIdentity(:final childName) => '$childName (via parent code)',
        UnresolvedResolvedIdentity() => 'Unknown',
      };
}

class _RecordedView extends StatelessWidget {
  final VerificationDecision decision;
  final String direction;

  const _RecordedView({required this.decision, required this.direction});

  @override
  Widget build(BuildContext context) {
    return _ResultScaffold(
      color: Colors.green,
      icon: Icons.check_circle,
      title: direction == 'In' ? 'ENTRY RECORDED' : 'EXIT RECORDED',
      subtitle: '',
      message: '',
      footer: const _DoneButton(),
    );
  }
}

class _DirectionConfirmButtons extends StatelessWidget {
  final String? suggestedDirection;

  const _DirectionConfirmButtons({this.suggestedDirection});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: () =>
              context.read<VerificationSessionBloc>().add(const VerificationDirectionConfirmed('In')),
          icon: const Icon(Icons.login),
          label: Text(suggestedDirection == 'In' ? 'Confirm In (suggested)' : 'Confirm In'),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: () =>
              context.read<VerificationSessionBloc>().add(const VerificationDirectionConfirmed('Out')),
          style: FilledButton.styleFrom(backgroundColor: Colors.blueGrey),
          icon: const Icon(Icons.logout),
          label: Text(suggestedDirection == 'Out' ? 'Confirm Out (suggested)' : 'Confirm Out'),
        ),
      ],
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Done'),
    );
  }
}

class _ResultScaffold extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final String message;
  final Widget footer;

  const _ResultScaffold({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.message,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 96, color: Colors.white),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(subtitle, style: const TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
          ],
          if (message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(fontSize: 16, color: Colors.white70), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 32),
          footer,
        ],
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String message;
  final bool showDone;

  const _StatusView({
    required this.color,
    required this.icon,
    required this.title,
    required this.message,
    this.showDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return _ResultScaffold(
      color: color,
      icon: icon,
      title: title,
      subtitle: '',
      message: message,
      footer: showDone ? const _DoneButton() : const SizedBox.shrink(),
    );
  }
}
