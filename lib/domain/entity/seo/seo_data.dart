import 'seo_check_item.dart';
import 'topic_cluster.dart';
import 'internal_link_suggestion.dart';
import 'content_structure_item.dart';

class SeoData {
  final List<SeoCheckItem> onPageSeoItems;
  final List<TopicCluster> topicClusters;
  final List<InternalLinkSuggestion> internalLinkSuggestions;
  final List<ContentStructureItem> contentStructureItems;

  SeoData({
    required this.onPageSeoItems,
    required this.topicClusters,
    required this.internalLinkSuggestions,
    required this.contentStructureItems,
  });
}
