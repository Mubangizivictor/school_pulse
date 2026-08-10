import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReviewSubmitScreen extends StatelessWidget {
  const ReviewSubmitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            const Text(
              'Review & Submit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Mid Term Test • Section A',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Total Students', '28'),
            _buildSummaryRow('Marks Entered', '8', valueColor: Colors.white),
            _buildSummaryRow('Marks Pending', '20', valueColor: Colors.orange),
            _buildSummaryRow('Maximum Mark', '20'),
            const SizedBox(height: 32),
            const Text(
              'Quick Preview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPreviewItem('1', 'Akena Brian', '16/20'),
            _buildPreviewItem('2', 'Nanyonga Faith', '14/20'),
            _buildPreviewItem('3', 'Odhiambo James', '9/20'),
            const Padding(
              padding: EdgeInsets.only(left: 32, top: 8),
              child: Text(
                '... and 25 more students',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF334155).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF818CF8), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Once submitted, marks will be locked for editing.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marks submitted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.go('/staff/marks');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4338CA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Marks',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color valueColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String rank, String name, String score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$rank.',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            score,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
