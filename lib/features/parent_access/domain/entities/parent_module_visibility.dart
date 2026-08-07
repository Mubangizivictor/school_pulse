import 'package:equatable/equatable.dart';

/// Resolved answer to "what can this parent see for this child, right now."
///
/// One instance is produced per (relationship, institution policy, feature
/// toggles) combination by [ParentModuleResolver]. Every parent-facing nav
/// surface (quick-action grid, bottom nav, more-menu, router guards) reads
/// this instead of hardcoding "show everything" - see
/// ParentModuleResolver's doc comment for why relationship type alone isn't
/// enough to decide visibility.
class ParentModuleVisibility extends Equatable {
  final bool academics;
  final bool reportCard;
  final bool attendance;
  final bool fees;
  final bool health;
  final bool transport;
  final bool library;
  final bool discipline;
  final bool boarding;
  final bool messages;
  final bool appointments;
  final bool digitalId;

  // Always available regardless of relationship access flags - self-service
  // account surfaces, not student-data access.
  final bool profile;
  final bool notifications;
  final bool security;

  const ParentModuleVisibility({
    this.academics = false,
    this.reportCard = false,
    this.attendance = false,
    this.fees = false,
    this.health = false,
    this.transport = false,
    this.library = false,
    this.discipline = false,
    this.boarding = false,
    this.messages = false,
    this.appointments = false,
    this.digitalId = false,
    this.profile = true,
    this.notifications = true,
    this.security = true,
  });

  /// Suspended/revoked/superseded relationships and unresolved states land
  /// here: nothing student-scoped, only the parent's own account surfaces.
  static const none = ParentModuleVisibility();

  @override
  List<Object?> get props => [
    academics,
    reportCard,
    attendance,
    fees,
    health,
    transport,
    library,
    discipline,
    boarding,
    messages,
    appointments,
    digitalId,
    profile,
    notifications,
    security,
  ];
}
