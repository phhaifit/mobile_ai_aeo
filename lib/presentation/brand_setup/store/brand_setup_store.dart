import 'package:boilerplate/core/stores/error/error_store.dart';
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
  final String url;
  final String label;
  final String type;
  final bool monitored;

  LinkItem({
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
  final String name;
  final bool enabled;
  final String tier;
  final int pollingMinutes;

  LlmConfig({
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

  _BrandSetupStore(this.errorStore);

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

  @computed
  int get enabledLlmCount => llmConfigs.where((e) => e.enabled).length;

  @computed
  int get activeRules => rewriteRules.where((e) => e.enabled).length;

  @action
  Future<void> loadMockData() async {
    isLoading = true;
    await Future.delayed(Duration(milliseconds: 250));

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
        url: 'https://northwind.ai',
        label: 'Primary domain',
        type: 'Website',
        monitored: true,
      ),
      LinkItem(
        url: 'https://blog.northwind.ai',
        label: 'Content hub',
        type: 'Blog',
        monitored: true,
      ),
      LinkItem(
        url: 'https://docs.northwind.ai',
        label: 'Docs',
        type: 'Docs',
        monitored: true,
      ),
      LinkItem(
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
        name: 'OpenAI GPT-4.1',
        enabled: true,
        tier: 'Premium',
        pollingMinutes: 30,
      ),
      LlmConfig(
        name: 'Claude 3.5',
        enabled: true,
        tier: 'Premium',
        pollingMinutes: 45,
      ),
      LlmConfig(
        name: 'Gemini',
        enabled: false,
        tier: 'Standard',
        pollingMinutes: 60,
      ),
      LlmConfig(
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

    isLoading = false;
  }
}
