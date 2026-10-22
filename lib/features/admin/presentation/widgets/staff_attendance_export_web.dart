// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<String> saveCsvImpl({
  required String fileName,
  required String content,
}) async {
  final bytes = html.Blob([content], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(bytes);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
  return 'Downloaded';
}
