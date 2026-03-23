import 'package:flutter/material.dart';
import '../util/history_utils.dart';

/// Badge widget displaying execution status
/// 
/// Shows status with icon and label, color-coded by status type
class ExecutionStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final EdgeInsets padding;

  const ExecutionStatusBadge({
    Key? key,
    required this.status,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color(getStatusColor(status));
    final symbol = getStatusSymbol(status);
    final label = getStatusLabel(status);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        border: Border.all(color: backgroundColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            symbol,
            style: TextStyle(
              color: backgroundColor,
              fontSize: fontSize + 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: backgroundColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
