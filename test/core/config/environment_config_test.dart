import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/core/config/environment_config.dart';

void main() {
  group('EnvironmentConfig', () {
    test('defaultDev factory creates dev environment config', () {
      final config = EnvironmentConfig.defaultDev();

      expect(config.environment, Environment.dev);
      expect(config.apiBaseUrl, 'http://jsonplaceholder.typicode.com');
      expect(config.aiApiBaseUrl, 'http://localhost:8080');
      expect(config.sentryDsn, '');
      expect(config.analyticsEnabled, false);
    });

    test('isSentryEnabled returns true when sentryDsn is not empty', () {
      final configEnabled = EnvironmentConfig(
        environment: Environment.prod,
        apiBaseUrl: 'https://api.example.com',
        aiApiBaseUrl: 'https://ai.example.com',
        sentryDsn: 'https://abc123@sentry.io/123456',
      );

      expect(configEnabled.isSentryEnabled, true);
    });

    test('isSentryEnabled returns false when sentryDsn is empty', () {
      final configDisabled = EnvironmentConfig(
        environment: Environment.dev,
        apiBaseUrl: 'http://localhost:3000',
        aiApiBaseUrl: 'http://localhost:8080',
        sentryDsn: '',
      );

      expect(configDisabled.isSentryEnabled, false);
    });

    test('isProduction returns true for prod environment', () {
      final config = EnvironmentConfig(
        environment: Environment.prod,
        apiBaseUrl: 'https://api.example.com',
        aiApiBaseUrl: 'https://ai.example.com',
      );

      expect(config.isProduction, true);
    });

    test('isProduction returns false for dev environment', () {
      final config = EnvironmentConfig(
        environment: Environment.dev,
        apiBaseUrl: 'http://localhost:3000',
        aiApiBaseUrl: 'http://localhost:8080',
      );

      expect(config.isProduction, false);
    });

    test('isProduction returns false for staging environment', () {
      final config = EnvironmentConfig(
        environment: Environment.staging,
        apiBaseUrl: 'https://staging-api.example.com',
        aiApiBaseUrl: 'https://staging-ai.example.com',
      );

      expect(config.isProduction, false);
    });

    test('constructor respects all parameters', () {
      final config = EnvironmentConfig(
        environment: Environment.staging,
        apiBaseUrl: 'https://staging-api.example.com',
        aiApiBaseUrl: 'https://staging-ai.example.com',
        sentryDsn: 'https://test@sentry.io/999',
        analyticsEnabled: true,
      );

      expect(config.environment, Environment.staging);
      expect(config.apiBaseUrl, 'https://staging-api.example.com');
      expect(config.aiApiBaseUrl, 'https://staging-ai.example.com');
      expect(config.sentryDsn, 'https://test@sentry.io/999');
      expect(config.analyticsEnabled, true);
    });
  });
}
