import 'package:flutter/material.dart';
import '../screen/cronjob_list_screen.dart';
import '../screen/create_edit_cronjob_screen.dart';
import '../screen/agent_configuration_screen.dart';
import '../history/screen/cronjob_history_screen.dart';
import '../history/screen/execution_details_screen.dart';

/// Route paths for cronjob feature
class CronjobRoutes {
  CronjobRoutes._();

  /// List all cronjobs: /cronjob/list
  static const String list = '/cronjob/list';

  /// Create new cronjob: /cronjob/create
  static const String create = '/cronjob/create';

  /// Edit cronjob: /cronjob/edit?id=<cronjob_id>
  static const String edit = '/cronjob/edit';

  /// View cronjob execution history: /cronjob/history?id=<cronjob_id>
  static const String history = '/cronjob/history';

  /// View execution details: /cronjob/execution/details?id=<execution_id>&cronjobId=<cronjob_id>
  static const String executionDetails = '/cronjob/execution/details';
  
  /// Configure agent: /cronjob/agent/configure
  static const String agentConfigure = '/cronjob/agent/configure';
}

/// Route arguments class
class CronjobHistoryArgs {
  final String cronjobId;
  final String? cronjobName;

  CronjobHistoryArgs({
    required this.cronjobId,
    this.cronjobName,
  });
}

class ExecutionDetailsArgs {
  final String executionId;
  final String cronjobId;
  final String? cronjobName;

  ExecutionDetailsArgs({
    required this.executionId,
    required this.cronjobId,
    this.cronjobName,
  });
}

class AgentConfigureArgs {
  final String agentType;
  final String agentTitle;

  AgentConfigureArgs({
    required this.agentType,
    required this.agentTitle,
  });
}

/// Route generator for cronjob feature
class CronjobRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case CronjobRoutes.list:
        return MaterialPageRoute(
          builder: (_) => const CronjobListScreen(),
        );

      case CronjobRoutes.create:
        return MaterialPageRoute(
          builder: (_) => const CreateEditCronjobScreen(),
        );

      case CronjobRoutes.edit:
        final cronjobId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CreateEditCronjobScreen(
            cronjobId: cronjobId,
          ),
        );

      case CronjobRoutes.history:
        final args = settings.arguments as CronjobHistoryArgs?;
        if (args == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Error: Missing cronjob ID for history'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => CronjobHistoryScreen(
            cronjobId: args.cronjobId,
            cronjobName: args.cronjobName ?? 'Cronjob',
          ),
        );

      case CronjobRoutes.executionDetails:
        final args = settings.arguments as ExecutionDetailsArgs?;
        if (args == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Error: Missing execution details arguments'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ExecutionDetailsScreen(
            executionId: args.executionId,
            cronjobId: args.cronjobId,
            cronjobName: args.cronjobName,
          ),
        );

      case CronjobRoutes.agentConfigure:
        final args = settings.arguments as AgentConfigureArgs?;
        if (args == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Error: Missing agent configuration arguments'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => AgentConfigurationScreen(
            agentType: args.agentType,
            agentTitle: args.agentTitle,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}

