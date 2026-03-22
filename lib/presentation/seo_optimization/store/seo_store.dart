import 'package:mobx/mobx.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';

part 'seo_store.g.dart';

class SeoStore = _SeoStore with _$SeoStore;

abstract class _SeoStore with Store {
  final String TAG = "_SeoStore";

  final ErrorStore errorStore;

  // ─── On-page SEO ───────────────────────────────────────────────────────────
  @observable
  List<SeoCheckItem> onPageSeoItems = [];

  // ─── Topic Clustering ──────────────────────────────────────────────────────
  @observable
  List<TopicCluster> topicClusters = [];

  // ─── Internal Linking ──────────────────────────────────────────────────────
  @observable
  List<InternalLinkSuggestion> internalLinkSuggestions = [];

  // ─── Content Structure ─────────────────────────────────────────────────────
  @observable
  List<ContentStructureItem> contentStructureItems = [];

  @observable
  bool isLoading = false;

  // constructor:---------------------------------------------------------------
  _SeoStore(this.errorStore);

  // actions:-------------------------------------------------------------------
  @action
  Future<void> fetchMockData() async {
    isLoading = true;
    try {
      await Future.delayed(const Duration(milliseconds: 700));

      // ── On-page SEO mock data ──
      onPageSeoItems = [
        SeoCheckItem(
          title: 'Title Tag',
          detail: 'Title is 58 characters — within the 50–60 char sweet spot.',
          status: SeoStatus.pass,
        ),
        SeoCheckItem(
          title: 'Meta Description',
          detail:
              'Meta description is 172 characters. Consider trimming to <160.',
          status: SeoStatus.warn,
        ),
        SeoCheckItem(
          title: 'H1 Tag',
          detail:
              'Page is missing an H1 heading. Add one for better crawlability.',
          status: SeoStatus.fail,
        ),
        SeoCheckItem(
          title: 'Image Alt Text',
          detail: '3 of 7 images are missing alt attributes.',
          status: SeoStatus.warn,
        ),
        SeoCheckItem(
          title: 'Canonical URL',
          detail: 'Canonical tag is present and points to the correct URL.',
          status: SeoStatus.pass,
        ),
        SeoCheckItem(
          title: 'Page Load Speed',
          detail: 'LCP is 1.9 s (Good). Core Web Vitals look healthy.',
          status: SeoStatus.pass,
        ),
        SeoCheckItem(
          title: 'Mobile Friendliness',
          detail: 'Viewport meta tag detected. Page is mobile-responsive.',
          status: SeoStatus.pass,
        ),
        SeoCheckItem(
          title: 'Structured Data',
          detail: 'No schema markup found. Add Article or Product schema.',
          status: SeoStatus.fail,
        ),
      ];

      // ── Topic Clustering mock data ──
      topicClusters = [
        TopicCluster(
          pillarTopic: 'AI Answer Engine Optimization',
          subtopics: [
            'ChatGPT citations',
            'Gemini brand coverage',
            'AI Overview snippets',
            'AEO strategy',
          ],
        ),
        TopicCluster(
          pillarTopic: 'Brand Visibility',
          subtopics: [
            'Visibility score',
            'Brand mentions',
            'Competitor comparison',
            'Sentiment analysis',
          ],
        ),
        TopicCluster(
          pillarTopic: 'Content Marketing',
          subtopics: [
            'Long-form articles',
            'Topic authority',
            'Keyword clustering',
            'Evergreen content',
          ],
        ),
        TopicCluster(
          pillarTopic: 'Technical SEO',
          subtopics: [
            'Core Web Vitals',
            'Crawl budget',
            'XML sitemap',
            'Robots.txt',
          ],
        ),
      ];

      // ── Internal Linking mock data ──
      internalLinkSuggestions = [
        InternalLinkSuggestion(
          sourcePage: '/blog/what-is-aeo',
          targetPage: '/features/brand-monitoring',
          anchorText: 'brand monitoring tools',
          relevanceScore: 94,
        ),
        InternalLinkSuggestion(
          sourcePage: '/blog/seo-vs-aeo',
          targetPage: '/blog/ai-overview-guide',
          anchorText: 'Google AI Overviews',
          relevanceScore: 88,
        ),
        InternalLinkSuggestion(
          sourcePage: '/features/overview',
          targetPage: '/pricing',
          anchorText: 'visibility score plans',
          relevanceScore: 81,
        ),
        InternalLinkSuggestion(
          sourcePage: '/blog/chatgpt-brand-mentions',
          targetPage: '/blog/what-is-aeo',
          anchorText: 'answer engine optimization',
          relevanceScore: 76,
        ),
        InternalLinkSuggestion(
          sourcePage: '/docs/getting-started',
          targetPage: '/features/content-optimization',
          anchorText: 'content optimization guide',
          relevanceScore: 70,
        ),
      ];

      // ── Content Structure mock data ──
      contentStructureItems = [
        ContentStructureItem(
          section: 'Introduction',
          recommendation:
              'Add a concise problem statement in the first 100 words to hook AI readers.',
          priority: StructurePriority.high,
        ),
        ContentStructureItem(
          section: 'Headings Hierarchy',
          recommendation:
              'Use H2 for main sections and H3 for subsections. Avoid skipping levels.',
          priority: StructurePriority.high,
        ),
        ContentStructureItem(
          section: 'FAQ Section',
          recommendation:
              'Add an FAQ block with 5–8 Q&A pairs to increase AI citation probability.',
          priority: StructurePriority.medium,
        ),
        ContentStructureItem(
          section: 'Conclusion',
          recommendation:
              'End with a clear summary paragraph — AI models often extract conclusions for answers.',
          priority: StructurePriority.medium,
        ),
        ContentStructureItem(
          section: 'Key Takeaways',
          recommendation:
              'Add a bulleted "Key Takeaways" box near the top for featured snippet eligibility.',
          priority: StructurePriority.low,
        ),
      ];

      errorStore.setErrorMessage('');
    } catch (error) {
      errorStore.setErrorMessage(error.toString());
    } finally {
      isLoading = false;
    }
  }

  // dispose:-------------------------------------------------------------------
  @action
  dispose() {}
}

// ─── Data Models ─────────────────────────────────────────────────────────────

enum SeoStatus { pass, warn, fail }

class SeoCheckItem {
  final String title;
  final String detail;
  final SeoStatus status;

  SeoCheckItem({
    required this.title,
    required this.detail,
    required this.status,
  });
}

class TopicCluster {
  final String pillarTopic;
  final List<String> subtopics;

  TopicCluster({required this.pillarTopic, required this.subtopics});
}

class InternalLinkSuggestion {
  final String sourcePage;
  final String targetPage;
  final String anchorText;
  final int relevanceScore;

  InternalLinkSuggestion({
    required this.sourcePage,
    required this.targetPage,
    required this.anchorText,
    required this.relevanceScore,
  });
}

enum StructurePriority { high, medium, low }

class ContentStructureItem {
  final String section;
  final String recommendation;
  final StructurePriority priority;

  ContentStructureItem({
    required this.section,
    required this.recommendation,
    required this.priority,
  });
}
