import 'package:flutter/material.dart';

class ReportTemplateConfigScreen extends StatefulWidget {
  final String schoolId;
  const ReportTemplateConfigScreen({super.key, required this.schoolId});

  @override
  State<ReportTemplateConfigScreen> createState() =>
      _ReportTemplateConfigScreenState();
}

class _ReportTemplateConfigScreenState
    extends State<ReportTemplateConfigScreen> {
  String _tableLayout = 'traditional';
  bool _showRanking = false;
  bool _showSubjectPosition = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Template Designer'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('SAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Configuration
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layout Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _tableLayout,
                    decoration: const InputDecoration(
                      labelText: 'Table Layout',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'traditional',
                        child: Text('Traditional (Marks & Grades)'),
                      ),
                      DropdownMenuItem(
                        value: 'competency',
                        child: Text('Competency (Lower Secondary)'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _tableLayout = v!),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Show Class Ranking'),
                    value: _showRanking,
                    onChanged: (v) => setState(() => _showRanking = v),
                  ),
                  SwitchListTile(
                    title: const Text('Show Subject Positions'),
                    value: _showSubjectPosition,
                    onChanged: (v) => setState(() => _showSubjectPosition = v),
                  ),
                  const Divider(),
                  const Text(
                    'Branding',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('School Logo'),
                    trailing: const Icon(Icons.image),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text('Custom Header Text'),
                    subtitle: const Text(
                      'Edit official school title and address',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          // Live Preview
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(32),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'SCHOOL NAME & LOGO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Text(
                        'OFFICIAL REPORT CARD',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Name: John Doe'),
                          Text('Term: 1 2024'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Table(
                        border: TableBorder.all(),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[300]),
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Subject',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (_tableLayout == 'traditional') ...[
                                const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Score',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Grade',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Competency',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    'Score (1-3)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Mathematics'),
                              ),
                              if (_tableLayout == 'traditional') ...[
                                const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('85%'),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('D1'),
                                ),
                              ] else ...[
                                const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('High'),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('2.8'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Divider(),
                      const Text(
                        'QR AUTHENTICITY CODE',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
