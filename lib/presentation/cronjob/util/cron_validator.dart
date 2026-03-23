/// Cron expression validator and parser
/// 
/// Validates cron expressions in both 5-field and 6-field formats:
/// - 5-field: minute hour day month dayofweek
/// - 6-field: second minute hour day month dayofweek

class CronValidator {
  // Prevent instantiation
  CronValidator._();

  /// Validates a cron expression
  /// 
  /// Returns true if the expression is valid, false otherwise
  static bool isValid(String? expression) {
    if (expression == null || expression.isEmpty) return false;

    final fields = expression.trim().split(RegExp(r'\s+'));

    // Check if 5 or 6 fields
    if (fields.length != 5 && fields.length != 6) return false;

    // Determine field start index (skip seconds if 6-field format)
    int startIndex = fields.length == 6 ? 1 : 0;

    // Validate minute (index 0 or 1)
    if (!_isValidField(fields[startIndex], 0, 59)) return false;

    // Validate hour (index 1 or 2)
    if (!_isValidField(fields[startIndex + 1], 0, 23)) return false;

    // Validate day (index 2 or 3)
    if (!_isValidField(fields[startIndex + 2], 1, 31)) return false;

    // Validate month (index 3 or 4)
    if (!_isValidField(fields[startIndex + 3], 1, 12)) return false;

    // Validate day of week (index 4 or 5)
    if (!_isValidField(fields[startIndex + 4], 0, 7)) return false;

    return true;
  }

  /// Validates a single cron field
  /// 
  /// Supports:
  /// - * (any value)
  /// - , (list) e.g., 1,3,5
  /// - - (range) e.g., 1-5
  /// - / (step) e.g., */5, 1-10/2
  /// - ? (day/dayofweek wildcard)
  /// - L (last - for day of month)
  /// - W (weekday - for day of month)
  /// - # (nth occurrence - for day of week)
  /// - Numbers (specific value)
  static bool _isValidField(String field, int min, int max) {
    // Wildcard characters
    if (field == '*' || field == '?') return true;

    // Handle step values
    if (field.contains('/')) {
      final parts = field.split('/');
      if (parts.length != 2) return false;

      final base = parts[0];
      final step = int.tryParse(parts[1]);
      if (step == null || step <= 0) return false;

      // Base can be * or a range
      if (base == '*') return true;
      return _isValidRange(base, min, max);
    }

    // Handle list values
    if (field.contains(',')) {
      final parts = field.split(',');
      return parts.every((part) => _isValidValue(part.trim(), min, max));
    }

    // Handle range
    if (field.contains('-')) {
      return _isValidRange(field, min, max);
    }

    // Handle special characters (L, W, # only for certain fields)
    if (field.contains('L') || field.contains('W') || field.contains('#')) {
      return _isValidSpecialField(field, min, max);
    }

    // Single value
    return _isValidValue(field, min, max);
  }

  /// Validates a range like "1-5"
  static bool _isValidRange(String range, int min, int max) {
    final parts = range.split('-');
    if (parts.length != 2) return false;

    final start = int.tryParse(parts[0].trim());
    final end = int.tryParse(parts[1].trim());

    if (start == null || end == null) return false;
    if (start < min || start > max || end < min || end > max) return false;
    if (start > end) return false;

    return true;
  }

  /// Validates a single value
  static bool _isValidValue(String value, int min, int max) {
    final num = int.tryParse(value);
    if (num == null) return false;
    return num >= min && num <= max;
  }

  /// Validates special field characters (L, W, #)
  static bool _isValidSpecialField(String field, int min, int max) {
    // L (last) - for day of month: L, 1L, 15L, etc.
    if (field.contains('L')) {
      if (field == 'L') return true;
      final base = field.replaceAll('L', '');
      if (base.isEmpty) return true;
      return _isValidValue(base, min, max);
    }

    // W (weekday) - for day of month: 1W, 15W, etc.
    if (field.contains('W')) {
      final base = field.replaceAll('W', '');
      if (base.isEmpty) return false;
      return _isValidValue(base, 1, 31);
    }

    // # (nth) - for day of week: 1#1 (first Monday), 5#3 (third Friday)
    if (field.contains('#')) {
      final parts = field.split('#');
      if (parts.length != 2) return false;
      final dow = int.tryParse(parts[0]);
      final nth = int.tryParse(parts[1]);
      if (dow == null || nth == null) return false;
      if (dow < 0 || dow > 7) return false;
      if (nth < 1 || nth > 5) return false;
      return true;
    }

    return false;
  }

  /// Parses a cron expression and returns a human-readable description
  /// 
  /// Example: "0 9 * * *" -> "At 9:00 AM, every day"
  static String describe(String expression) {
    if (!isValid(expression)) return 'Invalid cron expression';

    final fields = expression.trim().split(RegExp(r'\s+'));
    
    // Handle 6-field format (seconds)
    final hasSeconds = fields.length == 6;
    int minIdx = hasSeconds ? 1 : 0;
    int hourIdx = hasSeconds ? 2 : 1;
    int dayIdx = hasSeconds ? 3 : 2;
    int monthIdx = hasSeconds ? 4 : 3;
    int dowIdx = hasSeconds ? 5 : 4;

    final minute = fields[minIdx];
    final hour = fields[hourIdx];
    final day = fields[dayIdx];
    final month = fields[monthIdx];
    final dow = fields[dowIdx];

    // Build description
    final parts = <String>[];

    // Time
    if (hour == '*' && minute == '*') {
      parts.add('Every minute');
    } else if (hour == '*') {
      parts.add('At minute $minute, every hour');
    } else if (minute == '*') {
      parts.add('Every minute of hour $hour');
    } else if (minute == '0' && hour != '*') {
      parts.add('At ${_formatHour(hour)}');
    } else {
      parts.add('At ${_formatHour(hour)}:${minute.padLeft(2, '0')}');
    }

    // Day/Month/Day of Week
    if (day == '*' && dow == '*') {
      if (month == '*') {
        parts.add('every day');
      } else {
        parts.add('in ${_formatMonth(month)}');
      }
    } else if (day != '*' && dow == '?') {
      parts.add('on day ${day}');
      if (month != '*') {
        parts.add('of ${_formatMonth(month)}');
      }
    } else if (day == '?' && dow != '*') {
      parts.add('on ${_formatDayOfWeek(dow)}');
    } else {
      parts.add('on day $day or ${_formatDayOfWeek(dow)}');
    }

    return parts.join(' ');
  }

  static String _formatHour(String hour) {
    if (hour == '*') return 'every hour';
    final h = int.parse(hour);
    return '${h.toString().padLeft(2, '0')}:00';
  }

  static String _formatMonth(String month) {
    if (month == '*') return 'every month';
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    try {
      final m = int.parse(month);
      return months[m - 1];
    } catch (_) {
      return month;
    }
  }

  static String _formatDayOfWeek(String dow) {
    if (dow == '*' || dow == '?') return 'every day';
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    try {
      final d = int.parse(dow);
      return days[d % 7];
    } catch (_) {
      return dow;
    }
  }

  /// Returns common cron presets with descriptions
  static Map<String, String> getPresets() {
    return {
      'daily': '0 9 * * *',      // 9 AM daily
      'weekly': '0 9 * * 1',     // 9 AM every Monday
      'monthly': '0 9 1 * *',    // 9 AM on 1st of month
      'hourly': '0 * * * *',     // Every hour
      'twice_daily': '0 9,17 * * *', // 9 AM and 5 PM
    };
  }

  /// Returns preset descriptions for UI
  static Map<String, String> getPresetDescriptions() {
    return {
      'daily': 'Every day at 9:00 AM',
      'weekly': 'Every Monday at 9:00 AM',
      'monthly': 'On the 1st of every month at 9:00 AM',
      'hourly': 'Every hour',
      'twice_daily': 'Daily at 9:00 AM and 5:00 PM',
    };
  }
}
