import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/login_flow/auth_chrome.dart';

/// Student Hub onboarding: access code, then a PIN the student chooses.
/// Presentation only - no auth wiring yet, so the CTA and "Sign In" link are
/// inert until the student auth flow is built.
class StudentHubScreen extends StatefulWidget {
  const StudentHubScreen({super.key});

  @override
  State<StudentHubScreen> createState() => _StudentHubScreenState();
}

class _StudentHubScreenState extends State<StudentHubScreen> {
  static const _accent = AppColors.emeraldGreen;

  /// The school office issues the PIN alongside the access code, so this is a
  /// fixed 4-digit entry rather than a PIN the student picks.
  static const _pinLength = 4;

  final _codeController = TextEditingController();
  final List<TextEditingController> _pinControllers = List.generate(
    _pinLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _pinFocus = List.generate(
    _pinLength,
    (_) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    // The boxes restyle themselves on focus, so a rebuild has to follow the
    // focus change as well as the text change.
    for (final node in _pinFocus) {
      node.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    for (final c in _pinControllers) {
      c.dispose();
    }
    for (final f in _pinFocus) {
      f.dispose();
    }
    super.dispose();
  }

  /// Advance to the next box as digits are typed, and step back on delete so
  /// the row behaves like a single field.
  void _onPinChanged(int index, String value) {
    if (value.isNotEmpty && index < _pinLength - 1) {
      _pinFocus[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _pinFocus[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AuthPortalScaffold(
      accent: _accent,
      children: [
        const _StudentBadge(),
        const SizedBox(height: AppSpacing.l),
        // Keep the portal mark legible against either app theme.
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTypography.headlineMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
            children: const [
              TextSpan(text: 'Student '),
              TextSpan(
                text: 'Hub',
                style: TextStyle(color: _accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          'Enter the code and PIN issued by\nyour school to get started.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.x2l),

        // Step 1 - access code
        _StepCard(
          step: 1,
          stepColor: AppColors.electricBlue,
          title: 'Enter Access Code',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: AppTypography.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. STU12345',
                  hintStyle: AppTypography.bodyLarge.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                  ),
                  prefixIcon: Icon(
                    Icons.vpn_key_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l,
                    vertical: AppSpacing.xl,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.14)
                          : AppColors.borderLight,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.electricBlue,
                      width: 1.6,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.14)
                          : AppColors.borderLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.brightCyan,
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      'Use the code provided by your school office.',
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Step 2 - PIN
        _StepCard(
          step: 2,
          stepColor: _accent,
          title: 'Enter Your PIN',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the 4-digit PIN issued with your access code.',
                style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              // Fixed-size squares rather than stretched cells, so the row
              // reads as a PIN entry instead of four wide text boxes.
              Row(
                children: [
                  for (var i = 0; i < _pinLength; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.l),
                    _pinBox(i),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x2l),

        AuthCtaButton(
          label: 'Continue',
          gradient: const [AppColors.royalBlue, _accent],
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.x2l),
        const _StudentScene(),
      ],
    );
  }

  Widget _pinBox(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final filled = _pinControllers[index].text.isNotEmpty;
    final focused = _pinFocus[index].hasFocus;

    return SizedBox(
      width: 56,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: focused ? 0.08 : 0.04)
              : colors.surfaceContainerHighest.withValues(
                  alpha: focused ? 0.8 : 0.55,
                ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: focused
                ? _accent
                : filled
                ? _accent.withValues(alpha: 0.6)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.22)
                      : AppColors.borderLight),
            width: focused ? 2 : 1.2,
          ),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: TextField(
          controller: _pinControllers[index],
          focusNode: _pinFocus[index],
          onChanged: (v) => _onPinChanged(index, v),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          obscureText: true,
          obscuringCharacter: '•',
          showCursor: false,
          style: AppTypography.headlineSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
          // The global InputDecorationTheme fills and outlines every field.
          // Both are cleared here - every border state, not just `border` -
          // so only the surrounding container is visible.
          decoration: const InputDecoration(
            counterText: '',
            filled: false,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            isCollapsed: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

/// Graduation-cap badge flanked by the circuit traces from the reference.
class _StudentBadge extends StatelessWidget {
  const _StudentBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _TracePainter())),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgDark,
              border: Border.all(color: AppColors.emeraldGreen, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emeraldGreen.withValues(alpha: 0.5),
                  blurRadius: 26,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 34,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TracePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final dot = Paint();

    // Mirrored traces running out from behind the badge on both sides.
    for (final dir in [-1.0, 1.0]) {
      final start = size.width / 2 + dir * 46;
      for (final spec in [
        (dy: -9.0, len: 46.0),
        (dy: 0.0, len: 62.0),
        (dy: 9.0, len: 46.0),
      ]) {
        final end = start + dir * spec.len;
        stroke.color = (dir < 0 ? AppColors.brightCyan : AppColors.emeraldGreen)
            .withValues(alpha: 0.55);
        canvas.drawLine(
          Offset(start, cy + spec.dy),
          Offset(end, cy + spec.dy),
          stroke,
        );
        dot.color = (dir < 0 ? AppColors.brightCyan : AppColors.emeraldGreen);
        canvas.drawCircle(Offset(end, cy + spec.dy), 2.2, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_TracePainter oldDelegate) => false;
}

/// Numbered step container used for the two onboarding stages.
class _StepCard extends StatelessWidget {
  final int step;
  final Color stepColor;
  final String title;
  final Widget child;

  const _StepCard({
    required this.step,
    required this.stepColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : colors.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: stepColor.withValues(alpha: 0.18),
                  border: Border.all(color: stepColor, width: 1.4),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$step',
                  style: AppTypography.labelLarge.copyWith(
                    color: stepColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          child,
        ],
      ),
    );
  }
}

/// Line-art learning scene closing the page: a school flanked by floating
/// study motifs on a field of stars.
class _StudentScene extends StatelessWidget {
  const _StudentScene();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(child: CustomPaint(painter: _StudentScenePainter())),
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _SceneGlyph(
                  icon: Icons.menu_book_outlined,
                  size: 26,
                  bottom: 44,
                ),
                _SceneGlyph(
                  icon: Icons.emoji_events_outlined,
                  size: 28,
                  bottom: 62,
                ),
                _SceneGlyph(
                  icon: Icons.lightbulb_outline,
                  size: 26,
                  bottom: 40,
                ),
                _SceneGlyph(icon: Icons.public_outlined, size: 30, bottom: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneGlyph extends StatelessWidget {
  final IconData icon;
  final double size;
  final double bottom;

  const _SceneGlyph({
    required this.icon,
    required this.size,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Icon(
        icon,
        size: size,
        color: AppColors.brightCyan.withValues(alpha: 0.55),
      ),
    );
  }
}

class _StudentScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..color = AppColors.brightCyan.withValues(alpha: 0.5);

    // Small schoolhouse centred on the baseline.
    final cx = size.width / 2;
    final baseY = size.height - 6;
    const bw = 66.0;
    const bh = 44.0;
    canvas.drawRect(Rect.fromLTWH(cx - bw / 2, baseY - bh, bw, bh), stroke);
    canvas.drawPath(
      Path()
        ..moveTo(cx - bw / 2 - 5, baseY - bh)
        ..lineTo(cx, baseY - bh - 20)
        ..lineTo(cx + bw / 2 + 5, baseY - bh)
        ..close(),
      stroke,
    );
    canvas.drawLine(
      Offset(cx, baseY - bh - 20),
      Offset(cx, baseY - bh - 34),
      stroke,
    );
    canvas.drawRect(Rect.fromLTWH(cx - 8, baseY - 22, 16, 22), stroke);

    // Star field behind the scene.
    final dot = Paint();
    for (var i = 0; i < 46; i++) {
      final x = (i * 71.0) % size.width;
      final y = (i * 43.0) % (size.height * 0.85);
      dot.color = AppColors.brightCyan.withValues(
        alpha: 0.10 + ((i % 5) * 0.06),
      );
      canvas.drawCircle(Offset(x, y), 1.1, dot);
    }
  }

  @override
  bool shouldRepaint(_StudentScenePainter oldDelegate) => false;
}
