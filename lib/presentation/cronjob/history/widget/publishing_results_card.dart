import 'package:flutter/material.dart';
import '../util/history_utils.dart';

/// Mock ExecutionResult model for widget testing
/// In real app, use actual entity from data layer
class MockExecutionResult {
  final String destination;
  final String status;
  final String? errorMessage;
  final DateTime? publishedAt;

  MockExecutionResult({
    required this.destination,
    required this.status,
    this.errorMessage,
    this.publishedAt,
  });
}

/// Card widget for displaying publishing result for a destination
/// 
/// Shows destination name, status icon, and error message if failed
class PublishingResultsCard extends StatelessWidget {
  final MockExecutionResult result;

  const PublishingResultsCard({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSuccess = result.status.toLowerCase() == 'success';
    final bgColor = Color(getStatusColor(result.status));
    final symbol = getStatusSymbol(result.status);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status row
            Row(
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    color: bgColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.destination,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!isSuccess && result.errorMessage != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          result.errorMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: bgColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Success status
            if (isSuccess) ...[
              const SizedBox(height: 8),
              Text(
                'Success',
                style: TextStyle(
                  fontSize: 12,
                  color: bgColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
