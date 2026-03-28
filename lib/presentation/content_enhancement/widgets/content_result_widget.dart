import 'package:boilerplate/domain/entity/content/content_operation.dart';
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
    if (result == null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
          child: Text(
            'Result will appear here',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).primaryColor.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  result!.operation.displayName,
                  style: const TextStyle(fontSize: 12),
                ),
                padding: EdgeInsets.zero,
              ),
              Row(
                children: [
                  if (result!.tokensUsed != null)
                    Text(
                      '${result!.tokensUsed} tokens',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: 'Copy result',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result!.resultText));
                      onCopy?.call();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(result!.resultText),
        ],
      ),
    );
  }
}
