import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import 'package:school_pulse/features/school_calendar/domain/entities/calendar_event.dart';
import 'package:school_pulse/features/school_calendar/domain/entities/calendar_event_type.dart';
import 'package:school_pulse/features/school_calendar/presentation/widgets/month_calendar_grid.dart';

CalendarEvent _event(DateTime day, {CalendarEventType type = CalendarEventType.event}) {
  return CalendarEvent(
    id: '1',
    schoolId: 'school-1',
    title: 'Test event',
    type: type,
    startDate: day,
    endDate: day,
    createdAt: day,
    audience: const NotificationAudience.school(),
  );
}

Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: ThemeData(brightness: brightness),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  testWidgets('renders weekday headers Mon..Sun', (tester) async {
    await tester.pumpWidget(
      _wrap(MonthCalendarGrid(month: DateTime(2026, 8), events: const [])),
    );
    for (final day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
      expect(find.text(day), findsOneWidget);
    }
  });

  testWidgets('renders every day-of-month cell for August 2026 (31 days)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(MonthCalendarGrid(month: DateTime(2026, 8), events: const [])),
    );
    expect(find.text('31'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('day tap with event triggers onDayTap callback', (
    tester,
  ) async {
    DateTime? tapped;
    final events = [_event(DateTime(2026, 8, 10))];
    await tester.pumpWidget(
      _wrap(
        MonthCalendarGrid(
          month: DateTime(2026, 8),
          events: events,
          onDayTap: (day) => tapped = day,
        ),
      ),
    );
    await tester.tap(find.text('10'));
    await tester.pump();
    expect(tapped, DateTime(2026, 8, 10));
  });

  testWidgets('renders without overflow at narrow (320px) width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrap(
        MonthCalendarGrid(
          month: DateTime(2026, 8),
          events: [_event(DateTime(2026, 8, 5))],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in dark mode without error', (tester) async {
    await tester.pumpWidget(
      _wrap(
        MonthCalendarGrid(month: DateTime(2026, 8), events: const []),
        brightness: Brightness.dark,
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
