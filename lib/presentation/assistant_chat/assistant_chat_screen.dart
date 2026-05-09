import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/assistant_chat/assistant_fab_visibility.dart';
import 'package:boilerplate/presentation/assistant_chat/store/assistant_chat_store.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_body.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_colors.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_drawer.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AssistantChatScreen extends StatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  State<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    assistantFabSuppressed.value = true;
  }

  @override
  void dispose() {
    assistantFabSuppressed.value = false;
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: AssistantChatColors.pageBackground,
      drawer: Observer(
        builder: (_) {
          final store = getIt<AssistantChatStore>();
          return AssistantChatDrawer(
            recentSessions: store.recentSessions,
            onNewChat: () {
              Navigator.pop(context);
              store.startNewChat();
            },
            onRecentSessions: () {
              Navigator.pop(context);
              _snack('Recent sessions — full history uses the list below.');
            },
            onSavedPrompts: () {
              Navigator.pop(context);
              _snack('Saved prompts — connect when backend is ready.');
            },
            onOpenSession: (id) {
              Navigator.pop(context);
              store.openSession(id);
            },
            onDeleteSession: (id) {
              store.deleteSession(id);
            },
            onSettings: () {
              Navigator.pop(context);
              _snack('Settings — connect when ready.');
            },
            onProfileMenu: () {
              Navigator.pop(context);
              _snack('Account menu — connect when ready.');
            },
            onDashboard: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.dashboard);
            },
          );
        },
      ),
      body: SafeArea(
        child: AssistantChatBody(
          embedded: false,
          onOpenMenu: () {
            FocusManager.instance.primaryFocus?.unfocus();
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
    );
  }
}
