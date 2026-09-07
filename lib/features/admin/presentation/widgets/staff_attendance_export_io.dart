import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<String> saveCsvImpl({
  required String fileName,
  required String content,
}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsString(content);
  await Share.shareXFiles([
    XFile(file.path, mimeType: 'text/csv', name: fileName),
  ], subject: fileName);
  return 'Shared';
}
