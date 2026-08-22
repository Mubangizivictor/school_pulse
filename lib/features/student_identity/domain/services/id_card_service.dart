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

  /// Server-signed credential envelope to encode in the QR. Falls back to
  /// [uniqueSystemId] at the call site for identities issued before signing
  /// existed - this service always just encodes whatever it's given.
  final String qrCodeData;
  final Uint8List? studentPhotoBytes;

  const IdCardBatchEntry({
    required this.studentName,
    required this.admissionNumber,
    required this.studentId,
    required this.className,
    required this.stream,
    required this.uniqueSystemId,
    required this.qrCodeData,
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
    String academicYear = '',
    required String qrCodeData,
    Uint8List? schoolLogoBytes,
    Uint8List? studentPhotoBytes,
  }) async {
    final pdf = pw.Document();
    final front = await _buildCardPage(
      schoolName: schoolName,
      studentName: studentName,
      admissionNumber: admissionNumber,
      studentId: studentId,
      className: className,
      stream: stream,
      uniqueSystemId: uniqueSystemId,
      academicYear: academicYear,
      qrCodeData: qrCodeData,
      studentPhotoBytes: studentPhotoBytes,
    );
    final back = await _buildCardBackPage(
      schoolName: schoolName,
      qrCodeData: qrCodeData,
    );
    pdf
      ..addPage(front)
      ..addPage(back);
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
      final front = await _buildCardPage(
        schoolName: schoolName,
        studentName: entry.studentName,
        admissionNumber: entry.admissionNumber,
        studentId: entry.studentId,
        className: entry.className,
        stream: entry.stream,
        uniqueSystemId: entry.uniqueSystemId,
        qrCodeData: entry.qrCodeData,
        studentPhotoBytes: entry.studentPhotoBytes,
      );
      final back = await _buildCardBackPage(
        schoolName: schoolName,
        qrCodeData: entry.qrCodeData,
      );
      pdf
        ..addPage(front)
        ..addPage(back);
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
    String academicYear = '',
    required String qrCodeData,
    Uint8List? studentPhotoBytes,
  }) async {
    return pw.Page(
      pageFormat: PdfPageFormat(
        85.60 * PdfPageFormat.mm,
        53.98 * PdfPageFormat.mm,
      ),
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Container(
            width: 85.60 * PdfPageFormat.mm,
            height: 53.98 * PdfPageFormat.mm,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey, width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  schoolName.toUpperCase(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                if (studentPhotoBytes != null)
                  pw.Container(
                    width: 48,
                    height: 48,
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
                    width: 48,
                    height: 48,
                    decoration: const pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      color: PdfColors.grey300,
                    ),
                  ),
                pw.SizedBox(height: 5),
                pw.Text(
                  studentName.toUpperCase(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                _buildCardRow('Class', '$className $stream'),
                _buildCardRow('Student code', studentId),
                _buildCardRow('Admission no.', admissionNumber),
                if (academicYear.isNotEmpty)
                  _buildCardRow('Academic year', academicYear),
                pw.Spacer(),
                pw.Text(
                  'This card is the property of $schoolName.',
                  style: const pw.TextStyle(
                    fontSize: 6,
                    color: PdfColors.grey700,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<pw.Page> _buildCardBackPage({
    required String schoolName,
    required String qrCodeData,
  }) async {
    if (qrCodeData.isEmpty) {
      throw StateError(
        'A signed QR credential is required to print this card.',
      );
    }
    final validation = QrValidator.validate(
      data: qrCodeData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
    final qr = validation.qrCode;
    if (qr == null) {
      throw StateError('The QR credential could not be encoded.');
    }
    final data = await QrPainter.withQr(
      qr: qr,
      eyeStyle: const QrEyeStyle(color: ui.Color(0xFF000000)),
      dataModuleStyle: const QrDataModuleStyle(color: ui.Color(0xFF000000)),
      gapless: true,
    ).toImageData(320);
    if (data == null) {
      throw StateError('The QR credential image could not be generated.');
    }
    return pw.Page(
      pageFormat: PdfPageFormat(
        85.60 * PdfPageFormat.mm,
        53.98 * PdfPageFormat.mm,
      ),
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey, width: 1),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              schoolName.toUpperCase(),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.SizedBox(height: 7),
            pw.Image(
              pw.MemoryImage(data.buffer.asUint8List()),
              width: 108,
              height: 108,
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'Scan to verify student',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'Identity verified  •  Authorized access  •  Non-transferable',
              style: const pw.TextStyle(fontSize: 6),
              textAlign: pw.TextAlign.center,
            ),
            pw.Spacer(),
            pw.Text(
              'This card is the property of $schoolName. If found, please return it to the school.',
              style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildCardRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> printIdCard(Uint8List pdfData) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
  }

  Future<void> shareIdCard(Uint8List pdfData, String filename) =>
      Printing.sharePdf(bytes: pdfData, filename: filename);
}
