import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClassMarksSummaryScreen extends StatelessWidget {
  const ClassMarksSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF0F172A);
    final surfaceColor = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Class Marks Summary', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mid Term Test', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildSummaryBox('Class Average', '64%', Colors.greenAccent),
                const SizedBox(width: 12),
                _buildSummaryBox('Highest Score', '36/40', Colors.white),
                const SizedBox(width: 12),
                _buildSummaryBox('Lowest Score', '18/40', Colors.white),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  _buildMiniTab('Overview', true),
                  _buildMiniTab('Distribution', false),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildStudentPerformanceList(surfaceColor),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Class Average', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('64%', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTab(String label, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF312E81) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildStudentPerformanceList(Color surfaceColor) {
    return Column(
      children: [
        _buildPerformanceItem('Akena Brian', '36/40', '90%', Colors.greenAccent),
        _buildPerformanceItem('Tusiime Kevin', '32/40', '80%', Colors.greenAccent),
        _buildPerformanceItem('Nanyonga Faith', '28/40', '70%', Colors.greenAccent),
        _buildPerformanceItem('Kamya Sharon', '24/40', '60%', Colors.orangeAccent),
        _buildPerformanceItem('Odhiambo James', '18/40', '45%', Colors.redAccent),
      ],
    );
  }

  Widget _buildPerformanceItem(String name, String marks, String percentage, Color pctColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(radius: 14, backgroundColor: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14))),
          Text(marks, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(width: 24),
          Text(percentage, style: TextStyle(color: pctColor, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(Icons.trending_up, color: Colors.green, size: 14),
        ],
      ),
    );
  }
}
