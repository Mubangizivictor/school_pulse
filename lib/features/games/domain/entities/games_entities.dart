import 'package:equatable/equatable.dart';

class SportsHouse extends Equatable {
  final String id;
  final String name;
  final String color;
  final int totalPoints;
  final String houseMaster;

  const SportsHouse({
    required this.id,
    required this.name,
    required this.color,
    required this.totalPoints,
    required this.houseMaster,
  });

  @override
  List<Object?> get props => [id, name, color, totalPoints, houseMaster];
}

class SportsCompetition extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final String venue;
  final String status; // Planned, Ongoing, Completed

  const SportsCompetition({
    required this.id,
    required this.title,
    required this.date,
    required this.venue,
    required this.status,
  });

  @override
  List<Object?> get props => [id, title, date, venue, status];
}
