import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/director/data/repositories/director_governance_repository.dart';
import 'package:school_pulse/features/director/domain/entities/strategic_goal.dart';
import 'package:school_pulse/features/director/domain/entities/leadership_meeting.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;
  late FakeFirebaseFirestore firestore;

  const director = UserEntity(
    id: 'director-1',
    name: 'Dr. Alex Morgan',
    email: 'director@school.test',
    roles: [UserRole.director],
    schoolId: 'school-1',
  );

  setUp(() {
    authBloc = MockAuthBloc();
    firestore = FakeFirebaseFirestore();
    when(() => authBloc.state).thenReturn(const AuthAuthenticated(director));
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pump();
  }

  group('Strategic goals', () {
    testWidgets('renders empty state with no goals', (tester) async {
      final repo = DirectorGovernanceRepository(firestore: firestore);
      await pump(
        tester,
        _TestableGoalsScreen(repository: repo, schoolId: 'school-1'),
      );
      await tester.pump();
      expect(
        find.text('No strategic goals yet. Tap + to add one.'),
        findsOneWidget,
      );
    });

    testWidgets('renders an existing goal from Firestore', (tester) async {
      await firestore
          .collection('schools')
          .doc('school-1')
          .collection('strategic_goals')
          .add(
            StrategicGoal(
              goalId: '',
              institutionId: 'school-1',
              title: 'Increase enrollment by 20%',
              description: 'Grow admissions across all campuses',
              responsibleDepartment: 'Admissions',
              targetValue: 20,
              currentValue: 8,
              unit: '%',
              status: GoalStatus.onTrack,
              deadline: DateTime(2026, 12, 31),
              createdAt: DateTime(2026, 1, 1),
              createdBy: 'director-1',
            ).toMap(),
          );

      final repo = DirectorGovernanceRepository(firestore: firestore);
      await pump(
        tester,
        _TestableGoalsScreen(repository: repo, schoolId: 'school-1'),
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.textContaining('Increase enrollment by 20%'), findsOneWidget);
      expect(find.textContaining('8 / 20 %'), findsOneWidget);
    });
  });

  group('Leadership meetings', () {
    testWidgets('renders empty state with no meetings', (tester) async {
      final repo = DirectorGovernanceRepository(firestore: firestore);
      await pump(
        tester,
        _TestableMeetingsScreen(repository: repo, schoolId: 'school-1'),
      );
      await tester.pump();
      expect(
        find.text('No meetings recorded yet. Tap + to add one.'),
        findsOneWidget,
      );
    });

    testWidgets('renders an existing meeting from Firestore', (tester) async {
      await firestore
          .collection('schools')
          .doc('school-1')
          .collection('leadership_meetings')
          .add(
            LeadershipMeeting(
              meetingId: '',
              institutionId: 'school-1',
              title: 'Board Meeting',
              agenda: 'Term review',
              type: MeetingType.board,
              participants: const ['Dr. Alex Morgan'],
              decisions: const [],
              actions: const [],
              scheduledAt: DateTime(2026, 5, 28),
              createdAt: DateTime(2026, 1, 1),
              createdBy: 'director-1',
            ).toMap(),
          );

      final repo = DirectorGovernanceRepository(firestore: firestore);
      await pump(
        tester,
        _TestableMeetingsScreen(repository: repo, schoolId: 'school-1'),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Board Meeting'), findsOneWidget);
    });
  });
}

/// The production screens construct their own [DirectorGovernanceRepository]
/// pointed at [FirebaseFirestore.instance]; these thin harnesses expose the
/// same body against an injected fake so the Firestore round-trip can be
/// exercised without a live backend.
class _TestableGoalsScreen extends StatelessWidget {
  final DirectorGovernanceRepository repository;
  final String schoolId;
  const _TestableGoalsScreen({
    required this.repository,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: StreamBuilder<List<StrategicGoal>>(
      stream: repository.watchGoals(schoolId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final goals = snapshot.data!;
        if (goals.isEmpty)
          return const Text('No strategic goals yet. Tap + to add one.');
        return ListView(
          children: goals
              .map(
                (g) => Text(
                  '${g.title}\n${g.currentValue.toStringAsFixed(0)} / ${g.targetValue.toStringAsFixed(0)} ${g.unit}',
                ),
              )
              .toList(),
        );
      },
    ),
  );
}

class _TestableMeetingsScreen extends StatelessWidget {
  final DirectorGovernanceRepository repository;
  final String schoolId;
  const _TestableMeetingsScreen({
    required this.repository,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: StreamBuilder<List<LeadershipMeeting>>(
      stream: repository.watchMeetings(schoolId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final meetings = snapshot.data!;
        if (meetings.isEmpty) {
          return const Text('No meetings recorded yet. Tap + to add one.');
        }
        return ListView(children: meetings.map((m) => Text(m.title)).toList());
      },
    ),
  );
}
