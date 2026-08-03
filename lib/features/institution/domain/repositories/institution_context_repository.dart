import 'package:school_pulse/features/institution/domain/entities/institution_context.dart';

abstract class InstitutionContextRepository {
  Future<InstitutionContext> loadContext(String institutionId);
  Stream<InstitutionContext> watchContext(String institutionId);
}
