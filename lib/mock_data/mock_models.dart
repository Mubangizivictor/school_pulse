import 'package:flutter/material.dart';

enum StudentStatus { present, absent, late }
enum FeeStatus { paid, due, overdue }
enum Severity { info, success, warning, error }

class Student {
  final String id;
  final String name;
  final String className;
  final String studentId;
  final String? photoUrl;

  const Student({
    required this.id,
    required this.name,
    required this.className,
    required this.studentId,
    this.photoUrl,
  });
}

class Parent {
  final String id;
  final String name;
  final List<String> studentIds;
  final String phoneNumber;

  const Parent({
    required this.id,
    required this.name,
    required this.studentIds,
    required this.phoneNumber,
  });
}

class Alert {
  final String id;
  final String title;
  final String message;
  final Severity severity;
  final DateTime timestamp;

  const Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
  });
}

class AcademicRecord {
  final String studentId;
  final String subject;
  final double score;
  final String grade;
  final String term;
  final String year;

  const AcademicRecord({
    required this.studentId,
    required this.subject,
    required this.score,
    required this.grade,
    required this.term,
    required this.year,
  });
}
