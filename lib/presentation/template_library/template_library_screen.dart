import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/template_library/store/template_library_store.dart';
import 'package:boilerplate/presentation/template_library/widgets/website_analyzer_widget.dart';
import 'package:boilerplate/presentation/template_library/widgets/industry_template_card.dart';
import 'package:boilerplate/presentation/template_library/widgets/voice_preview_modal.dart';

class TemplateLibraryScreen extends StatefulWidget {
  @override
  State<TemplateLibraryScreen> createState() => _TemplateLibraryScreenState();
}

class _TemplateLibraryScreenState extends State<TemplateLibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TemplateLibraryStore _store;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _store = getIt<TemplateLibraryStore>();
    _store.fetchIndustryTemplates();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          'Template Library',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'From Website',
              icon: Icon(Icons.language, size: 20),
            ),
            Tab(
              text: 'Industry Templates',
              icon: Icon(Icons.category, size: 20),
            ),
          ],
          labelStyle: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: Color(0xFF2196F3),
          labelColor: Color(0xFF2196F3),
          unselectedLabelColor: Color(0xFF999999),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: From Website
          WebsiteAnalyzerWidget(store: _store),

          // Tab 2: Industry Templates
          Observer(
            builder: (context) {
              if (_store.isLoading) {
                return _buildLoadingState();
              }

              return ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  Text(
                    'Pre-built Templates',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Choose from expertly-crafted writing styles for your industry.',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Industry sections
                  ..._buildIndustryGroups(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIndustryGroups() {
    final industries = <String, List>{};
    for (var template in _store.industryTemplates) {
      if (!industries.containsKey(template.industry)) {
        industries[template.industry] = [];
      }
      industries[template.industry]!.add(template);
    }

    List<Widget> widgets = [];
    industries.forEach((industry, templates) {
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Industry header
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                industry,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            // Templates grid
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.75,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return IndustryTemplateCard(
                  style: template,
                  onTap: () {
                    _store.selectTemplate(template);
                    _showVoicePreview(context, template);
                  },
                );
              },
            ),
            SizedBox(height: 28.0),
          ],
        ),
      );
    });

    return widgets;
  }

  void _showVoicePreview(BuildContext context, dynamic template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoicePreviewModal(
        template: template,
        onApply: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${template.name} style applied!'),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xFF333333),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Loading Templates...',
            style: TextStyle(
              fontSize: 14.0,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}
