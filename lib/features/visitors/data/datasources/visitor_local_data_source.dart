import '../../domain/entities/visitor.dart';
import 'package:isar/isar.dart';
import '../models/visitor_isar.dart';
import '../models/visitor_blacklist_isar.dart';
import '../models/pre_approved_visitor_isar.dart';
import '../models/scheduled_visit_isar.dart';
import '../models/package_delivery_isar.dart';

abstract class VisitorLocalDataSource {
  Future<List<VisitorIsar>> getVisitors(String schoolId);
  Future<void> saveVisitor(VisitorIsar visitor);
  Future<VisitorIsar?> getVisitorById(String visitorId);
  Future<List<VisitorIsar>> getPendingSyncVisitors();
  Future<List<VisitorIsar>> getActiveVisitors(String schoolId);
  Future<List<VisitorIsar>> getOverstayedVisitors(String schoolId);
  
  Future<List<VisitorBlacklistIsar>> getBlacklist();
  Future<void> saveBlacklist(List<VisitorBlacklistIsar> blacklist);
  
  Future<List<PreApprovedVisitorIsar>> getPreApprovedVisitors(String schoolId);
  Future<void> savePreApprovedVisitors(List<PreApprovedVisitorIsar> visitors);
  Future<void> markPreApprovedAsUsed(String preApprovedId);

  // New methods for Scheduled Visits
  Future<void> saveScheduledVisits(List<ScheduledVisitIsar> visits);
  Future<List<ScheduledVisitIsar>> getScheduledVisits(String schoolId);
  Future<void> markScheduledVisitApproved(String scheduledVisitId);
  Future<void> markScheduledVisitRejected(String scheduledVisitId);
  Future<void> markScheduledVisitCheckedIn(String scheduledVisitId);
  
  // New methods for Package Deliveries
  Future<void> savePackageDelivery(PackageDeliveryIsar delivery);
  Future<List<PackageDeliveryIsar>> getPackageDeliveries(String schoolId);
  
  Stream<List<VisitorIsar>> watchVisitors(String schoolId);
}

class VisitorLocalDataSourceImpl implements VisitorLocalDataSource {
  final Isar isar;

  VisitorLocalDataSourceImpl(this.isar);

  @override
  Future<List<VisitorIsar>> getVisitors(String schoolId) async {
    return await isar.visitorIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .sortByArrivalTimeDesc()
        .findAll();
  }

  @override
  Future<void> saveVisitor(VisitorIsar visitor) async {
    await isar.writeTxn(() async {
      await isar.visitorIsars.put(visitor);
    });
  }

  @override
  Future<VisitorIsar?> getVisitorById(String visitorId) async {
    return await isar.visitorIsars
        .filter()
        .visitorIdEqualTo(visitorId)
        .findFirst();
  }

  @override
  Future<List<VisitorIsar>> getPendingSyncVisitors() async {
    return await isar.visitorIsars
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<VisitorIsar>> getActiveVisitors(String schoolId) async {
    return await isar.visitorIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .statusEqualTo(VisitorStatus.checkedIn)
        .findAll();
  }

  @override
  Future<List<VisitorIsar>> getOverstayedVisitors(String schoolId) async {
    final now = DateTime.now();
    return await isar.visitorIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .statusEqualTo(VisitorStatus.checkedIn)
        .expectedDepartureTimeLessThan(now)
        .findAll();
  }

  @override
  Future<List<VisitorBlacklistIsar>> getBlacklist() async {
    return await isar.visitorBlacklistIsars.where().findAll();
  }

  @override
  Future<void> saveBlacklist(List<VisitorBlacklistIsar> blacklist) async {
    await isar.writeTxn(() async {
      await isar.visitorBlacklistIsars.clear();
      await isar.visitorBlacklistIsars.putAll(blacklist);
    });
  }

  @override
  Future<List<PreApprovedVisitorIsar>> getPreApprovedVisitors(String schoolId) async {
    return await isar.preApprovedVisitorIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .findAll();
  }

  @override
  Future<void> savePreApprovedVisitors(List<PreApprovedVisitorIsar> visitors) async {
    await isar.writeTxn(() async {
      await isar.preApprovedVisitorIsars.clear();
      await isar.preApprovedVisitorIsars.putAll(visitors);
    });
  }

  @override
  Future<void> markPreApprovedAsUsed(String preApprovedId) async {
    await isar.writeTxn(() async {
      final visitor = await isar.preApprovedVisitorIsars
          .filter()
          .preApprovedIdEqualTo(preApprovedId)
          .findFirst();
      if (visitor != null) {
        visitor.isUsed = true;
        await isar.preApprovedVisitorIsars.put(visitor);
      }
    });
  }

  @override
  Future<void> saveScheduledVisits(List<ScheduledVisitIsar> visits) async {
    await isar.writeTxn(() async {
      await isar.scheduledVisitIsars.clear();
      await isar.scheduledVisitIsars.putAll(visits);
    });
  }

  @override
  Future<List<ScheduledVisitIsar>> getScheduledVisits(String schoolId) async {
    return await isar.scheduledVisitIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .findAll();
  }

  @override
  Future<void> markScheduledVisitApproved(String scheduledVisitId) async {
    await isar.writeTxn(() async {
      final visit = await isar.scheduledVisitIsars
          .filter()
          .scheduledVisitIdEqualTo(scheduledVisitId)
          .findFirst();
      if (visit != null) {
        visit.isApproved = true;
        await isar.scheduledVisitIsars.put(visit);
      }
    });
  }

  @override
  Future<void> markScheduledVisitRejected(String scheduledVisitId) async {
    await isar.writeTxn(() async {
      final visit = await isar.scheduledVisitIsars
          .filter()
          .scheduledVisitIdEqualTo(scheduledVisitId)
          .findFirst();
      if (visit != null) {
        visit.isRejected = true;
        await isar.scheduledVisitIsars.put(visit);
      }
    });
  }

  @override
  Future<void> markScheduledVisitCheckedIn(String scheduledVisitId) async {
    await isar.writeTxn(() async {
      final visit = await isar.scheduledVisitIsars
          .filter()
          .scheduledVisitIdEqualTo(scheduledVisitId)
          .findFirst();
      if (visit != null) {
        visit.isCheckedIn = true;
        await isar.scheduledVisitIsars.put(visit);
      }
    });
  }

  @override
  Future<void> savePackageDelivery(PackageDeliveryIsar delivery) async {
    await isar.writeTxn(() async {
      await isar.packageDeliveryIsars.put(delivery);
    });
  }

  @override
  Future<List<PackageDeliveryIsar>> getPackageDeliveries(String schoolId) async {
    return await isar.packageDeliveryIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .sortByArrivalTimeDesc()
        .findAll();
  }

  @override
  Stream<List<VisitorIsar>> watchVisitors(String schoolId) {
    return isar.visitorIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .sortByArrivalTimeDesc()
        .watch(fireImmediately: true);
  }
}
