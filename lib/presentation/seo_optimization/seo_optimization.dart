import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/seo_optimization/store/seo_store.dart';
import 'package:boilerplate/presentation/seo_optimization/widgets/onpage_seo_checker_widget.dart';
import 'package:boilerplate/presentation/seo_optimization/widgets/topic_clustering_widget.dart';
import 'package:boilerplate/presentation/seo_optimization/widgets/internal_linking_widget.dart';
import 'package:boilerplate/presentation/seo_optimization/widgets/content_structure_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';

class SeoOptimizationScreen extends StatefulWidget {
  @override
  State<SeoOptimizationScreen> createState() => _SeoOptimizationScreenState();
}

class _SeoOptimizationScreenState extends State<SeoOptimizationScreen>
    with SingleTickerProviderStateMixin {
  late final SeoStore _seoStore;
  late final TabController _tabController;

  static const _tabs = [
    _TabItem(
      label: 'On-page SEO',
      icon: Icons.checklist_rounded,
    ),
    _TabItem(
      label: 'Topic Clusters',
      icon: Icons.hub_outlined,
    ),
    _TabItem(
      label: 'Internal Links',
      icon: Icons.link,
    ),
    _TabItem(
      label: 'Structure',
      icon: Icons.auto_fix_high,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _seoStore = getIt<SeoStore>();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _seoStore.fetchMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: Observer(
              builder: (context) => _buildTabBarView(),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.black, size: 18.0),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'SEO Content Optimization',
        style: GoogleFonts.oswald(
          color: Colors.black,
          fontSize: 17.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0052CC)),
          tooltip: 'Refresh',
          onPressed: () => _seoStore.fetchMockData(),
        ),
        const SizedBox(width: 4.0),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: const Color(0xFF0052CC),
        unselectedLabelColor: const Color(0xFF888888),
        indicatorColor: const Color(0xFF0052CC),
        indicatorWeight: 2.5,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
        tabs: _tabs
            .map(
              (t) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.icon, size: 15.0),
                    const SizedBox(width: 6.0),
                    Text(t.label),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        OnPageSeoCheckerWidget(
          items: _seoStore.onPageSeoItems,
          isLoading: _seoStore.isLoading,
        ),
        TopicClusteringWidget(
          clusters: _seoStore.topicClusters,
          isLoading: _seoStore.isLoading,
        ),
        InternalLinkingWidget(
          suggestions: _seoStore.internalLinkSuggestions,
          isLoading: _seoStore.isLoading,
        ),
        ContentStructureWidget(
          items: _seoStore.contentStructureItems,
          isLoading: _seoStore.isLoading,
        ),
      ],
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem({required this.label, required this.icon});
}
