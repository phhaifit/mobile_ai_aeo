import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/assistant_chat/store/assistant_chat_store.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_composer.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_colors.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_drawer.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_message_bubble.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_suggestion_card.dart';
import 'package:boilerplate/core/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AssistantChatScreen extends StatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  State<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> {
  late final AssistantChatStore _store;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _store = getIt<AssistantChatStore>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _store.loadChat();
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _onSend() async {
    final text = _textController.text;
    _textController.clear();
    await _store.sendMessage(text);
    _scrollToBottom();
  }

  String _dateLabelForMessages() {
    // Mock seed uses "today"; when API returns history, derive per-day groups.
    return 'TODAY';
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
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
      backgroundColor: AssistantChatColors.pageBackground,
      drawer: AssistantChatDrawer(
        onNewChat: () {
          Navigator.pop(context);
          _textController.clear();
          _store.refreshChat().then((_) => _scrollToBottom());
        },
        onRecentSessions: () {
          Navigator.pop(context);
          _snack('Recent sessions — connect to API when ready.');
        },
        onSavedPrompts: () {
          Navigator.pop(context);
          _snack('Saved prompts — connect to API when ready.');
        },
        onRecentChatTap: (title) {
          Navigator.pop(context);
          _snack('Open chat: $title (mock).');
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => _dismissKeyboard(),
              child: _Header(
                onMenu: () {
                  _dismissKeyboard();
                  _scaffoldKey.currentState?.openDrawer();
                },
                onRefresh: () async {
                  _textController.clear();
                  await _store.refreshChat();
                  _scrollToBottom();
                },
              ),
            ),
            Expanded(
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) => _dismissKeyboard(),
                child: Observer(
                  builder: (_) {
                    if (_store.isLoadingBootstrap && _store.messages.isEmpty) {
                      return const Center(
                          child: CustomProgressIndicatorWidget());
                    }
                    return ListView(
                      controller: _scrollController,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      children: [
                        ..._store.suggestions.map(
                          (s) => AssistantSuggestionCard(
                            suggestion: s,
                            onTap: () {
                              _textController.text = s.description;
                              _textController.selection =
                                  TextSelection.collapsed(
                                offset: _textController.text.length,
                              );
                            },
                          ),
                        ),
                        if (_store.messages.isNotEmpty)
                          AssistantDateSeparator(
                              label: _dateLabelForMessages()),
                        ..._store.messages.map(
                          (m) => AssistantMessageBubble(message: m),
                        ),
                        if (_store.isSending) const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Observer(
                builder: (_) => AssistantChatComposer(
                  controller: _textController,
                  onSend: _onSend,
                  isSending: _store.isSending,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onMenu,
    required this.onRefresh,
  });

  final VoidCallback onMenu;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenu,
            icon: const Icon(Icons.menu, color: AssistantChatColors.iconMuted),
          ),
          const Expanded(
            child: Text(
              'Assistant',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AssistantChatColors.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: AssistantChatColors.iconMuted),
          ),
        ],
      ),
    );
  }
}
