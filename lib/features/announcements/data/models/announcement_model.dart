import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/announcements/domain/entities/announcement_entity.dart';

class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.schoolId,
    required super.title,
    required super.body,
    required super.authorId,
    required super.authorName,
    super.status,
    super.audienceRoles,
    required super.createdAt,
    required super.updatedAt,
    super.publishedAt,
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      schoolId: data['schoolId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      status: AnnouncementStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => AnnouncementStatus.draft,
      ),
      audienceRoles: List<String>.from(data['audienceRoles'] ?? const []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'title': title,
      'body': body,
      'authorId': authorId,
      'authorName': authorName,
      'status': status.name,
      'audienceRoles': audienceRoles,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'publishedAt': publishedAt != null
          ? Timestamp.fromDate(publishedAt!)
          : null,
    };
  }

  factory AnnouncementModel.fromEntity(AnnouncementEntity entity) {
    return AnnouncementModel(
      id: entity.id,
      schoolId: entity.schoolId,
      title: entity.title,
      body: entity.body,
      authorId: entity.authorId,
      authorName: entity.authorName,
      status: entity.status,
      audienceRoles: entity.audienceRoles,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      publishedAt: entity.publishedAt,
    );
  }
}
