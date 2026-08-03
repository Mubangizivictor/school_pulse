import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:school_pulse/core/utils/admin_seeder.dart';
import 'package:school_pulse/firebase_options.dart';

/// Runs the demo seeder against the real Firebase project, then reads back the
/// pieces the Class Teacher panel actually resolves through.
///
/// This exists because seeding was otherwise only reachable by tapping "Seed
/// Full Data" in the Admin dashboard, which makes it unverifiable from a
/// terminal and unrepeatable in CI. The read-back at the end is the point: a
/// seeder that runs without throwing is not the same as a seeder that wrote
/// what the panel needs.
///
/// Destructive - `seedFullData()` clears ~30 collections before rewriting
/// them. Point it at a demo project only.
///
///   `flutter test integration_test/seed_harness.dart -d <simulator-id>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Both the seeder's writes and the read-backs below go through Firestore
    // rules, so the harness has to be somebody. Signing in as the demo admin
    // is what the Admin dashboard button implicitly does.
    const adminEmail = 'admin@gmail.com';
    final auth = FirebaseAuth.instance;
    try {
      await auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: AdminSeeder.defaultPassword,
      );
    } on FirebaseAuthException catch (e) {
      // First run against an empty project: the account the seeder would
      // create does not exist yet, so create it before seeding rather than
      // seeding unauthenticated and silently writing nothing. Any other
      // failure code is a real problem and should surface as one.
      // ignore: avoid_print
      print('Admin sign-in failed (${e.code}): ${e.message}');
      if (e.code == 'user-not-found' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-email') {
        await auth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: AdminSeeder.defaultPassword,
        );
      } else {
        rethrow;
      }
    }
  });

  // seedFullData signs in as several accounts along the way (the school
  // admin, then the super admin, for their respective seed steps) via the
  // shared FirebaseAuth.instance, so the session left behind after it returns
  // is whichever ran last - not the one setUpAll started with. Every read in
  // every test below needs the school admin's access, so restore it before
  // each one rather than assuming the session survives between tests.
  setUp(() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'admin@gmail.com',
      password: AdminSeeder.defaultPassword,
    );
  });

  testWidgets(
    'seeds the demo school',
    (tester) async {
      await AdminSeeder.seedFullData();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'admin@gmail.com',
        password: AdminSeeder.defaultPassword,
      );

      // seedFullData swallows its own exceptions and debugPrints instead, so
      // "it returned" proves nothing. Assert against a document only this run
      // could have written.
      final marker = await FirebaseFirestore.instance
          .collection('schools')
          .doc(AdminSeeder.demoSchoolId)
          .collection('staff_role_assignments')
          .doc('victor-class-teacher-p7')
          .get();
      expect(
        marker.exists,
        isTrue,
        reason: 'seeding reported no error but wrote no class assignment',
      );
    },
    // Several hundred documents plus Auth account creation through temporary
    // FirebaseApp instances; the default 30s is nowhere near enough.
    timeout: const Timeout(Duration(minutes: 10)),
  );

  testWidgets(
    'the academic calendar the panel scopes by exists',
    (tester) async {
      final db = FirebaseFirestore.instance;

      final year = await db
          .collection('academic_years')
          .doc(AdminSeeder.currentAcademicYearId)
          .get();
      expect(year.exists, isTrue, reason: 'academic_years/2026 missing');
      expect(year.data()?['isCurrent'], isTrue);

      final terms = await db
          .collection('academic_terms')
          .where('academicYearId', isEqualTo: AdminSeeder.currentAcademicYearId)
          .get();
      expect(terms.docs, hasLength(3));

      final current = terms.docs.where((d) => d.data()['isCurrent'] == true);
      expect(current, hasLength(1), reason: 'exactly one term must be current');
      expect(current.first.id, AdminSeeder.currentTermId);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'Victor holds three responsibilities against one staff profile',
    (tester) async {
      // Checked by the seeder's own fixed document ids rather than by
      // counting the collection: this staffId also carries rows created
      // outside this seeder entirely (from earlier, unrelated testing), so a
      // count-based assertion would be checking the wrong thing.
      final assignments = FirebaseFirestore.instance
          .collection('schools')
          .doc(AdminSeeder.demoSchoolId)
          .collection('staff_role_assignments');

      final classDoc = await assignments.doc('victor-class-teacher-p7').get();
      final mathsP6 = await assignments.doc('victor-subject-maths-p6').get();
      final mathsP7 = await assignments.doc('victor-subject-maths-p7').get();

      expect(classDoc.exists, isTrue, reason: 'this is what was entirely missing before');
      expect(mathsP6.exists, isTrue);
      expect(mathsP7.exists, isTrue);

      final classRow = classDoc.data()!;
      expect(classRow['roleType'], 'classTeacher');
      expect(classRow['classId'], AdminSeeder.classTeacherClassId);
      expect(classRow['status'], 'active');

      final classPermissions =
          (classRow['permissionScope']['permissions'] as List).cast<String>();
      expect(classPermissions, contains('class.attendance.take'));
      expect(classPermissions, contains('class.report.entry'));

      // The subject rows must carry no class.* authority, or switching
      // responsibility would drag class-teacher rights across with it.
      for (final doc in [mathsP6, mathsP7]) {
        final data = doc.data()!;
        expect(data['roleType'], 'subjectTeacher');
        final permissions =
            (data['permissionScope']['permissions'] as List).cast<String>();
        expect(
          permissions.where((p) => p.startsWith('class.')),
          isEmpty,
          reason: 'subject assignments must not grant class.* permissions',
        );
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'the class has a roster and history, but today is deliberately unmarked',
    (tester) async {
      final db = FirebaseFirestore.instance;

      final roster = await db
          .collection('students')
          .where('schoolId', isEqualTo: AdminSeeder.demoSchoolId)
          .where('classId', isEqualTo: AdminSeeder.classTeacherClassId)
          .where('academicYearId', isEqualTo: AdminSeeder.currentAcademicYearId)
          .where('status', isEqualTo: 'active')
          .get();
      expect(roster.docs, isNotEmpty, reason: 'P7 roster is empty');

      final sessions = await db
          .collection('schools')
          .doc(AdminSeeder.demoSchoolId)
          .collection('class_attendance_sessions')
          .where('classId', isEqualTo: AdminSeeder.classTeacherClassId)
          .get();
      expect(
        sessions.docs,
        isNotEmpty,
        reason: 'attendance history is what gives the rate something to show',
      );

      // The one that must NOT exist: today's register is left unwritten so
      // Roll Call is a live flow rather than an already-closed one.
      final now = DateTime.now();
      final todayId = '${AdminSeeder.classTeacherClassId}_all_daily_'
          '${now.year}-${now.month.toString().padLeft(2, '0')}'
          '-${now.day.toString().padLeft(2, '0')}';
      expect(
        sessions.docs.where((d) => d.id == todayId),
        isEmpty,
        reason: "today's register must be unmarked after seeding",
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
