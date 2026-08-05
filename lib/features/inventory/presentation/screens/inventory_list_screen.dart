import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import '../bloc/stores_assets_bloc.dart';
import '../../domain/entities/inventory_item.dart';
import '../bloc/stores_assets_event.dart';
import '../bloc/stores_assets_state.dart';
import '../widgets/add_inventory_item_dialog.dart';
import '../widgets/issue_stock_dialog.dart';
import '../widgets/receive_goods_dialog.dart';
import '../../../../core/utils/reporting_engine.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StoresAssetsBloc>().add(LoadInventoryItems());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              final state = context.read<StoresAssetsBloc>().state;
              if (state is StoresAssetsLoaded) {
                ReportingEngine.exportInventoryToExcel(state.items);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<StoresAssetsBloc, StoresAssetsState>(
        builder: (context, state) {
          if (state is StoresAssetsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<InventoryItem> items = [];
          if (state is StoresAssetsLoaded) {
            items = state.items;
          }

          if (items.isEmpty) {
            return const Center(child: Text('No inventory items found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                item.category,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.quantity} ${item.unit}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: item.isOutOfStock
                                    ? semanticColors.error
                                    : item.isLowStock
                                    ? semanticColors.warning
                                    : null,
                              ),
                            ),
                            if (item.isLowStock)
                              Text(
                                'Low Stock',
                                style: TextStyle(
                                  color: semanticColors.warning,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  IssueStockDialog(item: item),
                            );
                          },
                          icon: const Icon(Icons.outbox_rounded, size: 18),
                          label: const Text('Issue'),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  ReceiveGoodsDialog(item: item),
                            );
                          },
                          icon: const Icon(
                            Icons.add_business_rounded,
                            size: 18,
                          ),
                          label: const Text('Receive'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddInventoryItemDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
