import 'package:flutter/material.dart';

class SupportTicketsScreen extends StatelessWidget {
  const SupportTicketsScreen({super.key});

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
          'Support & Tickets',
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
                _buildStatItem('Total Tickets', '24', const Color(0xFF312E81)),
                const SizedBox(width: 8),
                _buildStatItem('Open', '8', const Color(0xFF064E3B)),
                const SizedBox(width: 8),
                _buildStatItem('In Progress', '6', const Color(0xFF450A0A)),
                const SizedBox(width: 8),
                _buildStatItem('Resolved', '10', const Color(0xFF1E293B)),
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
                          'Search tickets...',
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
                _buildTab('All Tickets', active: true),
                _buildTab('Open'),
                _buildTab('In Progress'),
                _buildTab('Resolved'),
                _buildTab('Closed'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildTicketTile(
                  id: '#TKT-2024-1256',
                  school: 'Greenfield High School',
                  issue: 'Login issue for school admin',
                  priority: 'High',
                  status: 'Open',
                  date: 'May 31, 2024',
                ),
                _buildTicketTile(
                  id: '#TKT-2024-1255',
                  school: 'St. Mary\'s Academy',
                  issue: 'Unable to generate reports',
                  priority: 'Medium',
                  status: 'In Progress',
                  date: 'May 30, 2024',
                ),
                _buildTicketTile(
                  id: '#TKT-2024-1254',
                  school: 'Hope Valley School',
                  issue: 'Payment not reflecting',
                  priority: 'High',
                  status: 'Open',
                  date: 'May 30, 2024',
                ),
                _buildTicketTile(
                  id: '#TKT-2024-1253',
                  school: 'Bright Future Academy',
                  issue: 'Feature request for parent portal',
                  priority: 'Low',
                  status: 'Resolved',
                  date: 'May 29, 2024',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Ticket',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

  Widget _buildTicketTile({
    required String id,
    required String school,
    required String issue,
    required String priority,
    required String status,
    required String date,
  }) {
    Color statusColor;
    Color statusBg;
    switch (status) {
      case 'Open':
        statusColor = const Color(0xFFF59E0B);
        statusBg = const Color(0xFFF59E0B).withValues(alpha: 0.1);
        break;
      case 'In Progress':
        statusColor = const Color(0xFF3B82F6);
        statusBg = const Color(0xFF3B82F6).withValues(alpha: 0.1);
        break;
      case 'Resolved':
        statusColor = const Color(0xFF10B981);
        statusBg = const Color(0xFF10B981).withValues(alpha: 0.1);
        break;
      default:
        statusColor = Colors.white;
        statusBg = Colors.white.withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'School: $school',
            style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            issue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Priority: ',
                    style: TextStyle(color: Color(0x66FFFFFF), fontSize: 11),
                  ),
                  Text(
                    priority,
                    style: TextStyle(
                      color: priority == 'High'
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFF59E0B),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'Created: $date',
                style: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
