import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/bloc/messaging_bloc.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';

/// Carries the picked members from [SelectContactsScreen] to
/// [NewGroupDetailsScreen] via GoRouter's `extra`.
class NewConversationDraft {
  final ChatType type;
  final List<MessageContact> members;

  const NewConversationDraft({required this.type, required this.members});
}

class SelectContactsScreen extends StatefulWidget {
  /// True for anything with more than two people - group, broadcast list or
  /// channel. False starts a 1:1 chat straight away.
  final bool isGroupSelection;

  /// Which kind of multi-person conversation is being created.
  final ChatType conversationType;

  const SelectContactsScreen({
    super.key,
    this.isGroupSelection = false,
    this.conversationType = ChatType.group,
  });

  @override
  State<SelectContactsScreen> createState() => _SelectContactsScreenState();
}

class _SelectContactsScreenState extends State<SelectContactsScreen> {
  final List<String> _selectedIds = [];
  final TextEditingController _searchController = TextEditingController();

  List<MessageContact> _contacts = [];
  List<MessageContact> _recent = [];
  bool _loading = true;
  bool _searching = false;
  String _query = '';
  String? _error;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = context.messagingUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'You are signed out.';
      });
      return;
    }
    try {
      final repository = context.messages;
      final contacts = await repository.getContacts(
        user.schoolId,
        excludeId: user.id,
      );
      final recent = await repository.getRecentContacts(user.id, limit: 3);
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _recent = recent;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  List<MessageContact> get _filtered {
    if (_query.isEmpty) return _contacts;
    final term = _query.toLowerCase();
    return _contacts
        .where(
          (c) =>
              c.name.toLowerCase().contains(term) ||
              _roleLabel(c.role).toLowerCase().contains(term),
        )
        .toList();
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
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  hintStyle: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _query = value),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_titleForType(), style: AppTypography.titleLarge),
                  Text(
                    '${_selectedIds.length} of ${_contacts.length} selected',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(
              _searching ? Icons.close : Icons.search,
              color: AppColors.textPrimary(context),
            ),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) {
                _searchController.clear();
                _query = '';
              }
            }),
          ),
        ],
      ),
      bottomNavigationBar: MessagingUserBuilder(
        builder: (context, user) => _buildActionBar(context, user),
      ),
      body: MessagingUserBuilder(
        builder: (context, user) => Column(
          children: [
            if (widget.isGroupSelection && _selectedIds.isNotEmpty) ...[
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  border: Border(
                    bottom: BorderSide(color: colors.outlineVariant),
                  ),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  itemCount: _selectedIds.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts.firstWhere(
                      (c) => c.id == _selectedIds[index],
                    );
                    return SizedBox(
                      width: 70,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.electricBlue,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: AppColors.electricBlue,
                                  child: Text(
                                    contact.initials,
                                    style: const TextStyle(
                                      color: AppColors.electricBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedIds.remove(contact.id),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contact.name.split(' ').first,
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, UserEntity user) {
    // With no contacts, a disabled CTA adds noise and sits against the iOS
    // gesture area. The empty state offers refresh instead.
    if (_loading || (_contacts.isEmpty && _selectedIds.isEmpty)) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;
    final enabled = _selectedIds.isNotEmpty && !_creating;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
        AppSpacing.m,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.m),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: enabled ? () => _continue(user) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                disabledBackgroundColor: colors.surfaceContainerHigh,
                disabledForegroundColor: colors.onSurfaceVariant,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: _creating
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isGroupSelection
                              ? Icons.arrow_forward_rounded
                              : Icons.chat_bubble_rounded,
                          size: 19,
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Text(
                          widget.isGroupSelection ? 'Continue' : 'Start chat',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: SchoolPulseLoader());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'Could not load contacts.\n$_error',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
        ),
      );
    }
    if (_contacts.isEmpty) {
      return _buildEmptyContactsState();
    }

    final filtered = _filtered;
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No contacts match "$_query"',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textMuted(context),
          ),
        ),
      );
    }

    // Only worth splitting the list when nothing is being searched for.
    final recentIds = _recent.map((c) => c.id).toSet();
    final showSections = _query.isEmpty && _recent.isNotEmpty;
    final rest = showSections
        ? filtered.where((c) => !recentIds.contains(c.id))
        : filtered;

    return ListView(
      children: [
        if (showSections) ...[
          _buildSectionHeader('FREQUENTLY CONTACTED'),
          ..._recent.map(_buildContactTile),
        ],
        _buildSectionHeader(showSections ? 'ALL CONTACTS' : 'CONTACTS'),
        ...rest.map(_buildContactTile),
      ],
    );
  }

  Widget _buildEmptyContactsState() {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Icon(
                widget.isGroupSelection
                    ? Icons.group_add_outlined
                    : Icons.person_search_outlined,
                size: 46,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No contacts yet',
              style: AppTypography.titleLarge.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'No one else in your school has an account yet. Once they join, they will appear here automatically.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh contacts'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continue(UserEntity user) async {
    final selected = _selectedIds
        .map(
          (id) => _contacts.firstWhere(
            (c) => c.id == id,
            orElse: () => _recent.firstWhere((c) => c.id == id),
          ),
        )
        .toList();

    if (widget.isGroupSelection) {
      context.push(
        '/messages/new/group/details',
        extra: NewConversationDraft(
          type: widget.conversationType,
          members: selected,
        ),
      );
      return;
    }

    setState(() => _creating = true);
    final result = await context.dispatchMessagingAction(
      DirectConversationRequested(selected.first),
    );
    if (!mounted) return;

    if (result.actionStatus == MessagingActionStatus.success &&
        result.createdConversationId != null) {
      context.pushReplacement('/messages/chat/${result.createdConversationId}');
    } else {
      setState(() => _creating = false);
      context.showMessagingSnack(
        result.lastDecision?.message ??
            'Could not start the chat: ${result.lastActionError}',
      );
    }
  }

  String _titleForType() {
    if (!widget.isGroupSelection) return 'New Chat';
    switch (widget.conversationType) {
      case ChatType.broadcast:
        return 'Select Recipients';
      case ChatType.channel:
        return 'Add Subscribers';
      default:
        return 'Add Members';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.s,
      ),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textMuted(context),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildContactTile(MessageContact contact) {
    final isSelected = _selectedIds.contains(contact.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 4),
      child: Material(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? const BorderSide(color: AppColors.electricBlue)
              : BorderSide.none,
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.electricBlue,
            child: Text(
              contact.initials,
              style: const TextStyle(
                color: AppColors.electricBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            contact.name,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            _roleLabel(contact.role),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.electricBlue : Colors.black,
                width: 2,
              ),
              color: isSelected ? AppColors.electricBlue : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(contact.id);
              } else {
                if (!widget.isGroupSelection) {
                  _selectedIds.clear();
                }
                _selectedIds.add(contact.id);
              }
            });
          },
        ),
      ),
    );
  }
}

/// `school_contacts` stores the raw enum name ('classTeacher'); the UI wants
/// 'Class Teacher'.
String _roleLabel(String roleName) {
  final role = UserRole.values.where((r) => r.name == roleName);
  return role.isEmpty ? roleName : UserRoleDisplay.name(role.first);
}
