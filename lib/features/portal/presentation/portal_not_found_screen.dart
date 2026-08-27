import 'package:flutter/material.dart';

class PortalNotFoundScreen extends StatelessWidget {
  const PortalNotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.domain_disabled_outlined, size: 56),
              SizedBox(height: 20),
              Text(
                'School portal not found',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12),
              Text(
                'This school portal is unavailable or its address is not configured. Please check the link or contact the school.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
