import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

/// Read-only bridge from Structure into the existing staff-account source of
/// truth. Structure defines roles/responsibilities; Auth/Admin owns accounts.
abstract class StructurePeopleReadinessRepository {
  Stream<List<UserEntity>> watchSchoolStaff(String schoolId);
}
