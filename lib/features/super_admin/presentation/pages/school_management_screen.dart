import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/app_components.dart';
import '../../domain/entities/school.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import '../widgets/super_admin_logout_button.dart';
import 'create_school_dialog.dart';
import 'school_detail_screen.dart';

class SchoolManagementScreen extends StatefulWidget {
  const SchoolManagementScreen({super.key});

  @override
  State<SchoolManagementScreen> createState() => _SchoolManagementScreenState();
}

class _SchoolManagementScreenState extends State<SchoolManagementScreen> {
  String _searchQuery = '';
  SchoolStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isWide = isSuperAdminWide(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Management'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: isWide ? 24 : 8),
            child: isWide
                ? ElevatedButton.icon(
                    onPressed: () => _showCreateSchoolDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Register New School'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 48),
                    ),
                  )
                : IconButton.filled(
                    onPressed: () => _showCreateSchoolDialog(context),
                    icon: const Icon(Icons.add),
                    tooltip: 'Register New School',
                  ),
          ),
          if (!isWide) const SuperAdminLogoutButton(),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(theme),
          Expanded(
            child: BlocBuilder<SuperAdminBloc, SuperAdminState>(
              builder: (context, state) {
                if (state.status == SuperAdminStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredSchools = state.schools.where((school) {
                  final matchesSearch =
                      school.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      school.tenantId.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                  final matchesStatus =
                      _statusFilter == null || school.status == _statusFilter;
                  return matchesSearch && matchesStatus;
                }).toList();

                if (filteredSchools.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No schools found',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: filteredSchools.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final school = filteredSchools[index];
                    return _SchoolListTile(school: school);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppSearchField(
              hintText: 'Search by school name or tenant ID...',
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<SchoolStatus?>(
            value: _statusFilter,
            hint: const Text('Filter by Status'),
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Statuses')),
              ...SchoolStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.name.toUpperCase()),
                );
              }),
            ],
            onChanged: (value) => setState(() => _statusFilter = value),
          ),
        ],
      ),
    );
  }

  void _showCreateSchoolDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateSchoolDialog(),
    );
  }
}

class _SchoolListTile extends StatelessWidget {
  final School school;

  const _SchoolListTile({required this.school});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(school.status);

    return Card(
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SchoolDetailScreen(school: school),
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              school.name.substring(0, 1).toUpperCase(),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(school.name, style: theme.textTheme.titleMedium),
            const SizedBox(width: 12),
            StatusBadge(label: school.status.name, color: statusColor),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              Text('ID: ${school.tenantId}'),
              const SizedBox(width: 20),
              Icon(
                Icons.calendar_today,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              Text(
                'Expiry: ${DateFormat('MMM dd, yyyy').format(school.subscriptionExpiry)}',
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.people,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              Text('${school.metadata['studentCount'] ?? 0} Students'),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Color _getStatusColor(SchoolStatus status) {
    switch (status) {
      case SchoolStatus.active:
        return Colors.green;
      case SchoolStatus.suspended:
        return Colors.red;
      case SchoolStatus.trial:
        return Colors.orange;
      case SchoolStatus.archived:
        return Colors.grey;
    }
  }
}
