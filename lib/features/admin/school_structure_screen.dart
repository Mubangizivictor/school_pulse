import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/data/models/school_class.dart';
import 'package:school_pulse/features/admin/data/repositories/school_structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

class SchoolStructureScreen extends StatefulWidget {
  const SchoolStructureScreen({super.key});

  @override
  State<SchoolStructureScreen> createState() => _SchoolStructureScreenState();
}

class _SchoolStructureScreenState extends State<SchoolStructureScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repository = di.sl<SchoolStructureRepository>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('School Structure'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Classes & Streams'),
            Tab(text: 'Subjects'),
            Tab(text: 'Staff Departments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClassesTab(),
          _buildSubjectsTab(),
          _buildDepartmentsTab(),
        ],
      ),
    );
  }

  Widget _buildClassesTab() {
    return StreamBuilder<List<SchoolClass>>(
      stream: _repository.watchClasses(),
      builder: (context, snapshot) {
        final classes = snapshot.data ?? const [];
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 700 ? 1 : (constraints.maxWidth < 1100 ? 2 : 3);
            final isMobile = constraints.maxWidth < 600;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Active Classes',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: () => _showClassDialog(context),
                        icon: const Icon(Icons.add),
                        label: Text(isMobile ? 'Add' : 'Add New Class'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (classes.isEmpty)
                    const EmptyState(
                      icon: Icons.class_outlined,
                      title: 'No classes yet',
                      message: 'Add your first class to start building the school structure.',
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: constraints.maxWidth < 400 ? 2.8 : 3.2,
                      ),
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final c = classes[index];
                        return AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  c.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join(),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      c.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${c.streamCount} Stream${c.streamCount == 1 ? '' : 's'} • ${c.studentCount} Students',
                                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _showClassDialog(context, existing: c),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubjectsTab() {
    return StreamBuilder<List<SchoolSubject>>(
      stream: _repository.watchSubjects(),
      builder: (context, snapshot) {
        final subjects = snapshot.data ?? const [];
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Subjects Taught at This School',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: () => _showSubjectDialog(context),
                        icon: const Icon(Icons.add),
                        label: Text(isMobile ? 'Add' : 'Add Subject'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (subjects.isEmpty)
                    const EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'No subjects yet',
                      message: 'Register the subjects taught at this school so they can be assigned to subject teachers.',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: subjects.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final s = subjects[index];
                        return AppCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 20,
                              child: Text(s.name.isNotEmpty ? s.name[0] : '?', style: const TextStyle(fontSize: 14)),
                            ),
                            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  onPressed: () => _showSubjectDialog(context, existing: s),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  onPressed: () => _repository.deleteSubject(s.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDepartmentsTab() {
    return StreamBuilder<List<Department>>(
      stream: _repository.watchDepartments(),
      builder: (context, snapshot) {
        final departments = snapshot.data ?? const [];
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Academic & Ops Departments',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: () => _showDepartmentDialog(context),
                        icon: const Icon(Icons.add),
                        label: Text(isMobile ? 'New' : 'New Department'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (departments.isEmpty)
                    const EmptyState(
                      icon: Icons.apartment_outlined,
                      title: 'No departments yet',
                      message: 'Add a department to organize staff by function.',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: departments.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final d = departments[index];
                        return AppCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 20,
                              child: Text(d.name.isNotEmpty ? d.name[0] : '?', style: const TextStyle(fontSize: 14)),
                            ),
                            title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Text(
                              'Head: ${d.headName.isEmpty ? 'Unassigned' : d.headName} • ${d.memberCount} Members',
                              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () => _showDepartmentDialog(context, existing: d),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showClassDialog(BuildContext context, {SchoolClass? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final streamsController = TextEditingController(text: (existing?.streamCount ?? 1).toString());
    final studentsController = TextEditingController(text: (existing?.studentCount ?? 0).toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(existing == null ? 'Add New Class' : 'Edit Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Class Name (e.g. Primary 4)')),
            const SizedBox(height: 16),
            TextField(
              controller: streamsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number of Streams'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: studentsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Student Count'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final schoolClass = SchoolClass(
                id: existing?.id ?? '',
                name: nameController.text.trim(),
                streamCount: int.tryParse(streamsController.text) ?? 0,
                studentCount: int.tryParse(studentsController.text) ?? 0,
              );
              if (existing == null) {
                await _repository.addClass(schoolClass);
              } else {
                await _repository.updateClass(schoolClass);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(existing == null ? 'Add Class' : 'Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showSubjectDialog(BuildContext context, {SchoolSubject? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(existing == null ? 'Add Subject' : 'Edit Subject'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Subject Name (e.g. Mathematics)'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final subject = SchoolSubject(id: existing?.id ?? '', name: nameController.text.trim());
              if (existing == null) {
                await _repository.addSubject(subject);
              } else {
                await _repository.updateSubject(subject);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(existing == null ? 'Add Subject' : 'Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showDepartmentDialog(BuildContext context, {Department? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final headController = TextEditingController(text: existing?.headName ?? '');
    final membersController = TextEditingController(text: (existing?.memberCount ?? 0).toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(existing == null ? 'New Department' : 'Edit Department'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Department Name')),
            const SizedBox(height: 16),
            TextField(controller: headController, decoration: const InputDecoration(labelText: 'Head of Department')),
            const SizedBox(height: 16),
            TextField(
              controller: membersController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Member Count'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final department = Department(
                id: existing?.id ?? '',
                name: nameController.text.trim(),
                headName: headController.text.trim(),
                memberCount: int.tryParse(membersController.text) ?? 0,
              );
              if (existing == null) {
                await _repository.addDepartment(department);
              } else {
                await _repository.updateDepartment(department);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(existing == null ? 'Add Department' : 'Save Changes'),
          ),
        ],
      ),
    );
  }
}
