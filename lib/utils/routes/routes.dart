import 'package:boilerplate/presentation/content_enhancement/content_enhancement_screen.dart';
import 'package:boilerplate/presentation/home/home.dart';
import 'package:boilerplate/presentation/login/login.dart';
import 'package:boilerplate/presentation/technical_seo/technical_seo_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._();

  //static variables
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/post';
  static const String contentEnhancement = '/content-enhancement';
  static const String technicalSeo = '/technical-seo';

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => HomeScreen(),
    contentEnhancement: (BuildContext context) => const ContentEnhancementScreen(),
    technicalSeo: (BuildContext context) => const TechnicalSeoScreen(),
  };
}
