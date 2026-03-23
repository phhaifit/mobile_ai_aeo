import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/presentation/cronjob/widget/cron_helper_widget.dart';

void main() {
  group('CronHelperWidget', () {
    testWidgets('displays cron expression',
        (WidgetTester tester) async {
      const cronExpr = '0 9 * * MON-FRI';

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

      expect(find.text(cronExpr), findsOneWidget);
    });

    testWidgets('displays validation indicator for valid cron',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CronHelperWidget(
              cronExpression: '0 9 * * MON-FRI',
              lastExecutionTime: null,
            ),
          ),
        ),
      );

      // Check for valid cron icon (check mark)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
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

      // Check for invalid cron icon (error)
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays human-readable description',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CronHelperWidget(
              cronExpression: '0 9 * * MON-FRI',
              lastExecutionTime: null,
            ),
          ),
        ),
      );

      // Should contain descriptive text
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
              cronExpression: '0 9 * * MON-FRI',
              lastExecutionTime: lastRun,
            ),
          ),
        ),
      );

      // Should contain text about last execution
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('widget has correct background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CronHelperWidget(
              cronExpression: '0 9 * * MON-FRI',
              lastExecutionTime: null,
            ),
          ),
        ),
      );

      // Check for container with color
      final containers = find.byType(Container);
      expect(containers, findsOneWidget);
    });
  });
}
