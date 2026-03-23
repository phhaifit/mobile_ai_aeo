import 'package:flutter/material.dart';
import '../util/history_utils.dart';

/// Mock GeneratedArticle model for widget testing
/// In real app, use actual entity from data layer
class MockGeneratedArticle {
  final String id;
  final String title;
  final String content;
  final int wordCount;
  final int paragraphCount;

  MockGeneratedArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.wordCount,
    required this.paragraphCount,
  });
}

/// Card widget for displaying article preview
/// 
/// Shows article title, word count, paragraph count, and view action
class ArticlePreviewCard extends StatelessWidget {
  final MockGeneratedArticle article;
  final VoidCallback onViewFull;

  const ArticlePreviewCard({
    Key? key,
    required this.article,
    required this.onViewFull,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Stats
            Text(
              formatArticleStats(article.wordCount, article.paragraphCount),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            // View Full Button
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onViewFull,
                icon: const Icon(Icons.open_in_new),
                label: const Text('View Full Article'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
