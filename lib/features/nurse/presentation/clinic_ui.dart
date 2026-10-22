import 'package:flutter/material.dart';

/// Shared visual language for the privacy-first nurse workspace.  Keeping it
/// local to the clinic prevents health states from inheriting unrelated module
/// colours (where red/green may have different meanings).
abstract final class ClinicUi {
  static const black = Color(0xFF111111);
  static const muted = Color(0xFF6D6D73);
  static const line = Color(0xFFE5E5E7);
  static const surface = Color(0xFFF7F7F8);
  static const red = Color(0xFFD92D20);
  static const green = Color(0xFF16803A);

  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF111111)
      : Colors.white;

  static Color foreground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white : black;

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1C1C1E)
      : Colors.white;

  static BoxDecoration outlinedCard(BuildContext context) => BoxDecoration(
    color: card(context),
    borderRadius: BorderRadius.circular(9),
    border: Border.all(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3A3A3C)
          : line,
    ),
  );

  static Widget pill(String text, {required Color color}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .11),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}

class ClinicPage extends StatelessWidget {
  const ClinicPage({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
  });
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ClinicUi.background(context),
    appBar: appBar,
    floatingActionButton: floatingActionButton,
    body: SafeArea(top: appBar == null, child: child),
  );
}

class ClinicEmptyState extends StatelessWidget {
  const ClinicEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.medical_services_outlined,
  });
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 38, color: ClinicUi.muted),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: ClinicUi.foreground(context),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: ClinicUi.muted),
          ),
        ],
      ),
    ),
  );
}
