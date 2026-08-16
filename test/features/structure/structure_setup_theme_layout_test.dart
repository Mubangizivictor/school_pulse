import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/screens/structure_screen.dart';

class _MockStructureBloc extends MockBloc<StructureEvent, StructureState>
    implements StructureBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sections = <String>[
    'overview',
    'institution',
    'academic',
    'people',
    'operations',
    'campus-life',
    'communication',
    'finance',
    'security',
  ];

  Future<void> pumpSetup(
    WidgetTester tester, {
    required ThemeData theme,
    required String section,
  }) async {
    final bloc = _MockStructureBloc();
    when(() => bloc.state).thenReturn(const StructureState());
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: BlocProvider<StructureBloc>.value(
          value: bloc,
          child: StructureScreen(initialSection: section),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final entry in <({String name, ThemeData theme})>[
    (name: 'light', theme: _theme(Brightness.light)),
    (name: 'dark', theme: _theme(Brightness.dark)),
  ]) {
    testWidgets(
      'Structure Setup renders every section without overflow in ${entry.name} mode',
      (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        for (final section in sections) {
          await pumpSetup(tester, theme: entry.theme, section: section);
          expect(tester.takeException(), isNull, reason: 'section: $section');
          expect(find.text('Structure Setup'), findsAtLeastNWidgets(1));
        }
      },
    );
  }
}

ThemeData _theme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: dark ? AppColors.electricBlue : AppColors.royalBlue,
    brightness: brightness,
    surface: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
    onSurface: dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    onSurfaceVariant: dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight,
    outline: dark ? AppColors.borderDark : AppColors.borderLight,
    outlineVariant: dark ? AppColors.borderDark : AppColors.borderLight,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? AppColors.bgDark : AppColors.bgLight,
  );
}
