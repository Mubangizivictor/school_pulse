import 'package:equatable/equatable.dart';

class ReligionActivity extends Equatable {
  final String id;
  final String title;
  final DateTime dateTime;
  final String venue;
  final String
  category; // e.g., 'Catholic', 'Anglican', 'Muslim', 'SDA', 'Inter-faith'

  const ReligionActivity({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.venue,
    required this.category,
  });

  @override
  List<Object?> get props => [id, title, dateTime, venue, category];
}

class SpiritualGroup extends Equatable {
  final String id;
  final String name;
  final String leader;
  final int memberCount;

  const SpiritualGroup({
    required this.id,
    required this.name,
    required this.leader,
    required this.memberCount,
  });

  @override
  List<Object?> get props => [id, name, leader, memberCount];
}
