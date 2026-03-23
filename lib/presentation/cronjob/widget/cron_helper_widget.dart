import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:boilerplate/presentation/cronjob/util/cron_validator.dart';

/// Displays parsed cron expression with human-readable description
class CronHelperWidget extends StatelessWidget {
  final String cronExpression;
  final DateTime? lastExecutionTime;

  const CronHelperWidget({
    Key? key,
    required this.cronExpression,
    this.lastExecutionTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = CronValidator.isValid(cronExpression);
    final description = isValid
        ? CronValidator.describe(cronExpression)
        : 'Invalid cron expression';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid
            ? Colors.blue.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid ? Colors.blue.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cron expression
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle_outline : Icons.error_outline,
                size: 16,
                color: isValid ? Colors.blue : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cron: $cronExpression',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: isValid ? Colors.blue : Colors.red,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            style: GoogleFonts.montserrat(
              color: isValid ? Colors.blue.withOpacity(0.8) : Colors.red.withOpacity(0.8),
            ),
          ),

          // Last execution time (if available)
          if (lastExecutionTime != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.history_outlined,
                  size: 14,
                  color: theme.hintColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Last run: ${_formatTime(lastExecutionTime!)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: theme.hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Format time as relative string (e.g., "2 hours ago")
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins minute${mins != 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours != 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days day${days != 1 ? 's' : ''} ago';
    } else {
      return dateTime.toString().substring(0, 10);
    }
  }
}
