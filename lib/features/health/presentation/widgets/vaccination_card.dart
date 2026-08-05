import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/health/domain/entities/student_health_profile.dart';

class VaccinationCard extends StatelessWidget {
  final List<VaccinationRecord> records;
  final VoidCallback? onAdd;

  const VaccinationCard({super.key, required this.records, this.onAdd});

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
                Text(
                  'Vaccination Records',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onAdd != null)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    onPressed: onAdd,
                  ),
              ],
            ),
          ),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16, left: 16),
              child: Text(
                'No vaccination records found.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final record = records[index];
                return ListTile(
                  leading: const Icon(
                    Icons.vaccines_outlined,
                    color: Colors.blue,
                  ),
                  title: Text(
                    record.vaccineName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Administered: ${DateFormatter.format(record.dateAdministered)}',
                  ),
                  trailing: const Tooltip(
                    message: 'On file',
                    child: Icon(
                      Icons.verified_user,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
