import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/library/domain/entities/library_reservation.dart';
import 'package:school_pulse/features/library/presentation/screens/issue_resource_screen.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';

/// Librarian's queue of pending reservations - fulfil (send the borrower to
/// Issue Item, then mark the reservation fulfilled) or cancel outright.
class ReservationsScreen extends StatefulWidget {
  final String schoolId;
  const ReservationsScreen({super.key, required this.schoolId});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LibraryBloc>().add(WatchReservations(widget.schoolId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LibraryBloc, LibraryState>(
      listener: (context, state) {
        if (state is LibraryActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          context.read<LibraryBloc>().add(WatchReservations(widget.schoolId));
        }
        if (state is LibraryError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Reservations')),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, LibraryState state) {
    if (state is LibraryReservationsLoaded) {
      final pending = state.reservations
          .where((r) => r.status == ReservationStatus.pending)
          .toList()
        ..sort((a, b) => a.queuePosition.compareTo(b.queuePosition));

      if (pending.isEmpty) {
        return const EmptyState(
          icon: Icons.bookmark_border,
          title: 'No pending reservations',
          message: 'Reservations will appear here once a borrower reserves an item that is currently unavailable.',
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: pending.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _ReservationCard(reservation: pending[index], schoolId: widget.schoolId),
      );
    }

    if (state is LibraryError) {
      return EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not load reservations',
        message: state.message,
      );
    }

    return const Center(child: SchoolPulseLoader());
  }
}

class _ReservationCard extends StatelessWidget {
  final LibraryReservation reservation;
  final String schoolId;

  const _ReservationCard({required this.reservation, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${reservation.queuePosition}'),
        ),
        title: Text(
          reservation.resourceTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'For: ${reservation.borrowerName} (${reservation.borrowerType})\n'
          'Reserved: ${DateFormat('MMM d, yyyy').format(reservation.reservationDate)}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel reservation',
              onPressed: () => _confirmCancel(context),
            ),
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Fulfil - issue this item',
              onPressed: () => _fulfil(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel reservation?'),
        content: Text(
          'This will cancel ${reservation.borrowerName}\'s reservation for "${reservation.resourceTitle}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LibraryBloc>().add(
                CancelReservationRequested(schoolId, reservation.id),
              );
            },
            child: const Text('Cancel reservation'),
          ),
        ],
      ),
    );
  }

  Future<void> _fulfil(BuildContext context) async {
    final bloc = context.read<LibraryBloc>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: IssueResourceScreen(schoolId: schoolId),
        ),
      ),
    );
    if (context.mounted) {
      bloc.add(FulfilReservationRequested(schoolId, reservation.id));
    }
  }
}
