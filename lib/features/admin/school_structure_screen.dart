import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class SchoolStructureScreen extends StatefulWidget {
  const SchoolStructureScreen({super.key});

  @override
  State<SchoolStructureScreen> createState() => _SchoolStructureScreenState();
}

class _SchoolStructureScreenState extends State<SchoolStructureScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            Tab(text: 'Staff Departments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClassesTab(),
          _buildDepartmentsTab(),
        ],
      ),
    );
  }

  Widget _buildClassesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Classes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add New Class')),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              final className = 'Primary ${index + 1}';
              return AppCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('P.${index + 1}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(className, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Text('3 Streams • 120 Students', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () {}),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Academic & Ops Departments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('New Department')),
            ],
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final depts = ['Science', 'Mathematics', 'Humanities', 'Administration', 'Operations'];
              return AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text(depts[index][0])),
                  title: Text(depts[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Head: Mr. John Doe • 12 Members'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
