import 'package:flutter/material.dart';
import 'package:school_pulse/features/health/presentation/screens/nurse_clinic_visits_screen.dart';
import 'package:school_pulse/features/health/presentation/screens/nurse_home_screen.dart';
import 'package:school_pulse/features/health/presentation/screens/nurse_student_lookup_screen.dart';
import 'package:school_pulse/features/nurse/presentation/clinic_ui.dart';
import 'package:school_pulse/features/nurse/presentation/screens/medicine_inventory_screen.dart';
import 'package:school_pulse/features/nurse/presentation/screens/nurse_more_screen.dart';

/// Adaptive clinic shell. Mobile keeps the five persistent destinations from
/// the nurse workflow; wide layouts expose the same destinations in a rail.
class NurseShell extends StatefulWidget {
  const NurseShell({super.key});
  @override
  State<NurseShell> createState() => _NurseShellState();
}

class _NurseShellState extends State<NurseShell> {
  int _index = 0;
  final _pages = const [
    NurseHomeScreen(),
    NurseClinicVisitsScreen(),
    NurseStudentLookupScreen(),
    MedicineInventoryScreen(),
    NurseMoreScreen(),
  ];
  static const _labels = ['Home', 'Visits', 'Students', 'Inventory', 'More'];
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

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = ClinicUi.foreground(context);
    final unselectedColor = isDark ? Colors.white70 : ClinicUi.muted;
    final rail = NavigationRail(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
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
                Expanded(child: _pages[_index]),
              ],
            )
          : _pages[_index],
      bottomNavigationBar: wide
          ? null
          : NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: ClinicUi.background(context),
                // A transparent indicator plus a fixed black selected icon
                // made the active Home tab disappear in dark mode.
                indicatorColor: isDark
                    ? Colors.white.withValues(alpha: 0.16)
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
                selectedIndex: _index,
                onDestinationSelected: (value) =>
                    setState(() => _index = value),
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
}
