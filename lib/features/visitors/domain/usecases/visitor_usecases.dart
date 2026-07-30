import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/visitor.dart';
import '../entities/visitor_blacklist.dart';
import '../entities/pre_approved_visitor.dart';
import '../entities/scheduled_visit.dart';
import '../entities/package_delivery.dart';
import '../repositories/visitor_repository.dart';

class CheckInVisitor {
  final VisitorRepository repository;
  CheckInVisitor(this.repository);
  Future<Either<Failure, Visitor>> call(Visitor visitor) => repository.checkInVisitor(visitor);
}

class CheckOutVisitor {
  final VisitorRepository repository;
  CheckOutVisitor(this.repository);
  Future<Either<Failure, Visitor>> call(String id, DateTime time, String duration) => 
      repository.checkOutVisitor(id, time, duration);
}

class GetVisitors {
  final VisitorRepository repository;
  GetVisitors(this.repository);
  Future<Either<Failure, List<Visitor>>> call(String schoolId) => repository.getVisitors(schoolId);
}

class WatchVisitors {
  final VisitorRepository repository;
  WatchVisitors(this.repository);
  Stream<List<Visitor>> call(String schoolId) => repository.watchVisitors(schoolId);
}

class SearchVisitors {
  final VisitorRepository repository;
  SearchVisitors(this.repository);
  Future<Either<Failure, List<Visitor>>> call(String schoolId, String query) => repository.searchVisitors(schoolId, query);
}

class GetVisitorBlacklist {
  final VisitorRepository repository;
  GetVisitorBlacklist(this.repository);
  Future<Either<Failure, List<VisitorBlacklist>>> call() => repository.getBlacklist();
}

class AddToBlacklist {
  final VisitorRepository repository;
  AddToBlacklist(this.repository);
  Future<Either<Failure, void>> call(VisitorBlacklist blacklist) => repository.addToBlacklist(blacklist);
}

class GetPreApprovedVisitors {
  final VisitorRepository repository;
  GetPreApprovedVisitors(this.repository);
  Future<Either<Failure, List<PreApprovedVisitor>>> call(String schoolId) => 
      repository.getPreApprovedVisitors(schoolId);
}

class MarkPreApprovedAsUsed {
  final VisitorRepository repository;
  MarkPreApprovedAsUsed(this.repository);
  Future<Either<Failure, void>> call(String preApprovedId) =>
      repository.markPreApprovedAsUsed(preApprovedId);
}

class SyncVisitors {
  final VisitorRepository repository;
  SyncVisitors(this.repository);
  Future<Either<Failure, void>> call() => repository.syncPendingRecords();
}

class GetActiveVisitors {
  final VisitorRepository repository;
  GetActiveVisitors(this.repository);
  Future<Either<Failure, List<Visitor>>> call(String schoolId) => repository.getActiveVisitors(schoolId);
}

class GetOverstayedVisitors {
  final VisitorRepository repository;
  GetOverstayedVisitors(this.repository);
  Future<Either<Failure, List<Visitor>>> call(String schoolId) => repository.getOverstayedVisitors(schoolId);
}

class GetScheduledVisits {
  final VisitorRepository repository;
  GetScheduledVisits(this.repository);
  Future<Either<Failure, List<ScheduledVisit>>> call(String schoolId) => repository.getScheduledVisits(schoolId);
}

class ApproveScheduledVisit {
  final VisitorRepository repository;
  ApproveScheduledVisit(this.repository);
  Future<Either<Failure, void>> call(String visitId) => repository.approveScheduledVisit(visitId);
}

class RejectScheduledVisit {
  final VisitorRepository repository;
  RejectScheduledVisit(this.repository);
  Future<Either<Failure, void>> call(String visitId) => repository.rejectScheduledVisit(visitId);
}

class CheckInScheduledVisit {
  final VisitorRepository repository;
  CheckInScheduledVisit(this.repository);
  Future<Either<Failure, void>> call(String visitId) => repository.checkInScheduledVisit(visitId);
}

class LogPackageDelivery {
  final VisitorRepository repository;
  LogPackageDelivery(this.repository);
  Future<Either<Failure, void>> call(PackageDelivery delivery) => repository.logPackageDelivery(delivery);
}

class GetPackageDeliveries {
  final VisitorRepository repository;
  GetPackageDeliveries(this.repository);
  Future<Either<Failure, List<PackageDelivery>>> call(String schoolId) => repository.getPackageDeliveries(schoolId);
}

class MarkPackageAsCollected {
  final VisitorRepository repository;
  MarkPackageAsCollected(this.repository);
  Future<Either<Failure, void>> call(String packageId, String collectedBy) => repository.markPackageAsCollected(packageId, collectedBy);
}

class ExportVisitorsToSheets {
  final VisitorRepository repository;
  ExportVisitorsToSheets(this.repository);
  Future<Either<Failure, void>> call(String schoolId, String schoolName) =>
      repository.exportToSheets(schoolId, schoolName);
}

class ReissueBadge {
  final VisitorRepository repository;
  ReissueBadge(this.repository);
  Future<Either<Failure, Visitor>> call(String visitorId) => repository.reissueBadge(visitorId);
}
