class RetrievedPage {
  final String url;
  final String title;

  RetrievedPage({
    required this.url,
    required this.title,
  });

  factory RetrievedPage.fromJson(Map<String, dynamic> json) {
    return RetrievedPage(
      url: json['url'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }
}

class ContentGenerationResult {
  final String id;
  final String? topicId;
  final String? profileId;
  final String? promptId;
  final List<String> targetKeywords;
  final List<RetrievedPage> retrievedPages;
  final List<dynamic> contentInsight;
  final String completionStatus;
  final String contentType;
  final String? contentFormat;
  final String body;
  final String? title;
  final String? slug;
  final String? createdAt;

  ContentGenerationResult({
    required this.id,
    this.topicId,
    this.profileId,
    this.promptId,
    required this.targetKeywords,
    required this.retrievedPages,
    required this.contentInsight,
    required this.completionStatus,
    required this.contentType,
    this.contentFormat,
    required this.body,
    this.title,
    this.slug,
    this.createdAt,
  });

  factory ContentGenerationResult.fromJson(Map<String, dynamic> json) {
    final kw = json['targetKeywords'];
    final pages = json['retrievedPages'];
    return ContentGenerationResult(
      id: json['id'] as String? ?? '',
      topicId: json['topicId'] as String?,
      profileId: json['profileId'] as String?,
      promptId: json['promptId'] as String?,
      targetKeywords: kw is List
          ? kw.map((e) => e.toString()).toList()
          : <String>[],
      retrievedPages: pages is List
          ? pages
              .whereType<Map<String, dynamic>>()
              .map(RetrievedPage.fromJson)
              .toList()
          : <RetrievedPage>[],
      contentInsight: json['contentInsight'] is List
          ? List<dynamic>.from(json['contentInsight'] as List)
          : <dynamic>[],
      completionStatus: json['completionStatus'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      contentFormat: json['contentFormat'] as String?,
      body: json['body'] as String? ?? '',
      title: json['title'] as String?,
      slug: json['slug'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
