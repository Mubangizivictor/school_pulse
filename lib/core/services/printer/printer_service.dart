import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/finance/domain/entities/payment_record.dart';
import 'package:school_pulse/features/library/domain/entities/library_resource.dart';
import 'package:school_pulse/features/visitors/domain/entities/visitor.dart';

/// Abstract interface for Printer Services to allow swapping between different
/// SDKs (Zebra, Brother, Sunmi, etc.) or network printers.
abstract class PrinterService {
  Future<bool> isConnected();
  Future<List<PrinterDevice>> discoverPrinters();
  Future<bool> connect(PrinterDevice device);
  Future<bool> disconnect();

  /// Prints a visitor badge using raw data or a generated image
  Future<bool> printVisitorBadge(Visitor visitor, {Uint8List? badgeImage});

  /// Prints a fee payment receipt
  Future<bool> printFeeReceipt(
    PaymentRecord payment,
    String studentName,
    String className,
  );

  /// Prints a QR label for a library resource
  Future<bool> printLibraryLabel(LibraryResource resource);

  /// Generic print command for testing or small receipts
  Future<bool> printText(String text);
}

class PrinterDevice {
  final String name;
  final String address;
  final PrinterType type;
  final dynamic originalDevice; // Store the original BluetoothDevice object

  PrinterDevice({
    required this.name,
    required this.address,
    required this.type,
    this.originalDevice,
  });
}

enum PrinterType { bluetooth, network, usb }

/// Implementation for Bluetooth Thermal Printers (Common for Gatehouses)
class ThermalPrinterService implements PrinterService {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  @override
  Future<bool> isConnected() async {
    return await bluetooth.isConnected ?? false;
  }

  @override
  Future<List<PrinterDevice>> discoverPrinters() async {
    try {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      return devices
          .map(
            (d) => PrinterDevice(
              name: d.name ?? 'Unknown Device',
              address: d.address ?? '',
              type: PrinterType.bluetooth,
              originalDevice: d,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error discovering printers: $e');
      return [];
    }
  }

  @override
  Future<bool> connect(PrinterDevice device) async {
    try {
      if (device.originalDevice is BluetoothDevice) {
        await bluetooth.connect(device.originalDevice as BluetoothDevice);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error connecting to printer: $e');
      return false;
    }
  }

  @override
  Future<bool> disconnect() async {
    try {
      await bluetooth.disconnect();
      return true;
    } catch (e) {
      debugPrint('Error disconnecting: $e');
      return false;
    }
  }

  @override
  Future<bool> printVisitorBadge(
    Visitor visitor, {
    Uint8List? badgeImage,
  }) async {
    bool? connected = await bluetooth.isConnected;
    if (connected != true) return false;

    try {
      // Print Header
      bluetooth.printNewLine();
      bluetooth.printCustom("VISITOR PASS", 3, 1); // Size 3, Center
      bluetooth.printCustom("--------------------------------", 1, 1);

      // Visitor Name
      bluetooth.printCustom(visitor.fullName.toUpperCase(), 2, 1);
      bluetooth.printNewLine();

      // Badge Details
      bluetooth.printLeftRight(
        "Category:",
        visitor.category.name.toUpperCase(),
        1,
      );
      bluetooth.printLeftRight("Phone:", visitor.phone, 1);
      if (visitor.company != null) {
        bluetooth.printLeftRight("Company:", visitor.company!, 1);
      }

      bluetooth.printCustom("--------------------------------", 1, 1);

      // Host and Department
      bluetooth.printLeftRight("Visiting:", visitor.host, 1);
      bluetooth.printLeftRight("Dept:", visitor.department, 1);

      // Time In
      final timeFormatter = DateFormat('dd MMM yyyy, HH:mm');
      bluetooth.printLeftRight(
        "In:",
        timeFormatter.format(visitor.arrivalTime),
        1,
      );

      final expiry =
          visitor.expectedDepartureTime ??
          DateTime(
            visitor.arrivalTime.year,
            visitor.arrivalTime.month,
            visitor.arrivalTime.day,
            23,
            59,
          );
      bluetooth.printLeftRight("Expires:", timeFormatter.format(expiry), 1);

      if (visitor.gateId != null) {
        bluetooth.printLeftRight("Gate:", visitor.gateId!, 1);
      }

      if (visitor.vehicleNumber != null) {
        bluetooth.printLeftRight("Vehicle:", visitor.vehicleNumber!, 1);
      }
      if (visitor.parkingSlot != null) {
        bluetooth.printLeftRight("Parking:", visitor.parkingSlot!, 1);
      }
      if (visitor.badgeNumber.isNotEmpty) {
        bluetooth.printLeftRight("Badge #:", visitor.badgeNumber, 1);
      }

      bluetooth.printNewLine();

      // Purpose
      bluetooth.printCustom("Purpose: ${visitor.purpose}", 1, 0);

      bluetooth.printNewLine();
      bluetooth.printCustom("VALID UNTIL EXPIRY ABOVE", 1, 1);

      // QR Code (Visitor ID for checkout)
      bluetooth.printQRcode(visitor.id, 200, 200, 1);

      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine();

      // Cut paper (if supported)
      bluetooth.paperCut();

      return true;
    } catch (e) {
      debugPrint('Error printing badge: $e');
      return false;
    }
  }

  @override
  Future<bool> printFeeReceipt(
    PaymentRecord payment,
    String studentName,
    String className,
  ) async {
    bool? connected = await bluetooth.isConnected;
    if (connected != true) return false;

    try {
      final currencyFormatter = NumberFormat.currency(
        symbol: 'UGX ',
        decimalDigits: 0,
      );
      final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');

      bluetooth.printNewLine();
      bluetooth.printCustom("OFFICIAL RECEIPT", 3, 1);
      bluetooth.printCustom("--------------------------------", 1, 1);

      bluetooth.printLeftRight("Receipt #:", payment.receiptNumber, 1);
      bluetooth.printLeftRight("Date:", dateFormatter.format(payment.date), 1);
      bluetooth.printCustom("--------------------------------", 1, 1);

      bluetooth.printCustom("STUDENT DETAILS", 1, 1);
      bluetooth.printCustom(studentName.toUpperCase(), 2, 1);
      bluetooth.printCustom("Class: $className", 1, 1);
      bluetooth.printCustom(
        "Term: ${payment.term} - ${payment.academicYear}",
        1,
        1,
      );
      bluetooth.printNewLine();

      bluetooth.printCustom("PAYMENT SUMMARY", 1, 1);
      payment.feeBreakdown.forEach((category, amount) {
        bluetooth.printLeftRight(category, currencyFormatter.format(amount), 1);
      });

      bluetooth.printCustom("--------------------------------", 1, 1);
      bluetooth.printCustom("TOTAL PAID", 1, 1);
      bluetooth.printCustom(currencyFormatter.format(payment.amount), 3, 1);
      bluetooth.printCustom("--------------------------------", 1, 1);

      bluetooth.printLeftRight("Method:", payment.method, 1);
      bluetooth.printLeftRight("Ref:", payment.reference, 1);
      bluetooth.printLeftRight("Served By:", payment.recordedBy, 1);

      if (payment.notes != null && payment.notes!.isNotEmpty) {
        bluetooth.printNewLine();
        bluetooth.printCustom("Notes: ${payment.notes}", 1, 0);
      }

      bluetooth.printNewLine();
      bluetooth.printCustom("Scan to verify receipt", 1, 1);

      // QR Code for verification (contains payment ID and school ID for lookup)
      final qrData = 'PAY|${payment.schoolId}|${payment.id}';
      bluetooth.printQRcode(qrData, 200, 200, 1);

      bluetooth.printNewLine();
      bluetooth.printCustom("Thank you for your payment!", 1, 1);

      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine();

      bluetooth.paperCut();

      return true;
    } catch (e) {
      debugPrint('Error printing receipt: $e');
      return false;
    }
  }

  @override
  Future<bool> printLibraryLabel(LibraryResource resource) async {
    bool? connected = await bluetooth.isConnected;
    if (connected != true) return false;

    try {
      bluetooth.printNewLine();
      bluetooth.printCustom(resource.title.toUpperCase(), 2, 1);
      bluetooth.printCustom("Author: ${resource.author}", 1, 1);
      bluetooth.printCustom("Category: ${resource.category}", 1, 1);
      bluetooth.printCustom(
        "Shelf: ${resource.shelf} | Rack: ${resource.rack}",
        1,
        1,
      );

      bluetooth.printNewLine();
      bluetooth.printQRcode(resource.qrCode, 200, 200, 1);
      bluetooth.printCustom(resource.barcode, 1, 1);

      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.paperCut();

      return true;
    } catch (e) {
      debugPrint('Error printing library label: $e');
      return false;
    }
  }

  @override
  Future<bool> printText(String text) async {
    bool? connected = await bluetooth.isConnected;
    if (connected != true) return false;

    try {
      bluetooth.printCustom(text, 1, 0);
      bluetooth.printNewLine();
      return true;
    } catch (e) {
      debugPrint('Error printing text: $e');
      return false;
    }
  }
}
