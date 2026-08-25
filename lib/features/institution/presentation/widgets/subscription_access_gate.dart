import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/institution/domain/entities/institution_context.dart';
import 'package:school_pulse/features/institution/domain/services/subscription_access_resolver.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_cubit.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_state.dart';

/// App-wide subscription enforcement layer.
///
/// First activation: covers the app completely, so the school has no dashboard
/// access before its first manual payment is verified.
///
/// Renewal: leaves the already-configured dashboard visible behind a modal
/// barrier, but consumes every pointer event until renewal is approved. The
/// school never loses its data or context merely because a subscription ended.
class SubscriptionAccessGate extends StatefulWidget {
  const SubscriptionAccessGate({required this.child, super.key});

  final Widget child;

  @override
  State<SubscriptionAccessGate> createState() => _SubscriptionAccessGateState();
}

class _SubscriptionAccessGateState extends State<SubscriptionAccessGate> {
  static final Uri _paymentPortal = Uri.parse(
    'https://schoolpulse.victorbee.com/payment',
  );

  Timer? _clock;

  @override
  void initState() {
    super.initState();
    // The institution stream handles server changes immediately. This small
    // local ticker exists for the one case where nothing changes in Firestore:
    // an app remains open while the subscriptionExpiry clock passes.
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated ||
        authState.user.role == UserRole.superAdmin) {
      return widget.child;
    }

    return BlocBuilder<InstitutionContextCubit, InstitutionContextState>(
      builder: (context, institutionState) {
        if (institutionState is! InstitutionContextLoaded) return widget.child;

        final institution = institutionState.context;
        final resolver = SubscriptionAccessResolver.of(
          institution,
          role: authState.user.role,
        );
        switch (resolver.gateKind) {
          case AccessGateKind.initialPaymentRequired:
            return _InitialPaymentGate(
              institution: institution,
              isSchoolAdmin: authState.user.role == UserRole.schoolAdmin,
              onPay: () => _openPaymentPortal(context),
              onLogout: () => context.read<AuthBloc>().add(LogoutPressed()),
            );
          case AccessGateKind.renewalReadOnly:
            return _RenewalReadOnlyGate(
              institution: institution,
              isSchoolAdmin: true,
              onPay: () => _openPaymentPortal(context),
              child: widget.child,
            );
          case AccessGateKind.renewalBlocked:
            return _RenewalBlockedGate(
              institution: institution,
              onLogout: () => context.read<AuthBloc>().add(LogoutPressed()),
            );
          case AccessGateKind.none:
            return widget.child;
        }
      },
    );
  }

  static Future<void> _openPaymentPortal(BuildContext context) async {
    final opened = await launchUrl(
      _paymentPortal,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open the School Pulse payment portal. Visit schoolpulse.victorbee.com/payment.',
          ),
        ),
      );
    }
  }
}

class _InitialPaymentGate extends StatelessWidget {
  const _InitialPaymentGate({
    required this.institution,
    required this.isSchoolAdmin,
    required this.onPay,
    required this.onLogout,
  });

  final InstitutionContext institution;
  final bool isSchoolAdmin;
  final VoidCallback onPay;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final underReview = institution.isPaymentUnderReview;

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          underReview
                              ? Icons.schedule_rounded
                              : Icons.lock_outline_rounded,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        underReview
                            ? 'Payment under verification'
                            : 'Subscription payment required',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        institution.displayLabel,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        underReview
                            ? 'We received the payment proof. The first School Pulse dashboard will unlock only after the SaaS Owner verifies that the payment was received.'
                            : isSchoolAdmin
                            ? 'Your school application is approved. Complete the full subscription payment and upload proof before the first dashboard can open.'
                            : 'Your school is approved but has not completed its first subscription payment. Ask the School Administrator to complete payment.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (isSchoolAdmin && !underReview)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: onPay,
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text('Open Payment Portal'),
                          ),
                        ),
                      if (isSchoolAdmin && !underReview)
                        const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onLogout,
                          child: const Text('Sign Out'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Access updates automatically after payment approval.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RenewalReadOnlyGate extends StatelessWidget {
  const _RenewalReadOnlyGate({
    required this.child,
    required this.institution,
    required this.isSchoolAdmin,
    required this.onPay,
  });

  final Widget child;
  final InstitutionContext institution;
  final bool isSchoolAdmin;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final underReview = institution.isPaymentUnderReview;

    return Stack(
      fit: StackFit.expand,
      children: [
        AbsorbPointer(absorbing: true, child: child),
        ModalBarrier(dismissible: false, color: theme.colorScheme.scrim),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Material(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          underReview
                              ? Icons.schedule_rounded
                              : Icons.lock_clock_rounded,
                          size: 36,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          underReview
                              ? 'Renewal payment under review'
                              : 'Subscription renewal required',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          underReview
                              ? 'Your dashboard stays visible while we verify the renewal payment, but School Pulse actions remain locked until approval.'
                              : isSchoolAdmin
                              ? 'Your paid period has ended. The dashboard remains visible, but every action is locked until the full renewal payment is verified.'
                              : 'Your school subscription has expired. The dashboard remains visible but locked. Ask the School Administrator to renew School Pulse.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                        if (isSchoolAdmin && !underReview) ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: onPay,
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: const Text('Renew Subscription'),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          'Your school data is preserved. Access unlocks automatically after payment approval.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Every role except School Admin, once the subscription has lapsed: a
/// plain blocking screen with no renewal CTA (they can't act on it) and
/// none of _RenewalReadOnlyGate's dashboard-behind-a-barrier complexity -
/// they just need to know who can fix it.
class _RenewalBlockedGate extends StatelessWidget {
  const _RenewalBlockedGate({
    required this.institution,
    required this.onLogout,
  });

  final InstitutionContext institution;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.lock_clock_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'School Pulse subscription expired',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your school's School Pulse subscription has ended. Contact your School Administrator to renew access.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onLogout,
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
