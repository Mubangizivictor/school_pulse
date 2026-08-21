import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';

class ResourceDetailsScreen extends StatelessWidget {
  final ClassResource? resource;
  const ResourceDetailsScreen({super.key, this.resource});

  @override
  Widget build(BuildContext context) {
    final resource = this.resource;
    if (resource == null) {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(title: const Text('Resource Details')),
        body: const Center(child: Text('This resource is no longer available.')),
      );
    }

    final iconData = _iconFor(resource.kind);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Resource Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreMenu(context, resource),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: iconData.$2.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData.$1, color: iconData.$2, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          resource.isLink
                              ? 'Link'
                              : '${resource.kind.name} • ${resource.sizeLabel}',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),

            const SectionHeader(title: 'Information'),
            const SizedBox(height: AppSpacing.l),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Uploaded On',
                    value: _formatDate(resource.uploadedAt),
                  ),
                  _InfoTile(
                    icon: Icons.people_outline,
                    label: 'Shared With',
                    value: resource.audience.label,
                  ),
                  _InfoTile(
                    icon: Icons.file_download_outlined,
                    label: 'Downloads',
                    value: '${resource.downloadCount}',
                  ),
                  _InfoTile(
                    icon: Icons.description_outlined,
                    label: 'Description',
                    value: resource.description?.isNotEmpty == true
                        ? resource.description!
                        : 'No description added.',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),

            const SectionHeader(title: 'Actions'),
            const SizedBox(height: AppSpacing.l),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _ActionButton(
                  icon: resource.isLink
                      ? Icons.open_in_new
                      : Icons.remove_red_eye_outlined,
                  label: resource.isLink ? 'Open' : 'Preview',
                  color: Colors.blue,
                  onTap: () => _open(context, resource),
                ),
                _ActionButton(
                  icon: Icons.file_download_outlined,
                  label: 'Save Offline',
                  color: AppColors.success(context),
                  onTap: resource.isFolder || resource.isLink
                      ? null
                      : () => context.read<ClassResourceBloc>().add(
                          ClassResourceDownloadRequested(resource),
                        ),
                ),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  color: Colors.orange,
                  onTap: () => context.push(
                    '/staff/resources/share',
                    extra: resource,
                  ),
                ),
                _ActionButton(
                  icon: Icons.delete_outline,
                  label: 'Remove',
                  color: AppColors.danger(context),
                  onTap: () => _confirmRemove(context, resource),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, ClassResource resource) async {
    final url = resource.downloadUrl ?? resource.externalUrl;
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to open for this resource.')),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open this resource.')));
      }
    }
  }

  void _showMoreMenu(BuildContext context, ClassResource resource) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push('/staff/resources/share', extra: resource);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.danger(context)),
              title: Text('Remove', style: TextStyle(color: AppColors.danger(context))),
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmRemove(context, resource);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    ClassResource resource,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove resource?'),
        content: Text(
          resource.deleteRemovesFile
              ? 'This will permanently delete "${resource.name}".'
              : 'This detaches "${resource.name}" from your class. The '
                    'original file is not deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    context.read<ClassResourceBloc>().add(ClassResourceRemoved(resource));
    context.pop();
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: Theme.of(context).hintColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 52,
            endIndent: 16,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: disabled ? Theme.of(context).hintColor : color),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
