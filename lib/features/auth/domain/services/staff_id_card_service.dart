import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

/// Staff ID card PDF generator - deliberately a distinct visual template
/// from the student card (dark banner + "STAFF" label) rather than a
/// parameterized version of IdCardService, since the spec requires
/// Teacher/Staff/Visitor/Student templates to all look different at a
/// glance, not just carry different data.
class StaffIdCardService {
  Future<Uint8List> generateStaffIdCardPdf({
    required String schoolName,
    required String staffName,
    required String staffCode,
    required String roleLabel,
    Uint8List? staffPhotoBytes,
    // Signed StaffIdentity.qrCodeData token to encode instead of the raw
    // staffCode - falls back to staffCode for callers issued before signed
    // identities existed.
    String? qrData,
  }) async {
    final pdf = pw.Document();

    final qrValidationResult = QrValidator.validate(
      data: qrData ?? staffCode,
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildFront(
                  schoolName: schoolName,
                  staffName: staffName,
                  staffCode: staffCode,
                  roleLabel: roleLabel,
                  staffPhotoBytes: staffPhotoBytes,
                ),
                pw.SizedBox(width: 16),
                _buildBack(schoolName: schoolName, qrBytes: qrBytes),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _cardShell({required pw.Widget child}) {
    return pw.Container(
      width: 220,
      height: 350,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: child,
    );
  }

  pw.Widget _cardHeader(String title, {String? subtitle}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      decoration: const pw.BoxDecoration(
        color: PdfColors.blueGrey900,
        borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(9)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
              color: PdfColors.white,
            ),
            textAlign: pw.TextAlign.center,
          ),
          if (subtitle != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              subtitle,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.amber,
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildFront({
    required String schoolName,
    required String staffName,
    required String staffCode,
    required String roleLabel,
    Uint8List? staffPhotoBytes,
  }) {
    return _cardShell(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _cardHeader(schoolName.toUpperCase(), subtitle: 'STAFF'),
          pw.SizedBox(height: 16),
          if (staffPhotoBytes != null)
            pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                image: pw.DecorationImage(
                  image: pw.MemoryImage(staffPhotoBytes),
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
                color: PdfColors.blueGrey100,
              ),
            ),
          pw.SizedBox(height: 10),
          pw.Text(
            staffName.toUpperCase(),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            roleLabel,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey700),
          ),
          pw.Spacer(),
          _buildCardRow('Staff Code:', staffCode),
          pw.SizedBox(height: 12),
        ],
      ),
    );
  }

  pw.Widget _buildBack({required String schoolName, required Uint8List qrBytes}) {
    return _cardShell(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _cardHeader('STAFF ID CARD'),
          pw.SizedBox(height: 18),
          pw.Image(pw.MemoryImage(qrBytes), width: 100, height: 100),
          pw.SizedBox(height: 14),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12),
            child: pw.Text(
              'THIS CARD IS THE PROPERTY OF ${schoolName.toUpperCase()}',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
                color: PdfColors.blueGrey700,
              ),
            ),
          ),
          pw.Spacer(),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12),
            child: pw.Text(
              'If found, please return to the school office.',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ),
          pw.SizedBox(height: 12),
        ],
      ),
    );
  }

  pw.Widget _buildCardRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 16),
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
}
