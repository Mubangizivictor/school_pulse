import 'package:equatable/equatable.dart';

/// One subject taught in a class, as the Class Teacher panel's subject
/// picker needs it: an id to scope marks-entry queries by, and a name to
/// show. Nothing about who teaches it - that is the Subject Teacher's own
/// assignment, irrelevant to a Class Teacher marking on their behalf.
class ClassSubject extends Equatable {
  final String id;
  final String name;

  const ClassSubject({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
