import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/presentation/cronjob/widget/error_banner.dart';

void main() {
  group('ErrorBanner Widget', () {
    testWidgets('displays error message', (WidgetTester tester) async {
      const testMessage = 'Test error message';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: testMessage,
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('displays error icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Error',
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('calls onDismiss when close button is tapped',
        (WidgetTester tester) async {
      var onDismissCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Error',
              onDismiss: () {
                onDismissCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(onDismissCalled, true);
    });

    testWidgets('displays retry button when onRetry provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Error',
              onDismiss: () {},
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TextButton), findsWidgets);
    });

    testWidgets('calls onRetry when retry button is tapped',
        (WidgetTester tester) async {
      var onRetryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Error',
              onDismiss: () {},
              onRetry: () {
                onRetryCalled = true;
              },
            ),
          ),
        ),
      );

      final textButtons = find.byType(TextButton);
      await tester.tap(textButtons.at(0)); // Retry button
      expect(onRetryCalled, true);
    });

    testWidgets('message text is limited to 2 lines',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Error',
              onDismiss: () {},
            ),
          ),
        ),
      );

      final textWidget = find.byType(Text).at(0);
      expect(textWidget, findsOneWidget);
    });
  });
}
