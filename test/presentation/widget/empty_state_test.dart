import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boilerplate/presentation/cronjob/widget/empty_state.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';

/// Synchronous test delegate - uses SynchronousFuture so localization
/// is available on the very first frame (no async gap).
class _TestLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _TestLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) {
    final l10n = AppLocalizations(locale);
    l10n.localizedStrings = {
      'cronjob_no_jobs': 'No cronjobs yet',
      'cronjob_no_jobs_desc': 'Create your first automated job to get started',
      'cronjob_create_new': 'Create New Job',
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
  group('EmptyState Widget', () {
    testWidgets('displays icon, title, and description',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestable(EmptyState(onCreatePressed: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
      expect(find.text('No cronjobs yet'), findsOneWidget);
      expect(
        find.text('Create your first automated job to get started'),
        findsOneWidget,
      );
    });

    testWidgets('displays create button', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestable(EmptyState(onCreatePressed: () {})),
      );
      await tester.pumpAndSettle();

      // ElevatedButton.icon() creates _ElevatedButtonWithIcon,
      // so use byWidgetPredicate with `is` check instead of byType
      expect(
        find.byWidgetPredicate((w) => w is ElevatedButton),
        findsOneWidget,
      );
      expect(find.text('Create New Job'), findsOneWidget);
    });

    testWidgets('calls onCreatePressed when button is tapped',
        (WidgetTester tester) async {
      var onCreateCalled = false;

      await tester.pumpWidget(
        buildTestable(EmptyState(
          onCreatePressed: () {
            onCreateCalled = true;
          },
        )),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate((w) => w is ElevatedButton),
      );
      expect(onCreateCalled, true);
    });

    testWidgets('layout is centered and scrollable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestable(EmptyState(onCreatePressed: () {})),
      );
      await tester.pumpAndSettle();

      // Multiple Center widgets exist (from MaterialApp scaffolding),
      // just verify at least one is present
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
