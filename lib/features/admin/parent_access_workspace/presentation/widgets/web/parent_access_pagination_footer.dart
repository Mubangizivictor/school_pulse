import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

/// Desktop table pagination footer: "Showing X to Y of Z parents", a page
/// size dropdown, and prev/page-number/next controls - matches the
/// reference screenshot's footer under the parents table. Backed by the
/// cubit's already-loaded row count and cursor-based "has more" flag rather
/// than a full random-access page index, since the underlying data source
/// is cursor-paginated (Cloud Function callable), not offset-paginated.
class ParentAccessPaginationFooter extends StatelessWidget {
  final int shownCount;
  final int totalCount;
  final int pageSize;
  final bool hasNextPage;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;

  const ParentAccessPaginationFooter({
    super.key,
    required this.shownCount,
    required this.totalCount,
    required this.pageSize,
    required this.hasNextPage,
    required this.isLoadingMore,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            'Showing 1 to $shownCount of $totalCount parents',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$pageSize per page',
              style: TextStyle(fontSize: 12, color: AppColors.textPrimary(context)),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 18),
            onPressed: null,
            tooltip: 'Previous page',
          ),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary(context),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '1',
              style: TextStyle(color: AppColors.background(context), fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            icon: isLoadingMore
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right, size: 18),
            onPressed: hasNextPage ? onLoadMore : null,
            tooltip: 'Next page',
          ),
        ],
      ),
    );
  }
}
