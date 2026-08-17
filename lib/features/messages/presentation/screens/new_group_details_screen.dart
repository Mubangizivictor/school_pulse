import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _screenTitle,
          style: AppTypography.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: MessagingUserBuilder(
        builder: (context, user) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
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
                          color: AppColors.surfaceDark,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
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
                            : const Icon(
                                Icons.camera_alt_outlined,
                                size: 40,
                                color: AppColors.electricBlue,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.electricBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _photo == null ? 'Add Group Photo' : 'Change Group Photo',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.electricBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),
              _buildInputField(
                label: 'Group Name',
                hint: 'P7 - Mathematics Parents',
                controller: _nameController,
              ),
              const SizedBox(height: AppSpacing.l),
              _buildInputField(
                label: 'Description (Optional)',
                hint:
                    'This group is for all P7 parents to discuss Mathematics updates and homework.',
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSettingTile(
                Icons.person_add_outlined,
                'Add Members',
                '${_members.length} selected',
                onTap: () => context.pop(),
              ),
              _buildSettingTile(
                Icons.public,
                'Group Type',
                _typeLabel,
                onTap: _pickType,
              ),
              _buildSettingTile(
                Icons.admin_panel_settings_outlined,
                'Who can send messages?',
                _policy == MessagePolicy.everyone
                    ? 'All Members'
                    : 'Admins Only',
                onTap: _pickPolicy,
              ),
              const SizedBox(height: AppSpacing.x3l),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canCreate ? () => _create(user) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.disabled(context),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _creating
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _createLabel,
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.x3l),
            ],
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
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
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
                  option == ChatType.group
                      ? 'Private Group'
                      : option == ChatType.broadcast
                      ? 'Broadcast List'
                      : 'Announcement Channel',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  option == ChatType.group
                      ? 'Everyone can see and reply to each other'
                      : option == ChatType.broadcast
                      ? 'One-way messages to many recipients'
                      : 'An announcement feed only admins post to',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                trailing: _type == option
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.electricBlue,
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
    );
  }

  void _pickPolicy() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in MessagePolicy.values)
              ListTile(
                title: Text(
                  option == MessagePolicy.everyone
                      ? 'All Members'
                      : 'Admins Only',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: _policy == option
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.electricBlue,
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

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.electricBlue),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title,
    String value, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
        title: Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.electricBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20, color: Colors.white24),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
