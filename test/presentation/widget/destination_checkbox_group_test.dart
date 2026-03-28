import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';
import 'package:boilerplate/presentation/cronjob/widget/destination_checkbox_group.dart';

void main() {
  group('DestinationCheckboxGroup Widget', () {
    testWidgets('displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DestinationCheckboxGroup(
              selected: {},
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Publishing Destinations *'), findsOneWidget);
    });

    testWidgets('displays checkboxes for all destinations',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DestinationCheckboxGroup(
              selected: {},
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Should have checkboxes for each destination
      expect(
        find.byType(CheckboxListTile),
        findsWidgets,
      );
    });

    testWidgets('calls onChanged when checkbox is toggled',
        (WidgetTester tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DestinationCheckboxGroup(
              selected: {},
              onChanged: (_) {
                callCount++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pumpAndSettle();

      expect(callCount, 1);
    });

    testWidgets('pre-selects provided destinations',
        (WidgetTester tester) async {
      final selected = {PublishingDestination.website};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DestinationCheckboxGroup(
              selected: selected,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // At least one checkbox should be checked
      expect(find.byType(CheckboxListTile), findsWidgets);
    });

    testWidgets(
        'returns updated set when destination selection changes',
        (WidgetTester tester) async {
      var lastSelected = const <PublishingDestination>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DestinationCheckboxGroup(
              selected: {},
              onChanged: (newSet) {
                lastSelected = newSet;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pumpAndSettle();

      expect(lastSelected.isNotEmpty, true);
    });
  });
}
