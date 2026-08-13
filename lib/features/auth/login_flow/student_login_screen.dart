import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

/// Student Hub access screen.
///
/// This remains deliberately presentation-only until a student authentication
/// use case is introduced; it provides only local input validation.
class StudentHubScreen extends StatefulWidget {
  const StudentHubScreen({super.key});

  @override
  State<StudentHubScreen> createState() => _StudentHubScreenState();
}

class _StudentHubScreenState extends State<StudentHubScreen> {
  static const _pinLength = 4;

  final _codeController = TextEditingController();
  final _pinControllers = List.generate(
    _pinLength,
    (_) => TextEditingController(),
  );
  final _pinFocusNodes = List.generate(_pinLength, (_) => FocusNode());
  String? _codeError;
  String? _pinError;

  @override
  void initState() {
    super.initState();
    for (final node in _pinFocusNodes) {
      node.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    for (final controller in _pinControllers) {
      controller.dispose();
    }
    for (final node in _pinFocusNodes) {
      node
        ..removeListener(_refresh)
        ..dispose();
    }
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _submit() {
    final code = _codeController.text.trim();
    final pin = _pinControllers.map((controller) => controller.text).join();
    setState(() {
      _codeError = code.isEmpty ? 'Enter your access code.' : null;
      _pinError = pin.length == _pinLength ? null : 'Enter your 4-digit PIN.';
    });
  }

  void _onPinChanged(int index, String value) {
    if (value.length > 1) {
      _distributePin(value);
      return;
    }
    if (value.isNotEmpty && index < _pinLength - 1) {
      _pinFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _pinFocusNodes[index - 1].requestFocus();
    }
    if (_pinError != null) _pinError = null;
    _refresh();
  }

  void _distributePin(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    for (var i = 0; i < _pinLength; i++) {
      _pinControllers[i].text = i < digits.length ? digits[i] : '';
    }
    _pinFocusNodes[digits.length.clamp(1, _pinLength) - 1].requestFocus();
    _pinError = null;
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const accent = AppColors.emeraldGreen;

    return Scaffold(
      backgroundColor: colors.brightness == Brightness.dark
          ? colors.surface
          : AppColors.surfaceLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(28, 4, 28, AppSpacing.x4l),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewport.maxHeight - 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.canPop()
                              ? context.pop()
                              : context.go('/welcome'),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: colors.onSurface,
                            size: 32,
                          ),
                          tooltip: 'Back',
                        ),
                      ),
                      const SizedBox(height: 26),
                      const _StudentBadge(),
                      const SizedBox(height: AppSpacing.xl),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTypography.headlineLarge.copyWith(
                            color: colors.onSurface,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                          children: const [
                            TextSpan(text: 'Student '),
                            TextSpan(
                              text: 'Hub',
                              style: TextStyle(color: accent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Text(
                        'Enter the code and PIN issued by\nyour school to get started.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 16,
                          height: 1.5,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _AccessCodeCard(
                        controller: _codeController,
                        errorText: _codeError,
                        onChanged: (_) {
                          if (_codeError != null) {
                            setState(() => _codeError = null);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.x4l),
                      _PinCard(
                        controllers: _pinControllers,
                        focusNodes: _pinFocusNodes,
                        errorText: _pinError,
                        onChanged: _onPinChanged,
                      ),
                      const SizedBox(height: AppSpacing.x4l),
                      _ContinueButton(onPressed: _submit),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentBadge extends StatelessWidget {
  const _StudentBadge();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldGreen.withValues(alpha: .18),
            blurRadius: 26,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.school_rounded,
        color: AppColors.emeraldGreen,
        size: 38,
      ),
    ),
  );
}

class _AccessCodeCard extends StatelessWidget {
  const _AccessCodeCard({
    required this.controller,
    required this.errorText,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => _StepCard(
    step: 1,
    title: 'Access Code',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 35),
          child: Text(
            'Enter the access code provided by your school.',
            style: _descriptionStyle(context),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        TextField(
          controller: controller,
          onChanged: onChanged,
          textCapitalization: TextCapitalization.characters,
          style: AppTypography.bodyLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
          decoration: _fieldDecoration(
            context,
            hint: 'e.g. STU12345',
            icon: Icons.vpn_key_outlined,
            errorText: errorText,
          ),
        ),
      ],
    ),
  );
}

class _PinCard extends StatelessWidget {
  const _PinCard({
    required this.controllers,
    required this.focusNodes,
    required this.errorText,
    required this.onChanged,
  });
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final String? errorText;
  final void Function(int, String) onChanged;

  @override
  Widget build(BuildContext context) => _StepCard(
    step: 2,
    title: 'Your PIN',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 35),
          child: Text(
            'Enter the 4-digit PIN issued with your access code.',
            style: _descriptionStyle(context),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        LayoutBuilder(
          builder: (context, constraints) {
            // Keep the four-cell rhythm identical on wide browser windows;
            // only use the full available width when a mobile viewport needs it.
            final pinRowWidth = constraints.maxWidth > 320
                ? 320.0
                : constraints.maxWidth;
            final cellWidth = ((pinRowWidth - 72) / 4).clamp(44.0, 50.0);
            return SizedBox(
              width: pinRowWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                  (index) => _PinCell(
                    width: cellWidth,
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    onChanged: (value) => onChanged(index, value),
                  ),
                ),
              ),
            );
          },
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.m),
          Text(
            errorText!,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    ),
  );
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.title,
    required this.child,
  });
  final int step;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: .75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .015),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.emeraldGreen, width: 2),
                ),
                child: Text(
                  '$step',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.emeraldGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Text(
                title,
                style: AppTypography.headlineSmall.copyWith(
                  color: colors.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _PinCell extends StatelessWidget {
  const _PinCell({
    required this.width,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });
  final double width;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;
    final filled = controller.text.isNotEmpty;
    return SizedBox(
      width: width,
      height: 52,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: focused ? AppColors.emeraldGreen : AppColors.borderLight,
            width: focused ? 1.8 : 1.4,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 4,
              obscureText: true,
              showCursor: false,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.transparent, fontSize: 16),
              decoration: const InputDecoration(
                counterText: '',
                isCollapsed: true,
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            IgnorePointer(
              child: Text(
                '•',
                style: TextStyle(
                  color: filled
                      ? AppColors.emeraldGreen
                      : Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: .42),
                  fontSize: 22,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 58,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF18B4A4), AppColors.emeraldGreen],
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'Continue',
                style: AppTypography.headlineSmall.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Positioned(
                right: AppSpacing.x2l,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

TextStyle _descriptionStyle(BuildContext context) =>
    AppTypography.bodyLarge.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 11,
      height: 1.45,
      letterSpacing: 0,
    );

InputDecoration _fieldDecoration(
  BuildContext context, {
  required String hint,
  required IconData icon,
  String? errorText,
}) => InputDecoration(
  hintText: hint,
  errorText: errorText,
  prefixIcon: Icon(
    icon,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
    size: 24,
  ),
  hintStyle: AppTypography.bodyLarge.copyWith(
    color: Theme.of(
      context,
    ).colorScheme.onSurfaceVariant.withValues(alpha: .62),
    fontSize: 14,
    letterSpacing: 0,
  ),
  contentPadding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.x2l,
    vertical: 13,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.borderLight, width: 1.4),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.emeraldGreen, width: 1.8),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: Theme.of(context).colorScheme.error,
      width: 1.8,
    ),
  ),
);
