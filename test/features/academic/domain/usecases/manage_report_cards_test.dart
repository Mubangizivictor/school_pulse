import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/academic/domain/entities/report_card.dart';
import 'package:school_pulse/features/academic/domain/repositories/academic_repository.dart';
import 'package:school_pulse/features/academic/domain/usecases/manage_report_cards.dart';

class MockAcademicRepository extends Mock implements AcademicRepository {}

void main() {
  late GetReportCards usecase;
  late MockAcademicRepository mockAcademicRepository;

  setUp(() {
    mockAcademicRepository = MockAcademicRepository();
    usecase = GetReportCards(mockAcademicRepository);
  });

  const tReportCard = ReportCard(
    id: '1',
    studentId: 'student1',
    studentName: 'John Doe',
    className: 'P1',
    term: 'Term 1',
    year: '2023',
    status: ReportCardStatus.pending,
  );

  final tReportCards = [tReportCard];

  test('should get report cards from the repository', () async {
    // arrange
    when(
      () => mockAcademicRepository.getReportCards(
        studentId: any(named: 'studentId'),
        className: any(named: 'className'),
        term: any(named: 'term'),
        year: any(named: 'year'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => Right(tReportCards));

    // act
    final result = await usecase(studentId: 'student1');

    // assert
    expect(result, Right(tReportCards));
    verify(
      () => mockAcademicRepository.getReportCards(studentId: 'student1'),
    ).called(1);
    verifyNoMoreInteractions(mockAcademicRepository);
  });

  test('should sign report card using the repository', () async {
    late SignReportCard signUseCase;
    signUseCase = SignReportCard(mockAcademicRepository);

    // arrange
    when(
      () => mockAcademicRepository.signReportCard(
        reportCardId: any(named: 'reportCardId'),
        signerId: any(named: 'signerId'),
        isHeadTeacher: any(named: 'isHeadTeacher'),
      ),
    ).thenAnswer((_) async => const Right(null));

    const tParams = SignReportParams(
      reportCardId: '1',
      signerId: 'dean1',
      isHeadTeacher: false,
    );

    // act
    final result = await signUseCase(tParams);

    // assert
    expect(result, const Right(null));
    verify(
      () => mockAcademicRepository.signReportCard(
        reportCardId: '1',
        signerId: 'dean1',
        isHeadTeacher: false,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockAcademicRepository);
  });
}
