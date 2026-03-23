import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/presentation/cronjob/history/widget/execution_status_badge.dart';

void main() {
  group('ExecutionStatusBadge', () {
    testWidgets('displays success status with green color and checkmark',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExecutionStatusBadge(status: 'success'),
          ),
        ),
      );

      expect(find.text('✓'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('displays failed status with red color and X mark',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExecutionStatusBadge(status: 'failed'),
          ),
        ),
      );

      expect(find.text('✕'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('displays partial status with orange color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExecutionStatusBadge(status: 'partial'),
          ),
        ),
      );

      expect(find.text('◐'), findsOneWidget);
      expect(find.text('Partial'), findsOneWidget);
    });

    testWidgets('applies custom fontSize', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExecutionStatusBadge(
              status: 'success',
              fontSize: 18,
            ),
          ),
        ),
      );

      expect(find.byType(ExecutionStatusBadge), findsOneWidget);
    });

    testWidgets('applies custom padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExecutionStatusBadge(
              status: 'success',
              padding: EdgeInsets.all(20),
            ),
          ),
        ),
      );

      expect(find.byType(ExecutionStatusBadge), findsOneWidget);
    });

    testWidgets('handles unknown status gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExecutionStatusBadge(status: 'unknown'),
          ),
        ),
      );

      expect(find.byType(ExecutionStatusBadge), findsOneWidget);
    });
  });
}
