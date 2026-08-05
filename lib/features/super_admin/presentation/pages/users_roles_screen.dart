import 'package:flutter/material.dart';

class UsersRolesScreen extends StatelessWidget {
  const UsersRolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060910),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Users & Roles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStatItem('Total Users', '18', const Color(0xFF312E81)),
                const SizedBox(width: 12),
                _buildStatItem('Active Users', '15', const Color(0xFF064E3B)),
                const SizedBox(width: 12),
                _buildStatItem('Roles', '8', const Color(0xFF1E293B)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Search users...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildTab('All Users', active: true),
                _buildTab('Platform Owners'),
                _buildTab('Support Staff'),
                _buildTab('View Only'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildUserTile(
                  name: 'Victor Bee',
                  role: 'Platform Owner',
                  email: 'victor@schoolpulse.com',
                  lastActive: 'Today, 8:42 AM',
                  status: 'Active',
                  imageUrl: 'https://i.pravatar.cc/150?u=1',
                ),
                _buildUserTile(
                  name: 'Grace Hankso',
                  role: 'Support Admin',
                  email: 'grace@schoolpulse.com',
                  lastActive: 'Today, 7:15 AM',
                  status: 'Active',
                  imageUrl: 'https://i.pravatar.cc/150?u=2',
                ),
                _buildUserTile(
                  name: 'John Kato',
                  role: 'Support Staff',
                  email: 'john@schoolpulse.com',
                  lastActive: 'Yesterday, 11:30 PM',
                  status: 'Active',
                  imageUrl: 'https://i.pravatar.cc/150?u=3',
                ),
                _buildUserTile(
                  name: 'Sarah Achieng',
                  role: 'Billing Manager',
                  email: 'sarah@schoolpulse.com',
                  lastActive: 'Yesterday, 2:10 PM',
                  status: 'Active',
                  imageUrl: 'https://i.pravatar.cc/150?u=4',
                ),
                _buildUserTile(
                  name: 'David Ochieng',
                  role: 'View Only',
                  email: 'david@schoolpulse.com',
                  lastActive: 'May 30, 2024',
                  status: 'Active',
                  imageUrl: 'https://i.pravatar.cc/150?u=5',
                ),
                _buildUserTile(
                  name: 'Mariam Nalubega',
                  role: 'Support Staff',
                  email: 'mariam@schoolpulse.com',
                  lastActive: 'May 20, 2024',
                  status: 'Inactive',
                  imageUrl: 'https://i.pravatar.cc/150?u=6',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, {bool active = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6366F1) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserTile({
    required String name,
    required String role,
    required String email,
    required String lastActive,
    required String status,
    required String imageUrl,
  }) {
    final bool isActive = status == 'Active';
    final Color statusColor = isActive
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA855F7).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Platform Owner',
                        style: TextStyle(
                          color: Color(0xFFA855F7),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Last active: $lastActive',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.2),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
