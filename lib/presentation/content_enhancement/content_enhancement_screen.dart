import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/content/content_operation.dart';
import 'package:boilerplate/presentation/content_enhancement/store/content_enhancement_store.dart';
import 'package:boilerplate/presentation/content_enhancement/widgets/content_input_widget.dart';
import 'package:boilerplate/presentation/content_enhancement/widgets/content_result_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ContentEnhancementScreen extends StatefulWidget {
  const ContentEnhancementScreen({Key? key}) : super(key: key);

  @override
  State<ContentEnhancementScreen> createState() =>
      _ContentEnhancementScreenState();
}

class _ContentEnhancementScreenState extends State<ContentEnhancementScreen> {
  final ContentEnhancementStore _store = getIt<ContentEnhancementStore>();
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  static const _operationMeta = {
    ContentOperation.enhance: _OpMeta(
      Icons.auto_fix_high,
      Color(0xFF7C3AED),
      'Improve clarity, grammar & tone',
    ),
    ContentOperation.rewrite: _OpMeta(
      Icons.refresh,
      Color(0xFF2563EB),
      'Rewrite with different phrasing',
    ),
    ContentOperation.humanize: _OpMeta(
      Icons.emoji_people,
      Color(0xFF059669),
      'Make AI text sound natural',
    ),
    ContentOperation.summarize: _OpMeta(
      Icons.compress,
      Color(0xFFD97706),
      'Condense to key points',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Content Enhancement'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildOperationCards(),
            const SizedBox(height: 24),
            _buildInputSection(),
            const SizedBox(height: 16),
            _buildProcessButton(),
            const SizedBox(height: 24),
            _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI-Powered Content Tools',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Select an operation and enter your content below',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildOperationCards() {
    return Observer(
      builder: (_) => Row(
        children: ContentOperation.values.map((op) {
          final meta = _operationMeta[op]!;
          final isSelected = _store.selectedOperation == op;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: op != ContentOperation.values.last ? 8 : 0,
              ),
              child: _buildOpChip(op, meta, isSelected),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOpChip(ContentOperation op, _OpMeta meta, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _store.setOperation(op),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? meta.color.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? meta.color : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(meta.icon, color: meta.color, size: 20),
              const SizedBox(height: 4),
              Text(
                op.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isSelected ? meta.color : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.edit_note, size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                const Text(
                  'Input Content',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF475569),
                  ),
                ),
                const Spacer(),
                Observer(
                  builder: (_) => Text(
                    '${_store.inputText.length} / 10,000',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ContentInputWidget(
            controller: _textController,
            onClear: () {
              _store.clearResult();
              _store.setInputText('');
            },
            onChanged: (text) => _store.setInputText(text),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    return Observer(
      builder: (_) {
        final meta = _operationMeta[_store.selectedOperation]!;
        final isDisabled =
            _store.loading || _store.inputText.trim().isEmpty;
        return SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: isDisabled ? null : () => _store.processContent(),
            icon: _store.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(meta.icon, size: 18),
            label: Text(
              _store.loading
                  ? 'Processing...'
                  : _store.selectedOperation.displayName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: meta.color,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultSection() {
    return Observer(
      builder: (_) {
        if (_store.success && _store.currentResult != null) {
          final meta = _operationMeta[_store.currentResult!.operation]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: meta.color),
                  const SizedBox(width: 6),
                  Text(
                    'Result — ${_store.currentResult!.operation.displayName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ContentResultWidget(
                result: _store.currentResult,
                onCopy: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('Copied to clipboard'),
                        ],
                      ),
                      backgroundColor: const Color(0xFF059669),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          );
        }
        if (_store.loading) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.auto_fix_high,
                  size: 36, color: Colors.grey.shade300),
              const SizedBox(height: 10),
              Text(
                'Result will appear here',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OpMeta {
  final IconData icon;
  final Color color;
  final String description;
  const _OpMeta(this.icon, this.color, this.description);
}
