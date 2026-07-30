import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../widgets/campus_dialogs.dart';
import '../widgets/hostel_transport_dialogs.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';

/// Houses, Clubs & Societies, Facilities, Hostel Structure, and Transport
/// Structure - the physical/organizational campus metadata.
class CampusFacilitiesScreen extends StatefulWidget {
  const CampusFacilitiesScreen({super.key});

  @override
  State<CampusFacilitiesScreen> createState() => _CampusFacilitiesScreenState();
}

class _CampusFacilitiesScreenState extends State<CampusFacilitiesScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    Tab(text: 'Houses'),
    Tab(text: 'Clubs & Societies'),
    Tab(text: 'Facilities'),
    Tab(text: 'Hostel Structure'),
    Tab(text: 'Transport Structure'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus & Facilities'),
        bottom: TabBar(controller: _tabController, isScrollable: true, tabs: _tabs),
      ),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _HousesTab(state: state),
              _ClubsTab(state: state),
              _FacilitiesTab(state: state),
              _HostelStructureTab(state: state),
              _TransportStructureTab(state: state),
            ],
          );
        },
      ),
    );
  }
}

Color _fromHex(String hex, Color fallback) => hex.isNotEmpty ? Color(int.parse(hex.replaceFirst('#', '0xff'))) : fallback;

class _HousesTab extends StatelessWidget {
  final StructureState state;
  const _HousesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return Scaffold(
      body: state.houses.isEmpty
          ? const StructureEmptyHint('No houses defined yet.\nAdd Blue House, Red House, or disable this entirely.')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.houses.length,
              itemBuilder: (context, index) {
                final house = state.houses[index];
                return StructureListRow(
                  icon: Icons.home_outlined,
                  color: _fromHex(house.colorHex, Colors.blueGrey),
                  title: house.name,
                  subtitle: house.description,
                  isActive: house.isActive,
                  onEdit: () => showHouseFormDialog(context, existing: house, onSave: (u) => bloc.add(SaveHouseRequested(u))),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(context, title: 'Delete House', message: 'Delete "${house.name}"?');
                    if (confirmed == true) bloc.add(DeleteHouseRequested(house.id));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showHouseFormDialog(context, onSave: (h) => bloc.add(SaveHouseRequested(h))),
        icon: const Icon(Icons.add),
        label: const Text('Add House'),
      ),
    );
  }
}

class _ClubsTab extends StatelessWidget {
  final StructureState state;
  const _ClubsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return Scaffold(
      body: state.clubs.isEmpty
          ? const StructureEmptyHint('No clubs or societies defined yet.')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.clubs.length,
              itemBuilder: (context, index) {
                final club = state.clubs[index];
                return StructureListRow(
                  icon: Icons.groups_outlined,
                  color: Colors.deepPurple,
                  title: club.name,
                  subtitle: [if (club.category.isNotEmpty) club.category, if (club.patronName.isNotEmpty) 'Patron: ${club.patronName}'].join(' - '),
                  isActive: club.isActive,
                  onEdit: () => showClubFormDialog(context, existing: club, onSave: (u) => bloc.add(SaveClubRequested(u))),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(context, title: 'Delete Club', message: 'Delete "${club.name}"?');
                    if (confirmed == true) bloc.add(DeleteClubRequested(club.id));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showClubFormDialog(context, onSave: (c) => bloc.add(SaveClubRequested(c))),
        icon: const Icon(Icons.add),
        label: const Text('Add Club'),
      ),
    );
  }
}

class _FacilitiesTab extends StatelessWidget {
  final StructureState state;
  const _FacilitiesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return Scaffold(
      body: state.facilities.isEmpty
          ? const StructureEmptyHint('No facilities defined yet.')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.facilities.length,
              itemBuilder: (context, index) {
                final facility = state.facilities[index];
                return StructureListRow(
                  icon: Icons.holiday_village_outlined,
                  color: Colors.brown,
                  title: facility.name,
                  subtitle: [if (facility.facilityType.isNotEmpty) facility.facilityType, if (facility.location.isNotEmpty) facility.location].join(' - '),
                  isActive: facility.isActive,
                  onEdit: () => showFacilityFormDialog(context, existing: facility, onSave: (u) => bloc.add(SaveFacilityRequested(u))),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(context, title: 'Delete Facility', message: 'Delete "${facility.name}"?');
                    if (confirmed == true) bloc.add(DeleteFacilityRequested(facility.id));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFacilityFormDialog(context, onSave: (f) => bloc.add(SaveFacilityRequested(f))),
        icon: const Icon(Icons.add),
        label: const Text('Add Facility'),
      ),
    );
  }
}

class _HostelStructureTab extends StatelessWidget {
  final StructureState state;
  const _HostelStructureTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        StructureSectionHeader(
          title: 'Hostels',
          actionLabel: 'Add Hostel',
          onAction: () => showHostelFormDialog(context, onSave: (h) => bloc.add(SaveHostelRequested(h))),
        ),
        if (state.hostels.isEmpty) const StructureEmptyHint('No hostels defined yet.'),
        ...state.hostels.map((hostel) => StructureListRow(
              icon: Icons.night_shelter_outlined,
              color: Colors.brown,
              title: hostel.name,
              subtitle: [hostel.gender, if (hostel.wardenName.isNotEmpty) 'Warden: ${hostel.wardenName}', 'Capacity ${hostel.capacity}'].join(' - '),
              isActive: hostel.isActive,
              onEdit: () => showHostelFormDialog(context, existing: hostel, onSave: (u) => bloc.add(SaveHostelRequested(u))),
              onDelete: () async {
                final confirmed = await showDeleteConfirmDialog(context, title: 'Delete Hostel', message: 'Delete "${hostel.name}"?');
                if (confirmed == true) bloc.add(DeleteHostelRequested(hostel.id));
              },
            )),
        const SizedBox(height: 20),
        StructureSectionHeader(
          title: 'Rooms',
          actionLabel: 'Add Room',
          onAction: state.hostels.isEmpty
              ? null
              : () => showHostelRoomFormDialog(context, hostels: state.hostels, onSave: (r) => bloc.add(SaveHostelRoomRequested(r))),
        ),
        if (state.hostels.isEmpty)
          const StructureEmptyHint('Add a hostel first.')
        else if (state.hostelRooms.isEmpty)
          const StructureEmptyHint('No rooms defined yet.'),
        ...state.hostelRooms.map((room) {
          final hostel = state.hostels.where((h) => h.id == room.hostelId).firstOrNull;
          return StructureListRow(
            icon: Icons.meeting_room_outlined,
            color: Colors.brown,
            title: 'Room ${room.roomNumber}',
            subtitle: [hostel?.name ?? 'No hostel', if (room.blockName.isNotEmpty) room.blockName, '${room.bedCapacity} bed(s)'].join(' - '),
            isActive: room.isActive,
            onEdit: () => showHostelRoomFormDialog(
              context,
              existing: room,
              hostels: state.hostels,
              onSave: (u) => bloc.add(SaveHostelRoomRequested(u)),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(context, title: 'Delete Room', message: 'Delete Room "${room.roomNumber}"?');
              if (confirmed == true) bloc.add(DeleteHostelRoomRequested(room.id));
            },
          );
        }),
      ],
    );
  }
}

class _TransportStructureTab extends StatelessWidget {
  final StructureState state;
  const _TransportStructureTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        StructureSectionHeader(
          title: 'Routes',
          actionLabel: 'Add Route',
          onAction: () => showTransportRouteFormDialog(context, onSave: (r) => bloc.add(SaveTransportRouteRequested(r))),
        ),
        if (state.transportRoutes.isEmpty) const StructureEmptyHint('No routes defined yet.'),
        ...state.transportRoutes.map((route) => StructureListRow(
              icon: Icons.route_outlined,
              color: Colors.teal,
              title: route.name,
              subtitle: route.code,
              isActive: route.isActive,
              onEdit: () => showTransportRouteFormDialog(context, existing: route, onSave: (u) => bloc.add(SaveTransportRouteRequested(u))),
              onDelete: () async {
                final confirmed = await showDeleteConfirmDialog(context, title: 'Delete Route', message: 'Delete "${route.name}"?');
                if (confirmed == true) bloc.add(DeleteTransportRouteRequested(route.id));
              },
            )),
        const SizedBox(height: 20),
        StructureSectionHeader(
          title: 'Stops',
          actionLabel: 'Add Stop',
          onAction: state.transportRoutes.isEmpty
              ? null
              : () => showTransportStopFormDialog(context, routes: state.transportRoutes, onSave: (s) => bloc.add(SaveTransportStopRequested(s))),
        ),
        if (state.transportRoutes.isEmpty)
          const StructureEmptyHint('Add a route first.')
        else if (state.transportStops.isEmpty)
          const StructureEmptyHint('No stops defined yet.'),
        ...state.transportStops.map((stop) {
          final route = state.transportRoutes.where((r) => r.id == stop.routeId).firstOrNull;
          return StructureListRow(
            icon: Icons.pin_drop_outlined,
            color: Colors.teal,
            title: stop.name,
            subtitle: [route?.name ?? 'No route', if (stop.pickupTime.isNotEmpty) stop.pickupTime, if (stop.zone.isNotEmpty) stop.zone].join(' - '),
            isActive: stop.isActive,
            onEdit: () => showTransportStopFormDialog(
              context,
              existing: stop,
              routes: state.transportRoutes,
              onSave: (u) => bloc.add(SaveTransportStopRequested(u)),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(context, title: 'Delete Stop', message: 'Delete "${stop.name}"?');
              if (confirmed == true) bloc.add(DeleteTransportStopRequested(stop.id));
            },
          );
        }),
        const SizedBox(height: 20),
        StructureSectionHeader(
          title: 'Vehicles',
          actionLabel: 'Add Vehicle',
          onAction: () => showTransportVehicleFormDialog(context, routes: state.transportRoutes, onSave: (v) => bloc.add(SaveTransportVehicleRequested(v))),
        ),
        if (state.transportVehicles.isEmpty) const StructureEmptyHint('No vehicles defined yet.'),
        ...state.transportVehicles.map((vehicle) {
          final route = state.transportRoutes.where((r) => r.id == vehicle.routeId).firstOrNull;
          return StructureListRow(
            icon: Icons.directions_bus_outlined,
            color: Colors.teal,
            title: vehicle.busNumber,
            subtitle: [if (vehicle.plateNumber.isNotEmpty) vehicle.plateNumber, route?.name ?? 'Unassigned', 'Capacity ${vehicle.capacity}'].join(' - '),
            isActive: vehicle.isActive,
            onEdit: () => showTransportVehicleFormDialog(
              context,
              existing: vehicle,
              routes: state.transportRoutes,
              onSave: (u) => bloc.add(SaveTransportVehicleRequested(u)),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(context, title: 'Delete Vehicle', message: 'Delete "${vehicle.busNumber}"?');
              if (confirmed == true) bloc.add(DeleteTransportVehicleRequested(vehicle.id));
            },
          );
        }),
      ],
    );
  }
}
