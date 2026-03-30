import 'package:boilerplate/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'store/performance_monitoring_store.dart';
import 'widgets/performance_summary_widget.dart';
import 'widgets/weekly_trend_chart_widget.dart';
import 'widgets/metric_trend_card_widget.dart';
import 'widgets/period_comparison_widget.dart';
import 'widgets/improvement_suggestions_widget.dart';

class PerformanceMonitoringScreen extends StatefulWidget {
  @override
  State<PerformanceMonitoringScreen> createState() => _PerformanceMonitoringScreenState();
}

class _PerformanceMonitoringScreenState extends State<PerformanceMonitoringScreen> {
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
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: Text(
          'Performance Monitoring',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Monitor brand visibility trends and track performance over time.'),
                ),
              );
            },
          ),
        ],
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading && _store.weeklyReport == null) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (_store.errorStore.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _store.errorStore.errorMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return _buildBodyLayout(context);
        },
      ),
    );
  }

  Widget _buildBodyLayout(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderDate(),
          SizedBox(height: 24),
          if (isDesktop)
            _buildDesktopLayout()
          else
            _buildMobileLayout(),
        ],
      ),
    );
  }

  Widget _buildHeaderDate() {
    return Observer(
      builder: (_) {
        final label = _store.weeklyReport?.weekLabel ?? 'Latest Week';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Performance Report',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPerformanceSummary(),
        SizedBox(height: 20),
        _buildMetricCards(),
        SizedBox(height: 20),
        _buildWeeklyTrendChart(),
        SizedBox(height: 20),
        _buildPeriodComparison(),
        SizedBox(height: 20),
        _buildImprovementSuggestions(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildPerformanceSummary(),
              SizedBox(height: 20),
              _buildMetricCards(),
              SizedBox(height: 20),
              _buildImprovementSuggestions(),
            ],
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildWeeklyTrendChart(),
              SizedBox(height: 20),
              _buildPeriodComparison(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceSummary() {
    return Observer(
      builder: (_) => PerformanceSummaryWidget(
        score: _store.weeklyReport?.overallHealthScore ?? 0.0,
        dateRangeLabel: _store.weeklyReport?.weekLabel ?? '',
        trendDirection: _store.trendDirection,
        isLoading: _store.isLoading,
      ),
    );
  }

  Widget _buildMetricCards() {
    return Observer(
      builder: (_) {
        if (_store.comparisons.isEmpty) return SizedBox();
        
        // Find metrics dynamically or use defaults
        final visMetric = _store.comparisons.firstWhere(
          (c) => c.metricName == 'Brand Visibility', 
          orElse: () => _store.comparisons[0]
        );
        final mentMetric = _store.comparisons.firstWhere(
          (c) => c.metricName == 'Brand Mentions', 
          orElse: () => _store.comparisons.length > 1 ? _store.comparisons[1] : _store.comparisons[0]
        );
        final linkMetric = _store.comparisons.firstWhere(
          (c) => c.metricName == 'Link Visibility', 
          orElse: () => _store.comparisons.length > 2 ? _store.comparisons[2] : _store.comparisons[0]
        );
        final sentMetric = _store.comparisons.firstWhere(
          (c) => c.metricName.contains('Positive'), 
          orElse: () => _store.comparisons.length > 3 ? _store.comparisons[3] : _store.comparisons[0]
        );

        return GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width >= 1200 ? 2 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: MediaQuery.of(context).size.width >= 1200 ? 1.8 : 2.5,
          children: [
            MetricTrendCardWidget(
              title: visMetric.metricName,
              value: visMetric.currentValue.toStringAsFixed(1),
              unitLabel: '%',
              changePercent: visMetric.changePercent,
              isImproved: visMetric.isImproved,
              icon: Icons.visibility,
              iconColor: Colors.blue,
            ),
            MetricTrendCardWidget(
              title: mentMetric.metricName,
              value: mentMetric.currentValue.toStringAsFixed(0),
              unitLabel: '',
              changePercent: mentMetric.changePercent,
              isImproved: mentMetric.isImproved,
              icon: Icons.chat_bubble_outline,
              iconColor: Colors.teal,
            ),
            MetricTrendCardWidget(
              title: linkMetric.metricName,
              value: linkMetric.currentValue.toStringAsFixed(1),
              unitLabel: '%',
              changePercent: linkMetric.changePercent,
              isImproved: linkMetric.isImproved,
              icon: Icons.link,
              iconColor: Colors.orange,
            ),
            MetricTrendCardWidget(
              title: sentMetric.metricName,
              value: sentMetric.currentValue.toStringAsFixed(1),
              unitLabel: '%',
              changePercent: sentMetric.changePercent,
              isImproved: sentMetric.isImproved,
              icon: Icons.sentiment_satisfied_alt,
              iconColor: Colors.green,
            ),
          ],
        );
      }
    );
  }

  Widget _buildWeeklyTrendChart() {
    return Observer(
      builder: (_) => WeeklyTrendChartWidget(
        labels: _store.chartLabels,
        values: _store.chartValues,
        selectedMetric: _store.selectedMetric,
        selectedPeriod: _store.selectedPeriod,
        onMetricChanged: _store.selectMetric,
        onPeriodChanged: _store.selectPeriod,
        isLoading: _store.isLoading,
      ),
    );
  }

  Widget _buildPeriodComparison() {
    return Observer(
      builder: (_) => PeriodComparisonWidget(
        comparisons: _store.comparisons,
        isLoading: _store.isLoading,
      ),
    );
  }

  Widget _buildImprovementSuggestions() {
    return Observer(
      builder: (_) => ImprovementSuggestionsWidget(
        suggestions: _store.suggestions,
        isLoading: _store.isLoading,
      ),
    );
  }
}
