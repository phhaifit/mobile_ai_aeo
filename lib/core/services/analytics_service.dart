import 'dart:developer' as developer;
import 'package:firebase_analytics/firebase_analytics.dart';

/// Analytics service wrapping Firebase Analytics.
/// Falls back to console logging if Firebase is not initialized.
class AnalyticsService {
  final bool enabled;
  FirebaseAnalytics? _analytics;

  AnalyticsService({this.enabled = false}) {
    if (enabled) {
      try {
        _analytics = FirebaseAnalytics.instance;
      } catch (_) {
        developer.log('Firebase Analytics not available', name: 'Analytics');
      }
    }
  }

  /// Navigator observer for automatic screen tracking in MaterialApp
  FirebaseAnalyticsObserver? get observer {
    if (_analytics == null) return null;
    return FirebaseAnalyticsObserver(analytics: _analytics!);
  }

  /// Log a screen view event
  void logScreenView({required String screenName}) {
    if (!enabled) return;
    _analytics?.logScreenView(screenName: screenName);
  }

  /// Log a custom event with optional parameters
  void logEvent({required String name, Map<String, Object>? params}) {
    if (!enabled) return;
    _analytics?.logEvent(name: name, parameters: params);
  }

  /// Set the current user ID for analytics
  void setUserId(String? userId) {
    if (!enabled) return;
    _analytics?.setUserId(id: userId);
  }
}
