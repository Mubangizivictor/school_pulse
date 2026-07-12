import 'package:cloud_firestore/cloud_firestore.dart';

class StaffAlert {
  final String id;
  final String title;
  final String body;
  final String type;
  final List<String> targets;
  final String? userId;
  final DateTime timestamp;
  final List<String> readBy;

  StaffAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.targets,
    this.userId,
    required this.timestamp,
    required this.readBy,
  });

  bool isReadBy(String uid) => readBy.contains(uid);

  factory StaffAlert.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return StaffAlert(
      id: doc.id,
      title: data['title'] as String? ?? 'Notification',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ??
          (data['userId'] != null ? 'Direct' : 'Push'),
      targets: List<String>.from(data['targets'] as List? ?? const []),
      userId: data['userId'] as String?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(data['readBy'] as List? ?? const []),
    );
  }
}
