import 'package:cloud_firestore/cloud_firestore.dart';

abstract class VisitorRemoteDataSource {
  Future<List<Map<String, dynamic>>> getVisitors(String schoolId);
  Future<void> syncVisitor(Map<String, dynamic> visitorData);
  Future<List<Map<String, dynamic>>> getBlacklist(String schoolId);
  Future<List<Map<String, dynamic>>> getPreApprovedVisitors(String schoolId);
  Future<void> markPreApprovedAsUsed(String preApprovedId);
  Future<void> addToBlacklist(Map<String, dynamic> blacklistData);

  // Enterprise features
  Future<List<Map<String, dynamic>>> getScheduledVisits(String schoolId);
  Future<void> updateScheduledVisit(String visitId, Map<String, dynamic> data);
  Future<void> syncPackageDelivery(Map<String, dynamic> deliveryData);
  Future<List<Map<String, dynamic>>> getPackageDeliveries(String schoolId);
}

class VisitorRemoteDataSourceImpl implements VisitorRemoteDataSource {
  final FirebaseFirestore firestore;

  VisitorRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<Map<String, dynamic>>> getVisitors(String schoolId) async {
    final snapshot = await firestore
        .collection('visitors')
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('arrivalTime', descending: true)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  @override
  Future<void> syncVisitor(Map<String, dynamic> visitorData) async {
    final id = visitorData['id'];
    final data = Map<String, dynamic>.from(visitorData)..remove('id');
    await firestore
        .collection('visitors')
        .doc(id)
        .set(data, SetOptions(merge: true));
  }

  @override
  Future<List<Map<String, dynamic>>> getBlacklist(String schoolId) async {
    final snapshot = await firestore
        .collection('visitor_blacklist')
        .where('schoolId', isEqualTo: schoolId)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getPreApprovedVisitors(
    String schoolId,
  ) async {
    final snapshot = await firestore
        .collection('pre_approved_visitors')
        .where('schoolId', isEqualTo: schoolId)
        .where('isUsed', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  @override
  Future<void> markPreApprovedAsUsed(String preApprovedId) async {
    await firestore
        .collection('pre_approved_visitors')
        .doc(preApprovedId)
        .update({'isUsed': true});
  }

  @override
  Future<void> addToBlacklist(Map<String, dynamic> blacklistData) async {
    final id = blacklistData['id'];
    final data = Map<String, dynamic>.from(blacklistData)..remove('id');
    await firestore.collection('visitor_blacklist').doc(id).set(data);
  }

  @override
  Future<List<Map<String, dynamic>>> getScheduledVisits(String schoolId) async {
    final snapshot = await firestore
        .collection('scheduled_visits')
        .where('schoolId', isEqualTo: schoolId)
        .where('isCheckedIn', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  @override
  Future<void> updateScheduledVisit(
    String visitId,
    Map<String, dynamic> data,
  ) async {
    await firestore.collection('scheduled_visits').doc(visitId).update(data);
  }

  @override
  Future<void> syncPackageDelivery(Map<String, dynamic> deliveryData) async {
    final id = deliveryData['id'];
    final data = Map<String, dynamic>.from(deliveryData)..remove('id');
    await firestore
        .collection('package_deliveries')
        .doc(id)
        .set(data, SetOptions(merge: true));
  }

  @override
  Future<List<Map<String, dynamic>>> getPackageDeliveries(
    String schoolId,
  ) async {
    final snapshot = await firestore
        .collection('package_deliveries')
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('arrivalTime', descending: true)
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }
}
