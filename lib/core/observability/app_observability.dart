import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Crash reporting + product analytics, in one place so every call site
/// follows the same privacy rule: **no personal data leaves the device**.
/// Analytics only ever sees route *patterns* (`/staff/students/:id`, never
/// the concrete id), role names and the tenant id - never names, emails,
/// phone numbers, student ids or free text. Every call is fire-and-forget
/// and swallows its own errors: observability must never break the app.
class AppObservability {
  AppObservability._();

  // Crashlytics has no web implementation.
  static bool get _crashlyticsSupported => !kIsWeb;

  static String? _signedInKey;

  /// Installs the global error hooks. Call once, after Firebase.initializeApp
  /// and before runApp.
  static Future<void> initCrashReporting() async {
    if (!_crashlyticsSupported) {
      final previous = FlutterError.onError;
      FlutterError.onError = (details) {
        previous?.call(details);
        debugPrint('FlutterError: ${details.exceptionAsString()}');
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('Uncaught error: $error\n$stack');
        return true;
      };
      return;
    }
    try {
      final crashlytics = FirebaseCrashlytics.instance;
      // Debug sessions would flood the dashboard with dev-loop noise.
      await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        crashlytics.recordFlutterFatalError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (e) {
      debugPrint('Crashlytics init failed (non-fatal): $e');
    }
  }

  /// Logs a `screen_view` for every route change, using the matched route
  /// pattern so path parameters (ids) are never sent.
  static void trackScreenViews(GoRouter router) {
    String? last;
    void onChange() {
      final pattern = router.routerDelegate.currentConfiguration.fullPath;
      if (pattern.isEmpty || pattern == last) return;
      last = pattern;
      _safe(
        () => FirebaseAnalytics.instance.logScreenView(
          screenName: pattern,
          screenClass: pattern,
        ),
      );
    }

    router.routerDelegate.addListener(onChange);
  }

  /// Signed-in session (interactive login or cold-start restore). Only the
  /// role and tenant are recorded, as user properties for segmentation.
  static void onSignedIn({required String role, required String schoolId}) {
    // AuthAuthenticated re-emits on profile refreshes; one login per session.
    final key = '$role@$schoolId';
    if (_signedInKey == key) return;
    _signedInKey = key;
    final analytics = FirebaseAnalytics.instance;
    _safe(() => analytics.setUserProperty(name: 'role', value: role));
    _safe(
      () => analytics.setUserProperty(
        name: 'school_id',
        value: schoolId.isEmpty ? null : schoolId,
      ),
    );
    _safe(() => analytics.logLogin(loginMethod: role));
    if (_crashlyticsSupported) {
      _safe(() => FirebaseCrashlytics.instance.setCustomKey('role', role));
      _safe(
        () => FirebaseCrashlytics.instance.setCustomKey('school_id', schoolId),
      );
    }
  }

  static void onSignedOut() {
    if (_signedInKey == null) return;
    _signedInKey = null;
    final analytics = FirebaseAnalytics.instance;
    _safe(() => analytics.logEvent(name: 'logout'));
    _safe(() => analytics.setUserProperty(name: 'role', value: null));
    _safe(() => analytics.setUserProperty(name: 'school_id', value: null));
  }

  static void _safe(Future<void> Function() call) {
    try {
      unawaited(
        call().catchError((Object e) {
          if (kDebugMode) debugPrint('Observability call failed: $e');
        }),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Observability call failed: $e');
    }
  }
}
