import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_pulse/features/institution/domain/entities/institution_context.dart';
import 'package:school_pulse/features/institution/domain/repositories/institution_context_repository.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_cubit.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_state.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';

class _MockRepository extends Mock implements InstitutionContextRepository {}

InstitutionContext _context({
  String institutionId = 'school-1',
  SchoolStatus status = SchoolStatus.active,
  bool isOfflineCached = false,
}) {
  return InstitutionContext(
    institutionId: institutionId,
    displayLabel: 'Test Institution',
    classification: InstitutionClassification.primary,
    divisions: const [],
    status: status,
    enabledFeatures: const [],
    loadedAt: DateTime(2026, 1, 1),
    isOfflineCached: isOfflineCached,
  );
}

void main() {
  late _MockRepository repository;
  late SharedPreferences preferences;

  setUp(() async {
    repository = _MockRepository();
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  group('InstitutionContextCubit', () {
    blocTest<InstitutionContextCubit, InstitutionContextState>(
      'emits Loading then Loaded for an active institution',
      build: () {
        when(
          () => repository.watchContext('school-1'),
        ).thenAnswer((_) => Stream.value(_context()));
        return InstitutionContextCubit(
          repository: repository,
          preferences: preferences,
        );
      },
      act: (cubit) => cubit.loadInstitution('school-1'),
      expect: () => [
        const InstitutionContextLoading(),
        isA<InstitutionContextLoaded>(),
      ],
    );

    blocTest<InstitutionContextCubit, InstitutionContextState>(
      'emits Suspended when institution status is suspended',
      build: () {
        when(() => repository.watchContext('school-1')).thenAnswer(
          (_) => Stream.value(_context(status: SchoolStatus.suspended)),
        );
        return InstitutionContextCubit(
          repository: repository,
          preferences: preferences,
        );
      },
      act: (cubit) => cubit.loadInstitution('school-1'),
      expect: () => [
        const InstitutionContextLoading(),
        isA<InstitutionContextSuspended>(),
      ],
    );

    blocTest<InstitutionContextCubit, InstitutionContextState>(
      'emits Suspended when institution status is archived',
      build: () {
        when(() => repository.watchContext('school-1')).thenAnswer(
          (_) => Stream.value(_context(status: SchoolStatus.archived)),
        );
        return InstitutionContextCubit(
          repository: repository,
          preferences: preferences,
        );
      },
      act: (cubit) => cubit.loadInstitution('school-1'),
      expect: () => [
        const InstitutionContextLoading(),
        isA<InstitutionContextSuspended>(),
      ],
    );

    blocTest<InstitutionContextCubit, InstitutionContextState>(
      'emits Error when the context stream errors',
      build: () {
        when(
          () => repository.watchContext('school-1'),
        ).thenAnswer((_) => Stream.error('network down'));
        return InstitutionContextCubit(
          repository: repository,
          preferences: preferences,
        );
      },
      act: (cubit) => cubit.loadInstitution('school-1'),
      expect: () => [
        const InstitutionContextLoading(),
        isA<InstitutionContextError>(),
      ],
    );

    test(
      'offline-cached context surfaces isOfflineCached on the loaded context',
      () async {
        when(
          () => repository.watchContext('school-1'),
        ).thenAnswer((_) => Stream.value(_context(isOfflineCached: true)));
        final cubit = InstitutionContextCubit(
          repository: repository,
          preferences: preferences,
        );

        await cubit.loadInstitution('school-1');
        await Future<void>.delayed(Duration.zero);

        final state = cubit.state;
        expect(state, isA<InstitutionContextLoaded>());
        expect(
          (state as InstitutionContextLoaded).context.isOfflineCached,
          isTrue,
        );
      },
    );

    test(
      'loadInstitution persists the selection for session restoration',
      () async {
        when(
          () => repository.watchContext('school-1'),
        ).thenAnswer((_) => Stream.value(_context()));
        final cubit = InstitutionContextCubit(
          repository: repository,
          preferences: preferences,
        );

        await cubit.loadInstitution('school-1');

        expect(
          preferences.getString('institution_context.current_institution_id'),
          'school-1',
        );
        expect(cubit.currentInstitutionId, 'school-1');
      },
    );

    test(
      'restore falls back to home institution when nothing was previously selected',
      () async {
        when(() => repository.watchContext('home-school')).thenAnswer(
          (_) => Stream.value(_context(institutionId: 'home-school')),
        );
        final cubit = InstitutionContextCubit(
          repository: repository,
          preferences: preferences,
        );

        await cubit.restore('home-school');

        expect(cubit.currentInstitutionId, 'home-school');
      },
    );

    test(
      'restore prefers a previously switched-to institution over home',
      () async {
        await preferences.setString(
          'institution_context.current_institution_id',
          'other-school',
        );
        when(() => repository.watchContext('other-school')).thenAnswer(
          (_) => Stream.value(_context(institutionId: 'other-school')),
        );
        final cubit = InstitutionContextCubit(
          repository: repository,
          preferences: preferences,
        );

        await cubit.restore('home-school');

        expect(cubit.currentInstitutionId, 'other-school');
      },
    );

    blocTest<InstitutionContextCubit, InstitutionContextState>(
      'clear resets to Initial and drops the persisted institution',
      build: () {
        when(
          () => repository.watchContext('school-1'),
        ).thenAnswer((_) => Stream.value(_context()));
        return InstitutionContextCubit(
          repository: repository,
          preferences: preferences,
        );
      },
      act: (cubit) async {
        await cubit.loadInstitution('school-1');
        await Future<void>.delayed(Duration.zero);
        cubit.clear();
      },
      expect: () => [
        const InstitutionContextLoading(),
        isA<InstitutionContextLoaded>(),
        const InstitutionContextInitial(),
      ],
      verify: (_) {
        expect(
          preferences.getString('institution_context.current_institution_id'),
          isNull,
        );
      },
    );
  });
}
