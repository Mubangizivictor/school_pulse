import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class CaEaBreakdownScreen extends StatelessWidget {
  const CaEaBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CA/EA Breakdown'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Text(
                    'Mathematics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success(context),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _BreakdownCard(
                        title: 'CA (40%)',
                        score: '40 / 40',
                        color: AppColors.primary(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _BreakdownCard(
                        title: 'EA (60%)',
                        score: '60 / 60',
                        color: AppColors.secondary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'CA Components',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                _ComponentItem(label: 'Class Tests (20)', value: '20'),
                _ComponentItem(label: 'Quizzes (10)', value: '10'),
                _ComponentItem(label: 'Assignments (10)', value: '10'),
                Divider(height: 32, color: AppColors.border(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total (CA)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      '40 / 40',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AppCard(
                  color: AppColors.success(context).withValues(alpha: 0.1),
                  borderColor: AppColors.success(context).withValues(alpha: 0.3),
                  child: Text(
                    'This will contribute 40% (up to 40 points) to the final score.',
                    style: TextStyle(
                      color: AppColors.success(context),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              label: 'Done',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final String title;
  final String score;
  final Color color;

  const _BreakdownCard({
    required this.title,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            score,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentItem extends StatelessWidget {
  final String label;
  final String value;

  const _ComponentItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
