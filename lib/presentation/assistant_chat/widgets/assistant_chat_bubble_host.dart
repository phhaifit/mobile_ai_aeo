import 'package:boilerplate/presentation/assistant_chat/assistant_fab_visibility.dart';
import 'package:boilerplate/presentation/assistant_chat/store/assistant_chat_store.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_body.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_colors.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_drawer.dart';
import 'package:boilerplate/utils/app_navigator_key.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// Floating Assistant entry: bottom-right FAB opens a compact chat bubble.
class AssistantChatBubbleHost extends StatefulWidget {
  const AssistantChatBubbleHost({super.key, required this.child});

  final Widget? child;

  @override
  State<AssistantChatBubbleHost> createState() =>
      _AssistantChatBubbleHostState();
}

class _AssistantChatBubbleHostState extends State<AssistantChatBubbleHost> {
  bool _open = false;
  final GlobalKey<ScaffoldState> _bubbleScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    assistantFabSuppressed.addListener(_onFabSuppressedChanged);
  }

  @override
  void dispose() {
    assistantFabSuppressed.removeListener(_onFabSuppressedChanged);
    super.dispose();
  }

  void _onFabSuppressedChanged() {
    if (assistantFabSuppressed.value && _open) {
      _bubbleScaffoldKey.currentState?.closeDrawer();
      setState(() => _open = false);
    }
  }

  void _snack(String message) {
    final rootCtx = appNavigatorKey.currentContext;
    final messenger = ScaffoldMessenger.maybeOf(rootCtx ?? context);
    messenger?.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    if (child == null) {
      return const SizedBox.shrink();
    }

    return ListenableBuilder(
      listenable: assistantFabSuppressed,
      builder: (context, _) {
        if (assistantFabSuppressed.value) {
          return child;
        }

        final padding = MediaQuery.paddingOf(context);
        final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
        final size = MediaQuery.sizeOf(context);

        final bubbleWidth = (size.width - 24).clamp(280.0, 400.0);

        // Bubble is bottom-anchored above the extended FAB. Height is derived so the
        // top sits just under the status bar / app title band (e.g. "Navigation").
        const bubbleTopInset = 8.0;
        const fabBottomMargin = 12.0;
        const gapAboveFab = 10.0;
        const extendedFabHeight = 56.0;
        final bubbleMaxHeight = (size.height -
                padding.top -
                bubbleTopInset -
                padding.bottom -
                viewInsetsBottom -
                fabBottomMargin -
                extendedFabHeight -
                gapAboveFab)
            .clamp(280.0, 2000.0);
        final store = getIt<AssistantChatStore>();

        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            child,
            if (_open)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    _bubbleScaffoldKey.currentState?.closeDrawer();
                    setState(() => _open = false);
                  },
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.32),
                  ),
                ),
              ),
            Positioned(
              right: 12,
              bottom: padding.bottom + viewInsetsBottom + 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_open) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Material(
                        elevation: 12,
                        shadowColor: Colors.black45,
                        color: AssistantChatColors.pageBackground,
                        child: SizedBox(
                          width: bubbleWidth,
                          height: bubbleMaxHeight,
                          child: Scaffold(
                            key: _bubbleScaffoldKey,
                            resizeToAvoidBottomInset: true,
                            drawer: Observer(
                              builder: (_) => AssistantChatDrawer(
                                embedAsSheet: false,
                                recentSessions: store.recentSessions,
                                onNewChat: () {
                                  _bubbleScaffoldKey.currentState
                                      ?.closeDrawer();
                                  store.startNewChat();
                                },
                                onRecentSessions: () {
                                  _bubbleScaffoldKey.currentState
                                      ?.closeDrawer();
                                  _snack(
                                    'Recent chats are listed in the drawer.',
                                  );
                                },
                                onSavedPrompts: () {
                                  _bubbleScaffoldKey.currentState
                                      ?.closeDrawer();
                                  _snack(
                                    'Saved prompts will be available when the API is ready.',
                                  );
                                },
                                onOpenSession: (id) {
                                  _bubbleScaffoldKey.currentState
                                      ?.closeDrawer();
                                  store.openSession(id);
                                },
                                onDeleteSession: (id) {
                                  store.deleteSession(id);
                                },
                                onSettings: () {
                                  _bubbleScaffoldKey.currentState
                                      ?.closeDrawer();
                                  _snack(
                                    'Settings will be available when ready.',
                                  );
                                },
                                onProfileMenu: () {
                                  _bubbleScaffoldKey.currentState
                                      ?.closeDrawer();
                                  _snack(
                                    'Account menu will be available when ready.',
                                  );
                                },
                                onDashboard: () {
                                  _bubbleScaffoldKey.currentState
                                      ?.closeDrawer();
                                  final nav = appNavigatorKey.currentContext;
                                  if (nav != null) {
                                    Navigator.pushNamed(nav, Routes.dashboard);
                                  }
                                },
                              ),
                            ),
                            body: AssistantChatBody(
                              embedded: true,
                              onOpenMenu: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                _bubbleScaffoldKey.currentState?.openDrawer();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Semantics(
                    label: 'Virtual Assistant',
                    button: true,
                    child: FloatingActionButton.extended(
                      heroTag: 'assistant_fab',
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (_open) {
                          _bubbleScaffoldKey.currentState?.closeDrawer();
                        }
                        setState(() => _open = !_open);
                      },
                      backgroundColor: AssistantChatColors.primary,
                      foregroundColor: Colors.white,
                      icon: Icon(_open
                          ? Icons.close_rounded
                          : Icons.chat_bubble_rounded),
                      label: Text(
                        _open ? 'Close' : 'Assistant',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
