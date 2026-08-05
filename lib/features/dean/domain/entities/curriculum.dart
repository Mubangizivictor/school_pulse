import 'package:equatable/equatable.dart';

class Curriculum extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String description;
  final List<Subject> subjects;
  final List<String> applicableLevels; // Kindergarten, Primary, etc.
  final AcademicCalendarConfig calendarConfig;

  const Curriculum({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.description,
    required this.subjects,
    required this.applicableLevels,
    required this.calendarConfig,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    description,
    subjects,
    applicableLevels,
    calendarConfig,
  ];
}

class AcademicCalendarConfig extends Equatable {
  final int termsPerYear;
  final List<String> termNames;
  final List<AssessmentWeighting> defaultWeighting;

  const AcademicCalendarConfig({
    required this.termsPerYear,
    required this.termNames,
    required this.defaultWeighting,
  });

  @override
  List<Object?> get props => [termsPerYear, termNames, defaultWeighting];
}

class AssessmentWeighting extends Equatable {
  final String type; // e.g., "CA1", "MidTerm", "EndTerm", "Project"
  final double weight; // Percentage

  const AssessmentWeighting({required this.type, required this.weight});

  @override
  List<Object?> get props => [type, weight];
}

class Subject extends Equatable {
  final String id;
  final String name;
  final String code;
  final String? department;
  final List<LearningObjective> objectives;
  final List<Topic> topics;
  final double currentCoverage; // Percentage

  const Subject({
    required this.id,
    required this.name,
    required this.code,
    this.department,
    required this.objectives,
    required this.topics,
    this.currentCoverage = 0.0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    department,
    objectives,
    topics,
    currentCoverage,
  ];
}

class LearningObjective extends Equatable {
  final String id;
  final String description;
  final bool isCore;

  const LearningObjective({
    required this.id,
    required this.description,
    this.isCore = true,
  });

  @override
  List<Object?> get props => [id, description, isCore];
}

class Topic extends Equatable {
  final String id;
  final String title;
  final List<SubTopic> subTopics;
  final int estimatedLessons;

  const Topic({
    required this.id,
    required this.title,
    required this.subTopics,
    required this.estimatedLessons,
  });

  @override
  List<Object?> get props => [id, title, subTopics, estimatedLessons];
}

class SubTopic extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const SubTopic({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [id, title, isCompleted];
}
