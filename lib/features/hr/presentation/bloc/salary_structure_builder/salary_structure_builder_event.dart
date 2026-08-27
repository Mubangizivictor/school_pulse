import 'package:equatable/equatable.dart';
import '../../../domain/entities/salary_structure.dart';

abstract class SalaryStructureBuilderEvent extends Equatable {
  const SalaryStructureBuilderEvent();
  @override
  List<Object?> get props => [];
}

class SalaryStructuresSubscriptionRequested extends SalaryStructureBuilderEvent {
  final String schoolId;
  const SalaryStructuresSubscriptionRequested(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}

class SalaryStructuresUpdated extends SalaryStructureBuilderEvent {
  final List<SalaryStructure> structures;
  const SalaryStructuresUpdated(this.structures);
  @override
  List<Object?> get props => [structures];
}

class SalaryStructureArchiveRequested extends SalaryStructureBuilderEvent {
  final String schoolId;
  final String structureId;
  const SalaryStructureArchiveRequested({
    required this.schoolId,
    required this.structureId,
  });
  @override
  List<Object?> get props => [schoolId, structureId];
}

/// Publishes a brand-new structure, or (when [createNewVersion] is true) a
/// new version of an already-published structure with the same
/// [structureId]. Never mutates a published version's lines directly - the
/// callable is the only path that can create/update a version.
class SalaryStructurePublishRequested extends SalaryStructureBuilderEvent {
  final String schoolId;
  final String? structureId;
  final String designationId;
  final String name;
  final List<SalaryStructureLine> lines;
  final bool createNewVersion;

  const SalaryStructurePublishRequested({
    required this.schoolId,
    this.structureId,
    required this.designationId,
    required this.name,
    required this.lines,
    this.createNewVersion = false,
  });

  @override
  List<Object?> get props => [
    schoolId,
    structureId,
    designationId,
    name,
    lines,
    createNewVersion,
  ];
}
