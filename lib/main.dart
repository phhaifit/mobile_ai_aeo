import 'package:boilerplate/core/config/environment_config.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:boilerplate/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setPreferredOrientations();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass Flutter errors to Crashlytics (not supported on web)
  if (!kIsWeb) {
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  // Init DI (loads .env and registers all services)
  await ServiceLocator.configureDependencies();

  final config = getIt<EnvironmentConfig>();

  // Initialize Sentry without appRunner to avoid zone mismatch
  if (config.isSentryEnabled) {
    await SentryFlutter.init(
      (options) {
        options.dsn = config.sentryDsn;
        options.environment = config.environment.name;
        options.tracesSampleRate = 1.0;
        options.autoInitializeNativeSdk = false;
      },
    );
  }

  runApp(MyApp());
}

Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
}
