import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';
import 'package:school_pulse/features/patron/presentation/screens/dormitory_management_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/boarding_attendance_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/welfare_management_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/discipline_management_screen.dart';
import 'package:school_pulse/features/patron/presentation/widgets/patron_stat_card.dart';

class PatronDashboard extends StatefulWidget {
  const PatronDashboard({super.key});

  @override
  State<PatronDashboard> createState() => _PatronDashboardState();
}

class _PatronDashboardState extends State<PatronDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<PatronBloc>().add(WatchDormitories());
    context.read<PatronBloc>().add(WatchBoardingStudents());
    context.read<PatronBloc>().add(WatchAnnouncements());
    context.read<PatronBloc>().add(WatchDisciplineIncidents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patron Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<PatronBloc, PatronState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<PatronBloc>().add(WatchDormitories());
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(state),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildRecentAnnouncements(state),
                  const SizedBox(height: 24),
                  _buildRecentIncidents(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(PatronState state) {
    int dormCount = 0;
    int studentCount = 0;
    int incidentCount = 0;

    if (state is DormitoriesLoaded) {
      dormCount = state.dormitories.length;
    }
    if (state is BoardingStudentsLoaded) {
      studentCount = state.students.length;
    }
    if (state is DisciplineIncidentsLoaded) {
      incidentCount = state.incidents.where((i) => i.status == 'Pending').length;
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        PatronStatCard(
          title: 'Dormitories',
          value: '$dormCount',
          icon: Icons.meeting_room,
          color: Colors.blue,
        ),
        PatronStatCard(
          title: 'Students',
          value: '$studentCount',
          icon: Icons.people,
          color: Colors.green,
        ),
        PatronStatCard(
          title: 'Open Cases',
          value: '$incidentCount',
          icon: Icons.gavel,
          color: Colors.orange,
        ),
        PatronStatCard(
          title: 'Attendance',
          value: '98%',
          icon: Icons.check_circle,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _actionButton(
              context,
              'Roll Call',
              Icons.event_note,
              Colors.indigo,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BoardingAttendanceScreen()),
              ),
            ),
            _actionButton(
              context,
              'Dorms',
              Icons.apartment,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DormitoryManagementScreen()),
              ),
            ),
            _actionButton(
              context,
              'Welfare',
              Icons.favorite,
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WelfareManagementScreen()),
              ),
            ),
            _actionButton(
              context,
              'Discipline',
              Icons.gavel,
              Colors.brown,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DisciplineManagementScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRecentAnnouncements(PatronState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Announcements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        if (state is AnnouncementsLoaded && state.announcements.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.announcements.take(3).length,
            itemBuilder: (context, index) {
              final announcement = state.announcements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(announcement.title),
                  subtitle: Text(announcement.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(
                    '${announcement.date.day}/${announcement.date.month}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          )
        else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No recent announcements'),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentIncidents(PatronState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Incidents',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DisciplineManagementScreen()),
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        if (state is DisciplineIncidentsLoaded && state.incidents.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.incidents.take(3).length,
            itemBuilder: (context, index) {
              final incident = state.incidents[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(incident.studentName),
                subtitle: Text(incident.category),
                trailing: Chip(
                  label: Text(incident.status, style: const TextStyle(fontSize: 10)),
                  backgroundColor: incident.status == 'Pending' ? Colors.orange.shade100 : Colors.green.shade100,
                ),
              );
            },
          )
        else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No recent incidents'),
            ),
          ),
      ],
    );
  }
}
