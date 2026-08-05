import 'package:equatable/equatable.dart';

abstract class SchoolDirectoryEvent extends Equatable {
  const SchoolDirectoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadDirectoryRequested extends SchoolDirectoryEvent {
  final String schoolId;

  const LoadDirectoryRequested({required this.schoolId});

  @override
  List<Object?> get props => [schoolId];
}
