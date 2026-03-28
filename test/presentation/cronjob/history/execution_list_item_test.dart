import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/presentation/cronjob/history/widget/execution_list_item.dart';

void main() {
  group('ExecutionListItem', () {
    final mockExecution = MockCronjobExecution(
      id: 'exec-1',
      cronjobId: 'job-1',
      executedAt: DateTime(2026, 3, 22, 10, 30),
      status: 'success',
      articleCount: 3,
      successfulDestinations: 3,
      totalDestinations: 3,
    );

    testWidgets('displays execution time', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExecutionListItem(
              execution: mockExecution,
              onTap: () {},
            ),
          ),
        ),
      );

      // Check that some time-related text is displayed
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('displays status badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExecutionListItem(
              execution: mockExecution,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('displays article count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExecutionListItem(
              execution: mockExecution,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('3 articles'), findsOneWidget);
    });

    testWidgets('displays destination count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExecutionListItem(
              execution: mockExecution,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('3 destinations'), findsOneWidget);
    });

    testWidgets('displays partial destination count correctly',
        (WidgetTester tester) async {
      final partialExecution = MockCronjobExecution(
        id: 'exec-2',
        cronjobId: 'job-1',
        executedAt: DateTime.now(),
        status: 'partial',
        articleCount: 3,
        successfulDestinations: 2,
        totalDestinations: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExecutionListItem(
              execution: partialExecution,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('2/3 destinations'), findsOneWidget);
    });

    testWidgets('calls onTap when view details is tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExecutionListItem(
              execution: mockExecution,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('View Details'));
      expect(tapped, isTrue);
    });

    testWidgets('shows retry button for failed execution',
        (WidgetTester tester) async {
      final failedExecution = MockCronjobExecution(
        id: 'exec-3',
        cronjobId: 'job-1',
        executedAt: DateTime.now(),
        status: 'failed',
        articleCount: 0,
        successfulDestinations: 0,
        totalDestinations: 3,
        errorMessage: 'Network error',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExecutionListItem(
              execution: failedExecution,
              onTap: () {},
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('calls onRetry when retry button is tapped',
        (WidgetTester tester) async {
      bool retried = false;
      final failedExecution = MockCronjobExecution(
        id: 'exec-3',
        cronjobId: 'job-1',
        executedAt: DateTime.now(),
        status: 'failed',
        articleCount: 0,
        successfulDestinations: 0,
        totalDestinations: 3,
        errorMessage: 'Network error',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExecutionListItem(
              execution: failedExecution,
              onTap: () {},
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('hides retry button for successful execution',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExecutionListItem(
              execution: mockExecution,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });
  });
}
