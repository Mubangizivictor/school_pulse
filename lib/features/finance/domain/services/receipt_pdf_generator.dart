import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../entities/student_bill.dart';

/// Renders a single [StudentPayment] as a downloadable/shareable PDF receipt
/// for parents - a client-side convenience copy, not the school's official
/// printed receipt. QR verification and amount-in-words are rendered
/// straight from the server-generated fields on [StudentPayment]
/// (`amountInWords`/`qrVerificationUrl`, set by `confirmPendingPayment` in
/// functions/payment_codes.js) - never recomputed client-side.
class ReceiptPdfGenerator {
  static Future<Uint8List> generate({
    required StudentPayment payment,
    required String studentName,
    required String schoolName,
  }) async {
    final pdf = pw.Document();
    final currency = NumberFormat.currency(symbol: '', decimalDigits: 0);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              schoolName,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Payment Receipt', style: const pw.TextStyle(fontSize: 12)),
            pw.Divider(),
            pw.SizedBox(height: 12),
            _row('Receipt No.', payment.receiptNumber),
            _row('Student', studentName),
            _row(
              'Date',
              payment.recordedAt != null
                  ? DateFormat('d MMM yyyy').format(payment.recordedAt!)
                  : '—',
            ),
            _row('Method', payment.method),
            if (payment.referenceNumber != null)
              _row('Reference', payment.referenceNumber!),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Amount Paid',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  currency.format(payment.amountUgx.abs()).trim(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (payment.amountInWords != null) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                payment.amountInWords!,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
            if (payment.qrVerificationUrl != null) ...[
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: payment.qrVerificationUrl!,
                      width: 72,
                      height: 72,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Scan to verify',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static Future<void> download({
    required StudentPayment payment,
    required String studentName,
    required String schoolName,
  }) async {
    final bytes = await generate(
      payment: payment,
      studentName: studentName,
      schoolName: schoolName,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'receipt_${payment.receiptNumber}.pdf',
    );
  }

  static pw.Widget _row(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
        pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
      ],
    ),
  );
}
