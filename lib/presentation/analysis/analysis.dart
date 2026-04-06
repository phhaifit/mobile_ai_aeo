import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/overview/store/overview_store.dart';
import 'package:boilerplate/presentation/overview/widgets/metrics_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AnalysisScreen extends StatefulWidget {
  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late final OverviewStore _overviewStore;

  @override
  void initState() {
    super.initState();
    _overviewStore = getIt<OverviewStore>();
    // TODO: Get projectId from route params or current project
    const projectId = '6542ec8c-0e5d-4694-8088-db9f17ac9e21';
    _overviewStore.fetchOverviewMetrics(projectId);
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        'Analysis',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/overview');
          },
          child: Text(
            'Overview',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.help_outline, color: Colors.grey),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Detailed analysis of mentions and AI platforms'),
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
            // Header
            Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analysis',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Sentiment tracking and AI platform insights for Your Brand',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Layout: On mobile - stack vertically, on desktop - side by side
            if (isMobile) ...[
              _buildSentimentWidget(),
              SizedBox(height: 16.0),
              _buildShareOfVoiceWidget(),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildSentimentWidget(),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    flex: 1,
                    child: _buildShareOfVoiceWidget(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentWidget() {
    return MentionSentimentWidget(store: _overviewStore);
  }

  Widget _buildShareOfVoiceWidget() {
    return ShareOfVoiceWidget(store: _overviewStore);
  }
}
