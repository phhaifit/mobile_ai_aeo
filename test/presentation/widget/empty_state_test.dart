import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/presentation/cronjob/widget/empty_state.dart';

void main() {
  group('EmptyState Widget', () {
    testWidgets('displays icon, title, and description',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              onCreatePressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
      expect(find.text('No Cronjobs Yet'), findsOneWidget);
      expect(
        find.text('Create your first cronjob to automate publishing'),
        findsOneWidget,
      );
    });

    testWidgets('displays create button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              onCreatePressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Create Cronjob'), findsOneWidget);
    });

    testWidgets('calls onCreatePressed when button is tapped',
        (WidgetTester tester) async {
      var onCreateCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              onCreatePressed: () {
                onCreateCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(onCreateCalled, true);
    });

    testWidgets('layout is centered and scrollable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              onCreatePressed: () {},
            ),
          ),
        ),
      );

      final centerWidget = find.byType(Center);
      expect(centerWidget, findsOneWidget);

      final singleChildScrollView =
          find.byType(SingleChildScrollView);
      expect(singleChildScrollView, findsOneWidget);
    });
  });
}
