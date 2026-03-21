import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/seo/check_status.dart';
import 'package:boilerplate/presentation/technical_seo/store/technical_seo_store.dart';
import 'package:boilerplate/presentation/technical_seo/widgets/audit_category_widget.dart';
import 'package:boilerplate/presentation/technical_seo/widgets/crawler_activity_widget.dart';
import 'package:boilerplate/presentation/technical_seo/widgets/seo_score_card_widget.dart';
import 'package:boilerplate/presentation/technical_seo/widgets/speed_metrics_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class TechnicalSeoScreen extends StatefulWidget {
  const TechnicalSeoScreen({super.key});

  @override
  State<TechnicalSeoScreen> createState() => _TechnicalSeoScreenState();
}

class _TechnicalSeoScreenState extends State<TechnicalSeoScreen>
    with SingleTickerProviderStateMixin {
  final TechnicalSeoStore _store = getIt<TechnicalSeoStore>();
  final TextEditingController _urlController = TextEditingController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _store.loadHistory();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tabController.dispose();
    _store.dispose();
    super.dispose();
  }

  bool _crawlersLoaded = false;

  void _onAudit() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a URL')),
      );
      return;
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL must start with http:// or https://')),
      );
      return;
    }
    _crawlersLoaded = false;
    _store.setUrl(url);
    _store.startAudit();
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Technical SEO'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Speed'),
            Tab(text: 'Crawlers'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildUrlInput(),
          Expanded(
            child: Observer(
              builder: (_) => _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: 'https://example.com',
                labelText: 'Website URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
                isDense: true,
              ),
              onSubmitted: (_) => _onAudit(),
            ),
          ),
          const SizedBox(width: 12),
          Observer(
            builder: (_) => ElevatedButton.icon(
              onPressed: _store.loading ? null : _onAudit,
              icon: _store.loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: const Text('Audit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildSpeedTab(),
        _buildCrawlersTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final audit = _store.currentAudit;

    if (_store.loading && audit == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (audit == null) {
      return _buildEmptyState(
        icon: Icons.analytics_outlined,
        message: 'Enter a URL and tap Audit to begin',
      );
    }

    return ListView(
      children: [
        SeoScoreCardWidget(
          score: audit.overallScore,
          url: audit.url,
          isPolling: _store.isPolling,
        ),
        if (audit.status == AuditStatus.completed)
          ...audit.categories.map(
            (cat) => AuditCategoryWidget(category: cat),
          )
        else
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Audit in progress...')),
          ),
      ],
    );
  }

  Widget _buildSpeedTab() {
    final audit = _store.currentAudit;

    if (audit == null) {
      return _buildEmptyState(
        icon: Icons.speed_outlined,
        message: 'Run an audit to see speed metrics',
      );
    }

    return SpeedMetricsWidget(audit: audit);
  }

  Widget _buildCrawlersTab() {
    // Load crawler events once when tab is first built (avoid infinite rebuild)
    if (!_crawlersLoaded && _store.inputUrl.isNotEmpty) {
      _crawlersLoaded = true;
      Future.microtask(() => _store.loadCrawlerEvents());
    }

    return Observer(
      builder: (_) {
        return Column(
          children: [
            if (_store.inputUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_store.crawlerEvents.length} events',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TextButton.icon(
                      onPressed: _store.loadCrawlerEvents,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: CrawlerActivityWidget(
                events: _store.crawlerEvents.toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
