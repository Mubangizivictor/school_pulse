import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/academic/domain/entities/report_card.dart';
import 'package:school_pulse/features/academic/domain/usecases/get_academic_records.dart';
import 'package:school_pulse/features/academic/domain/usecases/get_attendance_records.dart';
import 'package:school_pulse/features/academic/domain/usecases/manage_report_cards.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';

class MockGetAcademicRecords extends Mock implements GetAcademicRecords {}
class MockGetAttendanceRecords extends Mock implements GetAttendanceRecords {}
class MockGetReportCards extends Mock implements GetReportCards {}

void main() {
  late AcademicBloc bloc;
  late MockGetAcademicRecords mockGetAcademicRecords;
  late MockGetAttendanceRecords mockGetAttendanceRecords;
  late MockGetReportCards mockGetReportCards;

  setUp(() {
    mockGetAcademicRecords = MockGetAcademicRecords();
    mockGetAttendanceRecords = MockGetAttendanceRecords();
    mockGetReportCards = MockGetReportCards();
    bloc = AcademicBloc(
      getAcademicRecords: mockGetAcademicRecords,
      getAttendanceRecords: mockGetAttendanceRecords,
      getReportCards: mockGetReportCards,
    );
  });

  const tReportCard = ReportCard(
    id: '1',
    studentId: 'student1',
    studentName: 'John Doe',
    className: 'P1',
    term: 'Term 1',
    year: '2023',
    status: ReportCardStatus.fullySigned,
  );

  test('initial state should be AcademicInitial', () {
    expect(bloc.state, equals(AcademicInitial()));
  });

  group('GetReportCardRequested', () {
    blocTest<AcademicBloc, AcademicState>(
      'emits [AcademicLoading, AcademicReportCardLoaded] when GetReportCardRequested is added',
      build: () {
        when(() => mockGetReportCards(
              studentId: any(named: 'studentId'),
              term: any(named: 'term'),
              year: any(named: 'year'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => const Right([tReportCard]));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetReportCardRequested(
        studentId: 'student1',
        term: 'Term 1',
        year: '2023',
      )),
      expect: () => [
        AcademicLoading(),
        const AcademicReportCardLoaded(tReportCard),
      ],
    );
  });
}
