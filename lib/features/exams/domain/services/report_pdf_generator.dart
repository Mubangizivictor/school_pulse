import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../entities/subject_result.dart';
import '../entities/report_template.dart';
import '../../../student/domain/entities/student.dart';
import 'qr_verification_service.dart';

class ReportPdfGenerator {
  static Future<Uint8List> generateReportCard({
    required Student student,
    required List<SubjectResult> results,
    required ReportTemplate template,
    required String schoolName,
    required String schoolId,
    required String term,
    required String year,
    String? schoolLogoUrl,
  }) async {
    final pdf = pw.Document();

    final logo = schoolLogoUrl != null
        ? await networkImage(schoolLogoUrl)
        : null;

    final studentPhoto = student.photoUrl != null
        ? await networkImage(student.photoUrl!)
        : null;

    final qrData = QrVerificationService.generateQrData(
      schoolId: schoolId,
      studentId: student.studentId,
      term: term,
      year: year,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(schoolName, logo, template),
              pw.SizedBox(height: 20),
              _buildStudentInfo(student, studentPhoto, term, year, template),
              pw.SizedBox(height: 20),
              _buildResultsTable(results, template),
              pw.SizedBox(height: 20),
              _buildSummary(results),
              pw.Spacer(),
              _buildFooter(template, qrData),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(
    String name,
    pw.ImageProvider? logo,
    ReportTemplate template,
  ) {
    return pw.Row(
      mainAxisAlignment: template.logoPosition == 'center'
          ? pw.MainAxisAlignment.center
          : (template.logoPosition == 'right'
                ? pw.MainAxisAlignment.end
                : pw.MainAxisAlignment.start),
      children: [
        if (logo != null)
          pw.Container(width: 80, height: 80, child: pw.Image(logo)),
        pw.SizedBox(width: 20),
        pw.Column(
          children: [
            pw.Text(
              name,
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(template.headerText),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildStudentInfo(
    Student student,
    pw.ImageProvider? photo,
    String term,
    String year,
    ReportTemplate template,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Name: ${student.name}'),
            pw.Text('Admission No: ${student.studentId}'),
            pw.Text('Class: ${student.className}'),
            pw.Text('Term: $term, $year'),
          ],
        ),
        if (photo != null && template.photoPosition != 'none')
          pw.Container(width: 70, height: 70, child: pw.Image(photo)),
      ],
    );
  }

  static pw.Widget _buildResultsTable(
    List<SubjectResult> results,
    ReportTemplate template,
  ) {
    return pw.TableHelper.fromTextArray(
      context: null,
      data: <List<String>>[
        <String>['Subject', 'Score', 'Grade', 'Remarks', 'Teacher'],
        ...results.map(
          (r) => [
            r.subjectName,
            r.percentage.toStringAsFixed(1),
            r.grade,
            r.remarks,
            r.teacherName,
          ],
        ),
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
      },
    );
  }

  static pw.Widget _buildSummary(List<SubjectResult> results) {
    double total = results.fold(0, (sum, r) => sum + r.percentage);
    double avg = results.isEmpty ? 0 : total / results.length;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Average Score: ${avg.toStringAsFixed(2)}%',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(ReportTemplate template, String qrData) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Divider(),
              pw.Text(template.footerText),
              pw.Text(
                'Generated by School Pulse',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Column(
          children: [
            pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: qrData,
              width: 60,
              height: 60,
            ),
            pw.SizedBox(height: 4),
            pw.Text('Verify Report', style: const pw.TextStyle(fontSize: 6)),
          ],
        ),
      ],
    );
  }
}
