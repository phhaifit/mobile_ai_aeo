import 'package:boilerplate/domain/entity/assistant_chat/assistant_session_summary.dart';
import 'package:boilerplate/presentation/assistant_chat/widgets/assistant_chat_colors.dart';
import 'package:flutter/material.dart';

/// Drawer is shown from the floating bubble [Scaffold] above the app [Navigator],
/// so there is no [Overlay] for [IconButton] tooltips. Use ink targets + semantics.
class _DrawerIconAction extends StatelessWidget {
  const _DrawerIconAction({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.iconSize = 22,
    this.padding = const EdgeInsets.all(8),
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;
  final double iconSize;
  final EdgeInsetsGeometry padding;

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
            padding: padding,
            child: Icon(
              icon,
              size: iconSize,
              color: AssistantChatColors.iconMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Sidebar menu for Assistant (matches product drawer layout).
/// Use [embedAsSheet] when embedding drawer content in a sheet (no [Drawer] chrome).
class AssistantChatDrawer extends StatelessWidget {
  const AssistantChatDrawer({
    super.key,
    required this.recentSessions,
    required this.onNewChat,
    required this.onRecentSessions,
    required this.onSavedPrompts,
    required this.onOpenSession,
    required this.onDeleteSession,
    required this.onSettings,
    required this.onProfileMenu,
    required this.onDashboard,
    this.embedAsSheet = false,
    this.scrollController,
  });

  final List<AssistantSessionSummary> recentSessions;
  final VoidCallback onNewChat;
  final VoidCallback onRecentSessions;
  final VoidCallback onSavedPrompts;
  final ValueChanged<String> onOpenSession;
  final ValueChanged<String> onDeleteSession;
  final VoidCallback onSettings;
  final VoidCallback onProfileMenu;
  final VoidCallback onDashboard;

  /// When true, renders as full-width [Material] instead of a [Drawer] slot.
  final bool embedAsSheet;

  /// Optional scroll controller (e.g. from [DraggableScrollableSheet]).
  final ScrollController? scrollController;

  static const Color _sectionLabelColor = Color(0xFF9CA3AF);
  static const String _appVersion = 'v2.4.0';

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Assistant',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AssistantChatColors.primary,
                      ),
                    ),
                  ),
                  _DrawerIconAction(
                    icon: Icons.dashboard_outlined,
                    semanticLabel: 'Dashboard',
                    onPressed: onDashboard,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NewChatButton(
                    label: 'New Chat',
                    filled: true,
                    onPressed: onNewChat,
                  ),
                  const SizedBox(height: 10),
                  _NewChatButton(
                    label: 'New Chat',
                    filled: false,
                    onPressed: onNewChat,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerNavRow(
              icon: Icons.history_rounded,
              label: 'Recent Sessions',
              onTap: onRecentSessions,
            ),
            _DrawerNavRow(
              icon: Icons.bookmark_outline_rounded,
              label: 'Saved Prompts',
              onTap: onSavedPrompts,
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'RECENT CHATS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: _sectionLabelColor,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: recentSessions.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No saved chats yet.\nSend a message to start.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AssistantChatColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: recentSessions.length,
                      itemBuilder: (context, index) {
                        final s = recentSessions[index];
                        return _RecentChatTile(
                          title: s.title,
                          onTap: () => onOpenSession(s.id),
                          onDelete: () => onDeleteSession(s.id),
                        );
                      },
                    ),
            ),
            const Divider(height: 1, thickness: 1),
            _DrawerNavRow(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: onSettings,
            ),
            InkWell(
              onTap: onProfileMenu,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AssistantChatColors.iconCircleBg,
                      child: Text(
                        'AR',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AssistantChatColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alex Rivers',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AssistantChatColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Premium Member',
                            style: TextStyle(
                              fontSize: 13,
                              color: AssistantChatColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.unfold_more_rounded,
                      color: AssistantChatColors.iconMuted
                          .withValues(alpha: 0.85),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _appVersion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: _sectionLabelColor,
                ),
              ),
            ),
          ],
        ),
    );

    if (embedAsSheet) {
      return Material(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        child: content,
      );
    }
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: content,
    );
  }
}

class _NewChatButton extends StatelessWidget {
  const _NewChatButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 20, color: Colors.white),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: AssistantChatColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.add,
        size: 20,
        color: AssistantChatColors.iconMuted.withValues(alpha: 0.9),
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AssistantChatColors.textSecondary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: AssistantChatColors.drawerLavenderBg,
        foregroundColor: AssistantChatColors.textSecondary,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _DrawerNavRow extends StatelessWidget {
  const _DrawerNavRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AssistantChatColors.iconMuted),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AssistantChatColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmDeleteSession(
  BuildContext context,
  VoidCallback onConfirmed,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete this chat?'),
      content: const Text(
        'Are you sure you want to delete this conversation? '
        'This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFB91C1C),
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) onConfirmed();
}

class _RecentChatTile extends StatelessWidget {
  const _RecentChatTile({
    required this.title,
    required this.onTap,
    required this.onDelete,
  });

  final String title;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: AssistantChatColors.iconMuted.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AssistantChatColors.textPrimary,
                  ),
                ),
              ),
              _DrawerIconAction(
                icon: Icons.close,
                semanticLabel: 'Delete chat',
                iconSize: 20,
                padding: const EdgeInsets.all(4),
                onPressed: () => _confirmDeleteSession(context, onDelete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
