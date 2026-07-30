import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/user_roles.dart';

/// The person a [ScanCredential] resolved to, scoped to just enough
/// information for the verification engine itself to make a decision.
/// Purpose-specific result models (built per module in later phases)
/// project only what that module's operators are allowed to see - this
/// type is never returned directly to a module's UI.
sealed class ResolvedIdentity extends Equatable {
  const ResolvedIdentity();
}

class StudentResolvedIdentity extends ResolvedIdentity {
  final String id;
  final String name;
  final String studentCode;
  final String classId;
  final String? photoUrl;

  const StudentResolvedIdentity({
    required this.id,
    required this.name,
    required this.studentCode,
    required this.classId,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, name, studentCode, classId, photoUrl];
}

class StaffResolvedIdentity extends ResolvedIdentity {
  final String id;
  final String name;
  final String? staffCode;
  final List<UserRole> roles;

  const StaffResolvedIdentity({
    required this.id,
    required this.name,
    this.staffCode,
    required this.roles,
  });

  @override
  List<Object?> get props => [id, name, staffCode, roles];
}

class ParentPickupResolvedIdentity extends ResolvedIdentity {
  final String parentCode;
  final String childId;
  final String childName;
  final String? parentName;
  final String? phoneNumber;

  const ParentPickupResolvedIdentity({
    required this.parentCode,
    required this.childId,
    required this.childName,
    this.parentName,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [parentCode, childId, childName, parentName, phoneNumber];
}

class UnresolvedResolvedIdentity extends ResolvedIdentity {
  final String reason;

  const UnresolvedResolvedIdentity({required this.reason});

  @override
  List<Object?> get props => [reason];
}
