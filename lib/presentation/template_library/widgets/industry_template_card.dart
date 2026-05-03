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
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title with color indicator
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: EdgeInsets.only(top: 2),
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
                  SizedBox(height: 8.0),

                  // Description with smart truncation
                  _DescriptionWithDetails(
                    description: profile.description,
                    onViewDetails: onTap,
                  ),

                  SizedBox(height: 8.0),

                  // Edit and Delete buttons (compact)
                  if (onEdit != null || onDelete != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onEdit != null)
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                onPressed: onEdit,
                                icon: Icon(Icons.edit, size: 16),
                                color: Color(0xFF2196F3),
                                splashRadius: 16,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          if (onDelete != null)
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                onPressed: onDelete,
                                icon: Icon(Icons.delete, size: 16),
                                color: Colors.red,
                                splashRadius: 16,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Smart description widget with truncation and details modal
class _DescriptionWithDetails extends StatefulWidget {
  final String description;
  final VoidCallback onViewDetails;

  const _DescriptionWithDetails({
    required this.description,
    required this.onViewDetails,
  });

  @override
  State<_DescriptionWithDetails> createState() =>
      _DescriptionWithDetailsState();
}

class _DescriptionWithDetailsState extends State<_DescriptionWithDetails> {
  late final _textPainter = TextPainter(
    text: TextSpan(
      text: widget.description,
      style: TextStyle(
        fontSize: 13.0,
        color: Color(0xFF666666),
        height: 1.45,
      ),
    ),
    maxLines: 2,
    textDirection: TextDirection.ltr,
  );

  late bool _isTruncated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 56);
      if (_textPainter.didExceedMaxLines) {
        setState(() => _isTruncated = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.description,
          style: TextStyle(
            fontSize: 13.0,
            color: Color(0xFF666666),
            height: 1.45,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (_isTruncated)
          Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Profile Details'),
                    content: SingleChildScrollView(
                      child: Text(widget.description),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  SizedBox(width: 3.0),
                  Icon(
                    Icons.arrow_forward,
                    size: 12.0,
                    color: Color(0xFF2196F3),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
