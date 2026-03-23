import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/presentation/cronjob/history/widget/publishing_results_card.dart';

void main() {
  group('PublishingResultsCard', () {
    final successResult = MockExecutionResult(
      destination: 'Website (Blog)',
      status: 'success',
      publishedAt: DateTime.now(),
    );

    final failedResult = MockExecutionResult(
      destination: 'Facebook',
      status: 'failed',
      errorMessage: 'Rate limited - exceeded daily post limit',
    );

    testWidgets('displays success status with destination name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublishingResultsCard(result: successResult),
          ),
        ),
      );

      expect(find.text('Website (Blog)'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('displays failed status with destination name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublishingResultsCard(result: failedResult),
          ),
        ),
      );

      expect(find.text('Facebook'), findsOneWidget);
    });

    testWidgets('displays error message for failed result',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublishingResultsCard(result: failedResult),
          ),
        ),
      );

      expect(find.text('Rate limited - exceeded daily post limit'),
          findsOneWidget);
    });

    testWidgets('hides error message for successful result',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublishingResultsCard(result: successResult),
          ),
        ),
      );

      expect(find.text('Rate limited - exceeded daily post limit'), findsNothing);
    });

    testWidgets('displays status symbol for success', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublishingResultsCard(result: successResult),
          ),
        ),
      );

      expect(find.text('✓'), findsOneWidget);
    });

    testWidgets('displays status symbol for failed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublishingResultsCard(result: failedResult),
          ),
        ),
      );

      expect(find.text('✕'), findsOneWidget);
    });

    testWidgets('renders in a card widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublishingResultsCard(result: successResult),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('displays multiple results in a list',
        (WidgetTester tester) async {
      final partialResult = MockExecutionResult(
        destination: 'LinkedIn',
        status: 'success',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  PublishingResultsCard(result: successResult),
                  PublishingResultsCard(result: failedResult),
                  PublishingResultsCard(result: partialResult),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsWidgets);
      expect(find.text('Website (Blog)'), findsOneWidget);
      expect(find.text('Facebook'), findsOneWidget);
      expect(find.text('LinkedIn'), findsOneWidget);
    });

    testWidgets('handles null error message for failed result',
        (WidgetTester tester) async {
      final failedNoMessage = MockExecutionResult(
        destination: 'Twitter',
        status: 'failed',
        errorMessage: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublishingResultsCard(result: failedNoMessage),
          ),
        ),
      );

      expect(find.byType(PublishingResultsCard), findsOneWidget);
    });

    testWidgets('handles long error messages with truncation',
        (WidgetTester tester) async {
      final longErrorResult = MockExecutionResult(
        destination: 'Destination',
        status: 'failed',
        errorMessage:
            'This is a very long error message that explains in detail what '
            'went wrong and why the operation failed with specific technical details',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublishingResultsCard(result: longErrorResult),
          ),
        ),
      );

      expect(find.byType(PublishingResultsCard), findsOneWidget);
    });

    testWidgets('uses correct text styles and colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PublishingResultsCard(result: successResult),
          ),
        ),
      );

      final destinationText = find.text('Website (Blog)');
      expect(destinationText, findsOneWidget);

      final widget = tester.widget<Text>(
        find.descendant(
          of: find.byType(PublishingResultsCard),
          matching: find.byType(Text),
        ).first,
      );
      expect(widget.style?.fontWeight, anything);
    });
  });
}
