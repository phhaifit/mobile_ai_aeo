import 'package:boilerplate/presentation/forgot_password/forgot_password.dart';
import 'package:boilerplate/presentation/home/home.dart';
import 'package:boilerplate/presentation/login/login.dart';
import 'package:boilerplate/presentation/register/register.dart';
import 'package:boilerplate/presentation/dashboard/dashboard.dart';
import 'package:boilerplate/presentation/overview/overview.dart';
import 'package:boilerplate/presentation/all_posts/all_posts_screen.dart';
import 'package:boilerplate/presentation/ai_writer/ai_writer_screen.dart';
import 'package:boilerplate/presentation/auto_generation/auto_generation_screen.dart';
import 'package:boilerplate/presentation/cronjob/routes/cronjob_routes.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._();

  //static variables
  static const String splash = '/splash';
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/post';
  static const String overview = '/overview';
  static const String analytic = '/analytic';
  static const String allPosts = '/all-posts';
  static const String aiWriter = '/ai-writer';
  static const String autoGeneration = '/auto-generation';
  
  // Cronjob routes
  static const String cronjobList = '/cronjob/list';
  static const String cronjobCreate = '/cronjob/create';
  static const String cronjobEdit = '/cronjob/edit';
  static const String cronjobHistory = '/cronjob/history';
  static const String cronjobExecutionDetails = '/cronjob/execution/details';

  static final routes = <String, WidgetBuilder>{
    dashboard: (BuildContext context) => DashboardScreen(),
    login: (BuildContext context) => LoginScreen(),
    register: (BuildContext context) => RegisterScreen(),
    forgotPassword: (BuildContext context) => ForgotPasswordScreen(),
    home: (BuildContext context) => HomeScreen(),
    overview: (BuildContext context) => OverviewScreen(),
    allPosts: (BuildContext context) => AllPostsScreen(),
    aiWriter: (BuildContext context) => AiWriterScreen(),
    autoGeneration: (BuildContext context) => AutoGenerationScreen(),
    //analytic: (BuildContext context) => AnalyticScreen(),
  };
  
  // Route generator for handling complex route arguments
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Handle cronjob routes with arguments
    if (settings.name?.startsWith('/cronjob/') ?? false) {
      return CronjobRouteGenerator.generateRoute(settings);
    }
    
    // Handle standard routes
    if (routes.containsKey(settings.name)) {
      return MaterialPageRoute(
        builder: routes[settings.name]!,
      );
    }
    
    // Default fallback
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('Route ${settings.name} not found'),
        ),
      ),
    );
  }
}
