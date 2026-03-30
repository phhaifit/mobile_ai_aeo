import 'package:boilerplate/domain/entity/content/content_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContentResultWidget extends StatelessWidget {
  final ContentResult? result;
  final VoidCallback? onCopy;

  const ContentResultWidget({
    Key? key,
    this.result,
    this.onCopy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (result == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (result!.tokensUsed != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${result!.tokensUsed} tokens',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: result!.resultText));
                  onCopy?.call();
                },
                icon: const Icon(Icons.copy, size: 15),
                label: const Text('Copy', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            result!.resultText,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
