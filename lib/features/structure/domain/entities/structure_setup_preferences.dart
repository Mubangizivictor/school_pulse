import 'package:equatable/equatable.dart';

enum StructureUseChoice { undecided, enabled, disabled }

extension StructureUseChoiceX on StructureUseChoice {
  String get wireName => name;

  static StructureUseChoice fromWire(Object? value) {
    final raw = value?.toString();
    return StructureUseChoice.values.firstWhere(
      (choice) => choice.name == raw,
      orElse: () => StructureUseChoice.undecided,
    );
  }
}

/// Explicit answers to setup questions whose empty collections are ambiguous.
///
/// Example: an empty stream list can mean either "this school does not use
/// streams" or "streams have not been configured yet". The wizard must never
/// guess between those states, so the school records the decision here.
class StructureSetupPreferences extends Equatable {
  static const currentSetupVersion = 1;

  final StructureUseChoice departments;
  final StructureUseChoice streams;
  final StructureUseChoice rooms;
  final StructureUseChoice houses;
  final StructureUseChoice clubs;
  final StructureUseChoice boarding;
  final StructureUseChoice transport;
  final bool onboardingCompleted;
  final int setupVersion;
  final String lastStepId;

  const StructureSetupPreferences({
    this.departments = StructureUseChoice.undecided,
    this.streams = StructureUseChoice.undecided,
    this.rooms = StructureUseChoice.undecided,
    this.houses = StructureUseChoice.undecided,
    this.clubs = StructureUseChoice.undecided,
    this.boarding = StructureUseChoice.undecided,
    this.transport = StructureUseChoice.undecided,
    this.onboardingCompleted = false,
    this.setupVersion = currentSetupVersion,
    this.lastStepId = '',
  });

  StructureSetupPreferences copyWith({
    StructureUseChoice? departments,
    StructureUseChoice? streams,
    StructureUseChoice? rooms,
    StructureUseChoice? houses,
    StructureUseChoice? clubs,
    StructureUseChoice? boarding,
    StructureUseChoice? transport,
    bool? onboardingCompleted,
    int? setupVersion,
    String? lastStepId,
  }) {
    return StructureSetupPreferences(
      departments: departments ?? this.departments,
      streams: streams ?? this.streams,
      rooms: rooms ?? this.rooms,
      houses: houses ?? this.houses,
      clubs: clubs ?? this.clubs,
      boarding: boarding ?? this.boarding,
      transport: transport ?? this.transport,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      setupVersion: setupVersion ?? this.setupVersion,
      lastStepId: lastStepId ?? this.lastStepId,
    );
  }

  @override
  List<Object?> get props => [
        departments,
        streams,
        rooms,
        houses,
        clubs,
        boarding,
        transport,
        onboardingCompleted,
        setupVersion,
        lastStepId,
      ];
}
