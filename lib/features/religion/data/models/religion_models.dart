import '../../domain/entities/religion_entities.dart';

class ReligionActivityModel extends ReligionActivity {
  const ReligionActivityModel({
    required super.id,
    required super.title,
    required super.dateTime,
    required super.venue,
    required super.category,
  });

  factory ReligionActivityModel.fromJson(Map<String, dynamic> json, String id) {
    return ReligionActivityModel(
      id: id,
      title: json['title'] ?? '',
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : DateTime.now(),
      venue: json['venue'] ?? '',
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'venue': venue,
      'category': category,
    };
  }
}

class SpiritualGroupModel extends SpiritualGroup {
  const SpiritualGroupModel({
    required super.id,
    required super.name,
    required super.leader,
    required super.memberCount,
  });

  factory SpiritualGroupModel.fromJson(Map<String, dynamic> json, String id) {
    return SpiritualGroupModel(
      id: id,
      name: json['name'] ?? '',
      leader: json['leader'] ?? '',
      memberCount: json['memberCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'leader': leader,
      'memberCount': memberCount,
    };
  }
}
