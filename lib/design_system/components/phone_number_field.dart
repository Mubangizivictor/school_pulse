import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

/// A dial code + national-number pair for a country.
class PhoneCountry {
  final String flag;
  final String dialCode; // e.g. "+256"
  final String name;
  final String isoCode; // e.g. "UG"

  const PhoneCountry({
    required this.flag,
    required this.dialCode,
    required this.name,
    required this.isoCode,
  });
}

/// Curated country list. Uganda first (the platform's home market) but the
/// picker is fully international and searchable - no region is hard-locked,
/// matching the "Uganda-aware, international support" requirement without
/// baking in a regional default beyond ordering.
const List<PhoneCountry> kPhoneCountries = [
  PhoneCountry(flag: '🇺🇬', dialCode: '+256', name: 'Uganda', isoCode: 'UG'),
  PhoneCountry(flag: '🇰🇪', dialCode: '+254', name: 'Kenya', isoCode: 'KE'),
  PhoneCountry(flag: '🇹🇿', dialCode: '+255', name: 'Tanzania', isoCode: 'TZ'),
  PhoneCountry(flag: '🇷🇼', dialCode: '+250', name: 'Rwanda', isoCode: 'RW'),
  PhoneCountry(flag: '🇧🇮', dialCode: '+257', name: 'Burundi', isoCode: 'BI'),
  PhoneCountry(
    flag: '🇸🇸',
    dialCode: '+211',
    name: 'South Sudan',
    isoCode: 'SS',
  ),
  PhoneCountry(flag: '🇨🇩', dialCode: '+243', name: 'DR Congo', isoCode: 'CD'),
  PhoneCountry(flag: '🇪🇹', dialCode: '+251', name: 'Ethiopia', isoCode: 'ET'),
  PhoneCountry(flag: '🇳🇬', dialCode: '+234', name: 'Nigeria', isoCode: 'NG'),
  PhoneCountry(flag: '🇬🇭', dialCode: '+233', name: 'Ghana', isoCode: 'GH'),
  PhoneCountry(
    flag: '🇿🇦',
    dialCode: '+27',
    name: 'South Africa',
    isoCode: 'ZA',
  ),
  PhoneCountry(
    flag: '🇬🇧',
    dialCode: '+44',
    name: 'United Kingdom',
    isoCode: 'GB',
  ),
  PhoneCountry(
    flag: '🇺🇸',
    dialCode: '+1',
    name: 'United States',
    isoCode: 'US',
  ),
  PhoneCountry(flag: '🇮🇳', dialCode: '+91', name: 'India', isoCode: 'IN'),
  PhoneCountry(
    flag: '🇦🇪',
    dialCode: '+971',
    name: 'United Arab Emirates',
    isoCode: 'AE',
  ),
  PhoneCountry(flag: '🇨🇦', dialCode: '+1', name: 'Canada', isoCode: 'CA'),
  PhoneCountry(flag: '🇦🇺', dialCode: '+61', name: 'Australia', isoCode: 'AU'),
  PhoneCountry(flag: '🇩🇪', dialCode: '+49', name: 'Germany', isoCode: 'DE'),
  PhoneCountry(flag: '🇫🇷', dialCode: '+33', name: 'France', isoCode: 'FR'),
  PhoneCountry(
    flag: '🇳🇱',
    dialCode: '+31',
    name: 'Netherlands',
    isoCode: 'NL',
  ),
  PhoneCountry(flag: '🇨🇳', dialCode: '+86', name: 'China', isoCode: 'CN'),
  PhoneCountry(flag: '🇵🇰', dialCode: '+92', name: 'Pakistan', isoCode: 'PK'),
  PhoneCountry(
    flag: '🇧🇩',
    dialCode: '+880',
    name: 'Bangladesh',
    isoCode: 'BD',
  ),
  PhoneCountry(flag: '🇪🇬', dialCode: '+20', name: 'Egypt', isoCode: 'EG'),
];

/// Default dial code when nothing else is chosen. Uganda - the only place a
/// regional default is expressed, and only as an initial value the user can
/// change to any country in [kPhoneCountries].
const String kDefaultDialCode = '+256';

/// Normalises a dial code + national number into E.164 (`+<digits>`), or
/// returns `null` when the number is empty / not plausibly valid.
String? phoneToE164(String dialCode, String nationalNumber) {
  final dial = dialCode.replaceAll(RegExp(r'[^\d+]'), '');
  final digits = nationalNumber.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  final e164 = '$dial$digits';
  return RegExp(r'^\+\d{8,15}$').hasMatch(e164) ? e164 : null;
}

/// Shared phone entry: a searchable country/dial-code picker plus a
/// digit-only national-number field. Emits changes as `(dialCode,
/// nationalNumber)`; call [phoneToE164] to get the server-ready value.
///
/// Dark-graphite styling via [AppColors]; no gradients, subtle borders,
/// pale-blue focus. Replaces the private `_CountryCodePicker` copies that
/// were duplicated in the Link Parent and Add Staff flows.
class PhoneNumberField extends StatefulWidget {
  final String dialCode;
  final String nationalNumber;
  final ValueChanged<String> onDialCodeChanged;
  final ValueChanged<String> onNationalNumberChanged;
  final String? errorText;
  final String hintText;
  final bool enabled;

  const PhoneNumberField({
    super.key,
    required this.dialCode,
    required this.nationalNumber,
    required this.onDialCodeChanged,
    required this.onNationalNumberChanged,
    this.errorText,
    this.hintText = '772 123 456',
    this.enabled = true,
  });

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late final TextEditingController _numberController = TextEditingController(
    text: widget.nationalNumber,
  );

  @override
  void didUpdateWidget(covariant PhoneNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nationalNumber != _numberController.text) {
      _numberController.text = widget.nationalNumber;
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  PhoneCountry get _selected => kPhoneCountries.firstWhere(
    (c) => c.dialCode == widget.dialCode,
    orElse: () => const PhoneCountry(
      flag: '🌐',
      dialCode: kDefaultDialCode,
      name: 'International',
      isoCode: '',
    ),
  );

  Future<void> _pickCountry() async {
    final picked = await showModalBottomSheet<PhoneCountry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated(context),
      builder: (_) => const _CountryPickerSheet(),
    );
    if (picked != null) widget.onDialCodeChanged(picked.dialCode);
  }

  @override
  Widget build(BuildContext context) {
    final border = AppColors.border(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              button: true,
              label:
                  'Country dial code, currently ${_selected.name} '
                  '${_selected.dialCode}',
              child: InkWell(
                onTap: widget.enabled ? _pickCountry : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selected.flag,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selected.dialCode,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.textMuted(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _numberController,
                enabled: widget.enabled,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                onChanged: widget.onNationalNumberChanged,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  errorText: widget.errorText,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet();

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final matches = q.isEmpty
        ? kPhoneCountries
        : kPhoneCountries
              .where(
                (c) =>
                    c.name.toLowerCase().contains(q) ||
                    c.dialCode.contains(q) ||
                    c.isoCode.toLowerCase() == q,
              )
              .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search country or code',
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (_, i) {
                    final c = matches[i];
                    return ListTile(
                      leading: Text(
                        c.flag,
                        style: const TextStyle(fontSize: 20),
                      ),
                      title: Text(
                        c.name,
                        style: TextStyle(color: AppColors.textPrimary(context)),
                      ),
                      trailing: Text(
                        c.dialCode,
                        style: TextStyle(
                          color: AppColors.textMuted(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(c),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
