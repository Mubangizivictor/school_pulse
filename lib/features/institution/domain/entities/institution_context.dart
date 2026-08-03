import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';

/// Single source of truth for the currently active institution tenant.
/// Loaded once after authentication and consumed by routing and feature
/// blocs - individual modules must not build their own tenant context.
class InstitutionContext extends Equatable {
  final String institutionId;
  final String displayLabel;
  final InstitutionClassification classification;
  final List<InstitutionDivision> divisions;
  final SchoolStatus status;
  final List<String> enabledFeatures;
  final DateTime loadedAt;
  final bool isOfflineCached;

  const InstitutionContext({
    required this.institutionId,
    required this.displayLabel,
    required this.classification,
    required this.divisions,
    required this.status,
    required this.enabledFeatures,
    required this.loadedAt,
    this.isOfflineCached = false,
  });

  factory InstitutionContext.fromSchool(
    School school, {
    bool isOfflineCached = false,
  }) {
    return InstitutionContext(
      institutionId: school.id,
      displayLabel: school.displayLabel ?? school.name,
      classification: school.classification,
      divisions: school.divisions,
      status: school.status,
      enabledFeatures: school.enabledFeatures,
      loadedAt: DateTime.now(),
      isOfflineCached: isOfflineCached,
    );
  }

  bool get isSuspended =>
      status == SchoolStatus.suspended || status == SchoolStatus.archived;

  bool get requiresMfa => enabledFeatures.contains('mfa_required');

  @override
  List<Object?> get props => [
        institutionId,
        displayLabel,
        classification,
        divisions,
        status,
        enabledFeatures,
        loadedAt,
        isOfflineCached,
      ];
}
