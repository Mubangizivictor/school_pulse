import 'package:flutter/material.dart';
import 'package:school_pulse/features/approvals/presentation/screens/approval_center_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/qa/marks_qa_screen.dart';

class DeanApprovalsScreen extends StatefulWidget {
  const DeanApprovalsScreen({super.key});

  @override
  State<DeanApprovalsScreen> createState() => _DeanApprovalsScreenState();
}

class _DeanApprovalsScreenState extends State<DeanApprovalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Approvals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Report Cards'),
            Tab(text: 'Assessments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_ReportCardApprovals(), _AssessmentApprovals()],
      ),
    );
  }
}

class _ReportCardApprovals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ApprovalCenterScreen(
      moduleKeyFilter: 'academics',
      title: 'Report Card Approvals',
    );
  }
}

class _AssessmentApprovals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MarksQAScreen();
  }
}
