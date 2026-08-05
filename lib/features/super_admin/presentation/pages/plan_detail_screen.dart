import 'package:flutter/material.dart';

class PlanDetailScreen extends StatefulWidget {
  final String planName;
  const PlanDetailScreen({super.key, required this.planName});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060910),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildPlanHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildFeaturesTab(),
                  _buildLimitsTab(),
                  _buildSchoolsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          const Text(
            'Plan Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.token_outlined,
                  color: Color(0xFF6366F1),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.planName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF22C55E,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: Color(0xFF22C55E),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Advanced tools for established schools that need more flexibility and power.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'UGX 450,000',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/Month',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'UGX 4,500,000 /year',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(Save 17%)',
                style: TextStyle(
                  color: const Color(0xFF22C55E),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSimpleStat('22', 'Schools'),
              _buildStatDivider(),
              _buildSimpleStat('1,245', 'Total users'),
              _buildStatDivider(),
              _buildSimpleStat('96%', 'Adoption'),
              _buildStatDivider(),
              _buildSimpleStat('UGX 9.9M', 'MRR'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: false,
      indicatorColor: const Color(0xFF6366F1),
      indicatorWeight: 3,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withValues(alpha: 0.4),
      tabs: const [
        Tab(child: Text('Overview', style: TextStyle(fontSize: 13))),
        Tab(child: Text('Features', style: TextStyle(fontSize: 13))),
        Tab(child: Text('Limits', style: TextStyle(fontSize: 13))),
        Tab(child: Text('Schools', style: TextStyle(fontSize: 13))),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoCard('Plan Information', [
          _buildInfoRow('Plan ID', 'plan_professional_001'),
          _buildInfoRow('Status', 'Active', isStatus: true),
          _buildInfoRow('Billing Cycle', 'Monthly'),
          _buildInfoRow('Created', 'Feb 12, 2024'),
          _buildInfoRow('Last Updated', 'May 20, 2024'),
        ]),
        const SizedBox(height: 20),
        _buildSectionHeader('Description', null),
        const SizedBox(height: 12),
        Text(
          'The Professional Plan includes everything in Standard plus advanced reporting, more storage, custom branding, and priority support.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Included Features (24)', 'View all'),
        const SizedBox(height: 16),
        ...[
          'All Standard Plan features',
          'Advanced Reports',
          'Custom Branding',
          'API Access',
          'Priority Support',
        ].map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF22C55E),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  feature,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Features', 'Add Feature'),
        const SizedBox(height: 4),
        Text(
          'Manage what features are included in this plan',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 24),
        _buildFeatureItem(
          'Student Management',
          'Manage student information and records',
          Icons.people_outline,
          true,
          const Color(0xFF22C55E),
        ),
        _buildFeatureItem(
          'Attendance',
          'Track attendance with multiple methods',
          Icons.calendar_today_outlined,
          true,
          const Color(0xFF3B82F6),
        ),
        _buildFeatureItem(
          'Fee Management',
          'Manage fees, payments and invoices',
          Icons.account_balance_wallet_outlined,
          true,
          const Color(0xFFF59E0B),
        ),
        _buildFeatureItem(
          'Reports',
          'Generate academic and financial reports',
          Icons.bar_chart_outlined,
          true,
          const Color(0xFF8B5CF6),
        ),
        _buildFeatureItem(
          'Library Management',
          'Manage library resources and loans',
          Icons.menu_book_outlined,
          true,
          const Color(0xFF06B6D4),
        ),
        _buildFeatureItem(
          'Transport Management',
          'Manage transport and routes',
          Icons.directions_bus_outlined,
          true,
          const Color(0xFF10B981),
        ),
        _buildFeatureItem(
          'Parent Portal',
          'Parent access to student information',
          Icons.family_restroom_outlined,
          true,
          const Color(0xFFEC4899),
        ),
        _buildFeatureItem(
          'Mobile App Access',
          'Access via mobile applications',
          Icons.phone_android_outlined,
          true,
          const Color(0xFF6366F1),
        ),
        _buildFeatureItem(
          'Biometric Attendance',
          'Use biometrics for attendance',
          Icons.fingerprint_outlined,
          false,
          const Color(0xFFF97316),
        ),
        _buildFeatureItem(
          'AI Reports',
          'AI powered insights and reports',
          Icons.auto_awesome_outlined,
          false,
          const Color(0xFFA855F7),
        ),
      ],
    );
  }

  Widget _buildLimitsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Plan Limits', 'Edit Limits'),
        const SizedBox(height: 4),
        Text(
          'Set usage limits for this plan',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 24),
        _buildLimitItem('Maximum Students', '1,245 / 2,000', 0.62),
        const SizedBox(height: 24),
        _buildLimitItem('Maximum Staff', '125 / 200', 0.625),
        const SizedBox(height: 24),
        _buildLimitItem('Storage (GB)', '45 / 100', 0.45),
        const SizedBox(height: 24),
        _buildLimitItem('API Requests /day', '5k / 10k', 0.5),
      ],
    );
  }

  Widget _buildSchoolsTab() {
    return const Center(
      child: Text(
        'Schools using this plan',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionText,
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
          if (isStatus)
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    String title,
    String desc,
    IconData icon,
    bool enabled,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (v) {},
            activeColor: const Color(0xFF6366F1),
            activeTrackColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white.withValues(alpha: 0.5),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitItem(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
