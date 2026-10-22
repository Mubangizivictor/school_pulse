import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_tokens.g.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/nurse/presentation/clinic_ui.dart';

/// The authenticated clinic navigation frame.
///
/// This is a router shell rather than a page switcher: every nurse URL is
/// rendered inside it, including records, visit forms and student profiles.
/// That keeps the clinic navigation available throughout the nurse module.
class NurseShell extends StatelessWidget {
  const NurseShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = _indexFor(path);
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = ClinicUi.foreground(context);
    final tokens = Theme.of(context).extension<AppColors>()!;
    final unselectedColor = isDark ? tokens.textMuted : ClinicUi.muted;
    final rail = NavigationRail(
      selectedIndex: index,
      onDestinationSelected: (value) => _goToDestination(context, value),
      labelType: NavigationRailLabelType.all,
      backgroundColor: ClinicUi.background(context),
      selectedIconTheme: IconThemeData(color: selectedColor),
      unselectedIconTheme: IconThemeData(color: unselectedColor),
      selectedLabelTextStyle: TextStyle(
        color: selectedColor,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: TextStyle(color: unselectedColor),
      destinations: List.generate(
        _labels.length,
        (i) => NavigationRailDestination(
          icon: Icon(_icons[i]),
          selectedIcon: Icon(_selected[i]),
          label: Text(_labels[i]),
        ),
      ),
    );
    return Scaffold(
      backgroundColor: ClinicUi.background(context),
      body: wide
          ? Row(
              children: [
                rail,
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            )
          : child,
      bottomNavigationBar: wide
          ? null
          : NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: ClinicUi.background(context),
                indicatorColor: isDark
                    ? tokens.text.withValues(alpha: 0.16)
                    : ClinicUi.black.withValues(alpha: 0.10),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  return IconThemeData(
                    color: states.contains(WidgetState.selected)
                        ? selectedColor
                        : unselectedColor,
                  );
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    color: selected ? selectedColor : unselectedColor,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  );
                }),
              ),
              child: NavigationBar(
                height: 76,
                selectedIndex: index,
                onDestinationSelected: (value) =>
                    _goToDestination(context, value),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: List.generate(
                  _labels.length,
                  (i) => NavigationDestination(
                    icon: Icon(_icons[i], size: 22),
                    selectedIcon: Icon(_selected[i], size: 22),
                    label: _labels[i],
                  ),
                ),
              ),
            ),
    );
  }

  static const _labels = ['Home', 'Visits', 'Students', 'Inventory', 'More'];
  static const _paths = [
    '/staff/nurse',
    '/staff/nurse/visits',
    '/staff/nurse/lookup',
    '/staff/nurse/inventory',
    '/staff/nurse/more',
  ];
  static const _icons = [
    Icons.home_outlined,
    Icons.calendar_today_outlined,
    Icons.groups_outlined,
    Icons.inventory_2_outlined,
    Icons.more_horiz,
  ];
  static const _selected = [
    Icons.home,
    Icons.calendar_today,
    Icons.groups,
    Icons.inventory_2,
    Icons.more_horiz,
  ];

  static int _indexFor(String path) {
    if (path == '/staff/nurse') return 0;
    if (path.startsWith('/staff/nurse/visits')) return 1;
    if (path.startsWith('/staff/nurse/lookup') ||
        path.startsWith('/staff/nurse/profile')) {
      return 2;
    }
    if (path.startsWith('/staff/nurse/inventory')) return 3;
    return 4;
  }

  static void _goToDestination(BuildContext context, int index) {
    context.go(_paths[index]);
  }
}
