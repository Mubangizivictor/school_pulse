// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

String currentPortalHostname() {
  const override = String.fromEnvironment('PORTAL_HOST');
  return override.isNotEmpty ? override : (html.window.location.hostname ?? '');
}
