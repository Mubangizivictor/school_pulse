import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/package_delivery.dart';
import '../bloc/visitors_bloc.dart';
import '../bloc/visitors_event.dart';
import '../bloc/visitors_state.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class PackageDeliveryPage extends StatefulWidget {
  const PackageDeliveryPage({super.key});

  @override
  State<PackageDeliveryPage> createState() => _PackageDeliveryPageState();
}

class _PackageDeliveryPageState extends State<PackageDeliveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _courierController = TextEditingController();
  final _trackingController = TextEditingController();
  final _phoneController = TextEditingController();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final package = PackageDelivery(
      id: const Uuid().v4(),
      schoolId: authState.user.schoolId,
      recipientName: _recipientController.text,
      courierName: _courierController.text,
      courierPhone: _phoneController.text.isEmpty ? null : _phoneController.text,
      trackingNumber: _trackingController.text.isEmpty ? null : _trackingController.text,
      arrivalTime: DateTime.now(),
    );

    context.read<VisitorsBloc>().add(LogNewPackageDelivery(package));
    
    _recipientController.clear();
    _courierController.clear();
    _trackingController.clear();
    _phoneController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Package logged successfully')),
    );
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<VisitorsBloc>().add(LoadPackageDeliveries(authState.user.schoolId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Package Deliveries')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Log New Delivery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _recipientController,
                        decoration: const InputDecoration(labelText: 'Recipient Name *', prefixIcon: Icon(Icons.person)),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _courierController,
                        decoration: const InputDecoration(labelText: 'Courier/Company *', prefixIcon: Icon(Icons.local_shipping)),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(labelText: 'Courier Phone', prefixIcon: Icon(Icons.phone)),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _trackingController,
                              decoration: const InputDecoration(labelText: 'Tracking #', prefixIcon: Icon(Icons.tag)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(label: 'Log Delivery', onPressed: _submit),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<VisitorsBloc, VisitorsState>(
              builder: (context, state) {
                if (state is VisitorsLoading) return const Center(child: CircularProgressIndicator());
                if (state is VisitorsLoaded) {
                  final packages = state.packageDeliveries.where((p) => !p.isCollected).toList();
                  if (packages.isEmpty) return const Center(child: Text('No pending packages'));
                  
                  return ListView.builder(
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
                        title: Text(package.recipientName),
                        subtitle: Text('${package.courierName} • ${DateFormat('HH:mm').format(package.arrivalTime)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                          onPressed: () {
                            context.read<VisitorsBloc>().add(MarkPackageCollectedEvent(package.id, 'Self'));
                          },
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Something went wrong'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
