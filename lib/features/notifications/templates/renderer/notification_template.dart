import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_model.dart';

/// Placeholders a template may reference.
///
/// A closed set rather than free-form keys, so a template cannot accidentally
/// reference a field that does not exist and silently render an empty string
/// into a message a parent reads.
enum TemplateField {
  studentName,
  parentName,
  staffName,
  className,
  streamName,
  subjectName,
  date,
  time,
  amount,
  balance,
  routeName,
  stopName,
  appointmentTime,
  schoolName,
  bookTitle,
  dueDate,
  reason,
}

extension TemplateFieldToken on TemplateField {
  /// The token as it appears in template text, e.g. `{studentName}`.
  String get token => '{$name}';
}

/// A reusable notification template.
///
/// Templates exist so a school sends consistent, correctly-worded messages
/// without an author retyping them, and so the same event always produces the
/// same shape of notification.
@immutable
class NotificationTemplate {
  /// Stable identifier. Referenced by school overrides and by the modules that
  /// raise events, so renaming one would orphan those references.
  final String id;

  final String name;
  final NotificationCategory category;
  final NotificationType type;

  /// Short body, used for the list tile and the push banner.
  final String titleTemplate;
  final String bodyTemplate;

  /// Optional longer text for the details screen.
  final String? fullBodyTemplate;

  final NotificationPriority priority;
  final bool requiresAcknowledgment;

  /// Fields the template needs. Rendering fails loudly when one is missing,
  /// rather than producing "Dear , your child  was absent".
  final Set<TemplateField> requiredFields;

  const NotificationTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.titleTemplate,
    required this.bodyTemplate,
    this.fullBodyTemplate,
    this.priority = NotificationPriority.medium,
    this.requiresAcknowledgment = false,
    this.requiredFields = const {},
  });

  NotificationTemplate copyWith({
    String? titleTemplate,
    String? bodyTemplate,
    String? fullBodyTemplate,
    NotificationPriority? priority,
    bool? requiresAcknowledgment,
  }) {
    return NotificationTemplate(
      id: id,
      name: name,
      category: category,
      type: type,
      titleTemplate: titleTemplate ?? this.titleTemplate,
      bodyTemplate: bodyTemplate ?? this.bodyTemplate,
      fullBodyTemplate: fullBodyTemplate ?? this.fullBodyTemplate,
      priority: priority ?? this.priority,
      requiresAcknowledgment:
          requiresAcknowledgment ?? this.requiresAcknowledgment,
      requiredFields: requiredFields,
    );
  }
}

/// The result of rendering a template.
@immutable
class RenderedTemplate {
  final String title;
  final String body;
  final String? fullBody;

  /// Fields the template needed that no value was supplied for. Empty on a
  /// successful render.
  final Set<TemplateField> missingFields;

  const RenderedTemplate({
    required this.title,
    required this.body,
    this.fullBody,
    this.missingFields = const {},
  });

  bool get isComplete => missingFields.isEmpty;
}

/// Substitutes placeholder tokens in template text.
///
/// Rendering happens in the trusted application layer or on the server, never
/// from values a recipient controls, so a notification body cannot be used to
/// inject content into another user's notification.
class NotificationTemplateRenderer {
  const NotificationTemplateRenderer();

  /// Renders [template] with [values].
  ///
  /// Any required field with no value is reported in
  /// [RenderedTemplate.missingFields] and its token is left visible in the
  /// output, so a broken template is obvious in a preview rather than shipping
  /// a sentence with a hole in it.
  RenderedTemplate render(
    NotificationTemplate template,
    Map<TemplateField, String> values,
  ) {
    final missing = <TemplateField>{};

    for (final field in template.requiredFields) {
      final value = values[field];
      if (value == null || value.trim().isEmpty) missing.add(field);
    }

    return RenderedTemplate(
      title: _substitute(template.titleTemplate, values),
      body: _substitute(template.bodyTemplate, values),
      fullBody: template.fullBodyTemplate == null
          ? null
          : _substitute(template.fullBodyTemplate!, values),
      missingFields: missing,
    );
  }

  /// Replaces every known token present in [text].
  ///
  /// Unknown tokens are left as-is rather than stripped: a visible
  /// `{somethingWrong}` in a preview is a bug report, whereas silently
  /// deleting it hides the mistake until a parent sees the result.
  String _substitute(String text, Map<TemplateField, String> values) {
    var output = text;
    for (final field in TemplateField.values) {
      final value = values[field];
      if (value == null) continue;
      output = output.replaceAll(field.token, value);
    }
    return output;
  }

  /// Tokens [text] references, for validating a school-authored template.
  Set<TemplateField> tokensIn(String text) {
    return TemplateField.values
        .where((field) => text.contains(field.token))
        .toSet();
  }

  /// Tokens in [text] that are not recognised, so a template editor can warn
  /// before the template is saved and used.
  List<String> unknownTokensIn(String text) {
    final pattern = RegExp(r'\{([a-zA-Z0-9_]+)\}');
    final known = TemplateField.values.map((f) => f.name).toSet();
    return pattern
        .allMatches(text)
        .map((m) => m.group(1)!)
        .where((name) => !known.contains(name))
        .toList();
  }
}
