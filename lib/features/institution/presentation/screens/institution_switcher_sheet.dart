import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_cubit.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Lets a multi-institution user (e.g. a director or consultant working
/// across several tenants) switch their active institution context.
/// List-and-tap only for Phase 1 - no cross-institution dashboards,
/// notifications, or search.
class InstitutionSwitcherSheet extends StatelessWidget {
  const InstitutionSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const InstitutionSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final userId = authState.user.id;
    final firestore = di.sl<FirebaseFirestore>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Switch Institution'),
            const SizedBox(height: 12),
            FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: firestore
                  .collection('institution_memberships')
                  .where('userId', isEqualTo: userId)
                  .where('status', isEqualTo: 'active')
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: SchoolPulseLoader()),
                  );
                }
                final memberships = snapshot.data!.docs;
                if (memberships.isEmpty) {
                  return const EmptyState(
                    icon: Icons.apartment_outlined,
                    title: 'No other institutions',
                    message:
                        'You are not a member of any other institution yet.',
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: memberships.length,
                  itemBuilder: (context, index) {
                    final data = memberships[index].data();
                    final institutionId = data['institutionId'] as String;
                    final isActive =
                        context
                            .read<InstitutionContextCubit>()
                            .currentInstitutionId ==
                        institutionId;
                    return FutureBuilder<
                      DocumentSnapshot<Map<String, dynamic>>
                    >(
                      future: firestore
                          .collection('schools')
                          .doc(institutionId)
                          .get(),
                      builder: (context, schoolSnapshot) {
                        final name =
                            schoolSnapshot.data?.data()?['displayLabel'] ??
                            schoolSnapshot.data?.data()?['name'] ??
                            institutionId;
                        return ListTile(
                          leading: const Icon(Icons.apartment_outlined),
                          title: Text(name as String),
                          trailing: isActive
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.black,
                                )
                              : null,
                          // A client-side membership list is not sufficient
                          // authority to switch a tenant context. Re-enable
                          // this only when switching is backed by the
                          // authenticated session resolver.
                          onTap: null,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
