import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../entities/timetable.dart';
import '../entities/timetable_config.dart';

const _kInk = PdfColor.fromInt(0xFF1A1A2E);
const _kMuted = PdfColor.fromInt(0xFF6B7280);
const _kBorder = PdfColor.fromInt(0xFFD6D9E0);
const _kHeaderFill = PdfColor.fromInt(0xFF1A1A2E);
const _kBreakFill = PdfColor.fromInt(0xFFF3F4F6);
const _kZebraFill = PdfColor.fromInt(0xFFF9FAFB);

/// Renders a class/stream timetable to a real, positioned PDF table -
/// never a screenshot of the app. A4 landscape with a MultiPage body, so a
/// school with an unusually long day still paginates cleanly instead of
/// overflowing or crashing.
class TimetablePdfGenerator {
  static Future<Uint8List> generate({
    required Timetable timetable,
    required TimetableConfig config,
    required List<TimetableLesson> lessons,
    required String schoolName,
    required String academicYearName,
    required String termName,
    String? classLabel,
    String? schoolLogoUrl,
  }) async {
    final pdf = pw.Document();

    final logo = schoolLogoUrl != null && schoolLogoUrl.isNotEmpty
        ? await networkImage(schoolLogoUrl)
        : null;

    final sortedSlots = [...config.slots]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final days = config.teachingDays;
    final label = classLabel ?? timetable.name;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 20),
        header: (context) => context.pageNumber == 1
            ? pw.Column(
                children: [
                  _buildHeader(
                    schoolName: schoolName,
                    logo: logo,
                    classLabel: label,
                    academicYearName: academicYearName,
                    termName: termName,
                  ),
                  pw.SizedBox(height: 14),
                ],
              )
            : pw.SizedBox(),
        footer: (context) =>
            _buildFooter(context.pageNumber, context.pagesCount),
        build: (context) => [
          _buildGrid(days: days, slots: sortedSlots, lessons: lessons),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader({
    required String schoolName,
    required pw.ImageProvider? logo,
    required String classLabel,
    required String academicYearName,
    required String termName,
  }) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logo != null) ...[
              pw.Container(width: 48, height: 48, child: pw.Image(logo)),
              pw.SizedBox(width: 14),
            ],
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    schoolName.isEmpty ? 'School' : schoolName,
                    style: pw.TextStyle(
                      fontSize: 17,
                      fontWeight: pw.FontWeight.bold,
                      color: _kInk,
                    ),
                  ),
                  pw.Text(
                    'Class Timetable',
                    style: const pw.TextStyle(fontSize: 10, color: _kMuted),
                  ),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  classLabel,
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    color: _kInk,
                  ),
                ),
                pw.Text(
                  [
                    academicYearName,
                    if (termName.isNotEmpty) termName,
                  ].join('  •  '),
                  style: const pw.TextStyle(fontSize: 10, color: _kMuted),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(height: 1.4, color: _kInk),
      ],
    );
  }

  static pw.Widget _buildGrid({
    required List<String> days,
    required List<TimetableSlot> slots,
    required List<TimetableLesson> lessons,
  }) {
    TimetableLesson? lessonAt(String day, String slotId) {
      for (final lesson in lessons) {
        for (final occurrence in lesson.occurrences) {
          if (occurrence.day == day && occurrence.slotId == slotId) {
            return lesson;
          }
        }
      }
      return null;
    }

    final visibleSlots = slots
        .where((slot) => slot.days.isEmpty || days.any(slot.days.contains))
        .toList();

    // Time column stays narrow and fixed; the day columns split the rest of
    // the page width evenly, however many teaching days the school runs.
    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(78),
      for (var i = 0; i < days.length; i++) i + 1: const pw.FlexColumnWidth(1),
    };

    return pw.Table(
      columnWidths: columnWidths,
      border: pw.TableBorder.all(color: _kBorder, width: 0.6),
      children: [
        _headerRow(days),
        ...visibleSlots.asMap().entries.map((entry) {
          final rowIndex = entry.key;
          final slot = entry.value;
          final isPeriod = slot.type == 'period';
          final fill = !isPeriod
              ? _kBreakFill
              : (rowIndex.isOdd ? _kZebraFill : PdfColors.white);
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: fill),
            children: [
              _timeCell(slot),
              ...days.map(
                (day) => isPeriod
                    ? _lessonCell(
                        slot.days.isNotEmpty && !slot.days.contains(day)
                            ? null
                            : lessonAt(day, slot.id),
                      )
                    : _fixedBlockCell(slot.name),
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.TableRow _headerRow(List<String> days) {
    pw.Widget cell(String text) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 9.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: _kHeaderFill),
      children: [cell('Time'), ...days.map(cell)],
    );
  }

  static pw.Widget _timeCell(TimetableSlot slot) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      alignment: pw.Alignment.centerLeft,
      constraints: const pw.BoxConstraints(minHeight: 32),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            slot.name,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${slot.startTime}-${slot.endTime}',
            style: const pw.TextStyle(fontSize: 7, color: _kMuted),
          ),
        ],
      ),
    );
  }

  static pw.Widget _fixedBlockCell(String label) {
    return pw.Container(
      alignment: pw.Alignment.center,
      constraints: const pw.BoxConstraints(minHeight: 32),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontStyle: pw.FontStyle.italic,
          color: _kMuted,
        ),
      ),
    );
  }

  static pw.Widget _lessonCell(TimetableLesson? lesson) {
    if (lesson == null) {
      return pw.Container(constraints: const pw.BoxConstraints(minHeight: 32));
    }
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      alignment: pw.Alignment.center,
      constraints: const pw.BoxConstraints(minHeight: 32),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            lesson.subjectName,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          if (lesson.teacherName.isNotEmpty)
            pw.Text(
              lesson.teacherName,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 7, color: _kMuted),
            ),
          if (lesson.roomName?.isNotEmpty == true)
            pw.Text(
              lesson.roomName!,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 6.5, color: _kMuted),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(int pageNumber, int pagesCount) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 8),
        pw.Container(height: 0.6, color: _kBorder),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated by School Pulse - ${DateTime.now().toIso8601String().split('T').first}',
              style: const pw.TextStyle(fontSize: 7.5, color: _kMuted),
            ),
            if (pagesCount > 1)
              pw.Text(
                'Page $pageNumber of $pagesCount',
                style: const pw.TextStyle(fontSize: 7.5, color: _kMuted),
              ),
          ],
        ),
      ],
    );
  }

  /// Opens the platform print/preview sheet for already-generated PDF bytes.
  static Future<void> print(Uint8List pdfData) async {
    await Printing.layoutPdf(onLayout: (format) async => pdfData);
  }

  /// Opens the platform share sheet (which includes "Save to Files" on iOS
  /// and a save/share picker on Android) for already-generated PDF bytes.
  static Future<void> save(Uint8List pdfData, String fileName) async {
    await Printing.sharePdf(bytes: pdfData, filename: fileName);
  }
}
