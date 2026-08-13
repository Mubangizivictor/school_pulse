import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_state.dart';

class BrandingInitializer extends StatelessWidget {
  final Widget child;
  const BrandingInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BrandingBloc, BrandingState>(
      listener: (context, state) {
        // PlatformBranding (logout, or InitializeBranding at cold start) and
        // BrandingLoading (a tenant switch in flight) must clear the
        // previous tenant's colours/title immediately - leaving them in
        // place until the next BrandingLoaded lands is exactly the stale-
        // branding-after-logout/account-switch bug this screen exists to
        // prevent.
        if (state is BrandingLoaded) {
          context.read<ThemeProvider>().updateBranding(state.branding);
        } else if (state is PlatformBranding || state is BrandingLoading) {
          context.read<ThemeProvider>().updateBranding(null);
        }
      },
      child: child,
    );
  }
}
