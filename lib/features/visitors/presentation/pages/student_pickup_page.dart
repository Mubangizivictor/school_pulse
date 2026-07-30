import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';
import 'package:school_pulse/features/visitors/presentation/widgets/signature_pad.dart';
import '../bloc/visitors_bloc.dart';
import '../bloc/visitors_event.dart';
import '../../domain/entities/visitor.dart';
import 'package:uuid/uuid.dart';

class StudentPickupPage extends StatefulWidget {
  const StudentPickupPage({super.key});

  @override
  State<StudentPickupPage> createState() => _StudentPickupPageState();
}

class _StudentPickupPageState extends State<StudentPickupPage> {
  final _searchController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();

  Student? _selectedStudent;
  bool _isVerified = false;

  void _submitPickup() {
    if (_selectedStudent == null || !_isVerified) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final visitor = Visitor(
      id: const Uuid().v4(),
      schoolId: authState.user.schoolId,
      fullName: _guardianNameController.text,
      phone: _phoneController.text,
      host: _selectedStudent!.name,
      department: 'Student Pickup',
      purpose: 'Picking up student: ${_selectedStudent!.name} (${_selectedStudent!.studentId})',
      category: VisitorCategory.parent,
      arrivalTime: DateTime.now(),
      status: VisitorStatus.checkedIn,
      deviceId: 'local_device',
      studentId: _selectedStudent!.id,
    );

    context.read<VisitorsBloc>().add(CheckInNewVisitor(visitor));
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pickup logged for ${_selectedStudent!.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Pickup Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Search Student', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter Student ID or Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      context.read<StudentsBloc>().add(SearchStudents(_searchController.text));
                    }
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<StudentsBloc>().add(SearchStudents(value));
                }
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<StudentsBloc, StudentsState>(
              builder: (context, state) {
                if (state is StudentsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is StudentsError) {
                  return Text(state.message, style: const TextStyle(color: Colors.red));
                } else if (state is StudentsLoaded) {
                  if (state.students.isEmpty) {
                    return const Text('No students found.');
                  }
                  return Column(
                    children: state.students.map((student) => ListTile(
                      title: Text(student.name),
                      subtitle: Text('${student.className} - ${student.studentId}'),
                      trailing: _selectedStudent?.id == student.id 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedStudent = student;
                        });
                      },
                    )).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            if (_selectedStudent != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 30, child: Icon(Icons.school)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedStudent!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Class: ${_selectedStudent!.className}'),
                            Text('ID: ${_selectedStudent!.studentId}'),
                          ],
                        ),
                      ),
                      const Icon(Icons.verified, color: Colors.green),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Guardian Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _guardianNameController,
                decoration: const InputDecoration(labelText: 'Guardian Full Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _relationController,
                decoration: const InputDecoration(labelText: 'Relationship to Student', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              const Text('Guardian Signature', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SignaturePad(onChanged: (img) => setState(() => _isVerified = img != null)),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Confirm & Log Pickup',
                onPressed: _isVerified ? _submitPickup : null,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
