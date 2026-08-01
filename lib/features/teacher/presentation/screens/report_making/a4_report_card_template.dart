import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme.dart';

class A4ReportCardTemplate extends StatelessWidget {
  const A4ReportCardTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('A4 Report Template'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.print, color: Colors.white),
            label: const Text('Print PDF', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Container(
              width: 794, // A4 width in pixels at 96 DPI (approx)
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildStudentInfo(),
                  const SizedBox(height: 24),
                  _buildAcademicTable(),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildCompetencySection()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildAttendanceConductSection()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildRemarksSection(),
                  const SizedBox(height: 48),
                  _buildSignatures(),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'This is a computer generated report card. Signature is valid without seal.',
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.school, size: 60, color: SemanticColors.primary),
        const Expanded(
          child: Column(
            children: [
              Text(
                'LITTLE SAINTS INTERNATIONAL SCHOOL',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                '123 Education Lane, Victory Island, Lagos State, Nigeria',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'Email: info@littlesaints.sch.ng | Phone: +234 801 234 5678',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 8),
              Text(
                'ACADEMIC PERFORMANCE REPORT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, decoration: TextDecoration.underline),
              ),
            ],
          ),
        ),
        Container(
          width: 60,
          height: 70,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: const Center(child: Text('Photo', style: TextStyle(fontSize: 10))),
        ),
      ],
    );
  }

  Widget _buildStudentInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _infoItem('NAME OF STUDENT:', 'AMARA OKORO', flex: 2),
              _infoItem('ADM NO:', 'LSIS/2021/042'),
            ],
          ),
          const Divider(),
          Row(
            children: [
              _infoItem('CLASS:', 'PRIMARY 2 GOLD'),
              _infoItem('TERM:', 'FIRST TERM'),
              _infoItem('SESSION:', '2023/2024'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 12),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ACADEMIC RECORD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.black),
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(2),
          },
          children: [
            _buildTableHeader(),
            _buildTableRow('Mathematics', '35', '55', '90', 'A+', 'Distinction'),
            _buildTableRow('English Language', '30', '52', '82', 'A', 'Excellent'),
            _buildTableRow('Basic Science', '28', '48', '76', 'B+', 'Very Good'),
            _buildTableRow('Social Studies', '32', '50', '82', 'A', 'Excellent'),
            _buildTableRow('Physical Education', '38', '58', '96', 'A+', 'Distinction'),
            _buildTableRow('Information Tech.', '34', '54', '88', 'A', 'Excellent'),
            _buildTableRow('Creative Arts', '30', '45', '75', 'B+', 'Very Good'),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return const TableRow(
      decoration: BoxDecoration(color: Colors.black12),
      children: [
        Padding(padding: EdgeInsets.all(8), child: Text('SUBJECT', style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.all(8), child: Text('CA', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.all(8), child: Text('EXAM', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.all(8), child: Text('TOTAL', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.all(8), child: Text('GRADE', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.all(8), child: Text('REMARKS', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  TableRow _buildTableRow(String subject, String ca, String exam, String total, String grade, String remark) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text(subject)),
        Padding(padding: const EdgeInsets.all(8), child: Text(ca, textAlign: TextAlign.center)),
        Padding(padding: const EdgeInsets.all(8), child: Text(exam, textAlign: TextAlign.center)),
        Padding(padding: const EdgeInsets.all(8), child: Text(total, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(8), child: Text(grade, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(8), child: Text(remark, textAlign: TextAlign.center)),
      ],
    );
  }

  Widget _buildCompetencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AFFECTIVE & PSYCHOMOTOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.black),
          children: [
            _skillRow('Punctuality', '5'),
            _skillRow('Neatness', '5'),
            _skillRow('Politeness', '4'),
            _skillRow('Honesty', '5'),
            _skillRow('Self Control', '4'),
            _skillRow('Creativity', '5'),
            _skillRow('Sports', '3'),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Key: 5-Excellent, 4-Very Good, 3-Good, 2-Fair, 1-Poor', style: TextStyle(fontSize: 10)),
      ],
    );
  }

  TableRow _skillRow(String skill, String rating) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(6), child: Text(skill, style: const TextStyle(fontSize: 11))),
        Padding(padding: const EdgeInsets.all(6), child: Text(rating, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildAttendanceConductSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ATTENDANCE & CONDUCT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        _summaryBox('Attendance', '95 / 100 Days'),
        const SizedBox(height: 12),
        _summaryBox('Conduct', 'Amara exhibits exemplary behavior. She is respectful to staff and peers.'),
      ],
    );
  }

  Widget _summaryBox(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRemarksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('GENERAL REMARKS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: const Text(
            'Amara is a very dedicated student. She has shown remarkable improvement in her Mathematics skills this term. Her participation in class activities is commendable. Keep up the good work!',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildSignatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _signatureLine('Class Teacher'),
        _signatureLine('Principal / Head Teacher'),
        _signatureLine('Parent / Guardian'),
      ],
    );
  }

  Widget _signatureLine(String title) {
    return Column(
      children: [
        Container(width: 150, height: 1, color: Colors.black),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
