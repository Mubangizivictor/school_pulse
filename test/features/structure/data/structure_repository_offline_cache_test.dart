import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/structure/data/datasources/structure_local_data_source.dart';
import 'package:school_pulse/features/structure/data/datasources/structure_remote_data_source.dart';
import 'package:school_pulse/features/structure/data/repositories/structure_repository_impl.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';

class MockStructureRemoteDataSource extends Mock
    implements StructureRemoteDataSource {}

class MockStructureLocalDataSource extends Mock
    implements StructureLocalDataSource {}

EducationalLevel _level(String id) =>
    EducationalLevel(id: id, schoolId: 'school-1', name: 'Level $id');

void main() {
  late MockStructureRemoteDataSource remote;
  late MockStructureLocalDataSource local;
  late StructureRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(<EducationalLevel>[]);
  });

  setUp(() {
    remote = MockStructureRemoteDataSource();
    local = MockStructureLocalDataSource();
    repository = StructureRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
    );
    when(() => local.cacheLevels(any())).thenAnswer((_) async {});
  });

  test(
    'emits the cached copy first when one exists, before the live stream catches up',
    () async {
      when(() => local.getLevels()).thenAnswer((_) async => [_level('cached')]);
      final controller = StreamController<List<EducationalLevel>>();
      when(
        () => remote.watchLevels('school-1'),
      ).thenAnswer((_) => controller.stream);

      final emissions = <List<EducationalLevel>>[];
      final sub = repository.watchLevels('school-1').listen(emissions.add);

      // Cache read is async; give it a turn before the live stream fires.
      await Future.delayed(const Duration(milliseconds: 10));
      expect(emissions, [
        [_level('cached')],
      ]);

      controller.add([_level('live')]);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(emissions.last, [_level('live')]);
      verify(() => local.cacheLevels([_level('live')])).called(1);

      // Close before cancel: cancelling an async* generator's subscription
      // while it's still blocked in `await for` on an open, silent
      // StreamController never resolves - closing first lets the generator
      // body reach its own natural end.
      await controller.close();
      await sub.cancel();
    },
  );

  test(
    'emits nothing extra when the cache is empty - just the live stream',
    () async {
      when(() => local.getLevels()).thenAnswer((_) async => []);
      final controller = StreamController<List<EducationalLevel>>();
      when(
        () => remote.watchLevels('school-1'),
      ).thenAnswer((_) => controller.stream);

      final emissions = <List<EducationalLevel>>[];
      final sub = repository.watchLevels('school-1').listen(emissions.add);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(emissions, isEmpty);

      controller.add([_level('live')]);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(emissions, [
        [_level('live')],
      ]);

      // Close before cancel: cancelling an async* generator's subscription
      // while it's still blocked in `await for` on an open, silent
      // StreamController never resolves - closing first lets the generator
      // body reach its own natural end.
      await controller.close();
      await sub.cancel();
    },
  );

  test('caches every live emission, same as before this change', () async {
    when(() => local.getLevels()).thenAnswer((_) async => []);
    final controller = StreamController<List<EducationalLevel>>();
    when(
      () => remote.watchLevels('school-1'),
    ).thenAnswer((_) => controller.stream);

    final sub = repository.watchLevels('school-1').listen((_) {});

    controller.add([_level('a')]);
    controller.add([_level('b')]);
    await Future.delayed(const Duration(milliseconds: 10));

    verify(() => local.cacheLevels([_level('a')])).called(1);
    verify(() => local.cacheLevels([_level('b')])).called(1);

    await controller.close();
    await sub.cancel();
  });
}
