import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class SearchMessagesScreen extends StatefulWidget {
  const SearchMessagesScreen({super.key});

  @override
  State<SearchMessagesScreen> createState() => _SearchMessagesScreenState();
}

class _SearchMessagesScreenState extends State<SearchMessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

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
            color: isDark ? AppColors.surfaceDark : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary(context)),
            decoration: InputDecoration(
              hintText: 'Search messages...',
              hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted(context)),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textMuted(context)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
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
              dividerColor: isDark ? AppColors.borderDark : AppColors.borderLight,
              tabs: const [
                Tab(text: 'Messages'),
                Tab(text: 'Media'),
                Tab(text: 'Links'),
                Tab(text: 'Docs'),
              ],
            ),
            Expanded(
              child: _query.isEmpty ? _buildRecentSearches() : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RECENT SEARCHES', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
            TextButton(
              onPressed: () {},
              child: Text('Clear All', style: AppTypography.labelSmall.copyWith(color: AppColors.electricBlue)),
            ),
          ],
        ),
        _buildRecentItem('PTA meeting notes'),
        _buildRecentItem('Science homework'),
        _buildRecentItem('Holiday schedule'),
      ],
    );
  }

  Widget _buildRecentItem(String text) {
    return ListTile(
      leading: Icon(Icons.history, color: AppColors.textMuted(context)),
      title: Text(text, style: AppTypography.bodyMedium),
      trailing: Icon(Icons.close, size: 16, color: AppColors.textMuted(context)),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        _searchController.text = text;
        setState(() => _query = text);
      },
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.s),
      itemCount: 3,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.royalBlue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Row(
            children: [
              Expanded(child: Text('Mr. Kofi Mensah', style: AppTypography.titleSmall)),
              Text('10/05/24', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Please find the homework attached for Chapter 4...',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          onTap: () {},
        );
      },
    );
  }
}
