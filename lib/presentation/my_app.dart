import 'package:boilerplate/constants/app_theme.dart';
import 'package:boilerplate/constants/strings.dart';
import 'package:boilerplate/core/services/analytics_service.dart';
import 'package:boilerplate/presentation/dashboard/dashboard.dart';
import 'package:boilerplate/presentation/home/home.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/login.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/presentation/overview/overview.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../di/service_locator.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  // Create your store as a final variable in a base Widget. This works better
  // with Hot Reload than creating it directly in the `build` function.
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();
  final UserStore _userStore = getIt<UserStore>();
  final AnalyticsService _analyticsService = getIt<AnalyticsService>();

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: Strings.appName,
          theme: _themeStore.darkMode
              ? AppThemeData.darkThemeData
              : AppThemeData.lightThemeData,
          navigatorObservers: [
            if (_analyticsService.observer != null)
              _analyticsService.observer!,
          ],
          routes: Routes.routes,
          onGenerateRoute: Routes.onGenerateRoute,
          locale: Locale(_languageStore.locale),
          supportedLocales: _languageStore.supportedLanguages
              .map((language) => Locale(language.locale, language.code))
              .toList(),
          localizationsDelegates: [
            // A class which loads the translations from JSON files
            AppLocalizations.delegate,
            // Built-in localization of basic text for Material widgets
            GlobalMaterialLocalizations.delegate,
            // Built-in localization for text direction LTR/RTL
            GlobalWidgetsLocalizations.delegate,
            // Built-in localization of basic text for Cupertino widgets
            GlobalCupertinoLocalizations.delegate,
          ],
          home: DashboardScreen(),
        );
      },
    );
  }
}
