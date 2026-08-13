import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/branding/data/branding_local_cache.dart';
import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';
import 'package:school_pulse/features/branding/domain/usecases/get_school_branding.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_event.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_state.dart';

class MockBrandingLocalCache extends Mock implements BrandingLocalCache {}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockBrandingLocalCache localCache;
  late GetSchoolBranding getSchoolBranding;

  const schoolA = SchoolBranding(
    schoolId: 'school-a',
    schoolName: 'Academy A',
    schoolMotto: 'Knowledge for Life',
  );
  const schoolB = SchoolBranding(
    schoolId: 'school-b',
    schoolName: 'Academy B',
    schoolMotto: 'Excellence Every Day',
  );

  setUpAll(() {
    registerFallbackValue(schoolA);
  });

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    localCache = MockBrandingLocalCache();
    getSchoolBranding = GetSchoolBranding(firestore);
    await firestore.collection('schools').doc('school-a').set({
      'name': 'Academy A',
      'branding': {'motto': 'Knowledge for Life'},
    });
    await firestore.collection('schools').doc('school-b').set({
      'name': 'Academy B',
      'branding': {'motto': 'Excellence Every Day'},
    });
  });

  BrandingBloc buildBloc() => BrandingBloc(
    localCache: localCache,
    getSchoolBranding: getSchoolBranding,
  );

  group('InitializeBranding', () {
    blocTest<BrandingBloc, BrandingState>(
      'never paints a previous tenant at platform start, even with a warm cache',
      setUp: () =>
          when(() => localCache.get()).thenAnswer((_) async => schoolA),
      build: buildBloc,
      act: (bloc) => bloc.add(InitializeBranding()),
      expect: () => [isA<PlatformBranding>()],
    );
  });

  group('FetchBrandingForSchool', () {
    blocTest<BrandingBloc, BrandingState>(
      'loads and caches the requested school\'s branding',
      setUp: () {
        when(() => localCache.get()).thenAnswer((_) async => null);
        when(() => localCache.save(any())).thenAnswer((_) async {});
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const FetchBrandingForSchool('school-a')),
      expect: () => [
        isA<BrandingLoading>(),
        isA<BrandingLoaded>().having(
          (s) => s.branding?.schoolId,
          'schoolId',
          'school-a',
        ),
      ],
      verify: (_) {
        verify(() => localCache.save(any())).called(1);
      },
    );

    blocTest<BrandingBloc, BrandingState>(
      'a School A cache entry is never used to satisfy a School B fetch '
      '(cache contamination guard)',
      setUp: () {
        when(() => localCache.get()).thenAnswer((_) async => schoolA);
        when(() => localCache.save(any())).thenAnswer((_) async {});
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const FetchBrandingForSchool('school-b')),
      expect: () => [
        isA<BrandingLoading>(),
        isA<BrandingLoaded>().having(
          (s) => s.branding?.schoolId,
          'schoolId',
          'school-b',
        ),
      ],
    );

    blocTest<BrandingBloc, BrandingState>(
      'a network failure falls back to the tenant-matching cache entry only',
      setUp: () {
        when(() => localCache.get()).thenAnswer((_) async => schoolA);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const FetchBrandingForSchool('unknown-school')),
      expect: () => [isA<BrandingLoading>(), isA<BrandingError>()],
    );

    blocTest<BrandingBloc, BrandingState>(
      'a network failure with a matching cached tenant restores that cache '
      'as presentation data, not authorization',
      setUp: () {
        when(() => localCache.get()).thenAnswer((_) async => schoolB);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const FetchBrandingForSchool('unknown-school')),
      // The cache is keyed to school-b, so a fetch for a different
      // (unresolvable) school must not be satisfied by it.
      expect: () => [isA<BrandingLoading>(), isA<BrandingError>()],
    );

    blocTest<BrandingBloc, BrandingState>(
      'missing school document with no cache surfaces an error rather than '
      'a crash',
      setUp: () {
        when(() => localCache.get()).thenAnswer((_) async => null);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const FetchBrandingForSchool('does-not-exist')),
      expect: () => [isA<BrandingLoading>(), isA<BrandingError>()],
    );
  });

  group('ClearBranding', () {
    blocTest<BrandingBloc, BrandingState>(
      'logout clears the cache and resets to platform branding, not '
      'BrandingInitial or a stale BrandingLoaded',
      setUp: () => when(() => localCache.clear()).thenAnswer((_) async {}),
      build: buildBloc,
      seed: () => const BrandingLoaded(schoolA),
      act: (bloc) => bloc.add(ClearBranding()),
      expect: () => [isA<PlatformBranding>()],
      verify: (_) {
        verify(() => localCache.clear()).called(1);
      },
    );
  });
}
