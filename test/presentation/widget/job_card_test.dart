import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';
import 'package:boilerplate/domain/entity/cronjob/schedule.dart';
import 'package:boilerplate/domain/entity/cronjob/source_type.dart';
import 'package:boilerplate/presentation/cronjob/widget/job_card.dart';

void main() {
  group('JobCard Widget', () {
    late Cronjob testJob;

    setUp(() {
      testJob = Cronjob(
        id: 'test-job-1',
        name: 'Test Job',
        description: 'Test Description',
        schedule: Schedule.daily,
        schedulePattern: '0 9 * * MON-FRI',
        sourceType: SourceType.promptLibrary,
        articleCountPerRun: 5,
        destinations: [PublishingDestination.website],
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('displays job name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobCard(
              job: testJob,
              onEdit: () {},
              onDelete: () {},
              onTest: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Job'), findsOneWidget);
    });

    testWidgets('displays enabled status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobCard(
              job: testJob,
              onEdit: () {},
              onDelete: () {},
              onTest: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('✓ Enabled'), findsOneWidget);
    });

    testWidgets('displays article count',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobCard(
              job: testJob,
              onEdit: () {},
              onDelete: () {},
              onTest: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('5 articles per run'), findsOneWidget);
    });

    testWidgets('displays destination count',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobCard(
              job: testJob,
              onEdit: () {},
              onDelete: () {},
              onTest: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('1 destination'), findsOneWidget);
    });

    testWidgets('displays disabled status when disabled',
        (WidgetTester tester) async {
      final disabledJob = testJob;
      disabledJob.isEnabled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobCard(
              job: disabledJob,
              onEdit: () {},
              onDelete: () {},
              onTest: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('✗ Disabled'), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped',
        (WidgetTester tester) async {
      var onTapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobCard(
              job: testJob,
              onEdit: () {},
              onDelete: () {},
              onTest: () {},
              onTap: () {
                onTapCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      expect(onTapCalled, true);
    });

    testWidgets('card layout is responsive',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobCard(
              job: testJob,
              onEdit: () {},
              onDelete: () {},
              onTest: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
