import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';

class StructureScreen extends StatelessWidget {
  const StructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020716),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildModuleBanner(context),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Overview',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(color: Color(0xFF176BFF), fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: Color(0xFF176BFF), size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildQuickOverview(context),
            const SizedBox(height: 24),
            const Text(
              'Structure Settings',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSettingsGrid(context),
            const SizedBox(height: 20),
            _buildBottomProgress(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.school, color: Color(0xFF06164A), size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sunshine Model Academy',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text('School Admin', style: TextStyle(color: Color(0xFF8190AA), fontSize: 12)),
                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF8190AA), size: 16),
                  ],
                ),
              ],
            ),
          ),
          _buildHeaderIcon(Icons.notifications_outlined, '8'),
          const SizedBox(width: 12),
          _buildHeaderIcon(Icons.mail_outline, '12'),
        ],
      ),
    );
  }

  Widget _buildModuleBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1B3B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A315B)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0D2554),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_tree_outlined, color: Color(0xFF176BFF), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Structure Module',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure and manage the foundation of your school in one place.',
                  style: TextStyle(color: const Color(0xFF8190AA), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF11A85B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF11A85B), shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                const Text('Active', style: TextStyle(color: Color(0xFF11A85B), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFF8190AA), size: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, String badge) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: const Color(0xFF0B1B3B), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Color(0xFFF04400), shape: BoxShape.circle),
            child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickOverview(BuildContext context) {
    return Row(
      children: [
        _buildOverviewTile(Icons.layers_outlined, '12', 'Configured\nItems', const Color(0xFF176BFF)),
        const SizedBox(width: 8),
        _buildOverviewTile(Icons.check_circle_outline, '8', 'Completed\nSections', const Color(0xFF11A85B)),
        const SizedBox(width: 8),
        _buildOverviewTile(Icons.schedule, '2', 'Pending\nSetup', const Color(0xFFFFB400)),
        const SizedBox(width: 8),
        _buildOverviewTile(Icons.pie_chart_outline, '85%', 'Setup\nProgress', const Color(0xFFBD00FF)),
      ],
    );
  }

  Widget _buildOverviewTile(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1B3B).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1A315B)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8190AA), fontSize: 10, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.0,
      children: [
        _buildGridTile(context, Icons.calendar_month, 'Academic Year', const Color(0xFF176BFF), '/staff/admin/structure/academic?tab=0'),
        _buildGridTile(context, Icons.event_note, 'Terms & Semesters', const Color(0xFFFFB400), '/staff/admin/structure/academic?tab=0'),
        _buildGridTile(context, Icons.menu_book, 'Academic Units', const Color(0xFFBD00FF), '/staff/admin/structure/academic?tab=1'),
        _buildGridTile(context, Icons.groups_outlined, 'Classes & Groups', const Color(0xFF11A85B), '/staff/admin/structure/academic?tab=1'),
        _buildGridTile(context, Icons.account_balance, 'Departments', const Color(0xFF00C8FF), '/staff/admin/structure/people?tab=0'),
        _buildGridTile(context, Icons.book_outlined, 'Subjects & Courses', const Color(0xFFFF3377), '/staff/admin/structure/academic?tab=2'),
        _buildGridTile(context, Icons.home_outlined, 'Houses', const Color(0xFFFFB400), '/staff/admin/structure/campus?tab=1'),
        _buildGridTile(context, Icons.apartment, 'Campuses', const Color(0xFF11A85B), '/staff/admin/structure/campus?tab=0'),
        _buildGridTile(context, Icons.schedule, 'Timetable Settings', const Color(0xFF176BFF), '/staff/admin/structure/operations'),
        _buildGridTile(context, Icons.calendar_today, 'School Calendar', const Color(0xFFFF3377), '/staff/calendar'),
        _buildGridTile(context, Icons.trending_up, 'Promotion Rules', const Color(0xFF11A85B), '/staff/admin/structure/assessment'),
        _buildGridTile(context, Icons.settings_outlined, 'More Settings', const Color(0xFFFFB400), '/staff/admin/structure/operations'),
      ],
    );
  }

  Widget _buildGridTile(BuildContext context, IconData icon, String title, Color color, String route) {
    return AppCard(
      onTap: () => context.push(route),
      padding: const EdgeInsets.all(8),
      color: const Color(0xFF0B1B3B).withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 11, 
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1B3B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A315B)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: 0.85,
                  strokeWidth: 4,
                  backgroundColor: Color(0xFF020716),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF176BFF)),
                ),
              ),
              const Text(
                '85%',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Structure Setup Progress',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  "You're doing great! Complete the remaining sections to finish school setup.",
                  style: TextStyle(color: Color(0xFF8190AA), fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF176BFF),
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 36),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Continue Setup', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
