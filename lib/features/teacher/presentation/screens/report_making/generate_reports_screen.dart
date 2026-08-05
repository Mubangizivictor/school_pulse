import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_state.dart';

class GenerateReportsScreen extends StatefulWidget {
  const GenerateReportsScreen({super.key});

  @override
  State<GenerateReportsScreen> createState() => _GenerateReportsScreenState();
}

class _GenerateReportsScreenState extends State<GenerateReportsScreen> {
  double _progress = 0.0;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportWizardBloc>().add(ReportWizardSubmitRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportWizardBloc, ReportWizardState>(
      listener: (context, state) {
        if (state.status == ReportWizardStatus.success) {
          context.pushReplacement('/staff/reports/generated-success');
        } else if (state.status == ReportWizardStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Generation failed')),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        final steps = [
          'Compiling student data...',
          'Calculating averages...',
          'Generating PDF layouts...',
          'Applying school branding...',
          'Finalizing reports...',
        ];

        // Derived progress from status and steps
        double progress = 0.0;
        String statusText = 'Initializing...';

        if (state.status == ReportWizardStatus.loading) {
          // Since it's a batch firestore write, it might be fast.
          // We'll keep the visual simulation if we want, or just show a spinner.
          // For now let's just show a simple progress based on "loading"
          progress = 0.5;
          statusText = 'Saving reports to Firestore...';
        }

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'report_icon',
                    child: Icon(
                      Icons.description_outlined,
                      size: 80,
                      color: AppColors.primary(context),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Generating Reports',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we prepare the report cards for ${state.selectedClassName ?? 'selected class'}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 48),
                  AppCard(
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: state.status == ReportWizardStatus.loading
                              ? null
                              : 1.0,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              statusText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (state.status == ReportWizardStatus.loading)
                              const Text('Working...')
                            else
                              Text('100%'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
