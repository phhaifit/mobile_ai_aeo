import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/template_library/store/template_library_store.dart';
import 'package:boilerplate/presentation/template_library/widgets/website_analyzer_widget.dart';
import 'package:boilerplate/presentation/template_library/widgets/industry_template_card.dart';
import 'package:boilerplate/presentation/template_library/widgets/voice_preview_modal.dart';
import 'package:boilerplate/presentation/template_library/widgets/content_profile_form_modal.dart';
import 'package:boilerplate/presentation/template_library/widgets/delete_confirmation_dialog.dart';

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
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ContentProfileFormModal(
                      projectId: '9022c9d7-7443-4a33-96aa-56628ba81220',
                      onSuccess: () {
                        setState(() {});
                      },
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Create',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'From Website',
              icon: Icon(Icons.language, size: 20),
            ),
            Tab(
              text: 'Content Profiles',
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

              if (_store.contentProfiles.isEmpty) {
                return ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    Text(
                      'Content Profiles',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'No content profiles available.',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Color(0xFF666666),
                        height: 1.4,
                      ),
                    ),
                  ],
                );
              }

              return ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  Text(
                    'Content Profiles',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Select a content profile for your project.',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Content profiles grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _store.contentProfiles.length,
                    itemBuilder: (context, index) {
                      final profile = _store.contentProfiles[index];
                      return IndustryTemplateCard(
                        profile: profile,
                        onTap: () {
                          _store.selectContentProfile(profile);
                          _showProfilePreview(context, profile);
                        },
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (context) => ContentProfileFormModal(
                              projectId: '9022c9d7-7443-4a33-96aa-56628ba81220',
                              profile: profile,
                              onSuccess: () {
                                setState(() {});
                              },
                            ),
                          );
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (context) => DeleteConfirmationDialog(
                              projectId: '9022c9d7-7443-4a33-96aa-56628ba81220',
                              contentProfileId: profile.id,
                              profileName: profile.name,
                              onSuccess: () {
                                setState(() {});
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showProfilePreview(BuildContext context, dynamic profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoicePreviewModal(
        profile: profile,
        onApply: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${profile.name} profile applied!'),
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
