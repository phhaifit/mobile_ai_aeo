import 'dart:developer' as developer;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Error tracking service wrapping Firebase Crashlytics.
/// Falls back to console logging if Crashlytics is not initialized.
class ErrorTrackingService {
  final bool enabled;
  FirebaseCrashlytics? _crashlytics;

  ErrorTrackingService({this.enabled = false}) {
    if (enabled) {
      try {
        _crashlytics = FirebaseCrashlytics.instance;
      } catch (_) {
        developer.log('Crashlytics not available', name: 'ErrorTracking');
      }
    }
  }

  /// Capture an exception with optional stack trace
  void captureException(dynamic error, {StackTrace? stackTrace}) {
    if (!enabled) return;
    if (_crashlytics != null) {
      _crashlytics!.recordError(error, stackTrace);
    } else {
      developer.log('Exception: $error', name: 'ErrorTracking',
          error: error, stackTrace: stackTrace);
    }
  }

  /// Add a breadcrumb for debugging context
  void addBreadcrumb({required String message, String? category}) {
    if (!enabled) return;
    _crashlytics?.log('[$category] $message');
  }

  /// Set the current user for error reports
  void setUser({String? id, String? email}) {
    if (!enabled) return;
    if (id != null) _crashlytics?.setUserIdentifier(id);
  }
}
