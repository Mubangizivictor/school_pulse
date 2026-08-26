import 'package:school_pulse/features/messages/domain/repositories/messages_repository.dart';
import 'package:school_pulse/features/messages/domain/services/message_outbox_service.dart';

import 'message_outbox_service_web.dart'
    if (dart.library.io) 'message_outbox_service_mobile.dart'
    as impl;

/// [isar] is only used on mobile/desktop - the web implementation ignores it.
MessageOutboxService createMessageOutboxService({
  required dynamic isar,
  required MessagesRepository repository,
}) => impl.create(isar: isar, repository: repository);
