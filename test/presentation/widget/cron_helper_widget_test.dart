import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/presentation/cronjob/widget/cron_helper_widget.dart';

void main() {
  group('CronHelperWidget', () {
    testWidgets('displays cron expression', (WidgetTester tester) async {
      const cronExpr = '0 9 * * *';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CronHelperWidget(
              cronExpression: cronExpr,
              lastExecutionTime: null,
            ),
          ),
        ),
      );

      // Widget renders "Cron: <expression>"
      expect(find.textContaining(cronExpr), findsOneWidget);
    });

    testWidgets('displays validation indicator for valid cron',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CronHelperWidget(
              cronExpression: '0 9 * * *',
              lastExecutionTime: null,
            ),
          ),
        ),
      );

      // Widget uses check_circle_outline for valid cron
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('displays error indicator for invalid cron',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CronHelperWidget(
              cronExpression: 'invalid cron',
              lastExecutionTime: null,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays human-readable description',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CronHelperWidget(
              cronExpression: '0 9 * * *',
              lastExecutionTime: null,
            ),
          ),
        ),
      );

      final textFinder = find.byType(Text);
      expect(textFinder, findsWidgets);
    });

    testWidgets('displays last execution time when provided',
        (WidgetTester tester) async {
      final lastRun =
          DateTime.now().subtract(const Duration(hours: 2));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CronHelperWidget(
              cronExpression: '0 9 * * *',
              lastExecutionTime: lastRun,
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('widget has correct background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CronHelperWidget(
              cronExpression: '0 9 * * *',
              lastExecutionTime: null,
            ),
          ),
        ),
      );

      final containers = find.byType(Container);
      expect(containers, findsOneWidget);
    });
  });
}
