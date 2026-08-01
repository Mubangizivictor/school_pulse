import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';

class SelectClassScreen extends StatelessWidget {
  const SelectClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Class'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppSearchField(hintText: 'Search class...'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _ClassItem(
                  className: 'Primary 4 - Emerald',
                  studentCount: 32,
                  onTap: () => context.push('/teacher/reports/select-term'),
                ),
                const SizedBox(height: 12),
                _ClassItem(
                  className: 'Primary 4 - Sapphire',
                  studentCount: 33,
                  onTap: () => context.push('/teacher/reports/select-term'),
                ),
                const SizedBox(height: 12),
                _ClassItem(
                  className: 'Primary 5 - Emerald',
                  studentCount: 28,
                  onTap: () => context.push('/teacher/reports/select-term'),
                ),
                const SizedBox(height: 12),
                _ClassItem(
                  className: 'Primary 5 - Sapphire',
                  studentCount: 29,
                  onTap: () => context.push('/teacher/reports/select-term'),
                ),
                const SizedBox(height: 12),
                _ClassItem(
                  className: 'Primary 6 - Emerald',
                  studentCount: 31,
                  onTap: () => context.push('/teacher/reports/select-term'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              label: 'Continue',
              onPressed: () => context.push('/teacher/reports/select-term'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassItem extends StatelessWidget {
  final String className;
  final int studentCount;
  final VoidCallback onTap;

  const _ClassItem({
    required this.className,
    required this.studentCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.class_outlined, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('$studentCount Students', style: TextStyle(color: Theme.of(context).hintColor)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
        ],
      ),
    );
  }
}
