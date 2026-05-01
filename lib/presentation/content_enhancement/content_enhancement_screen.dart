import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/content/content_item.dart';
import 'package:boilerplate/domain/entity/content/content_operation.dart';
import 'package:boilerplate/presentation/content_enhancement/store/content_enhancement_store.dart';
import 'package:boilerplate/presentation/content_enhancement/widgets/before_after_widget.dart';
import 'package:boilerplate/presentation/content_enhancement/widgets/customization_panel.dart';
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

  @override
  void initState() {
    super.initState();
    // Fire-and-forget — picker shows a spinner while it resolves.
    _store.loadAvailableContents();
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
        actions: [
          Observer(
            builder: (_) => IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload posts',
              onPressed: _store.loadingContents
                  ? null
                  : () => _store.loadAvailableContents(force: true),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
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
            const SizedBox(height: 16),
            _buildCustomizationPanel(),
            const SizedBox(height: 20),
            _buildContentPickerSection(),
            const SizedBox(height: 16),
            _buildSelectedPreview(),
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
          'Pick one of your drafts, then choose how to refine it',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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

  Widget _buildCustomizationPanel() {
    return Observer(
      builder: (_) {
        final accent = _operationMeta[_store.selectedOperation]!.color;
        return CustomizationPanel(
          operation: _store.selectedOperation,
          selectedTone: _store.selectedTone,
          selectedLength: _store.selectedLength,
          customInstruction: _store.customInstruction,
          accentColor: accent,
          onToneChanged: _store.setTone,
          onLengthChanged: _store.setLength,
          onInstructionChanged: _store.setCustomInstruction,
        );
      },
    );
  }

  Widget _buildContentPickerSection() {
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                const Icon(Icons.article_outlined,
                    size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                const Text(
                  'Pick a post to enhance',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF475569),
                  ),
                ),
                const Spacer(),
                Observer(
                  builder: (_) => Text(
                    '${_store.availableContents.length} posts',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Observer(builder: (_) => _buildPickerBody()),
        ],
      ),
    );
  }


  Widget _buildPickerBody() {
    // Capture observable reads SYNCHRONOUSLY here so MobX subscribes the
    // surrounding Observer to them. Reads inside ListView.itemBuilder are
    // lazy and do NOT establish a subscription, which is why the picker
    // wasn't rebuilding when `selectedContent` changed.
    final loading = _store.loadingContents;
    final contents = _store.availableContents.toList();
    final selectedId = _store.selectedContent?.id;

    if (loading && contents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (contents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.inbox_outlined,
                size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'No drafts found in your project',
              style: TextStyle(
                  color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Generate a post in Content Studio first, then come back to enhance it.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 320),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
        shrinkWrap: true,
        itemCount: contents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, idx) {
          final item = contents[idx];
          return _buildPickerCard(item, item.id == selectedId);
        },
      ),
    );
  }

  Widget _buildPickerCard(ContentItem item, bool isSelected) {
    final accent = _operationMeta[_store.selectedOperation]!.color;
    final disabled = !item.isEnhanceable;

    // Filled solid color when selected — by far the strongest visual cue.
    final bgColor = disabled
        ? Colors.grey.shade50
        : (isSelected ? accent : Colors.white);
    final fgColor = disabled
        ? Colors.grey.shade400
        : (isSelected ? Colors.white : const Color(0xFF1E293B));
    final subtleColor = isSelected
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.grey.shade500;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : () => _store.selectContent(item),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? accent
                  : (disabled ? Colors.grey.shade200 : Colors.grey.shade300),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Big bold check / empty circle on the left.
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : (disabled
                          ? Colors.grey.shade100
                          : Colors.grey.shade100),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.check_rounded : Icons.add_rounded,
                  size: 22,
                  color: isSelected ? accent : Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: fgColor,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '✓ SELECTED',
                              style: TextStyle(
                                fontSize: 10,
                                color: accent,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildPickerStatusChip(item.status, isSelected),
                        if (item.contentType.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _buildPickerTypeChip(item.contentType, isSelected),
                        ],
                        if (item.topicName.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              item.topicName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: subtleColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerStatusChip(String status, bool isSelected) {
    if (isSelected) {
      // White-on-translucent pill so it stays legible against the accent fill.
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status.toUpperCase(),
          style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w700),
        ),
      );
    }
    return _buildStatusBadge(status);
  }

  Widget _buildPickerTypeChip(String type, bool isSelected) {
    if (isSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          type,
          style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w600),
        ),
      );
    }
    return _buildTypeBadge(type);
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toUpperCase();
    final color = switch (s) {
      'PUBLISHED' => const Color(0xFF059669),
      'READY' || 'COMPLETE' => const Color(0xFF2563EB),
      'DRAFTING' => const Color(0xFFD97706),
      'FAILED' => const Color(0xFFDC2626),
      _ => const Color(0xFF64748B),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        s,
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSelectedPreview() {
    return Observer(
      builder: (_) {
        final picked = _store.selectedContent;
        if (picked == null) return const SizedBox.shrink();
        final hasBody = picked.body.isNotEmpty;
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
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                child: Row(
                  children: [
                    Icon(Icons.preview_outlined,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'Selected draft — ${picked.title}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                    child: SelectableText(
                      hasBody
                          ? picked.body
                          : '(This draft has no body yet — pick another or generate it first.)',
                      style: TextStyle(
                        fontSize: 13,
                        color: hasBody
                            ? const Color(0xFF334155)
                            : Colors.grey.shade400,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProcessButton() {
    return Observer(
      builder: (_) {
        final meta = _operationMeta[_store.selectedOperation]!;
        final picked = _store.selectedContent;
        final isDisabled = _store.loading ||
            picked == null ||
            picked.id.isEmpty ||
            !picked.isEnhanceable;
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
                  ? 'Processing... (this may take ~30s)'
                  : (picked == null
                      ? 'Select a post to ${_store.selectedOperation.displayName.toLowerCase()}'
                      : '${_store.selectedOperation.displayName} this post'),
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
          final picked = _store.selectedContent;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: meta.color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Result — ${_store.currentResult!.operation.displayName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  if (_store.currentResult!.tokensUsed != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${_store.currentResult!.tokensUsed} tokens',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              BeforeAfterWidget(
                originalBody: picked?.body ?? '',
                resultBody: _store.currentResult!.resultText,
                accentColor: meta.color,
                onCopyResult: () => _showCopiedToast(),
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
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCopiedToast() {
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
  }
}

class _OpMeta {
  final IconData icon;
  final Color color;
  final String description;
  const _OpMeta(this.icon, this.color, this.description);
}
