import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../bloc/exam_factory_cubit.dart';

/// Shared scaffold for every Exam Factory screen: title, subtitle, a safe
/// back action for deep links with no Navigator history, and a status/error
/// aware body via [asyncBuilder] helpers used by the screens.
class ExamFactoryScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? action;
  final bool showBack;
  final String? backFallback;

  const ExamFactoryScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    this.showBack = true,
    this.backFallback,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExamFactoryCubit, ExamFactoryState>(
      listenWhen: (previous, current) =>
          !previous.queuedOffline && current.queuedOffline,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.cloud_off_outlined, size: 18, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Saved offline. It will sync automatically once you are back online.',
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.surfaceElevated(context),
          titleSpacing: 20,
          automaticallyImplyLeading: false,
          leading: showBack
              ? IconButton(
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      context.pop();
                    } else if (backFallback != null) {
                      context.go(backFallback!);
                    }
                  },
                )
              : null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleLarge.copyWith(fontSize: 21),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
            ],
          ),
          actions: action == null ? null : [action!],
        ),
        body: SafeArea(child: child),
      ),
    );
  }
}

class ExamFactoryLoading extends StatelessWidget {
  const ExamFactoryLoading({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class ExamFactoryEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  const ExamFactoryEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: AppColors.textMuted(context)),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    ),
  );
}

class ExamFactoryErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ExamFactoryErrorState({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 40, color: AppColors.danger(context)),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    ),
  );
}

/// A stream-driven body with loading, empty, and error states baked in so
/// every list screen behaves consistently.
class ExamFactoryStreamView<T> extends StatelessWidget {
  final Stream<List<T>> stream;
  final Widget Function(BuildContext, List<T>) builder;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final Widget? emptyAction;

  const ExamFactoryStreamView({
    super.key,
    required this.stream,
    required this.builder,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage = 'Items will appear here once available.',
    this.emptyAction,
  });

  @override
  Widget build(BuildContext context) => StreamBuilder<List<T>>(
    stream: stream,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const ExamFactoryLoading();
      }
      if (snapshot.hasError) {
        return ExamFactoryErrorState(message: _describe(snapshot.error));
      }
      final items = snapshot.data ?? const [];
      if (items.isEmpty) {
        return ExamFactoryEmpty(
          icon: emptyIcon,
          title: emptyTitle,
          message: emptyMessage,
          action: emptyAction,
        );
      }
      return builder(context, items);
    },
  );

  String _describe(Object? error) {
    final text = error.toString();
    if (text.contains('permission-denied')) {
      return 'You do not have permission to view this.';
    }
    return 'Could not load this data. Check your connection and try again.';
  }
}
