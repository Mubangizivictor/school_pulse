import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/templates/defaults/default_notification_templates.dart';
import 'package:school_pulse/features/notifications/templates/renderer/notification_template.dart';

void main() {
  const renderer = NotificationTemplateRenderer();

  group('rendering', () {
    test('substitutes every supplied token', () {
      final result = renderer
          .render(DefaultNotificationTemplates.studentAbsent, {
            TemplateField.studentName: 'Brian Mukasa',
            TemplateField.className: 'P.6A',
            TemplateField.date: '1 August',
          });

      expect(
        result.body,
        'Brian Mukasa was marked absent in P.6A on 1 August.',
      );
      expect(result.isComplete, isTrue);
    });

    test('substitutes tokens in the title too', () {
      final result = renderer
          .render(DefaultNotificationTemplates.homeworkAssigned, {
            TemplateField.subjectName: 'Mathematics',
            TemplateField.dueDate: 'Friday',
            TemplateField.className: 'P.6A',
          });

      expect(result.title, 'New Mathematics homework');
    });

    test('reports a missing required field instead of rendering a hole', () {
      final result = renderer.render(
        DefaultNotificationTemplates.studentAbsent,
        {TemplateField.studentName: 'Brian Mukasa'},
      );

      expect(result.isComplete, isFalse);
      expect(
        result.missingFields,
        containsAll([TemplateField.className, TemplateField.date]),
      );
      // The token stays visible so the gap is obvious in a preview.
      expect(result.body, contains('{className}'));
    });

    test('treats a blank value as missing', () {
      final result = renderer
          .render(DefaultNotificationTemplates.studentAbsent, {
            TemplateField.studentName: '   ',
            TemplateField.className: 'P.6A',
            TemplateField.date: '1 August',
          });

      expect(result.missingFields, contains(TemplateField.studentName));
    });

    test('renders the full body when the template has one', () {
      final result = renderer
          .render(DefaultNotificationTemplates.emergencyClosure, {
            TemplateField.schoolName: 'School Pulse Academy',
            TemplateField.date: 'Tuesday',
            TemplateField.reason: 'burst water main',
          });

      expect(result.fullBody, contains('School Pulse Academy will be CLOSED'));
      expect(result.fullBody, contains('burst water main'));
    });

    test('leaves an unknown token visible rather than deleting it', () {
      const template = NotificationTemplate(
        id: 'custom',
        name: 'Custom',
        category: NotificationCategory.announcements,
        type: NotificationType.announcement,
        titleTemplate: 'Hello',
        bodyTemplate: 'Value: {notARealField}',
      );

      final result = renderer.render(template, const {});

      expect(result.body, contains('{notARealField}'));
    });
  });

  group('token inspection', () {
    test('finds the known tokens a template references', () {
      final tokens = renderer.tokensIn(
        DefaultNotificationTemplates.feeReminder.bodyTemplate,
      );

      expect(
        tokens,
        containsAll([
          TemplateField.balance,
          TemplateField.studentName,
          TemplateField.dueDate,
        ]),
      );
    });

    test('reports unknown tokens so a bad template can be rejected', () {
      final unknown = renderer.unknownTokensIn(
        'Hello {studentName}, your {madeUpThing} is ready',
      );

      expect(unknown, ['madeUpThing']);
    });

    test('reports nothing for a valid template', () {
      expect(
        renderer.unknownTokensIn('Hello {studentName} in {className}'),
        isEmpty,
      );
    });
  });

  group('default catalog', () {
    test('every template id matches its map key', () {
      DefaultNotificationTemplates.all.forEach((key, template) {
        expect(template.id, key, reason: 'id must match its key for lookup');
      });
    });

    test('every required field actually appears in the template text', () {
      for (final template in DefaultNotificationTemplates.asList) {
        final text =
            '${template.titleTemplate} ${template.bodyTemplate} ${template.fullBodyTemplate ?? ''}';
        for (final field in template.requiredFields) {
          expect(
            text,
            contains(field.token),
            reason:
                '${template.id} requires ${field.name} but never uses it, so '
                'rendering would report a missing field that changes nothing',
          );
        }
      }
    });

    test('no template references an unknown token', () {
      for (final template in DefaultNotificationTemplates.asList) {
        final text =
            '${template.titleTemplate} ${template.bodyTemplate} ${template.fullBodyTemplate ?? ''}';
        expect(
          renderer.unknownTokensIn(text),
          isEmpty,
          reason: '${template.id} references a token that cannot be filled',
        );
      }
    });

    test('emergency and medical templates require acknowledgement', () {
      expect(
        DefaultNotificationTemplates.emergencyClosure.requiresAcknowledgment,
        isTrue,
      );
      expect(
        DefaultNotificationTemplates.medicalAlert.requiresAcknowledgment,
        isTrue,
      );
    });

    test('forCategory returns only that category', () {
      final finance = DefaultNotificationTemplates.forCategory(
        NotificationCategory.finance,
      );

      expect(finance, isNotEmpty);
      expect(
        finance.every((t) => t.category == NotificationCategory.finance),
        isTrue,
      );
    });
  });
}
