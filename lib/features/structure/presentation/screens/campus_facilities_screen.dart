import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/campus_entities.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../widgets/campus_dialogs.dart';
import '../widgets/hostel_transport_dialogs.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';

/// Focused campus/physical-structure editor.
///
/// The Structure wizard passes one `section` query parameter so an admin sees
/// only the task being configured instead of a tab bar full of unrelated
/// future setup.
class CampusFacilitiesScreen extends StatelessWidget {
  const CampusFacilitiesScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final requested =
        GoRouterState.of(context).uri.queryParameters['section'] ??
        'facilities';
    final section =
        const {
          'houses',
          'clubs',
          'facilities',
          'hostel',
          'transport',
        }.contains(requested)
        ? requested
        : 'facilities';
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;

    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(_sectionTitle(section))) : null,
      backgroundColor: showAppBar ? null : Colors.transparent,
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) => switch (section) {
          'houses' => _HousesTab(state: state, schoolId: schoolId),
          'clubs' => _ClubsTab(state: state, schoolId: schoolId),
          'hostel' => _HostelStructureTab(state: state, schoolId: schoolId),
          'transport' => _TransportStructureTab(
            state: state,
            schoolId: schoolId,
          ),
          _ => _FacilitiesTab(state: state, schoolId: schoolId),
        },
      ),
    );
  }

  String _sectionTitle(String section) => switch (section) {
    'houses' => 'Houses',
    'clubs' => 'Clubs & Societies',
    'hostel' => 'Boarding Structure',
    'transport' => 'Transport Structure',
    _ => 'Rooms & Learning Spaces',
  };
}

Color _fromHex(String hex, Color fallback) =>
    hex.isNotEmpty ? Color(int.parse(hex.replaceFirst('#', '0xff'))) : fallback;

class _HousesTab extends StatelessWidget {
  final StructureState state;
  final String schoolId;
  const _HousesTab({required this.state, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return Scaffold(
      body: state.houses.isEmpty
          ? const StructureEmptyHint(
              'No houses defined yet. Add only houses the school actually uses.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.houses.length,
              itemBuilder: (context, index) {
                final house = state.houses[index];
                return StructureListRow(
                  icon: Icons.home_outlined,
                  color: _fromHex(house.colorHex, Colors.black),
                  title: house.name,
                  subtitle: house.description,
                  isActive: house.isActive,
                  onEdit: () => showHouseFormDialog(
                    context,
                    schoolId: schoolId,
                    existing: house,
                    onSave: (u) => bloc.add(SaveHouseRequested(u)),
                  ),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete House',
                      message: 'Delete "${house.name}"?',
                    );
                    if (confirmed == true) {
                      bloc.add(DeleteHouseRequested(house.id));
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showHouseFormDialog(
          context,
          schoolId: schoolId,
          onSave: (h) => bloc.add(SaveHouseRequested(h)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add House'),
      ),
    );
  }
}

class _ClubsTab extends StatelessWidget {
  final StructureState state;
  final String schoolId;
  const _ClubsTab({required this.state, required this.schoolId});

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
                  color: Colors.black,
                  title: club.name,
                  subtitle: [
                    if (club.category.isNotEmpty) club.category,
                    if (club.patronName.isNotEmpty)
                      'Current patron: ${club.patronName}',
                  ].join(' - '),
                  isActive: club.isActive,
                  onEdit: () => showClubFormDialog(
                    context,
                    schoolId: schoolId,
                    existing: club,
                    onSave: (u) => bloc.add(SaveClubRequested(u)),
                  ),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Club',
                      message: 'Delete "${club.name}"?',
                    );
                    if (confirmed == true) {
                      bloc.add(DeleteClubRequested(club.id));
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showClubFormDialog(
          context,
          schoolId: schoolId,
          onSave: (c) => bloc.add(SaveClubRequested(c)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Club'),
      ),
    );
  }
}

class _FacilitiesTab extends StatelessWidget {
  final StructureState state;
  final String schoolId;
  const _FacilitiesTab({required this.state, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final scheme = Theme.of(context).colorScheme;

    void onAdd() => showFacilityFormDialog(
      context,
      schoolId: schoolId,
      campuses: state.campuses,
      onSave: (f) => bloc.add(SaveFacilityRequested(f)),
    );

    final campusesById = {for (final c in state.campuses) c.id: c};
    final byBuilding = <String, List<Facility>>{};
    for (final facility in state.facilities) {
      final label = campusesById[facility.campusId]?.name ?? 'Unassigned';
      byBuilding.putIfAbsent(label, () => []).add(facility);
    }

    void onAddCampus() => showCampusFormDialog(
      context,
      schoolId: schoolId,
      onSave: (c) => bloc.add(SaveCampusRequested(c)),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Campuses',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onAddCampus,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add campus'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.campuses.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Every school needs at least one campus - it is required '
                  'before staff, classes and other setup can be assigned.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              )
            else
              for (final campus in state.campuses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    child: ListTile(
                      leading: const Icon(Icons.location_city_outlined),
                      title: Text(
                        campus.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: campus.address.isNotEmpty
                          ? Text(campus.address)
                          : null,
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (action) {
                          if (action == 'edit') {
                            showCampusFormDialog(
                              context,
                              schoolId: schoolId,
                              existing: campus,
                              onSave: (u) => bloc.add(SaveCampusRequested(u)),
                            );
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                        ],
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    state.facilities.isEmpty
                        ? 'Add the physical spaces used for teaching and school operations.'
                        : 'Physical spaces used for teaching and school operations.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add space'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (state.facilities.isEmpty)
              _FacilitiesEmptyState(onAdd: onAdd)
            else
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final entry in byBuilding.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          entry.key.toUpperCase(),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                        ),
                      ),
                      for (final facility in entry.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            child: ListTile(
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  facilityTypeIcon(facility.facilityType),
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                facility.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  decoration: facility.isActive
                                      ? null
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(facility.facilityType),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (facility.location.isNotEmpty)
                                        _tagChip(
                                          context,
                                          Icons.place_outlined,
                                          facility.location,
                                        ),
                                      if (facility.capacity > 0)
                                        _tagChip(
                                          context,
                                          Icons.people_outline,
                                          'Capacity ${facility.capacity}',
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (action) async {
                                  if (action == 'edit') {
                                    showFacilityFormDialog(
                                      context,
                                      schoolId: schoolId,
                                      existing: facility,
                                      campuses: state.campuses,
                                      onSave: (u) =>
                                          bloc.add(SaveFacilityRequested(u)),
                                    );
                                  } else {
                                    final confirmed =
                                        await showDeleteConfirmDialog(
                                          context,
                                          title: 'Delete Space',
                                          message: 'Delete "${facility.name}"?',
                                        );
                                    if (confirmed == true) {
                                      bloc.add(
                                        DeleteFacilityRequested(facility.id),
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(BuildContext context, IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon, size: 16, color: scheme.onSecondaryContainer),
      label: Text(label, style: TextStyle(color: scheme.onSecondaryContainer)),
      visualDensity: VisualDensity.compact,
      backgroundColor: scheme.secondaryContainer,
      side: BorderSide.none,
    );
  }
}

class _FacilitiesEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _FacilitiesEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.holiday_village_outlined,
      title: 'No spaces added',
      message: 'Add classrooms, laboratories, halls or other facilities.',
      ctaLabel: 'Add space',
      onCtaPressed: onAdd,
    );
  }
}

class _HostelStructureTab extends StatefulWidget {
  final StructureState state;
  final String schoolId;
  const _HostelStructureTab({required this.state, required this.schoolId});

  @override
  State<_HostelStructureTab> createState() => _HostelStructureTabState();
}

class _HostelStructureTabState extends State<_HostelStructureTab> {
  List<UserEntity> _matronPatronStaff = const [];

  @override
  void initState() {
    super.initState();
    _loadMatronPatronStaff();
  }

  Future<void> _loadMatronPatronStaff() async {
    final result = await di.sl<GetStaffMembers>()(NoParams());
    if (!mounted) return;
    final staff = result.getOrElse(() => const []);
    setState(() {
      _matronPatronStaff = staff
          .where(
            (s) =>
                s.roles.contains(UserRole.boardingMatron) ||
                s.roles.contains(UserRole.boardingPatron),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final schoolId = widget.schoolId;
    final bloc = context.read<StructureBloc>();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Define hostels and rooms first. Patrons, matrons or wardens are assigned later so boarding structure never depends on staff creation.',
          ),
        ),
        StructureSectionHeader(
          title: 'Hostels / Dormitories',
          actionLabel: 'Add Hostel',
          onAction: () => showHostelFormDialog(
            context,
            schoolId: schoolId,
            matronPatronStaff: _matronPatronStaff,
            onSave: (h) => bloc.add(SaveHostelRequested(h)),
          ),
        ),
        if (state.hostels.isEmpty)
          const StructureEmptyHint('No hostels defined yet.'),
        ...state.hostels.map(
          (hostel) => StructureListRow(
            icon: Icons.night_shelter_outlined,
            color: Colors.black,
            title: hostel.name,
            subtitle: [
              hostel.gender,
              'Capacity ${hostel.capacity}',
              if (hostel.wardenName.isNotEmpty)
                'Current warden: ${hostel.wardenName}',
            ].join(' - '),
            isActive: hostel.isActive,
            onEdit: () => showHostelFormDialog(
              context,
              schoolId: schoolId,
              existing: hostel,
              matronPatronStaff: _matronPatronStaff,
              onSave: (u) => bloc.add(SaveHostelRequested(u)),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Delete Hostel',
                message: 'Delete "${hostel.name}"?',
              );
              if (confirmed == true) {
                bloc.add(DeleteHostelRequested(hostel.id));
              }
            },
          ),
        ),
        const SizedBox(height: 20),
        StructureSectionHeader(
          title: 'Rooms',
          actionLabel: 'Add Room',
          onAction: state.hostels.isEmpty
              ? null
              : () => showHostelRoomFormDialog(
                  context,
                  schoolId: schoolId,
                  hostels: state.hostels,
                  onSave: (r) => bloc.add(SaveHostelRoomRequested(r)),
                ),
        ),
        if (state.hostels.isEmpty)
          const StructureEmptyHint('Add a hostel first.')
        else if (state.hostelRooms.isEmpty)
          const StructureEmptyHint('No rooms defined yet.'),
        ...state.hostelRooms.map((room) {
          final hostel = state.hostels
              .where((h) => h.id == room.hostelId)
              .firstOrNull;
          return StructureListRow(
            icon: Icons.meeting_room_outlined,
            color: Colors.black,
            title: 'Room ${room.roomNumber}',
            subtitle: [
              hostel?.name ?? 'No hostel',
              if (room.blockName.isNotEmpty) room.blockName,
              '${room.bedCapacity} bed(s)',
            ].join(' - '),
            isActive: room.isActive,
            onEdit: () => showHostelRoomFormDialog(
              context,
              schoolId: schoolId,
              existing: room,
              hostels: state.hostels,
              onSave: (u) => bloc.add(SaveHostelRoomRequested(u)),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Delete Room',
                message: 'Delete Room "${room.roomNumber}"?',
              );
              if (confirmed == true) {
                bloc.add(DeleteHostelRoomRequested(room.id));
              }
            },
          );
        }),
      ],
    );
  }
}

class _TransportStructureTab extends StatelessWidget {
  final StructureState state;
  final String schoolId;
  const _TransportStructureTab({required this.state, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Define routes, stops and vehicles here. Drivers and conductors are assigned later through staff responsibilities.',
          ),
        ),
        StructureSectionHeader(
          title: 'Routes',
          actionLabel: 'Add Route',
          onAction: () => showTransportRouteFormDialog(
            context,
            schoolId: schoolId,
            onSave: (r) => bloc.add(SaveTransportRouteRequested(r)),
          ),
        ),
        if (state.transportRoutes.isEmpty)
          const StructureEmptyHint('No routes defined yet.'),
        ...state.transportRoutes.map(
          (route) => StructureListRow(
            icon: Icons.route_outlined,
            color: Colors.black,
            title: route.name,
            subtitle: route.code,
            isActive: route.isActive,
            onEdit: () => showTransportRouteFormDialog(
              context,
              schoolId: schoolId,
              existing: route,
              onSave: (u) => bloc.add(SaveTransportRouteRequested(u)),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Delete Route',
                message: 'Delete "${route.name}"?',
              );
              if (confirmed == true) {
                bloc.add(DeleteTransportRouteRequested(route.id));
              }
            },
          ),
        ),
        const SizedBox(height: 20),
        StructureSectionHeader(
          title: 'Stops',
          actionLabel: 'Add Stop',
          onAction: state.transportRoutes.isEmpty
              ? null
              : () => showTransportStopFormDialog(
                  context,
                  schoolId: schoolId,
                  routes: state.transportRoutes,
                  onSave: (s) => bloc.add(SaveTransportStopRequested(s)),
                ),
        ),
        if (state.transportRoutes.isEmpty)
          const StructureEmptyHint('Add a route first.')
        else if (state.transportStops.isEmpty)
          const StructureEmptyHint('No stops defined yet.'),
        ...state.transportStops.map((stop) {
          final route = state.transportRoutes
              .where((r) => r.id == stop.routeId)
              .firstOrNull;
          return StructureListRow(
            icon: Icons.pin_drop_outlined,
            color: Colors.black,
            title: stop.name,
            subtitle: [
              route?.name ?? 'No route',
              if (stop.pickupTime.isNotEmpty) stop.pickupTime,
              if (stop.zone.isNotEmpty) stop.zone,
            ].join(' - '),
            isActive: stop.isActive,
            onEdit: () => showTransportStopFormDialog(
              context,
              schoolId: schoolId,
              existing: stop,
              routes: state.transportRoutes,
              onSave: (u) => bloc.add(SaveTransportStopRequested(u)),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Delete Stop',
                message: 'Delete "${stop.name}"?',
              );
              if (confirmed == true) {
                bloc.add(DeleteTransportStopRequested(stop.id));
              }
            },
          );
        }),
        const SizedBox(height: 20),
        StructureSectionHeader(
          title: 'Vehicles',
          actionLabel: 'Add Vehicle',
          onAction: () => showTransportVehicleFormDialog(
            context,
            schoolId: schoolId,
            routes: state.transportRoutes,
            onSave: (v) => bloc.add(SaveTransportVehicleRequested(v)),
          ),
        ),
        if (state.transportVehicles.isEmpty)
          const StructureEmptyHint('No vehicles defined yet.'),
        ...state.transportVehicles.map((vehicle) {
          final route = state.transportRoutes
              .where((r) => r.id == vehicle.routeId)
              .firstOrNull;
          return StructureListRow(
            icon: Icons.directions_bus_outlined,
            color: Colors.black,
            title: vehicle.busNumber,
            subtitle: [
              if (vehicle.plateNumber.isNotEmpty) vehicle.plateNumber,
              route?.name ?? 'Unassigned',
              'Capacity ${vehicle.capacity}',
            ].join(' - '),
            isActive: vehicle.isActive,
            onEdit: () => showTransportVehicleFormDialog(
              context,
              schoolId: schoolId,
              existing: vehicle,
              routes: state.transportRoutes,
              onSave: (u) => bloc.add(SaveTransportVehicleRequested(u)),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Delete Vehicle',
                message: 'Delete "${vehicle.busNumber}"?',
              );
              if (confirmed == true) {
                bloc.add(DeleteTransportVehicleRequested(vehicle.id));
              }
            },
          );
        }),
      ],
    );
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
