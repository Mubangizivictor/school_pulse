import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
        'isActive': true,
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

      // 4. Seed Staff (Real Auth Accounts)
      final staff = [
        {'name': 'Mr. Okot John', 'email': 'teacher@school.ug', 'role': 'classTeacher'},
        {'name': 'Ms. Nalule Jane', 'email': 'bursar@school.ug', 'role': 'bursar'},
        {'name': 'Dr. Musoke Peter', 'email': 'nurse@school.ug', 'role': 'nurse'},
      ];

      for (var st in staff) {
        try {
          final existingStaff = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: st['email'])
              .get();

          if (existingStaff.docs.isNotEmpty) {
            debugPrint("⏩ Staff ${st['email']} already exists. Skipping Auth creation.");
            continue;
          }

          final tempAppName = 'seed_app_${st['role']}';
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
          late UserCredential cred;
          try {
            cred = await tempAuth.signInWithEmailAndPassword(email: st['email']!, password: "Test@123");
          } catch (_) {
            cred = await tempAuth.createUserWithEmailAndPassword(email: st['email']!, password: "Test@123");
          }

          await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
            'id': cred.user!.uid,
            'name': st['name'],
            'email': st['email'],
            'role': st['role'],
            'isActive': true,
            'mustChangePassword': true,
            'studentIds': [],
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          await tempApp.delete();
        } catch (e) {
          debugPrint("⚠️ Skipping staff seed for ${st['email']}: $e");
        }
      }
      debugPrint("✅ Staff seeded.");

      debugPrint("🏁 FULL SEEDING COMPLETE!");
    } catch (e) {
      debugPrint("❌ Seeding failed: $e");
    }
  }

  // Keeping old method for compatibility in main.dart
  static Future<void> seedAdmin() => seedFullData();
}
