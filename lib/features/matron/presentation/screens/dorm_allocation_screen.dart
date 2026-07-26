import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class DormAllocationScreen extends StatelessWidget {
  const DormAllocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dormitory Allocation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Unallocated Students (12)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _UnallocatedList(),
          const SizedBox(height: 24),
          const Text('Dormitory Capacity', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _DormCapacityGrid(),
        ],
      ),
    );
  }
}

class _UnallocatedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => AppCard(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(height: 4),
              Text('Student ${index + 1}', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DormCapacityGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _DormCard(name: 'Nile House', capacity: 50, occupied: 48),
        _DormCard(name: 'Kyoga House', capacity: 50, occupied: 42),
      ],
    );
  }
}

class _DormCard extends StatelessWidget {
  final String name;
  final int capacity;
  final int occupied;

  const _DormCard({required this.name, required this.capacity, required this.occupied});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('$occupied / $capacity', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Occupants', style: TextStyle(fontSize: 10)),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: occupied / capacity),
        ],
      ),
    );
  }
}
