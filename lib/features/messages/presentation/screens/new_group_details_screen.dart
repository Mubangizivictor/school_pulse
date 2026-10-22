import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/bloc/messaging_bloc.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';
import 'package:school_pulse/features/messages/presentation/screens/select_contacts_screen.dart';

class NewGroupDetailsScreen extends StatefulWidget {
  /// The members picked on the previous screen. Null when the screen is
  /// reached without going through the picker, which leaves the member count
  /// at zero and the create button disabled.
  final NewConversationDraft? draft;

  const NewGroupDetailsScreen({super.key, this.draft});

  @override
  State<NewGroupDetailsScreen> createState() => _NewGroupDetailsScreenState();
}

class _NewGroupDetailsScreenState extends State<NewGroupDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  late ChatType _type = widget.draft?.type ?? ChatType.group;
  MessagePolicy _policy = MessagePolicy.everyone;
  File? _photo;
  bool _creating = false;

  List<MessageContact> get _members => widget.draft?.members ?? const [];

  @override
  void initState() {
    super.initState();
    // A channel is an announcement feed by default; a group is a conversation.
    if (_type == ChatType.channel || _type == ChatType.broadcast) {
      _policy = MessagePolicy.adminsOnly;
    }
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _screenTitle.toUpperCase(),
          style: AppTypography.titleLarge.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      bottomNavigationBar: MessagingUserBuilder(
        builder: (context, user) => _buildCreateBar(context, user),
      ),
      body: MessagingUserBuilder(
        builder: (context, user) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            0,
            AppSpacing.l,
            112,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.l),
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border.all(
                            color: colors.onSurface,
                            width: 1,
                          ),
                          image: _photo != null
                              ? DecorationImage(
                                  image: FileImage(_photo!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _photo != null
                            ? null
                            : Icon(
                                Icons.camera_alt_outlined,
                                size: 40,
                                color: colors.onSurface,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.onSurface,
                            border: Border.all(color: colors.surface, width: 1),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 20,
                            color: colors.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                (_photo == null ? 'Add Group Photo' : 'Change Group Photo')
                    .toUpperCase(),
                style: AppTypography.labelMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),
              _buildInputField(
                context,
                label: '$_typeLabel Name',
                hint: 'P7 - Mathematics Parents',
                controller: _nameController,
              ),
              const SizedBox(height: AppSpacing.l),
              _buildInputField(
                context,
                label: 'Description (Optional)',
                hint:
                    'This group is for all P7 parents to discuss Mathematics updates and homework.',
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSectionLabel(context, 'SETUP'),
              const SizedBox(height: AppSpacing.s),
              _buildSettingTile(
                context,
                Icons.person_add_outlined,
                'Add Members',
                '${_members.length} selected',
                onTap: () => context.pop(),
              ),
              _buildSettingTile(
                context,
                Icons.public,
                'Group Type',
                _typeLabel,
                onTap: _pickType,
              ),
              _buildSettingTile(
                context,
                Icons.admin_panel_settings_outlined,
                'Who can send messages?',
                _policy == MessagePolicy.everyone
                    ? 'All Members'
                    : 'Admins Only',
                onTap: _pickPolicy,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateBar(BuildContext context, UserEntity user) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.s,
        AppSpacing.l,
        AppSpacing.m,
      ),
      child: Container(
        padding: const EdgeInsets.only(top: AppSpacing.m),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.onSurface, width: 1)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _canCreate ? () => _create(user) : null,
            icon: _creating
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  )
                : const Icon(Icons.check_circle_outline_rounded),
            label: Text((_creating ? 'Creating…' : _createLabel).toUpperCase()),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.onSurface,
              foregroundColor: colors.surface,
              disabledBackgroundColor: colors.surfaceContainerHigh,
              disabledForegroundColor: colors.onSurfaceVariant,
              minimumSize: const Size.fromHeight(56),
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              textStyle: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _canCreate =>
      !_creating &&
      _nameController.text.trim().isNotEmpty &&
      _members.isNotEmpty;

  String get _screenTitle {
    switch (_type) {
      case ChatType.broadcast:
        return 'New Broadcast';
      case ChatType.channel:
        return 'New Channel';
      default:
        return 'New Group';
    }
  }

  String get _createLabel {
    switch (_type) {
      case ChatType.broadcast:
        return 'Create Broadcast';
      case ChatType.channel:
        return 'Create Channel';
      default:
        return 'Create Group';
    }
  }

  String get _typeLabel {
    switch (_type) {
      case ChatType.broadcast:
        return 'Broadcast List';
      case ChatType.channel:
        return 'Announcement Channel';
      default:
        return 'Private Group';
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null || !mounted) return;
    setState(() => _photo = File(picked.path));
  }

  void _pickType() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (sheetContext) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(sheetContext).colorScheme.onSurface,
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in [
                ChatType.group,
                ChatType.broadcast,
                ChatType.channel,
              ])
                ListTile(
                  title: Text(
                    (option == ChatType.group
                            ? 'Private Group'
                            : option == ChatType.broadcast
                                ? 'Broadcast List'
                                : 'Announcement Channel')
                        .toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(sheetContext).colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    option == ChatType.group
                        ? 'Everyone can see and reply to each other'
                        : option == ChatType.broadcast
                            ? 'One-way messages to many recipients'
                            : 'An announcement feed only admins post to',
                    style: TextStyle(
                      color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  trailing: _type == option
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(sheetContext).colorScheme.onSurface,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() {
                      _type = option;
                      _policy = _type == ChatType.group
                          ? MessagePolicy.everyone
                          : MessagePolicy.adminsOnly;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickPolicy() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (sheetContext) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(sheetContext).colorScheme.onSurface,
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in MessagePolicy.values)
                ListTile(
                  title: Text(
                    (option == MessagePolicy.everyone
                            ? 'All Members'
                            : 'Admins Only')
                        .toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(sheetContext).colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  trailing: _policy == option
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(sheetContext).colorScheme.onSurface,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => _policy = option);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _create(UserEntity user) async {
    setState(() => _creating = true);
    final result = await context.dispatchMessagingAction(
      ConversationCreateRequested(
        type: _type,
        title: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        members: _members,
        messagePolicy: _policy,
      ),
    );
    if (!mounted) return;

    if (result.actionStatus != MessagingActionStatus.success ||
        result.createdConversationId == null) {
      setState(() => _creating = false);
      context.showMessagingSnack(
        result.lastDecision?.message ??
            'Could not create: ${result.lastActionError}',
      );
      return;
    }

    final conversationId = result.createdConversationId!;
    // The avatar is uploaded after creation so it can be filed under the
    // conversation's own storage path. Not itself permission-gated - group
    // creation was already the gate; this is just the follow-up write.
    if (_photo != null) {
      try {
        final url = await context.messages.uploadAttachment(
          schoolId: user.schoolId,
          conversationId: conversationId,
          file: _photo!,
          fileName: 'avatar.jpg',
        );
        if (!mounted) return;
        await context.messages.updateGroupInfo(conversationId, avatarUrl: url);
      } catch (e) {
        if (!mounted) return;
        context.showMessagingSnack(
          'Group created, but the photo could not be saved: $e',
        );
      }
    }

    if (!mounted) return;
    context.go('/messages/chat/$conversationId');
  }

  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: colors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colors.onSurfaceVariant,
            ),
            filled: true,
            fillColor: colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: colors.onSurface,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: colors.onSurface,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: colors.onSurface,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) => Text(
        label.toUpperCase(),
        style: AppTypography.labelMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      );

  Widget _buildSettingTile(
    BuildContext context,
    IconData icon,
    String title,
    String value, {
    VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.onSurface, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.onSurface,
            border: Border.all(color: colors.onSurface, width: 1),
          ),
          child: Icon(
            icon,
            color: colors.surface,
            size: 20,
          ),
        ),
        title: Text(
          title.toUpperCase(),
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toUpperCase(),
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: colors.onSurface,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
