import 'package:flutter/material.dart';
import 'package:boilerplate/presentation/template_library/models/writing_style_model.dart';

/// Card widget for displaying individual writing style templates
class IndustryTemplateCard extends StatelessWidget {
  final WritingStyleModel style;
  final VoidCallback onTap;

  const IndustryTemplateCard({
    Key? key,
    required this.style,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Color(0xFFE8E8E8), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.04),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color indicator and title
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _parseColor(style.color),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              style.name,
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF333333),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              style.industry,
                              style: TextStyle(
                                fontSize: 11.0,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  // Description
                  Text(
                    style.description,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.0),
                  // Preview tags
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: [
                      _buildPreviewTag('Voice', style.voice),
                      _buildPreviewTag('Tone', style.tone),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  // View details button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: _parseColor(style.color),
                        ),
                      ),
                      SizedBox(width: 4.0),
                      Icon(
                        Icons.arrow_forward,
                        size: 14.0,
                        color: _parseColor(style.color),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewTag(String label, String content) {
    final preview = content.split('.').first.replaceAll(RegExp(r'[,;]'), '');
    final displayText =
        preview.length > 20 ? '${preview.substring(0, 17)}...' : preview;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: _parseColor(style.color).withOpacity(0.08),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: _parseColor(style.color).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 10.0,
          color: _parseColor(style.color),
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
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
