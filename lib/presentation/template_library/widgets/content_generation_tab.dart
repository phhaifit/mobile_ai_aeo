import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/prompt/content_generation_result.dart';
import 'package:boilerplate/presentation/template_library/store/content_generation_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// Hardcoded AEO / SEO reference sources (high-quality pages).
const List<_LabeledUrl> _aeoReferencePages = [
  _LabeledUrl(
    label: 'Google — SEO Starter Guide',
    url:
        'https://developers.google.com/search/docs/fundamentals/seo-starter-guide',
  ),
  _LabeledUrl(
    label: 'Ahrefs — SEO basics',
    url: 'https://ahrefs.com/blog/seo-basics/',
  ),
  _LabeledUrl(
    label: 'Moz — Beginner\'s Guide to SEO',
    url: 'https://moz.com/beginners-guide-to-seo',
  ),
  _LabeledUrl(
    label: 'Search Engine Journal — SEO Guide',
    url: 'https://www.searchenginejournal.com/seo-guide/',
  ),
  _LabeledUrl(
    label: 'Backlinko — SEO Marketing Hub',
    url: 'https://backlinko.com/hub/seo',
  ),
];

const List<_ContentTypeOption> _contentTypes = [
  _ContentTypeOption(value: 'email', label: 'Email'),
  _ContentTypeOption(value: 'copywriting', label: 'Copywriting'),
  _ContentTypeOption(value: 'blog_post', label: 'Blog post'),
  _ContentTypeOption(
      value: 'social_media_post', label: 'Social media post'),
];

const List<_PlatformOption> _platforms = [
  _PlatformOption(value: 'facebook', label: 'Facebook'),
  _PlatformOption(value: 'zalo', label: 'Zalo'),
  _PlatformOption(value: 'linkedin', label: 'LinkedIn'),
  _PlatformOption(value: 'threads', label: 'Threads'),
  _PlatformOption(value: 'instagram', label: 'Instagram'),
];

/// Preset keyword packs (famous / high-intent topics).
const List<_KeywordPreset> _keywordPresets = [
  _KeywordPreset(label: 'AI & machine learning', keywords: ['AI', 'machine learning']),
  _KeywordPreset(label: 'SEO & AEO', keywords: ['SEO', 'AEO']),
  _KeywordPreset(label: 'Content marketing', keywords: ['content marketing', 'brand']),
  _KeywordPreset(label: 'Digital transformation', keywords: ['digital transformation', 'innovation']),
];

class _LabeledUrl {
  final String label;
  final String url;
  const _LabeledUrl({required this.label, required this.url});
}

class _ContentTypeOption {
  final String value;
  final String label;
  const _ContentTypeOption({required this.value, required this.label});
}

class _PlatformOption {
  final String value;
  final String label;
  const _PlatformOption({required this.value, required this.label});
}

class _KeywordPreset {
  final String label;
  final List<String> keywords;
  const _KeywordPreset({required this.label, required this.keywords});
}

class ContentGenerationTab extends StatefulWidget {
  @override
  State<ContentGenerationTab> createState() => _ContentGenerationTabState();
}

class _ContentGenerationTabState extends State<ContentGenerationTab> {
  late final ContentGenerationStore _store;
  final _improvementController = TextEditingController();
  final _referenceTypeController = TextEditingController();
  final _customRefUrlController = TextEditingController();
  final _customKeywordsController = TextEditingController();
  final _customerPersonaController = TextEditingController();

  String _contentTypeValue = _contentTypes.first.value;
  String _platformValue = _platforms.first.value;
  String? _contentProfileId;
  String? _promptId;
  bool _useCustomReferenceUrl = false;
  int _selectedReferenceIndex = 0;
  bool _useCustomKeywords = false;
  int _keywordPresetIndex = 0;

  static const String _demoProjectLabel = 'Demo project (fixed)';

  @override
  void initState() {
    super.initState();
    _store = getIt<ContentGenerationStore>();
    _store.loadLists();
  }

  @override
  void dispose() {
    _improvementController.dispose();
    _referenceTypeController.dispose();
    _customRefUrlController.dispose();
    _customKeywordsController.dispose();
    _customerPersonaController.dispose();
    super.dispose();
  }

  String _effectiveReferenceUrl() {
    if (_useCustomReferenceUrl) {
      return _customRefUrlController.text.trim();
    }
    if (_selectedReferenceIndex >= 0 &&
        _selectedReferenceIndex < _aeoReferencePages.length) {
      return _aeoReferencePages[_selectedReferenceIndex].url;
    }
    return '';
  }

  List<String> _effectiveKeywords() {
    if (_useCustomKeywords) {
      return _customKeywordsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (_keywordPresetIndex >= 0 &&
        _keywordPresetIndex < _keywordPresets.length) {
      return List<String>.from(_keywordPresets[_keywordPresetIndex].keywords);
    }
    return [];
  }

  String? get _effectiveProfileId {
    final profiles = _store.contentProfiles;
    if (profiles.isEmpty) return null;
    if (_contentProfileId != null &&
        profiles.any((p) => p.id == _contentProfileId)) {
      return _contentProfileId;
    }
    return profiles.first.id;
  }

  String? get _effectivePromptId {
    final prompts = _store.prompts;
    if (prompts.isEmpty) return null;
    if (_promptId != null && prompts.any((p) => p.id == _promptId)) {
      return _promptId;
    }
    return prompts.first.id;
  }

  Future<void> _submit() async {
    final promptId = _effectivePromptId;
    final profileId = _effectiveProfileId;
    final refUrl = _effectiveReferenceUrl();
    final keywords = _effectiveKeywords();

    if (promptId == null || promptId.isEmpty) {
      _toast('Please select a prompt.');
      return;
    }
    if (profileId == null || profileId.isEmpty) {
      _toast('Please select a content profile.');
      return;
    }
    if (refUrl.isEmpty) {
      _toast('Please enter or select a reference page URL.');
      return;
    }
    if (keywords.isEmpty) {
      _toast('Please enter or select at least one keyword.');
      return;
    }

    final persona = _customerPersonaController.text.trim();
    final result = await _store.generateContent(
      promptId: promptId,
      contentProfileId: profileId,
      contentType: _contentTypeValue,
      keywords: keywords,
      referencePageUrl: refUrl,
      platform: _platformValue,
      improvement: _improvementController.text.trim(),
      referenceType: _referenceTypeController.text.trim(),
      customerPersonaId: persona.isEmpty ? null : persona,
    );

    if (!mounted) return;
    if (result != null) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => _ContentGenerationResultDialog(result: result),
      );
    } else if (_store.errorStore.errorMessage.isNotEmpty) {
      _toast(_store.errorStore.errorMessage);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        if (_store.isLoadingLists) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading prompts and profiles…',
                  style: TextStyle(color: Color(0xFF666666), fontSize: 14),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Generate content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Pick a prompt and content profile, then generate an article for your project.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              _buildDropdown<String>(
                label: 'Project',
                value: contentGenerationDefaultProjectId,
                items: [
                  DropdownMenuItem(
                    value: contentGenerationDefaultProjectId,
                    child: Text(_demoProjectLabel),
                  ),
                ],
                onChanged: null,
              ),
              SizedBox(height: 16),
              _buildProfileDropdown(),
              SizedBox(height: 16),
              _buildPromptDropdown(),
              SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Content type',
                value: _contentTypeValue,
                items: _contentTypes
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.value,
                        child: Text(e.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _contentTypeValue = v);
                },
              ),
              SizedBox(height: 16),
              _buildDropdown<String>(
                label: 'Platform',
                value: _platformValue,
                items: _platforms
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.value,
                        child: Text(e.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _platformValue = v);
                },
              ),
              SizedBox(height: 16),
              Text(
                'Reference page',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Use my own URL',
                  style: TextStyle(fontSize: 14, color: Color(0xFF444444)),
                ),
                value: _useCustomReferenceUrl,
                activeColor: Color(0xFF2196F3),
                onChanged: (v) => setState(() => _useCustomReferenceUrl = v),
              ),
              if (!_useCustomReferenceUrl) ...[
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  value: _selectedReferenceIndex.clamp(
                      0, _aeoReferencePages.length - 1),
                  items: List.generate(
                    _aeoReferencePages.length,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(
                        _aeoReferencePages[i].label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  onChanged: (i) {
                    if (i != null) setState(() => _selectedReferenceIndex = i);
                  },
                ),
              ] else ...[
                TextField(
                  controller: _customRefUrlController,
                  decoration: InputDecoration(
                    hintText: 'https://example.com/page',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.url,
                ),
              ],
              SizedBox(height: 16),
              Text(
                'Target keywords',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Type my own keywords',
                  style: TextStyle(fontSize: 14, color: Color(0xFF444444)),
                ),
                value: _useCustomKeywords,
                activeColor: Color(0xFF2196F3),
                onChanged: (v) => setState(() => _useCustomKeywords = v),
              ),
              if (!_useCustomKeywords) ...[
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  value: _keywordPresetIndex.clamp(
                      0, _keywordPresets.length - 1),
                  items: List.generate(
                    _keywordPresets.length,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(_keywordPresets[i].label),
                    ),
                  ),
                  onChanged: (i) {
                    if (i != null) setState(() => _keywordPresetIndex = i);
                  },
                ),
              ] else ...[
                TextField(
                  controller: _customKeywordsController,
                  decoration: InputDecoration(
                    hintText: 'Comma separated, e.g. AI, machine learning',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
              SizedBox(height: 16),
              TextField(
                controller: _referenceTypeController,
                decoration: InputDecoration(
                  labelText: 'Reference type',
                  hintText: 'e.g. search, url, competitor',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _improvementController,
                decoration: InputDecoration(
                  labelText: 'Improvement instructions',
                  hintText: 'e.g. Make it shorter and more engaging',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _customerPersonaController,
                decoration: InputDecoration(
                  labelText: 'Customer persona ID (optional)',
                  hintText: 'UUID if applicable',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              SizedBox(height: 24),
              Observer(
                builder: (_) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _store.isGenerating ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _store.isGenerating
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Generate',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
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

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<T>(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildProfileDropdown() {
    final profiles = _store.contentProfiles;
    if (profiles.isEmpty) {
      return Text(
        'No content profiles yet. Create one from the toolbar.',
        style: TextStyle(color: Color(0xFF999999), fontSize: 13),
      );
    }
    final validId = _effectiveProfileId ?? profiles.first.id;
    return _buildDropdown<String>(
      label: 'Content profile',
      value: validId,
      items: profiles
          .map(
            (p) => DropdownMenuItem(
              value: p.id,
              child: Text(p.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _contentProfileId = v);
      },
    );
  }

  Widget _buildPromptDropdown() {
    final prompts = _store.prompts;
    if (prompts.isEmpty) {
      return Text(
        'No prompts returned for this project. Check API access or project setup.',
        style: TextStyle(color: Color(0xFF999999), fontSize: 13),
      );
    }
    final validId = _effectivePromptId ?? prompts.first.id;
    return _buildDropdown<String>(
      label: 'Prompt',
      value: validId,
      items: prompts
          .map(
            (p) => DropdownMenuItem(
              value: p.id,
              child: Text(p.label, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _promptId = v);
      },
    );
  }
}

class _ContentGenerationResultDialog extends StatelessWidget {
  final ContentGenerationResult result;

  const _ContentGenerationResultDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxH = MediaQuery.of(context).size.height * 0.85;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: maxH),
        child: SizedBox(
          height: maxH,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        result.title ?? 'Generated content',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              if (result.slug != null && result.slug!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    result.slug!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChipLabel(
                        label: 'Status', value: result.completionStatus),
                    _ChipLabel(label: 'Type', value: result.contentType),
                    if (result.contentFormat != null)
                      _ChipLabel(
                          label: 'Format', value: result.contentFormat!),
                    if (result.createdAt != null)
                      _ChipLabel(label: 'Created', value: result.createdAt!),
                  ],
                ),
              ),
              if (result.targetKeywords.isNotEmpty) ...[
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Keywords: ${result.targetKeywords.join(', ')}',
                    style: TextStyle(fontSize: 12, color: Color(0xFF555555)),
                  ),
                ),
              ],
              if (result.retrievedPages.isNotEmpty) ...[
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'References',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 6),
                      ...result.retrievedPages.map(
                        (p) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• ${p.title}\n  ${p.url}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF444444),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SelectableText(
                    result.body,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF222222),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final String label;
  final String value;

  const _ChipLabel({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 11, color: Color(0xFF444444)),
      ),
    );
  }
}
