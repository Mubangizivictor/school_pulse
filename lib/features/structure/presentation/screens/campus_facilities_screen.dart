import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../widgets/campus_dialogs.dart';
import '../widgets/hostel_transport_dialogs.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';
import '../widgets/structure_wizard_banner.dart';

/// Houses, Clubs & Societies, Facilities, Hostel Structure, and Transport
/// Structure - the physical/organizational campus metadata.
class CampusFacilitiesScreen extends StatefulWidget {
  final int initialTab;
  final int? wizardStep;
  final int? wizardTotal;
  const CampusFacilitiesScreen({
    super.key,
    this.initialTab = 0,
    this.wizardStep,
    this.wizardTotal,
  });

  @override
  State<CampusFacilitiesScreen> createState() => _CampusFacilitiesScreenState();
}

class _CampusFacilitiesScreenState extends State<CampusFacilitiesScreen> {
  static const _sections = [
    'Campuses',
    'Houses',
    'Clubs & societies',
    'Facilities',
    'Hostel structure',
    'Transport structure',
  ];
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab.clamp(0, _sections.length - 1);
  }

  @override
  void didUpdateWidget(covariant CampusFacilitiesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selectedIndex = widget.initialTab.clamp(0, _sections.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AdminAppBar(
        title: 'Houses & Campus Life',
        bottom: widget.wizardStep == null || widget.wizardTotal == null
            ? null
            : StructureWizardBanner(
                stepId: 'campuses',
                stepNumber: widget.wizardStep!,
                totalSteps: widget.wizardTotal!,
              ),
      ),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          final pages = [
            _CampusesTab(state: state),
            _HousesTab(state: state),
            _ClubsTab(state: state),
            _FacilitiesTab(state: state),
            _HostelStructureTab(state: state),
            _TransportStructureTab(state: state),
          ];
          return pages[_selectedIndex];
        },
      ),
    );
  }
}

Color _fromHex(String hex, Color fallback) =>
    hex.isNotEmpty ? Color(int.parse(hex.replaceFirst('#', '0xff'))) : fallback;

class _CampusesTab extends StatefulWidget {
  final StructureState state;
  const _CampusesTab({required this.state});

  @override
  State<_CampusesTab> createState() => _CampusesTabState();
}

class _CampusesTabState extends State<_CampusesTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final campuses = [...widget.state.campuses]
      ..removeWhere(
        (campus) =>
            !campus.name.toLowerCase().contains(_query.toLowerCase()) &&
            !campus.code.toLowerCase().contains(_query.toLowerCase()),
      )
      ..sort((a, b) => a.order.compareTo(b.order));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: StructureSearchBar(
              hint: 'Search campuses...',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: campuses.isEmpty
                ? const StructureEmptyHint(
                    'No campuses defined yet. Single-site institutions can skip this entirely - Campus is only needed for multi-site setups.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.l,
                    ),
                    itemCount: campuses.length,
                    itemBuilder: (context, index) {
                      final campus = campuses[index];
                      return StructureListRow(
                        icon: Icons.apartment_outlined,
                        color: Colors.blueGrey,
                        title: campus.name,
                        subtitle: [
                          if (campus.isPrimary) 'Primary',
                          if (campus.district.isNotEmpty) campus.district,
                        ].join(' - '),
                        isActive: campus.isActive,
                        badge: StructureStatusBadge(
                          label: 'Active',
                          isActive: campus.isActive,
                        ),
                        onEdit: () => showCampusFormDialog(
                          context,
                          existing: campus,
                          schoolId: schoolId,
                          onSave: (updated) =>
                              bloc.add(SaveCampusRequested(updated)),
                        ),
                        onDelete: () async {
                          final confirmed = await showDeleteConfirmDialog(
                            context,
                            title: 'Delete Campus',
                            message: 'Delete "${campus.name}"?',
                          );
                          if (confirmed == true) {
                            bloc.add(DeleteCampusRequested(campus.id));
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCampusFormDialog(
          context,
          schoolId: schoolId,
          onSave: (c) => bloc.add(SaveCampusRequested(c)),
        ),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Campus'),
      ),
    );
  }
}

class _HousesTab extends StatefulWidget {
  final StructureState state;
  const _HousesTab({required this.state});

  @override
  State<_HousesTab> createState() => _HousesTabState();
}

class _HousesTabState extends State<_HousesTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                StructureSearchBar(
                  hint: 'Search houses...',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                widget.state.houses
                    .where(
                      (house) => house.name.toLowerCase().contains(
                        _query.toLowerCase(),
                      ),
                    )
                    .isEmpty
                ? const StructureEmptyHint('No houses defined yet.')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.l,
                    ),
                    itemCount: widget.state.houses
                        .where(
                          (house) => house.name.toLowerCase().contains(
                            _query.toLowerCase(),
                          ),
                        )
                        .length,
                    itemBuilder: (context, index) {
                      final house = widget.state.houses
                          .where(
                            (house) => house.name.toLowerCase().contains(
                              _query.toLowerCase(),
                            ),
                          )
                          .elementAt(index);
                      return StructureListRow(
                        icon: Icons.home_outlined,
                        color: _fromHex(house.colorHex, Colors.indigo),
                        title: house.name,
                        subtitle: house.description,
                        isActive: house.isActive,
                        badge: StructureStatusBadge(
                          label: 'Active',
                          isActive: house.isActive,
                        ),
                        onEdit: () => showHouseFormDialog(
                          context,
                          existing: house,
                          schoolId: schoolId,
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showHouseFormDialog(
          context,
          schoolId: schoolId,
          onSave: (h) => bloc.add(SaveHouseRequested(h)),
        ),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add House'),
      ),
    );
  }
}

class _ClubsTab extends StatefulWidget {
  final StructureState state;
  const _ClubsTab({required this.state});

  @override
  State<_ClubsTab> createState() => _ClubsTabState();
}

class _ClubsTabState extends State<_ClubsTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                StructureSearchBar(
                  hint: 'Search clubs...',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                widget.state.clubs
                    .where(
                      (club) => club.name.toLowerCase().contains(
                        _query.toLowerCase(),
                      ),
                    )
                    .isEmpty
                ? const StructureEmptyHint('No clubs or societies defined yet.')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.l,
                    ),
                    itemCount: widget.state.clubs
                        .where(
                          (club) => club.name.toLowerCase().contains(
                            _query.toLowerCase(),
                          ),
                        )
                        .length,
                    itemBuilder: (context, index) {
                      final club = widget.state.clubs
                          .where(
                            (club) => club.name.toLowerCase().contains(
                              _query.toLowerCase(),
                            ),
                          )
                          .elementAt(index);
                      return StructureListRow(
                        icon: Icons.groups_outlined,
                        color: Colors.deepPurple,
                        title: club.name,
                        subtitle: [
                          if (club.category.isNotEmpty) club.category,
                          if (club.patronName.isNotEmpty)
                            'Patron: ${club.patronName}',
                        ].join(' - '),
                        isActive: club.isActive,
                        badge: StructureStatusBadge(
                          label: 'Active',
                          isActive: club.isActive,
                        ),
                        onEdit: () => showClubFormDialog(
                          context,
                          existing: club,
                          schoolId: schoolId,
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showClubFormDialog(
          context,
          schoolId: schoolId,
          onSave: (c) => bloc.add(SaveClubRequested(c)),
        ),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Club'),
      ),
    );
  }
}

class _FacilitiesTab extends StatefulWidget {
  final StructureState state;
  const _FacilitiesTab({required this.state});

  @override
  State<_FacilitiesTab> createState() => _FacilitiesTabState();
}

class _FacilitiesTabState extends State<_FacilitiesTab> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                const StructureSearchBar(hint: 'Search facilities...'),
                const SizedBox(height: AppSpacing.m),
                StructureFilterChips(
                  filters: const ['All', 'Buildings', 'Labs', 'Sports Grounds'],
                  selectedFilter: _selectedFilter,
                  onSelected: (val) => setState(() => _selectedFilter = val),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.state.facilities.isEmpty
                ? const StructureEmptyHint('No facilities defined yet.')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.l,
                    ),
                    itemCount: widget.state.facilities.length,
                    itemBuilder: (context, index) {
                      final facility = widget.state.facilities[index];
                      return StructureListRow(
                        icon: Icons.holiday_village_outlined,
                        color: Colors.brown,
                        title: facility.name,
                        subtitle: [
                          if (facility.facilityType.isNotEmpty)
                            facility.facilityType,
                          if (facility.location.isNotEmpty) facility.location,
                        ].join(' - '),
                        isActive: facility.isActive,
                        badge: StructureStatusBadge(
                          label: 'Active',
                          isActive: facility.isActive,
                        ),
                        onEdit: () => showFacilityFormDialog(
                          context,
                          existing: facility,
                          schoolId: schoolId,
                          onSave: (u) => bloc.add(SaveFacilityRequested(u)),
                        ),
                        onDelete: () async {
                          final confirmed = await showDeleteConfirmDialog(
                            context,
                            title: 'Delete Facility',
                            message: 'Delete "${facility.name}"?',
                          );
                          if (confirmed == true) {
                            bloc.add(DeleteFacilityRequested(facility.id));
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFacilityFormDialog(
          context,
          schoolId: schoolId,
          onSave: (f) => bloc.add(SaveFacilityRequested(f)),
        ),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Facility'),
      ),
    );
  }
}

class _HostelStructureTab extends StatefulWidget {
  final StructureState state;
  const _HostelStructureTab({required this.state});

  @override
  State<_HostelStructureTab> createState() => _HostelStructureTabState();
}

class _HostelStructureTabState extends State<_HostelStructureTab> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                const StructureSearchBar(hint: 'Search hostels...'),
                const SizedBox(height: AppSpacing.m),
                StructureFilterChips(
                  filters: const ['All', 'Hostels', 'Rooms'],
                  selectedFilter: _selectedFilter,
                  onSelected: (val) => setState(() => _selectedFilter = val),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              children: [
                StructureSectionHeader(
                  title: 'Hostels',
                  actionLabel: 'Add Hostel',
                  onAction: () => showHostelFormDialog(
                    context,
                    schoolId: schoolId,
                    onSave: (h) => bloc.add(SaveHostelRequested(h)),
                  ),
                ),
                if (widget.state.hostels.isEmpty)
                  const StructureEmptyHint('No hostels defined yet.'),
                ...widget.state.hostels.map(
                  (hostel) => StructureListRow(
                    icon: Icons.night_shelter_outlined,
                    color: Colors.brown,
                    title: hostel.name,
                    subtitle: [
                      hostel.gender,
                      if (hostel.wardenName.isNotEmpty)
                        'Warden: ${hostel.wardenName}',
                      'Capacity ${hostel.capacity}',
                    ].join(' - '),
                    isActive: hostel.isActive,
                    badge: StructureStatusBadge(
                      label: 'Active',
                      isActive: hostel.isActive,
                    ),
                    onEdit: () => showHostelFormDialog(
                      context,
                      existing: hostel,
                      schoolId: schoolId,
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
                const SizedBox(height: AppSpacing.xl),
                StructureSectionHeader(
                  title: 'Rooms',
                  actionLabel: 'Add Room',
                  onAction: widget.state.hostels.isEmpty
                      ? null
                      : () => showHostelRoomFormDialog(
                          context,
                          hostels: widget.state.hostels,
                          schoolId: schoolId,
                          onSave: (r) => bloc.add(SaveHostelRoomRequested(r)),
                        ),
                ),
                if (widget.state.hostels.isEmpty)
                  const StructureEmptyHint('Add a hostel first.')
                else if (widget.state.hostelRooms.isEmpty)
                  const StructureEmptyHint('No rooms defined yet.'),
                ...widget.state.hostelRooms.map((room) {
                  final hostel = widget.state.hostels
                      .where((h) => h.id == room.hostelId)
                      .firstOrNull;
                  return StructureListRow(
                    icon: Icons.meeting_room_outlined,
                    color: Colors.blueGrey,
                    title: 'Room ${room.roomNumber}',
                    subtitle: [
                      hostel?.name ?? 'No hostel',
                      if (room.blockName.isNotEmpty) room.blockName,
                      '${room.bedCapacity} bed(s)',
                    ].join(' - '),
                    isActive: room.isActive,
                    badge: StructureStatusBadge(
                      label: 'Active',
                      isActive: room.isActive,
                    ),
                    onEdit: () => showHostelRoomFormDialog(
                      context,
                      existing: room,
                      hostels: widget.state.hostels,
                      schoolId: schoolId,
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
                const SizedBox(height: AppSpacing.x4l),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransportStructureTab extends StatefulWidget {
  final StructureState state;
  const _TransportStructureTab({required this.state});

  @override
  State<_TransportStructureTab> createState() => _TransportStructureTabState();
}

class _TransportStructureTabState extends State<_TransportStructureTab> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              children: [
                const StructureSearchBar(hint: 'Search transport...'),
                const SizedBox(height: AppSpacing.m),
                StructureFilterChips(
                  filters: const ['All', 'Routes', 'Stops', 'Vehicles'],
                  selectedFilter: _selectedFilter,
                  onSelected: (val) => setState(() => _selectedFilter = val),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              children: [
                StructureSectionHeader(
                  title: 'Routes',
                  actionLabel: 'Add Route',
                  onAction: () => showTransportRouteFormDialog(
                    context,
                    schoolId: schoolId,
                    onSave: (r) => bloc.add(SaveTransportRouteRequested(r)),
                  ),
                ),
                if (widget.state.transportRoutes.isEmpty)
                  const StructureEmptyHint('No routes defined yet.'),
                ...widget.state.transportRoutes.map(
                  (route) => StructureListRow(
                    icon: Icons.route_outlined,
                    color: Colors.teal,
                    title: route.name,
                    subtitle: route.code,
                    isActive: route.isActive,
                    badge: StructureStatusBadge(
                      label: 'Active',
                      isActive: route.isActive,
                    ),
                    onEdit: () => showTransportRouteFormDialog(
                      context,
                      existing: route,
                      schoolId: schoolId,
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
                const SizedBox(height: AppSpacing.xl),
                StructureSectionHeader(
                  title: 'Stops',
                  actionLabel: 'Add Stop',
                  onAction: widget.state.transportRoutes.isEmpty
                      ? null
                      : () => showTransportStopFormDialog(
                          context,
                          routes: widget.state.transportRoutes,
                          schoolId: schoolId,
                          onSave: (s) =>
                              bloc.add(SaveTransportStopRequested(s)),
                        ),
                ),
                if (widget.state.transportRoutes.isEmpty)
                  const StructureEmptyHint('Add a route first.')
                else if (widget.state.transportStops.isEmpty)
                  const StructureEmptyHint('No stops defined yet.'),
                ...widget.state.transportStops.map((stop) {
                  final route = widget.state.transportRoutes
                      .where((r) => r.id == stop.routeId)
                      .firstOrNull;
                  return StructureListRow(
                    icon: Icons.pin_drop_outlined,
                    color: Colors.blueGrey,
                    title: stop.name,
                    subtitle: [
                      route?.name ?? 'No route',
                      if (stop.pickupTime.isNotEmpty) stop.pickupTime,
                      if (stop.zone.isNotEmpty) stop.zone,
                    ].join(' - '),
                    isActive: stop.isActive,
                    badge: StructureStatusBadge(
                      label: 'Active',
                      isActive: stop.isActive,
                    ),
                    onEdit: () => showTransportStopFormDialog(
                      context,
                      existing: stop,
                      routes: widget.state.transportRoutes,
                      schoolId: schoolId,
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
                const SizedBox(height: AppSpacing.xl),
                StructureSectionHeader(
                  title: 'Vehicles',
                  actionLabel: 'Add Vehicle',
                  onAction: () => showTransportVehicleFormDialog(
                    context,
                    routes: widget.state.transportRoutes,
                    schoolId: schoolId,
                    onSave: (v) => bloc.add(SaveTransportVehicleRequested(v)),
                  ),
                ),
                if (widget.state.transportVehicles.isEmpty)
                  const StructureEmptyHint('No vehicles defined yet.'),
                ...widget.state.transportVehicles.map((vehicle) {
                  final route = widget.state.transportRoutes
                      .where((r) => r.id == vehicle.routeId)
                      .firstOrNull;
                  return StructureListRow(
                    icon: Icons.directions_bus_outlined,
                    color: Colors.orange,
                    title: vehicle.busNumber,
                    subtitle: [
                      if (vehicle.plateNumber.isNotEmpty) vehicle.plateNumber,
                      route?.name ?? 'Unassigned',
                      'Capacity ${vehicle.capacity}',
                    ].join(' - '),
                    isActive: vehicle.isActive,
                    badge: StructureStatusBadge(
                      label: 'Active',
                      isActive: vehicle.isActive,
                    ),
                    onEdit: () => showTransportVehicleFormDialog(
                      context,
                      existing: vehicle,
                      routes: widget.state.transportRoutes,
                      schoolId: schoolId,
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
                const SizedBox(height: AppSpacing.x4l),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
