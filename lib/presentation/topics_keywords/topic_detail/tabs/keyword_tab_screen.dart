import 'package:boilerplate/presentation/topics_keywords/topic_detail/models/topic_keyword.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Keyword {
  String id;
  String text;
  DateTime createdAt;
  bool isSelected;

  Keyword({
    required this.id,
    required this.text,
    required this.createdAt,
    this.isSelected = false,
  });

  Keyword copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    bool? isSelected,
  }) {
    return Keyword(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class KeywordTabScreen extends StatefulWidget {
  const KeywordTabScreen({
    super.key,
    required this.searchController,
    required this.apiKeywords,
    required this.isLoading,
    this.errorMessage,
    required this.onRetry,
    required this.onAddKeywords,
    required this.onSuggestKeywords,
    required this.onDeleteKeyword,
  });

  final TextEditingController searchController;
  final List<TopicKeyword> apiKeywords;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final Future<bool> Function(List<String> keywords) onAddKeywords;
  final Future<List<String>> Function(List<String> keywords) onSuggestKeywords;
  final Future<bool> Function(String keywordId) onDeleteKeyword;

  @override
  State<KeywordTabScreen> createState() => _KeywordTabScreenState();
}

class _KeywordTabScreenState extends State<KeywordTabScreen> {
  final Set<String> _selectedKeywordIds = <String>{};
  final Set<String> _deletingKeywordIds = <String>{};

  late List<Keyword> _keywords;
  late List<Keyword> _visibleKeywords;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // Boot from API keywords; they may be empty on first frame if still loading
    _keywords = _fromApiKeywords(widget.apiKeywords);
    _visibleKeywords = _applySearch(_keywords, widget.searchController.text);
    widget.searchController.addListener(_handleSearchChanged);
  }

  @override
  void didUpdateWidget(KeywordTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-sync when the store delivers fresh keywords from the API
    if (oldWidget.apiKeywords != widget.apiKeywords) {
      final existing = _keywords.map((k) => k.id).toSet();
      final newItems = _fromApiKeywords(widget.apiKeywords)
          .where((k) => !existing.contains(k.id))
          .toList();
      if (newItems.isNotEmpty || _keywords.isEmpty) {
        setState(() {
          _keywords = [
            ..._fromApiKeywords(widget.apiKeywords),
            // Keep any locally-added keywords not yet in API
            ..._keywords.where(
              (k) => !widget.apiKeywords.map((tk) => tk.id).contains(k.id),
            ),
          ];
          _visibleKeywords =
              _applySearch(_keywords, widget.searchController.text);
        });
      }
    }
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_handleSearchChanged);
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() {
      _visibleKeywords = _applySearch(_keywords, widget.searchController.text);
    });
  }

  List<Keyword> _fromApiKeywords(List<TopicKeyword> raw) {
    return raw.map((tk) {
      return Keyword(
        id: tk.id,
        text: tk.text,
        createdAt: DateTime.now(), // Real API doesn't return created_at easily, mock for now or use now.
      );
    }).toList();
  }

  List<Keyword> _applySearch(List<Keyword> source, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return List<Keyword>.from(source);
    }
    return source
        .where((keyword) => keyword.text.toLowerCase().contains(normalized))
        .toList(growable: false);
  }

  bool get _isAllVisibleSelected {
    if (_visibleKeywords.isEmpty) {
      return false;
    }
    return _visibleKeywords
        .every((keyword) => _selectedKeywordIds.contains(keyword.id));
  }

  void _toggleSelectAllVisible(bool selected) {
    if (_isDeleting) {
      return;
    }

    setState(() {
      for (final keyword in _visibleKeywords) {
        if (_deletingKeywordIds.contains(keyword.id)) {
          continue;
        }
        if (selected) {
          _selectedKeywordIds.add(keyword.id);
        } else {
          _selectedKeywordIds.remove(keyword.id);
        }
      }
      _keywords = _keywords
          .map(
            (keyword) => keyword.copyWith(
              isSelected: _selectedKeywordIds.contains(keyword.id),
            ),
          )
          .toList(growable: false);
      _visibleKeywords = _applySearch(_keywords, widget.searchController.text);
    });
  }

  void _toggleSelectOne(String id, bool selected) {
    if (_isDeleting || _deletingKeywordIds.contains(id)) {
      return;
    }

    setState(() {
      if (selected) {
        _selectedKeywordIds.add(id);
      } else {
        _selectedKeywordIds.remove(id);
      }

      _keywords = _keywords
          .map(
            (keyword) => keyword.id == id
                ? keyword.copyWith(isSelected: selected)
                : keyword,
          )
          .toList(growable: false);
      _visibleKeywords = _applySearch(_keywords, widget.searchController.text);
    });
  }

  Future<void> _confirmDeleteBulk() async {
    final count = _selectedKeywordIds.length;
    if (count == 0 || _isDeleting) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return DeleteConfirmationModal(count: count);
      },
    );

    if (shouldDelete == true) {
      await _deleteByIds(_selectedKeywordIds.toSet());
    }
  }

  Future<void> _confirmDeleteSingle(Keyword keyword) async {
    if (_isDeleting) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const DeleteConfirmationModal(count: 1);
      },
    );

    if (shouldDelete == true) {
      await _deleteByIds({keyword.id});
    }
  }

  Future<void> _deleteByIds(Set<String> ids) async {
    if (ids.isEmpty) {
      return;
    }

    setState(() {
      _isDeleting = true;
      _deletingKeywordIds.addAll(ids);
    });

    final deletedIds = <String>{};
    for (final id in ids) {
      final success = await widget.onDeleteKeyword(id);
      if (success) {
        deletedIds.add(id);
      }
    }

    if (!mounted) {
      return;
    }

    _keywords =
        _keywords.where((keyword) => !deletedIds.contains(keyword.id)).toList();
    _selectedKeywordIds.removeAll(deletedIds);

    setState(() {
      _isDeleting = false;
      _deletingKeywordIds.removeAll(ids);
      _visibleKeywords = _applySearch(_keywords, widget.searchController.text);
    });

    final failedCount = ids.length - deletedIds.length;
    if (failedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed for $failedCount keyword(s). Please retry.'),
          backgroundColor: const Color(0xFFB42318),
        ),
      );
    }
  }

  Future<void> _addKeyword() async {
    if (_isDeleting) {
      return;
    }

    final addedKeywords = await _showAddKeywordsModal();
    if (addedKeywords == null || addedKeywords.isEmpty) {
      return;
    }

    final success = await widget.onAddKeywords(addedKeywords);
    if (!mounted || success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to add keywords. Please try again.'),
        backgroundColor: Color(0xFFB42318),
      ),
    );
  }

  Future<List<String>?> _showAddKeywordsModal() {
    final isMobile = MediaQuery.of(context).size.width < 720;

    Future<List<String>> refreshSuggestions() {
      return widget.onSuggestKeywords(
        _keywords.map((keyword) => keyword.text).toList(growable: false),
      );
    }

    if (isMobile) {
      return showModalBottomSheet<List<String>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return FractionallySizedBox(
            heightFactor: 0.92,
            child: _AddKeywordsModal(
              suggestions: const [],
              onRefreshSuggestions: refreshSuggestions,
              isMobile: true,
            ),
          );
        },
      );
    }

    return showDialog<List<String>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760, maxHeight: 620),
            child: _AddKeywordsModal(
              suggestions: const [],
              onRefreshSuggestions: refreshSuggestions,
              isMobile: false,
            ),
          ),
        );
      },
    );
  }

  Future<void> _editKeyword(Keyword keyword) async {
    if (_isDeleting || _deletingKeywordIds.contains(keyword.id)) {
      return;
    }

    final controller = TextEditingController(text: keyword.text);
    final updated = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Keyword',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D2939),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Enter keyword',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final value = controller.text.trim();
                          if (value.isEmpty) {
                            return;
                          }
                          Navigator.of(dialogContext).pop(value);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6A00),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    controller.dispose();

    if (updated == null || updated.isEmpty) {
      return;
    }

    setState(() {
      _keywords = _keywords
          .map((item) =>
              item.id == keyword.id ? item.copyWith(text: updated) : item)
          .toList(growable: false);
      _visibleKeywords = _applySearch(_keywords, widget.searchController.text);
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    // Loading state (first load)
    if (widget.isLoading && _keywords.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state (no data)
    if (widget.errorMessage != null && _keywords.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 38, color: Color(0xFFD0D5DD)),
            const SizedBox(height: 10),
            Text(
              widget.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: widget.onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6A00),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_isDeleting)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        _KeywordActionBar(
          searchController: widget.searchController,
          selectedCount: _selectedKeywordIds.length,
          onDelete: _confirmDeleteBulk,
          onAdd: _addKeyword,
          isDeleting: _isDeleting,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _visibleKeywords.isEmpty
              ? const _KeywordEmptyState()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 900;
                    if (isMobile) {
                      return KeywordMobileList(
                        keywords: _visibleKeywords,
                        allVisibleSelected: _isAllVisibleSelected,
                        onToggleAll: _toggleSelectAllVisible,
                        onToggleOne: _toggleSelectOne,
                        onEdit: _editKeyword,
                        onDeleteOne: _confirmDeleteSingle,
                        deletingIds: _deletingKeywordIds,
                        isDeleting: _isDeleting,
                        dateFormatter: _formatDate,
                      );
                    }

                    return KeywordTable(
                      keywords: _visibleKeywords,
                      allVisibleSelected: _isAllVisibleSelected,
                      onToggleAll: _toggleSelectAllVisible,
                      onToggleOne: _toggleSelectOne,
                      onEdit: _editKeyword,
                      onDeleteOne: _confirmDeleteSingle,
                      deletingIds: _deletingKeywordIds,
                      isDeleting: _isDeleting,
                      dateFormatter: _formatDate,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _KeywordActionBar extends StatelessWidget {
  const _KeywordActionBar({
    required this.searchController,
    required this.selectedCount,
    required this.onDelete,
    required this.onAdd,
    required this.isDeleting,
  });

  final TextEditingController searchController;
  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback onAdd;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final deleteButton = OutlinedButton.icon(
          onPressed: selectedCount == 0 || isDeleting ? null : onDelete,
          icon: isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.delete_outline, size: 18),
          label: Text(isDeleting ? 'Deleting...' : 'Delete ($selectedCount)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFDC2626),
            side: BorderSide(
              color: selectedCount == 0
                  ? const Color(0xFFFEE2E2)
                  : const Color(0xFFFCA5A5),
            ),
            backgroundColor: const Color(0xFFFFF1F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        );

        final addButton = ElevatedButton.icon(
          onPressed: isDeleting ? null : onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Keyword'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6A00),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        );

        if (compact) {
          return Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search keywords...',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [deleteButton, addButton],
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search keywords...',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                deleteButton,
                const SizedBox(width: 10),
                addButton,
              ],
            ),
          ],
        );
      },
    );
  }
}

class KeywordMobileList extends StatelessWidget {
  const KeywordMobileList({
    super.key,
    required this.keywords,
    required this.allVisibleSelected,
    required this.onToggleAll,
    required this.onToggleOne,
    required this.onEdit,
    required this.onDeleteOne,
    required this.deletingIds,
    required this.isDeleting,
    required this.dateFormatter,
  });

  final List<Keyword> keywords;
  final bool allVisibleSelected;
  final ValueChanged<bool> onToggleAll;
  final void Function(String id, bool selected) onToggleOne;
  final ValueChanged<Keyword> onEdit;
  final ValueChanged<Keyword> onDeleteOne;
  final Set<String> deletingIds;
  final bool isDeleting;
  final String Function(DateTime) dateFormatter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: allVisibleSelected,
                  onChanged: isDeleting
                      ? null
                      : (value) => onToggleAll(value ?? false),
                ),
                const SizedBox(width: 2),
                const Text(
                  'Select all',
                  style: TextStyle(
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEAECF0)),
          Expanded(
            child: ListView.separated(
              itemCount: keywords.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFEAECF0)),
              itemBuilder: (context, index) {
                final keyword = keywords[index];
                final isRowDeleting = deletingIds.contains(keyword.id);
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: keyword.isSelected,
                        onChanged: isDeleting || isRowDeleting
                            ? null
                            : (value) => onToggleOne(keyword.id, value ?? false),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              keyword.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101828),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormatter(keyword.createdAt),
                              style: const TextStyle(
                                color: Color(0xFF667085),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          IconButton(
                            onPressed: isDeleting || isRowDeleting
                                ? null
                                : () => onEdit(keyword),
                            icon: const Icon(Icons.edit_outlined),
                            color: const Color(0xFF155EEF),
                            splashRadius: 18,
                          ),
                          isRowDeleting
                              ? const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                )
                              : IconButton(
                                  onPressed: isDeleting
                                      ? null
                                      : () => onDeleteOne(keyword),
                                  icon: const Icon(Icons.delete_outline),
                                  color: const Color(0xFFEF4444),
                                  splashRadius: 18,
                                ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddKeywordsModal extends StatefulWidget {
  const _AddKeywordsModal({
    required this.suggestions,
    required this.onRefreshSuggestions,
    required this.isMobile,
  });

  final List<String> suggestions;
  final Future<List<String>> Function() onRefreshSuggestions;
  final bool isMobile;

  @override
  State<_AddKeywordsModal> createState() => _AddKeywordsModalState();
}

class _AddKeywordsModalState extends State<_AddKeywordsModal> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _selectedKeywords = [];
  late List<String> _suggestedKeywords;
  bool _isInitialLoading = true;
  bool _isRefreshingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _suggestedKeywords = List<String>.from(widget.suggestions);
    _loadInitialSuggestions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addFromInput(String raw) {
    final parts = raw
        .split(RegExp(r'[\n;,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return;
    }

    setState(() {
      for (final keyword in parts) {
        _addKeywordChip(keyword);
      }
    });
  }

  void _addKeywordChip(String keyword) {
    final normalized = keyword.trim();
    if (normalized.isEmpty) {
      return;
    }

    final exists = _selectedKeywords
        .any((item) => item.toLowerCase() == normalized.toLowerCase());
    if (exists) {
      return;
    }
    _selectedKeywords.add(normalized);
  }

  List<String> get _availableSuggestions {
    final selectedLower =
        _selectedKeywords.map((item) => item.toLowerCase()).toSet();
    return _suggestedKeywords
        .where((item) => !selectedLower.contains(item.toLowerCase()))
        .toList(growable: false);
  }

  Future<void> _loadInitialSuggestions() async {
    try {
      final initialSuggestions = await widget.onRefreshSuggestions();
      if (!mounted) {
        return;
      }

      setState(() {
        _suggestedKeywords = List<String>.from(initialSuggestions);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load keyword suggestions. You can still add manually.'),
            backgroundColor: Color(0xFFB42318),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _refreshSuggestions() async {
    if (_isRefreshingSuggestions) {
      return;
    }

    setState(() {
      _isRefreshingSuggestions = true;
    });

    try {
      final refreshedSuggestions = await widget.onRefreshSuggestions();

      if (!mounted) {
        return;
      }

      setState(() {
        _suggestedKeywords = List<String>.from(refreshedSuggestions);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to refresh suggestions. Please try again.'),
            backgroundColor: Color(0xFFB42318),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshingSuggestions = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = widget.isMobile ? 30.0 : 34.0;
    final horizontalPadding = widget.isMobile ? 14.0 : 24.0;
    final selectedBoxHeight = widget.isMobile ? 132.0 : 148.0;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: widget.isMobile
                ? const BorderRadius.vertical(top: Radius.circular(16))
                : BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  widget.isMobile ? 14 : 20,
                  horizontalPadding,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Add Keywords',
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1D2939),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          color: const Color(0xFF98A2B3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Type keywords or pick from suggestions.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF667085),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'KEYWORDS TO ADD',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF667085),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: selectedBoxHeight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD0D5DD)),
                      ),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ..._selectedKeywords.map((keyword) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF3F3F56),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      keyword,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedKeywords.remove(keyword);
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(999),
                                      child: const Icon(Icons.close, size: 16),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _controller,
                                onSubmitted: (value) {
                                  _addFromInput(value);
                                  _controller.clear();
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Type keyword and press Enter...',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'SUGGESTED KEYWORDS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed:
                              _isRefreshingSuggestions ? null : _refreshSuggestions,
                          icon: _isRefreshingSuggestions
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF667085),
                                  ),
                                )
                              : const Icon(Icons.refresh, size: 16),
                          label: Text(
                            _isRefreshingSuggestions ? 'Refreshing...' : 'Refresh',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFCFD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEAECF0)),
                    ),
                    child: _isInitialLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _availableSuggestions.isEmpty
                        ? const Center(
                            child: Text(
                              'No suggested keywords',
                              style: TextStyle(color: Color(0xFF98A2B3)),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _availableSuggestions.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final keyword = _availableSuggestions[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () => _addFromInput(keyword),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0xFFD0D5DD),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.add,
                                        size: 16,
                                        color: Color(0xFF98A2B3),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          keyword,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF344054),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFEAECF0)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    horizontalPadding, 14, horizontalPadding, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF344054),
                        side: const BorderSide(color: Color(0xFFD0D5DD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _selectedKeywords.isEmpty
                          ? null
                          : () => Navigator.of(context).pop(_selectedKeywords),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7A59),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFFCD5CC),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Save Keywords'),
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
}

class KeywordTable extends StatelessWidget {
  const KeywordTable({
    super.key,
    required this.keywords,
    required this.allVisibleSelected,
    required this.onToggleAll,
    required this.onToggleOne,
    required this.onEdit,
    required this.onDeleteOne,
    required this.deletingIds,
    required this.isDeleting,
    required this.dateFormatter,
  });

  final List<Keyword> keywords;
  final bool allVisibleSelected;
  final ValueChanged<bool> onToggleAll;
  final void Function(String id, bool selected) onToggleOne;
  final ValueChanged<Keyword> onEdit;
  final ValueChanged<Keyword> onDeleteOne;
  final Set<String> deletingIds;
  final bool isDeleting;
  final String Function(DateTime) dateFormatter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Checkbox(
                    value: allVisibleSelected,
                    onChanged: isDeleting
                        ? null
                        : (value) => onToggleAll(value ?? false),
                  ),
                ),
                const Expanded(
                  flex: 7,
                  child: Text(
                    'KEYWORD',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF667085),
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'CREATED AT',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF667085),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 120,
                  child: Text(
                    'ACTIONS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF667085),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEAECF0)),
          Expanded(
            child: ListView.builder(
              itemCount: keywords.length,
              itemBuilder: (context, index) {
                final keyword = keywords[index];
                final isRowDeleting = deletingIds.contains(keyword.id);
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: KeywordRow(
                    key: ValueKey(keyword.id),
                    keyword: keyword,
                    isSelected: keyword.isSelected,
                    isDeleting: isRowDeleting,
                    onChanged: isDeleting || isRowDeleting
                        ? (_) {}
                        : (selected) => onToggleOne(keyword.id, selected),
                    onEdit: isDeleting || isRowDeleting
                        ? null
                        : () => onEdit(keyword),
                    onDelete: isDeleting
                        ? null
                        : () => onDeleteOne(keyword),
                    dateLabel: dateFormatter(keyword.createdAt),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class KeywordRow extends StatelessWidget {
  const KeywordRow({
    super.key,
    required this.keyword,
    required this.isSelected,
    required this.isDeleting,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
    required this.dateLabel,
  });

  final Keyword keyword;
  final bool isSelected;
  final bool isDeleting;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFEAECF0).withValues(alpha: 0.8)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Checkbox(
              value: isSelected,
              onChanged: isDeleting ? null : (value) => onChanged(value ?? false),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              keyword.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              dateLabel,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  color: const Color(0xFF155EEF),
                  splashRadius: 18,
                ),
                isDeleting
                    ? const SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        color: const Color(0xFFEF4444),
                        splashRadius: 18,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteConfirmationModal extends StatelessWidget {
  const DeleteConfirmationModal({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              Navigator.of(context).pop(false);
              return null;
            },
          ),
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Delete Keywords',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D2939),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        icon: const Icon(Icons.close),
                        color: const Color(0xFF98A2B3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to delete $count keyword(s)? This action cannot be undone.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF475467),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: Color(0xFFEAECF0)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF344054),
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A59),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Delete All',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeywordEmptyState extends StatelessWidget {
  const _KeywordEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No keywords yet\nTry clicking + Add Keyword',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF667085),
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
