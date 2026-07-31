import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

/// One student's worth of data for a batch print run.
class IdCardBatchEntry {
  final String studentName;
  final String admissionNumber;
  final String studentId;
  final String className;
  final String stream;
  final String uniqueSystemId;
  final Uint8List? studentPhotoBytes;

  const IdCardBatchEntry({
    required this.studentName,
    required this.admissionNumber,
    required this.studentId,
    required this.className,
    required this.stream,
    required this.uniqueSystemId,
    this.studentPhotoBytes,
  });
}

class IdCardService {
  Future<Uint8List> generateIdCardPdf({
    required String schoolName,
    required String studentName,
    required String admissionNumber,
    required String studentId,
    required String className,
    required String stream,
    required String uniqueSystemId,
    Uint8List? schoolLogoBytes,
    Uint8List? studentPhotoBytes,
  }) async {
    final pdf = pw.Document();
    final page = await _buildCardPage(
      schoolName: schoolName,
      studentName: studentName,
      admissionNumber: admissionNumber,
      studentId: studentId,
      className: className,
      stream: stream,
      uniqueSystemId: uniqueSystemId,
      studentPhotoBytes: studentPhotoBytes,
    );
    pdf.addPage(page);
    return pdf.save();
  }

  /// One multi-page PDF covering every entry - sent to the printer as a
  /// single job instead of printing each student's card one at a time.
  Future<Uint8List> generateBatchIdCardsPdf({
    required String schoolName,
    required List<IdCardBatchEntry> entries,
  }) async {
    final pdf = pw.Document();
    for (final entry in entries) {
      final page = await _buildCardPage(
        schoolName: schoolName,
        studentName: entry.studentName,
        admissionNumber: entry.admissionNumber,
        studentId: entry.studentId,
        className: entry.className,
        stream: entry.stream,
        uniqueSystemId: entry.uniqueSystemId,
        studentPhotoBytes: entry.studentPhotoBytes,
      );
      pdf.addPage(page);
    }
    return pdf.save();
  }

  Future<pw.Page> _buildCardPage({
    required String schoolName,
    required String studentName,
    required String admissionNumber,
    required String studentId,
    required String className,
    required String stream,
    required String uniqueSystemId,
    Uint8List? studentPhotoBytes,
  }) async {
    final qrValidationResult = QrValidator.validate(
      data: uniqueSystemId,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode!,
      eyeStyle: const QrEyeStyle(color: ui.Color(0xFF000000)),
      dataModuleStyle: const QrDataModuleStyle(color: ui.Color(0xFF000000)),
      gapless: true,
    );

    final qrImageData = await painter.toImageData(200);
    final qrBytes = qrImageData!.buffer.asUint8List();

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Container(
            width: 250,
            height: 400,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey, width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  schoolName.toUpperCase(),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                if (studentPhotoBytes != null)
                  pw.Container(
                    width: 80,
                    height: 80,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      image: pw.DecorationImage(
                        image: pw.MemoryImage(studentPhotoBytes),
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                  )
                else
                  pw.Container(
                    width: 80,
                    height: 80,
                    decoration: const pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      color: PdfColors.grey300,
                    ),
                  ),
                pw.SizedBox(height: 10),
                pw.Text(
                  studentName.toUpperCase(),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 15),
                _buildCardRow('Admission:', admissionNumber),
                _buildCardRow('Student ID:', studentId),
                _buildCardRow('Class:', '$className $stream'),
                pw.Spacer(),
                pw.Image(pw.MemoryImage(qrBytes), width: 100, height: 100),
                pw.SizedBox(height: 5),
                pw.Text(
                  uniqueSystemId,
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  pw.Widget _buildCardRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> printIdCard(Uint8List pdfData) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
  }
}
