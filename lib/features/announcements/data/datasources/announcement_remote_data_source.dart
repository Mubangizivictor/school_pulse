import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';

abstract class AnnouncementRemoteDataSource {
  Future<List<AnnouncementModel>> getAnnouncements(String schoolId);
  Future<void> upsertAnnouncement(AnnouncementModel announcement);
  Future<void> deleteAnnouncement(String schoolId, String announcementId);
  Future<void> publishAnnouncement(String schoolId, String announcementId);
}

class AnnouncementRemoteDataSourceImpl implements AnnouncementRemoteDataSource {
  final FirebaseFirestore firestore;

  AnnouncementRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> _announcements(String schoolId) =>
      firestore.collection('schools').doc(schoolId).collection(
        'announcements',
      );

  @override
  Future<List<AnnouncementModel>> getAnnouncements(String schoolId) async {
    final snapshot = await _announcements(
      schoolId,
    ).orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => AnnouncementModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> upsertAnnouncement(AnnouncementModel announcement) async {
    final collection = _announcements(announcement.schoolId);
    if (announcement.id.isEmpty) {
      await collection.add(announcement.toFirestore());
    } else {
      await collection.doc(announcement.id).set(announcement.toFirestore());
    }
  }

  @override
  Future<void> deleteAnnouncement(
    String schoolId,
    String announcementId,
  ) async {
    await _announcements(schoolId).doc(announcementId).delete();
  }

  @override
  Future<void> publishAnnouncement(
    String schoolId,
    String announcementId,
  ) async {
    await _announcements(schoolId).doc(announcementId).update({
      'status': 'published',
      'publishedAt': Timestamp.fromDate(DateTime.now()),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
