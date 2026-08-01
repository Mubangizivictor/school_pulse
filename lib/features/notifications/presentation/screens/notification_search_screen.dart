import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/notification_category_config.dart';
import '../../domain/entities/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationSearchScreen extends StatefulWidget {
  const NotificationSearchScreen({super.key});

  @override
  State<NotificationSearchScreen> createState() => _NotificationSearchScreenState();
}

class _NotificationSearchScreenState extends State<NotificationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<NotificationItem> _searchResults = [];
  bool _isSearching = false;

  /// Debounces keystrokes so a query is not issued per character - each one is
  /// a billed read, and the intermediate results are never seen anyway.
  Timer? _debounce;

  /// Recent searches, newest first. Persisted per user so the list survives
  /// leaving the screen; previously these were five hardcoded strings.
  List<String> _recentSearches = [];

  static const _recentSearchesKey = 'notification_recent_searches';
  static const _maxRecentSearches = 8;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _recentSearches = prefs.getStringList(_recentSearchesKey) ?? const [];
    });
  }

  /// Records [term] as a recent search, most recent first and de-duplicated.
  Future<void> _rememberSearch(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;

    final updated = [
      trimmed,
      ..._recentSearches.where((s) => s.toLowerCase() != trimmed.toLowerCase()),
    ].take(_maxRecentSearches).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, updated);
    if (!mounted) return;
    setState(() => _recentSearches = updated);
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
    if (!mounted) return;
    setState(() => _recentSearches = const []);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _runSearch(query.trim()),
    );
  }

  Future<void> _runSearch(String query) async {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    if (user == null) {
      if (mounted) setState(() => _searchResults = []);
      return;
    }

    final result = await di.sl<NotificationRepository>().getNotifications(
          NotificationQuery(
            schoolId: user.schoolId,
            recipientUserId: user.id,
            searchTerm: query,
            // Search deliberately spans archived notifications: looking
            // something up is exactly when a user wants their whole history.
            includeArchived: true,
            limit: 50,
          ),
        );

    // The screen may have been popped while the query was in flight.
    if (!mounted) return;

    setState(() {
      _searchResults = result.fold((_) => const [], (page) => page.items);
    });

    // Recorded only after a query actually ran, so half-typed words do not
    // pile up in the recent list.
    unawaited(_rememberSearch(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          onChanged: _handleSearch,
          decoration: const InputDecoration(
            hintText: 'Search by title, sender, student...',
            hintStyle: TextStyle(color: Colors.white24),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white60),
              onPressed: () {
                _searchController.clear();
                _handleSearch('');
              },
            ),
        ],
      ),
      body: _isSearching ? _buildSearchResults() : _buildSearchSuggestions(),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.white24, size: 64),
            SizedBox(height: 16),
            Text('No results found', style: TextStyle(color: Colors.white60)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final notification = _searchResults[index];
        return _SearchTile(notification: notification);
      },
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Searches', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed:
                    _recentSearches.isEmpty ? null : _clearRecentSearches,
                child: Text(
                  'Clear all',
                  style: TextStyle(
                    color: _recentSearches.isEmpty
                        ? Colors.white24
                        : const Color(0xFF6366F1),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.isEmpty
                ? [
                    const Text(
                      'Your recent searches will appear here',
                      style: TextStyle(color: Colors.white30, fontSize: 12),
                    ),
                  ]
                : _recentSearches.map(_buildSearchChip).toList(),
          ),
          const SizedBox(height: 32),
          const Text('Popular Searches', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPopularSearch('Attendance'),
          _buildPopularSearch('Fee Payment'),
          _buildPopularSearch('Homework'),
          _buildPopularSearch('Transport'),
          _buildPopularSearch('Announcements'),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String label) {
    return InkWell(
      onTap: () {
        _searchController.text = label;
        _handleSearch(label);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ),
    );
  }

  Widget _buildPopularSearch(String label) {
    return InkWell(
      onTap: () {
        _searchController.text = label;
        _handleSearch(label);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.trending_up, color: Colors.white24, size: 20),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SearchTile extends StatelessWidget {
  final NotificationItem notification;

  const _SearchTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/staff/notifications/${notification.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(notification.category).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(_getCategoryIcon(notification.category), color: _getCategoryColor(notification.category), size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(notification.senderName, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  // Category treatment comes from the shared catalog so newly-added categories
  // pick up an icon and colour automatically. The values returned for the
  // original eight categories are unchanged.
  Color _getCategoryColor(NotificationCategory category) =>
      NotificationCategoryCatalog.of(category).color;

  IconData _getCategoryIcon(NotificationCategory category) =>
      NotificationCategoryCatalog.of(category).icon;
}
