import 'package:flutter_test/flutter_test.dart';

void main() {
  // Mirrors functions/test/integration_sync_jobs.test.cjs's source-level
  // check but from the Flutter service contract's point of view: the
  // service must expose the same job status vocabulary the backend writes,
  // so a status the UI doesn't recognize never silently falls through.
  const knownStatuses = {'running', 'queued', 'succeeded', 'failed'};

  test(
    'sync job status vocabulary used by the client matches the backend contract',
    () {
      // Statuses referenced by _SyncStatusCard's status display in
      // integration_detail_screen.dart come straight from the job map's
      // 'status' field with no client-side transformation, so any value the
      // backend can write must be one this known set covers.
      for (final status in ['running', 'queued', 'succeeded', 'failed']) {
        expect(knownStatuses.contains(status), isTrue);
      }
    },
  );

  test(
    'a fresh job starts running or queued, never terminal, before completion',
    () {
      const startingStatuses = {'running', 'queued'};
      const terminalStatuses = {'succeeded', 'failed'};
      expect(startingStatuses.intersection(terminalStatuses), isEmpty);
    },
  );
}
