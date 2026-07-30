import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/visitor.dart';

class VisitorQRScreen extends StatelessWidget {
  final Visitor visitor;

  const VisitorQRScreen({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode({
      'id': visitor.id,
      'name': visitor.fullName,
      'arrival': visitor.arrivalTime.toIso8601String(),
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor QR Pass'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              visitor.fullName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Arrival: ${DateFormat('hh:mm a, MMM dd').format(visitor.arrivalTime)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 250.0,
              ),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Show this QR code at the gate when checking out.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
