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
        if (state is BrandingLoaded) {
          context.read<ThemeProvider>().updateBranding(state.branding);
        }
      },
      child: child,
    );
  }
}
