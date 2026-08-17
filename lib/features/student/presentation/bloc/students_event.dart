import 'package:equatable/equatable.dart';

abstract class StudentsEvent extends Equatable {
  const StudentsEvent();

  @override
  List<Object> get props => [];
}

class SearchStudents extends StudentsEvent {
  final String query;
  const SearchStudents(this.query);

  @override
  List<Object> get props => [query];
}

/// Loads the complete roster for one school. This is intentionally separate
/// from [FetchStudents], which is the narrow "these known student ids" path
/// used by parent/relationship projections.
class LoadSchoolStudents extends StudentsEvent {
  final String schoolId;
  const LoadSchoolStudents(this.schoolId);

  @override
  List<Object> get props => [schoolId];
}

class FetchStudents extends StudentsEvent {
  final List<String> studentIds;
  const FetchStudents(this.studentIds);

  @override
  List<Object> get props => [studentIds];
}
