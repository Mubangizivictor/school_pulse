import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

/// Secure, callable-only parent invitation redemption.  No parent or learner
/// information is fetched until Firebase Phone Auth proves phone ownership.
class ParentAccessSetupScreen extends StatefulWidget {
  const ParentAccessSetupScreen({super.key});
  @override
  State<ParentAccessSetupScreen> createState() =>
      _ParentAccessSetupScreenState();
}

class _ParentAccessSetupScreenState extends State<ParentAccessSetupScreen> {
  final _code = TextEditingController();
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _pin = TextEditingController();
  final _confirmPin = TextEditingController();
  String? _verificationId, _error;
  Map<String, dynamic>? _summary;
  bool _busy = false, _submitted = false;

  String get _normalCode =>
      _code.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  String get _phoneE164 {
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('256')) return '+$digits';
    if (digits.startsWith('0')) return '+256${digits.substring(1)}';
    return '+256$digits';
  }

  bool get _validPhone => RegExp(r'^\+\d{8,15}$').hasMatch(_phoneE164);
  bool get _validCode => RegExp(r'^SP\d{6}$').hasMatch(_normalCode);
  bool get _validPin {
    if (!RegExp(r'^\d{4}$').hasMatch(_pin.text) ||
        RegExp(r'^(\d)\1{3}$').hasMatch(_pin.text))
      return false;
    final digits = _pin.text.split('').map(int.parse).toList();
    final up = List.generate(
      3,
      (i) => digits[i + 1] == digits[i] + 1,
    ).every((value) => value);
    final down = List.generate(
      3,
      (i) => digits[i + 1] == digits[i] - 1,
    ).every((value) => value);
    return !up && !down;
  }

  Future<void> _sendOtp() async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (!_validCode || !_validPhone) return;
    setState(() => _busy = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneE164,
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        await _redeem();
      },
      verificationFailed: (_) {
        if (mounted)
          setState(() {
            _busy = false;
            _error = 'We could not verify this phone number. Please try again.';
          });
      },
      codeSent: (id, _) {
        if (mounted)
          setState(() {
            _busy = false;
            _verificationId = id;
          });
      },
      codeAutoRetrievalTimeout: (id) {
        _verificationId = id;
      },
    );
  }

  Future<void> _confirmOtp() async {
    if (_verificationId == null || _otp.text.trim().length != 6) {
      setState(() => _error = 'Enter the 6-digit verification code.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: _otp.text.trim(),
        ),
      );
      await _redeem();
    } on FirebaseAuthException {
      if (mounted)
        setState(() {
          _busy = false;
          _error = 'We could not verify this phone number. Please try again.';
        });
    }
  }

  Future<void> _redeem() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('redeemParentAccessCode')
          .call({'code': _normalCode});
      if (mounted)
        setState(() {
          _summary = Map<String, dynamic>.from(result.data as Map);
          _busy = false;
        });
    } on FirebaseFunctionsException {
      if (mounted)
        setState(() {
          _busy = false;
          _error = 'This code is invalid, expired, or already used.';
        });
    }
  }

  Future<void> _finish() async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (!_validPin) {
      setState(() => _error = 'Choose a secure 4-digit PIN.');
      return;
    }
    if (_pin.text != _confirmPin.text) {
      setState(() => _error = 'PINs do not match.');
      return;
    }
    setState(() => _busy = true);
    try {
      await FirebaseFunctions.instance
          .httpsCallable('completeParentAccessCodeSetup')
          .call({'code': _normalCode, 'pin': _pin.text});
      if (mounted) context.go('/school-splash');
    } on FirebaseFunctionsException {
      if (mounted)
        setState(() {
          _busy = false;
          _error = 'This code is invalid, expired, or already used.';
        });
    }
  }

  @override
  void dispose() {
    for (final c in [_code, _phone, _otp, _pin, _confirmPin]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background(context),
    appBar: AppBar(
      backgroundColor: AppColors.background(context),
      elevation: 0,
      title: Text(
        _summary == null ? 'Connect to your school' : 'Create your PIN',
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w700,
        ),
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: _summary == null ? _connect(context) : _pinSetup(context),
        ),
      ),
    ),
  );

  List<Widget> _connect(BuildContext context) => [
    Icon(
      Icons.shield_outlined,
      size: 40,
      color: AppColors.textPrimary(context),
    ),
    const SizedBox(height: 12),
    Text(
      'Connect to your school',
      style: TextStyle(
        color: AppColors.textPrimary(context),
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    ),
    const SizedBox(height: 8),
    Text(
      'Enter the access code given to you by the school.',
      style: TextStyle(color: AppColors.textSecondary(context)),
    ),
    const SizedBox(height: 24),
    _RequiredLabel(text: 'Parent access code'),
    const SizedBox(height: 8),
    _GroupedCodeField(
      controller: _code,
      hasError: _submitted && !_validCode,
      onPaste: () async {
        final data = await Clipboard.getData('text/plain');
        if (data?.text != null) {
          setState(
            () => _code.text = data!.text!.toUpperCase().replaceAll(
              RegExp(r'[^A-Z0-9]'),
              '',
            ),
          );
        }
      },
    ),
    const SizedBox(height: 20),
    _RequiredLabel(text: 'Phone number'),
    const SizedBox(height: 8),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '🇺🇬 +256',
            style: TextStyle(color: AppColors.textPrimary(context)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '7XX XXX XXX',
              errorText: _submitted && !_validPhone
                  ? 'Enter a valid phone number'
                  : null,
            ),
          ),
        ),
      ],
    ),
    const SizedBox(height: 4),
    Text(
      'Use the phone number given to the school.',
      style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
    ),
    if (_verificationId != null) ...[
      const SizedBox(height: 16),
      _RequiredLabel(text: 'SMS verification code'),
      const SizedBox(height: 8),
      TextField(
        controller: _otp,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        decoration: const InputDecoration(hintText: '6-digit code'),
      ),
    ],
    if (_error != null) ...[
      const SizedBox(height: 16),
      _ErrorBanner(message: _error!),
    ],
    const SizedBox(height: 24),
    SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        label: _busy
            ? 'Verifying…'
            : _verificationId == null
            ? 'Verify code'
            : 'Verify code',
        isLoading: _busy,
        onPressed: _busy
            ? null
            : (_verificationId == null ? _sendOtp : _confirmOtp),
      ),
    ),
    const SizedBox(height: 24),
    Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: AppColors.textSecondary(context)),
          children: [
            const TextSpan(text: 'Need a new code? '),
            TextSpan(
              text: 'Contact your school.',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    ),
  ];

  List<Widget> _pinSetup(BuildContext context) {
    final learners = List<Map<String, dynamic>>.from(
      (_summary!['learners'] as List).map(
        (x) => Map<String, dynamic>.from(x as Map),
      ),
    );
    return [
      Text(
        'Create your PIN',
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 20),
      _verifiedRow(
        context,
        Icons.school_outlined,
        'School',
        '${_summary!['schoolName']}',
      ),
      _verifiedRow(
        context,
        Icons.person_outline,
        'Parent',
        '${_summary!['parentName']}',
      ),
      const SizedBox(height: 12),
      Text(
        'Linked learners',
        style: TextStyle(
          color: AppColors.textSecondary(context),
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border(context)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: learners
              .map(
                (learner) => ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary(context),
                  ),
                  title: Text(
                    '${learner['name']}',
                    style: TextStyle(color: AppColors.textPrimary(context)),
                  ),
                  trailing: Text(
                    '${learner['className']}',
                    style: TextStyle(color: AppColors.textMuted(context)),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      const SizedBox(height: 20),
      _RequiredLabel(text: 'Create 4-digit PIN'),
      const SizedBox(height: 8),
      _PinDotField(controller: _pin, hasError: _submitted && !_validPin),
      if (_submitted && !_validPin)
        _FieldError(message: 'Choose a secure 4-digit PIN.'),
      const SizedBox(height: 16),
      _RequiredLabel(text: 'Confirm PIN'),
      const SizedBox(height: 8),
      _PinDotField(
        controller: _confirmPin,
        hasError: _submitted && _pin.text != _confirmPin.text,
      ),
      if (_submitted && _validPin && _pin.text != _confirmPin.text)
        _FieldError(message: 'PINs do not match.'),
      if (_error != null) ...[
        const SizedBox(height: 16),
        _ErrorBanner(message: _error!),
      ],
      const SizedBox(height: 8),
      Text(
        'Avoid repeating or easy-to-guess numbers.',
        style: TextStyle(color: AppColors.textMuted(context), fontSize: 11.5),
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: PrimaryButton(
          label: _busy ? 'Connecting…' : 'Connect account',
          isLoading: _busy,
          onPressed: _busy ? null : _finish,
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 16,
            color: AppColors.textMuted(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Your PIN is private. The school cannot see it.',
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
          ),
        ],
      ),
    ];
  }

  Widget _verifiedRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      leading: Icon(icon, color: AppColors.textSecondary(context)),
      title: Text(
        label,
        style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(Icons.check_circle, color: AppColors.success(context)),
    ),
  );
}

class _RequiredLabel extends StatelessWidget {
  final String text;
  const _RequiredLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
        children: [
          TextSpan(text: text),
          TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.danger(context)),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerSurface(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: AppColors.danger(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppColors.danger(context), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldError extends StatelessWidget {
  final String message;
  const _FieldError({required this.message});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      message,
      style: TextStyle(color: AppColors.danger(context), fontSize: 12),
    ),
  );
}

/// Grouped SP-nnn-nnn code entry: a single underlying text field masked
/// visually as three boxed groups, matching the reference design's layout,
/// plus a Paste action for the school-provided code.
class _GroupedCodeField extends StatelessWidget {
  final TextEditingController controller;
  final bool hasError;
  final VoidCallback onPaste;

  const _GroupedCodeField({
    required this.controller,
    required this.hasError,
    required this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9-]')),
            LengthLimitingTextInputFormatter(10),
          ],
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            hintText: 'SP-482-791',
            errorText: hasError ? 'Enter a valid access code' : null,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPaste,
          icon: const Icon(Icons.copy_outlined, size: 16),
          label: const Text('Paste'),
        ),
      ],
    );
  }
}

/// Four-digit PIN entry rendered as four dot boxes, matching the reference
/// design, backed by a single hidden numeric text field for input handling.
class _PinDotField extends StatefulWidget {
  final TextEditingController controller;
  final bool hasError;

  const _PinDotField({required this.controller, required this.hasError});

  @override
  State<_PinDotField> createState() => _PinDotFieldState();
}

class _PinDotFieldState extends State<_PinDotField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.hasError
        ? AppColors.danger(context)
        : AppColors.border(context);
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        children: [
          Row(
            children: List.generate(4, (i) {
              final filled = i < widget.controller.text.length;
              return Padding(
                padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          _focusNode.hasFocus &&
                              i == widget.controller.text.length
                          ? AppColors.textPrimary(context)
                          : borderColor,
                      width: widget.hasError ? 1.6 : 1.2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: filled
                      ? Icon(
                          Icons.circle,
                          size: 10,
                          color: AppColors.textPrimary(context),
                        )
                      : null,
                ),
              );
            }),
          ),
          Opacity(
            opacity: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              obscureText: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }
}
