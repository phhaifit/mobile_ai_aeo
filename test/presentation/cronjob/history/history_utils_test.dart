import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/presentation/cronjob/history/util/history_utils.dart';

void main() {
  group('History Utilities', () {
    group('getDateRangeForPreset', () {
      test('returns today range for Today preset', () {
        final result = getDateRangeForPreset(DateRangePreset.today);
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        expect(result.start, todayDate);
        expect(result.end, todayDate.add(const Duration(days: 1)));
      });

      test('returns this week range for ThisWeek preset', () {
        final result = getDateRangeForPreset(DateRangePreset.thisWeek);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final weekStart = today.subtract(Duration(days: today.weekday - 1));

        expect(result.start, weekStart);
        expect(result.end.day >= today.day, isTrue);
      });

      test('returns this month range for ThisMonth preset', () {
        final result = getDateRangeForPreset(DateRangePreset.thisMonth);
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);

        expect(result.start, monthStart);
      });

      test('returns last 30 days range', () {
        final result = getDateRangeForPreset(DateRangePreset.last30Days);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final expected = today.subtract(const Duration(days: 30));

        expect(result.start.day, expected.day);
      });
    });

    group('formatExecutionTime', () {
      test('formats today as "Today HH:mma"', () {
        final now = DateTime.now();
        final result = formatExecutionTime(now);

        expect(result.contains('Today'), isTrue);
      });

      test('formats yesterday as "Yesterday HH:mma"', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = formatExecutionTime(yesterday);

        expect(result.contains('Yesterday'), isTrue);
      });

      test('formats older dates as "MMM d, yyyy HH:mma"', () {
        final oldDate = DateTime(2026, 1, 15, 10, 30);
        final result = formatExecutionTime(oldDate);

        expect(result.contains('Jan') || result.contains('January'), isTrue);
        expect(result.contains('2026'), isTrue);
      });
    });

    group('formatExecutionDateTime', () {
      test('returns formatted datetime string', () {
        final dateTime = DateTime(2026, 3, 22, 14, 30);
        final result = formatExecutionDateTime(dateTime);

        expect(result.contains('2026'), isTrue);
        expect(result.contains('22'), isTrue);
      });
    });

    group('getStatusColor', () {
      test('returns green for success', () {
        final color = getStatusColor('success');
        expect(color, 0xFF4CAF50);
      });

      test('returns red for failed', () {
        final color = getStatusColor('failed');
        expect(color, 0xFFF44336);
      });

      test('returns orange for partial', () {
        final color = getStatusColor('partial');
        expect(color, 0xFFFF9800);
      });

      test('returns grey for unknown status', () {
        final color = getStatusColor('unknown');
        expect(color, 0xFF9E9E9E);
      });

      test('is case insensitive', () {
        expect(getStatusColor('SUCCESS'), 0xFF4CAF50);
        expect(getStatusColor('FAILED'), 0xFFF44336);
      });
    });

    group('getStatusSymbol', () {
      test('returns checkmark for success', () {
        expect(getStatusSymbol('success'), '✓');
      });

      test('returns X mark for failed', () {
        expect(getStatusSymbol('failed'), '✕');
      });

      test('returns semicircle for partial', () {
        expect(getStatusSymbol('partial'), '◐');
      });

      test('returns question mark for unknown', () {
        expect(getStatusSymbol('unknown'), '?');
      });
    });

    group('getStatusLabel', () {
      test('returns Success for success', () {
        expect(getStatusLabel('success'), 'Success');
      });

      test('returns Failed for failed', () {
        expect(getStatusLabel('failed'), 'Failed');
      });

      test('returns Partial for partial', () {
        expect(getStatusLabel('partial'), 'Partial');
      });

      test('returns Unknown for unknown status', () {
        expect(getStatusLabel('unknown'), 'Unknown');
      });
    });

    group('formatArticleStats', () {
      test('formats word and paragraph count correctly', () {
        final result = formatArticleStats(850, 3);
        expect(result, '850 words • 3 paragraphs');
      });

      test('handles zero values', () {
        final result = formatArticleStats(0, 0);
        expect(result, '0 words • 0 paragraphs');
      });

      test('handles large numbers', () {
        final result = formatArticleStats(10000, 100);
        expect(result, '10000 words • 100 paragraphs');
      });
    });

    group('formatDestinationCount', () {
      test('formats full success count', () {
        final result = formatDestinationCount(3, 3);
        expect(result, '3 destinations');
      });

      test('formats partial success count', () {
        final result = formatDestinationCount(3, 2);
        expect(result, '2/3 destinations');
      });

      test('formats complete failure', () {
        final result = formatDestinationCount(3, 0);
        expect(result, '0/3 destinations');
      });

      test('formats single destination', () {
        final result = formatDestinationCount(1, 1);
        expect(result, '1 destinations');
      });
    });

    group('isValidDateRange', () {
      test('returns true for valid recent range', () {
        final range = DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 10)),
          end: DateTime.now(),
        );
        expect(isValidDateRange(range), isTrue);
      });

      test('returns false when start is after end', () {
        try {
          final range = DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().subtract(const Duration(days: 10)),
          );
          expect(isValidDateRange(range), isFalse);
        } catch (e) {
          // DateTimeRange constructor validates this - that's OK
          expect(e, isA<AssertionError>());
        }
      });

      test('returns false when start is more than 1 year ago', () {
        final range = DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 400)),
          end: DateTime.now(),
        );
        expect(isValidDateRange(range), isFalse);
      });

      test('returns false when end is in the future', () {
        final range = DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 10)),
          end: DateTime.now().add(const Duration(days: 2)),
        );
        expect(isValidDateRange(range), isFalse);
      });
    });

    group('ExecutionFilter', () {
      test('creates with default status filter', () {
        final filter = ExecutionFilter(
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        );

        expect(filter.statusFilter, ExecutionStatusFilter.all);
      });

      test('copyWith creates new instance with updated values', () {
        final original = ExecutionFilter(
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 31),
        );

        final updated = original.copyWith(
          statusFilter: ExecutionStatusFilter.success,
        );

        expect(updated.statusFilter, ExecutionStatusFilter.success);
        expect(updated.startDate, original.startDate);
      });

      test('equals operator works correctly', () {
        final filter1 = ExecutionFilter(
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 31),
        );

        final filter2 = ExecutionFilter(
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 31),
        );

        expect(filter1, filter2);
      });

      test('hashCode is consistent', () {
        final filter = ExecutionFilter(
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 31),
        );

        expect(filter.hashCode, filter.hashCode);
      });
    });
  });
}
