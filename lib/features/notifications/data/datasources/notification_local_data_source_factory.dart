import 'notification_local_data_source.dart';
import 'notification_local_data_source_stub.dart'
    if (dart.library.js_interop) 'notification_local_data_source_web.dart'
    if (dart.library.io) 'notification_local_data_source_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop, [remote] only on web.
NotificationLocalDataSource createNotificationLocalDataSource({
  required dynamic isar,
  required dynamic remote,
}) => impl.create(isar: isar, remote: remote);
