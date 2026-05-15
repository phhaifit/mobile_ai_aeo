import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/brand_setup/brand_positioning.dart';
import 'package:boilerplate/domain/entity/brand_setup/llm_polling_frequency.dart';
import 'package:boilerplate/domain/entity/brand_setup/project.dart';
import 'package:boilerplate/domain/usecase/brand_setup/brand_positioning_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/brand_profile_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/knowledge_base_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/llm_monitoring_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/llm_polling_frequency_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/project_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/url_link_usecase.dart';
import 'package:boilerplate/domain/usecase/brand_setup/url_rewrite_usecase.dart';
import 'package:mobx/mobx.dart';

part 'brand_setup_store.g.dart';

class BrandSetupStore = _BrandSetupStore with _$BrandSetupStore;

class BrandProfile {
  final String name;
  final String tagline;
  final String industry;
  final String website;
  final String logoUrl;
  final bool verified;

  BrandProfile({
    required this.name,
    required this.tagline,
    required this.industry,
    required this.website,
    required this.logoUrl,
    required this.verified,
  });
}

class KnowledgeBaseEntry {
  final String title;
  final String type;
  final String status;
  final String freshness;
  final int sources;

  KnowledgeBaseEntry({
    required this.title,
    required this.type,
    required this.status,
    required this.freshness,
    required this.sources,
  });
}

class LinkItem {
  final String id;
  final String url;
  final String label;
  final String type;
  final bool monitored;

  LinkItem({
    required this.id,
    required this.url,
    required this.label,
    required this.type,
    required this.monitored,
  });
}

class RewriteRule {
  final String pattern;
  final String target;
  final bool enabled;

  RewriteRule({
    required this.pattern,
    required this.target,
    required this.enabled,
  });
}

class LlmConfig {
  final String id;
  final String llmId;
  final String name;
  final bool enabled;
  final String tier;
  final int pollingMinutes;

  LlmConfig({
    required this.id,
    required this.llmId,
    required this.name,
    required this.enabled,
    required this.tier,
    required this.pollingMinutes,
  });
}

class ProjectCardModel {
  final String name;
  final String owner;
  final String stage;
  final String focus;
  final double completion;

  ProjectCardModel({
    required this.name,
    required this.owner,
    required this.stage,
    required this.focus,
    required this.completion,
  });
}

abstract class _BrandSetupStore with Store {
  final ErrorStore errorStore;
  final GetProjectsUseCase _getProjectsUseCase;
  final GetBrandProfileUseCase _getBrandProfileUseCase;
  final GetKnowledgeBaseEntriesUseCase _getKnowledgeBaseEntriesUseCase;
  final GetUrlLinksUseCase _getUrlLinksUseCase;
  final UpdateUrlLinkUseCase _updateUrlLinkUseCase;
  final GetUrlRewritesUseCase _getUrlRewritesUseCase;
  final GetLlmMonitoringConfigUseCase _getLlmMonitoringConfigUseCase;
  final ToggleLlmMonitoringUseCase _toggleLlmMonitoringUseCase;
  final GetLlmPollingFrequencyUseCase _getLlmPollingFrequencyUseCase;
  final GetBrandPositioningUseCase _getBrandPositioningUseCase;
  final UpdateBrandProfileUseCase _updateBrandProfileUseCase;
  final AddKnowledgeBaseEntryUseCase _addKnowledgeBaseEntryUseCase;

  _BrandSetupStore(
    this.errorStore,
    this._getProjectsUseCase,
    this._getBrandProfileUseCase,
    this._getKnowledgeBaseEntriesUseCase,
    this._getUrlLinksUseCase,
    this._updateUrlLinkUseCase,
    this._getUrlRewritesUseCase,
    this._getLlmMonitoringConfigUseCase,
    this._toggleLlmMonitoringUseCase,
    this._getLlmPollingFrequencyUseCase,
    this._getBrandPositioningUseCase,
    this._updateBrandProfileUseCase,
    this._addKnowledgeBaseEntryUseCase,
  );

  @observable
  BrandProfile? profile;

  @observable
  ObservableList<KnowledgeBaseEntry> knowledgeBase = ObservableList.of([]);

  @observable
  ObservableList<LinkItem> links = ObservableList.of([]);

  @observable
  ObservableList<RewriteRule> rewriteRules = ObservableList.of([]);

  @observable
  ObservableList<LlmConfig> llmConfigs = ObservableList.of([]);

  @observable
  ObservableList<ProjectCardModel> projects = ObservableList.of([]);

  @observable
  int defaultPollingMinutes = 30;

  @observable
  bool isLoading = false;

  @observable
  String? currentProjectId;

  @observable
  String? currentProjectName;

  @observable
  bool usingMockData = false;

  @computed
  int get enabledLlmCount => llmConfigs.where((e) => e.enabled).length;

  @computed
  int get activeRules => rewriteRules.where((e) => e.enabled).length;

  @action
  void toggleLink(int index, bool monitored) {
    if (index < 0 || index >= links.length) return;

    final link = links[index];
    links[index] = LinkItem(
      id: link.id,
      url: link.url,
      label: link.label,
      type: link.type,
      monitored: monitored,
    );

    final projectId = currentProjectId;
    if (projectId == null) return;

    _syncLinkToggle(projectId, index, link, monitored);
  }

  @action
  void toggleLlm(int index, bool enabled) {
    if (index < 0 || index >= llmConfigs.length) return;

    final llm = llmConfigs[index];
    llmConfigs[index] = LlmConfig(
      id: llm.id,
      llmId: llm.llmId,
      name: llm.name,
      enabled: enabled,
      tier: llm.tier,
      pollingMinutes: llm.pollingMinutes,
    );

    final projectId = currentProjectId;
    if (projectId == null) return;

    _syncLlmToggle(projectId, index, llm, enabled);
  }

  Future<void> _syncLinkToggle(
    String projectId,
    int index,
    LinkItem previous,
    bool monitored,
  ) async {
    try {
      await _updateUrlLinkUseCase(projectId, previous.id, {
        'url': previous.url,
        'title': previous.label,
        'description': previous.label,
        'isActive': monitored,
      });
    } catch (e) {
      links[index] = previous;
      errorStore.setErrorMessage('Update link failed: $e');
    }
  }

  @action
  Future<void> updateUrlLink(String linkId, Map<String, dynamic> data) async {
    final pid = currentProjectId;
    if (pid == null) {
      errorStore.setErrorMessage('No active project');
      return;
    }

    try {
      await _updateUrlLinkUseCase(pid, linkId, data);
      await loadData(projectId: pid);
    } catch (e) {
      errorStore.setErrorMessage('Update link failed: $e');
    }
  }

  Future<void> _syncLlmToggle(
    String projectId,
    int index,
    LlmConfig previous,
    bool enabled,
  ) async {
    try {
      await _toggleLlmMonitoringUseCase(projectId, previous.llmId, enabled);
    } catch (e) {
      llmConfigs[index] = previous;
      errorStore.setErrorMessage('Toggle LLM failed: $e');
    }
  }

  @action
  Future<void> loadData({String? projectId}) async {
    isLoading = true;
    errorStore.setErrorMessage('');
    try {
      final projectList = await _getProjectsUseCase();
      final activeProject =
          _pickActiveProject(projectList, preferredId: projectId);

      if (activeProject == null) {
        throw Exception('No project found. Please create a project first.');
      }

      currentProjectId = activeProject.id;
      currentProjectName = activeProject.name;
      projects = ObservableList.of(projectList.map(_mapProject).toList());

      final resolvedProjectId = activeProject.id;

      final results = await Future.wait([
        _getBrandProfileUseCase(resolvedProjectId),
        _getKnowledgeBaseEntriesUseCase(resolvedProjectId),
        _getUrlLinksUseCase(resolvedProjectId),
        _getUrlRewritesUseCase(resolvedProjectId),
        _getLlmMonitoringConfigUseCase(resolvedProjectId),
        _getLlmPollingFrequencyUseCase(resolvedProjectId),
        _getBrandPositioningUseCase(resolvedProjectId),
      ]);

      final domainProfile = results[0] as dynamic;
      final kbEntries = results[1] as List<dynamic>;
      final urlLinks = results[2] as List<dynamic>;
      final urlRewrites = results[3] as List<dynamic>;
      final llms = results[4] as List<dynamic>;
      final polling = results[5] as LlmPollingFrequency;
      final positioning = results[6] as BrandPositioning;

      profile = BrandProfile(
        name: domainProfile.brandName,
        tagline: positioning.positionStatement,
        industry: domainProfile.industry,
        website: domainProfile.websiteUrl ?? '',
        logoUrl: domainProfile.logoUrl ??
            'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=200&q=80',
        verified: (domainProfile.websiteUrl ?? '').isNotEmpty,
      );

      knowledgeBase = ObservableList.of(
        kbEntries.map((entry) {
          final tags = entry.tags as List<String>?;
          return KnowledgeBaseEntry(
            title: entry.title,
            type: entry.category ?? 'General',
            status: (entry.isPublished ?? false) ? 'Synced' : 'Draft',
            freshness: _relativeTime(entry.updatedAt),
            sources: tags?.length ?? 0,
          );
        }).toList(),
      );

      links = ObservableList.of(
        urlLinks.map((link) {
          return LinkItem(
            id: link.id,
            url: link.url,
            label: link.title ?? link.description ?? link.url,
            type: _linkType(link.url),
            monitored: link.isActive ?? true,
          );
        }).toList(),
      );

      rewriteRules = ObservableList.of(
        urlRewrites.map((rewrite) {
          return RewriteRule(
            pattern: rewrite.sourceUrl,
            target: rewrite.targetUrl,
            enabled: rewrite.isActive ?? false,
          );
        }).toList(),
      );

      llmConfigs = ObservableList.of(
        llms.map((llm) {
          return LlmConfig(
            id: llm.id,
            llmId: llm.llmId,
            name: llm.llmName,
            enabled: llm.isEnabled,
            tier: llm.isEnabled ? 'Active' : 'Inactive',
            pollingMinutes: _parsePollingMinutes(llm.pollingFrequency),
          );
        }).toList(),
      );

      defaultPollingMinutes = polling.intervalMinutes;
      usingMockData = false;
    } catch (e) {
      await loadMockData();
      usingMockData = true;
      errorStore.setErrorMessage('Using mock data: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadMockData() async {
    await Future.delayed(const Duration(milliseconds: 250));

    currentProjectId = null;
    currentProjectName = 'Mock Project';

    profile = BrandProfile(
      name: 'Northwind Labs',
      tagline: 'Trusted AI partner for enterprise product teams',
      industry: 'B2B SaaS — Analytics',
      website: 'https://northwind.ai',
      logoUrl:
          'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=200&q=80',
      verified: true,
    );

    knowledgeBase = ObservableList.of([
      KnowledgeBaseEntry(
        title: 'Product docs (v3)',
        type: 'Docs • API',
        status: 'Synced',
        freshness: '2h ago',
        sources: 124,
      ),
      KnowledgeBaseEntry(
        title: 'Changelog & release notes',
        type: 'Docs • Release',
        status: 'Syncing',
        freshness: '5m ago',
        sources: 38,
      ),
      KnowledgeBaseEntry(
        title: 'Support articles',
        type: 'Help Center',
        status: 'Queued',
        freshness: 'Next run',
        sources: 212,
      ),
    ]);

    links = ObservableList.of([
      LinkItem(
        id: 'mock-link-1',
        url: 'https://northwind.ai',
        label: 'Primary domain',
        type: 'Website',
        monitored: true,
      ),
      LinkItem(
        id: 'mock-link-2',
        url: 'https://blog.northwind.ai',
        label: 'Content hub',
        type: 'Blog',
        monitored: true,
      ),
      LinkItem(
        id: 'mock-link-3',
        url: 'https://docs.northwind.ai',
        label: 'Docs',
        type: 'Docs',
        monitored: true,
      ),
      LinkItem(
        id: 'mock-link-4',
        url: 'https://status.northwind.ai',
        label: 'Status',
        type: 'Status',
        monitored: false,
      ),
    ]);

    rewriteRules = ObservableList.of([
      RewriteRule(
        pattern: '/kb/*',
        target: 'https://docs.northwind.ai/{path}',
        enabled: true,
      ),
      RewriteRule(
        pattern: '/pricing',
        target: 'https://northwind.ai/pricing',
        enabled: true,
      ),
      RewriteRule(
        pattern: '/legacy/*',
        target: 'https://northwind.ai/migrate',
        enabled: false,
      ),
    ]);

    llmConfigs = ObservableList.of([
      LlmConfig(
        id: 'mock-llm-1',
        llmId: 'openai-gpt41',
        name: 'OpenAI GPT-4.1',
        enabled: true,
        tier: 'Premium',
        pollingMinutes: 30,
      ),
      LlmConfig(
        id: 'mock-llm-2',
        llmId: 'claude-35',
        name: 'Claude 3.5',
        enabled: true,
        tier: 'Premium',
        pollingMinutes: 45,
      ),
      LlmConfig(
        id: 'mock-llm-3',
        llmId: 'gemini',
        name: 'Gemini',
        enabled: false,
        tier: 'Standard',
        pollingMinutes: 60,
      ),
      LlmConfig(
        id: 'mock-llm-4',
        llmId: 'perplexity',
        name: 'Perplexity',
        enabled: true,
        tier: 'Standard',
        pollingMinutes: 20,
      ),
    ]);

    projects = ObservableList.of([
      ProjectCardModel(
        name: 'Brand refresh rollout',
        owner: 'Mia Chen',
        stage: 'In flight',
        focus: 'Homepage + pricing migration',
        completion: 0.62,
      ),
      ProjectCardModel(
        name: 'AI mention tracking v1',
        owner: 'Luis Vega',
        stage: 'Beta',
        focus: 'Add Gemini + Perplexity coverage',
        completion: 0.48,
      ),
      ProjectCardModel(
        name: 'Knowledge base hardening',
        owner: 'Priya Nair',
        stage: 'Planning',
        focus: 'Content freshness SLAs and retries',
        completion: 0.28,
      ),
    ]);

    defaultPollingMinutes = 30;
  }

  @action
  Future<void> updateBrandProfile(Map<String, dynamic> profileData) async {
    final pid = currentProjectId;
    if (pid == null) {
      errorStore.setErrorMessage('No active project');
      return;
    }

    try {
      await _updateBrandProfileUseCase(pid, profileData);
      await loadData(projectId: pid);
    } catch (e) {
      errorStore.setErrorMessage('Update profile failed: $e');
    }
  }

  @action
  Future<void> addKnowledgeBaseEntry(Map<String, dynamic> entryData) async {
    final pid = currentProjectId;
    if (pid == null) {
      errorStore.setErrorMessage('No active project');
      return;
    }

    try {
      await _addKnowledgeBaseEntryUseCase(pid, entryData);
      await loadData(projectId: pid);
    } catch (e) {
      errorStore.setErrorMessage('Add knowledge base failed: $e');
    }
  }

  Project? _pickActiveProject(
    List<Project> projectList, {
    String? preferredId,
  }) {
    if (projectList.isEmpty) return null;

    if (preferredId != null) {
      try {
        return projectList.firstWhere((p) => p.id == preferredId);
      } catch (_) {
        // Fall through to default project selection.
      }
    }

    try {
      return projectList.firstWhere((p) => p.isActive);
    } catch (_) {
      return projectList.first;
    }
  }

  ProjectCardModel _mapProject(Project project) {
    return ProjectCardModel(
      name: project.name,
      owner: project.ownerId,
      stage: project.isActive ? 'Active' : 'Inactive',
      focus: project.description,
      completion: project.isActive ? 0.7 : 0.3,
    );
  }

  int _parsePollingMinutes(String? value) {
    if (value == null || value.isEmpty) return defaultPollingMinutes;

    final digits = RegExp(r'\d+').firstMatch(value)?.group(0);
    if (digits != null) {
      return int.tryParse(digits) ?? defaultPollingMinutes;
    }

    switch (value.toLowerCase()) {
      case 'hourly':
        return 60;
      case 'daily':
        return 1440;
      case 'weekly':
        return 10080;
      default:
        return defaultPollingMinutes;
    }
  }

  String _linkType(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('docs')) return 'Docs';
    if (lower.contains('blog')) return 'Blog';
    if (lower.contains('status')) return 'Status';
    return 'Website';
  }

  String _relativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';

    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
