import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

enum TaskStatus { pending, inProgress, completed, overdue }

class TaskChecklistItem {
  final String id;
  final String title;
  final bool isCompleted;

  TaskChecklistItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

class TaskAttachment {
  final String id;
  final String name;
  final String size;
  final String type;

  TaskAttachment({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
  });
}

class TaskEntity {
  final String id;
  final String title;
  final String category;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final String? dormitory;
  final String? assignedTo;
  final String? description;
  final List<TaskChecklistItem> checklist;
  final List<TaskAttachment> attachments;
  final String? location;
  final DateTime? completedAt;
  final String? completedBy;
  final String? notes;

  TaskEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.dueTime,
    this.dormitory,
    this.assignedTo,
    this.description,
    this.checklist = const [],
    this.attachments = const [],
    this.location,
    this.completedAt,
    this.completedBy,
    this.notes,
  });
}
