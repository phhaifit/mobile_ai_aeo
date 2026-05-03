import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/template_library/store/template_library_store.dart';
import 'package:boilerplate/presentation/template_library/store/content_generation_store.dart';
import 'package:boilerplate/presentation/template_library/widgets/website_analyzer_widget.dart';
import 'package:boilerplate/presentation/template_library/widgets/industry_template_card.dart';
import 'package:boilerplate/presentation/template_library/widgets/voice_preview_modal.dart';
import 'package:boilerplate/presentation/template_library/widgets/content_profile_form_modal.dart';
import 'package:boilerplate/presentation/template_library/widgets/delete_confirmation_dialog.dart';
import 'package:boilerplate/presentation/template_library/widgets/content_generation_tab.dart';
import 'package:boilerplate/presentation/template_library/widgets/loading_widgets.dart';
import 'package:boilerplate/presentation/template_library/widgets/profile_operation_banner.dart';
import 'package:boilerplate/presentation/template_library/ui_content_industry.dart';

class TemplateLibraryScreen extends StatefulWidget {
  @override
  State<TemplateLibraryScreen> createState() => _TemplateLibraryScreenState();
}

class _TemplateLibraryScreenState extends State<TemplateLibraryScreen> {
  late final TemplateLibraryStore _store;

  /// Brief fake delay so the apply-profile loading dialog is visible (purely cosmetic).
  static const Duration _applyProfileLoadingDelay = Duration(milliseconds: 650);

  /// Indexed tabs (0–2). Avoids [TabController] / [TabBarView] index vs length
  /// mismatches that can occur after hot reload or with nested scrollables.
  int _tabIndex = 0;

  static const int _tabCount = 3;

  /// GlobalKey to access ContentGenerationTab and set profile
  final _contentGenerationTabKey = GlobalKey<State<ContentGenerationTab>>();

  /// Profiles tab: `null` = All industries (UI-only buckets).
  UiContentIndustry? _profileIndustryTagFilter;

  @override
  void initState() {
    super.initState();
    _store = getIt<TemplateLibraryStore>();
    _store.fetchIndustryTemplates();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  void _setTab(int index) {
    if (index < 0 || index >= _tabCount) return;
    setState(() => _tabIndex = index);
  }

  void _onContentProfileMutationSuccess() {
    getIt<ContentGenerationStore>().loadLists();
  }

  static const Color _tagAccent = Color(0xFF2196F3);

  Widget _buildIndustryTagRow() {
    Widget chip({
      required String label,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: _tagAccent.withOpacity(0.2),
        labelStyle: TextStyle(
          color: selected ? _tagAccent : Color(0xFF444444),
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
        side: BorderSide(
          color: selected ? _tagAccent : Color(0xFFE0E0E0),
        ),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Industry filter',
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 8.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              chip(
                label: 'All',
                selected: _profileIndustryTagFilter == null,
                onTap: () => setState(() => _profileIndustryTagFilter = null),
              ),
              SizedBox(width: 8.0),
              ...UiContentIndustry.values.map((ind) {
                final selected = _profileIndustryTagFilter == ind;
                return Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: chip(
                    label: ind.tagLabel,
                    selected: selected,
                    onTap: () => setState(() => _profileIndustryTagFilter = ind),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Single column of cards for the active tag (UI-only filter; API unchanged).
  List<Widget> _buildFilteredProfileCards(BuildContext listContext) {
    final all = _store.contentProfiles;
    final filtered = profilesForTagFilter(all, _profileIndustryTagFilter);
    if (filtered.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            'No profiles for this industry. Pick another tag or use All (display grouping only, not from API).',
            style: TextStyle(
              fontSize: 13.0,
              color: Color(0xFF999999),
              height: 1.35,
            ),
          ),
        ),
      ];
    }
    return filtered
        .map(
          (profile) => Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: IndustryTemplateCard(
              profile: profile,
              onTap: () {
                _store.selectContentProfile(profile);
                _showProfilePreview(listContext, profile);
              },
              onEdit: () {
                showDialog(
                  context: listContext,
                  builder: (_) => ContentProfileFormModal(
                    projectId: '9022c9d7-7443-4a33-96aa-56628ba81220',
                    hostContext: listContext,
                    profile: profile,
                    onSuccess: _onContentProfileMutationSuccess,
                  ),
                );
              },
              onDelete: () {
                showDialog(
                  context: listContext,
                  builder: (_) => DeleteConfirmationDialog(
                    projectId: '9022c9d7-7443-4a33-96aa-56628ba81220',
                    contentProfileId: profile.id,
                    profileName: profile.name,
                    hostContext: listContext,
                    onSuccess: _onContentProfileMutationSuccess,
                  ),
                );
              },
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: Text(
          'Template Library',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ContentProfileFormModal(
                      projectId: '9022c9d7-7443-4a33-96aa-56628ba81220',
                      hostContext: context,
                      onSuccess: _onContentProfileMutationSuccess,
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Create',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TabBar in body (full width) so all 3 tabs stay visible on narrow phones.
          Material(
            color: Colors.white,
            elevation: 0.5,
            child: _TemplateLibraryTabBar(
              selectedIndex: _tabIndex,
              onSelect: _setTab,
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              sizing: StackFit.expand,
              children: [
                WebsiteAnalyzerWidget(store: _store),
                Observer(
                  builder: (context) {
                    if (_store.isLoading) {
                      return _buildLoadingState();
                    }

                    if (_store.contentProfiles.isEmpty) {
                      return ListView(
                        padding: EdgeInsets.all(16.0),
                        children: [
                          Text(
                            'Content Profiles',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF333333),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'No content profiles available.',
                            style: TextStyle(
                              fontSize: 13.0,
                              color: Color(0xFF666666),
                              height: 1.4,
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView(
                      padding: EdgeInsets.all(16.0),
                      children: [
                        Text(
                          'Content Profiles',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Select a content profile. Use tags to filter by industry (UI only; not sent to the API).',
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Color(0xFF666666),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        _buildIndustryTagRow(),
                        SizedBox(height: 16.0),
                        ..._buildFilteredProfileCards(context),
                      ],
                    );
                  },
                ),
                ContentGenerationTab(
                  key: _contentGenerationTabKey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfilePreview(BuildContext hostContext, dynamic profile) {
    showModalBottomSheet(
      context: hostContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => VoicePreviewModal(
        profile: profile,
        onApply: () async {
          Navigator.pop(sheetContext);

          if (!hostContext.mounted) return;
          showDialog<void>(
            context: hostContext,
            barrierDismissible: false,
            builder: (_) => LoadingDialog(
              message: 'Applying profile...',
            ),
          );

          await Future<void>.delayed(_applyProfileLoadingDelay);
          if (!hostContext.mounted) return;

          _setTab(2);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final state = _contentGenerationTabKey.currentState;
            if (state != null) {
              (state as dynamic).setProfileId(profile.id);
            }
            if (!hostContext.mounted) return;
            Navigator.of(hostContext, rootNavigator: true).pop();
            showProfileOperationTopBanner(
              hostContext,
              success: true,
              message: '${profile.name} profile applied.',
            );
          });
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Loading Templates...',
            style: TextStyle(
              fontSize: 14.0,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateLibraryTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _TemplateLibraryTabBar({
    required this.selectedIndex,
    required this.onSelect,
  });

  static const _accent = Color(0xFF2196F3);
  static const _muted = Color(0xFF999999);

  @override
  Widget build(BuildContext context) {
    final items = [
      _TabSpec('Website', Icons.language),
      _TabSpec('Profiles', Icons.category),
      _TabSpec('Generate', Icons.auto_awesome),
    ];
    return Row(
      children: List.generate(items.length, (i) {
        final sel = selectedIndex == i;
        return Expanded(
          child: InkWell(
            onTap: () => onSelect(i),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[i].icon,
                    size: 18,
                    color: sel ? _accent : _muted,
                  ),
                  SizedBox(height: 4),
                  Text(
                    items[i].label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                      color: sel ? _accent : _muted,
                    ),
                  ),
                  SizedBox(height: 6),
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: sel ? _accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TabSpec {
  final String label;
  final IconData icon;
  const _TabSpec(this.label, this.icon);
}
