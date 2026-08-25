import 'dart:async';

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/messaging_context.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kRecentSearchesKey = 'messages.recent_searches';

class SearchMessagesScreen extends StatefulWidget {
  const SearchMessagesScreen({super.key});

  @override
  State<SearchMessagesScreen> createState() => _SearchMessagesScreenState();
}

class _SearchMessagesScreenState extends State<SearchMessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  Timer? _debounce;

  List<ChatMessageRef> _results = const [];
  bool _searching = false;
  List<String> _recent = const [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(
      () => _recent = prefs.getStringList(_kRecentSearchesKey) ?? const [],
    );
  }

  Future<void> _rememberSearch(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = [term, ..._recent.where((r) => r != term)].take(8).toList();
    await prefs.setStringList(_kRecentSearchesKey, updated);
    if (!mounted) return;
    setState(() => _recent = updated);
  }

  Future<void> _clearRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRecentSearchesKey);
    if (!mounted) return;
    setState(() => _recent = const []);
  }

  /// Firestore charges per read, so wait for a pause in typing before firing.
  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _results = const []);
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _runSearch(value.trim()),
    );
  }

  Future<void> _runSearch(String term) async {
    final user = context.messagingUser;
    if (user == null) return;

    setState(() => _searching = true);
    try {
      final results = await context.messages.searchMessages(user.id, term);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searching = false;
      });
      await _rememberSearch(term);
    } catch (e) {
      if (!mounted) return;
      setState(() => _searching = false);
      context.showMessagingSnack('Search failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              hintText: 'Search messages...',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted(context),
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: AppColors.textMuted(context),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: _onQueryChanged,
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
              onPressed: () {
                _searchController.clear();
                _onQueryChanged('');
              },
            ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.electricBlue,
              unselectedLabelColor: AppColors.textMuted(context),
              indicatorColor: AppColors.electricBlue,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: AppTypography.titleSmall,
              dividerColor: isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
              tabs: const [
                Tab(text: 'Messages'),
                Tab(text: 'Media'),
                Tab(text: 'Links'),
                Tab(text: 'Docs'),
              ],
            ),
            Expanded(
              child: _query.isEmpty
                  ? _buildRecentSearches()
                  : TabBarView(
                      children: [
                        _buildResults(_results),
                        _buildResults(
                          _results
                              .where(
                                (r) =>
                                    r.message.type == MessageType.image ||
                                    r.message.type == MessageType.video,
                              )
                              .toList(),
                        ),
                        _buildResults(
                          _results
                              .where((r) => r.message.content.contains('http'))
                              .toList(),
                        ),
                        _buildResults(
                          _results
                              .where((r) => r.message.type == MessageType.file)
                              .toList(),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT SEARCHES',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
            if (_recent.isNotEmpty)
              TextButton(
                onPressed: _clearRecent,
                child: Text(
                  'Clear All',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.electricBlue,
                  ),
                ),
              ),
          ],
        ),
        if (_recent.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.m),
            child: Text(
              'Your recent searches will show up here.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
          )
        else
          ..._recent.map(_buildRecentItem),
      ],
    );
  }

  Widget _buildRecentItem(String text) {
    return ListTile(
      leading: Icon(Icons.history, color: AppColors.textMuted(context)),
      title: Text(text, style: AppTypography.bodyMedium),
      trailing: IconButton(
        icon: Icon(Icons.close, size: 16, color: AppColors.textMuted(context)),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          final updated = _recent.where((r) => r != text).toList();
          await prefs.setStringList(_kRecentSearchesKey, updated);
          if (!mounted) return;
          setState(() => _recent = updated);
        },
      ),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        _searchController.text = text;
        _onQueryChanged(text);
      },
    );
  }

  Widget _buildResults(List<ChatMessageRef> results) {
    if (_searching) return const Center(child: SchoolPulseLoader());
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'No matches for "$_query"',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.s),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final ref = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.royalBlue,
            child: Text(
              ref.message.senderName.isEmpty
                  ? '?'
                  : ref.message.senderName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  ref.message.senderName,
                  style: AppTypography.titleSmall,
                ),
              ),
              Text(
                DateFormat('dd/MM/yy').format(ref.message.timestamp),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.message.content.isEmpty
                      ? (ref.message.fileName ?? 'Attachment')
                      : ref.message.content,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'in ${ref.conversationTitle}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.electricBlue,
                  ),
                ),
              ],
            ),
          ),
          onTap: () => context.push('/messages/chat/${ref.conversationId}'),
        );
      },
    );
  }
}
