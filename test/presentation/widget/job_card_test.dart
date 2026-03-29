import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';
import 'package:boilerplate/domain/entity/cronjob/schedule.dart';
import 'package:boilerplate/domain/entity/cronjob/source_type.dart';
import 'package:boilerplate/presentation/cronjob/widget/job_card.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';

/// Synchronous test delegate - uses SynchronousFuture so localization
/// is available on the very first frame.
class _TestLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _TestLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) {
    final l10n = AppLocalizations(locale);
    l10n.localizedStrings = {
      'cronjob_last_execution': 'Last Execution',
      'cronjob_enabled': 'Enabled',
      'cronjob_disabled': 'Disabled',
    };
    return SynchronousFuture(l10n);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

Widget buildTestable(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      _TestLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  );
}

void main() {
  group('JobCard Widget', () {
    late Cronjob testJob;

    setUp(() {
      testJob = Cronjob(
        id: 'test-job-1',
        name: 'Test Job',
        description: 'Test Description',
        schedule: Schedule.daily,
        schedulePattern: '0 9 * * *',
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
        buildTestable(JobCard(
          job: testJob,
          onEdit: () {},
          onDelete: () {},
          onTest: () {},
          onTap: () {},
        )),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Job'), findsOneWidget);
    });

    testWidgets('displays enabled status', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestable(JobCard(
          job: testJob,
          onEdit: () {},
          onDelete: () {},
          onTest: () {},
          onTap: () {},
        )),
      );
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE'), findsWidgets);
    });

    testWidgets('displays job description', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestable(JobCard(
          job: testJob,
          onEdit: () {},
          onDelete: () {},
          onTest: () {},
          onTap: () {},
        )),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('displays last run info', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestable(JobCard(
          job: testJob,
          onEdit: () {},
          onDelete: () {},
          onTest: () {},
          onTap: () {},
        )),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('LAST RUN'), findsOneWidget);
    });

    testWidgets('displays disabled status when disabled',
        (WidgetTester tester) async {
      testJob.isEnabled = false;

      await tester.pumpWidget(
        buildTestable(JobCard(
          job: testJob,
          onEdit: () {},
          onDelete: () {},
          onTest: () {},
          onTap: () {},
        )),
      );
      await tester.pumpAndSettle();

      expect(find.text('INACTIVE'), findsOneWidget);
    });

    testWidgets('calls onTest when configure button is tapped',
        (WidgetTester tester) async {
      var onTestCalled = false;

      await tester.pumpWidget(
        buildTestable(JobCard(
          job: testJob,
          onEdit: () {},
          onDelete: () {},
          onTest: () {
            onTestCalled = true;
          },
          onTap: () {},
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('CONFIGURE'));
      expect(onTestCalled, true);
    });

    testWidgets('card layout is responsive', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestable(JobCard(
          job: testJob,
          onEdit: () {},
          onDelete: () {},
          onTest: () {},
          onTap: () {},
        )),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
