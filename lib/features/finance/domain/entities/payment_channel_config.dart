import 'package:equatable/equatable.dart';

/// One instructional payment channel (MTN MoMo or Airtel Money) as
/// configured by the school's bursar - `functions/payment_codes.js`'s
/// `updatePaymentChannelConfig`. Instructions are school-configurable, never
/// hardcoded, since the actual USSD sequence/merchant label differs school
/// to school.
class MomoChannelConfig extends Equatable {
  final bool enabled;
  final String ussdCode;
  final List<String> steps;
  final String merchantLabel;

  const MomoChannelConfig({
    required this.enabled,
    required this.ussdCode,
    required this.steps,
    required this.merchantLabel,
  });

  factory MomoChannelConfig.fromJson(Map<String, dynamic>? json) {
    final j = json ?? const {};
    return MomoChannelConfig(
      enabled: j['enabled'] as bool? ?? false,
      ussdCode: j['ussdCode'] as String? ?? '',
      steps: ((j['steps'] as List?) ?? const [])
          .map((s) => s.toString())
          .toList(),
      merchantLabel: j['merchantLabel'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [enabled, ussdCode, steps, merchantLabel];
}

/// A bursar-approved bank/bank-agent collection account. [accountNumber] is
/// only ever shown to parents when [showAccountNumber] is true - the bursar
/// controls whether the raw number is safe to display in-app.
class BankAccountConfig extends Equatable {
  final String id;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final bool showAccountNumber;
  final String branchOrAgentNotes;
  final bool enabled;

  const BankAccountConfig({
    required this.id,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.showAccountNumber,
    required this.branchOrAgentNotes,
    required this.enabled,
  });

  factory BankAccountConfig.fromJson(Map<String, dynamic> json) {
    return BankAccountConfig(
      id: json['id'] as String? ?? '',
      bankName: json['bankName'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      showAccountNumber: json['showAccountNumber'] as bool? ?? false,
      branchOrAgentNotes: json['branchOrAgentNotes'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bankName': bankName,
    'accountName': accountName,
    'accountNumber': accountNumber,
    'showAccountNumber': showAccountNumber,
    'branchOrAgentNotes': branchOrAgentNotes,
    'enabled': enabled,
  };

  @override
  List<Object?> get props => [
    id,
    bankName,
    accountName,
    accountNumber,
    showAccountNumber,
    branchOrAgentNotes,
    enabled,
  ];
}

/// Any other school-configured channel not covered by the built-in MoMo/
/// Airtel/bank types (e.g. a second mobile-money provider, a payment app).
class OtherChannelConfig extends Equatable {
  final String id;
  final String label;
  final String instructions;
  final bool enabled;

  const OtherChannelConfig({
    required this.id,
    required this.label,
    required this.instructions,
    required this.enabled,
  });

  factory OtherChannelConfig.fromJson(Map<String, dynamic> json) {
    return OtherChannelConfig(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'instructions': instructions,
    'enabled': enabled,
  };

  @override
  List<Object?> get props => [id, label, instructions, enabled];
}

/// The school-wide singleton at `schools/{schoolId}/payment_config/channels`.
/// Bursar-writable only via `updatePaymentChannelConfig`; parents read this
/// (filtered to `enabled == true` entries) to render the "How to pay" screen.
class PaymentChannelConfig extends Equatable {
  final String schoolDisplayName;
  final MomoChannelConfig mtnMomo;
  final MomoChannelConfig airtelMoney;
  final List<BankAccountConfig> bankAccounts;
  final List<OtherChannelConfig> otherChannels;

  const PaymentChannelConfig({
    required this.schoolDisplayName,
    required this.mtnMomo,
    required this.airtelMoney,
    required this.bankAccounts,
    required this.otherChannels,
  });

  static const empty = PaymentChannelConfig(
    schoolDisplayName: '',
    mtnMomo: MomoChannelConfig(
      enabled: false,
      ussdCode: '',
      steps: [],
      merchantLabel: '',
    ),
    airtelMoney: MomoChannelConfig(
      enabled: false,
      ussdCode: '',
      steps: [],
      merchantLabel: '',
    ),
    bankAccounts: [],
    otherChannels: [],
  );

  bool get hasAnyEnabledChannel =>
      mtnMomo.enabled ||
      airtelMoney.enabled ||
      bankAccounts.any((b) => b.enabled) ||
      otherChannels.any((c) => c.enabled);

  factory PaymentChannelConfig.fromJson(Map<String, dynamic>? json) {
    final j = json ?? const {};
    return PaymentChannelConfig(
      schoolDisplayName: j['schoolDisplayName'] as String? ?? '',
      mtnMomo: MomoChannelConfig.fromJson(
        (j['mtnMomo'] as Map?)?.cast<String, dynamic>(),
      ),
      airtelMoney: MomoChannelConfig.fromJson(
        (j['airtelMoney'] as Map?)?.cast<String, dynamic>(),
      ),
      bankAccounts: ((j['bankAccounts'] as List?) ?? const [])
          .map(
            (b) =>
                BankAccountConfig.fromJson((b as Map).cast<String, dynamic>()),
          )
          .toList(),
      otherChannels: ((j['otherChannels'] as List?) ?? const [])
          .map(
            (c) =>
                OtherChannelConfig.fromJson((c as Map).cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    schoolDisplayName,
    mtnMomo,
    airtelMoney,
    bankAccounts,
    otherChannels,
  ];
}
