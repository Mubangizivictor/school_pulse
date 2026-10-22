import 'package:equatable/equatable.dart';

/// Master switches for which optional modules this school has enabled.
/// A single per-school document, edited from the Structure module's
/// Feature Toggles tab. Other features may read this to decide whether to
/// show themselves in navigation - this module only owns the switches
/// themselves, it does not reach into other features to hide their UI.
class FeatureToggles extends Equatable {
  final bool transport;
  final bool hostel;
  final bool library;
  final bool medical;
  final bool visitors;
  final bool inventory;
  final bool payroll;
  final bool procurement;
  final bool alumni;
  final bool communication;
  final bool boarding;
  final bool qrAttendance;
  final bool digitalIds;
  final bool parentPortal;
  final bool studentPortal;

  const FeatureToggles({
    this.transport = true,
    this.hostel = true,
    this.library = true,
    this.medical = true,
    this.visitors = true,
    this.inventory = true,
    this.payroll = true,
    this.procurement = true,
    this.alumni = false,
    this.communication = true,
    this.boarding = true,
    this.qrAttendance = true,
    this.digitalIds = true,
    this.parentPortal = true,
    this.studentPortal = true,
  });

  /// Every module off - used to render an unconfigured school's Feature
  /// Choices setup screen without relying on this class's `true` defaults,
  /// which exist only for backward compatibility with older navigation code
  /// reading an empty document, not as a claim that these are genuinely
  /// enabled.
  const FeatureToggles.allOff()
    : transport = false,
      hostel = false,
      library = false,
      medical = false,
      visitors = false,
      inventory = false,
      payroll = false,
      procurement = false,
      alumni = false,
      communication = false,
      boarding = false,
      qrAttendance = false,
      digitalIds = false,
      parentPortal = false,
      studentPortal = false;

  FeatureToggles copyWith({
    bool? transport,
    bool? hostel,
    bool? library,
    bool? medical,
    bool? visitors,
    bool? inventory,
    bool? payroll,
    bool? procurement,
    bool? alumni,
    bool? communication,
    bool? boarding,
    bool? qrAttendance,
    bool? digitalIds,
    bool? parentPortal,
    bool? studentPortal,
  }) {
    return FeatureToggles(
      transport: transport ?? this.transport,
      hostel: hostel ?? this.hostel,
      library: library ?? this.library,
      medical: medical ?? this.medical,
      visitors: visitors ?? this.visitors,
      inventory: inventory ?? this.inventory,
      payroll: payroll ?? this.payroll,
      procurement: procurement ?? this.procurement,
      alumni: alumni ?? this.alumni,
      communication: communication ?? this.communication,
      boarding: boarding ?? this.boarding,
      qrAttendance: qrAttendance ?? this.qrAttendance,
      digitalIds: digitalIds ?? this.digitalIds,
      parentPortal: parentPortal ?? this.parentPortal,
      studentPortal: studentPortal ?? this.studentPortal,
    );
  }

  @override
  List<Object?> get props => [
    transport,
    hostel,
    library,
    medical,
    visitors,
    inventory,
    payroll,
    procurement,
    alumni,
    communication,
    boarding,
    qrAttendance,
    digitalIds,
    parentPortal,
    studentPortal,
  ];
}
