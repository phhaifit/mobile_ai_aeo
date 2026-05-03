import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/analytic/store/analytic_store.dart';
import 'package:boilerplate/presentation/analytic/widgets/metrics_widgets.dart';
import 'package:boilerplate/presentation/template_library/widgets/loading_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AnalyticScreen extends StatefulWidget {
  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> {
  late final AnalyticStore _analyticStore;

  @override
  void initState() {
    super.initState();
    _analyticStore = getIt<AnalyticStore>();
    // TODO: Get projectId from route params or current project
    const projectId = '9022c9d7-7443-4a33-96aa-56628ba81220';
    _analyticStore.fetchAnalyticsMetrics(projectId);
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
                content: Text('Sentiment tracking and AI platform insights'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_analyticStore.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingIndicator(
              size: 52,
              color: Color(0xFF2196F3),
              animationType: AnimationType.ring,
            ),
            SizedBox(height: 16),
            Text(
              'Loading analysis…',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      );
    }

    if (_analyticStore.errorStore.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_analyticStore.errorStore.errorMessage),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                const projectId = '6542ec8c-0e5d-4694-8088-db9f17ac9e21';
                _analyticStore.fetchAnalyticsMetrics(projectId);
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

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
    return MentionSentimentWidget(store: _analyticStore);
  }

  Widget _buildShareOfVoiceWidget() {
    return ShareOfVoiceWidget(store: _analyticStore);
  }
}
