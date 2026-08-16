import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../entities/timetable.dart';
import '../entities/timetable_config.dart';

/// Renders a class/stream timetable to a real, positioned PDF table -
/// never a screenshot of the app. A4 landscape, since a full week's grid
/// reads far better wide than tall.
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(
                schoolName: schoolName,
                logo: logo,
                classLabel: classLabel ?? timetable.name,
                academicYearName: academicYearName,
                termName: termName,
                timetableName: timetable.name,
              ),
              pw.SizedBox(height: 16),
              _buildGrid(days: days, slots: sortedSlots, lessons: lessons),
              pw.SizedBox(height: 12),
              _buildFooter(),
            ],
          );
        },
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
    required String timetableName,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logo != null) ...[
          pw.Container(width: 56, height: 56, child: pw.Image(logo)),
          pw.SizedBox(width: 16),
        ],
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                schoolName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Class Timetable',
                style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              classLabel,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              [academicYearName, if (termName.isNotEmpty) termName].join(' - '),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
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

    final header = <String>['Time', ...days];

    final rows = slots
        .where((slot) => slot.days.isEmpty || days.any(slot.days.contains))
        .map((slot) {
          final timeCell = '${slot.name}\n${slot.startTime}-${slot.endTime}';
          if (slot.type != 'period') {
            // A fixed block (break/lunch/etc) spans every day identically -
            // one label repeated, not per-day lookups.
            return [timeCell, ...days.map((_) => slot.name)];
          }
          return [
            timeCell,
            ...days.map((day) {
              if (slot.days.isNotEmpty && !slot.days.contains(day)) return '';
              final lesson = lessonAt(day, slot.id);
              if (lesson == null) return '';
              return [
                lesson.subjectName,
                if (lesson.teacherName.isNotEmpty) lesson.teacherName,
              ].join('\n');
            }),
          ];
        })
        .toList();

    return pw.TableHelper.fromTextArray(
      context: null,
      data: [header, ...rows],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellHeight: 34,
      cellAlignments: {
        for (var i = 0; i < header.length; i++) i: pw.Alignment.center,
      },
      columnWidths: {0: const pw.FlexColumnWidth(1.3)},
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Generated by School Pulse',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
        ),
        pw.Text(
          DateTime.now().toIso8601String().split('T').first,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
        ),
      ],
    );
  }

  /// Opens the platform print/share sheet for already-generated PDF bytes.
  static Future<void> print(Uint8List pdfData) async {
    await Printing.layoutPdf(onLayout: (format) async => pdfData);
  }
}
