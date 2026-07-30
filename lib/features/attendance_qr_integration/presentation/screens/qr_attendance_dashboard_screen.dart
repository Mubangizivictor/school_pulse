import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../qr_scanner/presentation/screens/qr_scanner_screen.dart';
import '../../../qr_scanner/domain/entities/scanner_mode.dart';
import '../bloc/attendance_qr_bloc.dart';
import '../bloc/attendance_qr_event.dart';
import '../bloc/attendance_qr_state.dart';
import 'attendance_confirmation_screen.dart';

class QrAttendanceDashboardScreen extends StatelessWidget {
  const QrAttendanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<AttendanceQrBloc>().add(SyncAttendanceEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<AttendanceQrBloc, AttendanceQrState>(
        listener: (context, state) {
          if (state is StudentScannedSuccess) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AttendanceConfirmationScreen(
                  student: state.student,
                  module: 'Class Attendance', // This could be selectable
                ),
              ),
            );
          } else if (state is AttendanceSyncSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance synced successfully!')),
            );
          } else if (state is AttendanceQrError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatCard(
                  context,
                  title: 'Ready to Scan',
                  subtitle: 'Students must present their ID cards',
                  icon: Icons.qr_code_scanner,
                  color: Theme.of(context).primaryColor,
                  onTap: () => _openScanner(context),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Sync Status',
                        subtitle: 'Local logs pending',
                        icon: Icons.cloud_upload,
                        color: Colors.orange,
                        onTap: () => context.read<AttendanceQrBloc>().add(SyncAttendanceEvent()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Reports',
                        subtitle: 'Export to Sheets',
                        icon: Icons.table_chart,
                        color: Colors.green,
                        onTap: () async {
                          final recordsResult = await context.read<AttendanceQrBloc>().attendanceRepository.getPendingSyncRecords();
                          recordsResult.fold(
                            (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
                            (records) {
                              if (records.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No records to export.')));
                                return;
                              }
                              // Trigger export logic
                              // For simplicity, showing a dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Export Attendance'),
                                  content: Text('Export ${records.length} records to Google Sheets?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Invoke GoogleSheetsService via Bloc or direct
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export started...')));
                                      },
                                      child: const Text('Export'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _openScanner(context),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('START SCANNING'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrScannerScreen(
          mode: ScannerMode.attendance,
          onScan: (code) {
            context.read<AttendanceQrBloc>().add(ScanStudentQrEvent(code));
            Navigator.of(context).pop(); // Close scanner once code is read
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
