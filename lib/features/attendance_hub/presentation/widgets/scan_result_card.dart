import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

/// Matches the mockup's "Attendance Marked" card - big check circle, avatar,
/// name/class/time/status rows, then Mark Another / Done buttons.
class ScanResultCard extends StatelessWidget {
  final bool isDuplicate;
  final bool isInvalid;
  final String? photoUrl;
  final String name;
  final String subtitle;
  final String timeLabel;
  final String statusLabel;
  final VoidCallback onScanAnother;
  final VoidCallback onDone;

  const ScanResultCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.timeLabel,
    required this.statusLabel,
    required this.onScanAnother,
    required this.onDone,
    this.photoUrl,
    this.isDuplicate = false,
    this.isInvalid = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isInvalid
        ? AppColors.danger(context)
        : isDuplicate
        ? AppColors.warning(context)
        : AppColors.success(context);
    final title = isInvalid
        ? 'Invalid Card'
        : isDuplicate
        ? 'Already Marked'
        : 'Attendance Marked';

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              isInvalid
                  ? Icons.error_outline
                  : isDuplicate
                  ? Icons.info_outline
                  : Icons.check,
              color: color,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (!isInvalid)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: photoUrl != null
                          ? NetworkImage(photoUrl!)
                          : null,
                      child: photoUrl == null ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                timeLabel,
                                style: TextStyle(
                                  color: AppColors.textMuted(context),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.m),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.x3l),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onScanAnother,
              child: const Text('Mark Another'),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(onPressed: onDone, child: const Text('Done')),
          ),
        ],
      ),
    );
  }
}
