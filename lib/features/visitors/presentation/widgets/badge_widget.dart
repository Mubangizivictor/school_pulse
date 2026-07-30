import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:school_pulse/core/theme_provider.dart';
import '../../domain/entities/visitor.dart';
import 'package:intl/intl.dart';

class VisitorBadgeWidget extends StatelessWidget {
  final Visitor visitor;
  final String schoolName;

  const VisitorBadgeWidget({
    super.key,
    required this.visitor,
    required this.schoolName,
  });

  Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return fallback;
    }
  }

  DateTime get _expiry {
    final arrival = visitor.arrivalTime;
    return visitor.expectedDepartureTime ?? DateTime(arrival.year, arrival.month, arrival.day, 23, 59);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final config = themeProvider.config;
    final primaryColor = _parseColor(config?.primaryColor, Colors.blue);
    final secondaryColor = _parseColor(config?.secondaryColor, Colors.red);

    return Container(
      width: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              if (config?.schoolLogoUrl != null)
                Image.network(config!.schoolLogoUrl!, height: 40, width: 40)
              else
                Icon(Icons.school, size: 40, color: primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config?.schoolName ?? schoolName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'VISITOR PASS',
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          
          // Visitor Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              Container(
                width: 100,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: visitor.photoLocalPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(visitor.photoLocalPath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visitor.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${visitor.category.name.toUpperCase()}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Host', value: visitor.host),
                    _InfoRow(label: 'Dept', value: visitor.department),
                    _InfoRow(label: 'Date', value: DateFormat('dd MMM yyyy').format(visitor.arrivalTime)),
                    _InfoRow(label: 'In', value: DateFormat('HH:mm').format(visitor.arrivalTime)),
                    _InfoRow(label: 'Expires', value: DateFormat('dd MMM, HH:mm').format(_expiry)),
                    if (visitor.badgeNumber.isNotEmpty)
                      _InfoRow(label: 'Badge #', value: visitor.badgeNumber),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // QR and Purpose
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PURPOSE:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      visitor.purpose,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              QrImageView(
                data: visitor.id,
                version: QrVersions.auto,
                size: 80.0,
                eyeStyle: QrEyeStyle(color: primaryColor),
                dataModuleStyle: QrDataModuleStyle(color: primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
