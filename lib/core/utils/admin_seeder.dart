import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSeeder {
  static Future<void> seedFullData() async {
    try {
      debugPrint("🚀 Starting full data seeding...");

      // 1. Seed Admin Account
      const adminEmail = "mubangizivic@gmail.com";
      const adminPassword = "Test@123";
      
      UserCredential adminCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      ).catchError((_) => FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      ));

      await FirebaseFirestore.instance.collection('users').doc(adminCred.user!.uid).set({
        'id': adminCred.user!.uid,
        'name': 'System Administrator',
        'email': adminEmail,
        'role': 'schoolAdmin',
        'studentIds': [],
        'mustChangePassword': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint("✅ Admin seeded.");

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
      debugPrint("✅ Students seeded.");

      // 3. Seed Parent Access Codes
      final codes = [
        {
          'code': 'KHA1234',
          'studentIds': ['s1', 's4'],
          'studentNames': ['Mugisha Samuel', 'Babirye Joy'],
          'parentName': 'Mr. Kato Joseph'
        },
        {
          'code': 'KHA5678',
          'studentIds': ['s2'],
          'studentNames': ['Nakamya Sarah'],
          'parentName': 'Mrs. Namukasa Mary'
        },
      ];

      for (var c in codes) {
        await FirebaseFirestore.instance.collection('parent_access_codes').doc(c['code'] as String).set(c);
      }
      debugPrint("✅ Parent Access Codes seeded.");

      // 4. Seed some Staff (Firestore profiles only)
      // Note: Real staff need Auth accounts created via Admin panel, 
      // but we seed profiles so they show up in the Admin list.
      final staff = [
        {'id': 'st1', 'name': 'Mr. Okot John', 'email': 'teacher@school.ug', 'role': 'classTeacher', 'mustChangePassword': true},
        {'id': 'st2', 'name': 'Ms. Nalule Jane', 'email': 'bursar@school.ug', 'role': 'bursar', 'mustChangePassword': true},
        {'id': 'st3', 'name': 'Dr. Musoke Peter', 'email': 'nurse@school.ug', 'role': 'nurse', 'mustChangePassword': true},
      ];

      for (var st in staff) {
        await FirebaseFirestore.instance.collection('users').doc(st['id'] as String).set({
          ...st,
          'studentIds': [],
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      debugPrint("✅ Staff profiles seeded.");

      debugPrint("🏁 FULL SEEDING COMPLETE!");
    } catch (e) {
      debugPrint("❌ Seeding failed: $e");
    }
  }

  // Keeping old method for compatibility in main.dart
  static Future<void> seedAdmin() => seedFullData();
}
