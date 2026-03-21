import 'package:flutter/material.dart';
import 'dart:math' as math;

class VisibilityScoreWidget extends StatelessWidget {
  final double score;
  final double suggestedBenchmark;
  final bool isLoading;

  const VisibilityScoreWidget({
    Key? key,
    required this.score,
    required this.suggestedBenchmark,
    this.isLoading = false,
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
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Brand Visibility Score',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline,
                    size: 18.0, color: Color(0xFF999999)),
                onPressed: () {
                  // Show info about brand visibility score
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Brand Visibility Score measures your brand presence across digital channels.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                constraints: BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: 24.0),
          Center(
            child: SizedBox(
              width: 120.0,
              height: 120.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  CustomPaint(
                    size: Size(120.0, 120.0),
                    painter: CircleProgressPainter(
                      progress: 0.0,
                      backgroundColor: Color(0xFFE8E8E8),
                      progressColor: Color(0xFFE8E8E8),
                    ),
                  ),
                  // Score circle
                  CustomPaint(
                    size: Size(120.0, 120.0),
                    painter: CircleProgressPainter(
                      progress: score / 100.0,
                      backgroundColor: Color(0xFFE8E8E8),
                      progressColor: Color(0xFFFF5252),
                    ),
                  ),
                  // Center text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLoading ? '--' : score.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF5252),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.0),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current score',
                      style: TextStyle(
                        fontSize: 11.0,
                        color: Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      isLoading ? '--' : score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 30.0,
                  width: 1.0,
                  color: Color(0xFFDDDDDD),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Suggested benchmark',
                      style: TextStyle(
                        fontSize: 11.0,
                        color: Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '${suggestedBenchmark.toStringAsFixed(0)}+',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0066CC),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  CircleProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 3.0;

    // Draw background circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc (only if progress > 0)
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}
