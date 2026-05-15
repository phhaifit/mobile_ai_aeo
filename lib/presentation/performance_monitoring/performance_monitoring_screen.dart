import 'package:boilerplate/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
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

  int _currentContentPage = 1;
  static const int _itemsPerPage = 6;

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
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: Text(
          'Performance Monitoring',
          style: GoogleFonts.oswald(
            color: Colors.black,
            fontSize: 17.0,
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
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0052CC)),
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
                    Text(
                      'Performance Report',
                      style: GoogleFonts.oswald(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _store.dateRangeLabel,
                      style: GoogleFonts.montserrat(fontSize: 12.0, color: const Color(0xFF888888)),
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
            color: const Color(0xFF0052CC),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: const Color(0xFF0052CC), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.oswald(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
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

        final screenWidth = MediaQuery.of(context).size.width;
        final crossCount = screenWidth >= 600 ? 4 : 2;
        final aspectRatio = screenWidth >= 600 ? 1.6 : (screenWidth < 400 ? 1.2 : 1.4);

        return GridView.count(
          crossAxisCount: crossCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: aspectRatio,
          children: [
            SummaryCard(
              title: 'Brand Mentions',
              value: ba.brandMentions.toString(),
              subtitle: '${ba.brandMentionsRate.toStringAsFixed(1)}% rate',
              icon: Icons.chat_bubble_outline,
              color: const Color(0xFF0052CC),
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
        final allItems = _store.allContentItems;
        final items = allItems.where((c) {
          final date = c.publishedAt ?? c.createdAt;
          return !date.isBefore(_store.rangeStart) && !date.isAfter(_store.rangeEnd);
        }).toList();

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

        final totalPages = (items.length / _itemsPerPage).ceil();
        // Ensure current page is valid when data changes
        if (_currentContentPage > totalPages) {
          _currentContentPage = totalPages > 0 ? totalPages : 1;
        }

        final startIndex = (_currentContentPage - 1) * _itemsPerPage;
        final endIndex = startIndex + _itemsPerPage;
        final paginatedItems = items.sublist(
          startIndex,
          endIndex > items.length ? items.length : endIndex,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Recent Content',
                style: GoogleFonts.oswald(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            ...paginatedItems.map((item) => ContentItemCard(item: item)).toList(),
            if (totalPages > 1) _buildPaginationControls(totalPages),
          ],
        );
      },
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentContentPage > 1
                ? () {
                    setState(() {
                      _currentContentPage--;
                    });
                  }
                : null,
          ),
          Text(
            'Page $_currentContentPage of $totalPages',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentContentPage < totalPages
                ? () {
                    setState(() {
                      _currentContentPage++;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
