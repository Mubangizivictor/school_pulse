import 'package:equatable/equatable.dart';

class DirectorDashboardStats extends Equatable {
  final int totalStudents;
  final int totalStaff;
  final int totalClasses;
  final int totalDepartments;
  final String activeAcademicYear;
  final String currentTerm;
  final double schoolGrowthPercentage;

  // Financial Metrics
  final double expectedFees;
  final double collectedFees;
  final double outstandingFees;
  final double collectionPercentage;
  final double monthlyRevenue;
  final double termRevenue;
  final double yearRevenue;
  final double totalExpenditure;
  final double budgetUtilization;
  final int pendingFinancialApprovals;

  // Academic Performance
  final double overallSchoolAverage;
  final double passRate;
  final double improvementTrend;
  final List<ClassPerformance> topClasses;
  final List<ClassPerformance> weakClasses;

  // Staff & Engagement
  final double staffAttendanceRate;
  final double parentPortalUsageRate;
  final int activeIncidents;

  const DirectorDashboardStats({
    required this.totalStudents,
    required this.totalStaff,
    required this.totalClasses,
    required this.totalDepartments,
    required this.activeAcademicYear,
    required this.currentTerm,
    required this.schoolGrowthPercentage,
    required this.expectedFees,
    required this.collectedFees,
    required this.outstandingFees,
    required this.collectionPercentage,
    required this.monthlyRevenue,
    required this.termRevenue,
    required this.yearRevenue,
    required this.totalExpenditure,
    required this.budgetUtilization,
    required this.pendingFinancialApprovals,
    required this.overallSchoolAverage,
    required this.passRate,
    required this.improvementTrend,
    required this.topClasses,
    required this.weakClasses,
    required this.staffAttendanceRate,
    required this.parentPortalUsageRate,
    required this.activeIncidents,
  });

  @override
  List<Object?> get props => [
        totalStudents,
        totalStaff,
        totalClasses,
        totalDepartments,
        activeAcademicYear,
        currentTerm,
        schoolGrowthPercentage,
        expectedFees,
        collectedFees,
        outstandingFees,
        collectionPercentage,
        monthlyRevenue,
        termRevenue,
        yearRevenue,
        totalExpenditure,
        budgetUtilization,
        pendingFinancialApprovals,
        overallSchoolAverage,
        passRate,
        improvementTrend,
        topClasses,
        weakClasses,
        staffAttendanceRate,
        parentPortalUsageRate,
        activeIncidents,
      ];
}

class ClassPerformance extends Equatable {
  final String className;
  final double average;
  final double trend;

  const ClassPerformance({
    required this.className,
    required this.average,
    required this.trend,
  });

  @override
  List<Object?> get props => [className, average, trend];
}
