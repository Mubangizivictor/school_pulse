import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSeeder {
  static const String defaultPassword = "Test@123";
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> deleteAllData() async {
    final collections = [
      'users', 'students', 'parent_access_codes', 'attendance',
      'academic_records', 'report_cards', 'fees', 'payments', 'health_visits',
      'discipline_incidents', 'counseling_sessions', 'library_books',
      'visitor_logs', 'meal_plans', 'sports_houses', 'sports_competitions',
      'dormitories', 'religion_activities', 'spiritual_groups', 'alerts',
      'config', 'system_config', 'inventory_items', 'inventory_movements',
      'lesson_plans', 'school_events', 'staff_attendance', 'audit_logs',
      'audits', 'payroll', 'bus_routes', 'trips', 'pickup_logs', 'exams',
      'stats', 'classes', 'subjects',
    ];

    for (var collection in collections) {
      final snapshots = await _db.collection(collection).get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
      debugPrint("🗑️ Cleared collection: $collection");
    }
  }

  static Future<void> seedFullData() async {
    try {
      debugPrint("🚀 Starting full data seeding...");

      await deleteAllData();
      debugPrint("🧹 Database cleared.");

      await _seedAdmin();
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

      debugPrint("🏁 FULL SEEDING COMPLETE!");
    } catch (e) {
      debugPrint("❌ Seeding failed: $e");
    }
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

    await _db.collection('users').doc(adminCred.user!.uid).set({
      'id': adminCred.user!.uid,
      'name': 'System Administrator',
      'email': adminEmail,
      'role': 'schoolAdmin',
      'studentIds': [],
      'mustChangePassword': false,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // id, name, className, studentId, gender, isBoarder
  static final List<Map<String, Object>> _students = [
    {'id': 's1', 'name': 'Mugisha Samuel', 'className': 'Primary 4', 'studentId': 'KHA/2023/001', 'gender': 'Male', 'isBoarder': true},
    {'id': 's2', 'name': 'Nakamya Sarah', 'className': 'Primary 2', 'studentId': 'KHA/2023/045', 'gender': 'Female', 'isBoarder': true},
    {'id': 's3', 'name': 'Okello John', 'className': 'Primary 6', 'studentId': 'KHA/2022/112', 'gender': 'Male', 'isBoarder': true},
    {'id': 's4', 'name': 'Babirye Joy', 'className': 'Primary 4', 'studentId': 'KHA/2023/002', 'gender': 'Female', 'isBoarder': false},
    {'id': 's5', 'name': 'Ssempala Ivan', 'className': 'Primary 5', 'studentId': 'KHA/2022/078', 'gender': 'Male', 'isBoarder': false},
    {'id': 's6', 'name': 'Nabatanzi Grace', 'className': 'Primary 3', 'studentId': 'KHA/2023/090', 'gender': 'Female', 'isBoarder': true},
    {'id': 's7', 'name': 'Kato Emmanuel', 'className': 'Primary 6', 'studentId': 'KHA/2022/113', 'gender': 'Male', 'isBoarder': true},
    {'id': 's8', 'name': 'Nassiwa Rose', 'className': 'Primary 1', 'studentId': 'KHA/2024/010', 'gender': 'Female', 'isBoarder': false},
    {'id': 's9', 'name': 'Wamala Brian', 'className': 'Primary 5', 'studentId': 'KHA/2022/079', 'gender': 'Male', 'isBoarder': false},
    {'id': 's10', 'name': 'Achieng Patricia', 'className': 'Primary 2', 'studentId': 'KHA/2023/046', 'gender': 'Female', 'isBoarder': true},
    {'id': 's11', 'name': 'Mutebi Daniel', 'className': 'Primary 3', 'studentId': 'KHA/2023/091', 'gender': 'Male', 'isBoarder': false},
    {'id': 's12', 'name': 'Kirabo Faith', 'className': 'Primary 7', 'studentId': 'KHA/2023/003', 'gender': 'Female', 'isBoarder': false},
  ];

  static Future<void> _seedStudents() async {
    for (var s in _students) {
      await _db.collection('students').doc(s['id'] as String).set({
        'id': s['id'],
        'name': s['name'],
        'className': s['className'],
        'studentId': s['studentId'],
        'gender': s['gender'],
        'isBoarder': s['isBoarder'],
      });
    }
  }

  static Future<void> _seedParentAccessCodes() async {
    final codes = [
      {'code': 'KHA1234', 'studentIds': ['s1', 's4'], 'parentName': 'Mr. Kato Joseph', 'phoneNumber': '0700000000'},
      {'code': 'KHA5678', 'studentIds': ['s2'], 'parentName': 'Mrs. Namukasa Mary', 'phoneNumber': '0711111111'},
      {'code': 'KHA2001', 'studentIds': ['s3'], 'parentName': 'Mr. Okello Peter', 'phoneNumber': '0722222222'},
      {'code': 'KHA2002', 'studentIds': ['s5'], 'parentName': 'Mr. Ssemwanga Fred', 'phoneNumber': '0733333333'},
      {'code': 'KHA2003', 'studentIds': ['s6'], 'parentName': 'Mrs. Nabatanzi Alice', 'phoneNumber': '0744444444'},
      {'code': 'KHA2004', 'studentIds': ['s7', 's11'], 'parentName': 'Mr. Kato Robert', 'phoneNumber': '0755555555'},
      {'code': 'KHA2005', 'studentIds': ['s8'], 'parentName': 'Mrs. Nassiwa Joan', 'phoneNumber': '0766666666'},
      {'code': 'KHA2006', 'studentIds': ['s9'], 'parentName': 'Mr. Wamala Charles', 'phoneNumber': '0777777777'},
      {'code': 'KHA2007', 'studentIds': ['s10', 's12'], 'parentName': 'Mrs. Achieng Grace', 'phoneNumber': '0788888888'},
    ];

    final byId = {for (var s in _students) s['id'] as String: s};

    for (var c in codes) {
      final studentIds = c['studentIds'] as List<String>;
      await _db.collection('parent_access_codes').doc(c['code'] as String).set({
        'code': c['code'],
        'studentIds': studentIds,
        'studentNames': studentIds.map((id) => byId[id]!['name']).toList(),
        'parentName': c['parentName'],
        'phoneNumber': c['phoneNumber'],
        'pin': '1234',
        'mustChangePin': false,
        'isActive': true,
      });
    }
  }

  static Future<UserCredential> _getOrCreateUser(String email, String password) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } catch (_) {
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    }
  }

  static Future<Map<String, String>> _seedStaff() async {
    final staff = [
      {'name': 'Mr. Byaruhanga Sam', 'email': 'director@gmail.com', 'role': 'director'},
      {'name': 'Mrs. Nakiwala Grace', 'email': 'headteacher@gmail.com', 'role': 'headTeacher'},
      {'name': 'Mr. Ssekandi Paul', 'email': 'deputyhead@gmail.com', 'role': 'deputyHead'},
      {'name': 'Mr. Sseba John', 'email': 'dean@gmail.com', 'role': 'deanOfStudies'},
      {'name': 'Ms. Nalule Jane', 'email': 'bursar@gmail.com', 'role': 'bursar'},
      {'name': 'Mr. Okot John', 'email': 'teacher@gmail.com', 'role': 'classTeacher', 'assignedClass': 'Primary 4'},
      {'name': 'Ms. Tumusiime Grace', 'email': 'subjectteacher@gmail.com', 'role': 'subjectTeacher'},
      {'name': 'Mr. Wasswa Ivan', 'email': 'librarian@gmail.com', 'role': 'librarian'},
      {'name': 'Dr. Musoke Peter', 'email': 'nurse@gmail.com', 'role': 'nurse'},
      {'name': 'Mrs. Akello Mary', 'email': 'matron@gmail.com', 'role': 'boardingMatron'},
      {'name': 'Mr. Ochieng Denis', 'email': 'patron@gmail.com', 'role': 'boardingPatron'},
      {'name': 'Mr. Mugabe Steven', 'email': 'transport@gmail.com', 'role': 'transportCoordinator'},
      {'name': 'Ms. Namuli Ruth', 'email': 'discipline@gmail.com', 'role': 'guidanceDiscipline'},
      {'name': 'Mr. Kigozi Frank', 'email': 'inventory@gmail.com', 'role': 'storeInventory'},
      {'name': 'Mr. Lubega Tom', 'email': 'gatekeeper@gmail.com', 'role': 'gatekeeper'},
      {'name': 'Mr. Kateregga', 'email': 'security@gmail.com', 'role': 'securityHead'},
      {'name': 'Coach Okello', 'email': 'games@gmail.com', 'role': 'gamesMaster'},
      {'name': 'Chef Kato', 'email': 'catering@gmail.com', 'role': 'cateringManager'},
      {'name': 'Sheikh Juma', 'email': 'religion@gmail.com', 'role': 'religiousLeader'},
      {'name': 'Ms. Nabirye', 'email': 'receptionist@gmail.com', 'role': 'receptionist'},
      {'name': 'Ms. Nabirye Sarah', 'email': 'hr@gmail.com', 'role': 'hrOfficer'},
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

    return uids;
  }

  static Future<String?> _seedStaffMember(
    String name,
    String email,
    String role, {
    String? assignedClass,
    List<String> additionalRoles = const [],
    List<Map<String, String>>? subjects,
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
        cred = await tempAuth.signInWithEmailAndPassword(email: email, password: defaultPassword);
      } catch (_) {
        cred = await tempAuth.createUserWithEmailAndPassword(email: email, password: defaultPassword);
      }

      final roles = [role, ...additionalRoles];
      await _db.collection('users').doc(cred.user!.uid).set({
        'id': cred.user!.uid,
        'name': name,
        'email': email,
        'role': role,
        'roles': roles,
        'isActive': true,
        'mustChangePassword': false,
        'studentIds': [],
        'assignedClass': ?assignedClass,
        'subjects': ?subjects,
        'createdAt': FieldValue.serverTimestamp(),
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
      {'id': 'd1', 'name': 'Sunrise House', 'gender': 'Male', 'capacity': 20},
      {'id': 'd2', 'name': 'Sunset House', 'gender': 'Female', 'capacity': 20},
      {'id': 'd3', 'name': 'Rainbow House', 'gender': 'Female', 'capacity': 15},
    ];

    // studentId -> {dormitoryId, bedNumber}
    final allocations = {
      's1': {'dormitoryId': 'd1', 'bedNumber': 'A1'}, // Mugisha Samuel (Male)
      's3': {'dormitoryId': 'd1', 'bedNumber': 'A2'}, // Okello John (Male)
      's7': {'dormitoryId': 'd1', 'bedNumber': 'A3'}, // Kato Emmanuel (Male)
      's2': {'dormitoryId': 'd2', 'bedNumber': 'B1'}, // Nakamya Sarah (Female)
      's6': {'dormitoryId': 'd2', 'bedNumber': 'B2'}, // Nabatanzi Grace (Female)
      's10': {'dormitoryId': 'd2', 'bedNumber': 'B3'}, // Achieng Patricia (Female)
    };

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
    await _db.collection('stats').doc('attendance_summary').set({
      'totalStudents': _students.length,
      'studentsPresent': _students.length - 2,
      'studentsOnLeave': 2,
      'studentsIn': _students.length - 1,
      'studentsOut': 1,
      'updatedAt': Timestamp.fromDate(today),
    });

    // A night roll call from yesterday, so the matron dashboard has history.
    final yesterday = today.subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
    final batch = _db.batch();
    for (var studentId in allocations.keys) {
      final ref = _db.collection('attendance').doc(yesterday).collection('students').doc(studentId);
      batch.set(ref, {
        'studentId': studentId,
        'dormitoryId': allocations[studentId]!['dormitoryId'],
        'isPresent': studentId != 's10',
        'timestamp': Timestamp.fromDate(today.subtract(const Duration(days: 1, hours: -21))),
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
          'message': 'Tuition - Term 2, 2026 (UGX ${tuitionAmount.toStringAsFixed(0)}) is overdue. Please settle the balance.',
          'severity': 'warning',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
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
            'message': 'We have received UGX ${boardingAmount.toStringAsFixed(0)} for Boarding Fee - Term 2, 2026. Thank you!',
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
        'type': 'other',
        'responsiblePerson': 'Coach Okello',
      },
      {
        'title': "Parents' Visitation Day",
        'description': 'Parents are welcome to visit boarders and meet class teachers.',
        'date': now.add(const Duration(days: 14)),
        'type': 'general',
      },
      {
        'title': 'End of Term 2',
        'description': 'Last day of term; report cards issued.',
        'date': now.add(const Duration(days: 30)),
        'type': 'holiday',
      },
    ];

    for (var e in events) {
      await _db.collection('school_events').add({
        'title': e['title'],
        'description': e['description'],
        'date': Timestamp.fromDate(e['date'] as DateTime),
        'createdBy': 'System Administrator',
        'targetRoles': <String>[],
        'type': e['type'],
        'responsiblePerson': e['responsiblePerson'],
      });
    }
  }

  static Future<void> _seedLibraryBooks() async {
    final now = DateTime.now();
    final records = [
      {'studentId': 's1', 'title': 'Things Fall Apart', 'author': 'Chinua Achebe', 'due': 5, 'returned': false},
      {'studentId': 's3', 'title': 'Long Walk to Freedom', 'author': 'Nelson Mandela', 'due': 10, 'returned': false},
      {'studentId': 's5', 'title': 'The River Between', 'author': "Ngũgĩ wa Thiong'o", 'due': -3, 'returned': true},
      {'studentId': 's2', 'title': 'Weep Not, Child', 'author': "Ngũgĩ wa Thiong'o", 'due': -8, 'returned': true},
      {'studentId': 's7', 'title': 'So Long a Letter', 'author': 'Mariama Bâ', 'due': 3, 'returned': false},
      {'studentId': 's4', 'title': "Half of a Yellow Sun", 'author': 'Chimamanda Ngozi Adichie', 'due': -1, 'returned': true},
      {'studentId': 's9', 'title': 'Petals of Blood', 'author': "Ngũgĩ wa Thiong'o", 'due': 7, 'returned': false},
      {'studentId': 's6', 'title': "Nervous Conditions", 'author': 'Tsitsi Dangarembga', 'due': -15, 'returned': true},
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
    final visitors = [
      {'name': 'Mr. Kato Joseph', 'purpose': 'Visiting son (Mugisha Samuel)', 'entry': -180, 'exit': -30, 'status': 'Checked Out'},
      {'name': 'Delivery - Bantu Traders', 'purpose': 'Stationery delivery', 'entry': -1440, 'exit': -1400, 'status': 'Checked Out'},
      {'name': 'Mrs. Namukasa Mary', 'purpose': 'Fees payment', 'entry': -2880, 'exit': -2850, 'status': 'Checked Out'},
      {'name': 'Uganda Health Inspectorate', 'purpose': 'Routine health & safety inspection', 'entry': -4320, 'exit': -4200, 'status': 'Checked Out'},
      {'name': 'Mr. Ssemwanga Fred', 'purpose': 'Meeting class teacher', 'entry': -25, 'exit': null, 'status': 'Checked In'},
      {'name': 'Mrs. Achieng Grace', 'purpose': 'Picking up Kirabo Faith early', 'entry': -10, 'exit': null, 'status': 'Checked In'},
    ];

    for (var v in visitors) {
      await _db.collection('visitor_logs').add({
        'name': v['name'],
        'purpose': v['purpose'],
        'entryTime': Timestamp.fromDate(now.add(Duration(minutes: v['entry'] as int))),
        'exitTime': v['exit'] != null ? Timestamp.fromDate(now.add(Duration(minutes: v['exit'] as int))) : null,
        'status': v['status'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> _seedHealthVisits() async {
    final now = DateTime.now();
    final visits = [
      {'studentId': 's2', 'daysAgo': 2, 'reason': 'Headache', 'treatment': 'Paracetamol administered, rested in sick bay', 'medication': 'Paracetamol 500mg'},
      {'studentId': 's8', 'daysAgo': 5, 'reason': 'Malaria symptoms', 'treatment': 'Referred to Kampala Clinic', 'medication': 'Coartem'},
      {'studentId': 's6', 'daysAgo': 10, 'reason': 'Minor cut on knee', 'treatment': 'Wound cleaned and dressed', 'medication': 'Antiseptic ointment'},
      {'studentId': 's11', 'daysAgo': 1, 'reason': 'Stomach ache', 'treatment': 'Observed for 1 hour, resolved on its own', 'medication': 'None'},
      {'studentId': 's1', 'daysAgo': 20, 'reason': 'Allergic reaction - skin rash', 'treatment': 'Antihistamine given, parent notified', 'medication': 'Piriton'},
    ];

    for (var v in visits) {
      await _db.collection('health_visits').add({
        'studentId': v['studentId'],
        'date': Timestamp.fromDate(now.subtract(Duration(days: v['daysAgo'] as int))),
        'reason': v['reason'],
        'treatment': v['treatment'],
        'medication': v['medication'],
      });
    }
  }

  static Future<void> _seedInventory() async {
    final items = [
      {'id': 'inv1', 'name': 'Exercise Books', 'category': 'Stationery', 'quantity': 400, 'unit': 'Pieces', 'lowStockThreshold': 100},
      {'id': 'inv2', 'name': 'Whiteboard Markers', 'category': 'Stationery', 'quantity': 15, 'unit': 'Pieces', 'lowStockThreshold': 20},
      {'id': 'inv3', 'name': 'Football', 'category': 'Sports', 'quantity': 3, 'unit': 'Pieces', 'lowStockThreshold': 5},
      {'id': 'inv4', 'name': 'Desks', 'category': 'Furniture', 'quantity': 220, 'unit': 'Pieces', 'lowStockThreshold': 20},
      {'id': 'inv5', 'name': 'Printer Paper (Reams)', 'category': 'Stationery', 'quantity': 8, 'unit': 'Reams', 'lowStockThreshold': 10},
      {'id': 'inv6', 'name': 'First Aid Kits', 'category': 'Medical', 'quantity': 6, 'unit': 'Kits', 'lowStockThreshold': 4},
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
      {'itemId': 'inv1', 'itemName': 'Exercise Books', 'type': 'restock', 'quantity': 200, 'daysAgo': 14, 'note': 'Term 2 restock from Aristoc Suppliers'},
      {'itemId': 'inv2', 'itemName': 'Whiteboard Markers', 'type': 'issue', 'quantity': 10, 'daysAgo': 3, 'note': 'Issued to Primary 4-6 teachers'},
      {'itemId': 'inv5', 'itemName': 'Printer Paper (Reams)', 'type': 'issue', 'quantity': 5, 'daysAgo': 1, 'note': 'Issued to admin office for report printing'},
    ];

    for (var m in movements) {
      await _db.collection('inventory_movements').add({
        'itemId': m['itemId'],
        'itemName': m['itemName'],
        'type': m['type'],
        'quantity': m['quantity'],
        'date': Timestamp.fromDate(now.subtract(Duration(days: m['daysAgo'] as int))),
        'note': m['note'],
      });
    }
  }

  static Future<void> _seedDisciplineAndCounseling(String? counselorId) async {
    final now = DateTime.now();
    final incidents = [
      {'studentId': 's3', 'daysAgo': 10, 'description': 'Fighting with a classmate during break time', 'severity': 'error', 'punishment': 'Suspension'},
      {'studentId': 's7', 'daysAgo': 6, 'description': 'Repeatedly late to class', 'severity': 'warning', 'punishment': 'Verbal Warning'},
      {'studentId': 's9', 'daysAgo': 2, 'description': 'Disruptive behavior in class', 'severity': 'warning', 'punishment': ''},
    ];

    for (var inc in incidents) {
      await _db.collection('discipline_incidents').add({
        'studentId': inc['studentId'],
        'date': Timestamp.fromDate(now.subtract(Duration(days: inc['daysAgo'] as int))),
        'description': inc['description'],
        'severity': inc['severity'],
        'resolution': '',
        'counselingNotes': '',
        'punishment': inc['punishment'],
      });
    }

    final sessions = [
      {'studentId': 's3', 'daysAgo': 8, 'reason': 'Follow-up after fighting incident', 'notes': 'Student expressed frustration over bullying by peers.', 'recommendations': 'Weekly check-ins for a month.'},
    ];

    for (var s in sessions) {
      await _db.collection('counseling_sessions').add({
        'studentId': s['studentId'],
        'counselorId': counselorId ?? '',
        'date': Timestamp.fromDate(now.subtract(Duration(days: s['daysAgo'] as int))),
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
      {'email': 'bursar@gmail.com', 'name': 'Ms. Nalule Jane', 'base': 1100000.0},
      {'email': 'librarian@gmail.com', 'name': 'Mr. Wasswa Ivan', 'base': 700000.0},
      {'email': 'nurse@gmail.com', 'name': 'Dr. Musoke Peter', 'base': 950000.0},
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final idx = ((month - 1) % 12 + 12) % 12;
    return names[idx];
  }

  static Future<void> _seedTransport() async {
    final routes = [
      {'id': 'r1', 'name': 'Route A - Kansanga/Muyenga', 'busNumber': 'UBK 123A', 'driver': 'Mr. Ochieng Paul', 'studentCount': 18, 'status': 'Stationary'},
      {'id': 'r2', 'name': 'Route B - Ntinda/Kyambogo', 'busNumber': 'UBK 456B', 'driver': 'Mr. Kirunda James', 'studentCount': 22, 'status': 'Stationary'},
      {'id': 'r3', 'name': 'Route C - Entebbe Road', 'busNumber': 'UBK 789C', 'driver': 'Mr. Ssali Moses', 'studentCount': 15, 'status': 'En Route'},
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
      'startedAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 25))),
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
        {'mealType': 'Breakfast', 'menu': 'Porridge & Bread', 'time': '7:00 AM'},
        {'mealType': 'Lunch', 'menu': 'Posho, Beans & Greens', 'time': '1:00 PM'},
        {'mealType': 'Dinner', 'menu': 'Rice, Chicken Stew & Vegetables', 'time': '7:00 PM'},
      ],
      'tuesday': [
        {'mealType': 'Breakfast', 'menu': 'Tea & Mandazi', 'time': '7:00 AM'},
        {'mealType': 'Lunch', 'menu': 'Matooke, Groundnut Sauce', 'time': '1:00 PM'},
        {'mealType': 'Dinner', 'menu': 'Posho & Beef Stew', 'time': '7:00 PM'},
      ],
      'wednesday': [
        {'mealType': 'Breakfast', 'menu': 'Porridge & Sweet Potatoes', 'time': '7:00 AM'},
        {'mealType': 'Lunch', 'menu': 'Rice & Fish Stew', 'time': '1:00 PM'},
        {'mealType': 'Dinner', 'menu': 'Posho, Beans & Cabbage', 'time': '7:00 PM'},
      ],
      'thursday': [
        {'mealType': 'Breakfast', 'menu': 'Tea & Bread', 'time': '7:00 AM'},
        {'mealType': 'Lunch', 'menu': 'Matooke & Beef Stew', 'time': '1:00 PM'},
        {'mealType': 'Dinner', 'menu': 'Rice, Peas & Greens', 'time': '7:00 PM'},
      ],
      'friday': [
        {'mealType': 'Breakfast', 'menu': 'Porridge & Mandazi', 'time': '7:00 AM'},
        {'mealType': 'Lunch', 'menu': 'Posho & Groundnut Sauce', 'time': '1:00 PM'},
        {'mealType': 'Dinner', 'menu': 'Pilau & Chicken', 'time': '7:00 PM'},
      ],
      'saturday': [
        {'mealType': 'Breakfast', 'menu': 'Tea & Sweet Potatoes', 'time': '7:30 AM'},
        {'mealType': 'Lunch', 'menu': 'Rice & Beans', 'time': '1:00 PM'},
        {'mealType': 'Dinner', 'menu': 'Posho & Fish', 'time': '7:00 PM'},
      ],
      'sunday': [
        {'mealType': 'Breakfast', 'menu': 'Tea & Bread', 'time': '8:00 AM'},
        {'mealType': 'Lunch', 'menu': 'Pilau, Chicken & Salad', 'time': '1:30 PM'},
        {'mealType': 'Dinner', 'menu': 'Rice & Beef Stew', 'time': '7:00 PM'},
      ],
    };

    for (var entry in weekMenu.entries) {
      await _db.collection('meal_plans').doc(entry.key).set({'meals': entry.value});
    }

    await _db.collection('stats').doc('catering_summary').set({
      'mealsServedToday': 320,
      'studentsWithDietaryNeeds': 4,
    });
  }

  static Future<void> _seedGames() async {
    final houses = [
      {'id': 'h1', 'name': 'Red House', 'color': 'red', 'totalPoints': 120, 'houseMaster': 'Coach Okello'},
      {'id': 'h2', 'name': 'Blue House', 'color': 'blue', 'totalPoints': 145, 'houseMaster': 'Mr. Ochieng Paul'},
      {'id': 'h3', 'name': 'Green House', 'color': 'green', 'totalPoints': 98, 'houseMaster': 'Mrs. Nabatanzi Alice'},
      {'id': 'h4', 'name': 'Yellow House', 'color': 'yellow', 'totalPoints': 110, 'houseMaster': 'Mr. Kirunda James'},
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
      {'title': 'Inter-School Football Friendly', 'daysOffset': -20, 'venue': 'School Grounds', 'status': 'Completed'},
      {'title': 'Inter-House Sports Day', 'daysOffset': 7, 'venue': 'School Grounds', 'status': 'Planned'},
    ];

    for (var c in competitions) {
      await _db.collection('sports_competitions').add({
        'title': c['title'],
        'date': Timestamp.fromDate(now.add(Duration(days: c['daysOffset'] as int))),
        'venue': c['venue'],
        'status': c['status'],
      });
    }
  }

  static Future<void> _seedReligion() async {
    final now = DateTime.now();
    final activities = [
      {'title': 'Catholic Mass', 'daysOffset': -7, 'venue': 'School Chapel', 'category': 'Catholic'},
      {'title': "Friday Prayers (Jumu'ah)", 'daysOffset': -3, 'venue': 'Prayer Room', 'category': 'Muslim'},
      {'title': 'Inter-faith Prayer Day', 'daysOffset': 10, 'venue': 'Main Hall', 'category': 'Inter-faith'},
    ];

    for (var a in activities) {
      await _db.collection('religion_activities').add({
        'title': a['title'],
        'dateTime': Timestamp.fromDate(now.add(Duration(days: a['daysOffset'] as int))),
        'venue': a['venue'],
        'category': a['category'],
      });
    }

    final groups = [
      {'name': 'Catholic Fellowship', 'leader': 'Sheikh Juma', 'memberCount': 45},
      {'name': 'Muslim Students Association', 'leader': 'Sheikh Juma', 'memberCount': 20},
      {'name': 'Anglican Youth Fellowship', 'leader': 'Sheikh Juma', 'memberCount': 30},
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
      {'subject': 'Mathematics', 'className': 'Primary 6', 'daysOffset': 5, 'session': 'Morning'},
      {'subject': 'English', 'className': 'Primary 6', 'daysOffset': 6, 'session': 'Morning'},
      {'subject': 'Science', 'className': 'Primary 4', 'daysOffset': 8, 'session': 'Afternoon'},
      {'subject': 'Social Studies', 'className': 'Primary 5', 'daysOffset': 9, 'session': 'Morning'},
    ];

    for (var e in exams) {
      final date = now.add(Duration(days: e['daysOffset'] as int));
      await _db.collection('exams').add({
        'subject': e['subject'],
        'className': e['className'],
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'session': e['session'],
        'timestamp': Timestamp.fromDate(date),
      });
    }

    await _db.collection('stats').doc('exams_summary').set({
      'upcomingExams': exams.length,
      'termName': 'Term 2, 2026',
    });
  }

  static Future<void> seedAdmin() => seedFullData();
}
