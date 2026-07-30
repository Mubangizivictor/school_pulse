import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils/reporting_engine.dart';
import 'package:school_pulse/core/utils.dart';
import '../widgets/add_asset_dialog.dart';
import '../bloc/stores_assets_bloc.dart';
import '../bloc/stores_assets_event.dart';
import '../bloc/stores_assets_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'qr_scanner_screen.dart';
import 'procurement_screen.dart';
import 'maintenance_screen.dart';
import 'asset_details_screen.dart';
import 'inventory_list_screen.dart';
import 'repair_list_screen.dart';

class StoresAssetsDashboard extends StatefulWidget {
  const StoresAssetsDashboard({super.key});

  @override
  State<StoresAssetsDashboard> createState() => _StoresAssetsDashboardState();
}

class _StoresAssetsDashboardState extends State<StoresAssetsDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<StoresAssetsBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    final state = context.watch<StoresAssetsBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stores & Assets Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScannerScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              if (state is StoresAssetsLoaded) {
                ReportingEngine.exportAssetsToExcel(state.assets);
              }
            },
          ),
          const NotificationBellButton(),
        ],
      ),
      body: BlocListener<StoresAssetsBloc, StoresAssetsState>(
        listener: (context, state) {
          if (state is StoresAssetsLoaded && state.scannedAsset != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssetDetailsScreen(asset: state.scannedAsset!),
              ),
            );
          }
        },
        child: BlocBuilder<StoresAssetsBloc, StoresAssetsState>(
          builder: (context, state) {
            if (state is StoresAssetsLoading) {
              return const _LoadingView();
            }

            if (state is StoresAssetsError) {
              return Center(child: Text(state.message));
            }

            if (state is StoresAssetsLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<StoresAssetsBloc>().add(LoadDashboardData());
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildHeader(context, state),
                    const SizedBox(height: 24),
                    _buildStatsGrid(context, state, semanticColors),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'Maintenance & Repairs',
                      child: _buildMaintenanceList(context, state),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'Recent Stock Movements',
                      child: _buildMovementsList(context, state, semanticColors),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, StoresAssetsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operational Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          'Manage school resources from one place',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, StoresAssetsLoaded state, SemanticColors semanticColors) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        DashboardStatCard(
          title: 'Low Stock',
          value: state.lowStockCount.toDouble(),
          icon: Icons.warning_amber_rounded,
          color: semanticColors.warning,
        ),
        DashboardStatCard(
          title: 'Out of Stock',
          value: state.outOfStockCount.toDouble(),
          icon: Icons.error_outline_rounded,
          color: semanticColors.error,
        ),
        DashboardStatCard(
          title: 'Pending Orders',
          value: state.pendingPurchaseRequests.toDouble(),
          icon: Icons.shopping_cart_outlined,
          color: semanticColors.info,
        ),
        DashboardStatCard(
          title: 'Under Repair',
          value: state.assetsUnderRepair.toDouble(),
          icon: Icons.build_circle_outlined,
          color: Colors.deepPurple,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _QuickActionButton(
                label: 'Issue Stock',
                icon: Icons.outbox_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InventoryListScreen()),
                  );
                },
              ),
              _QuickActionButton(
                label: 'Receive Goods',
                icon: Icons.inventory_rounded,
                onTap: () {},
              ),
              _QuickActionButton(
                label: 'New Repair',
                icon: Icons.home_repair_service_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RepairListScreen()),
                  );
                },
              ),
              _QuickActionButton(
                label: 'Add Asset',
                icon: Icons.add_to_photos_rounded,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddAssetDialog(),
                  );
                },
              ),
              _QuickActionButton(
                label: 'Maintenance',
                icon: Icons.calendar_today_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MaintenanceScreen()),
                  );
                },
              ),
              _QuickActionButton(
                label: 'Procurement',
                icon: Icons.add_shopping_cart_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProcurementScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildMaintenanceList(BuildContext context, StoresAssetsLoaded state) {
    if (state.repairs.isEmpty && state.maintenanceSchedule.isEmpty) {
      return const AppCard(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No active repairs or maintenance')),
      );
    }
    // Combine and show top 3
    return Column(
      children: state.repairs.take(3).map((r) => _RepairTile(repair: r)).toList(),
    );
  }

  Widget _buildMovementsList(BuildContext context, StoresAssetsLoaded state, SemanticColors semanticColors) {
    if (state.recentMovements.isEmpty) {
      return const AppCard(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No recent movements')),
      );
    }
    return Column(
      children: state.recentMovements.take(5).map((m) => _MovementTile(movement: m, semanticColors: semanticColors)).toList(),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _RepairTile extends StatelessWidget {
  final dynamic repair; // AssetRepair or MaintenanceRecord
  const _RepairTile({required this.repair});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.build)),
        title: Text(repair.assetName),
        subtitle: Text(repair.description),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            repair.status.name.toUpperCase(),
            style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final dynamic movement;
  final SemanticColors semanticColors;

  const _MovementTile({required this.movement, required this.semanticColors});

  @override
  Widget build(BuildContext context) {
    final isRestock = movement.type.name == 'restock';
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isRestock ? Icons.arrow_downward : Icons.arrow_upward,
          color: isRestock ? semanticColors.success : semanticColors.warning,
        ),
        title: Text(movement.itemName),
        subtitle: Text('${movement.note} • ${DateFormatter.relative(movement.date)}'),
        trailing: Text(
          '${isRestock ? "+" : "-"}${movement.quantity}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isRestock ? semanticColors.success : semanticColors.warning,
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
