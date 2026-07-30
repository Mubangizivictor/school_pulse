import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../student/domain/entities/student.dart';
import '../bloc/student_identity_bloc.dart';
import '../bloc/student_identity_event.dart';
import '../bloc/student_identity_state.dart';
import '../../domain/services/id_card_service.dart';
import 'package:get_it/get_it.dart';
import 'package:school_pulse/core/theme_provider.dart';

class StudentIdCardScreen extends StatefulWidget {
  final Student student;

  const StudentIdCardScreen({super.key, required this.student});

  @override
  State<StudentIdCardScreen> createState() => _StudentIdCardScreenState();
}

class _StudentIdCardScreenState extends State<StudentIdCardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentIdentityBloc>().add(LoadStudentIdentityEvent(widget.student.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student ID Card'),
        actions: [
          BlocBuilder<StudentIdentityBloc, StudentIdentityState>(
            builder: (context, state) {
              if (state is StudentIdentityLoaded) {
                return IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () => _printIdCard(context, state.identity),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<StudentIdentityBloc, StudentIdentityState>(
        listener: (context, state) {
          if (state is StudentIdentityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is StudentIdentityLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StudentIdentityLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    _IdCardPreview(
                      student: widget.student,
                      identity: state.identity,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _printIdCard(context, state.identity),
                      icon: const Icon(Icons.print),
                      label: const Text('Print ID Card'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is StudentIdentityError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<StudentIdentityBloc>().add(
                            GenerateStudentIdentityEvent(widget.student),
                          );
                    },
                    child: const Text('Generate Identity'),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: ElevatedButton(
              onPressed: () {
                context.read<StudentIdentityBloc>().add(
                      GenerateStudentIdentityEvent(widget.student),
                    );
              },
              child: const Text('Generate Student ID'),
            ),
          );
        },
      ),
    );
  }

  Future<void> _printIdCard(BuildContext context, dynamic identity) async {
    final idCardService = GetIt.I<IdCardService>();
    final schoolName = context.read<ThemeProvider>().config?.schoolName ?? 'School Pulse Academy';
    try {
      final pdfData = await idCardService.generateIdCardPdf(
        schoolName: schoolName,
        studentName: widget.student.name,
        admissionNumber: widget.student.studentId,
        studentId: identity.uniqueSystemId,
        className: widget.student.className,
        stream: '', // Assuming stream is part of className or not available yet
        uniqueSystemId: identity.uniqueSystemId,
      );
      await idCardService.printIdCard(pdfData);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to print ID card: $e')),
        );
      }
    }
  }
}

class _IdCardPreview extends StatelessWidget {
  final Student student;
  final dynamic identity;

  const _IdCardPreview({
    required this.student,
    required this.identity,
  });

  @override
  Widget build(BuildContext context) {
    final schoolName = context.watch<ThemeProvider>().config?.schoolName ?? 'SCHOOL PULSE ACADEMY';
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              schoolName.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: student.photoUrl != null
                  ? NetworkImage(student.photoUrl!)
                  : null,
              child: student.photoUrl == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              student.name.toUpperCase(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 32),
            _buildInfoRow('Admission No', student.studentId),
            _buildInfoRow('Class', student.className),
            _buildInfoRow('System ID', identity.uniqueSystemId),
            const SizedBox(height: 24),
            QrImageView(
              data: identity.uniqueSystemId,
              version: QrVersions.auto,
              size: 120.0,
            ),
            const SizedBox(height: 8),
            Text(
              identity.uniqueSystemId,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}
