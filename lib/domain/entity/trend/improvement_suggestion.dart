import 'package:flutter/material.dart';

class ImprovementSuggestion {
  final String title;
  final String description;
  final String priority; // 'High', 'Medium', 'Low'
  final String relatedMetric; // "Brand Visibility", "Sentiment"...
  final IconData icon;

  ImprovementSuggestion({
    required this.title,
    required this.description,
    required this.priority,
    required this.relatedMetric,
    required this.icon,
  });
}
