import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Resolves the current School Pulse tenant without allowing callers to guess
/// or manually inject another school's id in production paths.
class StructureTenantResolver {
  final FirebaseFirestore firestore;
  final FirebaseAuth? auth;
  final String? schoolIdOverride;

  const StructureTenantResolver({
    required this.firestore,
    this.auth,
    this.schoolIdOverride,
  });

  Future<String> resolve() async {
    final override = schoolIdOverride?.trim() ?? '';
    if (override.isNotEmpty) return override;

    final uid = (auth ?? FirebaseAuth.instance).currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError(
        'An authenticated user is required for School Structure.',
      );
    }

    final doc = await firestore.collection('users').doc(uid).get();
    final schoolId = doc.data()?['schoolId']?.toString().trim() ?? '';
    if (schoolId.isEmpty) {
      throw StateError('The authenticated user is not linked to a school.');
    }
    return schoolId;
  }
}
