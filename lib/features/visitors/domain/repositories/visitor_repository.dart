import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/visitor.dart';
import '../entities/visitor_blacklist.dart';
import '../entities/pre_approved_visitor.dart';
import '../entities/scheduled_visit.dart';
import '../entities/package_delivery.dart';

abstract class VisitorRepository {
  Future<Either<Failure, List<Visitor>>> getVisitors(String schoolId);
  Future<Either<Failure, Visitor>> checkInVisitor(Visitor visitor);
  Future<Either<Failure, Visitor>> checkOutVisitor(String visitorId, DateTime departureTime, String duration);
  Future<Either<Failure, List<Visitor>>> searchVisitors(String schoolId, String query);
  
  Future<Either<Failure, List<VisitorBlacklist>>> getBlacklist();
  Future<Either<Failure, void>> addToBlacklist(VisitorBlacklist blacklist);
  
  Future<Either<Failure, List<PreApprovedVisitor>>> getPreApprovedVisitors(String schoolId);
  Future<Either<Failure, void>> markPreApprovedAsUsed(String preApprovedId);
  Future<Either<Failure, void>> syncPendingRecords();
  
  Stream<List<Visitor>> watchVisitors(String schoolId);

  // Enterprise additions
  Future<Either<Failure, List<Visitor>>> getActiveVisitors(String schoolId);
  Future<Either<Failure, List<Visitor>>> getOverstayedVisitors(String schoolId);
  Future<Either<Failure, List<ScheduledVisit>>> getScheduledVisits(String schoolId);
  Future<Either<Failure, void>> approveScheduledVisit(String visitId);
  Future<Either<Failure, void>> rejectScheduledVisit(String visitId);
  Future<Either<Failure, void>> checkInScheduledVisit(String visitId);
  Future<Either<Failure, void>> logPackageDelivery(PackageDelivery delivery);
  Future<Either<Failure, List<PackageDelivery>>> getPackageDeliveries(String schoolId);
  Future<Either<Failure, void>> markPackageAsCollected(String packageId, String collectedBy);
  Future<Either<Failure, void>> exportToSheets(String schoolId, String schoolName);
  Future<Either<Failure, Visitor>> reissueBadge(String visitorId);
}
