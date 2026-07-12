import 'package:equatable/equatable.dart';

class ClassProgress extends Equatable {
  final String title;
  final double progress;
  final String subtitle;

  const ClassProgress({
    required this.title,
    required this.progress,
    required this.subtitle,
  });

  @override
  List<Object?> get props => [title, progress, subtitle];
}

class TeacherDashboardStats extends Equatable {
  final int studentsToday;
  final int totalStudents;
  final int submissionsDue;
  final int classesToday;
  final int activeNotifications;
  final List<ClassProgress> classProgress;

  const TeacherDashboardStats({
    required this.studentsToday,
    required this.totalStudents,
    required this.submissionsDue,
    required this.classesToday,
    required this.activeNotifications,
    required this.classProgress,
  });

  @override
  List<Object?> get props => [
        studentsToday,
        totalStudents,
        submissionsDue,
        classesToday,
        activeNotifications,
        classProgress,
      ];
}
