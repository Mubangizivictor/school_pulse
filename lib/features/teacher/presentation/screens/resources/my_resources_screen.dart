import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

class MyResourcesScreen extends StatefulWidget {
  const MyResourcesScreen({super.key});

  @override
  State<MyResourcesScreen> createState() => _MyResourcesScreenState();
}

class _MyResourcesScreenState extends State<MyResourcesScreen> {
  String _query = '';
  ClassResourceKind? _filter;

  @override
  void initState() {
    super.initState();
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active != null) {
      context.read<ClassResourceBloc>().add(ClassResourcesRequested(active));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('My Resources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppSearchField(
              hintText: 'Search resources...',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Documents',
                  isSelected: _filter == ClassResourceKind.document,
                  onTap: () =>
                      setState(() => _filter = ClassResourceKind.document),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Videos',
                  isSelected: _filter == ClassResourceKind.video,
                  onTap: () =>
                      setState(() => _filter = ClassResourceKind.video),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Images',
                  isSelected: _filter == ClassResourceKind.image,
                  onTap: () =>
                      setState(() => _filter = ClassResourceKind.image),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Links',
                  isSelected: _filter == ClassResourceKind.link,
                  onTap: () => setState(() => _filter = ClassResourceKind.link),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Expanded(
            child: BlocBuilder<ClassResourceBloc, ClassResourceState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items =
                    state.files.where((r) {
                        if (_filter != null && r.kind != _filter) return false;
                        if (_query.isEmpty) return true;
                        return r.name.toLowerCase().contains(
                          _query.toLowerCase(),
                        );
                      }).toList()
                      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No resources match your search.',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    for (final item in items)
                      _ResourceItem(
                        resource: item,
                        onTap: () => context.push(
                          '/staff/resources/details',
                          extra: item,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            for (final kind in ClassResourceKind.values)
              if (kind != ClassResourceKind.folder &&
                  kind != ClassResourceKind.other)
                ListTile(
                  title: Text(kind.name),
                  onTap: () {
                    setState(() => _filter = kind);
                    Navigator.pop(sheetContext);
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ResourceItem extends StatelessWidget {
  final ClassResource resource;
  final VoidCallback onTap;

  const _ResourceItem({required this.resource, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconData = _iconFor(resource.kind);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconData.$2.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData.$1, color: iconData.$2),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  resource.isLink ? 'Link' : resource.sizeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(resource.uploadedAt),
            style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static (IconData, Color) _iconFor(ClassResourceKind kind) => switch (kind) {
    ClassResourceKind.document => (Icons.picture_as_pdf, Colors.red),
    ClassResourceKind.spreadsheet => (Icons.grid_on, Colors.green),
    ClassResourceKind.presentation => (Icons.slideshow, Colors.orange),
    ClassResourceKind.image => (Icons.image, Colors.green),
    ClassResourceKind.audio => (Icons.audiotrack, Colors.teal),
    ClassResourceKind.video => (Icons.videocam, Colors.purple),
    ClassResourceKind.link => (Icons.link, Colors.blue),
    ClassResourceKind.folder => (Icons.folder, Colors.amber),
    ClassResourceKind.other => (Icons.insert_drive_file, Colors.grey),
  };
}
