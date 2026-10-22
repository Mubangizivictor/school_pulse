import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../widgets/communication_config_dialogs.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';

/// Announcement/notification categories and reusable message templates
/// Structure exposes for Messaging/Notifications to consume - delivery
/// infrastructure itself lives in those modules, untouched here.
class CommunicationConfigScreen extends StatefulWidget {
  final int initialTab;
  const CommunicationConfigScreen({super.key, this.initialTab = 0});

  @override
  State<CommunicationConfigScreen> createState() =>
      _CommunicationConfigScreenState();
}

class _CommunicationConfigScreenState extends State<CommunicationConfigScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab.clamp(0, 2);
  }

  @override
  void didUpdateWidget(covariant CommunicationConfigScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selectedIndex = widget.initialTab.clamp(0, 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AdminAppBar(title: 'Communication Configuration'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => context.go(
                    '/staff/admin/structure/communication-config?tab=0',
                  ),
                  child: const Text('Announcements'),
                ),
                OutlinedButton(
                  onPressed: () => context.go(
                    '/staff/admin/structure/communication-config?tab=1',
                  ),
                  child: const Text('Notifications'),
                ),
                OutlinedButton(
                  onPressed: () => context.go(
                    '/staff/admin/structure/communication-config?tab=2',
                  ),
                  child: const Text('Templates'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<StructureBloc, StructureState>(
              builder: (context, state) => switch (_selectedIndex) {
                0 => _AnnouncementCategoriesTab(state: state),
                1 => _NotificationCategoriesTab(state: state),
                _ => _MessageTemplatesTab(state: state),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCategoriesTab extends StatelessWidget {
  final StructureState state;
  const _AnnouncementCategoriesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.announcementCategories.isEmpty
          ? const StructureEmptyHint(
              'No announcement categories defined yet.\ne.g. Academic, Sports, Emergency.',
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.l),
              itemCount: state.announcementCategories.length,
              itemBuilder: (context, index) {
                final category = state.announcementCategories[index];
                return StructureListRow(
                  icon: Icons.campaign_outlined,
                  color: Colors.black,
                  title: category.name,
                  isActive: category.isActive,
                  badge: StructureStatusBadge(
                    label: 'Active',
                    isActive: category.isActive,
                  ),
                  onEdit: () => showAnnouncementCategoryFormDialog(
                    context,
                    existing: category,
                    schoolId: schoolId,
                    onSave: (u) =>
                        bloc.add(SaveAnnouncementCategoryRequested(u)),
                  ),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Category',
                      message: 'Delete "${category.name}"?',
                    );
                    if (confirmed == true) {
                      bloc.add(
                        DeleteAnnouncementCategoryRequested(category.id),
                      );
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary(context),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () => showAnnouncementCategoryFormDialog(
          context,
          schoolId: schoolId,
          onSave: (c) => bloc.add(SaveAnnouncementCategoryRequested(c)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }
}

class _NotificationCategoriesTab extends StatelessWidget {
  final StructureState state;
  const _NotificationCategoriesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.notificationCategories.isEmpty
          ? const StructureEmptyHint(
              'No notification categories defined yet.\ne.g. Fee Reminder, Homework.',
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.l),
              itemCount: state.notificationCategories.length,
              itemBuilder: (context, index) {
                final category = state.notificationCategories[index];
                return StructureListRow(
                  icon: Icons.notifications_outlined,
                  color: Colors.black,
                  title: category.name,
                  isActive: category.isActive,
                  badge: StructureStatusBadge(
                    label: 'Active',
                    isActive: category.isActive,
                  ),
                  onEdit: () => showNotificationCategoryFormDialog(
                    context,
                    existing: category,
                    schoolId: schoolId,
                    onSave: (u) =>
                        bloc.add(SaveNotificationCategoryRequested(u)),
                  ),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Category',
                      message: 'Delete "${category.name}"?',
                    );
                    if (confirmed == true) {
                      bloc.add(
                        DeleteNotificationCategoryRequested(category.id),
                      );
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary(context),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () => showNotificationCategoryFormDialog(
          context,
          schoolId: schoolId,
          onSave: (c) => bloc.add(SaveNotificationCategoryRequested(c)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }
}

class _MessageTemplatesTab extends StatelessWidget {
  final StructureState state;
  const _MessageTemplatesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.messageTemplates.isEmpty
          ? const StructureEmptyHint(
              'No message templates defined yet.\ne.g. Fee Due Reminder, Attendance Alert.',
            )
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.l),
              itemCount: state.messageTemplates.length,
              itemBuilder: (context, index) {
                final template = state.messageTemplates[index];
                return StructureListRow(
                  icon: Icons.mail_outline,
                  color: Colors.black,
                  title: template.name,
                  subtitle: template.channel,
                  isActive: template.isActive,
                  badge: StructureStatusBadge(
                    label: 'Active',
                    isActive: template.isActive,
                  ),
                  onEdit: () => showMessageTemplateFormDialog(
                    context,
                    existing: template,
                    schoolId: schoolId,
                    onSave: (u) => bloc.add(SaveMessageTemplateRequested(u)),
                  ),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Template',
                      message: 'Delete "${template.name}"?',
                    );
                    if (confirmed == true) {
                      bloc.add(DeleteMessageTemplateRequested(template.id));
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary(context),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () => showMessageTemplateFormDialog(
          context,
          schoolId: schoolId,
          onSave: (t) => bloc.add(SaveMessageTemplateRequested(t)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Template'),
      ),
    );
  }
}
