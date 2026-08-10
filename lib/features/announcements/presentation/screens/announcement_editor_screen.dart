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

/// Admin-only editor for creating/updating a school-wide announcement.
/// Client-side gate on Permission.announcementManage via the loaded bloc
/// state's `canManage` flag - real enforcement stays in Firestore rules.
class AnnouncementEditorScreen extends StatelessWidget {
  final String? announcementId;

  const AnnouncementEditorScreen({super.key, this.announcementId});

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
      child: _AnnouncementEditorBody(announcementId: announcementId),
    );
  }
}

class _AnnouncementEditorBody extends StatefulWidget {
  final String? announcementId;

  const _AnnouncementEditorBody({this.announcementId});

  @override
  State<_AnnouncementEditorBody> createState() =>
      _AnnouncementEditorBodyState();
}

class _AnnouncementEditorBodyState extends State<_AnnouncementEditorBody> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _initialized = false;
  AnnouncementEntity? _existing;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _initFromLoaded(AnnouncementLoaded state) {
    if (_initialized || widget.announcementId == null) return;
    for (final a in state.announcements) {
      if (a.id == widget.announcementId) {
        _existing = a;
        _titleController.text = a.title;
        _bodyController.text = a.body;
        break;
      }
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state as AuthAuthenticated;
    final user = authState.user;
    final isEditing = widget.announcementId != null;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Announcement' : 'New Announcement'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<AnnouncementBloc, AnnouncementState>(
        listener: (context, state) {
          if (state is AnnouncementLoaded) {
            _initFromLoaded(state);
          }
          if (!state.canManageOrFalse) return;
        },
        builder: (context, state) {
          if (state is AnnouncementLoading || state is AnnouncementInitial) {
            return const Center(child: SchoolPulseLoader());
          }
          if (state is AnnouncementLoaded && !state.canManage) {
            return const EmptyState(
              icon: Icons.lock_outline,
              title: 'Not permitted',
              message: 'You do not have permission to manage announcements.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppSearchField(
                controller: _titleController,
                hintText: 'Title',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bodyController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Write the announcement...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: isEditing ? 'Save Changes' : 'Save Draft',
                onPressed: () {
                  final now = DateTime.now();
                  final announcement = AnnouncementEntity(
                    id: _existing?.id ?? '',
                    schoolId: user.schoolId,
                    title: _titleController.text.trim(),
                    body: _bodyController.text.trim(),
                    authorId: user.id,
                    authorName: user.name,
                    status: _existing?.status ?? AnnouncementStatus.draft,
                    createdAt: _existing?.createdAt ?? now,
                    updatedAt: now,
                    publishedAt: _existing?.publishedAt,
                  );
                  if (isEditing) {
                    context.read<AnnouncementBloc>().add(
                      UpdateAnnouncementRequested(
                        announcement: announcement,
                        operatorUser: user,
                      ),
                    );
                  } else {
                    context.read<AnnouncementBloc>().add(
                      CreateAnnouncementRequested(
                        announcement: announcement,
                        operatorUser: user,
                      ),
                    );
                  }
                  context.pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

extension on AnnouncementState {
  bool get canManageOrFalse =>
      this is AnnouncementLoaded && (this as AnnouncementLoaded).canManage;
}
