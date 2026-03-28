import 'package:flutter/material.dart';
import '../util/history_utils.dart';
import 'execution_status_badge.dart';

/// Mock CronjobExecution model for widget testing
/// In real app, use actual entity from domain
class MockCronjobExecution {
  final String id;
  final String cronjobId;
  final DateTime executedAt;
  final String status;
  final int articleCount;
  final int successfulDestinations;
  final int totalDestinations;
  final String? errorMessage;

  MockCronjobExecution({
    required this.id,
    required this.cronjobId,
    required this.executedAt,
    required this.status,
    required this.articleCount,
    required this.successfulDestinations,
    required this.totalDestinations,
    this.errorMessage,
  });
}

/// List item widget for displaying execution summary
/// 
/// Shows execution time, status, article count, and destination info
class ExecutionListItem extends StatelessWidget {
  final MockCronjobExecution execution;
  final VoidCallback onTap;
  final VoidCallback? onRetry;

  const ExecutionListItem({
    Key? key,
    required this.execution,
    required this.onTap,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? _buildMobileLayout()
              : _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildStats(),
        const SizedBox(height: 12),
        _buildFooter(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildStats(),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            formatExecutionTime(execution.executedAt),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ExecutionStatusBadge(
          status: execution.status,
          fontSize: 12,
        ),
      ],
    );
  }

  Widget _buildStats() {
    final destinationText = formatDestinationCount(
      execution.totalDestinations,
      execution.successfulDestinations,
    );

    return Row(
      children: [
        Text(
          '${execution.articleCount} articles',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          destinationText,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('View Details'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        if (execution.status == 'failed' && onRetry != null) ...[
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ],
    );
  }
}
