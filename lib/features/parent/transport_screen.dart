import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/transport/presentation/bloc/transport_bloc.dart';
import 'package:school_pulse/features/transport/presentation/bloc/transport_event.dart';
import 'package:school_pulse/features/transport/presentation/bloc/transport_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final studentState = context.read<SelectedStudentBloc>().state;
    if (studentState is SelectedStudentLoaded) {
      context.read<TransportBloc>().add(FetchTransportInfo(studentState.student.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: const StudentAppBar(title: 'Transport'),
      body: BlocListener<SelectedStudentBloc, SelectedStudentState>(
        listener: (context, state) {
          if (state is SelectedStudentLoaded) {
            context.read<TransportBloc>().add(FetchTransportInfo(state.student.id));
          }
        },
        child: BlocBuilder<TransportBloc, TransportState>(
          builder: (context, state) {
            if (state is TransportLoading || state is TransportInitial) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Skeleton(height: 120),
                  const SizedBox(height: 24),
                  const Skeleton(height: 24, width: 150),
                  const SizedBox(height: 12),
                  const Skeleton(height: 300),
                ],
              );
            } else if (state is TransportError) {
              return EmptyState(
                icon: Icons.no_transfer_outlined,
                title: 'No transport info',
                message: state.message,
                ctaLabel: 'Retry',
                onCtaPressed: _fetchData,
              );
            } else if (state is TransportLoaded) {
              final transport = state.info;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FadeInSlide(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Today\'s Status',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              StatusBadge(label: transport.status, color: semanticColors.info),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildRouteInfo(context, Icons.directions_bus, 'Route', transport.routeName),
                          const SizedBox(height: 12),
                          _buildRouteInfo(context, Icons.location_on, 'Assigned Stop', transport.stopName),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 100),
                    child: SectionHeader(title: 'Live Tracking'),
                  ),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 200),
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 300,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                                        Theme.of(context).colorScheme.surfaceContainerHighest,
                                      ],
                                    ),
                                  ),
                                  child: CustomPaint(
                                    painter: _RoutePathPainter(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.satellite_alt_outlined, size: 14, color: semanticColors.info),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Live GPS tracking · coming soon',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const AnimatedBusMarker(),
                              PositionDescriptor(
                                top: 220,
                                left: 60,
                                child: Column(
                                  children: [
                                    Icon(Icons.person_pin_circle, color: semanticColors.error, size: 32),
                                    Text(
                                      'Home',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 300),
                    child: SecondaryButton(
                      label: 'Contact Transport Coordinator',
                      icon: Icons.chat_bubble_outline,
                      onPressed: () => context.push('/parent/messages'),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildRouteInfo(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AnimatedBusMarker extends StatefulWidget {
  const AnimatedBusMarker({super.key});

  @override
  State<AnimatedBusMarker> createState() => _AnimatedBusMarkerState();
}

class _AnimatedBusMarkerState extends State<AnimatedBusMarker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: 100 + (50 * _animation.value),
          left: 150 - (70 * _animation.value),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Bus 04',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(Icons.directions_bus, color: Theme.of(context).colorScheme.primary, size: 32),
            ],
          ),
        );
      },
    );
  }
}

class PositionDescriptor extends StatelessWidget {
  final double? top;
  final double? left;
  final Widget child;

  const PositionDescriptor({super.key, this.top, this.left, required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned(top: top, left: left, child: child);
  }
}

class _RoutePathPainter extends CustomPainter {
  final Color color;

  _RoutePathPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.35, size.height * 0.45,
        size.width * 0.6, size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 0.36,
        size.width * 0.78, size.height * 0.18,
      );

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePathPainter oldDelegate) => oldDelegate.color != color;
}
