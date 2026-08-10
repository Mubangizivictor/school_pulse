import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';
import '../../domain/entities/announcement_entity.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final String announcementId;

  const AnnouncementDetailScreen({super.key, required this.announcementId});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    final user = authState.user;

    return BlocProvider(
      create: (_) => sl<AnnouncementBloc>()
        ..add(
          LoadAnnouncementsRequested(schoolId: user.schoolId, operatorUser: user),
        ),
      child: _AnnouncementDetailBody(announcementId: announcementId),
    );
  }
}

class _AnnouncementDetailBody extends StatelessWidget {
  final String announcementId;

  const _AnnouncementDetailBody({required this.announcementId});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state as AuthAuthenticated;
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Announcement'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<AnnouncementBloc, AnnouncementState>(
        listener: (context, state) {
          if (state is AnnouncementActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is AnnouncementActionDenied) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AnnouncementLoading || state is AnnouncementInitial) {
            return const Center(child: SchoolPulseLoader());
          }
          if (state is AnnouncementError) {
            return Center(child: Text(state.message));
          }
          if (state is! AnnouncementLoaded) {
            return const SizedBox.shrink();
          }

          AnnouncementEntity? announcement;
          for (final a in state.announcements) {
            if (a.id == announcementId) {
              announcement = a;
              break;
            }
          }

          if (announcement == null) {
            return const EmptyState(
              icon: Icons.campaign_outlined,
              title: 'Not found',
              message: 'This announcement could not be found.',
            );
          }

          final a = announcement;
          final isDraft = a.status == AnnouncementStatus.draft;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      a.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                  StatusBadge(
                    label: isDraft ? 'Draft' : 'Published',
                    color: isDraft
                        ? AppColors.warning(context)
                        : AppColors.success(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'By ${a.authorName}',
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
              const SizedBox(height: 16),
              Text(
                a.body,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              if (state.canManage) ...[
                if (isDraft)
                  PrimaryButton(
                    label: 'Publish',
                    icon: Icons.send_rounded,
                    onPressed: () => context.read<AnnouncementBloc>().add(
                      PublishAnnouncementRequested(
                        schoolId: a.schoolId,
                        announcementId: a.id,
                        operatorUser: user,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  onPressed: () => context.push(
                    '/staff/more/announcements/${a.id}/edit',
                  ),
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Delete',
                  icon: Icons.delete_outline,
                  onPressed: () async {
                    final confirmed = await confirmActionDialog(
                      context,
                      title: 'Delete announcement',
                      message: 'Are you sure you want to delete this announcement?',
                      confirmLabel: 'Delete',
                      isDestructive: true,
                    );
                    if (confirmed == true && context.mounted) {
                      context.read<AnnouncementBloc>().add(
                        DeleteAnnouncementRequested(
                          schoolId: a.schoolId,
                          announcementId: a.id,
                          operatorUser: user,
                        ),
                      );
                      context.pop();
                    }
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
