import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/data/datasources/remembered_login_store.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/branding/presentation/widgets/school_badge.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Detected school identity for the in-progress "Connect to school" flow.
/// Only ever populated from a server-verified access code - never trust a
/// client-derived guess at which school a code belongs to.
class _DetectedSchool {
  final String schoolId;
  final String schoolName;
  final String location;
  final String? badgeUrl;

  const _DetectedSchool({
    required this.schoolId,
    required this.schoolName,
    required this.location,
    this.badgeUrl,
  });
}

/// Shared native-iOS chrome for the three "Connect to school" steps: centered
/// nav title, back chevron, soft off-white background, generous safe-area
/// spacing.
class _ConnectToSchoolScaffold extends StatelessWidget {
  final Widget child;
  final Widget footer;

  const _ConnectToSchoolScaffold({required this.child, required this.footer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.chevron_left,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Connect to school',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.x2l,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: child,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.l,
              ),
              child: footer,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ScreenHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// One row inside an inset grouped section - subtle separators, no card
/// shadow, matching native iOS Settings-style forms.
class _InsetGroup extends StatelessWidget {
  final List<Widget> children;

  const _InsetGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: AppSpacing.xl,
                color: AppColors.border(context),
              ),
          ],
        ],
      ),
    );
  }
}

class _InsetLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const _InsetLabel({required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.l,
        AppSpacing.xl,
        AppSpacing.xs,
      ),
      child: RichText(
        text: TextSpan(
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary(context),
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(text: label),
            if (isRequired)
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.danger(context)),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundedBlackButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _RoundedBlackButton({
    required this.label,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AppColors.white : AppColors.black;
    final foreground = isDark ? AppColors.black : AppColors.white;
    final disabledFill = AppColors.border(context);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: SizedBox(
        height: 52,
        child: Material(
          color: enabled ? fill : disabledFill,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(
                          enabled
                              ? foreground
                              : AppColors.textSecondary(context),
                        ),
                      ),
                    )
                  : Text(
                      label,
                      style: AppTypography.titleMedium.copyWith(
                        color: enabled
                            ? foreground
                            : AppColors.textSecondary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Looks up a school's display name, location, and badge for a detected
/// schoolId. Never exposes anything unless the caller already holds a
/// server-verified [ParentAccessCode].
/// Reads schools/{id}/public/branding - a server-maintained mirror of only
/// the non-sensitive fields off schools/{id} and its institution_profile,
/// kept in sync by syncSchoolPublicBrandingOn{School,Profile}Write in
/// functions/index.js. The full schools/{id} doc also carries billing/
/// contact PII and is locked to signed-in staff of that school, so this
/// pre-login screen can't (and shouldn't) read it directly.
Future<_DetectedSchool?> _lookupSchool(String schoolId) async {
  if (schoolId.isEmpty) return null;
  try {
    final doc = await FirebaseFirestore.instance
        .collection('schools')
        .doc(schoolId)
        .collection('public')
        .doc('branding')
        .get();
    if (!doc.exists) return null;
    final data = doc.data() ?? const <String, dynamic>{};
    String? nonEmpty(Object? value) {
      final text = value?.toString().trim();
      return text == null || text.isEmpty ? null : text;
    }

    final name = nonEmpty(data['schoolName']) ?? 'School';
    final location = [
      nonEmpty(data['city']),
      nonEmpty(data['country']),
    ].whereType<String>().join(', ');
    return _DetectedSchool(
      schoolId: schoolId,
      schoolName: name,
      location: location,
      badgeUrl: nonEmpty(data['badgeUrl']),
    );
  } catch (_) {
    return null;
  }
}

class _DetectedSchoolHeader extends StatelessWidget {
  final _DetectedSchool school;

  const _DetectedSchoolHeader({required this.school});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SchoolBadge(badgeUrl: school.badgeUrl, size: 88),
        const SizedBox(height: AppSpacing.l),
        Text(
          school.schoolName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        if (school.location.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            school.location,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ],
    );
  }
}

/// A single generic message for every invalid/expired/revoked/used code, so
/// the flow never reveals which of those applies, nor any school identity.
const _kGenericCodeError =
    "That code doesn't look right. Please check it and try again.";

class ChildIdScreen extends StatefulWidget {
  const ChildIdScreen({super.key});

  @override
  State<ChildIdScreen> createState() => _ChildIdScreenState();
}

class _ChildIdScreenState extends State<ChildIdScreen> {
  final _controller = TextEditingController();
  final _rememberedLoginStore = RememberedLoginStore();
  Timer? _debounce;
  bool _isChecking = false;
  String? _error;
  ParentAccessCode? _resolvedCode;
  _DetectedSchool? _detectedSchool;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _rememberedLoginStore.getParentIdentity().then((identity) {
      if (!mounted || identity == null) return;
      _controller.text = identity.code;
    });
  }

  String get _normalizedCode =>
      _controller.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  void _onChanged() {
    _debounce?.cancel();
    // Any edit invalidates a previously detected school - never keep stale
    // branding on screen while the user is typing a different code.
    if (_resolvedCode != null || _detectedSchool != null || _error != null) {
      setState(() {
        _resolvedCode = null;
        _detectedSchool = null;
        _error = null;
      });
    }
    final code = _normalizedCode;
    if (code.length < 4) return;
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _verifyCode(code),
    );
  }

  Future<void> _verifyCode(String code) async {
    if (!mounted || code != _normalizedCode) return;
    setState(() {
      _isChecking = true;
      _error = null;
    });

    final result = await di.sl<ResolveParentAccessCode>()(code);
    if (!mounted || code != _normalizedCode) return;

    await result.fold(
      (failure) async {
        setState(() {
          _isChecking = false;
          _error = _kGenericCodeError;
        });
      },
      (accessCode) async {
        if (accessCode.isActive == false) {
          setState(() {
            _isChecking = false;
            _error = _kGenericCodeError;
          });
          return;
        }
        final school = await _lookupSchool(accessCode.schoolId);
        if (!mounted || code != _normalizedCode) return;
        if (school == null) {
          setState(() {
            _isChecking = false;
            _error = _kGenericCodeError;
          });
          return;
        }
        setState(() {
          _isChecking = false;
          _resolvedCode = accessCode;
          _detectedSchool = school;
        });
      },
    );
  }

  void _changeSchool() {
    _debounce?.cancel();
    setState(() {
      _controller.clear();
      _resolvedCode = null;
      _detectedSchool = null;
      _error = null;
    });
  }

  void _continue() {
    if (_resolvedCode == null) return;
    context.push('/parent/login/verify', extra: _resolvedCode);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detected = _detectedSchool;
    return _ConnectToSchoolScaffold(
      footer: _RoundedBlackButton(
        label: 'Continue',
        isLoading: false,
        onPressed: _resolvedCode != null ? _continue : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: detected == null
                ? Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.background(context),
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.shield,
                            size: 40,
                            color: AppColors.textPrimary(context),
                            semanticLabel: 'School Pulse',
                          ),
                          Icon(
                            Icons.monitor_heart_outlined,
                            size: 18,
                            color: AppColors.textPrimary(context),
                          ),
                        ],
                      ),
                    ),
                  )
                : _DetectedSchoolHeader(school: detected),
          ),
          const SizedBox(height: AppSpacing.x3l),
          const _ScreenHeading(
            title: 'Enter your school code',
            subtitle:
                'Use the access code provided by your school to get started.',
          ),
          const SizedBox(height: AppSpacing.x2l),
          _InsetGroup(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.l,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.textSecondary(context),
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                const TextSpan(text: 'Access code'),
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                    color: AppColors.danger(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextField(
                            controller: _controller,
                            textCapitalization: TextCapitalization.characters,
                            autocorrect: false,
                            enableSuggestions: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9\- ]'),
                              ),
                            ],
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              isCollapsed: true,
                              filled: false,
                              hintText: 'e.g. VHS2025',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary(context),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isChecking)
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else ...[
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          CupertinoIcons.viewfinder,
                          color: AppColors.textSecondary(context),
                        ),
                        tooltip: 'Scan code',
                        onPressed: _scanCode,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          CupertinoIcons.doc_on_clipboard,
                          color: AppColors.textSecondary(context),
                        ),
                        tooltip: 'Paste code',
                        onPressed: _pasteCode,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              _error!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.danger(context),
              ),
            ),
          ],
          if (detected != null) ...[
            const SizedBox(height: AppSpacing.xl),
            _InsetGroup(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Row(
                    children: [
                      SchoolBadge(badgeUrl: detected.badgeUrl, size: 40),
                      const SizedBox(width: AppSpacing.l),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    detected.schoolName,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: AppColors.textPrimary(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Icon(
                                  CupertinoIcons.checkmark_seal_fill,
                                  size: 16,
                                  color: AppColors.success(context),
                                ),
                              ],
                            ),
                            if (detected.location.isNotEmpty)
                              Text(
                                detected.location,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _changeSchool,
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pasteCode() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  Future<void> _scanCode() async {
    final scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _AccessCodeScannerScreen()),
    );
    if (scanned == null || scanned.isEmpty) return;
    _controller.text = scanned;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }
}

/// Barcode/QR scanner for a printed access code. Returns the first raw
/// scanned value back to the code field on Screen 1.
class _AccessCodeScannerScreen extends StatefulWidget {
  const _AccessCodeScannerScreen();

  @override
  State<_AccessCodeScannerScreen> createState() =>
      _AccessCodeScannerScreenState();
}

class _AccessCodeScannerScreenState extends State<_AccessCodeScannerScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan school code')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_handled) return;
          for (final barcode in capture.barcodes) {
            final value = barcode.rawValue;
            if (value != null && value.isNotEmpty) {
              _handled = true;
              Navigator.of(context).pop(value);
              break;
            }
          }
        },
      ),
    );
  }
}

class ParentPhoneScreen extends StatefulWidget {
  final ParentAccessCode? accessCode;
  const ParentPhoneScreen({super.key, this.accessCode});

  @override
  State<ParentPhoneScreen> createState() => _ParentPhoneScreenState();
}

class _ParentPhoneScreenState extends State<ParentPhoneScreen> {
  final _phoneController = TextEditingController();
  String _countryCode = '+256';
  bool _isLoading = false;
  String? _error;
  _DetectedSchool? _school;

  static const _countries = [
    {'flag': '🇺🇬', 'code': '+256'},
    {'flag': '🇰🇪', 'code': '+254'},
    {'flag': '🇹🇿', 'code': '+255'},
    {'flag': '🇷🇼', 'code': '+250'},
    {'flag': '🇳🇬', 'code': '+234'},
    {'flag': '🇬🇭', 'code': '+233'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSchool();
  }

  Future<void> _loadSchool() async {
    final accessCode = widget.accessCode;
    if (accessCode == null) return;
    final school = await _lookupSchool(accessCode.schoolId);
    if (!mounted) return;
    setState(() => _school = school);
  }

  void _verifyPhone() {
    final accessCode = widget.accessCode;
    if (accessCode == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final inputPhone = PhoneFormatter.toE164(
      '$_countryCode${_phoneController.text.replaceAll(RegExp(r'\D'), '')}',
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      if (accessCode.phoneNumber == inputPhone) {
        setState(() => _isLoading = false);
        context.push(
          '/parent/login/pin',
          extra: {'accessCode': accessCode, 'phoneNumber': inputPhone},
        );
      } else {
        setState(() {
          _isLoading = false;
          _error = 'That phone number does not match this access code.';
        });
      }
    });
  }

  void _changeCode() {
    context.pop();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schoolName = _school?.schoolName ?? 'your school';
    return _ConnectToSchoolScaffold(
      footer: _RoundedBlackButton(
        label: 'Continue',
        isLoading: _isLoading,
        onPressed: _phoneController.text.trim().isNotEmpty
            ? _verifyPhone
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_school != null) _DetectedSchoolHeader(school: _school!),
          const SizedBox(height: AppSpacing.x3l),
          _ScreenHeading(
            title: 'Confirm your phone',
            subtitle:
                "We'll use this number for important updates from $schoolName.",
          ),
          const SizedBox(height: AppSpacing.x2l),
          _InsetLabel(label: 'Phone number', isRequired: true),
          _InsetGroup(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _countryCode,
                        items: _countries
                            .map(
                              (c) => DropdownMenuItem(
                                value: c['code'],
                                child: Text('${c['flag']} ${c['code']}'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _countryCode = value);
                          }
                        },
                      ),
                    ),
                    Container(
                      height: 24,
                      width: 1,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.l,
                      ),
                      color: AppColors.border(context),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => setState(() {}),
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          hintText: '7XX XXX XXX',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary(context),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xl,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              _error!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.danger(context),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.x2l),
          Center(
            child: TextButton(
              onPressed: _changeCode,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Wrong school? ',
                      style: TextStyle(color: AppColors.textSecondary(context)),
                    ),
                    TextSpan(
                      text: 'Change code',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rejects PINs that are trivially guessable - all-repeated digits, or a
/// run that's strictly ascending/descending (e.g. 1234, 4321). Mirrors the
/// server-side `isSafeParentPin` check in functions/index.js so the user
/// sees the same rule before submitting.
bool _isWeakPin(String pin) {
  if (!RegExp(r'^\d{4}$').hasMatch(pin)) return true;
  final digits = pin.split('').map(int.parse).toList();
  if (digits.toSet().length == 1) return true;
  var ascending = true;
  var descending = true;
  for (var i = 1; i < digits.length; i++) {
    if (digits[i] != digits[i - 1] + 1) ascending = false;
    if (digits[i] != digits[i - 1] - 1) descending = false;
  }
  return ascending || descending;
}

class ParentPinScreen extends StatefulWidget {
  final ParentAccessCode accessCode;
  final String phoneNumber;

  const ParentPinScreen({
    super.key,
    required this.accessCode,
    required this.phoneNumber,
  });

  @override
  State<ParentPinScreen> createState() => _ParentPinScreenState();
}

class _ParentPinScreenState extends State<ParentPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _rememberedLoginStore = RememberedLoginStore();
  bool _pinVisible = false;
  bool _confirmVisible = false;
  bool _submitted = false;
  String? _error;
  String? _pinError;
  String? _confirmPinError;
  _DetectedSchool? _school;

  bool get _isFirstTime =>
      widget.accessCode.pin == null || widget.accessCode.pin!.isEmpty;

  @override
  void initState() {
    super.initState();
    _loadSchool();
  }

  Future<void> _loadSchool() async {
    final school = await _lookupSchool(widget.accessCode.schoolId);
    if (!mounted) return;
    setState(() => _school = school);
  }

  void _login() {
    setState(() {
      _submitted = true;
      _error = null;
      _pinError = null;
      _confirmPinError = null;
    });

    final pin = _pinController.text;
    final confirm = _confirmPinController.text;

    if (_isFirstTime) {
      if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
        setState(() => _pinError = 'Enter a 4-digit PIN.');
        return;
      }
      if (_isWeakPin(pin)) {
        setState(() => _pinError = 'Choose a less predictable PIN.');
        return;
      }
      if (pin != confirm) {
        setState(() => _confirmPinError = 'PINs do not match.');
        return;
      }

      context.read<AuthBloc>().add(
        CompleteParentPinSetupRequested(
          code: widget.accessCode.parentCode,
          phoneNumber: widget.phoneNumber,
          newPin: pin,
        ),
      );
    } else {
      context.read<AuthBloc>().add(
        LoginParentPressed(
          code: widget.accessCode.parentCode,
          phoneNumber: widget.phoneNumber,
          pin: pin,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _rememberedLoginStore.setParentIdentity(
            code: widget.accessCode.parentCode,
            phone: widget.phoneNumber,
          );
          context.go('/parent/home');
        } else if (state is AuthFailureState) {
          setState(() => _error = state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return _ConnectToSchoolScaffold(
          footer: _RoundedBlackButton(
            label: _isFirstTime ? 'Finish setup' : 'Sign in',
            isLoading: isLoading,
            onPressed: isLoading ? null : _login,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_school != null) _DetectedSchoolHeader(school: _school!),
              const SizedBox(height: AppSpacing.x3l),
              _ScreenHeading(
                title: _isFirstTime ? 'Create a PIN' : 'Enter your PIN',
                subtitle: _isFirstTime
                    ? 'Choose a 4-digit PIN for quick, secure access.'
                    : 'Enter your 4-digit PIN to continue.',
              ),
              const SizedBox(height: AppSpacing.x2l),
              _InsetLabel(
                label: _isFirstTime ? 'New PIN' : 'PIN',
                isRequired: true,
              ),
              _InsetGroup(
                children: [
                  _PinRow(
                    controller: _pinController,
                    obscured: !_pinVisible,
                    onToggleVisibility: () =>
                        setState(() => _pinVisible = !_pinVisible),
                    onChanged: (_) {
                      if (_pinError != null || _error != null) {
                        setState(() {
                          _pinError = null;
                          _error = null;
                        });
                      }
                    },
                  ),
                  if (_isFirstTime) ...[
                    Divider(height: 1, color: AppColors.border(context)),
                    _PinRow(
                      controller: _confirmPinController,
                      obscured: !_confirmVisible,
                      onToggleVisibility: () =>
                          setState(() => _confirmVisible = !_confirmVisible),
                      onChanged: (_) {
                        if (_confirmPinError != null) {
                          setState(() => _confirmPinError = null);
                        }
                      },
                      label: 'Confirm PIN',
                    ),
                  ],
                ],
              ),
              if ((_submitted && _pinError != null) ||
                  (_submitted && _confirmPinError != null) ||
                  _error != null) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  _pinError ?? _confirmPinError ?? _error ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.danger(context),
                  ),
                ),
              ],
              if (_isFirstTime) ...[
                const SizedBox(height: AppSpacing.l),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.shield,
                      size: 16,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        'Avoid easy-to-guess numbers.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.lock,
                      size: 14,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Text(
                      'Your PIN is private.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PinRow extends StatelessWidget {
  final TextEditingController controller;
  final bool obscured;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String> onChanged;
  final String label;

  const _PinRow({
    required this.controller,
    required this.obscured,
    required this.onToggleVisibility,
    required this.onChanged,
    this.label = 'New PIN',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.s,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscured,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              maxLength: 4,
              onChanged: onChanged,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary(context),
                letterSpacing: 6,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              obscured ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
              size: 20,
              color: AppColors.textSecondary(context),
            ),
            onPressed: onToggleVisibility,
          ),
        ],
      ),
    );
  }
}
