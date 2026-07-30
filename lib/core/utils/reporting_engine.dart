import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import '../../features/inventory/domain/entities/purchase_order.dart';
import '../../features/inventory/domain/entities/inventory_item.dart';
import '../../features/inventory/domain/entities/asset.dart';
import '../../features/security/domain/entities/security_entities.dart';

class ReportingEngine {
  static Future<void> exportInventoryToExcel(List<InventoryItem> items) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Inventory';

    // Headers
    sheet.getRangeByIndex(1, 1).setText('Name');
    sheet.getRangeByIndex(1, 2).setText('Category');
    sheet.getRangeByIndex(1, 3).setText('Quantity');
    sheet.getRangeByIndex(1, 4).setText('Unit');
    sheet.getRangeByIndex(1, 5).setText('Location');

    // Data
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      sheet.getRangeByIndex(i + 2, 1).setText(item.name);
      sheet.getRangeByIndex(i + 2, 2).setText(item.category);
      sheet.getRangeByIndex(i + 2, 3).setNumber(item.quantity.toDouble());
      sheet.getRangeByIndex(i + 2, 4).setText(item.unit);
      sheet.getRangeByIndex(i + 2, 5).setText(item.storeLocation ?? '');
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/Inventory_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(fileName);
  }

  static Future<void> exportAssetsToExcel(List<Asset> assets) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Assets';

    // Headers
    sheet.getRangeByIndex(1, 1).setText('Asset #');
    sheet.getRangeByIndex(1, 2).setText('Name');
    sheet.getRangeByIndex(1, 3).setText('Category');
    sheet.getRangeByIndex(1, 4).setText('Status');
    sheet.getRangeByIndex(1, 5).setText('Condition');
    sheet.getRangeByIndex(1, 6).setText('Purchase Price');

    // Data
    for (int i = 0; i < assets.length; i++) {
      final asset = assets[i];
      sheet.getRangeByIndex(i + 2, 1).setText(asset.assetNumber);
      sheet.getRangeByIndex(i + 2, 2).setText(asset.name);
      sheet.getRangeByIndex(i + 2, 3).setText(asset.category);
      sheet.getRangeByIndex(i + 2, 4).setText(asset.status.name);
      sheet.getRangeByIndex(i + 2, 5).setText(asset.condition);
      sheet.getRangeByIndex(i + 2, 6).setNumber(asset.purchasePrice);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/Assets_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(fileName);
  }

  static Future<void> exportPurchaseOrderToPdf(PurchaseOrder order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('PURCHASE ORDER', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Order #: ${order.orderNumber}'),
                      pw.Text('Date: ${order.date.day}/${order.date.month}/${order.date.year}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 32),
              pw.Text('Supplier: ${order.supplierName}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 24),
              pw.TableHelper.fromTextArray(
                headers: ['Item', 'Quantity', 'Unit Price', 'Total'],
                data: order.items.map((item) => [
                  item.itemName,
                  item.quantity.toString(),
                  item.unitPrice.toStringAsFixed(0),
                  item.totalPrice.toStringAsFixed(0),
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 24),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total Amount: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('UGX ${order.totalAmount.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                ],
              ),
              pw.SizedBox(height: 48),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 150, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                      pw.Text('Prepared By'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 150, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                      pw.Text('Authorized Signature'),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  /// Covers both "Gate Reports" (daily entry/exit, gate usage, late
  /// arrivals) and "Student Movement Reports" (early departures, pickup
  /// history, boarding movement) from the same underlying data - the caller
  /// filters/date-ranges the list before passing it in.
  static Future<void> exportStudentMovementsToExcel(List<StudentMovement> movements) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Student Movements';

    const headers = ['Student', 'Class', 'Date/Time', 'Gate', 'Direction', 'Type', 'Verification Method', 'Officer'];
    for (var i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    for (var i = 0; i < movements.length; i++) {
      final m = movements[i];
      final row = i + 2;
      sheet.getRangeByIndex(row, 1).setText(m.studentName);
      sheet.getRangeByIndex(row, 2).setText(m.className);
      sheet.getRangeByIndex(row, 3).setText(m.timestamp.toLocal().toString());
      sheet.getRangeByIndex(row, 4).setText(m.gateId);
      sheet.getRangeByIndex(row, 5).setText(m.direction);
      sheet.getRangeByIndex(row, 6).setText(m.movementType);
      sheet.getRangeByIndex(row, 7).setText(m.verificationMethod);
      sheet.getRangeByIndex(row, 8).setText(m.officerId);
    }

    await _saveAndOpenExcel(workbook, 'Student_Movements_Report');
  }

  static Future<void> exportSecurityIncidentsToExcel(List<SecurityIncident> incidents) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Security Incidents';

    const headers = ['Type', 'Description', 'Date/Time', 'Location', 'Status', 'Reported By', 'Resolution'];
    for (var i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    for (var i = 0; i < incidents.length; i++) {
      final incident = incidents[i];
      final row = i + 2;
      sheet.getRangeByIndex(row, 1).setText(incident.type);
      sheet.getRangeByIndex(row, 2).setText(incident.description);
      sheet.getRangeByIndex(row, 3).setText(incident.timestamp.toLocal().toString());
      sheet.getRangeByIndex(row, 4).setText(incident.location);
      sheet.getRangeByIndex(row, 5).setText(incident.status);
      sheet.getRangeByIndex(row, 6).setText(incident.reportedByOfficerId);
      sheet.getRangeByIndex(row, 7).setText(incident.report);
    }

    await _saveAndOpenExcel(workbook, 'Security_Incidents_Report');
  }

  static Future<void> exportPatrolLogToExcel(List<SecurityPatrol> patrols) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Security Patrols';

    const headers = ['Location', 'Date/Time', 'Officer', 'Observations', 'Issues Found'];
    for (var i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    for (var i = 0; i < patrols.length; i++) {
      final patrol = patrols[i];
      final row = i + 2;
      sheet.getRangeByIndex(row, 1).setText(patrol.location);
      sheet.getRangeByIndex(row, 2).setText(patrol.timestamp.toLocal().toString());
      sheet.getRangeByIndex(row, 3).setText(patrol.officerId);
      sheet.getRangeByIndex(row, 4).setText(patrol.observations);
      sheet.getRangeByIndex(row, 5).setText(patrol.issuesFound.join('; '));
    }

    await _saveAndOpenExcel(workbook, 'Security_Patrols_Report');
  }

  static Future<void> exportLostAndFoundToExcel(List<LostAndFoundItem> items) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Lost and Found';

    const headers = ['Description', 'Location Found', 'Date Found', 'Status', 'Found By'];
    for (var i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final row = i + 2;
      sheet.getRangeByIndex(row, 1).setText(item.description);
      sheet.getRangeByIndex(row, 2).setText(item.locationFound);
      sheet.getRangeByIndex(row, 3).setText(item.dateFound.toLocal().toString());
      sheet.getRangeByIndex(row, 4).setText(item.isClaimed ? 'Claimed' : 'Unclaimed');
      sheet.getRangeByIndex(row, 5).setText(item.foundByPersonId);
    }

    await _saveAndOpenExcel(workbook, 'Lost_And_Found_Report');
  }

  static Future<void> _saveAndOpenExcel(Workbook workbook, String baseName) async {
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/${baseName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final File file = File(fileName);
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(fileName);
  }
}
