/// Web never opens Isar - every XLocalDataSource has a Firestore-backed
/// web implementation instead. This function should never actually be
/// called on web (callers guard with `if (!kIsWeb)`), but exists so the
/// conditional import in isar_bootstrap.dart has a web-safe target.
Future<dynamic> open() async => null;
