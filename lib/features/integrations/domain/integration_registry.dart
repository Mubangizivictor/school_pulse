import 'package:flutter/material.dart';

enum IntegrationCategory {
  payments,
  communication,
  productivity,
  devices,
  printing,
  domains,
  dataApis,
}

enum IntegrationStatus {
  notAvailable,
  available,
  setupRequired,
  notConnected,
  connecting,
  connected,
  healthy,
  warning,
  degraded,
  reauthorizationRequired,
  credentialExpired,
  failed,
  disabled,
  suspended,
  entitlementRequired,
}

class IntegrationDefinition {
  const IntegrationDefinition({
    required this.key,
    required this.displayName,
    required this.description,
    required this.category,
    required this.provider,
    required this.icon,
    required this.requiredModule,
    required this.minimumEntitlement,
    this.supportsTestConnection = false,
    this.supportsWebhooks = false,
    this.supportsSync = false,
    this.supportsOfflineQueue = false,
    this.sensitivity = 'standard',
    this.version = 1,
  });
  final String key,
      displayName,
      description,
      provider,
      requiredModule,
      minimumEntitlement,
      sensitivity;
  final IntegrationCategory category;
  final IconData icon;
  final bool supportsTestConnection,
      supportsWebhooks,
      supportsSync,
      supportsOfflineQueue;
  final int version;
}

/// Typed, UI-independent catalog. Connection state is fetched from the secure
/// backend and is never inferred from a form being filled in.
class IntegrationRegistry {
  const IntegrationRegistry._();
  static const definitions = <IntegrationDefinition>[
    IntegrationDefinition(
      key: 'google_sheets',
      displayName: 'Google Sheets',
      description: 'Export attendance records for reporting.',
      category: IntegrationCategory.productivity,
      provider: 'Google',
      icon: Icons.table_chart_outlined,
      requiredModule: 'Attendance',
      minimumEntitlement: 'Standard',
      supportsTestConnection: true,
      supportsSync: true,
    ),
    IntegrationDefinition(
      key: 'google_calendar',
      displayName: 'Google Calendar',
      description: 'One-way export of institution calendar events.',
      category: IntegrationCategory.productivity,
      provider: 'Google',
      icon: Icons.calendar_month_outlined,
      requiredModule: 'Calendar',
      minimumEntitlement: 'Standard',
      supportsTestConnection: true,
      supportsSync: true,
    ),
    IntegrationDefinition(
      key: 'transactional_email',
      displayName: 'Transactional Email',
      description: 'Platform-managed delivery and sender-branding status.',
      category: IntegrationCategory.communication,
      provider: 'School Pulse',
      icon: Icons.email_outlined,
      requiredModule: 'Notifications',
      minimumEntitlement: 'Included',
      supportsTestConnection: true,
    ),
    IntegrationDefinition(
      key: 'sms_gateway',
      displayName: 'SMS Provider',
      description: 'Managed SMS sender and delivery status.',
      category: IntegrationCategory.communication,
      provider: 'Provider adapter',
      icon: Icons.sms_outlined,
      requiredModule: 'Messaging',
      minimumEntitlement: 'Standard',
      supportsTestConnection: true,
    ),
    IntegrationDefinition(
      key: 'push_notifications',
      displayName: 'Push Notifications',
      description: 'Platform-managed device delivery health.',
      category: IntegrationCategory.communication,
      provider: 'Firebase Cloud Messaging',
      icon: Icons.notifications_outlined,
      requiredModule: 'Notifications',
      minimumEntitlement: 'Included',
    ),
    IntegrationDefinition(
      key: 'institution_mtn_momo',
      displayName: 'MTN MoMo for school fees',
      description: 'Institution payment gateway; distinct from SaaS billing.',
      category: IntegrationCategory.payments,
      provider: 'MTN',
      icon: Icons.account_balance_wallet_outlined,
      requiredModule: 'Finance',
      minimumEntitlement: 'Premium',
      supportsTestConnection: true,
      sensitivity: 'high',
    ),
    IntegrationDefinition(
      key: 'institution_airtel_money',
      displayName: 'Airtel Money for school fees',
      description: 'Institution payment gateway; distinct from SaaS billing.',
      category: IntegrationCategory.payments,
      provider: 'Airtel',
      icon: Icons.account_balance_wallet_outlined,
      requiredModule: 'Finance',
      minimumEntitlement: 'Premium',
      supportsTestConnection: true,
      sensitivity: 'high',
    ),
    IntegrationDefinition(
      key: 'pesapal',
      displayName: 'PesaPal',
      description:
          'Institution payment gateway with backend callback verification.',
      category: IntegrationCategory.payments,
      provider: 'PesaPal',
      icon: Icons.payments_outlined,
      requiredModule: 'Finance',
      minimumEntitlement: 'Premium',
      supportsTestConnection: true,
      sensitivity: 'high',
    ),
    IntegrationDefinition(
      key: 'biometric_device',
      displayName: 'Biometric devices',
      description: 'Register attendance devices and assignments.',
      category: IntegrationCategory.devices,
      provider: 'Device adapter',
      icon: Icons.fingerprint_outlined,
      requiredModule: 'Attendance',
      minimumEntitlement: 'Standard',
    ),
    IntegrationDefinition(
      key: 'receipt_printer',
      displayName: 'Receipt printer',
      description: 'Configure a local thermal receipt printer.',
      category: IntegrationCategory.printing,
      provider: 'Local device',
      icon: Icons.print_outlined,
      requiredModule: 'Finance',
      minimumEntitlement: 'Standard',
      supportsTestConnection: true,
    ),
    IntegrationDefinition(
      key: 'custom_domain',
      displayName: 'Custom domain',
      description: 'Request DNS verification and SSL provisioning.',
      category: IntegrationCategory.domains,
      provider: 'School Pulse',
      icon: Icons.language_outlined,
      requiredModule: 'Public portal',
      minimumEntitlement: 'Premium',
      supportsTestConnection: true,
      sensitivity: 'high',
    ),
    IntegrationDefinition(
      key: 'outbound_webhook',
      displayName: 'Outbound webhooks',
      description: 'Signed and replay-protected event delivery.',
      category: IntegrationCategory.dataApis,
      provider: 'Provider adapter',
      icon: Icons.webhook_outlined,
      requiredModule: 'Integrations',
      minimumEntitlement: 'Premium',
      supportsTestConnection: true,
      supportsWebhooks: true,
      sensitivity: 'high',
    ),
  ];
  static IntegrationDefinition? byKey(String key) {
    for (final definition in definitions) {
      if (definition.key == key) return definition;
    }
    return null;
  }
}
