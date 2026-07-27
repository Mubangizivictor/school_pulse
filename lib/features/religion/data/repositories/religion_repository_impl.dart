import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/religion_entities.dart';
import '../../domain/repositories/religion_repository.dart';
import '../datasources/religion_remote_data_source.dart';
import '../models/religion_models.dart';

class ReligionRepositoryImpl implements ReligionRepository {
  final ReligionRemoteDataSource remoteDataSource;

  ReligionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ReligionActivity>>> getUpcomingActivities() async {
    try {
      final activities = await remoteDataSource.getUpcomingActivities();
      return Right(activities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SpiritualGroup>>> getSpiritualGroups() async {
    try {
      final groups = await remoteDataSource.getSpiritualGroups();
      return Right(groups);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createActivity(ReligionActivity activity) async {
    try {
      final model = ReligionActivityModel(
        id: activity.id,
        title: activity.title,
        dateTime: activity.dateTime,
        venue: activity.venue,
        category: activity.category,
      );
      await remoteDataSource.createActivity(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateGroupMemberCount(String groupId, int count) async {
    try {
      await remoteDataSource.updateGroupMemberCount(groupId, count);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
