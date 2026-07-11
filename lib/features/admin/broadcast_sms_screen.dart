import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';

class BroadcastSmsScreen extends StatefulWidget {
  const BroadcastSmsScreen({super.key});

  @override
  State<BroadcastSmsScreen> createState() => _BroadcastSmsScreenState();
}

class _BroadcastSmsScreenState extends State<BroadcastSmsScreen> {
  final _messageController = TextEditingController();
  final Set<String> _selectedRecipients = {'Parents'};
  bool _isScheduled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Broadcast Center'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildComposer(),
                  const SizedBox(height: 24),
                  _buildRecipientSelector(),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _buildSmsCreditsCard(),
                  const SizedBox(height: 24),
                  _buildRecentBroadcasts(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Compose Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          TextField(
            controller: _messageController,
            maxLines: 6,
            maxLength: 160,
            decoration: InputDecoration(
              hintText: 'Type your broadcast message here...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              fillColor: Theme.of(context).colorScheme.surface,
              filled: true,
            ),
            onChanged: (val) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${(_messageController.text.length / 160).ceil()} SMS Unit(s) will be used per recipient.',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Switch(
                value: _isScheduled,
                onChanged: (val) => setState(() => _isScheduled = val),
              ),
              const Text('Schedule for later'),
              if (_isScheduled) ...[
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('Select Date & Time'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _messageController.text.isEmpty ? null : () {},
              icon: const Icon(Icons.send),
              label: Text(_isScheduled ? 'Schedule Broadcast' : 'Send Broadcast Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientSelector() {
    final groups = ['Parents', 'All Staff', 'Teachers Only', 'Bursars & Admin', 'Specific Class Parents'];
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Target Audience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: groups.map((group) {
              final isSelected = _selectedRecipients.contains(group);
              return FilterChip(
                label: Text(group),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedRecipients.add(group);
                    } else {
                      _selectedRecipients.remove(group);
                    }
                  });
                },
              );
            }).toList(),
          ),
          if (_selectedRecipients.contains('Specific Class Parents')) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Select Classes:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['P.1', 'P.2', 'P.3', 'P.4', 'P.5', 'P.6', 'P.7'].map((c) {
                return ChoiceChip(
                  label: Text(c),
                  selected: false,
                  onSelected: (v) {},
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmsCreditsCard() {
    return AppCard(
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
      child: Column(
        children: [
          const Icon(Icons.account_balance_wallet, size: 40, color: Colors.blue),
          const SizedBox(height: 12),
          const Text('SMS Credits Available', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('14,582 Units', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: () {}, child: const Text('Top Up Credits')),
        ],
      ),
    );
  }

  Widget _buildRecentBroadcasts() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final items = [
                {'to': 'All Parents', 'msg': 'Term 3 Report Cards are now available...', 'date': '24 Oct'},
                {'to': 'Teachers', 'msg': 'Staff meeting scheduled for tomorrow 8am.', 'date': '22 Oct'},
                {'to': 'P.7 Parents', 'msg': 'Mock results are out. Please check portal.', 'date': '15 Oct'},
              ];
              return ListTile(
                title: Text(items[index]['to']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(items[index]['msg']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                trailing: Text(items[index]['date']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              );
            },
          ),
        ],
      ),
    );
  }
}
