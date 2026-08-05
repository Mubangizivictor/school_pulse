import 'package:equatable/equatable.dart';

enum AnnouncementStatus { draft, published }

class AnnouncementEntity extends Equatable {
  final String id;
  final String schoolId;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final AnnouncementStatus status;
  final List<String> audienceRoles;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  const AnnouncementEntity({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    this.status = AnnouncementStatus.draft,
    this.audienceRoles = const [],
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  AnnouncementEntity copyWith({
    String? id,
    String? schoolId,
    String? title,
    String? body,
    String? authorId,
    String? authorName,
    AnnouncementStatus? status,
    List<String>? audienceRoles,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    bool clearPublishedAt = false,
  }) {
    return AnnouncementEntity(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      title: title ?? this.title,
      body: body ?? this.body,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      status: status ?? this.status,
      audienceRoles: audienceRoles ?? this.audienceRoles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: clearPublishedAt ? null : (publishedAt ?? this.publishedAt),
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    title,
    body,
    authorId,
    authorName,
    status,
    audienceRoles,
    createdAt,
    updatedAt,
    publishedAt,
  ];
}
