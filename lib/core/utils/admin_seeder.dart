import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSeeder {
  static const String defaultPassword = "Password@123";

  static Future<void> deleteAllData() async {
    final collections = [
      'users', 'students', 'parent_access_codes', 'attendance',
      'academic_records', 'fees', 'payments', 'health_visits',
      'discipline_incidents', 'counseling_sessions', 'books',
      'borrowed_books', 'visitors', 'menus', 'games_activities',
      'exams', 'dorms', 'dorm_allocations', 'religious_activities',
      'alerts', 'system_config', 'inventory_items', 'inventory_movements',
      'lesson_plans', 'calendar_events', 'staff_attendance', 'audits'
    ];

    for (var collection in collections) {
      final snapshots = await FirebaseFirestore.instance.collection(collection).get();
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

      // 1. Seed Admin Account
      const adminEmail = "mubangizivic@gmail.com";
      UserCredential adminCred = await _getOrCreateUser(adminEmail, defaultPassword);

      await FirebaseFirestore.instance.collection('users').doc(adminCred.user!.uid).set({
        'id': adminCred.user!.uid,
        'name': 'System Administrator',
        'email': adminEmail,
        'role': 'schoolAdmin',
        'studentIds': [],
        'mustChangePassword': false,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Seed Students
      final students = [
        {'id': 's1', 'name': 'Mugisha Samuel', 'className': 'Primary 4', 'studentId': 'KHA/2023/001'},
        {'id': 's2', 'name': 'Nakamya Sarah', 'className': 'Primary 2', 'studentId': 'KHA/2023/045'},
        {'id': 's3', 'name': 'Okello John', 'className': 'Primary 6', 'studentId': 'KHA/2022/112'},
        {'id': 's4', 'name': 'Babirye Joy', 'className': 'Primary 4', 'studentId': 'KHA/2023/002'},
      ];

      for (var s in students) {
        await FirebaseFirestore.instance.collection('students').doc(s['id']).set(s);
      }

      // 3. Seed Parent Access Codes
      final codes = [
        {'code': 'KHA1234', 'studentIds': ['s1', 's4'], 'studentNames': ['Mugisha Samuel', 'Babirye Joy'], 'parentName': 'Mr. Kato Joseph'},
        {'code': 'KHA5678', 'studentIds': ['s2'], 'studentNames': ['Nakamya Sarah'], 'parentName': 'Mrs. Namukasa Mary'},
      ];

      for (var c in codes) {
        await FirebaseFirestore.instance.collection('parent_access_codes').doc(c['code'] as String).set(c);
      }

      // 4. Seed Staff Roles for testing different dashboards
      final staff = [
        {'name': 'Mr. Okot John', 'email': 'teacher@school.ug', 'role': 'classTeacher'},
        {'name': 'Ms. Nalule Jane', 'email': 'bursar@school.ug', 'role': 'bursar'},
        {'name': 'Dr. Musoke Peter', 'email': 'nurse@school.ug', 'role': 'nurse'},
        {'name': 'Mrs. Akello Mary', 'email': 'matron@school.ug', 'role': 'boardingMatron'},
        {'name': 'Mr. Sseba John', 'email': 'dean@school.ug', 'role': 'deanOfStudies'},
        {'name': 'Sheikh Juma', 'email': 'religion@school.ug', 'role': 'religiousLeader'},
        {'name': 'Mr. Otim David', 'email': 'exams@school.ug', 'role': 'examsOfficer'},
        {'name': 'Chef Kato', 'email': 'catering@school.ug', 'role': 'cateringManager'},
        {'name': 'Coach Okello', 'email': 'games@school.ug', 'role': 'gamesMaster'},
        {'name': 'Mr. Kateregga', 'email': 'security@school.ug', 'role': 'securityHead'},
        {'name': 'Ms. Nabirye', 'email': 'hr@school.ug', 'role': 'hrOfficer'},
      ];

      for (var st in staff) {
        await _seedStaffMember(st['name']!, st['email']!, st['role']!);
      }

      debugPrint("🏁 FULL SEEDING COMPLETE!");
    } catch (e) {
      debugPrint("❌ Seeding failed: $e");
    }
  }

  static Future<UserCredential> _getOrCreateUser(String email, String password) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } catch (_) {
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    }
  }

  static Future<void> _seedStaffMember(String name, String email, String role) async {
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

      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'id': cred.user!.uid,
        'name': name,
        'email': email,
        'role': role,
        'isActive': true,
        'mustChangePassword': false,
        'studentIds': [],
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      await tempApp.delete();
      debugPrint("✅ Seeded $role: $email");
    } catch (e) {
      debugPrint("⚠️ Skipping staff seed for $email: $e");
    }
  }

  static Future<void> seedAdmin() => seedFullData();
}
