import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/assistant_chat/store/assistant_chat_store.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_composer.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_colors.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_message_bubble.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_suggestion_card.dart';
import 'package:boilerplate/core/widgets/progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart' show reaction, ReactionDisposer;

/// Chat list + composer + header. Used by full-screen [AssistantChatScreen] and
/// the floating bubble host.
class AssistantChatBody extends StatefulWidget {
  const AssistantChatBody({
    super.key,
    required this.onOpenMenu,
    this.embedded = false,
  });

  /// Opens the session drawer ([Scaffold.drawer]) or equivalent.
  final VoidCallback onOpenMenu;

  /// Slightly denser layout when shown inside the floating card.
  final bool embedded;

  @override
  State<AssistantChatBody> createState() => _AssistantChatBodyState();
}

class _AssistantChatBodyState extends State<AssistantChatBody>
    with WidgetsBindingObserver {
  late final AssistantChatStore _store;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ReactionDisposer _composerClearDispo;

  static const double _listBottomExtra = 20;

  @override
  void initState() {
    super.initState();
    _store = getIt<AssistantChatStore>();
    _composerClearDispo = reaction(
      (_) => _store.composerClearNonce,
      (_) => _textController.clear(),
    );
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _store.loadChat();
      await _store.loadRecentSessions();
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _composerClearDispo();
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _scrollToBottom();
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
    final future = _store.sendMessage(text);
    _scrollToBottom();
    await future;
    _scrollToBottom();
  }

  String _dateLabelForMessages() => 'TODAY';

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return ColoredBox(
      color: AssistantChatColors.pageBackground,
      child: Column(
        children: [
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _dismissKeyboard(),
            child: _AssistantChatHeader(
              embedded: widget.embedded,
              onMenu: () {
                _dismissKeyboard();
                widget.onOpenMenu();
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
                    return const Center(child: CustomProgressIndicatorWidget());
                  }
                  return ListView(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      16 + bottomInset + _listBottomExtra,
                    ),
                    children: [
                      ..._store.suggestions.map(
                        (s) => AssistantSuggestionCard(
                          suggestion: s,
                          onTap: () {
                            _textController.text = s.description;
                            _textController.selection = TextSelection.collapsed(
                              offset: _textController.text.length,
                            );
                          },
                        ),
                      ),
                      if (_store.messages.isNotEmpty)
                        AssistantDateSeparator(label: _dateLabelForMessages()),
                      ..._store.messages.map(
                        (m) => AssistantMessageBubble(message: m),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, widget.embedded ? 8 : 12),
            child: Observer(
              builder: (_) => AssistantChatComposer(
                embedded: widget.embedded,
                controller: _textController,
                onSend: _onSend,
                isSending: _store.isSending,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// [IconButton] always inserts a [Tooltip] when `tooltip` is non-null; tooltips need
/// an [Overlay] (inside [Navigator]). The floating bubble is built above the navigator,
/// so we use a plain ink splash control instead.
class _EmbeddedHeaderIconButton extends StatelessWidget {
  const _EmbeddedHeaderIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: AssistantChatColors.iconMuted),
          ),
        ),
      ),
    );
  }
}

class _AssistantChatHeader extends StatelessWidget {
  const _AssistantChatHeader({
    required this.embedded,
    required this.onMenu,
    required this.onRefresh,
  });

  final bool embedded;
  final VoidCallback onMenu;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: embedded ? 16 : 18,
      fontWeight: FontWeight.w700,
      color: AssistantChatColors.primary,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: embedded ? 2 : 4),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          if (embedded)
            _EmbeddedHeaderIconButton(
              icon: Icons.menu,
              semanticLabel: 'Menu',
              onPressed: onMenu,
            )
          else
            IconButton(
              onPressed: onMenu,
              icon: const Icon(Icons.menu, color: AssistantChatColors.iconMuted),
              tooltip: 'Menu',
            ),
          Expanded(
            child: Text(
              embedded ? 'Virtual Assistant' : 'Assistant',
              textAlign: TextAlign.center,
              style: titleStyle,
            ),
          ),
          if (embedded)
            _EmbeddedHeaderIconButton(
              icon: Icons.refresh,
              semanticLabel: 'Refresh',
              onPressed: onRefresh,
            )
          else
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, color: AssistantChatColors.iconMuted),
              tooltip: 'Refresh',
            ),
        ],
      ),
    );
  }
}
