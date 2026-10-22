import 'portal_tenant.dart';

/// Routing hint only; authorization still comes from the authenticated user.
class PortalRuntime {
  static PortalTenant? tenant;
}
