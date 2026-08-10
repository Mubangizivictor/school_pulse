import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';
import '../bloc/school_directory_bloc.dart';
import '../bloc/school_directory_event.dart';
import '../bloc/school_directory_state.dart';
import '../../domain/entities/directory_contact_entity.dart';

const _teachingRoles = {'classTeacher', 'subjectTeacher'};
const _adminRoles = {
  'director',
  'headTeacher',
  'deputyHead',
  'schoolAdmin',
  'bursar',
  'hrOfficer',
};

class SchoolDirectoryScreen extends StatelessWidget {
  const SchoolDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    final schoolId = authState.user.schoolId;

    return BlocProvider(
      create: (_) =>
          sl<SchoolDirectoryBloc>()
            ..add(LoadDirectoryRequested(schoolId: schoolId)),
      child: const _SchoolDirectoryBody(),
    );
  }
}

class _SchoolDirectoryBody extends StatefulWidget {
  const _SchoolDirectoryBody();

  @override
  State<_SchoolDirectoryBody> createState() => _SchoolDirectoryBodyState();
}

class _SchoolDirectoryBodyState extends State<_SchoolDirectoryBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<DirectoryContactEntity> _filter(
    List<DirectoryContactEntity> contacts,
    int tabIndex,
  ) {
    Iterable<DirectoryContactEntity> result = contacts;
    bool hasRole(DirectoryContactEntity contact, Set<String> roles) =>
        roles.contains(contact.role) || contact.roles.any(roles.contains);

    switch (tabIndex) {
      case 1:
        result = result.where((c) => hasRole(c, _teachingRoles));
        break;
      case 2:
        result = result.where(
          (c) => !hasRole(c, _teachingRoles) && !hasRole(c, _adminRoles),
        );
        break;
      case 3:
        result = result.where((c) => hasRole(c, _adminRoles));
        break;
    }
    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      result = result.where(
        (c) =>
            c.name.toLowerCase().contains(q) ||
            c.role.toLowerCase().contains(q) ||
            c.roles.any((role) => role.toLowerCase().contains(q)) ||
            (c.phone?.toLowerCase().contains(q) ?? false),
      );
    }
    final sortedContacts = result.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sortedContacts;
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calling is not available on this device.'),
        ),
      );
    }
  }

  Future<void> _showContact(DirectoryContactEntity contact) async {
    final phone = contact.phone?.trim();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarInitials(name: contact.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        contact.roles.isEmpty
                            ? contact.role
                            : contact.roles.join(' • '),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (phone != null && phone.isNotEmpty)
              PrimaryButton(
                label: 'Call ${contact.name.split(' ').first}',
                icon: Icons.call_outlined,
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _call(phone);
                },
              )
            else
              const Text(
                'No phone number has been shared for this staff member.',
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('School Directory'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Teaching'),
            Tab(text: 'Non-Teaching'),
            Tab(text: 'Admin'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppSearchField(
              hintText: 'Search staff by name...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: BlocBuilder<SchoolDirectoryBloc, SchoolDirectoryState>(
              builder: (context, state) {
                if (state is SchoolDirectoryLoading ||
                    state is SchoolDirectoryInitial) {
                  return const Center(child: SchoolPulseLoader());
                }
                if (state is SchoolDirectoryError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            label: 'Try Again',
                            onPressed: () {
                              final user = context.read<AuthBloc>().state;
                              if (user is AuthAuthenticated) {
                                context.read<SchoolDirectoryBloc>().add(
                                  LoadDirectoryRequested(
                                    schoolId: user.user.schoolId,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (state is! SchoolDirectoryLoaded) {
                  return const SizedBox.shrink();
                }

                return TabBarView(
                  controller: _tabController,
                  children: List.generate(4, (i) {
                    final contacts = _filter(state.contacts, i);
                    if (contacts.isEmpty) {
                      return const EmptyState(
                        icon: Icons.people_outline,
                        title: 'No contacts',
                        message: 'No staff members found in this category.',
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: contacts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return AppCard(
                          onTap: () => _showContact(contact),
                          child: Row(
                            children: [
                              AvatarInitials(name: contact.name),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contact.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary(context),
                                      ),
                                    ),
                                    Text(
                                      contact.role,
                                      style: TextStyle(
                                        color: AppColors.textMuted(context),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (contact.phone != null &&
                                  contact.phone!.isNotEmpty)
                                IconButton(
                                  icon: Icon(
                                    Icons.call_outlined,
                                    color: AppColors.primary(context),
                                  ),
                                  onPressed: () => _call(contact.phone!),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
