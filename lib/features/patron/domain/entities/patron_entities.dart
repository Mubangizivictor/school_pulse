import 'package:equatable/equatable.dart';

class Dormitory extends Equatable {
  final String id;
  final String name;
  final int capacity;
  final int occupantCount;
  final String? roomLeaderId;
  final String? roomLeaderName;

  const Dormitory({
    required this.id,
    required this.name,
    required this.capacity,
    required this.occupantCount,
    this.roomLeaderId,
    this.roomLeaderName,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    capacity,
    occupantCount,
    roomLeaderId,
    roomLeaderName,
  ];
}

class BoardingStudent extends Equatable {
  final String id;
  final String name;
  final String? dormitoryId;
  final String? dormitoryName;
  final String? bedNumber;
  final String status; // 'Present', 'Leave', 'Sick', etc.
  final String? photoUrl;
  final String studentClass;

  const BoardingStudent({
    required this.id,
    required this.name,
    this.dormitoryId,
    this.dormitoryName,
    this.bedNumber,
    this.status = 'Present',
    this.photoUrl,
    required this.studentClass,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    dormitoryId,
    dormitoryName,
    bedNumber,
    status,
    photoUrl,
    studentClass,
  ];
}

class BoardingAttendance extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String dormitoryId;
  final DateTime date;
  final String type; // 'Morning', 'Evening', 'Weekend'
  final String status; // 'Present', 'Absent', 'Leave', 'Sick'
  final String? remarks;
  final String recordedBy;

  const BoardingAttendance({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.dormitoryId,
    required this.date,
    required this.type,
    required this.status,
    this.remarks,
    required this.recordedBy,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    dormitoryId,
    date,
    type,
    status,
    remarks,
    recordedBy,
  ];
}

class WelfareRecord extends Equatable {
  final String id;
  final String schoolId;
  final String studentId;
  final String studentName;
  final String category; // 'Concern', 'Counseling', 'Check-up', 'Observation'
  final String note;
  final DateTime date;
  final String recordedBy;
  final bool isPrivate;

  const WelfareRecord({
    required this.id,
    this.schoolId = '',
    required this.studentId,
    required this.studentName,
    required this.category,
    required this.note,
    required this.date,
    required this.recordedBy,
    this.isPrivate = false,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    studentId,
    studentName,
    category,
    note,
    date,
    recordedBy,
    isPrivate,
  ];
}

class DisciplineIncident extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String description;
  final String category;
  final String actionTaken;
  final DateTime date;
  final String status; // 'Pending', 'Resolved', 'Follow-up'
  final String recordedBy;

  const DisciplineIncident({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.description,
    required this.category,
    required this.actionTaken,
    required this.date,
    required this.status,
    required this.recordedBy,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    description,
    category,
    actionTaken,
    date,
    status,
    recordedBy,
  ];
}

class BoardingAnnouncement extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String authorName;
  final String? targetDormitoryId; // Optional: specific dorm or all

  const BoardingAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.authorName,
    this.targetDormitoryId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    date,
    authorName,
    targetDormitoryId,
  ];
}
