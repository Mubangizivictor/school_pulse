import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class SelectContactsScreen extends StatefulWidget {
  final bool isGroupSelection;
  const SelectContactsScreen({super.key, this.isGroupSelection = false});

  @override
  State<SelectContactsScreen> createState() => _SelectContactsScreenState();
}

class _SelectContactsScreenState extends State<SelectContactsScreen> {
  final List<String> _selectedIds = [];
  final List<Map<String, String>> _contacts = [
    {'id': '1', 'name': 'Mr. Kofi Mensah', 'role': 'Science Teacher'},
    {'id': '2', 'name': 'Mrs. Amina', 'role': 'Class Teacher - P7'},
    {'id': '3', 'name': 'Finance Office', 'role': 'School Department'},
    {'id': '4', 'name': 'Nurse Office', 'role': 'School Health'},
    {'id': '5', 'name': 'School Admin', 'role': 'Administrator'},
    {'id': '6', 'name': 'Mr. Boateng', 'role': 'Parent'},
    {'id': '7', 'name': 'Abena Owusu', 'role': 'Parent'},
    {'id': '8', 'name': 'David Evans', 'role': 'Teacher'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isGroupSelection ? 'Add Members' : 'New Chat'),
        actions: [
          if (widget.isGroupSelection)
            TextButton(
              onPressed: _selectedIds.isEmpty ? null : () => context.push('/messages/new/group/details'),
              child: const Text('Next'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or role',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.surfaceDark 
                    : AppColors.surfaceContainer(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (widget.isGroupSelection && _selectedIds.isNotEmpty)
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedIds.length,
                itemBuilder: (context, index) {
                  final contact = _contacts.firstWhere((c) => c['id'] == _selectedIds[index]);
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            const CircleAvatar(radius: 25, child: Icon(Icons.person)),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedIds.remove(contact['id'])),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(contact['name']!.split(' ').first, style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                  child: Text('Frequently Contacted', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted(context))),
                ),
                ..._contacts.take(3).map((c) => _buildContactTile(c)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                  child: Text('All Contacts', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted(context))),
                ),
                ..._contacts.skip(3).map((c) => _buildContactTile(c)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isGroupSelection && _selectedIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/messages/new/group/details'),
              label: Text('Next (${_selectedIds.length})'),
              icon: const Icon(Icons.arrow_forward),
            )
          : null,
    );
  }

  Widget _buildContactTile(Map<String, String> contact) {
    final isSelected = _selectedIds.contains(contact['id']);
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(contact['name']!),
      subtitle: Text(contact['role']!),
      trailing: widget.isGroupSelection
          ? Checkbox(
              value: isSelected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedIds.add(contact['id']!);
                  } else {
                    _selectedIds.remove(contact['id']);
                  }
                });
              },
            )
          : null,
      onTap: () {
        if (widget.isGroupSelection) {
          setState(() {
            if (isSelected) {
              _selectedIds.remove(contact['id']);
            } else {
              _selectedIds.add(contact['id']!);
            }
          });
        } else {
          context.push('/messages/chat/${contact['id']}');
        }
      },
    );
  }
}
