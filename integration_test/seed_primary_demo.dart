import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/core/utils/admin_seeder.dart';
import 'package:school_pulse/firebase_options.dart';

/// Seeds a small, focused Primary-level demo: the school structure (levels,
/// classes, subjects) plus 5 students, 3 parents (as parent_access_codes),
/// and 5 teachers.
///
/// Non-destructive - unlike `AdminSeeder.seedFullData()`, this does NOT call
/// `deleteAllData()` first, so it's safe to run against a project that
/// already has other seeded/real data. It signs in (or creates) the same
/// demo school admin account the rest of the seeders use.
///
///   `flutter test integration_test/seed_primary_demo.dart -d <simulator-id>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const schoolId = AdminSeeder.demoSchoolId;
  late FirebaseFirestore db;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    db = FirebaseFirestore.instance;

    // Deliberately does NOT fall back to createUserWithEmailAndPassword: a
    // brand-new admin@gmail.com would have no Firestore users/{uid} profile,
    // and firestore.rules only allows a client to self-create that doc when
    // role == 'parent' - a schoolAdmin profile can only be written by the
    // Admin SDK (see AdminSeeder._seedAdmin(), which this run assumes has
    // already been executed at least once).
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'admin@gmail.com',
      password: AdminSeeder.defaultPassword,
    );
  });

  testWidgets(
    'seeds a primary-level demo: structure, 5 students, 3 parents, 5 teachers',
    (tester) async {
      // 1. School structure (Primary level, classes, subjects).
      await db.collection('educational_levels').doc('level-primary').set({
        'schoolId': schoolId,
        'name': 'Primary',
        'code': 'PRI',
        'order': 1,
        'description': 'Primary 1 to Primary 7',
        'isActive': true,
      });

      const classNames = [
        'Primary 1',
        'Primary 2',
        'Primary 3',
        'Primary 4',
        'Primary 5',
        'Primary 6',
        'Primary 7',
      ];
      for (final className in classNames) {
        final slug = className.toLowerCase().replaceAll(' ', '-');
        await db.collection('classes').doc(slug).set({
          'schoolId': schoolId,
          'name': className,
          'code': className.replaceAll('Primary ', 'P'),
          'levelId': 'level-primary',
          'capacity': 40,
          'description': '',
          'isActive': true,
        });
      }

      const subjectNames = [
        'Mathematics',
        'English',
        'Science',
        'SST',
        'Religious Education',
      ];
      for (final s in subjectNames) {
        final slug = s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
        await db.collection('subjects').doc(slug).set({
          'schoolId': schoolId,
          'name': s,
        });
      }

      // 2. Five students, spread across Primary 1-5.
      const students = [
        {
          'id': 'demo-s1',
          'name': 'Mugisha Samuel',
          'className': 'Primary 1',
          'gender': 'male',
        },
        {
          'id': 'demo-s2',
          'name': 'Nakamya Sarah',
          'className': 'Primary 2',
          'gender': 'female',
        },
        {
          'id': 'demo-s3',
          'name': 'Okello John',
          'className': 'Primary 3',
          'gender': 'male',
        },
        {
          'id': 'demo-s4',
          'name': 'Babirye Grace',
          'className': 'Primary 4',
          'gender': 'female',
        },
        {
          'id': 'demo-s5',
          'name': 'Kato Emmanuel',
          'className': 'Primary 5',
          'gender': 'male',
        },
      ];

      for (var i = 0; i < students.length; i++) {
        final s = students[i];
        final studentCode = 'KHA/2026/D${(i + 1).toString().padLeft(3, '0')}';
        await db.collection('students').doc(s['id']!).set({
          'id': s['id'],
          'schoolId': schoolId,
          'name': s['name'],
          'className': s['className'],
          'classId': s['className'],
          'studentId': studentCode,
          'studentCode': studentCode,
          'admissionNumber': studentCode,
          'gender': s['gender'],
          'dateOfBirth': Timestamp.fromDate(DateTime(2016, 1, 1)),
          'academicYearId': AdminSeeder.currentAcademicYearId,
          'status': 'active',
          'level': 'primary',
          'isBoarder': false,
          'residency': 'day',
          'hasHealthAlert': false,
        });

        final uniqueSystemId = 'SP-${s['id']}';
        await db.collection('student_identities').doc(s['id']!).set({
          'studentId': s['id'],
          'uniqueSystemId': uniqueSystemId,
          'schoolStudentId': studentCode,
          'qrCodeData': uniqueSystemId,
          'nfcStatus': 'unassigned',
        });
      }

      // 3. Three parents, as parent_access_codes (the app's only parent
      // representation). One parent covers a sibling pair (demo-s4, demo-s5).
      const parents = [
        {
          'code': 'DEMO1001',
          'parentName': 'Mr. Mugisha Peter',
          'phoneNumber': '0700000101',
          'studentIds': ['demo-s1'],
        },
        {
          'code': 'DEMO1002',
          'parentName': 'Mrs. Nakamya Joan',
          'phoneNumber': '0700000102',
          'studentIds': ['demo-s2', 'demo-s3'],
        },
        {
          'code': 'DEMO1003',
          'parentName': 'Mrs. Babirye Alice',
          'phoneNumber': '0700000103',
          'studentIds': ['demo-s4', 'demo-s5'],
        },
      ];
      final studentsById = {for (final s in students) s['id']!: s};

      for (final p in parents) {
        final studentIds = p['studentIds']! as List<String>;
        await db.collection('parent_access_codes').doc(p['code'] as String).set({
          'code': p['code'],
          'parentCode': p['code'],
          'schoolId': schoolId,
          'studentIds': studentIds,
          'studentNames': studentIds
              .map((id) => studentsById[id]!['name'])
              .toList(),
          'parentName': p['parentName'],
          'phoneNumber': PhoneFormatter.toE164(p['phoneNumber'] as String),
          'pin': '1234',
          'mustChangePin': false,
          'isActive': true,
        });
      }

      // 4. Five teachers, one per class-teacher assignment on the first five
      // primary classes.
      const teachers = [
        {
          'name': 'Ms. Namuli Ruth',
          'email': 'demo.teacher1@gmail.com',
          'assignedClass': 'Primary 1',
        },
        {
          'name': 'Mr. Ssekandi Paul',
          'email': 'demo.teacher2@gmail.com',
          'assignedClass': 'Primary 2',
        },
        {
          'name': 'Ms. Tumusiime Grace',
          'email': 'demo.teacher3@gmail.com',
          'assignedClass': 'Primary 3',
        },
        {
          'name': 'Mr. Okot John',
          'email': 'demo.teacher4@gmail.com',
          'assignedClass': 'Primary 4',
        },
        {
          'name': 'Mrs. Nakiwala Grace',
          'email': 'demo.teacher5@gmail.com',
          'assignedClass': 'Primary 5',
        },
      ];

      for (final t in teachers) {
        final tempAppName =
            'seed_app_${(t['email'] as String).replaceAll('.', '_').replaceAll('@', '_')}';
        FirebaseApp tempApp;
        try {
          tempApp = Firebase.app(tempAppName);
        } catch (_) {
          tempApp = await Firebase.initializeApp(
            name: tempAppName,
            options: Firebase.app().options,
          );
        }

        final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
        UserCredential cred;
        try {
          cred = await tempAuth.signInWithEmailAndPassword(
            email: t['email'] as String,
            password: AdminSeeder.defaultPassword,
          );
        } catch (_) {
          cred = await tempAuth.createUserWithEmailAndPassword(
            email: t['email'] as String,
            password: AdminSeeder.defaultPassword,
          );
        }

        await db.collection('users').doc(cred.user!.uid).set({
          'id': cred.user!.uid,
          'name': t['name'],
          'email': t['email'],
          'role': 'classTeacher',
          'roles': ['classTeacher'],
          'schoolId': schoolId,
          'isActive': true,
          'mustChangePassword': false,
          'studentIds': [],
          'assignedClass': t['assignedClass'],
        }, SetOptions(merge: true));

        await db.collection('school_contacts').doc(cred.user!.uid).set({
          'name': t['name'],
          'role': 'classTeacher',
          'roles': ['classTeacher'],
          'schoolId': schoolId,
          'isActive': true,
        }, SetOptions(merge: true));

        final assignmentId =
            'demo-class-teacher-${(t['assignedClass'] as String).toLowerCase().replaceAll(' ', '-')}';
        await db
            .collection('schools')
            .doc(schoolId)
            .collection('staff_role_assignments')
            .doc(assignmentId)
            .set({
              'schoolId': schoolId,
              'campusId': 'main',
              'staffId': cred.user!.uid,
              'userId': cred.user!.uid,
              'roleType': 'classTeacher',
              'academicYearId': AdminSeeder.currentAcademicYearId,
              'subjectId': null,
              'subjectName': null,
              'classId': t['assignedClass'],
              'className': t['assignedClass'],
              'startDate': Timestamp.fromDate(DateTime(2026, 2, 1)),
              'endDate': null,
              'status': 'active',
              'permissionScope': {
                'permissions': <String>[],
                'subjectId': null,
                'classId': t['assignedClass'],
                'academicYearId': AdminSeeder.currentAcademicYearId,
                'termIds': <String>[],
              },
              'assignedBy': 'seed_primary_demo',
              'assignedAt': FieldValue.serverTimestamp(),
            });

        await tempApp.delete();
        debugPrint('✅ Seeded teacher: ${t['email']}');
      }

      // Read-back: prove the writes actually landed, not just that the test
      // returned without throwing.
      final structureCheck = await db.collection('classes').doc('primary-1').get();
      expect(structureCheck.exists, isTrue, reason: 'Primary 1 class missing');

      final studentsCheck = await db
          .collection('students')
          .where('schoolId', isEqualTo: schoolId)
          .where('id', whereIn: students.map((s) => s['id']).toList())
          .get();
      expect(studentsCheck.docs, hasLength(5));

      final parentsCheck = await db
          .collection('parent_access_codes')
          .where('code', whereIn: parents.map((p) => p['code']).toList())
          .get();
      expect(parentsCheck.docs, hasLength(3));

      debugPrint('🏁 Primary demo seed complete: structure, 5 students, 3 parents, 5 teachers.');
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
