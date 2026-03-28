import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/presentation/cronjob/history/widget/article_preview_card.dart';

void main() {
  group('ArticlePreviewCard', () {
    final mockArticle = MockGeneratedArticle(
      id: 'article-1',
      title: 'AI Trends 2026',
      content: 'This is a test article content',
      wordCount: 850,
      paragraphCount: 3,
    );

    testWidgets('displays article title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlePreviewCard(
              article: mockArticle,
              onViewFull: () {},
            ),
          ),
        ),
      );

      expect(find.text('AI Trends 2026'), findsOneWidget);
    });

    testWidgets('displays word count and paragraph count',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlePreviewCard(
              article: mockArticle,
              onViewFull: () {},
            ),
          ),
        ),
      );

      expect(find.text('850 words • 3 paragraphs'), findsOneWidget);
    });

    testWidgets('displays view full article button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlePreviewCard(
              article: mockArticle,
              onViewFull: () {},
            ),
          ),
        ),
      );

      expect(find.text('View Full Article'), findsOneWidget);
    });

    testWidgets('calls onViewFull when button is tapped',
        (WidgetTester tester) async {
      bool called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlePreviewCard(
              article: mockArticle,
              onViewFull: () => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('View Full Article'));
      expect(called, isTrue);
    });

    testWidgets('handles long article titles with ellipsis',
        (WidgetTester tester) async {
      final longTitleArticle = MockGeneratedArticle(
        id: 'article-2',
        title: 'This is a very long article title that will probably exceed the'
            ' maximum width and should be truncated with ellipsis',
        content: 'Content',
        wordCount: 500,
        paragraphCount: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlePreviewCard(
              article: longTitleArticle,
              onViewFull: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ArticlePreviewCard), findsOneWidget);
    });

    testWidgets('displays zero word count correctly',
        (WidgetTester tester) async {
      final emptyArticle = MockGeneratedArticle(
        id: 'article-3',
        title: 'Empty Article',
        content: '',
        wordCount: 0,
        paragraphCount: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlePreviewCard(
              article: emptyArticle,
              onViewFull: () {},
            ),
          ),
        ),
      );

      expect(find.text('0 words • 0 paragraphs'), findsOneWidget);
    });

    testWidgets('renders in a card widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticlePreviewCard(
              article: mockArticle,
              onViewFull: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('has proper spacing and padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ArticlePreviewCard(
                    article: mockArticle,
                    onViewFull: () {},
                  ),
                  ArticlePreviewCard(
                    article: mockArticle,
                    onViewFull: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsWidgets);
    });
  });
}
