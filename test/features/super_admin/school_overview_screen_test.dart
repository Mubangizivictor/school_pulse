// Proves Screen A (school_overview_screen.dart, exported as
// SchoolDetailScreen) renders the compact redesign: identity card, profile
// summary, and the four action rows into Subscription/Payments/Modules/
// School admins - with no delete-school menu item and no header suspend
// icon (both removed per the redesign spec). The real screen constructs a
// SchoolCountsService (Cloud Functions) inside _MetricsGridState, which
// throws synchronously in a widget test with no Firebase.initializeApp - so
// the metrics-loading/error/refresh behavior is verified at the source
// level here, the same approach the rest of this suite uses for
// Firebase-backed screens (see billing_home_screen_test.dart,
// school_subscription_screen_test.dart), while everything not gated on
// Firebase (identity card, action rows, removed dead UI) is still verified
// with a live widget pump.
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';
import 'package:school_pulse/features/super_admin/domain/repositories/super_admin_repository.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_bloc.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/school_detail_screen.dart';

class _MockRepository extends Mock implements SuperAdminRepository {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

School _school() => School(
  id: 'school1',
  name: 'Greenhill Academy',
  tenantId: 'GREEN',
  address: 'Kampala',
  contactEmail: 'admin@greenhill.ug',
  contactPhone: '+256700000000',
  status: SchoolStatus.active,
  subscriptionPlanId: 'enterprise',
  createdAt: DateTime(2024, 1, 1),
  subscriptionExpiry: DateTime.now().add(const Duration(days: 199)),
);

Future<void> _pump(WidgetTester tester, School school) async {
  final repository = _MockRepository();
  final auth = _MockFirebaseAuth();
  when(() => repository.getAllSchools()).thenAnswer((_) async => [school]);
  when(() => repository.getSchoolApplications()).thenAnswer((_) async => []);
  when(() => repository.getSubscriptionPlans()).thenAnswer((_) async => []);
  when(() => repository.getPlatformStats()).thenAnswer((_) async => {});

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<SuperAdminBloc>(
        create: (_) => SuperAdminBloc(repository: repository, auth: auth),
        child: SchoolDetailScreen(school: school),
      ),
    ),
  );
  // A single pump (not pumpAndSettle): _MetricsGridState's constructor
  // throws building SchoolCountsService with no Firebase app in this test
  // environment, which the widget tester surfaces as a caught FlutterError
  // rather than a fatal crash - assert on what's real without settling
  // through infinite retries.
  await tester.pump();
}

void main() {
  testWidgets('renders identity card and action rows', (tester) async {
    await _pump(tester, _school());

    expect(find.text('Greenhill Academy'), findsWidgets);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('Subscription'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Modules'), findsOneWidget);
    expect(find.text('School admins'), findsOneWidget);
  });

  testWidgets('no delete-school action and no header suspend icon', (
    tester,
  ) async {
    await _pump(tester, _school());

    expect(find.text('Delete School'), findsNothing);
    expect(find.text('Delete school'), findsNothing);
    expect(find.byIcon(Icons.block_rounded), findsNothing);
  });

  group('metrics grid source', () {
    late String source;

    setUpAll(() {
      source = File(
        'lib/features/super_admin/presentation/pages/school_overview_screen.dart',
      ).readAsStringSync();
    });

    test('reads real counts from SchoolCountsService, not metadata fields', () {
      expect(source.contains('SchoolCountsService'), isTrue);
      expect(source.contains("school.metadata['studentCount']"), isFalse);
      expect(source.contains("school.metadata['staffCount']"), isFalse);
    });

    test(
      'has loading, loaded and unavailable states with a retry affordance',
      () {
        expect(source.contains('_CountsLoadState'), isTrue);
        expect(source.contains('CircularProgressIndicator'), isTrue);
        expect(source.contains('tap to retry'), isTrue);
      },
    );

    test('pull-to-refresh also refreshes the metrics tile', () {
      expect(source.contains('_metricsKey.currentState?.refresh()'), isTrue);
    });
  });
}
