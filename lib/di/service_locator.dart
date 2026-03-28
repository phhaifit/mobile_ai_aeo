import 'package:boilerplate/core/config/environment_config.dart';
import 'package:boilerplate/data/di/data_layer_injection.dart';
import 'package:boilerplate/domain/di/domain_layer_injection.dart';
import 'package:boilerplate/presentation/di/presentation_layer_injection.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> configureDependencies() async {
    // Load environment config first
    await _configureEnvironment();

    await DataLayerInjection.configureDataLayerInjection();
    await DomainLayerInjection.configureDomainLayerInjection();
    await PresentationLayerInjection.configurePresentationLayerInjection();
  }

  static Future<void> _configureEnvironment() async {
    try {
      await dotenv.load(fileName: '.env.dev');
    } catch (_) {
      // Fallback if .env file not found
    }

    final envName = dotenv.env['ENVIRONMENT'] ?? 'dev';
    final environment = Environment.values.firstWhere(
      (e) => e.name == envName,
      orElse: () => Environment.dev,
    );

    getIt.registerSingleton<EnvironmentConfig>(
      EnvironmentConfig(
        environment: environment,
        apiBaseUrl: dotenv.env['API_BASE_URL'] ??
            'http://jsonplaceholder.typicode.com',
        aiApiBaseUrl: dotenv.env['AI_API_BASE_URL'] ??
            'http://localhost:8080',
        sentryDsn: dotenv.env['SENTRY_DSN'] ?? '',
        analyticsEnabled: dotenv.env['ANALYTICS_ENABLED'] == 'true',
      ),
    );
  }
}
