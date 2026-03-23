import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:boilerplate/presentation/overview/store/overview_store.dart';

/// Widget displaying Mention Sentiment Tracking with a stacked progress bar
class MentionSentimentWidget extends StatelessWidget {
  final OverviewStore store;

  const MentionSentimentWidget({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: Color(0xFFEEEEEE),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and info icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mention Sentiment Tracking',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Icon(
                    Icons.info_outlined,
                    size: 18.0,
                    color: Color(0xFFBBBBBB),
                  ),
                ],
              ),
              SizedBox(height: 20.0),

              // Stacked progress bar
              _buildStackedProgressBar(),
              SizedBox(height: 16.0),

              // Legend with percentages
              _buildLegend(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStackedProgressBar() {
    final total = store.sentimentPositivePercent +
        store.sentimentNeutralPercent +
        store.sentimentNegativePercent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        height: 32.0,
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            // Positive segment (Green)
            Expanded(
              flex: (store.sentimentPositivePercent / total * 100).toInt(),
              child: Container(
                color: Color(0xFF4CAF50), // Green
              ),
            ),
            // Neutral segment (Grey)
            Expanded(
              flex: (store.sentimentNeutralPercent / total * 100).toInt(),
              child: Container(
                color: Color(0xFFBDBDBD), // Grey
              ),
            ),
            // Negative segment (Red)
            Expanded(
              flex: (store.sentimentNegativePercent / total * 100).toInt(),
              child: Container(
                color: Color(0xFFF44336), // Red
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(
          color: Color(0xFF4CAF50),
          label: 'Positive',
          percentage: store.sentimentPositivePercent,
          count: store.sentimentPositiveCount,
        ),
        SizedBox(height: 10.0),
        _buildLegendItem(
          color: Color(0xFFBDBDBD),
          label: 'Neutral',
          percentage: store.sentimentNeutralPercent,
          count: store.sentimentNeutralCount,
        ),
        SizedBox(height: 10.0),
        _buildLegendItem(
          color: Color(0xFFF44336),
          label: 'Negative',
          percentage: store.sentimentNegativePercent,
          count: store.sentimentNegativeCount,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required double percentage,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(width: 8.0),
        Text(
          '($count)',
          style: TextStyle(
            fontSize: 12.0,
            color: Color(0xFF999999),
          ),
        ),
      ],
    );
  }
}

/// Widget displaying Share of Voice across LLMs
class ShareOfVoiceWidget extends StatelessWidget {
  final OverviewStore store;

  const ShareOfVoiceWidget({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: Color(0xFFEEEEEE),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and info icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Share of Voice across LLMs',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Icon(
                    Icons.info_outlined,
                    size: 18.0,
                    color: Color(0xFFBBBBBB),
                  ),
                ],
              ),
              SizedBox(height: 20.0),

              // List of LLMs
              ...store.llmShareData
                  .map(
                    (llmData) => _buildLLMComparisonItem(llmData),
                  )
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLLMComparisonItem(LLMShareData llmData) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LLM Name
          Text(
            llmData.llmName,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 12.0),

          // Your Brand row
          _buildProgressBarRow(
            label: 'Your Brand',
            percentage: llmData.brandPercent,
            color: Color(0xFF2196F3),
            isBrand: true,
          ),
          SizedBox(height: 8.0),

          // Competitor Avg row
          _buildProgressBarRow(
            label: 'Competitor Avg',
            percentage: llmData.competitorAvgPercent,
            color: Color(0xFFFFA726),
            isBrand: false,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBarRow({
    required String label,
    required double percentage,
    required Color color,
    required bool isBrand,
  }) {
    // Normalize percentage to max 100 for display purposes
    final displayPercent = percentage > 100 ? 100.0 : percentage;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100.0,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: isBrand ? FontWeight.w600 : FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: Container(
              height: 20.0,
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Stack(
                children: [
                  // Background bar
                  Container(
                    color: color.withOpacity(0.15),
                    width: double.infinity,
                  ),
                  // Filled bar
                  FractionallySizedBox(
                    widthFactor: displayPercent / 100,
                    child: Container(
                      color: color,
                    ),
                  ),
                  // Percentage text
                  Center(
                    child: Text(
                      '${displayPercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                        color: displayPercent > 50
                            ? Colors.white
                            : Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
