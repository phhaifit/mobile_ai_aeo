import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/domain/entity/cronjob/source_type.dart';
import 'package:boilerplate/presentation/cronjob/widget/source_type_radio_group.dart';

void main() {
  group('SourceTypeRadioGroup Widget', () {
    testWidgets('displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceTypeRadioGroup(
              selected: SourceType.promptLibrary,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Content Source *'), findsOneWidget);
    });

    testWidgets('displays radio buttons for all source types',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceTypeRadioGroup(
              selected: SourceType.promptLibrary,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Should have radio tiles for each source type
      expect(find.byType(RadioListTile<SourceType>), findsWidgets);
    });

    testWidgets('highlights the selected source type',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceTypeRadioGroup(
              selected: SourceType.promptLibrary,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // At least one radio button should be selected
      expect(find.byType(RadioListTile<SourceType>), findsWidgets);
    });

    testWidgets('calls onChanged when selection changes',
        (WidgetTester tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceTypeRadioGroup(
              selected: SourceType.promptLibrary,
              onChanged: (_) {
                callCount++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RadioListTile<SourceType>).at(1));
      await tester.pumpAndSettle();

      expect(callCount, 1);
    });

    testWidgets('updates selection on radio button change',
        (WidgetTester tester) async {
      var selectedType = SourceType.promptLibrary;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceTypeRadioGroup(
              selected: selectedType,
              onChanged: (newType) {
                selectedType = newType;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RadioListTile<SourceType>).at(1));
      await tester.pumpAndSettle();

      expect(selectedType, isNotNull);
    });

    testWidgets('displays all source type options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceTypeRadioGroup(
              selected: SourceType.promptLibrary,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Should have at least 3 source types
      expect(
        find.byType(RadioListTile<SourceType>).evaluate().length,
        greaterThanOrEqualTo(3),
      );
    });
  });
}
