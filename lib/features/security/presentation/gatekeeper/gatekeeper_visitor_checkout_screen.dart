import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/gatekeeper_components.dart';
import 'package:school_pulse/features/visitors/domain/entities/visitor.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_bloc.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_event.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_state.dart';
import 'gatekeeper_shared.dart';

/// Gatekeeper Simple Mode visitor checkout: pick from currently-inside
/// visitors (VisitorsBloc.activeVisitors, already loaded by the home
/// screen), then one CHECK OUT tap. No manual exit-time entry - duration is
/// computed automatically, same as the existing scan-to-checkout flow.
class GatekeeperVisitorCheckOutScreen extends StatefulWidget {
  const GatekeeperVisitorCheckOutScreen({super.key});

  @override
  State<GatekeeperVisitorCheckOutScreen> createState() => _GatekeeperVisitorCheckOutScreenState();
}

class _GatekeeperVisitorCheckOutScreenState extends State<GatekeeperVisitorCheckOutScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Visitor? _selected;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmCheckOut() {
    if (_selected == null) return;
    setState(() => _isSubmitting = true);
    final now = DateTime.now();
    context.read<VisitorsBloc>().add(CheckOutVisitorEvent(
          visitorId: _selected!.id,
          departureTime: now,
          duration: formatVisitDuration(_selected!.arrivalTime, now),
        ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visitor Checkout')),
      body: _selected != null ? _buildConfirm(context) : _buildList(context),
    );
  }

  Widget _buildList(BuildContext context) {
    return BlocBuilder<VisitorsBloc, VisitorsState>(
      builder: (context, state) {
        if (state is! VisitorsLoaded) return const Center(child: CircularProgressIndicator());
        final visitors = state.activeVisitors.where((v) {
          if (_query.isEmpty) return true;
          final q = _query.toLowerCase();
          return v.fullName.toLowerCase().contains(q) || v.phone.contains(q);
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${state.activeVisitors.length} visitors currently inside', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(hintText: 'Search by name or phone', prefixIcon: Icon(Icons.search)),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 16),
              if (visitors.isEmpty)
                const Expanded(
                  child: EmptyState(
                    icon: Icons.meeting_room_outlined,
                    title: 'No visitors inside',
                    message: 'Everyone currently checked in will appear here.',
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: visitors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final visitor = visitors[index];
                      return AppCard(
                        onTap: () => setState(() => _selected = visitor),
                        child: Row(
                          children: [
                            AvatarInitials(name: visitor.fullName, size: 44),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(visitor.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('${visitor.purpose} • ${visitor.host}', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfirm(BuildContext context) {
    final visitor = _selected!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarInitials(name: visitor.fullName, size: 96),
          const SizedBox(height: 16),
          Text(visitor.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text('${visitor.purpose} • Visiting ${visitor.host}', textAlign: TextAlign.center),
          Text('Arrived ${formatVisitDuration(visitor.arrivalTime, DateTime.now())} ago', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          GatekeeperPrimaryButton(
            label: 'CHECK OUT',
            icon: Icons.logout,
            tone: GatekeeperButtonTone.info,
            isLoading: _isSubmitting,
            onPressed: _confirmCheckOut,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isSubmitting ? null : () => setState(() => _selected = null),
            child: const Text('Not this visitor — go back'),
          ),
        ],
      ),
    );
  }
}
