import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/overview/store/overview_store.dart';
import 'package:boilerplate/presentation/overview/widgets/metric_summary_card.dart';
import 'package:boilerplate/presentation/overview/widgets/visibility_score_widget.dart';
import 'package:boilerplate/presentation/overview/widgets/content_strategy_widget.dart';
import 'package:boilerplate/presentation/overview/widgets/domain_distribution_widget.dart';
import 'package:boilerplate/presentation/template_library/widgets/loading_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class OverviewScreen extends StatefulWidget {
  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  late final OverviewStore _overviewStore;

  @override
  void initState() {
    super.initState();
    _overviewStore = getIt<OverviewStore>();
    // TODO: Get projectId from route params or current project
    const projectId = '9022c9d7-7443-4a33-96aa-56628ba81220';
    _overviewStore.fetchOverviewMetrics(projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: Observer(
        builder: (context) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: _buildBody(context),
              ),
              if (_overviewStore.isLoading)
                Positioned.fill(
                  child: Material(
                    color: Colors.white.withOpacity(0.88),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LoadingIndicator(
                            size: 52,
                            color: Color(0xFF2196F3),
                            animationType: AnimationType.ring,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading overview…',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      title: Text(
        'Overview',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline, color: Colors.grey),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Brand performance metrics for Your Brand in last 30 days'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with last updated time
            Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Brand performance metrics for Your Brand in last 30 days. Last updated: Mar 18, 2026 at 06:28 PM',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Layout: On mobile - stack vertically, on desktop - row with left and right
            if (isMobile) ...[
              // Mobile layout: Stack everything vertically
              _buildVisibilityScoreSection(),
              SizedBox(height: 16.0),
              _buildMetricsSection(isMobile: true),
              SizedBox(height: 16.0),
              _buildDomainDistributionSection(),
              SizedBox(height: 16.0),
              _buildCompetitorsSection(),
              SizedBox(height: 16.0),
              _buildContentStrategySection(),
            ] else ...[
              // Desktop/Tablet layout: Two columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: Visibility Score + Content Strategy
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildVisibilityScoreSection(),
                        SizedBox(height: 16.0),
                        _buildContentStrategySection(),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.0),
                  // Right column: Metrics Cards
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMetricsSection(isMobile: false),
                        SizedBox(height: 16.0),
                        _buildDomainDistributionSection(),
                        SizedBox(height: 16.0),
                        _buildCompetitorsSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityScoreSection() {
    return Observer(
      builder: (context) => VisibilityScoreWidget(
        score: _overviewStore.brandVisibilityScore,
        suggestedBenchmark: _overviewStore.suggestedBenchmark,
        isLoading: _overviewStore.isLoading,
      ),
    );
  }

  Widget _buildMetricsSection({required bool isMobile}) {
    return Observer(
      builder: (context) {
        final metrics = [
          {
            'title': 'Brand Visibility',
            'value': _overviewStore.brandVisibilityPercent.toStringAsFixed(1),
            'unit': '%',
            'icon': Icons.trending_up,
            'color': Colors.blue,
          },
          {
            'title': 'Brand Mentions',
            'value': _overviewStore.brandMentions.toString(),
            'unit': '',
            'icon': Icons.chat_bubble_outline,
            'color': Colors.teal,
          },
          {
            'title': 'Link Visibility',
            'value': _overviewStore.linkVisibilityPercent.toStringAsFixed(1),
            'unit': '%',
            'icon': Icons.link,
            'color': Colors.orange,
          },
          {
            'title': 'Link References',
            'value': _overviewStore.linkReferences.toString(),
            'unit': '',
            'icon': Icons.bookmark_outline,
            'color': Colors.purple,
          },
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 1,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: isMobile ? 0.9 : 2.0,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return MetricSummaryCard(
              title: metric['title'] as String,
              value: metric['value'] as String,
              unitLabel: metric['unit'] as String,
              icon: metric['icon'] as IconData,
              iconColor: metric['color'] as Color,
            );
          },
        );
      },
    );
  }

  Widget _buildDomainDistributionSection() {
    return Observer(
      builder: (context) => DomainDistributionWidget(
        domains: _overviewStore.topReferencedDomains,
        isLoading: _overviewStore.isLoading,
      ),
    );
  }

  Widget _buildContentStrategySection() {
    return ContentStrategyWidget();
  }

  Widget _buildCompetitorsSection() {
    return Observer(
      builder: (context) {
        if (_overviewStore.isLoading) {
          return SizedBox.shrink();
        }
        final scores = _overviewStore.competitorScores;
        if (scores.isEmpty) {
          return SizedBox.shrink();
        }
        final entries = scores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Competitive presence',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 6.0),
              Text(
                'Benchmark-style scores vs selected peers (filled from API or demo when data is missing).',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFF666666),
                  height: 1.45,
                ),
              ),
              SizedBox(height: 16.0),
              ...entries.map(
                (e) => Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          '${e.value}',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
