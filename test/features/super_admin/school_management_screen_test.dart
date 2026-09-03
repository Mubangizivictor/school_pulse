import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/school_management_screen.dart';

void main() {
  testWidgets('Schools controls fit at 390px in light mode', (tester) async {
    await tester.pumpWidget(const _SchoolsControlsHarness());

    expect(find.text('Schools'), findsOneWidget);
    expect(find.text('Applications'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Schools controls retain readable dark-mode structure', (
    tester,
  ) async {
    await tester.pumpWidget(const _SchoolsControlsHarness(dark: true));

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Suspended'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Summary cards stack without overflow at 360px', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SchoolSummaryCards(
                activeCount: 18,
                applicationsCount: 4,
                suspendedCount: 2,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Active schools'), findsOneWidget);
    expect(find.text('Applications'), findsOneWidget);
    expect(find.text('Suspended'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _SchoolsControlsHarness extends StatefulWidget {
  const _SchoolsControlsHarness({this.dark = false});
  final bool dark;

  @override
  State<_SchoolsControlsHarness> createState() =>
      _SchoolsControlsHarnessState();
}

class _SchoolsControlsHarnessState extends State<_SchoolsControlsHarness>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  final _search = TextEditingController();

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      brightness: widget.dark ? Brightness.dark : Brightness.light,
    ),
    home: MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: Scaffold(
        body: Column(
          children: [
            PlatformSchoolsHeader(
              tabIndex: 0,
              activeCount: 128,
              applicationsCount: 7,
              suspendedCount: 3,
              onRefresh: () {},
              onCreate: () {},
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SchoolStatusTabs(
                controller: _tabs,
                activeCount: 128,
                applicationsCount: 7,
                suspendedCount: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SchoolSearchAndFilter(
                controller: _search,
                filter: SchoolFilter.all,
                tabIndex: 0,
                onChanged: (_) {},
                onFilterChanged: (_) {},
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
