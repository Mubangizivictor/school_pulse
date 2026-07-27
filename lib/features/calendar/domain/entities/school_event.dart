import 'package:equatable/equatable.dart';
import '../../../../core/user_roles.dart';

enum SchoolEventType { general, staffMeeting, exam, holiday, other }

class SchoolEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String createdBy;
  final List<UserRole> targetRoles;
  final SchoolEventType type;
  final String? responsiblePerson;

  const SchoolEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.createdBy,
    this.targetRoles = const [],
    this.type = SchoolEventType.general,
    this.responsiblePerson,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        createdBy,
        targetRoles,
        type,
        responsiblePerson,
      ];
}
