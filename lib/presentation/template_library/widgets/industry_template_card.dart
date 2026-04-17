import 'package:flutter/material.dart';
import 'package:boilerplate/domain/entity/content/content_profile.dart';

/// Card widget for displaying individual content profile templates
class IndustryTemplateCard extends StatelessWidget {
  final ContentProfile profile;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const IndustryTemplateCard({
    Key? key,
    required this.profile,
    required this.onTap,
    this.onEdit,
    this.onDelete,
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
                  // Title with color indicator
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          profile.name,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  // Description
                  Text(
                    profile.description,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16.0),
                  // Action buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // View Details button
                      Expanded(
                        child: GestureDetector(
                          onTap: onTap,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'View Details',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                              SizedBox(width: 4.0),
                              Icon(
                                Icons.arrow_forward,
                                size: 14.0,
                                color: Color(0xFF2196F3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Edit and Delete buttons
                  if (onEdit != null || onDelete != null) ...[
                    SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onEdit != null)
                          Tooltip(
                            message: 'Edit Profile',
                            child: IconButton(
                              onPressed: onEdit,
                              icon: Icon(Icons.edit, size: 18),
                              color: Color(0xFF2196F3),
                              splashRadius: 20,
                              padding: EdgeInsets.zero,
                              constraints:
                                  BoxConstraints(minWidth: 36, minHeight: 36),
                            ),
                          ),
                        if (onDelete != null)
                          Tooltip(
                            message: 'Delete Profile',
                            child: IconButton(
                              onPressed: onDelete,
                              icon: Icon(Icons.delete, size: 18),
                              color: Colors.red,
                              splashRadius: 20,
                              padding: EdgeInsets.zero,
                              constraints:
                                  BoxConstraints(minWidth: 36, minHeight: 36),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
