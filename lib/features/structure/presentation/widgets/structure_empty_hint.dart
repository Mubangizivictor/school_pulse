import 'package:flutter/material.dart';

/// Shared "nothing here yet" placeholder used across every Structure tab.
class StructureEmptyHint extends StatelessWidget {
  final String message;
  const StructureEmptyHint(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}
