/// Utility functions for execution history filtering and formatting
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:intl/intl.dart';

/// Enum for execution status filter
enum ExecutionStatusFilter {
  all('all'),
  success('success'),
  failed('failed'),
  partial('partial');

  final String value;
  const ExecutionStatusFilter(this.value);
}

/// Date range preset options
enum DateRangePreset {
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  last30Days('Last 30 Days');

  final String label;
  const DateRangePreset(this.label);
}

/// Get date range based on preset
DateTimeRange getDateRangeForPreset(DateRangePreset preset) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  switch (preset) {
    case DateRangePreset.today:
      return DateTimeRange(
        start: today,
        end: today.add(const Duration(days: 1)),
      );
    case DateRangePreset.thisWeek:
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      return DateTimeRange(
        start: weekStart,
        end: today.add(const Duration(days: 1)),
      );
    case DateRangePreset.thisMonth:
      final monthStart = DateTime(now.year, now.month, 1);
      return DateTimeRange(
        start: monthStart,
        end: today.add(const Duration(days: 1)),
      );
    case DateRangePreset.last30Days:
      return DateTimeRange(
        start: today.subtract(const Duration(days: 30)),
        end: today.add(const Duration(days: 1)),
      );
  }
}

/// Format DateTime for display in history list
String formatExecutionTime(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final executionDate = DateTime(
    dateTime.year,
    dateTime.month,
    dateTime.day,
  );

  final timeFormat = DateFormat('h:mma').format(dateTime);

  if (executionDate == today) {
    return 'Today $timeFormat';
  } else if (executionDate == yesterday) {
    return 'Yesterday $timeFormat';
  } else {
    final dateFormat = DateFormat('MMM d, yyyy').format(dateTime);
    return '$dateFormat $timeFormat';
  }
}

/// Format DateTime for display in details view
String formatExecutionDateTime(DateTime dateTime) {
  return DateFormat('MMMM d, yyyy h:mma').format(dateTime);
}

/// Get color for execution status
int getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'success':
      return 0xFF4CAF50; // Green
    case 'failed':
      return 0xFFF44336; // Red
    case 'partial':
      return 0xFFFF9800; // Orange
    default:
      return 0xFF9E9E9E; // Grey
  }
}

/// Get icon symbol for status
String getStatusSymbol(String status) {
  switch (status.toLowerCase()) {
    case 'success':
      return '✓';
    case 'failed':
      return '✕';
    case 'partial':
      return '◐';
    default:
      return '?';
  }
}

/// Get status label text
String getStatusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'success':
      return 'Success';
    case 'failed':
      return 'Failed';
    case 'partial':
      return 'Partial';
    default:
      return 'Unknown';
  }
}

/// Format article metadata
String formatArticleStats(int wordCount, int paragraphCount) {
  return '$wordCount words • $paragraphCount paragraphs';
}

/// Format destination count
String formatDestinationCount(int total, int successful) {
  if (total == successful) {
    return '$total destinations';
  } else {
    return '$successful/$total destinations';
  }
}

/// Validate date range (start before end, not too far back, not in future)
bool isValidDateRange(DateTimeRange range) {
  final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
  final tomorrow = DateTime.now().add(const Duration(days: 1));

  return range.start.isBefore(range.end) &&
      range.start.isAfter(oneYearAgo) &&
      range.end.isBefore(tomorrow);
}

/// Class to hold filter state
/// Note: Uses Flutter's DateTimeRange from material.dart
class ExecutionFilter {
  final DateTime startDate;
  final DateTime endDate;
  final ExecutionStatusFilter statusFilter;

  ExecutionFilter({
    required this.startDate,
    required this.endDate,
    this.statusFilter = ExecutionStatusFilter.all,
  });

  ExecutionFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    ExecutionStatusFilter? statusFilter,
  }) {
    return ExecutionFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExecutionFilter &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          statusFilter == other.statusFilter;

  @override
  int get hashCode =>
      startDate.hashCode ^ endDate.hashCode ^ statusFilter.hashCode;
}
