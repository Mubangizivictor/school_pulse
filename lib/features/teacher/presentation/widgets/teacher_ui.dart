// Shared, theme-aware presentation primitives for both teacher experiences.
// Teacher screens should use these rather than carrying their own light/dark
// palette. Every colour below comes from the active School Pulse ThemeData,
// which also means a school's branding overrides are respected.
import 'package:flutter/material.dart';

class TeacherScaffold extends StatelessWidget {
  const TeacherScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    body: SafeArea(top: false, child: body),
    bottomNavigationBar: bottomNavigationBar,
    floatingActionButton: floatingActionButton,
  );
}

class TeacherHeader extends StatelessWidget implements PreferredSizeWidget {
  const TeacherHeader({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) =>
      AppBar(title: Text(title), leading: leading, actions: actions);
}

class TeacherResponsiveContainer extends StatelessWidget {
  const TeacherResponsiveContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.maxWidth = 1120,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

class TeacherSectionHeader extends StatelessWidget {
  const TeacherSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (actionLabel != null)
        TextButton(onPressed: onAction, child: Text(actionLabel!)),
    ],
  );
}

class TeacherSectionCard extends StatelessWidget {
  const TeacherSectionCard({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
  );
}

class TeacherStatsCard extends StatelessWidget {
  const TeacherStatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;
    return TeacherSectionCard(
      child: Row(
        children: [
          Icon(icon, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherActionCard extends StatelessWidget {
  const TeacherActionCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => TeacherSectionCard(
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}

class TeacherStatusChip extends StatelessWidget {
  const TeacherStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: icon == null ? null : Icon(icon, size: 16, color: color),
    label: Text(label),
    side: BorderSide(color: color.withValues(alpha: .45)),
    backgroundColor: color.withValues(alpha: .12),
    labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
  );
}

class TeacherSearchField extends StatelessWidget {
  const TeacherSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Search',
  });
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: const Icon(Icons.search),
    ),
  );
}

class TeacherEmptyState extends StatelessWidget {
  const TeacherEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 44,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}

class TeacherLoadingState extends StatelessWidget {
  const TeacherLoadingState({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class TeacherErrorState extends StatelessWidget {
  const TeacherErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => TeacherEmptyState(
    icon: Icons.cloud_off_outlined,
    title: 'Unable to load',
    message: message,
    action: onRetry == null
        ? null
        : FilledButton(onPressed: onRetry, child: const Text('Retry')),
  );
}

class TeacherBottomNavigation extends StatelessWidget {
  const TeacherBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });
  final int selectedIndex;
  final List<NavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: NavigationBar(
      selectedIndex: selectedIndex,
      destinations: destinations,
      onDestinationSelected: onDestinationSelected,
    ),
  );
}

// Names retained as shared extension points for common teacher flows.
typedef TeacherStudentCard = TeacherActionCard;
typedef TeacherStudentList = ListView;
typedef TeacherFilterBar = Wrap;
typedef TeacherAttendanceSummary = TeacherSectionCard;
typedef TeacherManualAttendanceList = ListView;
typedef TeacherMarksCard = TeacherSectionCard;
typedef TeacherAssessmentCard = TeacherSectionCard;
typedef TeacherResourceCard = TeacherActionCard;
typedef TeacherListTile = ListTile;
typedef TeacherDialog = AlertDialog;
typedef TeacherBottomSheet = BottomSheet;
