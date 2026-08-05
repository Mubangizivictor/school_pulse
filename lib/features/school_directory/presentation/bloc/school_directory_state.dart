import 'package:equatable/equatable.dart';
import '../../domain/entities/directory_contact_entity.dart';

abstract class SchoolDirectoryState extends Equatable {
  const SchoolDirectoryState();

  @override
  List<Object?> get props => [];
}

class SchoolDirectoryInitial extends SchoolDirectoryState {}

class SchoolDirectoryLoading extends SchoolDirectoryState {}

class SchoolDirectoryLoaded extends SchoolDirectoryState {
  final List<DirectoryContactEntity> contacts;

  const SchoolDirectoryLoaded({required this.contacts});

  @override
  List<Object?> get props => [contacts];
}

class SchoolDirectoryError extends SchoolDirectoryState {
  final String message;
  const SchoolDirectoryError(this.message);

  @override
  List<Object?> get props => [message];
}
