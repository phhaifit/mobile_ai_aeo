import '../../domain/entity/seo/seo_check_item.dart';
import '../../domain/entity/seo/topic_cluster.dart';
import '../../domain/entity/seo/internal_link_suggestion.dart';
import '../../domain/entity/seo/content_structure_item.dart';
import '../../domain/entity/seo/seo_data.dart';

class SeoSeedData {
  static SeoData getSampleSeoData() {
    return SeoData(
      onPageSeoItems: _getOnPageSeoItems(),
      topicClusters: _getTopicClusters(),
      internalLinkSuggestions: _getInternalLinkSuggestions(),
      contentStructureItems: _getContentStructureItems(),
    );
  }

  static List<SeoCheckItem> _getOnPageSeoItems() {
    return [
      SeoCheckItem(
        title: 'Title Tag',
        detail: 'Title is 58 characters — within the 50–60 char sweet spot.',
        status: SeoStatus.pass,
      ),
      SeoCheckItem(
        title: 'Meta Description',
        detail: 'Meta description is 172 characters. Consider trimming to <160.',
        status: SeoStatus.warn,
      ),
      SeoCheckItem(
        title: 'H1 Tag',
        detail: 'Page is missing an H1 heading. Add one for better crawlability.',
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
  }

  static List<TopicCluster> _getTopicClusters() {
    return [
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
  }

  static List<InternalLinkSuggestion> _getInternalLinkSuggestions() {
    return [
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
  }

  static List<ContentStructureItem> _getContentStructureItems() {
    return [
      ContentStructureItem(
        section: 'Introduction',
        recommendation: 'Add a concise problem statement in the first 100 words to hook AI readers.',
        priority: StructurePriority.high,
      ),
      ContentStructureItem(
        section: 'Headings Hierarchy',
        recommendation: 'Use H2 for main sections and H3 for subsections. Avoid skipping levels.',
        priority: StructurePriority.high,
      ),
      ContentStructureItem(
        section: 'FAQ Section',
        recommendation: 'Add an FAQ block with 5–8 Q&A pairs to increase AI citation probability.',
        priority: StructurePriority.medium,
      ),
      ContentStructureItem(
        section: 'Conclusion',
        recommendation: 'End with a clear summary paragraph — AI models often extract conclusions for answers.',
        priority: StructurePriority.medium,
      ),
      ContentStructureItem(
        section: 'Key Takeaways',
        recommendation: 'Add a bulleted "Key Takeaways" box near the top for featured snippet eligibility.',
        priority: StructurePriority.low,
      ),
    ];
  }
}
