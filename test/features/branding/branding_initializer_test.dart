import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/features/branding/data/branding_local_cache.dart';
import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';
import 'package:school_pulse/features/branding/domain/usecases/get_school_branding.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_event.dart';
import 'package:school_pulse/features/branding/presentation/screens/branding_initializer.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

class MockBrandingLocalCache extends Mock implements BrandingLocalCache {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const SchoolBranding(schoolId: 'x', schoolName: 'x', schoolMotto: ''),
    );
  });

  testWidgets(
    'clears ThemeProvider branding on logout so School A colours/title '
    'never survive into School Pulse auth or School B',
    (tester) async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('schools').doc('school-a').set({
        'name': 'Academy A',
        'branding': {'primaryColor': '#FF0000'},
      });
      final localCache = MockBrandingLocalCache();
      when(() => localCache.get()).thenAnswer((_) async => null);
      when(() => localCache.save(any())).thenAnswer((_) async {});
      when(() => localCache.clear()).thenAnswer((_) async {});

      final brandingBloc = BrandingBloc(
        localCache: localCache,
        getSchoolBranding: GetSchoolBranding(firestore),
      );
      final themeProvider = ThemeProvider();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [BlocProvider.value(value: brandingBloc)],
          child: ChangeNotifierProvider.value(
            value: themeProvider,
            child: BrandingInitializer(
              child: Builder(builder: (_) => const SizedBox.shrink()),
            ),
          ),
        ),
      );

      brandingBloc.add(const FetchBrandingForSchool('school-a'));
      await tester.pumpAndSettle();
      expect(themeProvider.branding?.schoolId, 'school-a');

      brandingBloc.add(ClearBranding());
      await tester.pumpAndSettle();
      expect(
        themeProvider.branding,
        isNull,
        reason:
            'logout must clear the previous school\'s branding from '
            'ThemeProvider, not just from BrandingBloc',
      );
    },
  );
}
