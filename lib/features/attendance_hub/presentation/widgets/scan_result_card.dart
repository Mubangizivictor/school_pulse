import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

/// Matches the mockup's "Attendance Marked" card - big check circle, avatar,
/// name/class/time/status rows, then Mark Another / Done buttons.
class ScanResultCard extends StatefulWidget {
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
  State<ScanResultCard> createState() => _ScanResultCardState();
}

class _ScanResultCardState extends State<ScanResultCard> {
  // A cached photoUrl points at Firebase Storage - while offline (the
  // expected state during QR/NFC attendance per the offline-first spec),
  // NetworkImage fails to load but CircleAvatar's `child` is only shown when
  // `backgroundImage` is null, so without this the avatar would render
  // blank instead of falling back to the person icon.
  bool _photoFailed = false;

  @override
  void didUpdateWidget(covariant ScanResultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoUrl != widget.photoUrl) _photoFailed = false;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isInvalid
        ? AppColors.danger(context)
        : widget.isDuplicate
        ? AppColors.warning(context)
        : AppColors.success(context);
    final title = widget.isInvalid
        ? 'Invalid Card'
        : widget.isDuplicate
        ? 'Already Marked'
        : 'Attendance Marked';
    final photoUrl = widget.photoUrl;
    final showPhoto = photoUrl != null && !_photoFailed;

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
              widget.isInvalid
                  ? Icons.error_outline
                  : widget.isDuplicate
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
          if (!widget.isInvalid)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: showPhoto
                          ? NetworkImage(photoUrl)
                          : null,
                      onBackgroundImageError: showPhoto
                          ? (_, _) {
                              // Offline device, no local cache of this
                              // photo, or a bad URL - never leave the
                              // avatar blank, fall back to the icon.
                              if (mounted) {
                                setState(() => _photoFailed = true);
                              }
                            }
                          : null,
                      child: showPhoto ? null : const Icon(Icons.person),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                widget.timeLabel,
                                style: TextStyle(
                                  color: AppColors.textMuted(context),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.m),
                              Text(
                                widget.statusLabel,
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
              onPressed: widget.onScanAnother,
              child: const Text('Mark Another'),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onDone,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
