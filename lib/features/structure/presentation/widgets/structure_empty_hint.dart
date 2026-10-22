import 'package:flutter/material.dart';

/// Shared "nothing here yet" placeholder used across every Structure tab -
/// matches the icon+title+subtitle EmptyState pattern used by the
/// redesigned Enrollment Setup wizard, so every "No X yet" screen across
/// both wizards reads as one visual system.
class StructureEmptyHint extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? title;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  const StructureEmptyHint(
    this.message, {
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title,
    this.ctaLabel,
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onCtaPressed,
                icon: const Icon(Icons.add),
                label: Text(ctaLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
