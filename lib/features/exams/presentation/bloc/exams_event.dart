import 'package:equatable/equatable.dart';

abstract class ExamsEvent extends Equatable {
  const ExamsEvent();

  @override
  List<Object?> get props => [];
}

class ExamsDashboardRequested extends ExamsEvent {}
