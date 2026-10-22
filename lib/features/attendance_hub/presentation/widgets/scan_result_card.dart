import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

/// Compact attendance result preview used after QR/NFC resolution.
/// Attendance scanning is continuous by default: show the student briefly,
/// then let the screen re-arm the NFC reader automatically.
class ScanResultCard extends StatefulWidget {
  final bool isDuplicate;
  final bool isInvalid;
  final bool autoContinue;
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
    this.autoContinue = true,
  });

  @override
  State<ScanResultCard> createState() => _ScanResultCardState();
}

class _ScanResultCardState extends State<ScanResultCard> {
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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                widget.isInvalid
                    ? Icons.error_outline
                    : widget.isDuplicate
                    ? Icons.info_outline
                    : Icons.check_rounded,
                color: color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            if (!widget.isInvalid)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundImage: showPhoto
                            ? NetworkImage(photoUrl)
                            : null,
                        onBackgroundImageError: showPhoto
                            ? (_, _) {
                                if (mounted) {
                                  setState(() => _photoFailed = true);
                                }
                              }
                            : null,
                        child: showPhoto
                            ? null
                            : const Icon(Icons.person, size: 38),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        widget.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted(context),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.timeLabel.isNotEmpty) ...[
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: AppColors.textMuted(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.timeLabel,
                              style: TextStyle(
                                color: AppColors.textMuted(context),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.l),
                          ],
                          Icon(Icons.check_circle, size: 17, color: color),
                          const SizedBox(width: 4),
                          Text(
                            widget.statusLabel,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.l),
            if (widget.autoContinue)
              Column(
                children: [
                  SizedBox(
                    width: 180,
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    'Ready for the next student…',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.onScanAnother,
                  child: const Text('Scan Another'),
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
          ],
        ),
      ),
    );
  }
}
