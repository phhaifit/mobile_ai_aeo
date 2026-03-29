import 'package:flutter/material.dart';

class MetricTrendCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String unitLabel;
  final double changePercent;
  final bool isImproved;
  final IconData icon;
  final Color iconColor;

  const MetricTrendCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.unitLabel,
    required this.changePercent,
    required this.isImproved,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final changeColor = isImproved ? Colors.green : Colors.red;
    final changeIcon = isImproved ? Icons.arrow_upward : Icons.arrow_downward;
    final changeText = '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20.0,
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (unitLabel.isNotEmpty) ...[
                SizedBox(width: 2.0),
                Text(
                  unitLabel,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.0),
          Row(
            children: [
              Icon(
                changeIcon,
                color: changeColor,
                size: 16.0,
              ),
              SizedBox(width: 4.0),
              Text(
                changeText,
                style: TextStyle(
                  color: changeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
              ),
              SizedBox(width: 4.0),
              Text(
                'vs last week',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
