import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

/// Visitor badge PDF generator - a distinct, deliberately temporary-looking
/// template (orange banner, visible arrival date, no permanent-looking
/// styling) so it reads as a day pass, not a staff/student credential.
class VisitorIdCardService {
  Future<Uint8List> generateVisitorIdCardPdf({
    required String schoolName,
    required String visitorName,
    required String badgeNumber,
    required String host,
    required String purpose,
    required DateTime arrivalTime,
    Uint8List? visitorPhotoBytes,
  }) async {
    final pdf = pw.Document();

    final qrValidationResult = QrValidator.validate(
      data: badgeNumber,
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
            child: pw.Container(
              width: 250,
              height: 400,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.orange, width: 2),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(vertical: 10),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.orange,
                      borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          schoolName.toUpperCase(),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.white),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'VISITOR PASS',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  if (visitorPhotoBytes != null)
                    pw.Container(
                      width: 80,
                      height: 80,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        image: pw.DecorationImage(image: pw.MemoryImage(visitorPhotoBytes), fit: pw.BoxFit.cover),
                      ),
                    )
                  else
                    pw.Container(
                      width: 80,
                      height: 80,
                      decoration: const pw.BoxDecoration(shape: pw.BoxShape.circle, color: PdfColors.orange100),
                    ),
                  pw.SizedBox(height: 10),
                  pw.Text(visitorName.toUpperCase(),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16), textAlign: pw.TextAlign.center),
                  pw.SizedBox(height: 15),
                  _buildCardRow('Host:', host),
                  _buildCardRow('Purpose:', purpose),
                  _buildCardRow('Date:', arrivalTime.toLocal().toString().split(' ').first),
                  pw.Spacer(),
                  pw.Image(pw.MemoryImage(qrBytes), width: 100, height: 100),
                  pw.SizedBox(height: 5),
                  pw.Text(badgeNumber, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                  pw.SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildCardRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 16),
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
