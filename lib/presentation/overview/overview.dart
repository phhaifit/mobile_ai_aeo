import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/overview/store/overview_store.dart';
import 'package:boilerplate/presentation/overview/widgets/metric_summary_card.dart';
import 'package:boilerplate/presentation/overview/widgets/visibility_score_widget.dart';
import 'package:boilerplate/presentation/overview/widgets/content_strategy_widget.dart';
import 'package:boilerplate/presentation/overview/widgets/top_reference_domains_widget.dart';
import 'package:boilerplate/presentation/overview/widgets/metrics_widgets.dart';
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
    _overviewStore.fetchMockData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: Observer(
        builder: (context) {
          return _buildBody(context);
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
              _buildSentimentWidget(),
              SizedBox(height: 16.0),
              _buildShareOfVoiceWidget(),
              SizedBox(height: 16.0),
              _buildTopDomainsSection(),
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
                        _buildTopDomainsSection(),
                        SizedBox(height: 16.0),
                        _buildSentimentWidget(),
                        SizedBox(height: 16.0),
                        _buildShareOfVoiceWidget(),
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

  Widget _buildTopDomainsSection() {
    return Observer(
      builder: (context) => TopReferencedDomainsWidget(
        domains: _overviewStore.topReferencedDomains,
        isLoading: _overviewStore.isLoading,
      ),
    );
  }

  Widget _buildContentStrategySection() {
    return ContentStrategyWidget();
  }

  Widget _buildSentimentWidget() {
    return MentionSentimentWidget(store: _overviewStore);
  }

  Widget _buildShareOfVoiceWidget() {
    return ShareOfVoiceWidget(store: _overviewStore);
  }
}
