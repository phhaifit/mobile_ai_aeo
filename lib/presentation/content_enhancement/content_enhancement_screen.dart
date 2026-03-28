import 'package:boilerplate/core/widgets/progress_indicator_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Enhancement'),
      ),
      body: Stack(
        children: [
          _buildBody(),
          Observer(
            builder: (_) =>
                _store.loading ? const CustomProgressIndicatorWidget() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOperationChips(),
          const SizedBox(height: 16),
          ContentInputWidget(
            controller: _textController,
            onClear: _store.clearResult,
            onChanged: (text) => _store.setInputText(text),
          ),
          const SizedBox(height: 12),
          _buildProcessButton(),
          const SizedBox(height: 16),
          _buildResultSection(),
        ],
      ),
    );
  }

  Widget _buildOperationChips() {
    return Observer(
      builder: (_) => Wrap(
        spacing: 8.0,
        children: ContentOperation.values.map((op) {
          return ChoiceChip(
            label: Text(op.displayName),
            selected: _store.selectedOperation == op,
            onSelected: (_) => _store.setOperation(op),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProcessButton() {
    return Observer(
      builder: (_) => ElevatedButton(
        onPressed: (_store.loading || _store.inputText.trim().isEmpty)
            ? null
            : () => _store.processContent(),
        child: const Text('Process'),
      ),
    );
  }

  Widget _buildResultSection() {
    return Observer(
      builder: (_) {
        if (_store.success && _store.currentResult != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Result',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ContentResultWidget(
                result: _store.currentResult,
                onCopy: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
            ],
          );
        }
        return ContentResultWidget(result: null);
      },
    );
  }
}
