import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme.dart';

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
    _simulateGeneration();
  }

  void _simulateGeneration() async {
    final steps = [
      'Compiling student data...',
      'Calculating averages...',
      'Generating PDF layouts...',
      'Applying school branding...',
      'Finalizing reports...',
    ];

    for (int i = 0; i < steps.length; i++) {
      if (!mounted) return;
      setState(() {
        _status = steps[i];
        _progress = (i + 1) / steps.length;
      });
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (mounted) {
      context.pushReplacement('/teacher/reports/generated-success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Hero(
                tag: 'report_icon',
                child: Icon(
                  Icons.description_outlined,
                  size: 80,
                  color: SemanticColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Generating Reports',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we prepare the report cards for Primary 2 Gold.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              AppCard(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _progress,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_status, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('${(_progress * 100).toInt()}%'),
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
  }
}
