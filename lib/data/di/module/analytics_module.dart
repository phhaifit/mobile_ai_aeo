import 'package:boilerplate/core/config/environment_config.dart';
import 'package:boilerplate/core/services/analytics_service.dart';
import 'package:boilerplate/core/services/error_tracking_service.dart';

import '../../../di/service_locator.dart';

/// DI module for analytics and error tracking services.
class AnalyticsModule {
  static Future<void> configureAnalyticsModuleInjection() async {
    final config = getIt<EnvironmentConfig>();

    getIt.registerSingleton<AnalyticsService>(
      AnalyticsService(enabled: config.analyticsEnabled),
    );

    getIt.registerSingleton<ErrorTrackingService>(
      ErrorTrackingService(enabled: config.isSentryEnabled),
    );
  }
}
