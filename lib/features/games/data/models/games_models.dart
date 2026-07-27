import '../../domain/entities/games_entities.dart';

class SportsHouseModel extends SportsHouse {
  const SportsHouseModel({
    required super.id,
    required super.name,
    required super.color,
    required super.totalPoints,
    required super.houseMaster,
  });

  factory SportsHouseModel.fromJson(Map<String, dynamic> json, String id) {
    return SportsHouseModel(
      id: id,
      name: json['name'] ?? '',
      color: json['color'] ?? '#808080',
      totalPoints: json['totalPoints'] ?? 0,
      houseMaster: json['houseMaster'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
      'totalPoints': totalPoints,
      'houseMaster': houseMaster,
    };
  }
}

class SportsCompetitionModel extends SportsCompetition {
  const SportsCompetitionModel({
    required super.id,
    required super.title,
    required super.date,
    required super.venue,
    required super.status,
  });

  factory SportsCompetitionModel.fromJson(Map<String, dynamic> json, String id) {
    return SportsCompetitionModel(
      id: id,
      title: json['title'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      venue: json['venue'] ?? '',
      status: json['status'] ?? 'Planned',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'venue': venue,
      'status': status,
    };
  }
}
