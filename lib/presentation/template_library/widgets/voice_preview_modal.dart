import 'package:flutter/material.dart';

/// Modal for previewing voice and style details
class VoicePreviewModal extends StatelessWidget {
  final dynamic template;
  final VoidCallback onApply;

  const VoicePreviewModal({
    Key? key,
    required this.template,
    required this.onApply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _parseColor(template.color),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.name,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF333333),
                              ),
                            ),
                            Text(
                              template.industry,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    template.description,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Color(0xFF666666),
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 28.0),
                  // Voice & Tone Details
                  _buildDetailSection('Voice', template.voice),
                  SizedBox(height: 20.0),
                  _buildDetailSection('Tone', template.tone),
                  SizedBox(height: 20.0),
                  _buildDetailSection('Target Audience', template.audience),
                  SizedBox(height: 28.0),
                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _parseColor(template.color),
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Apply This Style',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF666666),
                        side: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Color(0xFFE8E8E8), width: 1.0),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 13.0,
              color: Color(0xFF555555),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xff')));
    } catch (e) {
      return Color(0xFF2196F3);
    }
  }
}
