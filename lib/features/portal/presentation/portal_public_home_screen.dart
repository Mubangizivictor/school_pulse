import 'package:flutter/material.dart';

import '../domain/portal_tenant.dart';

/// The public-facing page a visitor sees at a school's own subdomain
/// (e.g. greenhill.schoolpulseapp.com) before signing in - branding,
/// contact info, and a way into the app. Mirrors
/// web_marketing/school.html's content (same portal_domains fields) but
/// as a standalone native screen, since this runs inside the Flutter web
/// build itself rather than the separate static marketing site.
///
/// Self-contained like PortalNotFoundScreen (its own MaterialApp) since it
/// runs before the real app's MultiBlocProvider/router tree is built in
/// main.dart - it has no access to that tree yet.
class PortalPublicHomeScreen extends StatelessWidget {
  const PortalPublicHomeScreen({
    required this.tenant,
    required this.onContinue,
    super.key,
  });

  final PortalTenant tenant;
  final VoidCallback onContinue;

  Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    var value = hex.replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    final parsed = int.tryParse(value, radix: 16);
    return parsed == null ? fallback : Color(parsed);
  }

  @override
  Widget build(BuildContext context) {
    const fallbackPrimary = Color(0xFF2563EB);
    final primary = _parseColor(tenant.primaryColor, fallbackPrimary);

    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: primary,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 48,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Logo(tenant: tenant, color: primary),
                    const SizedBox(height: 24),
                    Text(
                      tenant.schoolName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Powered by School Pulse',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    if (_hasContactInfo)
                      _ContactBlock(tenant: tenant)
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: onContinue,
                        child: const Text('Sign in to School Pulse'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasContactInfo =>
      (tenant.address?.isNotEmpty ?? false) ||
      (tenant.phone?.isNotEmpty ?? false) ||
      (tenant.email?.isNotEmpty ?? false);
}

class _Logo extends StatelessWidget {
  const _Logo({required this.tenant, required this.color});
  final PortalTenant tenant;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final logoUrl = tenant.logoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          logoUrl,
          width: 88,
          height: 88,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initialsFallback(),
        ),
      );
    }
    return _initialsFallback();
  }

  Widget _initialsFallback() {
    final initials = tenant.schoolName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? 'SP' : initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ContactBlock extends StatelessWidget {
  const _ContactBlock({required this.tenant});
  final PortalTenant tenant;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tenant.address?.isNotEmpty ?? false)
            _ContactRow(icon: Icons.location_on_outlined, text: tenant.address!),
          if (tenant.phone?.isNotEmpty ?? false)
            _ContactRow(icon: Icons.call_outlined, text: tenant.phone!),
          if (tenant.email?.isNotEmpty ?? false)
            _ContactRow(icon: Icons.mail_outline, text: tenant.email!),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
