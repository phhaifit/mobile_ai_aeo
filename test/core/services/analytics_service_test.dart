import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/core/services/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    test('constructor sets enabled flag correctly', () {
      final serviceEnabled = AnalyticsService(enabled: true);
      expect(serviceEnabled.enabled, true);

      final serviceDisabled = AnalyticsService(enabled: false);
      expect(serviceDisabled.enabled, false);
    });

    test('enabled defaults to false', () {
      final service = AnalyticsService();
      expect(service.enabled, false);
    });

    test('logScreenView does nothing when disabled', () {
      final service = AnalyticsService(enabled: false);
      // Should not throw
      service.logScreenView(screenName: 'TestScreen');
    });

    test('logScreenView accepts screen name when enabled', () {
      final service = AnalyticsService(enabled: true);
      // Should not throw
      service.logScreenView(screenName: 'TestScreen');
      service.logScreenView(screenName: 'AnotherScreen');
    });

    test('logEvent does nothing when disabled', () {
      final service = AnalyticsService(enabled: false);
      // Should not throw
      service.logEvent(
        name: 'test_event',
        params: {'key': 'value'},
      );
    });

    test('logEvent accepts event name and params when enabled', () {
      final service = AnalyticsService(enabled: true);
      // Should not throw
      service.logEvent(
        name: 'button_clicked',
        params: {'button_id': 'submit'},
      );
      service.logEvent(name: 'page_viewed');
      service.logEvent(
        name: 'user_action',
        params: {'action': 'share', 'content_id': '123'},
      );
    });

    test('logEvent accepts null params', () {
      final service = AnalyticsService(enabled: true);
      // Should not throw
      service.logEvent(name: 'simple_event', params: null);
    });

    test('setUserId does nothing when disabled', () {
      final service = AnalyticsService(enabled: false);
      // Should not throw
      service.setUserId('user123');
      service.setUserId(null);
    });

    test('setUserId accepts user ID when enabled', () {
      final service = AnalyticsService(enabled: true);
      // Should not throw
      service.setUserId('user123');
      service.setUserId('another_user');
      service.setUserId(null);
    });

    test('multiple operations work correctly when enabled', () {
      final service = AnalyticsService(enabled: true);
      // Should not throw
      service.setUserId('user123');
      service.logScreenView(screenName: 'HomeScreen');
      service.logEvent(name: 'screen_loaded');
      service.logEvent(
        name: 'user_action',
        params: {'action': 'navigate'},
      );
    });
  });
}
