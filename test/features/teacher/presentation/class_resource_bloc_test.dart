import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_resource_repository.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';

class _MockRepository extends Mock implements ClassResourceRepository {}

class _FakeContext extends Fake implements ActiveResponsibilityContext {}

class _FakeResource extends Fake implements ClassResource {}

void main() {
  late _MockRepository repository;

  final assignment = StaffRoleAssignment(
    id: 'a1',
    schoolId: 'school1',
    staffId: 'staff1',
    userId: 'user1',
    roleType: StaffResponsibilityType.classTeacher,
    academicYearId: '2026',
    classId: 'p5',
    className: 'P5',
    startDate: DateTime(2026, 1, 1),
    assignedAt: DateTime(2026, 1, 1),
  );

  final context = ActiveResponsibilityContext.fromAssignment(
    assignment,
    termId: 't2',
    termName: 'Term 2',
  );

  final resource = ClassResource(
    id: 'r1',
    schoolId: 'school1',
    classId: 'p5',
    academicYearId: '2026',
    name: 'Notes.pdf',
    uploadedAt: DateTime(2026, 1, 5),
  );

  setUpAll(() {
    registerFallbackValue(ClassResourceAudience.teacherOnly);
    registerFallbackValue(_FakeContext());
    registerFallbackValue(_FakeResource());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    repository = _MockRepository();
    // Shared by every _onRequested call the bloc issues after a mutation.
    when(
      () => repository.getResources(
        context: any(named: 'context'),
        folderId: any(named: 'folderId'),
      ),
    ).thenAnswer((_) async => const Right([]));
    when(
      () => repository.getStorageUsage(context: any(named: 'context')),
    ).thenAnswer((_) async => const Right(StorageUsage()));
  });

  tearDown(resetMocktailState);

  group('ClassResourcesRequested', () {
    blocTest<ClassResourceBloc, ClassResourceState>(
      'loads resources and storage usage on request',
      setUp: () {
        when(
          () => repository.getResources(
            context: any(named: 'context'),
            folderId: any(named: 'folderId'),
          ),
        ).thenAnswer((_) async => Right([resource]));
        when(
          () => repository.getStorageUsage(context: any(named: 'context')),
        ).thenAnswer(
          (_) async => const Right(
            StorageUsage(usedBytes: 100, quotaBytes: 1000, fileCount: 1),
          ),
        );
      },
      build: () => ClassResourceBloc(repository: repository),
      act: (bloc) => bloc.add(ClassResourcesRequested(context)),
      expect: () => [
        isA<ClassResourceState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ClassResourceState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.resources, 'resources', [resource])
            .having((s) => s.storageUsage.usedBytes, 'usedBytes', 100),
      ],
    );

    blocTest<ClassResourceBloc, ClassResourceState>(
      'surfaces a permission failure without crashing',
      setUp: () {
        when(
          () => repository.getResources(
            context: any(named: 'context'),
            folderId: any(named: 'folderId'),
          ),
        ).thenAnswer(
          (_) async => const Left(PermissionDeniedFailure('Not allowed')),
        );
        when(
          () => repository.getStorageUsage(context: any(named: 'context')),
        ).thenAnswer((_) async => const Right(StorageUsage()));
      },
      build: () => ClassResourceBloc(repository: repository),
      act: (bloc) => bloc.add(ClassResourcesRequested(context)),
      expect: () => [
        isA<ClassResourceState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ClassResourceState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'errorMessage', 'Not allowed'),
      ],
    );
  });

  group('ClassResourceUploaded', () {
    blocTest<ClassResourceBloc, ClassResourceState>(
      'uploads then reloads the resource list',
      setUp: () {
        when(
          () => repository.uploadFile(
            context: any(named: 'context'),
            fileName: any(named: 'fileName'),
            bytes: any(named: 'bytes'),
            folderId: any(named: 'folderId'),
            description: any(named: 'description'),
            audience: any(named: 'audience'),
          ),
        ).thenAnswer((_) async => Right(resource));
        when(
          () => repository.getResources(
            context: any(named: 'context'),
            folderId: any(named: 'folderId'),
          ),
        ).thenAnswer((_) async => Right([resource]));
        when(
          () => repository.getStorageUsage(context: any(named: 'context')),
        ).thenAnswer((_) async => const Right(StorageUsage()));
      },
      build: () => ClassResourceBloc(repository: repository),
      seed: () => ClassResourceState(context: context),
      act: (bloc) => bloc.add(
        ClassResourceUploaded(fileName: 'Notes.pdf', bytes: Uint8List(0)),
      ),
      expect: () => [
        isA<ClassResourceState>().having((s) => s.isSaving, 'isSaving', true),
        isA<ClassResourceState>()
            .having((s) => s.isSaving, 'isSaving', false)
            .having(
              (s) => s.successMessage,
              'successMessage',
              'Uploaded to your class.',
            ),
        isA<ClassResourceState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ClassResourceState>().having(
          (s) => s.resources,
          'resources',
          [resource],
        ),
      ],
    );
  });

  group('ClassResourceRemoved', () {
    blocTest<ClassResourceBloc, ClassResourceState>(
      'removes a resource then reloads',
      setUp: () {
        when(
          () => repository.remove(
            context: any(named: 'context'),
            resource: any(named: 'resource'),
          ),
        ).thenAnswer((_) async => const Right(null));
      },
      build: () => ClassResourceBloc(repository: repository),
      seed: () => ClassResourceState(context: context, resources: [resource]),
      act: (bloc) => bloc.add(ClassResourceRemoved(resource)),
      expect: () => [
        isA<ClassResourceState>().having((s) => s.isSaving, 'isSaving', true),
        isA<ClassResourceState>()
            .having((s) => s.isSaving, 'isSaving', false)
            .having(
              (s) => s.successMessage,
              'successMessage',
              'Resource removed.',
            ),
        isA<ClassResourceState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ClassResourceState>().having((s) => s.resources, 'resources', []),
      ],
    );
  });
}
