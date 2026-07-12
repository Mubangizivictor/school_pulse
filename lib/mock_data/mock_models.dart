import 'package:school_pulse/core/enums/student_status.dart';

enum FeeStatus { paid, due, overdue }
enum Severity { info, success, warning, error }

class Parent {
  final String id;
  final String name;
  final List<String> studentIds;
  final String phoneNumber;
  final String accessCode;

  const Parent({
    required this.id,
    required this.name,
    required this.studentIds,
    required this.phoneNumber,
    required this.accessCode,
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
  final String teacherRemark;
  final double trend; // positive for up, negative for down

  const AcademicRecord({
    required this.studentId,
    required this.subject,
    required this.score,
    required this.grade,
    required this.term,
    required this.year,
    this.teacherRemark = '',
    this.trend = 0,
  });
}

class AttendanceRecord {
  final String studentId;
  final DateTime date;
  final StudentStatus status;
  final String note;

  const AttendanceRecord({
    required this.studentId,
    required this.date,
    required this.status,
    this.note = '',
  });
}

class FeeItem {
  final String id;
  final String studentId;
  final String category;
  final double amount;
  final FeeStatus status;
  final DateTime dueDate;

  const FeeItem({
    required this.id,
    required this.studentId,
    required this.category,
    required this.amount,
    required this.status,
    required this.dueDate,
  });
}

class PaymentRecord {
  final String id;
  final String studentId;
  final double amount;
  final DateTime date;
  final String method; // MTN MoMo, Airtel Money, Cash
  final String reference;

  const PaymentRecord({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.date,
    required this.method,
    required this.reference,
  });
}

class HealthVisit {
  final String id;
  final String studentId;
  final DateTime date;
  final String reason;
  final String treatment;
  final String medication;

  const HealthVisit({
    required this.id,
    required this.studentId,
    required this.date,
    required this.reason,
    required this.treatment,
    required this.medication,
  });
}

class LibraryBook {
  final String id;
  final String studentId;
  final String title;
  final String author;
  final DateTime dueDate;
  final bool isReturned;

  const LibraryBook({
    required this.id,
    required this.studentId,
    required this.title,
    required this.author,
    required this.dueDate,
    this.isReturned = false,
  });
}

class DisciplineIncident {
  final String id;
  final String studentId;
  final DateTime date;
  final String description;
  final Severity severity;
  final String resolution;
  final String counselingNotes;

  const DisciplineIncident({
    required this.id,
    required this.studentId,
    required this.date,
    required this.description,
    required this.severity,
    required this.resolution,
    required this.counselingNotes,
  });
}

class TransportInfo {
  final String studentId;
  final String routeName;
  final String stopName;
  final String status; // At School, On Route, Dropped Off

  const TransportInfo({
    required this.studentId,
    required this.routeName,
    required this.stopName,
    required this.status,
  });
}

class ChatMessage {
  final String id;
  final String threadId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });
}

class ChatThread {
  final String id;
  final String participantName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isAnnouncement;

  const ChatThread({
    required this.id,
    required this.participantName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isAnnouncement = false,
  });
}
