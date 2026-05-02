import 'package:boilerplate/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'store/performance_monitoring_store.dart';
import 'widgets/date_range_selector.dart';
import 'widgets/summary_card.dart';
import 'widgets/brand_trend_chart.dart';
import 'widgets/sentiment_chart.dart';
import 'widgets/model_breakdown_chart.dart';
import 'widgets/content_trend_chart.dart';
import 'widgets/content_topic_chart.dart';
import 'widgets/content_item_card.dart';

class PerformanceMonitoringScreen extends StatefulWidget {
  @override
  State<PerformanceMonitoringScreen> createState() =>
      _PerformanceMonitoringScreenState();
}

class _PerformanceMonitoringScreenState
    extends State<PerformanceMonitoringScreen> {
  late final PerformanceMonitoringStore _store;

  @override
  void initState() {
    super.initState();
    _store = getIt<PerformanceMonitoringStore>();
    _store.loadAllData();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: const Text(
          'Performance Monitoring',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Observer(
            builder: (_) => _store.isRefreshing
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF3B82F6)),
                    tooltip: 'Refresh Data',
                    onPressed: () {
                      _store.refreshData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Refreshing data...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading && _store.brandAnalytics == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_store.errorStore.errorMessage.isNotEmpty &&
              _store.brandAnalytics == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 12),
                    Text(
                      _store.errorStore.errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _store.loadAllData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildBody();
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date range selector
          _buildDateRangeHeader(),
          const SizedBox(height: 24),

          // ═══ BRAND PERFORMANCE SECTION ═══
          _sectionHeader('Brand Performance', Icons.analytics_outlined),
          const SizedBox(height: 16),
          _buildBrandSummaryCards(),
          const SizedBox(height: 16),
          Observer(
            builder: (_) => BrandTrendChart(
              data: _store.brandChartData,
              selectedMetric: _store.selectedBrandMetric,
              onMetricChanged: _store.selectBrandMetric,
              isLoading: _store.isLoading,
            ),
          ),
          const SizedBox(height: 16),
          _buildSentimentAndModelRow(),
          const SizedBox(height: 32),

          // ═══ CONTENT PERFORMANCE SECTION ═══
          _sectionHeader('Content Performance', Icons.article_outlined),
          const SizedBox(height: 16),
          _buildContentSummaryCards(),
          const SizedBox(height: 16),
          Observer(
            builder: (_) => ContentTrendChart(
              data: _store.contentPublishTrend,
              isLoading: _store.isLoadingContent,
            ),
          ),
          const SizedBox(height: 16),
          Observer(
            builder: (_) => ContentTopicChart(
              topicCounts: _store.contentByTopic,
              isLoading: _store.isLoadingContent,
            ),
          ),
          const SizedBox(height: 16),
          _buildContentList(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDateRangeHeader() {
    return Observer(
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Report',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _store.dateRangeLabel,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DateRangeSelector(
            selectedRange: _store.selectedRange,
            onRangeChanged: (range, {customStart, customEnd}) {
              _store.selectRange(range,
                  start: customStart, end: customEnd);
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: const Color(0xFF3B82F6), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandSummaryCards() {
    return Observer(
      builder: (_) {
        final ba = _store.brandAnalytics;
        if (ba == null) return const SizedBox();

        return GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 4 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: [
            SummaryCard(
              title: 'Brand Mentions',
              value: ba.brandMentions.toString(),
              subtitle: '${ba.brandMentionsRate.toStringAsFixed(1)}% rate',
              icon: Icons.chat_bubble_outline,
              color: const Color(0xFF3B82F6),
            ),
            SummaryCard(
              title: 'Link References',
              value: ba.linkReferences.toString(),
              subtitle: '${ba.linkReferencesRate.toStringAsFixed(1)}% rate',
              icon: Icons.link,
              color: const Color(0xFFF59E0B),
            ),
            SummaryCard(
              title: 'Total Responses',
              value: ba.totalResponses.toString(),
              icon: Icons.bar_chart,
              color: const Color(0xFF10B981),
            ),
            SummaryCard(
              title: 'AI Overviews',
              value: ba.aiOverviewsCount.toString(),
              subtitle: '${ba.aiOverviewsRate.toStringAsFixed(1)}% rate',
              icon: Icons.auto_awesome,
              color: const Color(0xFF8B5CF6),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSentimentAndModelRow() {
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Observer(
      builder: (_) {
        final ba = _store.brandAnalytics;
        if (ba == null) return const SizedBox();

        final sentiment = SentimentChart(
          positive: ba.sentimentStats.positive,
          neutral: ba.sentimentStats.neutral,
          negative: ba.sentimentStats.negative,
          isLoading: _store.isLoading,
        );

        final model = ModelBreakdownChart(
          models: ba.analyticsByModel,
          isLoading: _store.isLoading,
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: sentiment),
              const SizedBox(width: 16),
              Expanded(child: model),
            ],
          );
        }

        return Column(
          children: [
            sentiment,
            const SizedBox(height: 16),
            model,
          ],
        );
      },
    );
  }

  Widget _buildContentSummaryCards() {
    return Observer(
      builder: (_) {
        return Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Content',
                value: _store.totalContent.toString(),
                icon: Icons.library_books,
                color: const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Published',
                value: _store.publishedCount.toString(),
                icon: Icons.check_circle_outline,
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Draft',
                value: _store.draftCount.toString(),
                icon: Icons.edit_note,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContentList() {
    return Observer(
      builder: (_) {
        final items = _store.allContentItems;
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No content items found',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Recent Content',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            ...items.map((item) => ContentItemCard(item: item)).toList(),
          ],
        );
      },
    );
  }
}
