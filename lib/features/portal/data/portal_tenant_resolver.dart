import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/portal_tenant.dart';
import 'portal_host.dart';

enum PortalResolutionKind { platform, tenant, notFound }

class PortalResolution {
  const PortalResolution.platform()
    : kind = PortalResolutionKind.platform,
      tenant = null;
  const PortalResolution.tenant(this.tenant)
    : kind = PortalResolutionKind.tenant;
  const PortalResolution.notFound()
    : kind = PortalResolutionKind.notFound,
      tenant = null;
  final PortalResolutionKind kind;
  final PortalTenant? tenant;
}

class PortalTenantResolver {
  PortalTenantResolver(this._db);
  final FirebaseFirestore _db;
  static const _platform = {
    'schoolpulse.ug',
    'www.schoolpulse.ug',
    'localhost',
    '127.0.0.1',
  };
  Future<PortalResolution> resolve([String? value]) async {
    final host = (value ?? currentPortalHostname()).toLowerCase().trim();
    if (host.isEmpty || _platform.contains(host)) {
      return const PortalResolution.platform();
    }
    final doc = await _db.collection('portal_domains').doc(host).get();
    if (!doc.exists || doc.data()?['status'] != 'active') {
      return const PortalResolution.notFound();
    }
    try {
      return PortalResolution.tenant(PortalTenant.fromMap(host, doc.data()!));
    } catch (_) {
      return const PortalResolution.notFound();
    }
  }
}
