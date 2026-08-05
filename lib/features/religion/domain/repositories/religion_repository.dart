import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/religion_entities.dart';

abstract class ReligionRepository {
  Future<Either<Failure, List<ReligionActivity>>> getUpcomingActivities();
  Future<Either<Failure, List<SpiritualGroup>>> getSpiritualGroups();
  Future<Either<Failure, void>> createActivity(ReligionActivity activity);
  Future<Either<Failure, void>> updateGroupMemberCount(
    String groupId,
    int count,
  );
}
