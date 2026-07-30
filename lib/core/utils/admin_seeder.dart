import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:school_pulse/core/utils.dart';

class AdminSeeder {
  static const String defaultPassword = "Test@123";
  static const String demoSchoolId = 'school-pulse-academy';
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> deleteAllData() async {
    final collections = [
      // 'users' is deliberately excluded - users/{uid} has `allow delete: if
      // false` (staff accounts are only ever deactivated, never bulk-
      // deleted by a client) and deleting the Firestore profile wouldn't
      // remove the paired Firebase Auth account anyway. _seedStaff() below
      // upserts by fixed email/uid, so skipping the delete here is safe -
      // reseeding just re-writes the same accounts in place.
      // 'audit_logs' is also excluded - it's an append-only audit trail
      // (`allow update, delete: if false`), so a reseed accumulates on top
      // of prior history instead of erasing it.
      'students', 'parent_access_codes', 'attendance',
      'academic_records', 'report_cards', 'report_comments', 'fees', 'payments',
      'health_visits', 'health_profiles', 'clinic_visits',
      'emergency_incidents', 'medical_inventory', 'medical_supply_requests',
      'welfare_records',
      'discipline_incidents',
      'counseling_sessions',
      'library_books',
      'homework',
      'visitors',
      'appointments',
      'meal_plans',
      'sports_houses',
      'sports_competitions',
      'dormitories', 'religion_activities', 'spiritual_groups', 'alerts',
      'config', 'inventory_items', 'inventory_movements',
      'lesson_plans', 'school_events', 'staff_attendance',
      'payroll', 'bus_routes', 'trips', 'pickup_logs', 'exams',
      'stats', 'classes', 'subjects',
    ];

    for (var collection in collections) {
      try {
        final snapshots = await _db.collection(collection).get();
        for (var doc in snapshots.docs) {
          await doc.reference.delete();
        }
        debugPrint("🗑️ Cleared collection: $collection");
      } catch (e) {
        debugPrint("⚠️ Could not clear $collection: $e");
      }
    }
  }

  static Future<void> seedFullData() async {
    try {
      debugPrint("🚀 Starting full data seeding...");

      await deleteAllData();
      debugPrint("🧹 Database cleared.");

      await _seedAdmin();
      await _seedSuperAdmin();
      // A new school onboarding registers its classes/streams and subjects
      // before staff accounts can be assigned to them - do that here first.
      await _seedSchoolStructure();
      await _seedStudents();
      await _seedParentAccessCodes();
      final staffUids = await _seedStaff();

      await _seedDormitories();
      await _seedFeesAndPayments();
      await _seedSchoolEvents();
      await _seedLibraryBooks();
      await _seedVisitorLogs();
      await _seedHealthVisits();
      await _seedInventory();
      await _seedDisciplineAndCounseling(staffUids['discipline@gmail.com']);
      await _seedPayroll(staffUids);
      await _seedTransport();
      await _seedCatering();
      await _seedGames();
      await _seedReligion();
      await _seedExams();
      await _seedNoticesAndAuditLogs();

      debugPrint("🏁 FULL SEEDING COMPLETE!");
    } catch (e) {
      debugPrint("❌ Seeding failed: $e");
    }
  }

  static Future<void> _seedSuperAdmin() async {
    const superAdminEmail = "superadmin@gmail.com";
    final cred = await _getOrCreateUser(superAdminEmail, defaultPassword);

    await _db.collection('users').doc(cred.user!.uid).set({
      'id': cred.user!.uid,
      'name': 'Platform Owner',
      'email': superAdminEmail,
      'role': 'superAdmin',
      'schoolId': 'platform',
      'studentIds': [],
      'mustChangePassword': false,
      'isActive': true,
    }, SetOptions(merge: true));
  }

  static Future<void> _seedSchoolStructure() async {
    final classes = [
      {'name': 'Primary 1', 'streamCount': 1, 'studentCount': 0},
      {'name': 'Primary 2', 'streamCount': 1, 'studentCount': 0},
      {'name': 'Primary 3', 'streamCount': 1, 'studentCount': 0},
      {'name': 'Primary 4', 'streamCount': 2, 'studentCount': 0},
      {'name': 'Primary 5', 'streamCount': 2, 'studentCount': 0},
      {'name': 'Primary 6', 'streamCount': 2, 'studentCount': 0},
      {'name': 'Primary 7', 'streamCount': 2, 'studentCount': 0},
    ];
    for (var c in classes) {
      await _db.collection('classes').add(c);
    }

    const subjects = [
      'Mathematics',
      'English',
      'Science',
      'SST',
      'Religious Education',
      'Physical Education',
      'Art & Craft',
    ];
    for (var s in subjects) {
      await _db.collection('subjects').add({'name': s});
    }
  }

  static Future<void> _seedAdmin() async {
    const adminEmail = "mubangizivic@gmail.com";
    final adminCred = await _getOrCreateUser(adminEmail, defaultPassword);

    // No 'createdAt' here - users/{uid}'s update rule only allows changing
    // mustChangePassword/studentIds, and a re-stamped serverTimestamp would
    // always show up as a diff and get the whole write denied on a reseed
    // (the admin doc survives deleteAllData(), so this merge is an update,
    // not a create, on every run after the first).
    await _db.collection('users').doc(adminCred.user!.uid).set({
      'id': adminCred.user!.uid,
      'name': 'System Administrator',
      'email': adminEmail,
      'role': 'schoolAdmin',
      'schoolId': demoSchoolId,
      'studentIds': [],
      'mustChangePassword': false,
      'isActive': true,
    }, SetOptions(merge: true));
  }

  // id, name, className, studentId, gender, isBoarder - 100 students spread
  // across Primary 1-7, ~35% boarders, so every admin screen (dashboard
  // counts, dormitories, fees, library) has a realistic volume of data
  // instead of a token handful of rows.
  static const List<String> _maleFirstNames = [
    'Mugisha',
    'Okello',
    'Kato',
    'Wamala',
    'Mutebi',
    'Ssempala',
    'Byaruhanga',
    'Kirunda',
    'Ochieng',
    'Ssekandi',
    'Tumusiime',
    'Lubega',
    'Kigozi',
    'Ssali',
    'Mubangizi',
    'Kayongo',
    'Ntambi',
    'Ssebunya',
    'Kavuma',
    'Mwesigwa',
  ];
  static const List<String> _femaleFirstNames = [
    'Nakamya',
    'Babirye',
    'Nabatanzi',
    'Achieng',
    'Kirabo',
    'Nassiwa',
    'Nakiwala',
    'Namukasa',
    'Nabirye',
    'Namuli',
    'Nansubuga',
    'Namutebi',
    'Nalubega',
    'Nankya',
    'Namazzi',
    'Naigaga',
    'Nankunda',
    'Nabukenya',
    'Namono',
    'Kobusingye',
  ];
  static const List<String> _maleGivenNames = [
    'Samuel',
    'John',
    'Emmanuel',
    'Brian',
    'Ivan',
    'Daniel',
    'Denis',
    'Peter',
    'Fred',
    'Robert',
    'Charles',
    'Moses',
    'Paul',
    'James',
    'Steven',
    'Joseph',
    'Isaac',
    'Joshua',
    'Vincent',
    'Patrick',
  ];
  static const List<String> _femaleGivenNames = [
    'Sarah',
    'Joy',
    'Grace',
    'Patricia',
    'Faith',
    'Rose',
    'Mary',
    'Alice',
    'Ruth',
    'Joan',
    'Esther',
    'Irene',
    'Betty',
    'Diana',
    'Sandra',
    'Christine',
    'Peace',
    'Hope',
    'Winnie',
    'Brenda',
  ];
  static const List<String> _classNames = [
    'Primary 1',
    'Primary 2',
    'Primary 3',
    'Primary 4',
    'Primary 5',
    'Primary 6',
    'Primary 7',
  ];

  static List<Map<String, Object>> _generateStudents() {
    final students = <Map<String, Object>>[];
    for (var i = 0; i < 100; i++) {
      final isMale = i.isEven;
      final familyName = isMale
          ? _maleFirstNames[i % _maleFirstNames.length]
          : _femaleFirstNames[i % _femaleFirstNames.length];
      final givenName = isMale
          ? _maleGivenNames[(i ~/ 2) % _maleGivenNames.length]
          : _femaleGivenNames[(i ~/ 2) % _femaleGivenNames.length];
      students.add({
        'id': 's${i + 1}',
        'name': '$familyName $givenName',
        'className': _classNames[i % _classNames.length],
        'studentId': 'KHA/2026/${(i + 1).toString().padLeft(3, '0')}',
        'gender': isMale ? 'Male' : 'Female',
        'isBoarder': i % 3 == 0,
      });
    }
    return students;
  }

  static final List<Map<String, Object>> _students = _generateStudents();

  static Future<void> _seedStudents() async {
    for (var s in _students) {
      await _db.collection('students').doc(s['id'] as String).set({
        'id': s['id'],
        'schoolId': demoSchoolId,
        'name': s['name'],
        'className': s['className'],
        'classId': s['className'],
        'studentId': s['studentId'],
        'studentCode': s['studentId'],
        'admissionNumber': s['studentId'],
        'gender': (s['gender'] as String).toLowerCase(),
        'dateOfBirth': Timestamp.fromDate(DateTime(2012, 1, 1)),
        'academicYearId': '2026',
        'status': 'active',
        'level': 'primary',
        'isBoarder': s['isBoarder'],
      });
    }
  }

  /// One code per 1-2 students (simulating siblings sharing a family code),
  /// covering every seeded student so the Admin "Parents" tab has a
  /// realistic volume of family access codes to browse/search/manage.
  static List<Map<String, Object>> _generateParentAccessCodes() {
    final codes = <Map<String, Object>>[];
    var i = 0;
    var phone = 700000000;
    var codeNum = 1000;
    while (i < _students.length) {
      final isSiblingPair = i % 4 == 0 && i + 1 < _students.length;
      final group = _students.sublist(i, i + (isSiblingPair ? 2 : 1));
      final familyName = (group.first['name'] as String).split(' ').first;
      final title = codeNum.isEven ? 'Mr.' : 'Mrs.';
      codes.add({
        'code': 'KHA${codeNum++}',
        'studentIds': group.map((s) => s['id'] as String).toList(),
        'parentName': '$title $familyName',
        'phoneNumber': '0${phone++}',
      });
      i += group.length;
    }
    return codes;
  }

  static Future<void> _seedParentAccessCodes() async {
    final codes = _generateParentAccessCodes();
    final byId = {for (var s in _students) s['id'] as String: s};

    for (var c in codes) {
      final studentIds = c['studentIds'] as List<String>;
      await _db.collection('parent_access_codes').doc(c['code'] as String).set({
        'code': c['code'],
        'parentCode': c['code'],
        'schoolId': demoSchoolId,
        'studentIds': studentIds,
        'studentNames': studentIds.map((id) => byId[id]!['name']).toList(),
        'parentName': c['parentName'],
        'phoneNumber': PhoneFormatter.toE164(c['phoneNumber'] as String),
        'pin': '1234',
        'mustChangePin': false,
        'isActive': true,
      });
    }
  }

  static Future<UserCredential> _getOrCreateUser(
    String email,
    String password,
  ) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (_) {
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  }

  static Future<Map<String, String>> _seedStaff() async {
    final staff = [
      {
        'name': 'Mr. Byaruhanga Sam',
        'email': 'director@gmail.com',
        'role': 'director',
      },
      {
        'name': 'Mrs. Nakiwala Grace',
        'email': 'headteacher@gmail.com',
        'role': 'headTeacher',
      },
      {
        'name': 'Mr. Ssekandi Paul',
        'email': 'deputyhead@gmail.com',
        'role': 'deputyHead',
      },
      {
        'name': 'Mr. Sseba John',
        'email': 'dean@gmail.com',
        'role': 'deanOfStudies',
      },
      {
        'name': 'Ms. Nalule Jane',
        'email': 'bursar@gmail.com',
        'role': 'bursar',
      },
      {
        'name': 'Mr. Okot John',
        'email': 'teacher@gmail.com',
        'role': 'classTeacher',
        'assignedClass': 'Primary 4',
      },
      {
        'name': 'Ms. Tumusiime Grace',
        'email': 'subjectteacher@gmail.com',
        'role': 'subjectTeacher',
      },
      {
        'name': 'Mr. Wasswa Ivan',
        'email': 'librarian@gmail.com',
        'role': 'librarian',
      },
      {'name': 'Dr. Musoke Peter', 'email': 'nurse@gmail.com', 'role': 'nurse'},
      {
        'name': 'Mrs. Akello Mary',
        'email': 'matron@gmail.com',
        'role': 'boardingMatron',
      },
      {
        'name': 'Mr. Ochieng Denis',
        'email': 'patron@gmail.com',
        'role': 'boardingPatron',
      },
      {
        'name': 'Mr. Mugabe Steven',
        'email': 'transport@gmail.com',
        'role': 'transportCoordinator',
      },
      {
        'name': 'Ms. Namuli Ruth',
        'email': 'discipline@gmail.com',
        'role': 'guidanceDiscipline',
      },
      {
        'name': 'Mr. Kigozi Frank',
        'email': 'inventory@gmail.com',
        'role': 'storeInventory',
      },
      {
        'name': 'Mr. Lubega Tom',
        'email': 'gatekeeper@gmail.com',
        'role': 'gatekeeper',
      },
      {
        'name': 'Mr. Kateregga',
        'email': 'security@gmail.com',
        'role': 'securityHead',
      },
      {
        'name': 'Coach Okello',
        'email': 'games@gmail.com',
        'role': 'gamesMaster',
      },
      {
        'name': 'Chef Kato',
        'email': 'catering@gmail.com',
        'role': 'cateringManager',
      },
      {
        'name': 'Sheikh Juma',
        'email': 'religion@gmail.com',
        'role': 'religiousLeader',
      },
      {
        'name': 'Ms. Nabirye',
        'email': 'receptionist@gmail.com',
        'role': 'receptionist',
      },
      {
        'name': 'Ms. Nabirye Sarah',
        'email': 'hr@gmail.com',
        'role': 'hrOfficer',
      },
    ];

    final uids = <String, String>{};
    for (var st in staff) {
      final uid = await _seedStaffMember(
        st['name']!,
        st['email']!,
        st['role']!,
        assignedClass: st['assignedClass'],
      );
      if (uid != null) uids[st['email']!] = uid;
    }

    // A concrete example of one login holding several roles at once: Mr.
    // Victor is the Primary 7 class teacher, teaches Mathematics to P6 and
    // P7, and is also the discipline head. His panel shows all three.
    final victorUid = await _seedStaffMember(
      'Mr. Victor Ssebunya',
      'victor@gmail.com',
      'classTeacher',
      assignedClass: 'Primary 7',
      additionalRoles: const ['subjectTeacher', 'guidanceDiscipline'],
      subjects: const [
        {'subjectName': 'Mathematics', 'className': 'Primary 6'},
        {'subjectName': 'Mathematics', 'className': 'Primary 7'},
      ],
    );
    if (victorUid != null) uids['victor@gmail.com'] = victorUid;

    // A freshly-invited teacher who hasn't logged in yet - exercises the
    // Admin Dashboard's "Pending Actions" panel (staff pending first-login
    // setup) and the audit log's "Staff Account Created" entry.
    //
    // Unlike every other staff member above, this one must go through the
    // createStaffAccount Cloud Function rather than a direct Firestore
    // write: users/{uid} only allows a client to *create* its own doc when
    // role == 'parent' (see firestore.rules), so a brand-new non-parent
    // profile can only ever be written by the Admin SDK. The other staff
    // above already have a users/{uid} doc from a prior seed, so their
    // writes hit the (isStaff()-gated) update path instead and don't need
    // this - only a genuinely new account does.
    final newHireUid = await _seedNewHireViaCloudFunction();
    if (newHireUid != null) uids['pending.teacher@gmail.com'] = newHireUid;

    return uids;
  }

  static Future<String?> _seedNewHireViaCloudFunction() async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'createStaffAccount',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'name': 'Ms. Kirabo Patience',
        'email': 'pending.teacher@gmail.com',
        'roles': ['subjectTeacher'],
      });
      debugPrint(
        "✅ Seeded pending new hire via Cloud Function: pending.teacher@gmail.com",
      );
      return result.data['uid'] as String?;
    } catch (e) {
      // 'already-exists' means a previous seed run already created this
      // account - that's fine, it's already there to demonstrate the
      // pending-setup scenario.
      debugPrint("⚠️ Skipping new-hire seed (pending.teacher@gmail.com): $e");
      return null;
    }
  }

  static Future<String?> _seedStaffMember(
    String name,
    String email,
    String role, {
    String? assignedClass,
    List<String> additionalRoles = const [],
    List<Map<String, String>>? subjects,
    bool mustChangePassword = false,
    bool isActive = true,
  }) async {
    try {
      final tempAppName = 'seed_app_${role.replaceAll(' ', '_')}';
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
          email: email,
          password: defaultPassword,
        );
      } catch (_) {
        cred = await tempAuth.createUserWithEmailAndPassword(
          email: email,
          password: defaultPassword,
        );
      }

      final roles = [role, ...additionalRoles];
      // No 'createdAt' - see the comment on the admin's own write above;
      // same reasoning applies here since staff docs also survive
      // deleteAllData() and this becomes an update on every reseed after
      // the first.
      await _db.collection('users').doc(cred.user!.uid).set({
        'id': cred.user!.uid,
        'name': name,
        'email': email,
        'role': role,
        'roles': roles,
        'schoolId': demoSchoolId,
        'isActive': isActive,
        'mustChangePassword': mustChangePassword,
        'studentIds': [],
        'assignedClass': assignedClass,
        'subjects': subjects,
      }, SetOptions(merge: true));

      await _db.collection('school_contacts').doc(cred.user!.uid).set({
        'name': name,
        'role': role,
        'roles': roles,
        'schoolId': demoSchoolId,
        'isActive': isActive,
      }, SetOptions(merge: true));

      await tempApp.delete();
      debugPrint("✅ Seeded ${roles.join('+')}: $email");
      return cred.user!.uid;
    } catch (e) {
      debugPrint("⚠️ Skipping staff seed for $email: $e");
      return null;
    }
  }

  static Future<void> _seedDormitories() async {
    // Each dormitory is single-gender, so the Matron (Female) and Patron
    // (Male) accounts each only ever see their own wing.
    final dorms = [
      {'id': 'd1', 'name': 'Sunrise House', 'gender': 'Male', 'capacity': 25},
      {'id': 'd2', 'name': 'Sunset House', 'gender': 'Female', 'capacity': 20},
      {'id': 'd3', 'name': 'Rainbow House', 'gender': 'Female', 'capacity': 15},
    ];

    final maleBoarders = _students
        .where((s) => s['isBoarder'] == true && s['gender'] == 'Male')
        .toList();
    final femaleBoarders = _students
        .where((s) => s['isBoarder'] == true && s['gender'] == 'Female')
        .toList();

    // studentId -> {dormitoryId, bedNumber}
    final allocations = <String, Map<String, String>>{};
    for (var i = 0; i < maleBoarders.length; i++) {
      allocations[maleBoarders[i]['id'] as String] = {
        'dormitoryId': 'd1',
        'bedNumber': 'A${i + 1}',
      };
    }
    for (var i = 0; i < femaleBoarders.length; i++) {
      final dormId = i < 20 ? 'd2' : 'd3';
      final bedNumber = i < 20 ? i + 1 : i - 19;
      allocations[femaleBoarders[i]['id'] as String] = {
        'dormitoryId': dormId,
        'bedNumber': 'B$bedNumber',
      };
    }

    final occupantCounts = <String, int>{};
    for (var alloc in allocations.values) {
      final dormId = alloc['dormitoryId']!;
      occupantCounts[dormId] = (occupantCounts[dormId] ?? 0) + 1;
    }

    for (var d in dorms) {
      await _db.collection('dormitories').doc(d['id'] as String).set({
        'name': d['name'],
        'gender': d['gender'],
        'capacity': d['capacity'],
        'currentOccupants': occupantCounts[d['id']] ?? 0,
      });
    }

    for (var entry in allocations.entries) {
      await _db.collection('students').doc(entry.key).update({
        'dormitoryId': entry.value['dormitoryId'],
        'bedNumber': entry.value['bedNumber'],
      });
    }

    final today = DateTime.now();
    final onLeaveCount = (allocations.length / 10).ceil().clamp(1, 10);
    await _db.collection('stats').doc('attendance_summary').set({
      'totalStudents': _students.length,
      'studentsPresent': _students.length - onLeaveCount,
      'studentsOnLeave': onLeaveCount,
      'studentsIn': allocations.length - onLeaveCount,
      'studentsOut': onLeaveCount,
      'updatedAt': Timestamp.fromDate(today),
    });

    // A night roll call from yesterday, so the matron dashboard has history.
    // Every 10th boarder is marked absent, so the roll call isn't a
    // suspiciously uniform 100% present.
    final yesterday = today
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];
    final boarderIds = allocations.keys.toList();
    final batch = _db.batch();
    for (var i = 0; i < boarderIds.length; i++) {
      final studentId = boarderIds[i];
      final ref = _db
          .collection('attendance')
          .doc(yesterday)
          .collection('students')
          .doc(studentId);
      batch.set(ref, {
        'studentId': studentId,
        'dormitoryId': allocations[studentId]!['dormitoryId'],
        'isPresent': i % 10 != 0,
        'timestamp': Timestamp.fromDate(
          today.subtract(const Duration(days: 1, hours: -21)),
        ),
        'type': 'night',
      });
    }
    await batch.commit();
  }

  static Future<void> _seedFeesAndPayments() async {
    final statuses = ['paid', 'due', 'overdue'];
    final methods = ['Mobile Money', 'Cash', 'Bank Transfer'];
    final now = DateTime.now();

    for (var i = 0; i < _students.length; i++) {
      final s = _students[i];
      final studentId = s['id'] as String;
      final isBoarder = s['isBoarder'] as bool;
      final status = statuses[i % statuses.length];
      final tuitionAmount = 450000.0 + (i * 15000);

      await _db.collection('fees').add({
        'studentId': studentId,
        'category': 'Tuition - Term 2, 2026',
        'amount': tuitionAmount,
        'status': status,
        'dueDate': Timestamp.fromDate(DateTime(2026, 8, 15)),
      });

      if (status == 'paid') {
        final paymentDate = now.subtract(Duration(days: 3 + i));
        await _db.collection('payments').add({
          'studentId': studentId,
          'amount': tuitionAmount,
          'date': Timestamp.fromDate(paymentDate),
          'method': methods[i % methods.length],
          'reference': 'RCT-${1000 + i}',
        });
        await _db.collection('alerts').add({
          'studentId': studentId,
          'title': 'Payment Received',
          'message':
              'We have received UGX ${tuitionAmount.toStringAsFixed(0)} for Tuition - Term 2, 2026. Thank you!',
          'severity': 'success',
          'timestamp': Timestamp.fromDate(paymentDate),
        });
      } else if (status == 'overdue') {
        await _db.collection('alerts').add({
          'studentId': studentId,
          'title': 'Fee Overdue',
          'message':
              'Tuition - Term 2, 2026 (UGX ${tuitionAmount.toStringAsFixed(0)}) is overdue. Please settle the balance.',
          'severity': 'warning',
          'timestamp': Timestamp.fromDate(
            now.subtract(const Duration(days: 2)),
          ),
        });
      }

      if (isBoarder) {
        final boardingAmount = 200000.0;
        final boardingStatus = i.isEven ? 'due' : 'paid';
        await _db.collection('fees').add({
          'studentId': studentId,
          'category': 'Boarding Fee - Term 2, 2026',
          'amount': boardingAmount,
          'status': boardingStatus,
          'dueDate': Timestamp.fromDate(DateTime(2026, 8, 15)),
        });
        if (boardingStatus == 'paid') {
          final paymentDate = now.subtract(Duration(days: 5 + i));
          await _db.collection('payments').add({
            'studentId': studentId,
            'amount': boardingAmount,
            'date': Timestamp.fromDate(paymentDate),
            'method': methods[(i + 1) % methods.length],
            'reference': 'RCT-B${1000 + i}',
          });
          await _db.collection('alerts').add({
            'studentId': studentId,
            'title': 'Payment Received',
            'message':
                'We have received UGX ${boardingAmount.toStringAsFixed(0)} for Boarding Fee - Term 2, 2026. Thank you!',
            'severity': 'success',
            'timestamp': Timestamp.fromDate(paymentDate),
          });
        }
      }
    }
  }

  static Future<void> _seedSchoolEvents() async {
    final now = DateTime.now();
    final events = [
      {
        'title': 'Term 2 Midterm Exams',
        'description': 'Midterm assessments for all classes.',
        'date': now.subtract(const Duration(days: 14)),
        'type': 'exam',
      },
      {
        'title': 'Staff Meeting - Term Review',
        'description': 'Review of term 2 progress with all department heads.',
        'date': now.subtract(const Duration(days: 5)),
        'type': 'staffMeeting',
      },
      {
        'title': 'Inter-House Sports Day',
        'description': 'Annual athletics competition between the four houses.',
        'date': now.add(const Duration(days: 7)),
        'type': 'sportsEvent',
      },
      {
        'title': "Parents' Visitation Day",
        'description':
            'Parents are welcome to visit boarders and meet class teachers.',
        'date': now.add(const Duration(days: 14)),
        'type': 'general',
      },
      {
        'title': 'End of Term 2',
        'description': 'Last day of term; report cards issued.',
        'date': now.add(const Duration(days: 30)),
        'type': 'holiday',
      },
      {
        'title': 'Grade Entry Deadline',
        'description': 'All class teachers must submit Term 2 marks.',
        'date': now.add(const Duration(days: 2)),
        'type': 'deadline',
      },
      {
        'title': 'Report Card Signing Deadline',
        'description': 'Head Teacher and Dean sign-off on report cards.',
        'date': now.add(const Duration(days: 6)),
        'type': 'deadline',
      },
    ];

    for (var e in events) {
      await _db.collection('school_events').add({
        'title': e['title'],
        'description': e['description'],
        'date': Timestamp.fromDate(e['date'] as DateTime),
        'createdBy': 'System Administrator',
        'targetGroups': const ['Parents', 'All Staff'],
        'type': e['type'],
      });
    }
  }

  static Future<void> _seedLibraryBooks() async {
    final now = DateTime.now();
    final records = [
      {
        'studentId': 's1',
        'title': 'Things Fall Apart',
        'author': 'Chinua Achebe',
        'due': 5,
        'returned': false,
      },
      {
        'studentId': 's3',
        'title': 'Long Walk to Freedom',
        'author': 'Nelson Mandela',
        'due': 10,
        'returned': false,
      },
      {
        'studentId': 's5',
        'title': 'The River Between',
        'author': "Ngũgĩ wa Thiong'o",
        'due': -3,
        'returned': true,
      },
      {
        'studentId': 's2',
        'title': 'Weep Not, Child',
        'author': "Ngũgĩ wa Thiong'o",
        'due': -8,
        'returned': true,
      },
      {
        'studentId': 's7',
        'title': 'So Long a Letter',
        'author': 'Mariama Bâ',
        'due': 3,
        'returned': false,
      },
      {
        'studentId': 's4',
        'title': "Half of a Yellow Sun",
        'author': 'Chimamanda Ngozi Adichie',
        'due': -1,
        'returned': true,
      },
      {
        'studentId': 's9',
        'title': 'Petals of Blood',
        'author': "Ngũgĩ wa Thiong'o",
        'due': 7,
        'returned': false,
      },
      {
        'studentId': 's6',
        'title': "Nervous Conditions",
        'author': 'Tsitsi Dangarembga',
        'due': -15,
        'returned': true,
      },
    ];

    for (var r in records) {
      await _db.collection('library_books').add({
        'studentId': r['studentId'],
        'title': r['title'],
        'author': r['author'],
        'dueDate': Timestamp.fromDate(now.add(Duration(days: r['due'] as int))),
        'isReturned': r['returned'],
      });
    }
  }

  static Future<void> _seedVisitorLogs() async {
    final now = DateTime.now();

    // Two or three visitors per day for the last 13 days, so the Visitor
    // Log's history (and the Admin Dashboard's "Visitors Today" vs overall
    // count) shows a realistic spread across dates, not just today.
    const pastVisitors = [
      {'name': 'Mr. Kato Joseph', 'purpose': 'Visiting son'},
      {'name': 'Delivery - Bantu Traders', 'purpose': 'Stationery delivery'},
      {'name': 'Mrs. Namukasa Mary', 'purpose': 'Fees payment'},
      {
        'name': 'Uganda Health Inspectorate',
        'purpose': 'Routine health & safety inspection',
      },
      {'name': 'Mr. Ssali Moses', 'purpose': 'Bus maintenance contractor'},
      {'name': 'Mrs. Nabirye Joan', 'purpose': 'Parent-teacher meeting'},
      {'name': 'Aristoc Suppliers', 'purpose': 'Textbook delivery'},
      {'name': 'Mr. Kavuma Peter', 'purpose': 'Picking up sick child'},
      {'name': 'Kampala Water Board', 'purpose': 'Water meter inspection'},
      {
        'name': 'Mrs. Kirabo Sarah',
        'purpose': 'Dropping off forgotten homework',
      },
      {
        'name': 'Mr. Tumusiime Isaac',
        'purpose': 'Job interview - Bursar office',
      },
      {
        'name': 'Dr. Nansubuga Ruth',
        'purpose': 'Visiting school nurse - medical supplies',
      },
    ];

    final visitors = <Map<String, Object?>>[];
    var nameIndex = 0;
    for (var daysAgo = 13; daysAgo >= 1; daysAgo--) {
      final visitsToday = daysAgo.isEven ? 2 : 1;
      for (var v = 0; v < visitsToday; v++) {
        final visitor = pastVisitors[nameIndex % pastVisitors.length];
        nameIndex++;
        final entryMinutes = -(daysAgo * 1440) + (v * 180) - 600;
        visitors.add({
          'name': visitor['name'],
          'purpose': visitor['purpose'],
          'entry': entryMinutes,
          'exit': entryMinutes + 45,
          'status': 'Checked Out',
        });
      }
    }

    // Today's visitors, including two still on-site.
    visitors.addAll(const [
      {
        'name': 'Mr. Ssemwanga Fred',
        'purpose': 'Meeting class teacher',
        'entry': -25,
        'exit': null,
        'status': 'Checked In',
      },
      {
        'name': 'Mrs. Achieng Grace',
        'purpose': 'Picking up a child early',
        'entry': -10,
        'exit': null,
        'status': 'Checked In',
      },
      // Checked in 3h ago and never checked out - exercises the Admin
      // Dashboard's "Pending Actions" overdue-visitor warning.
      {
        'name': 'Mr. Byaruhanga Denis',
        'purpose': 'Vendor meeting - catering supplies',
        'entry': -180,
        'exit': null,
        'status': 'Checked In',
      },
    ]);

    for (var v in visitors) {
      // VisitorRepository (used by both the live Visitor Log screen and the
      // Admin Dashboard stats) reads from 'visitors' with checkIn/checkOut -
      // this used to write to a 'visitor_logs' collection nothing reads.
      await _db.collection('visitors').add({
        'name': v['name'],
        'purpose': v['purpose'],
        'contact': '',
        'checkIn': Timestamp.fromDate(
          now.add(Duration(minutes: v['entry'] as int)),
        ),
        'checkOut': v['exit'] != null
            ? Timestamp.fromDate(now.add(Duration(minutes: v['exit'] as int)))
            : null,
        'signedInBy': '',
      });
    }
  }

  static Future<void> _seedHealthVisits() async {
    final now = DateTime.now();
    final recorderId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final visits = [
      {
        'studentId': 's2',
        'daysAgo': 2,
        'reason': 'Headache',
        'treatment': 'Paracetamol administered, rested in sick bay',
        'medication': 'Paracetamol 500mg',
      },
      {
        'studentId': 's8',
        'daysAgo': 5,
        'reason': 'Malaria symptoms',
        'treatment': 'Referred to Kampala Clinic',
        'medication': 'Coartem',
      },
      {
        'studentId': 's6',
        'daysAgo': 10,
        'reason': 'Minor cut on knee',
        'treatment': 'Wound cleaned and dressed',
        'medication': 'Antiseptic ointment',
      },
      {
        'studentId': 's11',
        'daysAgo': 1,
        'reason': 'Stomach ache',
        'treatment': 'Observed for 1 hour, resolved on its own',
        'medication': 'None',
      },
      {
        'studentId': 's1',
        'daysAgo': 20,
        'reason': 'Allergic reaction - skin rash',
        'treatment': 'Antihistamine given, parent notified',
        'medication': 'Piriton',
      },
    ];

    for (var v in visits) {
      final visitRef = _db.collection('clinic_visits').doc();
      await visitRef.set({
        'id': visitRef.id,
        'schoolId': demoSchoolId,
        'studentId': v['studentId'],
        'dateTime': Timestamp.fromDate(
          now.subtract(Duration(days: v['daysAgo'] as int)),
        ),
        'reason': v['reason'],
        'symptoms': v['reason'],
        'treatmentProvided': v['treatment'],
        'medicationsGiven': v['medication'] == 'None'
            ? <Map<String, dynamic>>[]
            : [
                {
                  'medicationId': 'seed-medication',
                  'medicationName': v['medication'],
                  'dosage': 'As directed',
                  'timeAdministered': Timestamp.fromDate(now),
                  'administeredBy': 'seed-nurse',
                },
              ],
        'followUpRequired': false,
        'outcome': 'VisitOutcome.sentBackToClass',
        'recordedBy': recorderId,
      });
    }

    for (final student in _students.take(12)) {
      final studentId = student['id'] as String;
      final profileId = base64Url
          .encode(utf8.encode('$demoSchoolId:$studentId'))
          .replaceAll('=', '');
      await _db.collection('health_profiles').doc(profileId).set({
        'studentId': studentId,
        'schoolId': demoSchoolId,
        'bloodGroup': studentId.hashCode.isEven ? 'O' : 'A',
        'rhesusFactor': '+',
        'allergies': studentId == 's1' ? ['Peanuts'] : <String>[],
        'chronicIllnesses': <String>[],
        'currentMedications': <String>[],
        'emergencyContactName': 'Parent / Guardian',
        'emergencyContactPhone': '+256700000000',
        'vaccinationHistory': <Map<String, dynamic>>[],
      });
    }

    final inventory = [
      ('Paracetamol 500 mg', 'Pain relief', 120, 'Tablets', 30),
      ('Disposable gloves', 'PPE', 18, 'Pairs', 25),
      ('Antiseptic solution', 'First aid', 8, 'Bottles', 5),
      ('Digital thermometer', 'Equipment', 3, 'Pieces', 2),
    ];
    for (final item in inventory) {
      final ref = _db.collection('medical_inventory').doc();
      await ref.set({
        'id': ref.id,
        'schoolId': demoSchoolId,
        'name': item.$1,
        'type': item.$1.contains('thermometer')
            ? 'MedicalItemType.equipment'
            : item.$1.contains('gloves')
            ? 'MedicalItemType.supply'
            : 'MedicalItemType.medication',
        'category': item.$2,
        'quantity': item.$3,
        'unit': item.$4,
        'reorderLevel': item.$5,
        'purchaseDate': Timestamp.fromDate(
          now.subtract(const Duration(days: 30)),
        ),
      });
    }
  }

  static Future<void> _seedInventory() async {
    final items = [
      {
        'id': 'inv1',
        'name': 'Exercise Books',
        'category': 'Stationery',
        'quantity': 400,
        'unit': 'Pieces',
        'lowStockThreshold': 100,
      },
      {
        'id': 'inv2',
        'name': 'Whiteboard Markers',
        'category': 'Stationery',
        'quantity': 15,
        'unit': 'Pieces',
        'lowStockThreshold': 20,
      },
      {
        'id': 'inv3',
        'name': 'Football',
        'category': 'Sports',
        'quantity': 3,
        'unit': 'Pieces',
        'lowStockThreshold': 5,
      },
      {
        'id': 'inv4',
        'name': 'Desks',
        'category': 'Furniture',
        'quantity': 220,
        'unit': 'Pieces',
        'lowStockThreshold': 20,
      },
      {
        'id': 'inv5',
        'name': 'Printer Paper (Reams)',
        'category': 'Stationery',
        'quantity': 8,
        'unit': 'Reams',
        'lowStockThreshold': 10,
      },
      {
        'id': 'inv6',
        'name': 'First Aid Kits',
        'category': 'Medical',
        'quantity': 6,
        'unit': 'Kits',
        'lowStockThreshold': 4,
      },
      {
        'id': 'inv7',
        'name': 'Ball Point Pens',
        'category': 'Stationery',
        'quantity': 850,
        'unit': 'Pieces',
        'lowStockThreshold': 150,
      },
      {
        'id': 'inv8',
        'name': 'Chalk Boxes',
        'category': 'Stationery',
        'quantity': 40,
        'unit': 'Boxes',
        'lowStockThreshold': 15,
      },
      {
        'id': 'inv9',
        'name': 'Netballs',
        'category': 'Sports',
        'quantity': 5,
        'unit': 'Pieces',
        'lowStockThreshold': 4,
      },
      {
        'id': 'inv10',
        'name': 'Volleyball Nets',
        'category': 'Sports',
        'quantity': 2,
        'unit': 'Pieces',
        'lowStockThreshold': 2,
      },
      {
        'id': 'inv11',
        'name': 'Athletics Track Cones',
        'category': 'Sports',
        'quantity': 30,
        'unit': 'Pieces',
        'lowStockThreshold': 10,
      },
      {
        'id': 'inv12',
        'name': 'Classroom Chairs',
        'category': 'Furniture',
        'quantity': 480,
        'unit': 'Pieces',
        'lowStockThreshold': 30,
      },
      {
        'id': 'inv13',
        'name': 'Staff Room Tables',
        'category': 'Furniture',
        'quantity': 12,
        'unit': 'Pieces',
        'lowStockThreshold': 2,
      },
      {
        'id': 'inv14',
        'name': 'Whiteboards',
        'category': 'Furniture',
        'quantity': 18,
        'unit': 'Pieces',
        'lowStockThreshold': 3,
      },
      {
        'id': 'inv15',
        'name': 'Digital Thermometers',
        'category': 'Medical',
        'quantity': 8,
        'unit': 'Pieces',
        'lowStockThreshold': 3,
      },
      {
        'id': 'inv16',
        'name': 'Paracetamol (Boxes)',
        'category': 'Medical',
        'quantity': 22,
        'unit': 'Boxes',
        'lowStockThreshold': 10,
      },
      {
        'id': 'inv17',
        'name': 'Wheelbarrows',
        'category': 'Maintenance',
        'quantity': 4,
        'unit': 'Pieces',
        'lowStockThreshold': 1,
      },
      {
        'id': 'inv18',
        'name': 'Detergent (20L)',
        'category': 'Cleaning',
        'quantity': 30,
        'unit': 'Jerricans',
        'lowStockThreshold': 10,
      },
      {
        'id': 'inv19',
        'name': 'Toilet Paper Rolls',
        'category': 'Cleaning',
        'quantity': 12,
        'unit': 'Rolls',
        'lowStockThreshold': 40,
      },
      {
        'id': 'inv20',
        'name': 'Laptops (ICT Lab)',
        'category': 'ICT',
        'quantity': 25,
        'unit': 'Pieces',
        'lowStockThreshold': 5,
      },
      {
        'id': 'inv21',
        'name': 'Projector Bulbs',
        'category': 'ICT',
        'quantity': 3,
        'unit': 'Pieces',
        'lowStockThreshold': 4,
      },
      {
        'id': 'inv22',
        'name': 'Cooking Gas Cylinders (Kitchen)',
        'category': 'Catering',
        'quantity': 6,
        'unit': 'Cylinders',
        'lowStockThreshold': 2,
      },
      {
        'id': 'inv23',
        'name': 'Rice (50kg Bags)',
        'category': 'Catering',
        'quantity': 14,
        'unit': 'Bags',
        'lowStockThreshold': 5,
      },
      {
        'id': 'inv24',
        'name': 'Posho / Maize Flour (50kg Bags)',
        'category': 'Catering',
        'quantity': 18,
        'unit': 'Bags',
        'lowStockThreshold': 5,
      },
    ];

    for (var item in items) {
      await _db.collection('inventory_items').doc(item['id'] as String).set({
        'name': item['name'],
        'category': item['category'],
        'quantity': item['quantity'],
        'unit': item['unit'],
        'lowStockThreshold': item['lowStockThreshold'],
      });
    }

    final now = DateTime.now();
    final movements = [
      {
        'itemId': 'inv1',
        'itemName': 'Exercise Books',
        'type': 'restock',
        'quantity': 200,
        'daysAgo': 14,
        'note': 'Term 2 restock from Aristoc Suppliers',
      },
      {
        'itemId': 'inv2',
        'itemName': 'Whiteboard Markers',
        'type': 'issue',
        'quantity': 10,
        'daysAgo': 3,
        'note': 'Issued to Primary 4-6 teachers',
      },
      {
        'itemId': 'inv5',
        'itemName': 'Printer Paper (Reams)',
        'type': 'issue',
        'quantity': 5,
        'daysAgo': 1,
        'note': 'Issued to admin office for report printing',
      },
      {
        'itemId': 'inv7',
        'itemName': 'Ball Point Pens',
        'type': 'restock',
        'quantity': 500,
        'daysAgo': 20,
        'note': 'Bulk order from Aristoc Suppliers',
      },
      {
        'itemId': 'inv9',
        'itemName': 'Netballs',
        'type': 'issue',
        'quantity': 2,
        'daysAgo': 9,
        'note': 'Issued to Games department for house matches',
      },
      {
        'itemId': 'inv12',
        'itemName': 'Classroom Chairs',
        'type': 'restock',
        'quantity': 60,
        'daysAgo': 25,
        'note': 'New Primary 1 stream furnishing',
      },
      {
        'itemId': 'inv16',
        'itemName': 'Paracetamol (Boxes)',
        'type': 'issue',
        'quantity': 4,
        'daysAgo': 5,
        'note': 'Issued to sick bay',
      },
      {
        'itemId': 'inv18',
        'itemName': 'Detergent (20L)',
        'type': 'issue',
        'quantity': 8,
        'daysAgo': 4,
        'note': 'Issued to cleaning staff - dormitories',
      },
      {
        'itemId': 'inv19',
        'itemName': 'Toilet Paper Rolls',
        'type': 'issue',
        'quantity': 30,
        'daysAgo': 2,
        'note': 'Issued across all blocks - running low, reorder needed',
      },
      {
        'itemId': 'inv20',
        'itemName': 'Laptops (ICT Lab)',
        'type': 'restock',
        'quantity': 10,
        'daysAgo': 30,
        'note': 'ICT lab expansion - new intake',
      },
      {
        'itemId': 'inv23',
        'itemName': 'Rice (50kg Bags)',
        'type': 'issue',
        'quantity': 4,
        'daysAgo': 6,
        'note': 'Issued to kitchen - weekly ration',
      },
      {
        'itemId': 'inv24',
        'itemName': 'Posho / Maize Flour (50kg Bags)',
        'type': 'issue',
        'quantity': 5,
        'daysAgo': 6,
        'note': 'Issued to kitchen - weekly ration',
      },
    ];

    for (var m in movements) {
      await _db.collection('inventory_movements').add({
        'itemId': m['itemId'],
        'itemName': m['itemName'],
        'type': m['type'],
        'quantity': m['quantity'],
        'date': Timestamp.fromDate(
          now.subtract(Duration(days: m['daysAgo'] as int)),
        ),
        'note': m['note'],
      });
    }
  }

  static Future<void> _seedDisciplineAndCounseling(String? counselorId) async {
    final now = DateTime.now();
    final incidents = [
      {
        'studentId': 's3',
        'daysAgo': 10,
        'description': 'Fighting with a classmate during break time',
        'severity': 'error',
        'punishment': 'Suspension',
      },
      {
        'studentId': 's7',
        'daysAgo': 6,
        'description': 'Repeatedly late to class',
        'severity': 'warning',
        'punishment': 'Verbal Warning',
      },
      {
        'studentId': 's9',
        'daysAgo': 2,
        'description': 'Disruptive behavior in class',
        'severity': 'warning',
        'punishment': '',
      },
    ];

    for (var inc in incidents) {
      await _db.collection('discipline_incidents').add({
        'studentId': inc['studentId'],
        'date': Timestamp.fromDate(
          now.subtract(Duration(days: inc['daysAgo'] as int)),
        ),
        'description': inc['description'],
        'severity': inc['severity'],
        'resolution': '',
        'counselingNotes': '',
        'punishment': inc['punishment'],
      });
    }

    final sessions = [
      {
        'studentId': 's3',
        'daysAgo': 8,
        'reason': 'Follow-up after fighting incident',
        'notes': 'Student expressed frustration over bullying by peers.',
        'recommendations': 'Weekly check-ins for a month.',
      },
    ];

    for (var s in sessions) {
      await _db.collection('counseling_sessions').add({
        'studentId': s['studentId'],
        'counselorId': counselorId ?? '',
        'date': Timestamp.fromDate(
          now.subtract(Duration(days: s['daysAgo'] as int)),
        ),
        'reason': s['reason'],
        'notes': s['notes'],
        'recommendations': s['recommendations'],
        'linkedIncidentId': null,
      });
    }
  }

  static Future<void> _seedPayroll(Map<String, String> staffUids) async {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final monthLabel = '${_monthName(lastMonth.month)} ${lastMonth.year}';

    final entries = [
      {'email': 'teacher@gmail.com', 'name': 'Mr. Okot John', 'base': 900000.0},
      {
        'email': 'bursar@gmail.com',
        'name': 'Ms. Nalule Jane',
        'base': 1100000.0,
      },
      {
        'email': 'librarian@gmail.com',
        'name': 'Mr. Wasswa Ivan',
        'base': 700000.0,
      },
      {
        'email': 'nurse@gmail.com',
        'name': 'Dr. Musoke Peter',
        'base': 950000.0,
      },
      {'email': 'hr@gmail.com', 'name': 'Ms. Nabirye Sarah', 'base': 1000000.0},
    ];

    for (var e in entries) {
      final staffId = staffUids[e['email']] ?? '';
      final base = e['base'] as double;
      const allowances = 100000.0;
      const bonuses = 0.0;
      final nssfEmployee = base * 0.05;
      final nssfEmployer = base * 0.10;
      final paye = base > 235000 ? (base - 235000) * 0.2 : 0.0;
      final netPay = base + allowances + bonuses - nssfEmployee - paye;

      await _db.collection('payroll').add({
        'staffId': staffId,
        'staffName': e['name'],
        'month': monthLabel,
        'baseSalary': base,
        'allowances': allowances,
        'bonuses': bonuses,
        'deductions': 0.0,
        'nssfEmployee': nssfEmployee,
        'nssfEmployer': nssfEmployer,
        'paye': paye,
        'netPay': netPay,
        'createdAt': Timestamp.fromDate(lastMonth),
      });
    }
  }

  static String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final idx = ((month - 1) % 12 + 12) % 12;
    return names[idx];
  }

  static Future<void> _seedTransport() async {
    final routes = [
      {
        'id': 'r1',
        'name': 'Route A - Kansanga/Muyenga',
        'busNumber': 'UBK 123A',
        'driver': 'Mr. Ochieng Paul',
        'studentCount': 18,
        'status': 'Stationary',
      },
      {
        'id': 'r2',
        'name': 'Route B - Ntinda/Kyambogo',
        'busNumber': 'UBK 456B',
        'driver': 'Mr. Kirunda James',
        'studentCount': 22,
        'status': 'Stationary',
      },
      {
        'id': 'r3',
        'name': 'Route C - Entebbe Road',
        'busNumber': 'UBK 789C',
        'driver': 'Mr. Ssali Moses',
        'studentCount': 15,
        'status': 'En Route',
      },
    ];

    for (var r in routes) {
      await _db.collection('bus_routes').doc(r['id'] as String).set({
        'name': r['name'],
        'busNumber': r['busNumber'],
        'driver': r['driver'],
        'studentCount': r['studentCount'],
        'status': r['status'],
      });
    }

    final now = DateTime.now();
    await _db.collection('trips').add({
      'routeId': 'r3',
      'status': 'ongoing',
      'startedAt': Timestamp.fromDate(
        now.subtract(const Duration(minutes: 25)),
      ),
    });

    await _db.collection('stats').doc('transport_summary').set({
      'activeRoutes': routes.length,
      'studentsOnBoard': 55,
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  static Future<void> _seedCatering() async {
    final weekMenu = {
      'monday': [
        {
          'mealType': 'Breakfast',
          'menu': 'Porridge & Bread',
          'time': '7:00 AM',
        },
        {
          'mealType': 'Lunch',
          'menu': 'Posho, Beans & Greens',
          'time': '1:00 PM',
        },
        {
          'mealType': 'Dinner',
          'menu': 'Rice, Chicken Stew & Vegetables',
          'time': '7:00 PM',
        },
      ],
      'tuesday': [
        {'mealType': 'Breakfast', 'menu': 'Tea & Mandazi', 'time': '7:00 AM'},
        {
          'mealType': 'Lunch',
          'menu': 'Matooke, Groundnut Sauce',
          'time': '1:00 PM',
        },
        {'mealType': 'Dinner', 'menu': 'Posho & Beef Stew', 'time': '7:00 PM'},
      ],
      'wednesday': [
        {
          'mealType': 'Breakfast',
          'menu': 'Porridge & Sweet Potatoes',
          'time': '7:00 AM',
        },
        {'mealType': 'Lunch', 'menu': 'Rice & Fish Stew', 'time': '1:00 PM'},
        {
          'mealType': 'Dinner',
          'menu': 'Posho, Beans & Cabbage',
          'time': '7:00 PM',
        },
      ],
      'thursday': [
        {'mealType': 'Breakfast', 'menu': 'Tea & Bread', 'time': '7:00 AM'},
        {'mealType': 'Lunch', 'menu': 'Matooke & Beef Stew', 'time': '1:00 PM'},
        {
          'mealType': 'Dinner',
          'menu': 'Rice, Peas & Greens',
          'time': '7:00 PM',
        },
      ],
      'friday': [
        {
          'mealType': 'Breakfast',
          'menu': 'Porridge & Mandazi',
          'time': '7:00 AM',
        },
        {
          'mealType': 'Lunch',
          'menu': 'Posho & Groundnut Sauce',
          'time': '1:00 PM',
        },
        {'mealType': 'Dinner', 'menu': 'Pilau & Chicken', 'time': '7:00 PM'},
      ],
      'saturday': [
        {
          'mealType': 'Breakfast',
          'menu': 'Tea & Sweet Potatoes',
          'time': '7:30 AM',
        },
        {'mealType': 'Lunch', 'menu': 'Rice & Beans', 'time': '1:00 PM'},
        {'mealType': 'Dinner', 'menu': 'Posho & Fish', 'time': '7:00 PM'},
      ],
      'sunday': [
        {'mealType': 'Breakfast', 'menu': 'Tea & Bread', 'time': '8:00 AM'},
        {
          'mealType': 'Lunch',
          'menu': 'Pilau, Chicken & Salad',
          'time': '1:30 PM',
        },
        {'mealType': 'Dinner', 'menu': 'Rice & Beef Stew', 'time': '7:00 PM'},
      ],
    };

    for (var entry in weekMenu.entries) {
      await _db.collection('meal_plans').doc(entry.key).set({
        'meals': entry.value,
      });
    }

    await _db.collection('stats').doc('catering_summary').set({
      'mealsServedToday': 320,
      'studentsWithDietaryNeeds': 4,
    });
  }

  static Future<void> _seedGames() async {
    final houses = [
      {
        'id': 'h1',
        'name': 'Red House',
        'color': 'red',
        'totalPoints': 120,
        'houseMaster': 'Coach Okello',
      },
      {
        'id': 'h2',
        'name': 'Blue House',
        'color': 'blue',
        'totalPoints': 145,
        'houseMaster': 'Mr. Ochieng Paul',
      },
      {
        'id': 'h3',
        'name': 'Green House',
        'color': 'green',
        'totalPoints': 98,
        'houseMaster': 'Mrs. Nabatanzi Alice',
      },
      {
        'id': 'h4',
        'name': 'Yellow House',
        'color': 'yellow',
        'totalPoints': 110,
        'houseMaster': 'Mr. Kirunda James',
      },
    ];

    for (var h in houses) {
      await _db.collection('sports_houses').doc(h['id'] as String).set({
        'name': h['name'],
        'color': h['color'],
        'totalPoints': h['totalPoints'],
        'houseMaster': h['houseMaster'],
      });
    }

    final now = DateTime.now();
    final competitions = [
      {
        'title': 'Inter-School Football Friendly',
        'daysOffset': -20,
        'venue': 'School Grounds',
        'status': 'Completed',
      },
      {
        'title': 'Inter-House Sports Day',
        'daysOffset': 7,
        'venue': 'School Grounds',
        'status': 'Planned',
      },
    ];

    for (var c in competitions) {
      await _db.collection('sports_competitions').add({
        'title': c['title'],
        'date': Timestamp.fromDate(
          now.add(Duration(days: c['daysOffset'] as int)),
        ),
        'venue': c['venue'],
        'status': c['status'],
      });
    }
  }

  static Future<void> _seedReligion() async {
    final now = DateTime.now();
    final activities = [
      {
        'title': 'Catholic Mass',
        'daysOffset': -7,
        'venue': 'School Chapel',
        'category': 'Catholic',
      },
      {
        'title': "Friday Prayers (Jumu'ah)",
        'daysOffset': -3,
        'venue': 'Prayer Room',
        'category': 'Muslim',
      },
      {
        'title': 'Inter-faith Prayer Day',
        'daysOffset': 10,
        'venue': 'Main Hall',
        'category': 'Inter-faith',
      },
    ];

    for (var a in activities) {
      await _db.collection('religion_activities').add({
        'title': a['title'],
        'dateTime': Timestamp.fromDate(
          now.add(Duration(days: a['daysOffset'] as int)),
        ),
        'venue': a['venue'],
        'category': a['category'],
      });
    }

    final groups = [
      {
        'name': 'Catholic Fellowship',
        'leader': 'Sheikh Juma',
        'memberCount': 45,
      },
      {
        'name': 'Muslim Students Association',
        'leader': 'Sheikh Juma',
        'memberCount': 20,
      },
      {
        'name': 'Anglican Youth Fellowship',
        'leader': 'Sheikh Juma',
        'memberCount': 30,
      },
    ];

    for (var g in groups) {
      await _db.collection('spiritual_groups').add({
        'name': g['name'],
        'leader': g['leader'],
        'memberCount': g['memberCount'],
      });
    }
  }

  static Future<void> _seedExams() async {
    final now = DateTime.now();
    final exams = [
      {
        'subject': 'Mathematics',
        'className': 'Primary 6',
        'daysOffset': 5,
        'session': 'Morning',
      },
      {
        'subject': 'English',
        'className': 'Primary 6',
        'daysOffset': 6,
        'session': 'Morning',
      },
      {
        'subject': 'Science',
        'className': 'Primary 4',
        'daysOffset': 8,
        'session': 'Afternoon',
      },
      {
        'subject': 'Social Studies',
        'className': 'Primary 5',
        'daysOffset': 9,
        'session': 'Morning',
      },
    ];

    for (var e in exams) {
      final date = now.add(Duration(days: e['daysOffset'] as int));
      await _db.collection('exams').add({
        'subject': e['subject'],
        'className': e['className'],
        'date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'session': e['session'],
        'timestamp': Timestamp.fromDate(date),
      });
    }

    await _db.collection('stats').doc('exams_summary').set({
      'upcomingExams': exams.length,
      'termName': 'Term 2, 2026',
    });
  }

  /// A couple of staff-wide broadcasts (Admin Dashboard "Active Staff
  /// Notices") and historical audit-log entries (Admin Dashboard "Live
  /// Audit Log"), so both panels have content immediately after a reseed
  /// instead of only filling in once someone performs a real action.
  static Future<void> _seedNoticesAndAuditLogs() async {
    final now = DateTime.now();
    final adminUid = FirebaseAuth.instance.currentUser?.uid;

    final notices = [
      {
        'title': 'Annual Sports Day',
        'body':
            'Scheduled for Friday - all staff to supervise their assigned house.',
        'daysAgo': 1,
      },
      {
        'title': 'End of Term Exams',
        'body':
            'Timetables will be released to class teachers tomorrow morning.',
        'daysAgo': 3,
      },
    ];
    for (var n in notices) {
      await _db.collection('alerts').add({
        'title': n['title'],
        'body': n['body'],
        'targets': ['All Staff'],
        'timestamp': Timestamp.fromDate(
          now.subtract(Duration(days: n['daysAgo'] as int)),
        ),
        'type': 'Push',
        'status': 'sent',
      });
    }

    final logs = [
      {
        'title': 'Staff Account Created',
        'description': 'Ms. Kirabo Patience was added as Subject Teacher.',
        'iconName': 'person_add',
        'colorHex': 'FF2196F3',
        'minutesAgo': 40,
      },
      {
        'title': 'Broadcast Sent',
        'description': '"Annual Sports Day" sent to All Staff via Push.',
        'iconName': 'send',
        'colorHex': 'FF9C27B0',
        'minutesAgo': 1440,
      },
      {
        'title': 'Visitor Checked In',
        'description':
            'Mr. Byaruhanga Denis - Vendor meeting - catering supplies.',
        'iconName': 'inventory_2',
        'colorHex': 'FF009688',
        'minutesAgo': 180,
      },
    ];
    for (var l in logs) {
      await _db.collection('audit_logs').add({
        'title': l['title'],
        'description': l['description'],
        'iconName': l['iconName'],
        'colorHex': l['colorHex'],
        'timestamp': Timestamp.fromDate(
          now.subtract(Duration(minutes: l['minutesAgo'] as int)),
        ),
        'userId': adminUid,
      });
    }
  }

  static Future<void> seedAdmin() => seedFullData();
}
