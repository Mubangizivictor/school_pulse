import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance & Punctuality'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionHeader(title: 'Summary'),
                const SizedBox(height: 12),
                _AttendanceMetricItem(label: 'Days School Open', value: '60'),
                _AttendanceMetricItem(label: 'Days Present', value: '55'),
                _AttendanceMetricItem(label: 'Days Absent', value: '3'),
                _AttendanceMetricItem(label: 'Late Arrivals', value: '2'),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      const Text('Attendance Rate', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 16),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: 0.917,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey.shade200,
                              color: Colors.green,
                            ),
                          ),
                          const Column(
                            children: [
                              Text('91.7%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              label: 'Save & Next',
              onPressed: () => context.push('/teacher/reports/behaviour-conduct'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceMetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _AttendanceMetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
