import 'package:equatable/equatable.dart';
import '../../domain/entities/security_entities.dart';

enum SecurityStatus { initial, loading, loaded, error }

/// A one-off success/error message for a mutating action (e.g. "Gate
/// created"). Deliberately NOT Equatable - each instance is compared by
/// identity, so [SecurityState]'s Equatable `props` sees it as a distinct
/// value on every emission (even for repeated text), letting a
/// BlocListener's `listenWhen` fire exactly once per action instead of being
/// swallowed by value-equality.
class SecurityFeedback {
  final String message;
  final bool isError;
  SecurityFeedback(this.message, {this.isError = false});
}

/// Single accumulating dashboard state. Gates/movements/incidents/etc. each
/// have their own live Firestore+Isar stream subscription in SecurityBloc;
/// every update merges into this one state via copyWith rather than
/// emitting a disjoint state subtype, so unrelated streams don't blank out
/// data the screen already loaded.
class SecurityState extends Equatable {
  final SecurityStatus status;
  final String? errorMessage;
  final Map<String, dynamic> stats;
  final List<Gate> gates;
  final List<StudentMovement> studentMovements;
  final List<StaffMovement> staffMovements;
  final List<SecurityIncident> incidents;
  final List<EmergencyEvent> activeEmergencies;
  final List<SecurityPatrol> patrols;
  final List<LostAndFoundItem> lostAndFound;
  final SecurityFeedback? feedback;

  const SecurityState({
    this.status = SecurityStatus.initial,
    this.errorMessage,
    this.stats = const {},
    this.gates = const [],
    this.studentMovements = const [],
    this.staffMovements = const [],
    this.incidents = const [],
    this.activeEmergencies = const [],
    this.patrols = const [],
    this.lostAndFound = const [],
    this.feedback,
  });

  SecurityState copyWith({
    SecurityStatus? status,
    String? errorMessage,
    Map<String, dynamic>? stats,
    List<Gate>? gates,
    List<StudentMovement>? studentMovements,
    List<StaffMovement>? staffMovements,
    List<SecurityIncident>? incidents,
    List<EmergencyEvent>? activeEmergencies,
    List<SecurityPatrol>? patrols,
    List<LostAndFoundItem>? lostAndFound,
    SecurityFeedback? feedback,
  }) {
    return SecurityState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      stats: stats ?? this.stats,
      gates: gates ?? this.gates,
      studentMovements: studentMovements ?? this.studentMovements,
      staffMovements: staffMovements ?? this.staffMovements,
      incidents: incidents ?? this.incidents,
      activeEmergencies: activeEmergencies ?? this.activeEmergencies,
      patrols: patrols ?? this.patrols,
      lostAndFound: lostAndFound ?? this.lostAndFound,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        stats,
        gates,
        studentMovements,
        staffMovements,
        incidents,
        activeEmergencies,
        patrols,
        lostAndFound,
        feedback,
      ];
}
