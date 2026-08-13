import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_event.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_state.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';

/// Resolves trusted tenant identity before any tenant route can render.
class AuthenticatedBootstrapScreen extends StatefulWidget {
  const AuthenticatedBootstrapScreen({super.key});

  @override
  State<AuthenticatedBootstrapScreen> createState() =>
      _AuthenticatedBootstrapScreenState();
}

class _AuthenticatedBootstrapScreenState
    extends State<AuthenticatedBootstrapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  void _resolve() {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated || auth.user.schoolId.isEmpty) return;
    final branding = context.read<BrandingBloc>().state;
    if (branding is BrandingLoaded &&
        branding.branding?.schoolId == auth.user.schoolId) {
      context.go('/school-splash');
      return;
    }
    context.read<BrandingBloc>().add(
      FetchBrandingForSchool(auth.user.schoolId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final missingSchool =
        auth is AuthAuthenticated && auth.user.schoolId.isEmpty;
    return BlocListener<BrandingBloc, BrandingState>(
      listener: (context, state) {
        if (state is BrandingLoaded) context.go('/school-splash');
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PulseLogo(variant: PulseLogoVariant.auth, width: 176),
              const SizedBox(height: 24),
              Text(
                missingSchool
                    ? 'Your account is not linked to a school'
                    : 'Preparing your school workspace',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(height: 12),
              BlocBuilder<BrandingBloc, BrandingState>(
                builder: (_, state) {
                  if (state is BrandingError) {
                    return TextButton.icon(
                      onPressed: _resolve,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry connection'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
