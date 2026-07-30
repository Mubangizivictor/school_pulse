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
}
