import 'package:flutter/material.dart';

class ContentStrategyWidget extends StatelessWidget {
  const ContentStrategyWidget({Key? key}) : super(key: key);

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
          Text(
            'Brand content strategy',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Step-by-step guidance to improve your brand content strategy',
            style: TextStyle(
              fontSize: 12.0,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.0),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 40.0,
                  color: Color(0xFFCCCCCC),
                ),
                SizedBox(height: 12.0),
                Text(
                  'Strategic content recommendations\nwill appear here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Color(0xFF999999),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Coming soon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.0,
                    color: Color(0xFFBBBBBB),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
