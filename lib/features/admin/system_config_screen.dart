import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class SystemConfigScreen extends StatelessWidget {
  const SystemConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('System Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSchoolIdentitySection(context),
            const SizedBox(height: 24),
            _buildAcademicCalendarSection(context),
            const SizedBox(height: 24),
            _buildIntegrationSettings(context),
            const SizedBox(height: 24),
            _buildSecuritySettings(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolIdentitySection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('School Identity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 32),
                    Text('Logo', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(
                child: Column(
                  children: [
                    TextField(decoration: InputDecoration(labelText: 'School Name', hintText: 'e.g. Kampala Heights Academy')),
                    SizedBox(height: 16),
                    TextField(decoration: InputDecoration(labelText: 'School Motto', hintText: 'e.g. Excellence in Service')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicCalendarSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Term & Session Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: TextField(decoration: InputDecoration(labelText: 'Current Term', hintText: 'Term 3'))),
              SizedBox(width: 16),
              Expanded(child: TextField(decoration: InputDecoration(labelText: 'Academic Year', hintText: '2023/2024'))),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: TextField(decoration: InputDecoration(labelText: 'Term Start Date', suffixIcon: Icon(Icons.calendar_today)))),
              SizedBox(width: 16),
              Expanded(child: TextField(decoration: InputDecoration(labelText: 'Term End Date', suffixIcon: Icon(Icons.calendar_today)))),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.history), label: const Text('Manage Past Sessions')),
        ],
      ),
    );
  }

  Widget _buildIntegrationSettings(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('External Integrations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.sms_outlined),
            title: const Text('SMS Gateway (Twilio)'),
            subtitle: const Text('Status: Connected • 14,500 Credits remaining'),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment_outlined),
            title: const Text('Payment Provider (Flutterwave)'),
            subtitle: const Text('Status: Live Mode'),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Security & Access Control', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text('Enforce Multi-Factor Authentication (MFA)'),
            subtitle: const Text('Require MFA for all staff with Admin/Bursar roles'),
            value: true, 
            onChanged: (v) {},
          ),
          CheckboxListTile(
            title: const Text('Restrict Login by IP Range'),
            subtitle: const Text('Limit staff logins to school network only'),
            value: false, 
            onChanged: (v) {},
          ),
        ],
      ),
    );
  }
}
