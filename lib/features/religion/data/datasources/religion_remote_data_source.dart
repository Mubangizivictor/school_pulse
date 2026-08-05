import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/religion_models.dart';

abstract class ReligionRemoteDataSource {
  Future<List<ReligionActivityModel>> getUpcomingActivities();
  Future<List<SpiritualGroupModel>> getSpiritualGroups();
  Future<void> createActivity(ReligionActivityModel activity);
  Future<void> updateGroupMemberCount(String groupId, int count);
}

class ReligionRemoteDataSourceImpl implements ReligionRemoteDataSource {
  final FirebaseFirestore firestore;

  ReligionRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ReligionActivityModel>> getUpcomingActivities() async {
    final snapshot = await firestore
        .collection('religion_activities')
        .where(
          'dateTime',
          isGreaterThanOrEqualTo: DateTime.now().toIso8601String(),
        )
        .orderBy('dateTime')
        .get();
    return snapshot.docs
        .map((doc) => ReligionActivityModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<SpiritualGroupModel>> getSpiritualGroups() async {
    final snapshot = await firestore.collection('spiritual_groups').get();
    return snapshot.docs
        .map((doc) => SpiritualGroupModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> createActivity(ReligionActivityModel activity) async {
    await firestore.collection('religion_activities').add(activity.toJson());
  }

  @override
  Future<void> updateGroupMemberCount(String groupId, int count) async {
    await firestore.collection('spiritual_groups').doc(groupId).update({
      'memberCount': count,
    });
  }
}
