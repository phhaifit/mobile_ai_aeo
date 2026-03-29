import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/core/services/error_tracking_service.dart';

void main() {
  group('ErrorTrackingService', () {
    test('constructor sets enabled flag correctly', () {
      final serviceEnabled = ErrorTrackingService(enabled: true);
      expect(serviceEnabled.enabled, true);

      final serviceDisabled = ErrorTrackingService(enabled: false);
      expect(serviceDisabled.enabled, false);
    });

    test('enabled defaults to false', () {
      final service = ErrorTrackingService();
      expect(service.enabled, false);
    });

    test('captureException does nothing when disabled', () {
      final service = ErrorTrackingService(enabled: false);
      // Should not throw
      service.captureException(Exception('test error'));
    });

    test('captureException accepts exception when enabled', () {
      final service = ErrorTrackingService(enabled: true);
      // Should not throw
      service.captureException(Exception('test error'));
      service.captureException('string error');
      service.captureException(123);
    });

    test('captureException accepts exception with stack trace', () {
      final service = ErrorTrackingService(enabled: true);
      final stackTrace = StackTrace.current;
      // Should not throw
      service.captureException(
        Exception('test error'),
        stackTrace: stackTrace,
      );
    });

    test('captureException accepts null stack trace', () {
      final service = ErrorTrackingService(enabled: true);
      // Should not throw
      service.captureException(
        Exception('test error'),
        stackTrace: null,
      );
    });

    test('addBreadcrumb does nothing when disabled', () {
      final service = ErrorTrackingService(enabled: false);
      // Should not throw
      service.addBreadcrumb(message: 'test message');
      service.addBreadcrumb(
        message: 'test message',
        category: 'user_action',
      );
    });

    test('addBreadcrumb accepts message when enabled', () {
      final service = ErrorTrackingService(enabled: true);
      // Should not throw
      service.addBreadcrumb(message: 'app started');
      service.addBreadcrumb(message: 'user logged in');
    });

    test('addBreadcrumb accepts message with category', () {
      final service = ErrorTrackingService(enabled: true);
      // Should not throw
      service.addBreadcrumb(
        message: 'button clicked',
        category: 'user_action',
      );
      service.addBreadcrumb(
        message: 'api request sent',
        category: 'http',
      );
      service.addBreadcrumb(
        message: 'database query executed',
        category: 'database',
      );
    });

    test('addBreadcrumb accepts null category', () {
      final service = ErrorTrackingService(enabled: true);
      // Should not throw
      service.addBreadcrumb(
        message: 'test message',
        category: null,
      );
    });

    test('setUser does nothing when disabled', () {
      final service = ErrorTrackingService(enabled: false);
      // Should not throw
      service.setUser(id: 'user123', email: 'user@example.com');
      service.setUser(id: 'user123');
      service.setUser(email: 'user@example.com');
    });

    test('setUser accepts user id and email when enabled', () {
      final service = ErrorTrackingService(enabled: true);
      // Should not throw
      service.setUser(id: 'user123', email: 'user@example.com');
    });

    test('setUser accepts only user id', () {
      final service = ErrorTrackingService(enabled: true);
      // Should not throw
      service.setUser(id: 'user123');
    });

    test('setUser accepts only email', () {
      final service = ErrorTrackingService(enabled: true);
      // Should not throw
      service.setUser(email: 'user@example.com');
    });

    test('setUser accepts null values', () {
      final service = ErrorTrackingService(enabled: true);
      // Should not throw
      service.setUser(id: null, email: null);
      service.setUser(id: 'user123', email: null);
      service.setUser(id: null, email: 'user@example.com');
    });

    test('multiple operations work correctly when enabled', () {
      final service = ErrorTrackingService(enabled: true);
      // Should not throw
      service.setUser(id: 'user123', email: 'user@example.com');
      service.addBreadcrumb(
        message: 'page navigated',
        category: 'navigation',
      );
      service.captureException(Exception('test error'));
      service.addBreadcrumb(message: 'error handled');
    });
  });
}
