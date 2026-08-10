import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/injection_container.dart';

class ActiveSessionsScreen extends StatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  State<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends State<ActiveSessionsScreen> {
  bool _revoking = false;

  Future<void> _revokeSessions() async {
    final confirmed = await confirmActionDialog(
      context,
      title: 'Sign out on all devices?',
      message:
          'This will sign out this device and every other device using your account. You will need to sign in again.',
      confirmLabel: 'Sign out everywhere',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _revoking = true);
    try {
      await FirebaseFunctions.instance
          .httpsCallable('revokeAllSessions')
          .call<void>();
      await sl<FirebaseAuth>().signOut();
      if (!mounted) return;
      context.read<AuthBloc>().add(LogoutPressed());
      context.go('/welcome');
    } on FirebaseFunctionsException catch (e) {
      _showError(e.message ?? 'Unable to sign out active sessions.');
    } catch (_) {
      _showError('Unable to sign out active sessions. Please try again.');
    } finally {
      if (mounted) setState(() => _revoking = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = sl<FirebaseAuth>().currentUser;
    final lastSignIn = user?.metadata.lastSignInTime;
    final signedInLabel = lastSignIn == null
        ? 'Current session'
        : 'Signed in ${DateFormat.yMMMd().add_jm().format(lastSignIn.toLocal())}';

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Active Sessions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Row(
              children: [
                Icon(Icons.smartphone, color: AppColors.primary(context)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Device',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        signedInLabel,
                        style: TextStyle(color: AppColors.textMuted(context)),
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: 'Active', color: AppColors.success(context)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SecondaryButton(
            label: _revoking ? 'Signing out…' : 'Sign Out on All Devices',
            icon: Icons.logout,
            onPressed: _revoking ? null : _revokeSessions,
          ),
          const SizedBox(height: 12),
          Text(
            'For your security, this also signs out this device.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted(context)),
          ),
        ],
      ),
    );
  }
}
