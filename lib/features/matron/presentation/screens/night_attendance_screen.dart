import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class NightAttendanceScreen extends StatefulWidget {
  const NightAttendanceScreen({super.key});

  @override
  State<NightAttendanceScreen> createState() => _NightAttendanceScreenState();
}

class _NightAttendanceScreenState extends State<NightAttendanceScreen> {
  final Map<int, bool> _attendance = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Night Attendance'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.save)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Dormitory'),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Nile House')),
                DropdownMenuItem(value: '2', child: Text('Kyoga House')),
              ],
              onChanged: (v) {},
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => CheckboxListTile(
                title: Text('Student Name ${index + 1}'),
                subtitle: const Text('Bed 12-A'),
                value: _attendance[index] ?? false,
                onChanged: (val) => setState(() => _attendance[index] = val ?? false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
