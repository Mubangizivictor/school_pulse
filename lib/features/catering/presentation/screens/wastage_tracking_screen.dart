import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/catering_bloc.dart';
import '../bloc/catering_event.dart';
import '../bloc/catering_state.dart';
import '../../domain/entities/wastage_record.dart';

class WastageTrackingScreen extends StatefulWidget {
  const WastageTrackingScreen({super.key});

  @override
  State<WastageTrackingScreen> createState() => _WastageTrackingScreenState();
}

class _WastageTrackingScreenState extends State<WastageTrackingScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadWastage();
  }

  void _loadWastage() {
    context.read<CateringBloc>().add(LoadWastageRecords(_startDate, _endDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Wastage Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: DateTimeRange(
                  start: _startDate,
                  end: _endDate,
                ),
              );
              if (range != null) {
                setState(() {
                  _startDate = range.start;
                  _endDate = range.end;
                });
                _loadWastage();
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<CateringBloc, CateringState>(
        builder: (context, state) {
          if (state is CateringLoading) {
            return const Center(child: SchoolPulseLoader());
          } else if (state is WastageRecordsLoaded) {
            final records = state.records;
            if (records.isEmpty) {
              return const Center(
                child: Text(
                  'No wastage records found for the selected period.',
                ),
              );
            }
            return ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      '${record.mealCategoryName} - ${DateFormat('MMM dd, yyyy').format(record.date)}',
                    ),
                    subtitle: Text('Reason: ${record.reason}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${record.quantityWasted} ${record.unit} wasted',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Impact: UGX ${record.costImpact.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is CateringError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(
            child: Text('Select a date range to view wastage.'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWastageDialog(context),
        label: const Text('Report Wastage'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddWastageDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String mealCategoryId = '';
    String mealCategoryName = '';
    double prepared = 0;
    double served = 0;
    String reason = '';
    String unit = 'Kg';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Meal Wastage'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Meal Category'),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('Breakfast')),
                    DropdownMenuItem(value: '2', child: Text('Lunch')),
                    DropdownMenuItem(value: '3', child: Text('Supper')),
                  ],
                  onChanged: (val) {
                    mealCategoryId = val!;
                    mealCategoryName = val == '1'
                        ? 'Breakfast'
                        : val == '2'
                        ? 'Lunch'
                        : 'Supper';
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantity Prepared (Kg/Litres)',
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => prepared = double.tryParse(val!) ?? 0,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantity Served (Kg/Litres)',
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => served = double.tryParse(val!) ?? 0,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Reason for Wastage',
                  ),
                  maxLines: 2,
                  onSaved: (val) => reason = val ?? '',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final wasted = prepared - served;
                final record = WastageRecord(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  mealCategoryId: mealCategoryId,
                  mealCategoryName: mealCategoryName,
                  date: DateTime.now(),
                  quantityPrepared: prepared,
                  quantityServed: served,
                  quantityWasted: wasted > 0 ? wasted : 0,
                  unit: unit,
                  reason: reason,
                  costImpact:
                      (wasted > 0 ? wasted : 0) * 2500, // Example cost per unit
                );
                context.read<CateringBloc>().add(
                  SaveWastageRecordEvent(record),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
