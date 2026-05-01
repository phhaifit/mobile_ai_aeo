import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Side-by-side comparison of the original draft body and the AI result.
///
/// Falls back to a stacked layout when the available width is too narrow
/// for two columns (~600 px breakpoint), so this widget works on both
/// phone and tablet/web shells.
class BeforeAfterWidget extends StatelessWidget {
  final String originalBody;
  final String resultBody;
  final Color accentColor;
  final VoidCallback? onCopyResult;

  const BeforeAfterWidget({
    Key? key,
    required this.originalBody,
    required this.resultBody,
    required this.accentColor,
    this.onCopyResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumns = constraints.maxWidth >= 600;
        final originalPanel = _buildPanel(
          title: 'Original',
          icon: Icons.article_outlined,
          color: const Color(0xFF94A3B8),
          body: originalBody,
        );
        final resultPanel = _buildPanel(
          title: 'AI Result',
          icon: Icons.auto_fix_high,
          color: accentColor,
          body: resultBody,
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: resultBody));
                onCopyResult?.call();
              },
              icon: const Icon(Icons.copy, size: 14),
              label: const Text('Copy', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        );

        if (useColumns) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: originalPanel),
                const SizedBox(width: 12),
                Expanded(child: resultPanel),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            originalPanel,
            const SizedBox(height: 12),
            resultPanel,
          ],
        );
      },
    );
  }

  Widget _buildPanel({
    required String title,
    required IconData icon,
    required Color color,
    required String body,
    List<Widget> actions = const [],
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                ...actions,
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360, minHeight: 80),
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: SelectableText(
                  body.isEmpty ? '(empty)' : body,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: body.isEmpty
                        ? Colors.grey.shade400
                        : const Color(0xFF334155),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
