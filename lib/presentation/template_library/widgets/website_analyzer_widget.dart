/// Website Analyzer Widget - Main feature for analyzing websites and recommending writing styles
///
/// This file contains all UI components related to website analysis:
///
/// 1. **WebsiteAnalyzerWidget** - Main stateful widget that combines input and results
///    - Manages URL input state via TextEditingController
///    - Uses Observer to reactively display different states (input, loading, results)
///    - Displays input section, loading state, and analysis results based on store state
///
/// 2. **WebsiteAnalysisResultCard** - Displays analysis results in an elegant card format
///    - Shows success state with check icon and recommended template
///    - Displays key analysis data: Target Audience, Content Tone, Analysis Details
///    - Includes "View Recommended Style" button that opens voice preview modal
///    - Handles navigation to VoicePreviewModal
///
/// 3. **WebsiteAnalysisLoadingState** - Shimmer loading skeleton while analyzing
///    - Shows placeholder boxes with animation effect
///    - Displays "Scanning website content..." message
///    - Uses static _buildShimmerBox helper for consistent placeholder styling

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:boilerplate/presentation/template_library/store/template_library_store.dart';
import 'package:boilerplate/presentation/template_library/widgets/voice_preview_modal.dart';

/// Widget for analyzing websites to recommend writing styles
class WebsiteAnalyzerWidget extends StatefulWidget {
  final TemplateLibraryStore store;

  const WebsiteAnalyzerWidget({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  State<WebsiteAnalyzerWidget> createState() => _WebsiteAnalyzerWidgetState();
}

class _WebsiteAnalyzerWidgetState extends State<WebsiteAnalyzerWidget> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.store.inputUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input section
                _buildInputSection(),
                SizedBox(height: 24.0),

                // Results section
                if (widget.store.isAnalyzing) WebsiteAnalysisLoadingState(),
                if (widget.store.analysisResult != null &&
                    !widget.store.isAnalyzing)
                  WebsiteAnalysisResultCard(
                    result: widget.store.analysisResult!,
                    store: widget.store,
                    context: context,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analyze Your Website',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          'Enter your website URL and we\'ll automatically recommend the best writing style for your brand.',
          style: TextStyle(
            fontSize: 13.0,
            color: Color(0xFF666666),
            height: 1.4,
          ),
        ),
        SizedBox(height: 16.0),
        // URL Input Field
        TextField(
          controller: _urlController,
          enabled: !widget.store.isAnalyzing,
          decoration: InputDecoration(
            hintText: 'e.g., https://www.example.com',
            hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
            prefixIcon: Icon(Icons.link, color: Color(0xFF999999)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Color(0xFF2196F3), width: 1.5),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          ),
          style: TextStyle(fontSize: 14.0, color: Color(0xFF333333)),
        ),
        SizedBox(height: 16.0),
        // Analyze Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.store.isAnalyzing
                ? null
                : () {
                    if (_urlController.text.isNotEmpty) {
                      widget.store.generateFromWebsite(_urlController.text);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
              disabledBackgroundColor: Color(0xFFCCCCCC),
              padding: EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 0,
            ),
            child: Text(
              widget.store.isAnalyzing ? 'Analyzing...' : 'Analyze Website',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Card widget for displaying website analysis results
class WebsiteAnalysisResultCard extends StatelessWidget {
  final WebsiteAnalysisResult result;
  final TemplateLibraryStore store;
  final BuildContext context;

  const WebsiteAnalysisResultCard({
    Key? key,
    required this.result,
    required this.store,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 32.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Color(0xFFE8E8E8), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF2196F3),
                      size: 24.0,
                    ),
                  ),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analysis Complete',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
                          'Recommended: ${result.recommendedTemplate}',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Divider(color: Color(0xFFE8E8E8), height: 1),
              SizedBox(height: 20.0),
              _buildResultField('Target Audience', result.targetAudience),
              SizedBox(height: 16.0),
              _buildResultField('Content Tone', result.contentTone),
              SizedBox(height: 16.0),
              _buildResultField('Analysis Details', result.analysisDetails),
              SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to template preview
                    final template = store.industryTemplates.firstWhere(
                      (t) => t.name == result.recommendedTemplate,
                      orElse: () => store.industryTemplates.first,
                    );
                    _showVoicePreviewModal(context, template);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2196F3),
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'View Recommended Style',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 6.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.0,
            color: Color(0xFF333333),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _showVoicePreviewModal(BuildContext context, dynamic template) {
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
            ),
          );
        },
      ),
    );
  }
}

/// Loading state widget with shimmer skeleton
class WebsiteAnalysisLoadingState extends StatelessWidget {
  const WebsiteAnalysisLoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 32.0),
        Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Color(0xFFE8E8E8), width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBox(width: 200, height: 20),
              SizedBox(height: 16.0),
              _buildShimmerBox(width: double.infinity, height: 14),
              SizedBox(height: 8.0),
              _buildShimmerBox(width: double.infinity, height: 14),
              SizedBox(height: 8.0),
              _buildShimmerBox(width: 250, height: 14),
              SizedBox(height: 24.0),
              _buildShimmerBox(width: 280, height: 16),
              SizedBox(height: 8.0),
              _buildShimmerBox(width: double.infinity, height: 14),
              SizedBox(height: 8.0),
              _buildShimmerBox(width: double.infinity, height: 14),
            ],
          ),
        ),
        SizedBox(height: 16.0),
        Text(
          'Scanning website content...',
          style: TextStyle(
            fontSize: 12.0,
            color: Color(0xFF999999),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  static Widget _buildShimmerBox(
      {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(6.0),
      ),
    );
  }
}
