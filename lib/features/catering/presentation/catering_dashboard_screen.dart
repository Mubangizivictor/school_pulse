import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/qr_scanner/presentation/screens/qr_scanner_screen.dart';
import 'package:school_pulse/features/qr_scanner/domain/entities/scanner_mode.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/shared/staff_dashboard/staff_dashboard_widgets.dart';
import '../domain/entities/meal_record.dart';
import 'screens/inventory_screen.dart';
import 'screens/meal_planning_screen.dart';
import 'screens/stock_request_screen.dart';
import 'screens/wastage_tracking_screen.dart';
import 'screens/catering_financial_report_screen.dart';
import 'bloc/catering_bloc.dart';
import 'bloc/catering_event.dart';
import 'bloc/catering_state.dart';

class CateringDashboardScreen extends StatefulWidget {
  const CateringDashboardScreen({super.key});

  @override
  State<CateringDashboardScreen> createState() =>
      _CateringDashboardScreenState();
}

class _CateringDashboardScreenState extends State<CateringDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CateringBloc>().add(LoadCateringDashboard());
  }

  void _scanForMeal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerScreen(
          mode: ScannerMode.verification,
          onScan: (studentId) => _verifyMealEligibility(context, studentId),
        ),
      ),
    );
  }

  void _verifyMealEligibility(BuildContext context, String studentId) {
    context.read<CateringBloc>().add(VerifyStudentMeal(studentId));
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return BlocListener<CateringBloc, CateringState>(
      listener: (context, state) {
        if (state is MealEligibilityVerified) {
          _showEligibilityResult(context, state.eligibilityData);
        } else if (state is CateringError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.black,
            ),
          );
        } else if (state is CateringSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.black,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: staffDashboardAppBar(context, roleLabel: 'Catering'),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<CateringBloc>().add(LoadCateringDashboard());
          },
          child: BlocBuilder<CateringBloc, CateringState>(
            builder: (context, state) {
              if (state is CateringLoading &&
                  state is! CateringDashboardLoaded) {
                return const _CateringSkeleton();
              }

              if (state is CateringDashboardLoaded) {
                final data = state.dashboardData;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    StaffHeroSummaryCard(
                      greetingNameFallback: 'Chef',
                      kpis: [
                        StaffKpiData(
                          title: 'Expected Students',
                          valueText: '${data['expectedStudents'] ?? 0}',
                          subtitle: 'Today',
                          icon: Icons.people_alt_rounded,
                          color: AppColors.information(context),
                        ),
                        StaffKpiData(
                          title: 'Meals Served',
                          valueText: '${data['mealsServedToday'] ?? 0}',
                          subtitle: 'Today',
                          icon: Icons.restaurant_rounded,
                          color: AppColors.success(context),
                        ),
                        StaffKpiData(
                          title: 'Boarders',
                          valueText: '${data['boardersCount'] ?? 0}',
                          subtitle: 'On roll',
                          icon: Icons.hotel_rounded,
                          color: AppColors.warning(context),
                        ),
                        StaffKpiData(
                          title: 'Day Scholars',
                          valueText: '${data['dayScholarsCount'] ?? 0}',
                          subtitle: 'On roll',
                          icon: Icons.school_rounded,
                          color: AppColors.danger(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildTodayMenuSection(context, data['todayMenu'] ?? []),
                    const SizedBox(height: 24),
                    _buildInventoryAlerts(
                      context,
                      data['lowStockAlertsCount'] ?? 0,
                      semanticColors,
                    ),
                    const SizedBox(height: 24),
                    _buildKitchenActivities(
                      context,
                      data['kitchenActivities'] ?? [],
                    ),
                  ],
                );
              }

              if (state is CateringError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      ElevatedButton(
                        onPressed: () => context.read<CateringBloc>().add(
                          LoadCateringDashboard(),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return const _CateringSkeleton();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ActionChip(
                icon: Icons.search,
                label: 'Eligibility Lookup',
                onTap: () => context.push('/staff/catering/lookup'),
              ),
              _ActionChip(
                icon: Icons.qr_code_scanner,
                label: 'Verify Meal',
                onTap: () => _scanForMeal(context),
              ),
              _ActionChip(
                icon: Icons.menu_book,
                label: 'Menu Planning',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MealPlanningScreen(),
                    ),
                  );
                },
              ),
              _ActionChip(
                icon: Icons.inventory,
                label: 'Food Inventory',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CateringInventoryScreen(),
                    ),
                  );
                },
              ),
              _ActionChip(
                icon: Icons.shopping_cart,
                label: 'Stock Request',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StockRequestScreen(),
                    ),
                  );
                },
              ),
              _ActionChip(
                icon: Icons.delete_sweep,
                label: 'Wastage',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WastageTrackingScreen(),
                    ),
                  );
                },
              ),
              _ActionChip(
                icon: Icons.bar_chart,
                label: 'Finance',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CateringFinancialReportScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayMenuSection(BuildContext context, List<dynamic> menu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Menu",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: () {}, child: const Text('View Weekly')),
          ],
        ),
        if (menu.isEmpty)
          const AppCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No menu items set for today'),
              ),
            ),
          )
        else
          ...menu.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AppCard(
                child: ListTile(
                  title: Text(item['mealCategory'] ?? ''),
                  subtitle: Text(item['menu'] ?? ''),
                  trailing: Text(item['time'] ?? ''),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInventoryAlerts(
    BuildContext context,
    int count,
    SemanticColors semanticColors,
  ) {
    if (count == 0) return const SizedBox.shrink();
    return AppCard(
      color: semanticColors.error,
      child: ListTile(
        leading: Icon(Icons.warning, color: semanticColors.error),
        title: Text(
          '$count Items Low in Stock',
          style: TextStyle(
            color: semanticColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text('Action required to avoid stockout'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Widget _buildKitchenActivities(
    BuildContext context,
    List<dynamic> activities,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kitchen Activities',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (activities.isEmpty)
          const Text('No recent activities')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: const Icon(Icons.history, size: 20),
                title: Text(activity['description'] ?? ''),
                subtitle: Text(activity['time'] ?? ''),
                dense: true,
              );
            },
          ),
      ],
    );
  }

  void _showEligibilityResult(BuildContext context, Map<String, dynamic> data) {
    final status = data['eligibilityStatus'] as String;
    final isCleared = status == 'Cleared';
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isCleared
                    ? semanticColors.success
                    : semanticColors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCleared ? Icons.check_circle : Icons.cancel,
                color: isCleared
                    ? semanticColors.success
                    : semanticColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isCleared ? 'Access Granted' : 'Access Denied',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isCleared
                    ? semanticColors.success
                    : semanticColors.error,
              ),
            ),
            const SizedBox(height: 24),
            _buildStudentDetailRow('Student', data['studentName']),
            _buildStudentDetailRow('Class', data['class']),
            // Deliberately no balance/percentage-paid row here - catering
            // staff see eligible/not-eligible only, never why, per the
            // "never reveal balances" requirement (see
            // CateringEligibilityService, which enforces this for the
            // manual-search lookup path).
            if (!isCleared)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Meal not authorized. Please contact the bursar.',
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 32),
            if (isCleared)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    String userId = '';
                    String schoolId = '';
                    if (authState is AuthAuthenticated) {
                      userId = authState.user.id;
                      schoolId = authState.user.schoolId;
                    }

                    context.read<CateringBloc>().add(
                      RecordMealServedEvent(
                        MealRecord(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          studentId: data['studentId'],
                          studentName: data['studentName'],
                          classId: data['class'],
                          mealCategoryId:
                              '1', // Should be determined by current time
                          mealCategoryName: 'Lunch',
                          servedAt: DateTime.now(),
                          servedBy: userId,
                          schoolId: schoolId,
                          academicYear: '2024',
                          term: 'Term 1',
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Record Meal Served'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CateringSkeleton extends StatelessWidget {
  const _CateringSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: List.generate(
            4,
            (index) => const Skeleton(borderRadius: 12),
          ),
        ),
        const SizedBox(height: 24),
        const Skeleton(width: 150, height: 20),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Skeleton(width: 80, height: 80, borderRadius: 12),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Skeleton(width: 150, height: 20),
        const SizedBox(height: 12),
        ...List.generate(
          2,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Skeleton(height: 80, borderRadius: 12),
          ),
        ),
      ],
    );
  }
}
