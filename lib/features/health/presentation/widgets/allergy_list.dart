import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class AllergyInfo {
  final String allergen;
  final String reaction;
  final String severity; // High, Medium, Low

  AllergyInfo({required this.allergen, required this.reaction, required this.severity});
}

class AllergyList extends StatelessWidget {
  final List<AllergyInfo> allergies;
  final VoidCallback? onAdd;

  const AllergyList({super.key, required this.allergies, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Allergies & Sensitivities', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (onAdd != null)
                  IconButton(
                    icon: const Icon(Icons.add_alert_outlined, size: 20),
                    onPressed: onAdd,
                  ),
              ],
            ),
          ),
          if (allergies.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16, left: 16),
              child: Text('No allergies reported.', style: TextStyle(fontStyle: FontStyle.italic)),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allergies.map((a) => _AllergyChip(allergy: a)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _AllergyChip extends StatelessWidget {
  final AllergyInfo allergy;
  const _AllergyChip({required this.allergy});

  @override
  Widget build(BuildContext context) {
    final color = allergy.severity.toLowerCase() == 'high' ? Colors.red : (allergy.severity.toLowerCase() == 'medium' ? Colors.orange : Colors.blue);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '${allergy.allergen}: ${allergy.reaction}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
