import 'package:flutter/material.dart';

class MetricSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String unitLabel;
  final IconData icon;
  final Color iconColor;
  final String statusText;

  const MetricSummaryCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unitLabel,
    required this.icon,
    this.iconColor = Colors.blue,
    this.statusText = 'Publish content to start tracking',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: value,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: unitLabel,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                icon,
                size: 32.0,
                color: iconColor,
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Container(
            height: 1.0,
            color: Color(0xFFE8E8E8),
          ),
          SizedBox(height: 12.0),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11.0,
              color: Color(0xFF999999),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
