import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import '../bloc/catering_bloc.dart';
import '../bloc/catering_event.dart';
import '../bloc/catering_state.dart';

class CateringInventoryScreen extends StatefulWidget {
  const CateringInventoryScreen({super.key});

  @override
  State<CateringInventoryScreen> createState() => _CateringInventoryScreenState();
}

class _CateringInventoryScreenState extends State<CateringInventoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CateringBloc>().add(LoadInventoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () {
              // Navigate to Stock Request screen
            },
            tooltip: 'Request Stock',
          ),
        ],
      ),
      body: BlocBuilder<CateringBloc, CateringState>(
        builder: (context, state) {
          if (state is CateringLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is InventoryLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text('No inventory items found.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isLowStock = item.currentStock <= item.reorderLevel;

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${item.category ?? 'N/A'}'),
                        if (item.expiryDate != null)
                          Text('Expiry: ${item.expiryDate!.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(
                                  color: item.expiryDate!.isBefore(DateTime.now())
                                      ? semanticColors.error
                                      : null)),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item.currentStock} ${item.unit}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLowStock ? semanticColors.error : semanticColors.success,
                          ),
                        ),
                        if (isLowStock)
                          Text('Low Stock',
                              style: TextStyle(color: semanticColors.error, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          if (state is CateringError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
