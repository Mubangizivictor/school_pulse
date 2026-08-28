import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'finance_reports_service.dart';

/// Renders a [FinanceReport] as a simple, monochrome, printable PDF —
/// used for the two report types the audit calls out for print/share
/// (cashbook, arrears). Data is passed straight from the already-built
/// report; nothing is recomputed here.
class FinanceReportPdf {
  static Future<Uint8List> generate(
    FinanceReport report, {
    required String schoolName,
  }) async {
    final doc = pw.Document();
    final headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 9,
    );
    final cellStyle = const pw.TextStyle(fontSize: 8.5);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              schoolName,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
            ),
            pw.SizedBox(height: 2),
            pw.Text(report.title, style: const pw.TextStyle(fontSize: 11)),
            pw.Text(
              'Period: ${report.rangeLabel}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.Divider(),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: headerStyle,
            cellStyle: cellStyle,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellAlignment: pw.Alignment.centerLeft,
            headers: report.columns,
            data: report.rows,
          ),
          if (report.totals.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Divider(),
            ...report.totals.entries.map(
              (e) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 1),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(e.key, style: headerStyle),
                    pw.Text(e.value, style: cellStyle),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
    return doc.save();
  }
}
