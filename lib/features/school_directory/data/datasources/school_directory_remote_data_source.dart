import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/directory_contact_model.dart';

abstract class SchoolDirectoryRemoteDataSource {
  Future<List<DirectoryContactModel>> getContacts(String schoolId);
}

class SchoolDirectoryRemoteDataSourceImpl
    implements SchoolDirectoryRemoteDataSource {
  final FirebaseFirestore firestore;

  SchoolDirectoryRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<DirectoryContactModel>> getContacts(String schoolId) async {
    final snapshot = await firestore
        .collection('school_contacts')
        .where('schoolId', isEqualTo: schoolId)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => DirectoryContactModel.fromFirestore(doc))
        .toList();
  }
}
