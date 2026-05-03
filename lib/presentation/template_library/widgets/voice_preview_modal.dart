import 'package:flutter/material.dart';
import 'package:boilerplate/domain/entity/content/content_profile.dart';

/// Modal for previewing content profile details
class VoicePreviewModal extends StatelessWidget {
  final ContentProfile profile;
  final VoidCallback onApply;

  const VoicePreviewModal({
    Key? key,
    required this.profile,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        profile.projectId,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    profile.description,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Color(0xFF666666),
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 28.0),
                  // Content Details
                  _buildDetailSection('Voice & Tone', profile.voiceAndTone),
                  SizedBox(height: 20.0),
                  _buildDetailSection('Target Audience', profile.audience),
                  SizedBox(height: 28.0),
                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2196F3),
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Apply This Profile',
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
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 80.0),
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
}
