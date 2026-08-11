import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../domain/entities/parent_module_visibility.dart';
import '../bloc/parent_access_cubit.dart';
import '../bloc/parent_access_state.dart';

/// Wraps a parent-facing screen so direct route navigation (deep link,
/// typed URL, or a stale push from before a relationship was restricted)
/// can't reach a module the current relationship doesn't grant - closing
/// the gap the quick-action grid and more-menu filtering alone don't
/// cover, since both only hide the *entry point*, not the destination
/// route itself.
class ParentModuleGuard extends StatelessWidget {
  final bool Function(ParentModuleVisibility visibility) isAllowed;
  final Widget child;

  const ParentModuleGuard({
    super.key,
    required this.isAllowed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentAccessCubit, ParentAccessState>(
      builder: (context, state) {
        if (state is ParentAccessLoading || state is ParentAccessInitial) {
          return const Scaffold(body: Center(child: SchoolPulseLoader()));
        }

        final visibility = state is ParentAccessResolved
            ? state.visibility
            : ParentModuleVisibility.none;

        if (!isAllowed(visibility)) {
          return Scaffold(
            body: EmptyState(
              icon: Icons.lock_outline,
              title: 'Not available',
              message: 'You do not have access to this for the selected child.',
            ),
          );
        }

        return child;
      },
    );
  }
}
