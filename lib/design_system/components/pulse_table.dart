import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';

class PulseTableColumn<T> {
  final String title;
  final Widget Function(T) cellBuilder;
  final double? width;
  final bool isNumeric;

  PulseTableColumn({
    required this.title,
    required this.cellBuilder,
    this.width,
    this.isNumeric = false,
  });
}

class PulseTable<T> extends StatelessWidget {
  final List<T> items;
  final List<PulseTableColumn<T>> columns;
  final bool isLoading;
  final String emptyMessage;

  const PulseTable({
    super.key,
    required this.items,
    required this.columns,
    this.isLoading = false,
    this.emptyMessage = 'No data available',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.x4l),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x4l),
          child: Text(
            emptyMessage,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.medium,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            isDark ? AppColors.deepNavy.withValues(alpha: 0.5) : AppColors.bgLight,
          ),
          columnSpacing: AppSpacing.x3l,
          horizontalMargin: AppSpacing.xl,
          headingTextStyle: AppTypography.labelLarge.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontWeight: FontWeight.bold,
          ),
          dataTextStyle: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          columns: columns
              .map(
                (col) => DataColumn(
                  label: Text(col.title),
                  numeric: col.isNumeric,
                ),
              )
              .toList(),
          rows: items
              .map(
                (item) => DataRow(
                  cells: columns
                      .map(
                        (col) => DataCell(col.cellBuilder(item)),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
